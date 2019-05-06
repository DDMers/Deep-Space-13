//This contains all the parts for the warp engine
/*

Activation sequence:
Complete the deuterium + anti deuterium injectors (they start semi finished)
Open deut + anti deut transmission manifolds to feed the injectors
Set transmission ratio such that it�s 0.5 : 0.5 for a stable reaction
Add dilithium to dilithium matrix
Realign dilithium matrix to your desired spec
Insert dilithium matrix into core
Activate matter + antimatter stream (turn on injectors)
Monitor the reaction for instability

*/
/obj/machinery/proc/default_radial_toggle(var/mob/user)
	if(!allowed(user))
		visible_message("<span class='notice'>You need an engineering level ID to access this machine.</span>")
		return
	var/list/options = list("on", "off")
	for(var/option in options)
		options[option] = image(icon = 'DS13/icons/actions/engine_actions.dmi', icon_state = "[option]")
	var/dowhat = show_radial_menu(user,src,options)
	if(!dowhat)
		return
	return dowhat

/obj/machinery/power/matter_injector
	name = "matter stream injector"
	desc = "A huge device used to inject matter into a controlled antimatter reaction system for the purpose of power generation."
	icon = 'DS13/icons/obj/power/warpcore/injectors.dmi'
	icon_state = "injector-1"
	anchored = TRUE
	density = TRUE
	var/active = FALSE
	var/obj/machinery/power/warp_core/core //We need one of these.
	var/injects_matter = TRUE //set to false for antimatter injector
	var/construction_state = "cables"
	var/can_activate = FALSE //Are we built and ready?
	var/toggleable = TRUE //Is the core about to breach? Block them from turning us off.
	obj_integrity = 300 //Super tough.
	req_access = list(ACCESS_ENGINE_EQUIP)

/obj/machinery/power/matter_injector/attackby(obj/item/W, mob/user, params) //Steps: Cables, screwdriver, crowbar
	if(istype(W, /obj/item/stack/cable_coil))
		if(construction_state != "cables")
			return ..()
		var/obj/item/stack/cable_coil/CC = W
		to_chat(user, "<span class='notice'>You start to add some cables to [src]'s isolinear circuitry.</span>")
		if(do_after(user, 30, target = src))
			if(CC.use(1))
				user.visible_message("[user.name] adds wires to the [name].", \
				"You add some wires.")
				construction_state = "screwdriver"
	. = ..()

/obj/machinery/power/matter_injector/attackby(obj/item/I,mob/user)
	if(default_unfasten_wrench(user, I))
		return FALSE
	. = ..()

/obj/machinery/power/matter_injector/screwdriver_act(mob/user, obj/item/I)
	if(construction_state == "screwdriver")
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start to fasten [src]'s isolinear circuitry.</span>")
		if(do_after(user, 30, target = src))
			construction_state = "crowbar"
			icon_state = "injector-2"
		return TRUE

/obj/machinery/power/matter_injector/crowbar_act(mob/user, obj/item/I)
	if(construction_state == "crowbar")
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start to replace [src]'s cover.</span>")
		if(do_after(user, 30, target = src))
			to_chat(user, "<span class='notice'>You replace [src]'s cover.</span>")
			construction_state = "finished"
			icon_state = "injector"
			can_activate = TRUE
		return TRUE

/obj/machinery/power/matter_injector/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/power/matter_injector/attack_hand(mob/user)
	. = ..()
	if(!can_activate)
		return
	var/dowhat = default_radial_toggle(user)
	switch(dowhat)
		if("on")
			set_active(TRUE)
		if("off")
			set_active(FALSE)

/obj/machinery/power/matter_injector/proc/set_active(var/bool) //Set active true or false.
	if(!toggleable)
		playsound(src, 'DS13/sound/effects/warpcore/unabletocomply.ogg', 100, 0)//You have to wait until above 50% containment
		visible_message("<span_class='notice'>Warp core breach in progress</span>")
		return
	if(bool)
		active = TRUE
		icon_state = "injector-low"
		playsound(loc, 'DS13/sound/effects/computer/power_up.ogg', 100, 1)
		if(core)
			core.start()
			if(injects_matter)
				core.matter_stream = TRUE
			else
				core.antimatter_stream = TRUE
	else
		active = FALSE
		icon_state = "injector"
		playsound(loc, 'DS13/sound/effects/computer/power_down.ogg', 100, 1)
		if(core)
			if(injects_matter)
				core.matter_stream = FALSE
			else
				core.antimatter_stream = FALSE

