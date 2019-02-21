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
	var/admin_override = FALSE //Need to test? set this on and you can fire and move yourself
	var/fire_mode = "phaser"
	var/photons = 4 //How many torpedoes do we have?
	var/list/weapon_sounds = list('DS13/sound/effects/weapons/phaser.ogg','DS13/sound/effects/weapons/phaser2.ogg','DS13/sound/effects/weapons/phaser3.ogg','DS13/sound/effects/weapons/phaser4.ogg')
	var/obj/structure/overmap/tractor_target = null //Are we tractoring a target? This forces it to move towards us.
	var/datum/beam/tractor_beam = null
	var/hail_ready = TRUE //Hailing cooldown
	var/torpedo_damage = 30
	var/area/linked_area = null
	var/destroyed = FALSE
	var/damage_sector = "shields" //Tactical can change this! What system are we targeting?

/obj/structure/overmap/proc/send_sound_crew(var/sound/S)
	for(var/mob/M in operators)
		SEND_SOUND(M, S)

/obj/structure/overmap/proc/send_text_crew(var/S)
	for(var/mob/M in operators)
		to_chat(M, S)

/obj/effect/temp_visual/ship_explosion
	icon = 'DS13/icons/overmap/effects.dmi'
	icon_state = "ship_explode"
	duration = 30

/obj/effect/temp_visual/ship_explosion/Initialize()
	. = ..()
	pixel_x = rand(0,10)
	pixel_y = rand(0,10)

/obj/structure/overmap/proc/onMouseDown(object, location, params, mob/mob)
	var/sound/thesound = pick('DS13/sound/effects/computer/beep.ogg','DS13/sound/effects/computer/beep2.ogg','DS13/sound/effects/computer/beep3.ogg')
	SEND_SOUND(mob, thesound)
	if(object == src)
		return attack_hand(mob)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	if(!admin_override) //Allows me to fly and shoot for testing
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
	if(charging || !weapons_ready) //So you can't spam it infinitely
		return
	if(!target.process)
		target.process = TRUE
		target.start_process() //In case it's an inactive ship. We still need to tow it!
	addtimer(CALLBACK(src, .proc/recharge_weapons), weapons_cooldown)
	weapons_ready = FALSE
	if(target.shields.check_vulnerability()) //Are their shields above 50% strength?
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
	if(!tractor_target)
		return
	tractor_target.nav_target = null
	tractor_target.vel = 0
	tractor_target = null
	if(tractor_beam)
		qdel(tractor_beam)

/obj/structure/overmap/proc/tractor_pull() //Force the target to turn to us and move towards us.
	if(!tractor_target)
		return
	if(tractor_target.shields.check_vulnerability())
		tractor_target.nav_target = src
		tractor_target.vel = 1
		if(get_dist(src, tractor_target) > 1) //To stop it glitching out when it reaches us
			tractor_target.vel += (max_speed / 1.3)
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
		var/datum/position/pos = RETURN_PRECISE_POSITION(src)
		var/turf/source = pos.return_turf()
		var/datum/beam/S = new /datum/beam(source,target,time=10,beam_icon_state="solar_beam",maxdistance=5000,btype=/obj/effect/ebeam)
		spawn(0)
			S.Start()
		var/sound/SS = pick(weapon_sounds)
		send_sound_crew(SS)
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
			target.take_damage(src, torpedo_damage)
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
	target.send_sound_crew('sound/ai/commandreport.ogg')
	target.send_text_crew(new_message)
	send_text_crew(new_message)
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
	for(var/mob/player in GLOB.player_list)
		var/area/player_area = get_area(player)
		if(is_station_level(player.z) && !istype(player_area,/area/ship))
			if(pilot)
				if(player == pilot) continue
			if(tactical)
				if(player == tactical) continue
			if(science)
				if(player == science) continue
			shake_camera(player, 1,3)
			if(shields_absorbed)
				if(prob(50))
					var/sound/shieldhit = pick('DS13/sound/effects/damage/shield_hit.ogg','DS13/sound/effects/damage/shield_hit2.ogg')
					SEND_SOUND(player, shieldhit)
				continue
			var/sound/S = pick('DS13/sound/effects/damage/shiphit.ogg','DS13/sound/effects/damage/shiphit2.ogg','DS13/sound/effects/damage/shiphit3.ogg','DS13/sound/effects/damage/creak1.ogg','DS13/sound/effects/damage/creak2.ogg')
			SEND_SOUND(player, S)
	var/max = rand(1,5)
	for(var/I = 0, I < max, I ++)
		var/obj/machinery/X = pick(GLOB.machines)
		X.explode_effect()
	if(shields_absorbed)
		return
	if(prob(10))
		var/turf/T = pick(get_area_turfs(target))
		T.atmos_spawn_air("plasma=15;TEMP=2000")
	if(prob(10))
		var/turf/T = pick(get_area_turfs(target))
		explosion(T,0,4,3)


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
		return//Catch: The amount was inputted as something it's not supposed to. This is often caused by torpedoes because projectile code HATES him (click to find out more)
	visual_damage()
	for(var/mob/M in operators)
		shake_camera(M, 1, 3)
	if(istype(source, /obj/item/projectile))
		send_sound_crew('DS13/sound/effects/damage/torpedo_hit.ogg')
