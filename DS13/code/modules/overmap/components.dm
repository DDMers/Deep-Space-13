/obj/structure/overmap_component
	name = "thing"
	icon = 'DS13/icons/overmap/components.dmi'
	density = TRUE
	anchored = TRUE
	can_be_unanchored = TRUE
	var/obj/structure/overmap/linked
	var/id = "ds13"
	var/position = null //Set this to either "pilot", "tactical" or "science"

/obj/structure/overmap_component/attack_hand(mob/user) //this doesnt work!!
	if(!isliving(user))
		return
	if(!linked || QDELETED(linked))
		find_overmap()
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/L = user
	if(!position)
		return ..()
	var/obj/item/card/id/ID = L.get_idcard(FALSE)
	if(ID && istype(ID))
		if(!check_access(ID))
			to_chat(L, "You require a high level access card to use this console!.")
			return
		linked.enter(L, position)
		return
	to_chat(L, "You require a high level access card to use this console!.")
	return

/obj/structure/overmap_component/attack_ai(mob/user)
	if(position)
		return linked.enter(user, position)
	return

/obj/structure/overmap_component/take_damage(amount)
	if(obj_integrity <= amount)
		obj_integrity = 10 //Don't want them to actually be destroyed until we make them buildable. But you can bash the shit out of them for now
		return
	. = ..()

/obj/structure/overmap_component/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/find_overmap), 40)

/obj/structure/overmap_component/examine(mob/user)
	. = ..()
	if(!linked || QDELETED(linked))
		return
	to_chat(user, "-it seems to be connected to [linked]")

/obj/structure/overmap_component/proc/find_overmap()
	var/area/AR = get_area(src)
	if(AR.linked_overmap)
		linked = AR.linked_overmap //Saves me a bit of a headache with all these damn subtypes :)
		linked.components += src
		return
	for(var/obj/structure/overmap/OM in GLOB.overmap_ships)
		if(OM.class == id)
			linked = OM
			OM.components += src

/obj/structure/overmap_component/viewscreen
	name = "Viewscreen"
	desc = "You can't help but feel excited at the opportunity that space has to offer as you stare out a small porthole..."
	icon_state = "viewscreen"
	icon = 'DS13/icons/obj/decor/viewscreen.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER
	density = FALSE

/obj/structure/overmap_component/viewscreen/miranda
	name = "Viewscreen"
	desc = "Allows you to see your ship."
	icon_state = "viewscreen"
	icon = 'DS13/icons/obj/decor/viewscreen.dmi'
	id = "miranda"

/obj/structure/overmap_component/viewscreen/examine(mob/user)
	if(!linked || QDELETED(linked))
		find_overmap()
		return
	if(isobserver(user) && linked)
		var/mob/dead/observer/O = user
		O.ManualFollow(linked)
		return
	linked.enter(user, "observer",TRUE) //Enter them as an observer
	. = ..()

/obj/structure/overmap_component/viewscreen/attack_ai(mob/user)
	if(!linked || QDELETED(linked))
		find_overmap()
	if(isobserver(user) && linked)
		user.forceMove(get_turf(linked))
		return
	return linked.enter(user, "observer",TRUE) //Enter them as an observer

/obj/structure/overmap_component/helm
	name = "Piloting station"
	desc = "This console gives you the power to control a starship. Screwdriver it to change its command codes."
	icon_state = "pilot"
	position = "pilot"
	req_access = list(ACCESS_HEADS)
	flags_1 = HEAR_1
	var/redalert_activator = "red alert" //the activation message
	var/redalert_deactivator = "stand down red alert" //the de-activation message
	var/redalert = FALSE //Reduce processing usage.
	var/redalert_sound = 'DS13/sound/effects/redalert-mid.ogg'