/obj/machinery/power/matter_injector/antimatter
	name = "Anti-Matter stream injector"
	desc = "A huge device used to inject antimatter into a controlled antimatter reaction system for the purpose of power generation."
	injects_matter = FALSE

/obj/machinery/power/matter_injector/Initialize()
	. = ..()
	core = locate(/obj/machinery/power/warp_core) in get_area(src)
	if(injects_matter)
		core.MI = src
	else
		core.AI = src

/obj/item/dilithium_matrix //An interface for a dilithium crystal. It will take damage in the core based on how hot the reaction is. When it starts to get out of alignment you have to take it out and realign it with a safe cracking minigame.
	name = "Dilithium matrix"
	desc = "A device designed to harness the power of a dilithium crystal for interstellar travel. It needs occasional realignment"
	icon = 'DS13/icons/obj/power/warpcore/machines.dmi'
	icon_state = "matrix"
	var/alignment = 100 //this is damaged per tick based on how well youve aligned it. If this reaches 0 youre looking at a core breach as it regulates  the matter annihilation reaction
	var/max_alignment = 100
	var/obj/item/dilithium/stored
	var/target_freq = 1
	var/freq = 5
	var/combo_target = "omega" //Randomized sequence for the recalibration minigame.
	var/list/letters = list("delta,", "omega,", "phi,")
	var/combo = null
	var/combocount = 0 //How far into the combo are they?

/obj/item/dilithium_matrix/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='warning'>[src]'s realignment sequence is: [combo_target].</span>")

/obj/item/dilithium_matrix/Initialize()
	. = ..()
	combo_target = "[pick(letters)][pick(letters)][pick(letters)][pick(letters)][pick(letters)]"

/obj/item/dilithium_matrix/proc/absorb_damage(var/amount)
	alignment -= amount
	if(alignment > 0)
		return TRUE
	if(alignment <= 0)
		qdel(stored)
		stored = null
		alignment = 0
		icon_state = "matrix"
		visible_message("<span class='warning'>[src]'s dilithium crystal shatters!</span>")
		return FALSE

/obj/item/dilithium_matrix/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/dilithium))
		to_chat(user, "<span class='notice'>You slot [W] into [src].</span>")
		W.forceMove(src)
		stored = W
		icon_state = "matrix-dilithium"
		playsound(src, 'DS13/sound/effects/warpcore/loader_step1.ogg', 50, 1)

/obj/item/dilithium_matrix/attack_self(mob/user)
	var/sound/thesound = pick(GLOB.bleeps)
	SEND_SOUND(user, thesound)
	var/list/options = letters
	for(var/option in options)
		options[option] = image(icon = 'DS13/icons/actions/engine_actions.dmi', icon_state = "[option]")
	var/dowhat = show_radial_menu(user,src,options)
	if(!dowhat)
		return
	combo += "[dowhat]"
	combocount ++
	to_chat(user, "<span class='warning'>You inputted [dowhat] into the command sequence.</span>")
	playsound(src, 'sound/machines/sm/supermatter3.ogg', 20, 1)
	if(combocount <= 4)
		addtimer(CALLBACK(src, .proc/attack_self, user), 2)
	if(combocount >= 5) //Completed the sequence
		if(combo == combo_target)
			to_chat(user, "<span class='warning'>Realignment of dilithium matrix complete.</span>")
			playsound(src, 'sound/machines/sm/supermatter1.ogg', 30, 1)
			alignment = max_alignment
		else
			to_chat(user, "<span class='warning'>Realignment failed. Continued failure risks damage to dilithium crystal sample. Rotating command sequence.</span>")
			playsound(src, 'DS13/sound/effects/warpcore/overload.ogg', 100, 1)
			combo_target = "[pick(letters)][pick(letters)][pick(letters)][pick(letters)][pick(letters)]"
			absorb_damage(5) //Penalty for fucking it up. You risk destroying the crystal...
		combocount = 0
		combo = null

