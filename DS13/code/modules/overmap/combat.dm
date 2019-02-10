/mob/living/carbon/canMobMousedown(atom/object, location, params)
	. = ..()
	if(!overmap_ship)
		return
	. = overmap_ship


/obj/structure/overmap
	var/weapons_ready = TRUE //Are we ready to fire? This is a straight cooldown
	var/weapons_cooldown = 25 //Fire every second second. Addtimer is slow so watch out
	var/datum/beam/current_beam = null //Our phaser beam, wow!
	var/damage = 0 //How much damage do we do? This is +10'd assuming weapons are powered!
	var/charging = FALSE //charging weapons? if so, we can't fire
	var/admin_override = FALSE //Need to test? set this on and you can fire and move yourself
	var/fire_mode = "phaser"
	var/photons = 4 //How many torpedoes do we have?

/obj/effect/temp_visual/ship_explosion
	icon = 'DS13/icons/overmap/effects.dmi'
	icon_state = "ship_explode"
	duration = 30

/obj/effect/temp_visual/ship_explosion/Initialize()
	. = ..()
	pixel_x = rand(0,10)
	pixel_y = rand(0,10)

/obj/structure/overmap/proc/onMouseDown(object, location, params, mob/mob)
	if(object == src)
		return attack_hand(mob)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	if(!admin_override) //Allows me to fly and shoot for testing
		if(mob != tactical)
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

/obj/structure/overmap/proc/fire(var/obj/structure/overmap/target)
	if(charging || !weapons_ready)
		return
	addtimer(CALLBACK(src, .proc/recharge_weapons), weapons_cooldown)
	weapons_ready = FALSE
	check_power()
	if(fire_mode == "phaser")
		target.take_damage(src, damage)
		charging = TRUE
		var/source = src
		var/datum/beam/S = new /datum/beam(source,target,time=10,beam_icon_state="solar_beam",maxdistance=5000,btype=/obj/effect/ebeam)
		spawn(0)
			S.Start()
		playsound(src.loc, 'DS13/sound/effects/weapons/phaser.ogg', 70,1)
	else
		if(photons > 0)
			photons --
			addtimer(CALLBACK(src, .proc/recharge_weapons), weapons_cooldown)
			weapons_ready = FALSE
			charging = TRUE
			playsound(src.loc, 'DS13/sound/effects/weapons/torpedo.ogg', 70,1)
			var/obj/item/projectile/beam/laser/photon_torpedo/A = new /obj/item/projectile/beam/laser/photon_torpedo(loc)
			A.starting = loc
			A.preparePixelProjectile(target,src)
			A.pixel_x = rand(0, 5)
			A.fire()
			target.take_damage(src, damage)
		else
			if(tactical)
				to_chat(tactical, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>photon torpedo supply is depleted.</span>")
			return
	if(pilot)
		shake_camera(pilot, 1, 3)
	if(tactical)
		shake_camera(tactical, 1, 3)
	if(science)
		shake_camera(science, 1, 3)

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

/obj/structure/overmap/attack_hand(mob/user) //I will need this later to show radial menus
	if(user.remote_control in crew) //This means theyre one of our officers, so show them the appropriate radial TODO!
		if(user == tactical) //The user is our tactical operator, show him the options
			var/list/options = list("phaser", "torpedo")
			for(var/option in options)
				options[option] = image(icon = 'DS13/icons/actions/weaponselect.dmi', icon_state = "[option]")
			var/dowhat = show_radial_menu(user,src,options)
			if(!dowhat)
				return
			fire_mode = dowhat
			return
	if(!user.overmap_ship)
		enter(user)

/obj/structure/overmap/take_damage(var/atom/source, var/amount = 10)
	. = ..()
	if(pilot)
		shake_camera(pilot, 1, 1)
	if(tactical)
		shake_camera(tactical, 1, 1)
	if(science)
		shake_camera(science, 1, 1)
	if(istype(source, /obj/item/projectile))
		playsound(src.loc, 'DS13/sound/effects/damage/torpedo_hit.ogg', 70,1)
	var/datum/position/pos1 = new /datum/position(src)
	var/datum/position/pos2 = new /datum/position(source)
	var/turf/us = pos1.return_turf()
	var/turf/them = pos2.return_turf()
	var/damage_dir = get_dir(us, them)
	if(shields.absorb_damage(amount, damage_dir))
		show_damage(amount, TRUE)
		special_fx(TRUE)
	else
		health -= amount
		new /obj/effect/temp_visual/ship_explosion(get_turf(src))
		show_damage(amount)
		special_fx(FALSE)
	if(health <= 0)
		qdel(src)

/obj/machinery
	var/list/zaps = list('DS13/sound/effects/damage/consolehit.ogg','DS13/sound/effects/damage/consolehit2.ogg','DS13/sound/effects/damage/consolehit3.ogg','DS13/sound/effects/damage/consolehit4.ogg')
	var/list/bleeps = list('DS13/sound/effects/computer/bleep1.ogg','DS13/sound/effects/computer/bleep2.ogg')


/obj/machinery/proc/explode_effect()
	var/sound = pick(zaps)
	playsound(src.loc, sound, 70,1)
	var/bleep = pick(bleeps)
	playsound(src.loc, bleep, 70,1)
	do_sparks(5, 8, src)

/obj/structure/overmap/proc/special_fx(var/shields_absorbed)
	if(override_linked_ship || !main_overmap)
		return //Not just yet sweetie :)
	var/area = pick(GLOB.teleportlocs)
	var/area/target = GLOB.teleportlocs[area] //Pick a station area and yeet it.
	for(var/mob/player in GLOB.player_list)
		if(is_station_level(player.z))
			if(shields_absorbed)
				if(prob(50))
					SEND_SOUND(player, 'DS13/sound/effects/damage/shield_hit.ogg')
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
		explosion(T,3,4,3)


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