/obj/structure/overmap_component/helm/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/L = user
		var/obj/item/card/id/ID = L.get_idcard(FALSE)
		if(ID && istype(ID))
			if(check_access(ID))
				to_chat(user, "<span class='notice'>You can say <i>[redalert_activator]</i> to engage red alert, or say <b>[redalert_deactivator]</b> to disengage red alert.</span>")

/obj/structure/overmap_component/helm/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(speaker == src)
		return
	else
		if(check_deactivation(speaker, raw_message))
			redalert_end()
			return TRUE //Red alert appears in both, so check deactivator FIRST
		else
			if(check_activation(speaker, raw_message))
				redalert_start()
				return TRUE

/obj/structure/overmap_component/helm/proc/check_activation(atom/movable/speaker, raw_message)
	if(ishuman(speaker))
		var/mob/living/carbon/human/L = speaker
		var/obj/item/card/id/ID = L.get_idcard(FALSE)
		if(ID && istype(ID))
			if(!check_access(ID))
				return FALSE
		else
			return FALSE
	if(findtext(raw_message, "?"))
		return
	if(findtext(raw_message, redalert_activator))
		return TRUE
	else
		return FALSE

/obj/structure/overmap_component/helm/proc/check_deactivation(atom/movable/speaker, raw_message)
	if(ishuman(speaker))
		var/mob/living/carbon/human/L = speaker
		var/obj/item/card/id/ID = L.get_idcard(FALSE)
		if(ID && istype(ID))
			if(!check_access(ID))
				return FALSE
		else
			return FALSE
	if(findtext(raw_message, "?"))
		return
	if(findtext(raw_message, redalert_deactivator))
		return TRUE
	else
		return FALSE

/obj/structure/overmap_component/helm/proc/redalert_start()
	if(redalert || !linked)
		return
	redalert = TRUE
	if(linked.main_overmap)
		for(var/X in GLOB.teleportlocs) //Strip out shit that shouldn't be there
			var/area/AR = GLOB.teleportlocs[X]
			AR.redalert = TRUE
			spawn(0) //We're branching here so that looping through the areas doesnt depend on the lighting loop finishing. Makes me wish for multithreading :(
			for(var/thing in AR)
				if(istype(thing, /obj/machinery/light))
					var/obj/machinery/light/L = thing
					L.update()
		for(var/mob/player in GLOB.player_list)
			var/area/AR = get_area(player)
			if(is_station_level(player.z) && !AR.noteleport) //Player on station and not on another random ship.
				SEND_SOUND(player, sound(redalert_sound, repeat = 1, wait = 0, volume = 100, channel = CHANNEL_REDALERT)) //Send them the redalert sound
	else
		if(!linked.linked_area)
			return
		linked.linked_area.redalert = TRUE
		for(var/obj/machinery/light/L in linked.linked_area)
			L.update()
		for(var/mob/player in linked.linked_area)
			SEND_SOUND(player, sound(redalert_sound, repeat = 1, wait = 0, volume = 100, channel = CHANNEL_REDALERT)) //Send them the redalert sound
	set_security_level(SEC_LEVEL_RED)


/obj/structure/overmap_component/helm/proc/redalert_end()
	if(!redalert || !linked)
		return
	redalert = FALSE
	set_security_level(SEC_LEVEL_GREEN)
	if(linked.main_overmap)
		for(var/X in GLOB.teleportlocs) //Strip out shit that shouldn't be there
			var/area/AR = GLOB.teleportlocs[X]
			AR.redalert = FALSE
			AR.unset_fire_alarm_effects()
		for(var/mob/player in GLOB.player_list)
			var/area/AR = get_area(player)
			if(is_station_level(player.z) && !AR.noteleport) //Player on station and not on another random ship.
				if(player.client)
					SEND_SOUND(player, sound(null, repeat = 0, wait = 0, volume = 100, channel = CHANNEL_REDALERT))
	else
		if(!linked.linked_area)
			return
		linked.linked_area.redalert = FALSE
		linked.linked_area.unset_fire_alarm_effects()
		for(var/mob/player in linked.linked_area)
			SEND_SOUND(player, sound(null, repeat = 1, wait = 0, volume = 100, channel = CHANNEL_REDALERT)) //Send them the redalert sound