//HOW TO RATIO:
//LITTLE NUMBER / BIG NUMBER:
// 15/30 ->  0.5
/*

The antimatter | matter ratio is preset and constant, if it's powered. It gives a preset amount of power. The fun comes from maintaining it.

*/

/datum/supply_pack/engine/dilithium_matrix
	name = "Dilithium Matrix Crate"
	desc = "A replacement dilithium matrix and crystal sample for repairing warp cores. Requires engineering access to open."
	cost = 10000
	access = ACCESS_ENGINE_EQUIP
	contains = list(/obj/item/dilithium_matrix,/obj/item/dilithium)
	crate_name = "Dilithium Matrix Crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/obj/machinery/power/warp_core //here's where the magic happens. This thing takes matter and antimatter. The ratio at which theyre supplied determines the power output and chance of EXPLODING
	name = "warp core"
	desc = "A gigantic machine that amounts to a reaction chamber. It is fitted with magnetic constrictors for the containment of highly volatile antimatter while also being linked to the ship's matter and antimatter injectors which provide a reaction substrate."
	icon = 'DS13/icons/obj/power/warpcore/core.dmi'
	icon_state = "core-empty"
	pixel_x = -29
	layer = 4
	anchored = TRUE
	density = TRUE
	use_power = 0
	obj_integrity = 300 //Super tough.
	var/active = FALSE //Starts off. You have to power it with injectors.
	var/toggleable = TRUE //If you leave it to breach for too long, you'll no longer be able to turn it off!
	var/obj/machinery/atmospherics/components/binary/pump/outlet
	var/matter_stream = FALSE
	var/antimatter_stream = FALSE
	var/obj/machinery/power/matter_injector/MI
	var/obj/machinery/power/matter_injector/antimatter/AI
	var/obj/item/dilithium_matrix/dilithium_matrix
	var/datum/looping_sound/warp/soundloop
	var/containment = 100 //Don't let this drop to 0
	var/max_containment = 100
	var/breaching = FALSE //used to avoid soundspam
	var/ejected = FALSE //B'ELANNA, EJECT THE CORE
	var/ejecting = FALSE
	var/obj/structure/overmap/linked
	var/obj/item/radio/Radio
	var/voice_ready = TRUE //radio announcement
	var/voice_cooldown = 300
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/list/coils = list() //fuck I burnt my coil cyka
	req_access = list(ACCESS_ENGINE_EQUIP)

/obj/structure/ejected_core
	name = "Warp core frame"
	desc = "A warp core reactor housing that has been ejected. It is completely inert and unable to produce power."
	icon = 'DS13/icons/obj/power/warpcore/core.dmi'
	icon_state = "core-ejected"
	pixel_x = -29
	layer = 4

/obj/machinery/power/warp_core/proc/try_warp()
	if(!coils.len || !active())
		return FALSE
	for(var/X in coils)
		var/obj/machinery/power/warp_coil/V = X
		if(!V.active())
			return FALSE
	return TRUE

/obj/machinery/power/warp_core/crowbar_act(mob/user, obj/item/I)
	if(toggleable && dilithium_matrix)
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start to prize out [src]'s dilithium matrix.</span>")
		if(do_after(user, 50, target = src))
			log_game("[key_name(user)] removed a dilithium matrix from a warp core at [get_area(src)]. (Core integrity: [containment]%, Alignment:[dilithium_matrix.alignment]%")
			message_admins("[key_name_admin(user)] removed a dilithium matrix from a warp core at [get_area(src)]. (Core integrity: [containment]%, Alignment:[dilithium_matrix.alignment]%")
			to_chat(user, "<span class='notice'>You remove [src]'s dilithium matrix.</span>")
			icon_state = "core-empty"
			dilithium_matrix.forceMove(get_step(src, SOUTH))
			dilithium_matrix = null
		return TRUE
	if(!toggleable && dilithium_matrix)
		playsound(src, 'DS13/sound/effects/warpcore/critical.ogg', 100, 0)//You have to wait until above 50% containment
		visible_message("<span_class='notice'>[src]'s interface locks are fused!</span>")
		return TRUE

