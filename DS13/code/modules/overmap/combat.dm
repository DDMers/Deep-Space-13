/mob/living/carbon/canMobMousedown(atom/object, location, params)
	. = ..()
	if(!overmap_ship)
		return
	. = overmap_ship


/obj/structure/overmap
	var/weapons_ready = TRUE //Are we ready to fire? This is a straight cooldown
	var/weapons_cooldown = 25 //This prevents spam. Allows a shot once every 2 seconds
	var/datum/beam/current_beam = null //Our phaser beam, wow!
	var/damage = 0 //How much damage do we do? This is +10'd assuming weapons are powered!
	var/charging = FALSE //charging weapons? if so, we can't fire
	var/fire_mode = "phaser"
	var/photons = 0 //How many torpedoes do we have? We need this to start empty, as sci must load torps.
	var/list/weapon_sounds = list('DS13/sound/effects/weapons/phaser.ogg','DS13/sound/effects/weapons/phaser2.ogg','DS13/sound/effects/weapons/phaser3.ogg','DS13/sound/effects/weapons/phaser4.ogg')
	var/obj/structure/overmap/tractor_target = null //Are we tractoring a target? This forces it to move towards us.
	var/datum/beam/tractor_beam = null
	var/hail_ready = TRUE //Hailing cooldown
	var/torpedo_damage = 30
	var/area/linked_area = null
	var/destroyed = FALSE
	var/damage_sector = "shields" //Tactical can change this! What system are we targeting?
	var/list/torpedo_damage_list = list() //Keeps track of the damage that each torpedo that's been loaded will do. Science can upgrade the torpedoes for even more damage.
	var/cloaked = FALSE //Used for rommies.

/obj/structure/overmap/proc/send_sound_crew(var/sound/S)
	for(var/mob/M in operators)
		SEND_SOUND(M, S)

/obj/structure/overmap/proc/send_sound_all(var/sound/sound, var/text) //Send a sound to anyone on a ship.
	if(main_overmap)
		for(var/mob/player in GLOB.player_list)
			if(is_station_level(player.z))
				if(text)
					to_chat(player, "[text]")
				if(sound)
					SEND_SOUND(player, sound)
	else
		if(!linked_area)
			return
		for(var/X in linked_area)
			if(ismob(X))
				var/mob/player = X
				if(text)
					to_chat(player, "[text]")
				if(sound)
					SEND_SOUND(player, sound)

/obj/structure/overmap/proc/send_text_crew(var/S)
	to_chat(operators, S)

/obj/effect/temp_visual/ship_explosion
	icon = 'DS13/icons/overmap/effects.dmi'
	icon_state = "ship_explode"
	duration = 30

/obj/effect/temp_visual/ship_explosion/Initialize()
	. = ..()
	pixel_x = rand(0,10)
	pixel_y = rand(0,10)

/obj/structure/overmap/proc/get_beep() //Override this to change the SFX that play when you click stuff
	return pick(GLOB.bleeps)

/obj/structure/overmap/proc/onMouseDown(object, location, params, mob/mob)
	var/sound/thesound = get_beep()
	SEND_SOUND(mob, thesound)
	if(object == src)
		return attack_hand(mob)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	if(cloaked)
		to_chat(mob, "<span class='warning'> The controls flash a message: UNABLE TO MODIFY PARAMETERS WHILE CLOAKED.</span>")
		return
	if(mob != tactical)
		if(science)
			if(mob == science && istype(object, /obj/structure/overmap))
				var/list/options = list("tractor", "hail","tractor-cancel")
				for(var/option in options)
					options[option] = image(icon = 'DS13/icons/actions/weaponselect.dmi', icon_state = "[option]")
				var/dowhat = show_radial_menu(mob,object,options)
				if(!dowhat)
					return
				switch(dowhat)
					if("tractor")
						fire_tractor(object)
					if("hail")
						hail(object)
					if("tractor-cancel")
						release_tractor()
		return ..() //Only tactical can fire.
	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		if(istype(object, /obj/structure/overmap))
			nav_target = object
			return
	if(modifiers["shift"])
		var/atom/obj = object
		return obj.examine(mob)
	if(charging)
		return
	if(weapons_ready && mob == tactical && istype(object, /obj/structure/overmap))
		fire(object)
		return

/obj/structure/overmap/proc/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	return ..()

/obj/structure/overmap/proc/onMouseUp(object, location, params, mob/M)
	return ..()