/obj/structure/overmap_component/science
	name = "Science station"
	desc = "This console gives you the power to control a starship."
	icon_state = "science"
	position = "science"
	req_access = list(ACCESS_HEADS)

/obj/structure/overmap_component/tactical
	name = "Weapons station"
	desc = "This console gives you the power to control a starship."
	icon_state = "tactical"
	position = "tactical"
	req_access = list(ACCESS_HEADS)

/obj/structure/overmap_component/helm/miranda
	name = "Piloting station"
	desc = "This console gives you the power to control a starship."
	icon_state = "pilot"
	position = "pilot"
	id = "miranda"

/obj/structure/overmap_component/science/miranda
	name = "Science station"
	desc = "This console gives you the power to control a starship."
	icon_state = "science"
	position = "science"
	id = "miranda"

/obj/structure/overmap_component/tactical/miranda
	name = "Weapons station"
	desc = "This console gives you the power to control a starship."
	icon_state = "tactical"
	position = "tactical"
	id = "miranda"

/obj/structure/overmap_component/helm/warbird
	name = "Piloting station"
	desc = "This console gives you the power to control a starship."
	icon_state = "pilot"
	position = "pilot"
	id = "warbird"

/obj/structure/overmap_component/science/warbird
	name = "Science station"
	desc = "This console gives you the power to control a starship."
	icon_state = "science"
	position = "science"
	id = "warbird"

/obj/structure/overmap_component/tactical/warbird
	name = "Weapons station"
	desc = "This console gives you the power to control a starship."
	icon_state = "tactical"
	position = "tactical"
	id = "warbird"

///INJECTORS, RELAYS, AND INTEGRITY FIELD GEN!///
// Each relay gives +2 max power per system


/obj/structure/overmap_component/plasma_injector
	name = "Plasma injector"
	desc = "This sturdy device will inject supplied plasma into the ship's ODN relays, allowing for massive power transference. Simply load it with a plasma canister, or click it with an empty hand to remove a canister"
	icon_state = "injector"
	req_access = list(ACCESS_ENGINE_EQUIP)
	max_integrity = 350
	integrity_failure = 50
	density = FALSE
	var/obj/item/tank/internals/plasma/loaded_tank = null //Nicked from rad collector code, see there for documentation (collector.dm)
	var/powerproduction_drain = 0.015 //Relatively high drain on the plasma tanks.
	var/drainratio = 1
	var/supplying = FALSE //Are we supplying plasma to another object?
	var/obj/structure/overmap_component/plasma_relay/supply_to
	var/obj/structure/overmap_component/integrity_field_generator/generator
	var/locked = FALSE
	resistance_flags = FIRE_PROOF

/obj/structure/overmap_component/plasma_injector/Initialize()
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/structure/overmap_component/plasma_injector/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/L = user
		var/obj/item/card/id/ID = L.get_idcard(FALSE)
		if(ID && istype(ID))
			if(!check_access(ID))
				to_chat(user, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>you are not authorized to execute this command.</span>")
				return
		else
			to_chat(user, "You need to be wearing an ID to use this machine.")
			return
		eject()

/obj/structure/overmap_component/plasma_injector/examine(mob/user)
	. = ..()
	if(!supply_to)
		return
	to_chat(user, "it's injecting plasma towards [supply_to] in [get_area(supply_to)].")

/obj/structure/overmap_component/plasma_injector/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank/internals/plasma))
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] needs to be secured to the floor first!</span>")
			return TRUE
		if(loaded_tank)
			to_chat(user, "<span class='warning'>There's already a plasma tank loaded!</span>")
			return TRUE
		if(!user.transferItemToLoc(W, src))
			return
		loaded_tank = W
	else if(W.GetID())
		if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the controls.</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")
			return TRUE
	else
		return ..()