/obj/machinery/power/warp_core/default_radial_toggle(var/mob/user) //Overriding to allow core ejection.
	if(!allowed(user))
		visible_message("<span class='notice'>You need an engineering level ID to access this machine.</span>")
		return
	var/list/options = list("on", "off", "eject","cancel_eject")
	for(var/option in options)
		options[option] = image(icon = 'DS13/icons/actions/engine_actions.dmi', icon_state = "[option]")
	var/dowhat = show_radial_menu(user,src,options)
	if(!dowhat)
		return
	return dowhat

/obj/machinery/power/warp_core/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/power/warp_core/attack_hand(mob/user)
	if(!allowed(user))
		visible_message("<span class='notice'>You need an engineering level ID to access this machine.</span>")
		return
	var/dowhat = default_radial_toggle(user)
	switch(dowhat)
		if("on")
			set_active(TRUE)
			log_game("[key_name(user)] activated a warp core")
		if("off")
			set_active(FALSE)
			log_game("[key_name(user)] deactivated a warp core")
		if("eject")
			eject(user)
		if("cancel_eject")
			cancel_eject(user)

/obj/machinery/power/warp_core/proc/cancel_eject(var/mob/user)
	if(!ejecting)
		to_chat(user, "<span class='warning>There is no active ejection sequence in progress.</span>")
		return
	if(!allowed(user))
		visible_message("<span class='notice'>Unable to comply. You do not have sufficient access to cancel a core ejection.</span>")
		return
	log_game("[key_name(user)] cancelled a warp core ejection")
	message_admins("[key_name_admin(user)] cancelled a warp core ejection")
	visible_message("<span class='notice'>Warp core ejection sequence cancelled!</span>")
	ejecting = FALSE

/obj/machinery/power/warp_core/proc/eject(var/mob/user)
	if(!allowed(user))
		visible_message("<span class='notice'>Unable to comply. You do not have sufficient access to perform a core ejection.</span>")
		return
	if(ejecting)
		visible_message("<span class='notice'>Unable to comply. Core ejection already in progress!</span>")
		return
	var/question = alert("Eject the warp core? This can have serious consequences if done outside of an emergency.",name,"yes","no")
	if(question == "no" || !question)
		return
	log_game("[key_name(user)] triggered a warp core ejection")
	message_admins("[key_name_admin(user)] triggered a warp core ejection")
	visible_message("<span class='notice'>Warp core ejection sequence activated!</span>")
	ejecting = TRUE
	addtimer(CALLBACK(src, .proc/eject_finish), 115)
	var/area/A = get_area(src)
	var/obj/structure/overmap/F
	if(A.linked_overmap)
		F = A.linked_overmap //relay some sounds to the crew.
	if(F && F.main_overmap)
		for(var/mob/player in GLOB.player_list)
			if(is_station_level(player.z))
				SEND_SOUND(player, 'DS13/sound/effects/warpcore/eject_core.ogg')
	else
		playsound(src, 'DS13/sound/effects/warpcore/eject_core.ogg', 100, 0)

/obj/machinery/power/warp_core/proc/eject_finish()
	if(!ejecting) //Someone cancelled the ejection.
		return
	new /obj/structure/ejected_core(get_turf(src))
	qdel(src) //You successfully ejected the core!
	for(var/X in active_timers) //To avoid null pointers.
		qdel(X)

/obj/machinery/power/warp_core/proc/set_active(var/bool)
	if(!toggleable)
		playsound(src, 'DS13/sound/effects/warpcore/unabletocomply.ogg', 100, 0)//You have to wait until above 50% containment
		visible_message("<span_class='notice'>Antimatter containment is at [containment]%. Scanner relays cannot function below 50% containment for safety reasons.</span>")
		return
	if(bool)
		start()
	else
		stop()