//	var/target_angle = Get_Angle(src, source) //Fire a beam from them to us X --->>>> us. This should line up nicely with the phaser beam effect
//	var/damage_dir = angle2dir(target_angle) //Now we have our simulated beam, turn its angle into a dir.
	var/obj/structure/overmap/OM = source
	var/sector = get_quadrant_hit(OM,src)
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
	var/mod = (damage/2) //So you don't blow out the relays too frequently.
	for(var/obj/structure/overmap_component/XX in powered_components)
		if(istype(XX, /obj/structure/overmap_component/plasma_relay))
			var/obj/structure/overmap_component/plasma_relay/PS = XX
			if(PS.supplying == OM.damage_sector && PS.obj_integrity >= 40)
				PS.take_damage(mod)

/obj/structure/overmap/proc/explode()
	qdel(shield_overlay)
	qdel(shields)
	SpinAnimation(1000,1000)
	weapon_power = 0
	shield_power = 0
	engine_power = 0
	power_slots = 0
	movement_block = TRUE
	remove_control()
	send_sound_crew('DS13/sound/effects/damage/ship_explode.ogg')
	addtimer(CALLBACK(src, .proc/core_breach_finish), 450)
	for(var/mob/A in operators)
		to_chat(A, "<span class='cult'><font size=3>Your ship has been destroyed!")
		if(A.remote_control)
			A.remote_control.forceMove(get_turf(A))
	core_breach()


/obj/structure/overmap/proc/core_breach()
	if(!main_overmap)
		if(!linked_area)
			find_area()
		for(var/mob/player in linked_area)
			SEND_SOUND(player, 'DS13/sound/effects/damage/corebreach.ogg')
		return
	for(var/mob/player in GLOB.player_list)
		var/area/player_area = get_area(player)
		if(is_station_level(player.z) && !istype(player_area,/area/ship))
			SEND_SOUND(player, 'DS13/sound/effects/damage/corebreach.ogg')


/obj/structure/overmap/proc/core_breach_finish()
	if(main_overmap)
		Cinematic(CINEMATIC_NUKE_WIN,world)
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = 1
		qdel(src)
		return
	for(var/I = 0, I <= 11, I++) //If it's not a game-ender. Blow the shit out of the ship map
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
		if(prob(10))
			var/turf/T = pick(get_area_turfs(linked_area))
			explosion(T,3,4,3)
		if(prob(10))
			var/turf/T = pick(get_area_turfs(linked_area))
			T.atmos_spawn_air("plasma=15;TEMP=2000")


/obj/structure/overmap/proc/show_damage(var/amount, var/shields_absorbed) //Flash up numbers showing how much damage we just took
	if(amount > 100)
		amount = 100 //We can only show up to 100 currently
	//amount = round(10) //Get it to the nearest 10
	if(shields_absorbed)
		switch(amount)
			if(0 to 9) new /obj/effect/temp_visual/damage_indicator/shield/zero (src.loc) //Shields took the hit, show a blue number
			if(10 to 19) new /obj/effect/temp_visual/damage_indicator/shield (src.loc) //Shields took the hit, show a blue number
			if(20 to 29) new /obj/effect/temp_visual/damage_indicator/shield/twenty (src.loc) //Shields took the hit, show a blue number
			if(30 to 39) new /obj/effect/temp_visual/damage_indicator/shield/thirty (src.loc) //Shields took the hit, show a blue number
			if(40 to 49) new /obj/effect/temp_visual/damage_indicator/shield/forty (src.loc) //Shields took the hit, show a blue number
			if(50 to 59) new /obj/effect/temp_visual/damage_indicator/shield/fifty (src.loc) //Shields took the hit, show a blue number
			if(60 to 69) new /obj/effect/temp_visual/damage_indicator/shield/sixty (src.loc) //Shields took the hit, show a blue number
			if(70 to 79) new /obj/effect/temp_visual/damage_indicator/shield/seventy (src.loc) //Shields took the hit, show a blue number
			if(80 to 89) new /obj/effect/temp_visual/damage_indicator/shield/eighty (src.loc) //Shields took the hit, show a blue number
			if(90 to 99) new /obj/effect/temp_visual/damage_indicator/shield/ninety (src.loc) //Shields took the hit, show a blue number
			if(100) new /obj/effect/temp_visual/damage_indicator/shield/hundred (src.loc) //Shields took the hit, show a blue number
		return TRUE
	else
		switch(amount)
			if(0 to 9) new /obj/effect/temp_visual/damage_indicator/zero (src.loc) //Shields took the hit, show a blue number
			if(10 to 19) new /obj/effect/temp_visual/damage_indicator (src.loc) //Shields took the hit, show a blue number
			if(20 to 29) new /obj/effect/temp_visual/damage_indicator/twenty (src.loc) //Shields took the hit, show a blue number
			if(30 to 39) new /obj/effect/temp_visual/damage_indicator/thirty (src.loc) //Shields took the hit, show a blue number
			if(40 to 49) new /obj/effect/temp_visual/damage_indicator/forty (src.loc) //Shields took the hit, show a blue number
			if(50 to 59) new /obj/effect/temp_visual/damage_indicator/fifty (src.loc) //Shields took the hit, show a blue number
			if(60 to 69) new /obj/effect/temp_visual/damage_indicator/sixty (src.loc) //Shields took the hit, show a blue number
			if(70 to 79) new /obj/effect/temp_visual/damage_indicator/seventy (src.loc) //Shields took the hit, show a blue number
			if(80 to 89) new /obj/effect/temp_visual/damage_indicator/eighty (src.loc) //Shields took the hit, show a blue number
			if(90 to 99) new /obj/effect/temp_visual/damage_indicator/ninety (src.loc) //Shields took the hit, show a blue number
			if(100) new /obj/effect/temp_visual/damage_indicator/hundred (src.loc) //Shields took the hit, show a blue number
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