/obj/structure/overmap_component/plasma_injector/Destroy()
	STOP_PROCESSING(SSobj,src)
	. = ..()

/obj/structure/overmap_component/plasma_injector/process()
	if(!linked || !linked.powered_components.len)
		icon_state = "injector"
		return
	if(!supply_to || QDELETED(supply_to))
		supplying = FALSE
		find_supply_to()
		return
	if(!loaded_tank) //No tank, so draw from the enviornment
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/air = T.return_air()
		if(air.gases[/datum/gas/plasma])
			icon_state = "injector-on"
			var/gasdrained = min(powerproduction_drain*drainratio,air.gases[/datum/gas/plasma][MOLES])
			air.gases[/datum/gas/plasma][MOLES] -= gasdrained
			air.garbage_collect()
			if(supply_to)
				supply_to.plasma_volume += powerproduction_drain
			if(generator)
				generator.plasma_volume += powerproduction_drain
		else
			icon_state = "injector"
		return
	if(!loaded_tank.air_contents.gases[/datum/gas/plasma])
		playsound(src, 'DS13/sound/effects/computer/alert2.ogg', 100, 1)
		playsound(src, 'DS13/sound/effects/computer/power_down.ogg', 100, 1)
		eject()
		icon_state = "injector"
		return
	icon_state = "injector-on"
	var/gasdrained = min(powerproduction_drain*drainratio,loaded_tank.air_contents.gases[/datum/gas/plasma][MOLES])
	loaded_tank.air_contents.gases[/datum/gas/plasma][MOLES] -= gasdrained
	loaded_tank.air_contents.garbage_collect()
	if(supply_to)
		supply_to.plasma_volume += powerproduction_drain
	if(generator)
		generator.plasma_volume += powerproduction_drain
		loaded_tank.air_contents.gases[/datum/gas/plasma][MOLES] -= gasdrained
		loaded_tank.air_contents.garbage_collect()

/obj/structure/overmap_component/plasma_injector/proc/find_supply_to()
	if(!linked)
		find_overmap()
		return
	for(var/obj/structure/overmap_component/integrity_field_generator/IFS in linked.powered_components)
		if(!IFS.supplier)
			generator = IFS
			generator.supplier = src
			supplying = TRUE
	for(var/obj/structure/overmap_component/plasma_relay/X in linked.powered_components)
		if(!X.supplier)
			supply_to = X
			X.supplier = src
			supplying = TRUE
			return TRUE

/obj/structure/overmap_component/plasma_injector/proc/eject()
	locked = FALSE
	var/obj/item/tank/internals/plasma/Z = loaded_tank
	if (!Z)
		return
	Z.forceMove(drop_location())
	Z.layer = initial(Z.layer)
	Z.plane = initial(Z.plane)
	loaded_tank = null
	icon_state = "injector"

/obj/structure/overmap_component/plasma_relay //Annnd these supply power to your systems
	name = "ODN relay"
	desc = "This sturdy component fuses warp plasma into power via the power grid. This power is then supplied to a subsystem of choice"
	icon_state = "relay-closed"
	req_access = list(ACCESS_ENGINE_EQUIP)
	var/obj/structure/overmap_component/plasma_injector/supplier
	var/supplying = null //can be engines, shields, weapons
	var/panel_open = FALSE //You gotta take the panel off first if you want to mess with it.
	var/plasma_volume = 0 //How much plasma we got? If you store loads in it and this takes a hit it'll rupture and spill some of it all over the place.
	var/plasma_drain = 0.005 //Allows a tiny bit of plasma buildup in normal usage cases.
	var/active = FALSE //Have we got enough plasma to power a system?
	var/activated = FALSE //Have we powered a system? If so, no need to spam its max_power stat endlessly
	var/list/zaps = list('DS13/sound/effects/damage/consolehit.ogg','DS13/sound/effects/damage/consolehit2.ogg','DS13/sound/effects/damage/consolehit3.ogg','DS13/sound/effects/damage/consolehit4.ogg')
	var/list/bleeps = list('DS13/sound/effects/computer/bleep1.ogg','DS13/sound/effects/computer/bleep2.ogg')
	var/repair_step = "wrench" //Wrench, screwdriver, wirecutters, screwdriver, wrench
	max_integrity = 150
	var/benefit = 2 //2 of these per subsystem, or build more thru RnD
	var/force_shutdown = FALSE //Are we being forced to turn off?