/obj/machinery/power/warp_core/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='warning'>Antimatter containment is at [containment]%</span>")
	if(dilithium_matrix)
		to_chat(user, "<span class='notice'><i>Dilithium matrix alginment is at [dilithium_matrix.alignment]%</i></span>")

/obj/machinery/power/warp_core/Initialize()
	. = ..()
	soundloop = new(list(src), FALSE)
	find_overmap()
	Radio = new /obj/item/radio(src)
	Radio.keyslot = new radio_key
	Radio.listening = 0
	Radio.recalculateChannels()
	for(var/X in get_area(src))
		if(istype(X, /obj/machinery/power/warp_coil))
			var/obj/machinery/power/warp_coil/V = X
			coils += V

/obj/machinery/power/warp_core/proc/find_overmap()
	var/area/A = get_area(src)
	var/obj/structure/overmap/F
	if(A.linked_overmap)
		F = A.linked_overmap //relay some sounds to the crew.
	if(F)
		F.warp_core = src
		linked = F

/datum/looping_sound/warp
	start_length = 0
	mid_sounds = list('DS13/sound/effects/warp_hum.ogg')
	mid_length = 20
	volume = 100

/obj/machinery/power/warp_core/update_icon()
	if(!dilithium_matrix)
		icon_state = "core-empty"
		return
	if(!active)
		icon_state = "core"
		return
	else
		icon_state = "core-on"
	if(containment < 0)
		icon_state = "core-fast"
	switch(containment)
		if(0 to 19)
			icon_state = "core-fast"
		if(20 to 50)
			icon_state = "core-medium"

/obj/machinery/power/warp_core/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/dilithium_matrix) && !dilithium_matrix)
		var/obj/item/dilithium_matrix/M = I
		if(!M.stored)
			to_chat(user, "<span class='warning'>That dilithium matrix lacks a dilithium crystal!</span>")
			return ..()
		to_chat(user, "<span class='notice'>You start to slot [I] into [src]</span>")
		if(do_after(user, 50, target=src))
			playsound(src, 'DS13/sound/effects/FTL/load.ogg', 50, 1)
			I.forceMove(src)
			dilithium_matrix = I
			update_icon()
			start()
			return FALSE
	. = ..()

/obj/machinery/power/warp_core/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(Radio)
	. = ..()

/obj/machinery/power/warp_core/proc/start()
	if(!active())
		return
	active = TRUE
	soundloop.start()

/obj/machinery/power/warp_core/proc/stop()
	soundloop.stop()
	active = FALSE

/obj/machinery/power/warp_core/proc/active()
	if(QDELETED(MI) || !MI)
		MI = null
		return FALSE
	if(QDELETED(AI) || !AI)
		AI = null
		return FALSE
	if(!matter_stream || !antimatter_stream)
		return FALSE
	return TRUE

/obj/machinery/power/warp_core/process()
	update_icon()
	if(!linked)
		find_overmap()
	if(!active) //Not turned on. Don't process.
		return
	if(!outlet)
		outlet = locate(/obj/machinery/atmospherics/components/binary/pump) in get_step(src, SOUTH)
	if(!outlet.airs || !active())
		stop()
		return
	check_failure()
	announce_radio()
	if(!dilithium_matrix)
		return
	var/penalty = 0.1 //You need to realign every 30 minutes or so.
	dilithium_matrix.absorb_damage(penalty)
	for(var/datum/gas_mixture/S in outlet.airs)
		if(S.gases[/datum/gas/plasma])
			S.gases[/datum/gas/plasma][MOLES] += 10 //Add some extra plasma to it.
			S.garbage_collect()
	var/power = 800000
	add_avail(power)

/obj/machinery/power/warp_core/proc/reset_voice()
	voice_ready = TRUE