/obj/structure/overmap/proc/fire_tractor(var/obj/structure/overmap/target) //Fire a tractor beam, not a literal tractor!
	if(charging || !weapons_ready || !target) //So you can't spam it infinitely
		release_tractor()
		return
	if(!target.process)
		target.process = TRUE
		target.start_process() //In case it's an inactive ship. We still need to tow it!
	addtimer(CALLBACK(src, .proc/recharge_weapons), weapons_cooldown)
	weapons_ready = FALSE
	if(target.shields.check_vulnerability() || target.faction == faction) //Are their shields above 50% strength? Or if theyre a friendly, and being towed to safety.
		tractor_target = target
		send_sound_crew('DS13/sound/effects/weapons/tractor.ogg')
		target.send_sound_crew('DS13/sound/effects/weapons/tractor.ogg')
		var/source = src
		if(tractor_beam)
			qdel(tractor_beam)
		tractor_beam = new /datum/beam(source,target,time=2000,beam_icon_state="medbeam",maxdistance=5000,btype=/obj/effect/ebeam)
		spawn(0)
			tractor_beam.Start()
	else
		release_tractor()
		to_chat(science, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>target shield strength is above 50%.</span>")

/obj/structure/overmap/proc/release_tractor()
	if(!tractor_target || QDELETED(tractor_target))
		tractor_target = null
		return
	tractor_target.nav_target = null
	tractor_target.vel = 0
	tractor_target = null
	if(tractor_beam)
		qdel(tractor_beam)

/obj/structure/overmap/proc/tractor_pull() //Force the target to turn to us and move towards us.
	if(!tractor_target)
		return
	if(tractor_target.z != z) //Runabout safety check.
		release_tractor()
		return
	if(tractor_target.shields.check_vulnerability() || tractor_target.faction == faction)
		tractor_target.nav_target = src
		tractor_target.vel = 1
		if(get_dist(src, tractor_target) > 1) //To stop it glitching out when it reaches us
			var/num = 1.7 //Tractors are slooow
			tractor_target.vel = (num)
			tractor_target.turnspeed = 2
		else
			tractor_target.vel = 0
			tractor_target.check_power()
	else
		release_tractor() //Target shields are back, stop tractoring.


/obj/structure/overmap/proc/fire(var/obj/structure/overmap/target)
	if(charging || !weapons_ready)
		return
	addtimer(CALLBACK(src, .proc/recharge_weapons), weapons_cooldown)
	weapons_ready = FALSE
	check_power()
	for(var/mob/M in operators)
		shake_camera(M, 1, 3)
	if(fire_mode == "phaser")
		charging = TRUE
		var/obj/effect/temp_visual/phaserfire/F = new /obj/effect/temp_visual/phaserfire(src) //If we have a firing state, light em up!
		add_overlay(F)
		var/datum/beam/S = new /datum/beam(src,target,time=10,beam_icon_state="phaser",maxdistance=5000,btype=/obj/effect/ebeam)
		spawn(0)
			S.Start()
		var/sound/SS = pick(weapon_sounds)
		send_sound_crew(SS)
		target.send_sound_crew(SS)
		target.take_damage(src, damage)
	else
		if(photons > 0)
			photons --
			addtimer(CALLBACK(src, .proc/recharge_weapons), weapons_cooldown)
			weapons_ready = FALSE
			charging = TRUE
			send_sound_crew('DS13/sound/effects/weapons/torpedo.ogg')
			var/obj/item/projectile/beam/laser/photon_torpedo/A = new /obj/item/projectile/beam/laser/photon_torpedo(loc)
			A.starting = loc
			A.preparePixelProjectile(target,src)
			A.pixel_x = rand(0, 5)
			A.fire()
			var/next_torp_damage = torpedo_damage
			if(torpedo_damage_list.len)
				next_torp_damage = pick_n_take(torpedo_damage_list) //Pick from the photons we've got loaded.
			target.take_damage(src, next_torp_damage)
		else
			if(tactical)
				voice_alert('DS13/sound/effects/voice/OutOfTorpedoes.ogg')
				to_chat(tactical, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>photon torpedo supply is depleted.</span>")
			return

/obj/item/ammo_casing/energy/photon
	select_name = "photon torpedo"
	e_cost = 0
	projectile_type = /obj/item/projectile/beam/laser/photon_torpedo

/obj/item/projectile/beam/laser/photon_torpedo
	hitscan = FALSE
	name = "photon torpedo"
	damage = 0
	var/obj/source

/obj/structure/overmap/proc/recharge_weapons()
	weapons_ready = TRUE
	charging = FALSE

/obj/structure/overmap/proc/hail(var/obj/structure/overmap/target)
	if(!science || !hail_ready)
		return
	var/message = stripped_input(science,"Send a message to [target].","Transmit message on narrow band frequency.")
	if(!message)
		return
	hail_ready = FALSE
	var/new_message = "<span class='boldnotice'>Narrow band transmission:[src] ([science])</span> - <span class='warning'>[message]</span>"
	send_sound_all('sound/ai/commandreport.ogg', new_message)
	addtimer(CALLBACK(src, .proc/ready_hail), 25)

/obj/structure/overmap/proc/ready_hail()
	hail_ready = TRUE

/obj/structure/overmap/attack_hand(mob/user, proximity) //I will need this later to show radial menus
	if(user.remote_control in crew) //This means theyre one of our officers, so show them the appropriate radial!
		if(user == tactical) //The user is our tactical operator, show him the options
			var/list/options = list("phaser", "torpedo", "target_system")
			for(var/option in options)
				options[option] = image(icon = 'DS13/icons/actions/weaponselect.dmi', icon_state = "[option]")
			var/dowhat = show_radial_menu(user,src,options)
			if(!dowhat)
				return
			if(dowhat == "target_system")
				var/list/zones = list("shields", "engines", "weapons")
				for(var/option in zones)
					zones[option] = image(icon = 'DS13/icons/actions/weaponselect.dmi', icon_state = "[option]")
				var/zone = show_radial_menu(user,src,zones)
				if(zone)
					damage_sector = zone
					to_chat(user, "<b>[src] will now target enemy [zone] subsystems in combat.")
				return
			fire_mode = dowhat
			if(dowhat == "torpedo")
				var/sound/S = pick('DS13/sound/effects/voice/LoadingPhoton.ogg','DS13/sound/effects/voice/LoadingPhoton2.ogg')
				voice_alert(S)
			return

/obj/structure/overmap/proc/special_fx(var/shields_absorbed)
	if(!main_overmap)
		special_fx_targeted(shields_absorbed)
		return
	var/area = pick(GLOB.teleportlocs)
	var/area/target = GLOB.teleportlocs[area] //Pick a station area and yeet it.
	if(target.explosion_exempt)
		return //Welp, we tried.
	for(var/mob/player in GLOB.player_list)
		if(is_station_level(player.z))
			if(prob(50))
				shake_camera(player, 1,3)
			else
				shake_camera(player, 2,2)
			if(shields_absorbed)
				var/sound/shieldhit = pick('DS13/sound/effects/damage/shield_hit.ogg','DS13/sound/effects/damage/shield_hit2.ogg')
				SEND_SOUND(player, shieldhit)
				continue
			var/sound/S = pick('DS13/sound/effects/damage/shiphit.ogg','DS13/sound/effects/damage/shiphit2.ogg','DS13/sound/effects/damage/shiphit3.ogg','DS13/sound/effects/damage/shiphit4.ogg','DS13/sound/effects/damage/FTL/explosionfar_2.ogg','DS13/sound/effects/damage/FTL/explosionfar_3.ogg','DS13/sound/effects/damage/FTL/explosionfar_4.ogg','DS13/sound/effects/damage/FTL/explosionfar_5.ogg','DS13/sound/effects/damage/FTL/explosionfar_6.ogg')
			SEND_SOUND(player, S)
	if(shields_absorbed)
		for(var/i = 0 to rand(1,5))
			if(components.len)
				var/obj/structure/X = pick(components)
				X.explode_effect()
		return
	if(prob(35))
		var/turf/T = pick(get_area_turfs(target))
		new /obj/effect/temp_visual/explosion_telegraph(T)
		var/turf/TT = pick(get_area_turfs(target))
		TT.atmos_spawn_air("plasma=20;TEMP=1000")

/obj/effect/temp_visual/explosion_telegraph
	name = "Explosion imminent!"
	icon = 'DS13/icons/effects/effects.dmi'
	icon_state = "explosion_telegraph"
	duration = 30
	randomdir = 0
	alpha = 0
	layer = ABOVE_MOB_LAYER

/obj/effect/temp_visual/phaserfire
	name = "Explosion imminent!"
	icon = 'DS13/icons/effects/effects.dmi'
	icon_state = "firing"
	duration = 30
	randomdir = 0
	alpha = 255

/obj/effect/temp_visual/phaserfire/New()
	var/obj/structure/overmap/OM = locate(/obj/structure/overmap) in get_turf(src)
	if(OM)
		icon = OM.icon
	. = ..()

/obj/effect/temp_visual/explosion_telegraph_non_explosive
	name = "RUN"
	icon = 'DS13/icons/effects/effects.dmi'
	icon_state = "explosion_telegraph"
	duration = 30
	randomdir = 0
	layer = ABOVE_MOB_LAYER

/obj/effect/temp_visual/explosion_telegraph/Initialize()
	. = ..()
	for(var/turf/T in orange(src, 3))
		new /obj/effect/temp_visual/explosion_telegraph_non_explosive(T)
	for(var/mob/F in orange(src, 3))
		if(isliving(F))
			to_chat(F, "<span class='userdanger'>Something comes crashing down from the ceiling above you! GET OUT OF THE WAY!</span>")
			SEND_SOUND(F, 'sound/effects/seedling_chargeup.ogg')

/obj/effect/temp_visual/explosion_telegraph/Destroy()
	var/turf/T = get_turf(src)
	explosion(T,3,4,4)
	. = ..()

/obj/structure/overmap/take_damage(var/atom/source, var/amount = 10)
	. = ..()
	var/fluff = rand(1,6)
	switch(fluff)
		if(1)
			visible_message("<span class='warning'>Bits of [name] fly off into space!</span>")
		if(2)
			visible_message("<span class='warning'>[name]'s hull ruptures!</span>")
		if(3)
			visible_message("<span class='warning'>[name]'s hull buckles!</span>")
		if(4)
			visible_message("<span class='warning'>Warp plasma spews from [name]!</span>")
		if(5)
			visible_message("<spanR class='warning'>A beam tears across [name]'s hull!</span>")
		if(6)
			visible_message("<span class='warning'>[name]'s hull is scorched!</span>")
	if(!isnum(amount))
		stack_trace("an overmap just took damage from [source] but the amount specific wasn't a number ([amount])")
		return//Catch: The amount was inputted as something it's not supposed to. This is often caused by torpedoes because projectile code HATES him (click to find out more)
	visual_damage()
	for(var/mob/M in operators)
		shake_camera(M, 1, 3)
	if(istype(source, /obj/item/projectile))
		send_sound_crew('DS13/sound/effects/damage/torpedo_hit.ogg')
	var/sector
	var/obj/structure/overmap/OM
	if(source)
		OM = source
		sector = get_quadrant_hit(OM,src)
	else if(!source || !istype(source, /obj/structure/overmap)) //Generic damage not being caused by another ship, so pick a shield. Could be things like nebulae, meteorites etc.
		sector = rand(0,3) //Pick a quad, any quad
	GLOB.music_controller.play() //Try play some battle music, if there's already battle music then don't bother :)
	if(shields.absorb_damage(amount, sector))
		special_fx(TRUE)
		var/sound/shieldhit = pick('DS13/sound/effects/damage/shield_hit.ogg','DS13/sound/effects/damage/shield_hit2.ogg')
		send_sound_crew(shieldhit)
		show_damage(amount, TRUE)
		shield_alert()
		return
	else
		special_fx(FALSE)
		health -= amount
		new /obj/effect/temp_visual/ship_explosion(get_turf(src))
		show_damage(amount)
	if(health <= 0 && !destroyed)
		destroyed = TRUE
		explode()
	var/mod = (damage/1.5) //So you don't blow out the relays too frequently.
	for(var/obj/structure/overmap_component/XX in powered_components)
		if(istype(XX, /obj/structure/overmap_component/plasma_relay))
			var/obj/structure/overmap_component/plasma_relay/PS = XX
			if(PS.supplying == OM.damage_sector && PS.obj_integrity > 40)
				PS.take_damage(mod)
				return

/obj/structure/overmap/proc/explode()
	send_sound_crew('DS13/sound/effects/damage/ship_explode.ogg')
	if(main_overmap)
		SSredbot.send_discord_message("admin", "[src] is undergoing a core breach!", "game")
	if(warp_core && !QDELETED(warp_core) && !destroyed) //They have a core. So give them a chance to save the ship.
		warp_core.containment = -5//Force a warp core breach. No matter if it's on or not. They'll then have 45 seconds to haul ass to engi and eject the core.
		warp_core.breach(TRUE) //Force a core breach. It's done like this to prevent an infinite loop.
		destroyed = TRUE
		addtimer(CALLBACK(src, .proc/check_breach), 450)
		for(var/mob/A in operators)
			to_chat(A, "<span class='cult'><font size=3>Antimatter containment failing, evacuate the ship!</font></span>")
		return
	qdel(shield_overlay)
	qdel(shields)
	SpinAnimation(1000,1000)
	weapon_power = 0
	shield_power = 0
	engine_power = 0
	power_slots = 0
	movement_block = TRUE
	remove_control()
	addtimer(CALLBACK(src, .proc/core_breach_finish), 100)
	for(var/mob/A in operators)
		to_chat(A, "<span class='cult'><font size=3>Your ship has been destroyed!</font></span>")
		if(A.remote_control)
			A.remote_control.forceMove(get_turf(A))
	core_breach()

/obj/structure/overmap/proc/check_breach() //Check if the active warp core is salvaged. If not, explode the ship.
	if(!warp_core || QDELETED(warp_core))
		warp_core = null
		health = 50 //Second wind! Gives them time to run, because the next core breach will actually destroy them.
		destroyed = FALSE
		message_admins("[src]'s warp core was ejected before it could breach.")
		return FALSE
	if(warp_core.containment >= 0) //They saved it.
		health = 50 //Second wind! Gives them time to run, because the next core breach will actually destroy them.
		destroyed = FALSE
		warp_core.breaching = FALSE
		message_admins("[src]'s warp core was stabilized before it could breach.")
		return TRUE
	message_admins("[src]'s warp core has breached.")
	core_breach_finish() //They didn't save it. Explode them.
	if(main_overmap)
		SSredbot.send_discord_message("admin", "[src]'s antimatter containment failed, ending the round", "game")

/obj/structure/overmap/proc/core_breach()
	if(!main_overmap)
		if(!linked_area)
			find_area()
		for(var/mob/player in linked_area)
			SEND_SOUND(player, 'DS13/sound/effects/damage/ship_explode.ogg')
		return
	for(var/mob/player in GLOB.player_list)
		var/area/A = get_area(player)
		if(is_station_level(player.z) && GLOB.teleportlocs[A.name])
			SEND_SOUND(player, 'DS13/sound/effects/damage/ship_explode.ogg')

/obj/structure/overmap/proc/core_breach_finish()
	if(main_overmap)
		Cinematic(CINEMATIC_SHIPEXPLODE,world)
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = 1
		for(var/X in GLOB.teleportlocs) //If it's not a game-ender. Blow the shit out of the ship map
			var/area/target = GLOB.teleportlocs[X] //Pick a station area and yeet it.
			var/turf/T = pick(get_area_turfs(target))
			explosion(T,10,10,10) //Unlucky sod
	else
		for(var/I = 0, I <= 11, I++) //If it's not a game-ender. Blow the shit out of the ship map
			if(linked_area)
				var/turf/T = pick(get_area_turfs(linked_area))
				explosion(T,10,10,10)
	qdel(src)

/obj/structure/overmap/proc/special_fx_targeted(var/shields_absorbed) //This ship isn't the main overmap, so find the area we want and apply damage to it
	if(!linked_area)
		find_area()
	for(var/mob/player in linked_area)
		shake_camera(player, 1,3)
		if(shields_absorbed)
			if(prob(50))
				var/sound/shieldhit = pick('DS13/sound/effects/damage/shield_hit.ogg','DS13/sound/effects/damage/shield_hit2.ogg')
				SEND_SOUND(player, shieldhit)
			continue
		var/sound/S = pick('DS13/sound/effects/damage/shiphit.ogg','DS13/sound/effects/damage/shiphit2.ogg','DS13/sound/effects/damage/shiphit3.ogg','DS13/sound/effects/damage/creak1.ogg','DS13/sound/effects/damage/creak2.ogg')
		SEND_SOUND(player, S)
	if(prob(40))
		var/turf/T = pick(get_area_turfs(target))
		new /obj/effect/temp_visual/explosion_telegraph(T)
	if(prob(10))
		var/turf/T = pick(get_area_turfs(linked_area))
		T.atmos_spawn_air("plasma=20;TEMP=1000")


/obj/structure/overmap/proc/show_damage(var/amount, var/shields_absorbed) //Flash up numbers showing how much damage we just took
	if(amount > 100)
		amount = 100 //We can only show up to 100 currently
	//amount = round(10) //Get it to the nearest 10
	if(shields_absorbed)
		switch(amount)
			if(0 to 9) new /obj/effect/temp_visual/damage_indicator/shield/zero (src.loc) //Shields took the hit, show a blue number
			if(10 to 19) new /obj/effect/temp_visual/damage_indicator/shield (src.loc)
			if(20 to 29) new /obj/effect/temp_visual/damage_indicator/shield/twenty (src.loc)
			if(30 to 39) new /obj/effect/temp_visual/damage_indicator/shield/thirty (src.loc)
			if(40 to 49) new /obj/effect/temp_visual/damage_indicator/shield/forty (src.loc)
			if(50 to 59) new /obj/effect/temp_visual/damage_indicator/shield/fifty (src.loc)
			if(60 to 69) new /obj/effect/temp_visual/damage_indicator/shield/sixty (src.loc)
			if(70 to 79) new /obj/effect/temp_visual/damage_indicator/shield/seventy (src.loc)
			if(80 to 89) new /obj/effect/temp_visual/damage_indicator/shield/eighty (src.loc)
			if(90 to 99) new /obj/effect/temp_visual/damage_indicator/shield/ninety (src.loc)
			if(100) new /obj/effect/temp_visual/damage_indicator/shield/hundred (src.loc)
		return TRUE
	else
		switch(amount)
			if(0 to 9) new /obj/effect/temp_visual/damage_indicator/zero (src.loc) //Shields couldn't take the hit, show a red number
			if(10 to 19) new /obj/effect/temp_visual/damage_indicator (src.loc)
			if(20 to 29) new /obj/effect/temp_visual/damage_indicator/twenty (src.loc)
			if(30 to 39) new /obj/effect/temp_visual/damage_indicator/thirty (src.loc)
			if(40 to 49) new /obj/effect/temp_visual/damage_indicator/forty (src.loc)
			if(50 to 59) new /obj/effect/temp_visual/damage_indicator/fifty (src.loc)
			if(60 to 69) new /obj/effect/temp_visual/damage_indicator/sixty (src.loc)
			if(70 to 79) new /obj/effect/temp_visual/damage_indicator/seventy (src.loc)
			if(80 to 89) new /obj/effect/temp_visual/damage_indicator/eighty (src.loc)
			if(90 to 99) new /obj/effect/temp_visual/damage_indicator/ninety (src.loc)
			if(100) new /obj/effect/temp_visual/damage_indicator/hundred (src.loc)
		return TRUE

/obj/effect/temp_visual/damage_indicator/zero
	icon_state = "0"

/obj/effect/temp_visual/damage_indicator/shield/zero
	icon_state = "0"

/obj/effect/temp_visual/damage_indicator
	icon = 'DS13/icons/overmap/effects.dmi'
	icon_state = "10"
	duration = 15
	color = "#FF0000"

/obj/effect/temp_visual/damage_indicator/twenty
	icon_state = "20"

/obj/effect/temp_visual/damage_indicator/thirty
	icon_state = "30"

/obj/effect/temp_visual/damage_indicator/forty
	icon_state = "40"

/obj/effect/temp_visual/damage_indicator/fifty
	icon_state = "50"

/obj/effect/temp_visual/damage_indicator/sixty
	icon_state = "60"

/obj/effect/temp_visual/damage_indicator/seventy
	icon_state = "70"

/obj/effect/temp_visual/damage_indicator/eighty
	icon_state = "80"

/obj/effect/temp_visual/damage_indicator/ninety
	icon_state = "90"

/obj/effect/temp_visual/damage_indicator/hundred
	icon_state = "100"

/obj/effect/temp_visual/damage_indicator/shield
	icon = 'DS13/icons/overmap/effects.dmi'
	icon_state = "10"
	duration = 15
	color = "#00E0FF"

/obj/effect/temp_visual/damage_indicator/shield/twenty
	icon_state = "20"

/obj/effect/temp_visual/damage_indicator/shield/thirty
	icon_state = "30"

/obj/effect/temp_visual/damage_indicator/shield/forty
	icon_state = "40"

/obj/effect/temp_visual/damage_indicator/shield/fifty
	icon_state = "50"

/obj/effect/temp_visual/damage_indicator/shield/sixty
	icon_state = "60"

/obj/effect/temp_visual/damage_indicator/shield/seventy
	icon_state = "70"

/obj/effect/temp_visual/damage_indicator/shield/eighty
	icon_state = "80"

/obj/effect/temp_visual/damage_indicator/shield/ninety
	icon_state = "90"

/obj/effect/temp_visual/damage_indicator/shield/hundred
	icon_state = "100"

/obj/effect/temp_visual/damage_indicator/Initialize()
	. = ..()
	while(!QDELETED(src))
		stoplag()
		pixel_y += 1