/obj/structure/overmap_component/plasma_relay/examine(mob/user)
	. = ..()
	if(!panel_open)
		to_chat(user, "It looks like its panel is closed, you could probably <b> crowbar </b> it off.")
		return
	switch(repair_step)
		if("wrench","wrench2")
			to_chat(user, "You notice that its couplings are a bit loose. Perhaps a <b>wrench</b> would fix that?")
		if("screwdriver","screwdriver2")
			to_chat(user, "[src] could probably be repaired with a <b>screwdriver</b> ")
		if("wirecutters")
			to_chat(user, "A pair of <b>wirecutters</b> could help you remove [src]'s fused relays...'")

/obj/structure/overmap_component/plasma_relay/attack_hand(mob/user)
	. = ..()
	if(!isliving(user))
		return
	if(!linked || QDELETED(linked))
		find_overmap()
	var/Q = alert(user,"Redirect power to what system?","[src]","shields","weapons", "engines")
	if(!Q || Q == "cancel")
		playsound(loc, 'DS13/sound/effects/computer/bleep2.ogg',100)
		return
	playsound(loc, 'DS13/sound/effects/computer/beep3.ogg',100)
	set_active(FALSE) //Remove us from our benefactor
	supplying = Q
	set_active(TRUE)
	to_chat(user, "<span class='notice'>[src] will now supply the [supplying] subsystem with power</span>")

/obj/structure/overmap_component/plasma_relay/crowbar_act(mob/user, obj/item/I)
	if(panel_open)
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start to replace [src]'s cover.</span>")
		if(do_after(user, 30, target = src))
			panel_open = FALSE
			set_active(TRUE)
			to_chat(user, "<span class='notice'>You replace [src]'s cover.</span>")
		update_icon()
		return TRUE
	if(!panel_open)
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start to prize off [src]'s cover.</span>")
		if(do_after(user, 30, target = src))
			panel_open = TRUE
			to_chat(user, "<span class='notice'>You remove [src]'s cover.</span>")
		update_icon()
		return TRUE

/obj/structure/overmap_component/plasma_relay/wrench_act(mob/user, obj/item/I)
	if(repair_step == "wrench")
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start to unfasten [src]'s couplings.</span>")
		if(do_after(user, 30, target = src))
			repair_step = "screwdriver"
		update_icon()
		return TRUE
	if(repair_step == "wrench2")
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start to re-fasten [src]'s couplings.</span>")
		if(do_after(user, 30, target = src))
			repair_step = "wrench"
			to_chat(user, "<span class='notice'>You have successfully re-assembled [src]! replace its cover to complete repairs.</span>")
		update_icon()
		return TRUE

/obj/structure/overmap_component/plasma_relay/screwdriver_act(mob/user, obj/item/I)
	if(repair_step == "screwdriver")
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start to mend [src]'s isolinear circuitry.</span>")
		if(do_after(user, 30, target = src))
			repair_step = "wirecutters"
		update_icon()
		return TRUE
	if(repair_step == "screwdriver2")
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start fasten [src]'s screws.</span>")
		if(do_after(user, 30, target = src))
			repair_step = "wrench2"
		update_icon()
		return TRUE