/obj/machinery/power/warp_core/proc/announce_radio() //Warn the engis of specific events.
	if(!voice_ready)
		return FALSE
	switch(containment)
		if(0 to 20) //When it hits 20%. The engis need to know it's almost the point of no return.
			Radio.talk_into(src,"WARNING: Antimatter containment failure imminent! Evacuate engineering immediately!. Containment is at [containment]%.","Engineering",get_spans(),get_default_language())
			say("WARNING: Antimatter containment failure imminent! Evacuate engineering immediately!. Containment is at [containment]%.")
			addtimer(CALLBACK(src, .proc/reset_voice), voice_cooldown)
			voice_ready = FALSE
			return TRUE
		if(21 to 50) //When it hits 50%. Warn the engineers. It's outside of the switch so it isn't spammed.
			Radio.talk_into(src,"WARNING: Antimatter containment failing. Containment is at [containment]%.","Engineering",get_spans(),get_default_language())
			say("WARNING: Antimatter containment failing. Containment is at [containment]%.")
			addtimer(CALLBACK(src, .proc/reset_voice), voice_cooldown)
			voice_ready = FALSE
			return TRUE
	if(dilithium_matrix)
		switch(dilithium_matrix.alignment)
			if(0 to 10)
				Radio.talk_into(src,"WARNING: Dilithium matrix destabilization imminent!. Matrix alignment: [dilithium_matrix.alignment]%.","Engineering",get_spans(),get_default_language())
				say("WARNING: Dilithium matrix destabilization imminent!. Matrix alignment: [dilithium_matrix.alignment]%.")
				addtimer(CALLBACK(src, .proc/reset_voice), voice_cooldown)
				voice_ready = FALSE
				return TRUE
			if(11 to 30)
				Radio.talk_into(src,"WARNING: Dilithium matrix is poorly aligned. Matrix alignment: [dilithium_matrix.alignment]%.","Engineering",get_spans(),get_default_language())
				say("WARNING: Dilithium matrix is poorly aligned. Matrix alignment: [dilithium_matrix.alignment]%.")
				addtimer(CALLBACK(src, .proc/reset_voice), voice_cooldown)
				voice_ready = FALSE
				return TRUE
	return FALSE

/obj/machinery/power/warp_core/proc/check_failure() //In other words. They've turned it on, but it's not got anything to regulate the reaction, so it'll fail quickly
	if(!dilithium_matrix || QDELETED(dilithium_matrix) || !dilithium_matrix.stored)
		var/area/A = get_area(src)
		var/obj/structure/overmap/F
		if(A.linked_overmap)
			F = A.linked_overmap //relay some sounds to the crew.
		if(F && F.main_overmap)
			for(var/mob/player in GLOB.player_list)
				if(is_station_level(player.z) && player)
					SEND_SOUND(player, 'DS13/sound/effects/warpcore/containment_failing.ogg')
		else
			playsound(loc, 'DS13/sound/effects/warpcore/containment_failing.ogg', 100, 1)
		containment --
		switch(containment)
			if(0)
				if(breaching)
					return
				breach()
				return //Kaboom.
			if(1 to 9)
				playsound(loc, 'DS13/sound/effects/warpcore/warpcore_collapse_warning.ogg', 100, 0)
				icon_state = "core-fast"
				toggleable = FALSE //No going back. You're facing a warp core breach. By this point you need to eject the core
				overload_injectors(TRUE)
			if(10 to 19)
				playsound(loc, 'DS13/sound/effects/warpcore/finalalert.ogg', 100, 1)
				icon_state = "core-fast"
				toggleable = FALSE //No going back. You're facing a warp core breach. By this point you need to eject the core
				overload_injectors(TRUE)
			if(20 to 49)
				playsound(loc, 'DS13/sound/effects/warpcore/critical.ogg', 100, 1)
				icon_state = "core-medium"
			if(50 to 80)
				playsound(loc, 'DS13/sound/effects/warpcore/unregulated_reaction.ogg', 100, 1)
				icon_state = "core-on"
	else
		if(containment < max_containment) //It will become toggleable again after the reaction stabilises
			containment += 0.5
		if(containment >= 50)
			toggleable = TRUE
			overload_injectors(FALSE)

