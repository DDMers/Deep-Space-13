/mob/living/carbon/canMobMousedown(atom/object, location, params)
	. = ..()
	if(!overmap_ship)
		return
	. = overmap_ship


/obj/structure/overmap
	var/weapons_ready = TRUE //Are we ready to fire? This is a straight cooldown
	var/weapons_cooldown = 8 //Fire every second. Addtimer is slow so watch out
	var/datum/beam/current_beam = null //Our phaser beam, wow!
	var/damage = 10 //How much damage do we do?

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
	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		if(istype(object, /obj/structure/overmap))
			nav_target = object
			return
	if(modifiers["shift"])
		var/atom/obj = object
		return obj.examine(mob)
	if(weapons_ready && mob == tactical)
		fire()

/obj/structure/overmap/proc/fire(var/obj/structure/overmap/target)
	target.take_damage(src, damage)
	addtimer(CALLBACK(src, .proc/recharge_weapons), weapons_cooldown)
	weapons_ready = FALSE
	var/source = get_turf(src)
	if(current_beam)
		qdel(current_beam)
	current_beam = new(source,target,time=100,beam_icon_state="solar_beam",maxdistance=5000,btype=/obj/effect/ebeam)
	spawn(0)
		current_beam.Start()

/obj/structure/overmap/proc/recharge_weapons()
	weapons_ready = TRUE

/obj/structure/overmap/attack_hand(mob/user) //I will need this later to show radial menus
	if(user.remote_control in crew) //This means theyre one of our officers, so show them the appropriate radial TODO!
		. = ..()
	else
		enter(user)

/obj/structure/overmap/take_damage(var/atom/source, var/amount = 10)
	. = ..()
	var/datum/position/pos1 = new /datum/position(src)
	var/datum/position/pos2 = new /datum/position(source)
	var/turf/us = pos1.return_turf()
	var/turf/them = pos2.return_turf()
	var/damage_dir = get_dir(us, them)
	say("[damage_dir]")
	if(shields.absorb_damage(amount, damage_dir))
		show_damage(amount, TRUE)
	else
		health -= amount
		new /obj/effect/temp_visual/ship_explosion(get_turf(src))
		show_damage(amount)
	if(health <= 0)
		qdel(src)

/obj/structure/overmap/proc/show_damage(var/amount, var/shields_absorbed) //Flash up numbers showing how much damage we just took
	if(amount > 100)
		amount = 100 //We can only show up to 100 currently
	if(shields_absorbed)
		var/obj/effect/temp_visual/damage_indicator/shield/num = new(src.loc) //Shields took the hit, show a blue number
		num.icon_state = "[amount]"
		return TRUE
	else
		var/obj/effect/temp_visual/damage_indicator/num = new(src.loc) //Shields took the hit, show a blue number
		num.icon_state = "[amount]"

/obj/effect/temp_visual/damage_indicator
	icon = 'DS13/icons/overmap/effects.dmi'
	icon_state = "10"
	duration = 15
	color = "#FF0000"

/obj/effect/temp_visual/damage_indicator/shield
	icon = 'DS13/icons/overmap/effects.dmi'
	icon_state = "10"
	duration = 15
	color = "#00E0FF"

/obj/effect/temp_visual/damage_indicator/shieldhit
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	duration = 8

/obj/effect/temp_visual/damage_indicator/Initialize()
	. = ..()
	while(!QDELETED(src))
		stoplag()
		pixel_y += 1