/obj/structure/overmap_component/plasma_relay/wirecutter_act(mob/user, obj/item/I)
	if(repair_step == "wirecutters")
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start cutting out [src]'s fused relays.</span>")
		if(do_after(user, 30, target = src))
			repair_step = "screwdriver2"
			to_chat(user, "<span class='notice'>You have successfully repaired [src]! re-assembly is the reverse of removal.</span>")
			obj_integrity = max_integrity
		update_icon()
		return TRUE

/obj/structure/overmap_component/plasma_relay/examine(mob/user)
	. = ..()
	if(supplier && supplying)
		to_chat(user, "it's receiving plasma from [supplier] and is supplying the <b>[supplying]</b> system for [linked]")
	else
		to_chat(user, "it's currently <b>unpowered</b>")

/obj/structure/overmap_component/plasma_relay/take_damage(damage_amount)
	. = ..()
	var/sound = pick(zaps)
	playsound(src.loc, sound, 70,1)
	var/bleep = pick(bleeps)
	playsound(src.loc, bleep, 70,1)
	do_sparks(5, 8, src)
	if(plasma_volume >= 2)
		var/turf/T = get_step(src, SOUTH)
		T.atmos_spawn_air("plasma=10;TEMP=2000") //Anything less than this barely even matters
		plasma_volume -= 2

/obj/structure/overmap_component/plasma_relay/update_icon()
	if(panel_open)
		icon_state = "relay-open"
		return
	else
		icon_state = "relay-closed"
		if(obj_integrity < 40)
			icon_state = "relay-closed-alert"
			set_active(FALSE)
		return
	icon_state = "relay-closed"

/obj/structure/overmap_component/plasma_relay/process()
	update_icon()
	if(obj_integrity < 40 || plasma_volume < plasma_drain)
		set_active(FALSE)
		return
	if(!supplying)
		find_supplying()
		return
	if(!active && !panel_open)
		set_active(TRUE)
		return
	if(plasma_volume >= plasma_drain)
		plasma_volume -= plasma_drain
		set_active(TRUE)
	else
		set_active(FALSE)

/obj/structure/overmap_component/plasma_relay/proc/set_active(var/set_to_what, var/forced = FALSE)
	if(set_to_what && forced)
		force_shutdown = FALSE
	if(panel_open || force_shutdown)
		active = FALSE
		return
	if(set_to_what)
		if(activated)
			return
		activated = TRUE
		active = TRUE
		playsound(loc, 'DS13/sound/effects/computer/power_up.ogg', 100, 1)
		switch(supplying)
			if("shields")
				linked.max_shield_power += benefit
			if("weapons")
				linked.max_weapon_power += benefit
			if("engines")
				linked.max_engine_power += benefit
		linked.check_power()
	else
		if(!activated) //Has to have been active, and thus benefitting a system, in order to remove said benefit.
			return
		activated = FALSE
		active = FALSE
		playsound(loc, 'DS13/sound/effects/computer/power_down.ogg', 100, 1)
		if(forced)
			force_shutdown = TRUE //Can't repower. We've been forcibly shut down
		switch(supplying)
			if("shields")
				linked.max_shield_power -= benefit
			if("weapons")
				linked.max_weapon_power -= benefit
			if("engines")
				linked.max_engine_power -= benefit
		linked.check_power()

/obj/structure/overmap_component/plasma_relay/proc/find_supplying()
	if(!linked)
		find_overmap()
		return
	if(linked.max_shield_power < 4) //Fill up shields first :)
		supplying = "shields"
	if(linked.max_weapon_power < 4)
		supplying = "weapons"
	if(linked.max_engine_power < 4)
		supplying = "engines"
	if(!supplying)
		supplying = pick("shields","weapons","engines")
	set_active(TRUE) //Set it to be activated. It'll then shut off due to lack of plasma.

/obj/structure/overmap_component/plasma_relay/Initialize()
	. = ..()

/obj/structure/overmap_component/plasma_relay/find_overmap()
	. = ..()
	if(linked)
		linked.powered_components += src
	START_PROCESSING(SSobj,src)