/obj/machinery/power/warp_core/proc/overload_injectors(var/bool)
	if(bool) //TRUE means overload them, false means reset overload.
		if(AI && MI)
			AI.toggleable = FALSE
			AI.icon_state = "injector-high"
			playsound(AI.loc, 'DS13/sound/effects/warpcore/overload.ogg', 100, 1)
			MI.toggleable = FALSE
			MI.icon_state = "injector-high"
			playsound(MI.loc, 'DS13/sound/effects/warpcore/overload.ogg', 100, 1)
	else
		if(AI && MI)
			AI.toggleable = TRUE
			if(AI.active)
				AI.icon_state = "injector-low"
			else
				AI.icon_state = initial(AI.icon_state)
			MI.toggleable = TRUE
			if(MI.active)
				MI.icon_state = "injector-low"
			else
				MI.icon_state = initial(AI.icon_state)

/obj/machinery/power/warp_core/proc/breach(var/forced = FALSE) //You have 45 seconds to eject the core before you go up in flames.
	if(breaching)
		return
	breaching = TRUE
	var/area/A = get_area(src)
	var/obj/structure/overmap/F
	if(A.linked_overmap)
		F = A.linked_overmap //relay some sounds to the crew.
	if(F && F.main_overmap)
		for(var/mob/player in GLOB.player_list)
			var/area/AA = get_area(player)
			if(is_station_level(player.z) && GLOB.teleportlocs[AA.name])
				SEND_SOUND(player, 'DS13/sound/effects/damage/corebreach.ogg')
	var/turf/T = get_turf(src)//Shit out some plasma for good measure.
	T.atmos_spawn_air("plasma=20;TEMP=1000")
	if(!forced)
		if(!F.warp_core)
			F.warp_core = src
		F.explode()

/obj/machinery/atmospherics/components/binary/pump/on/warp
	name = "Plasma outlet manifold"
	desc = "This regulator serves as an outlet for heated warp plasma from the warp core"
	icon = 'DS13/icons/obj/power/warpcore/machines.dmi'
	anchored = TRUE
	density = FALSE
	layer = 2.35 //Hidden

/obj/machinery/power/eps_conduit
	name = "Eps power tap"
	desc = "A conduit which taps a percentage of the power outputted by a warp core for powering secondary systems."
	icon = 'DS13/icons/obj/power/warpcore/machines.dmi'
	icon_state = "eps_tap"
	anchored = TRUE
	density = FALSE
	pixel_y = 32 //it sits on the wall

/obj/item/dilithium
	name = "Dilithium crystal cluster"
	desc = "An extremely rare and valuable element which the whole of society is completely dependant on. It allows for faster than light travel."
	icon = 'DS13/icons/obj/power/warpcore/machines.dmi'
	icon_state = "dilithium"

/obj/machinery/power/warp_coil
	name = "warp coil"
	desc = "A huge ring of verterium cortenide which when provided with high energy warp plasma, will produce a subspace distortion field rated to a maximum of 300 cochranes, you shouldn't get too close when it's active."
	icon = 'DS13/icons/obj/machinery/warpcoil.dmi'
	icon_state = "warpcoil"
	pixel_x = -30
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	anchored = TRUE
	density = FALSE
	obj_integrity = 300
	use_power = 20000
	var/drain = 1.25 //Moles. How quickly it eats plasma from the air.

/obj/machinery/power/warp_coil/Initialize()
	. = ..()

/obj/machinery/power/warp_coil/process()
	active()

/obj/machinery/power/warp_coil/proc/active() //So our plasma provides the energy for the cochranes, then these beauties sap it all out for warp energy
	icon_state = "warpcoil"
	if(!anchored || !powered())
		return FALSE
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/air = T.return_air()
	if(air.gases[/datum/gas/plasma])
		if(air.gases[/datum/gas/plasma][MOLES] < drain)
			return FALSE
		icon_state = "warpcoil-hot"
		var/gasdrained = min(drain,air.gases[/datum/gas/plasma][MOLES])
		air.gases[/datum/gas/plasma][MOLES] -= gasdrained
		air.garbage_collect()
		radiation_pulse(src, 1000, 5)
		return TRUE
	return FALSE