/obj/structure/overmap_component/plasma_relay/Destroy()
	STOP_PROCESSING(SSobj,src)
	. = ..()

/obj/structure/overmap_component/system_control //These let you manually shut off power to a system for sabotage purposes.
	name = "System control panel"
	desc = "This ultra-sturdy box can toggle ODN relays connected to its current system."
	icon_state = "control-closed"
	var/controlling = null
	var/panel_open = FALSE
	var/active = TRUE //They always start active
	var/hacked = FALSE
	req_access = list(ACCESS_ENGINE_EQUIP)
	var/step = "start"
	max_integrity = 1000 //Ultra robust

/obj/structure/overmap_component/system_control/examine(mob/user)
	. = ..()
	if(!linked || QDELETED(linked))
		find_overmap()
	if(!controlling)
		return
	to_chat(user, "-it is controlling the [controlling] subsystem.")

/obj/structure/overmap_component/system_control/Initialize()
	. = ..()
	if(!linked || QDELETED(linked))
		find_overmap()
	addtimer(CALLBACK(src, .proc/find_system), 40)

/obj/structure/overmap_component/system_control/proc/find_system()
	if(!linked || QDELETED(linked))
		find_overmap()
		return
	linked.subsystem_controllers += src
	var/can_shields = TRUE
	var/can_weapons = TRUE
	var/can_engines = TRUE
	for(var/obj/structure/overmap_component/system_control/X in linked.subsystem_controllers)
		if(X && istype(X) && X != src)
			if(!X.controlling)
				continue
			if(X.controlling == "shields")
				can_shields = FALSE
			if(X.controlling == "weapons")
				can_weapons = FALSE
			if(X.controlling == "engines")
				can_engines = FALSE
	if(can_shields)
		controlling = "shields"
		return
	if(can_weapons)
		controlling = "weapons"
		return
	if(can_engines)
		controlling = "engines"
		return

/obj/structure/overmap_component/system_control/crowbar_act(mob/user, obj/item/I)
	if(panel_open)
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start to replace [src]'s cover.</span>")
		if(do_after(user, 50, target = src))
			panel_open = FALSE
			to_chat(user, "<span class='notice'>You replace [src]'s cover.</span>")
		update_icon()
		return TRUE
	if(!panel_open)
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start to prize off [src]'s cover.</span>")
		if(do_after(user, 50, target = src))
			panel_open = TRUE
			to_chat(user, "<span class='notice'>You remove [src]'s cover.</span>")
		update_icon()
		return TRUE

/obj/structure/overmap_component/system_control/screwdriver_act(mob/user, obj/item/I)
	if(panel_open && !hacked)
		if(step == "start")
			playsound(loc,I.usesound,100,1)
			to_chat(user, "<span class='notice'>You start to undo [src]'s screws.</span>")
			if(do_after(user, 100, target = src))
				step = "wrench"
			update_icon()
			return TRUE

/obj/structure/overmap_component/system_control/wrench_act(mob/user, obj/item/I)
	if(step == "wrench")
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You force your way through [src]'s protective casings.</span>")
		if(do_after(user, 100, target = src))
			step = "end"
		update_icon()
		return TRUE

/obj/structure/overmap_component/system_control/welder_act(mob/user, obj/item/I)
	if(!I.tool_start_check(user, amount=3))
		return
	if(step == "end")
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You begin to cut through [src]'s authorization circuitry</span>")
		if(do_after(user, 100, target = src))
			hacked = TRUE
			playsound(loc, 'DS13/sound/effects/computer/alert1.ogg',100)
			say("Authori~@A@DA~D~A~D%%0-110- no longer required.")
			step = "finished"
		update_icon()
		return TRUE
	if(step == "finished")
		playsound(loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You begin to mend [src]'s authorization circuitry</span>")
		if(do_after(user, 100, target = src))
			hacked = FALSE
			playsound(loc, 'DS13/sound/effects/computer/alert1.ogg',100)
			say("Authorization protocols re-enstated.")
			step = "start"
		update_icon()
		return TRUE


/obj/structure/overmap_component/system_control/attack_hand(mob/user)
	if(!isliving(user))
		return
	if(ishuman(user))
		if(!linked || QDELETED(linked))
			find_overmap()
		if(!controlling)
			find_system()
			return
		var/mob/living/carbon/human/L = user
		if(!hacked)
			var/obj/item/card/id/ID = L.get_idcard(FALSE)
			if(ID && istype(ID))
				if(!check_access(ID))
					to_chat(user, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>you are not authorized to execute this command.</span>")
					return
			else
				to_chat(user, "You need to be wearing an ID to use this machine.")
				return
	var/Q = alert(user,"[active ? "deactivate" : "activate"] [controlling] subsystem?","[src]","yes","no")
	if(Q == "yes")
		to_chat(user, "You [active ? "deactivate" : "activate"] all ODN relays connected to the [controlling] subsystem.")
		if(active)
			active = FALSE
		else
			active = TRUE
		for(var/obj/structure/overmap_component/plasma_relay/XX in linked.powered_components)
			if(XX.supplying == controlling)
				XX.set_active(active, TRUE)
	update_icon()

/obj/structure/overmap_component/system_control/update_icon()
	if(panel_open)
		icon_state = "control-open"
		return
	if(active)
		icon_state = "control-closed"
	else
		icon_state = "control-closed-alert"


/obj/structure/overmap_component/integrity_field_generator
	name = "Structural integrity field generator"
	desc = "A sturdy device which, when supplied with warp plasma, generates a structural integrity field around the ship, allowing it to withstand even the harshest envioronments! A warning label on it reads: WARNING. Loss of structural integrity field will result in a catastrophic warp containment breach."
	icon_state = "fieldgen"
	icon = 'DS13/icons/overmap/integrity_field_gen.dmi'
	req_access = list(ACCESS_ENGINE_EQUIP)
	max_integrity = 350
	integrity_failure = 50
	var/plasma_volume = 0
	var/drainrate = 0.015 //How quickly we drain plasma
	var/healrate = 0.15 //Equates to how quickly the ship heals. Keep in mind that this is SLOW! Otherwise missions would be too easy ;)
	var/locked = FALSE
	var/obj/structure/overmap_component/plasma_injector/supplier
	var/active = FALSE
	var/activated = FALSE
	var/panel_open = FALSE
	var/force_shutdown = FALSE //Has someone deliberately turned us off?
	pixel_x = -9 //Deal with shitty offset

/obj/structure/overmap_component/integrity_field_generator/proc/set_active(var/set_to_what)
	if(panel_open || force_shutdown)
		active = FALSE
		return
	if(set_to_what)
		if(activated)
			return
		activated = TRUE
		active = TRUE
		playsound(loc, 'DS13/sound/effects/computer/power_up.ogg', 100, 1)
	else
		if(!activated) //Has to have been active, and thus benefitting a system, in order to remove said benefit.
			return
		activated = FALSE
		active = FALSE
		playsound(loc, 'DS13/sound/effects/computer/power_down.ogg', 100, 1)

/obj/structure/overmap_component/integrity_field_generator/Initialize()
	. = ..()

/obj/structure/overmap_component/integrity_field_generator/find_overmap()
	. = ..()
	if(linked)
		linked.powered_components += src
	START_PROCESSING(SSobj,src)
	set_active(TRUE) //Start 'er up Jim!

/obj/structure/overmap_component/integrity_field_generator/Destroy()
	STOP_PROCESSING(SSobj,src)
	. = ..()

/obj/structure/overmap_component/integrity_field_generator/process()
	if(!linked || plasma_volume <= 0 || linked.health >= linked.max_health)
		set_active(FALSE)
		return
	set_active(TRUE)
	if(linked.health < linked.max_health && plasma_volume >= drainrate)
		plasma_volume -= drainrate
		linked.health += healrate