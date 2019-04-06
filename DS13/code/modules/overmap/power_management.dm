/obj/structure/overmap
	var/shield_power = 0
	var/weapon_power = 0
	var/engine_power = 0
	var/max_shield_power = 0
	var/max_weapon_power = 0
	var/max_engine_power = 0
	var/power_slots = 4 //Power all systems, and one bonus piece for playing around

/obj/structure/overmap/proc/power_ship() //Admin only! This gets you to full power for testing
	max_shield_power = 4
	max_weapon_power = 4
	max_engine_power = 4
	shield_power = 4
	weapon_power = 4
	engine_power = 4
	check_power()

/obj/structure/overmap/OvermapInitialize()
	. = ..()
	shield_power = 1
	weapon_power = 1
	engine_power = 1
	power_slots -= 3
	check_power()
	if(AI_enabled)
		take_control()

/obj/structure/overmap/proc/check_power(var/play_voice = FALSE)
	if(power_slots < 0)
		power_slots = 0
	if(max_shield_power < shield_power) //EG. power = 4, max = 2
		var/diff = shield_power - max_shield_power //4 - 2 = 2
		shield_power = max_shield_power //2
		power_slots += diff //+= 2
	if(max_weapon_power < weapon_power)
		var/diff = weapon_power - max_weapon_power
		weapon_power = max_weapon_power
		power_slots += diff
	if(max_engine_power < engine_power)
		var/diff = engine_power - max_engine_power
		engine_power = max_engine_power
		power_slots += diff
	var/new_chargerate = initial(shields.chargerate) + (shield_power/2) //Nerfed this so that shields become more of an issue when they go down
	var/new_damage = initial(damage)+(weapon_power*10)
	var/new_speed = initial(max_speed)+engine_power
	var/new_turnspeed = initial(turnspeed)+(engine_power/4) //Slight buff to turnspeed, maximum of 0.6 which does make a decent difference
	max_warp = initial(max_warp)+engine_power
	shields.chargerate = new_chargerate //A slight buff to shields can really help
	damage = new_damage
	max_speed = new_speed
	turnspeed = new_turnspeed
	if(shield_power <= 0)
		shields.depower()
		shields.chargerate = 0
		if(play_voice)voice_alert('DS13/sound/effects/voice/ShieldsDisabled.ogg')
	if(weapon_power <= 0)
		damage = 0
		if(play_voice)voice_alert('DS13/sound/effects/voice/PhasersDisabled.ogg')
	if(engine_power <= 0)
		max_speed = 0
		turnspeed = 0
		if(play_voice)voice_alert('DS13/sound/effects/voice/ImpulseDisabled.ogg')

/obj/structure/overmap/proc/after_enter(mob/user)
	user.throw_alert("Radar",/obj/screen/alert/radar)
	if(user == science)
		user.throw_alert("Shield Management", /obj/screen/alert/power_manager/shields)
		user.throw_alert("Weapon Management", /obj/screen/alert/power_manager/weapons)
		user.throw_alert("Engine Management", /obj/screen/alert/power_manager/engines)
		user.throw_alert("Reactor core", /obj/screen/alert/power_manager/power_slot)
		for(var/obj/screen/alert/power_manager/C in user.alerts)
			C.theship = src
			C.update_icon() //Show what power level we are currently at

/obj/structure/overmap/proc/after_exit(mob/user)
	user.clear_alert("Radar",/obj/screen/alert/radar)
	if(user == science)
		user.clear_alert("Shield Management", /obj/screen/alert/power_manager/shields)
		user.clear_alert("Weapon Management", /obj/screen/alert/power_manager/weapons)
		user.clear_alert("Engine Management", /obj/screen/alert/power_manager/engines)
		user.clear_alert("Reactor core", /obj/screen/alert/power_manager/power_slot)

/obj/screen/alert/power_manager
	icon = 'DS13/icons/actions/power_management.dmi'
	icon_state = "default"
	name = "Subsystem power"
	desc = "Assign subsystem power with this."
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/obj/structure/overmap/theship
	var/system = "nothing" //Flufftext

/obj/screen/alert/power_manager/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/update_icon), 8)

/obj/screen/alert/power_manager/update_icon()
	if(!theship)
		theship = mob_viewer.overmap_ship
	cut_overlays()
	return

/obj/screen/alert/power_manager/proc/remove_power()
	theship.power_slots ++ //Add power to the main bank from which we can draw.
	return

/obj/screen/alert/power_manager/proc/add_power() //Handle the math of powering up a system
	if(theship.power_slots <= 0)
		return
	theship.power_slots --
	return

/obj/screen/alert/power_manager/shields
	name = "Shield system power"
	icon_state = "shields"
	system = "shields"

/obj/screen/alert/power_manager/shields/remove_power()
	if(theship.shield_power > 0)
		theship.shield_power --
		update_icon()
		. = ..()

/obj/screen/alert/power_manager/shields/add_power()
	if(theship.power_slots <= 0)
		return
	if(theship.shield_power < theship.max_shield_power)
		theship.shield_power ++
	else
		return
	update_icon()
	. = ..()

/obj/screen/alert/power_manager/shields/update_icon()
	. = ..()
	var/num = theship.shield_power
	if(num > 4) //Only 4 states supported thus far!
		num = 4 //So the bars don't go all fucky
	var/image/I = image('DS13/icons/actions/power_management.dmi',icon_state = "[num]")
	var/image/II = image('DS13/icons/actions/power_management.dmi',icon_state = "c[theship.max_shield_power]")
	add_overlay(I)
	add_overlay(II)

/obj/screen/alert/power_manager/weapons
	name = "Weapons system power"
	icon_state = "weapons"
	system = "weapons"

/obj/screen/alert/power_manager/weapons/remove_power()
	if(theship.weapon_power > 0)
		theship.weapon_power --
		update_icon()
		. = ..()

/obj/screen/alert/power_manager/weapons/add_power()
	if(theship.power_slots <= 0)
		return
	if(theship.weapon_power < theship.max_weapon_power)
		theship.weapon_power ++
	else
		return
	update_icon()
	. = ..()

/obj/screen/alert/power_manager/weapons/update_icon()
	. = ..()
	var/num = theship.weapon_power
	if(num > 4) //Only 4 states supported thus far!
		num = 4 //So the bars don't go all fucky
	var/image/I = image('DS13/icons/actions/power_management.dmi',icon_state = "[num]")
	var/image/II = image('DS13/icons/actions/power_management.dmi',icon_state = "c[theship.max_weapon_power]")
	add_overlay(I)
	add_overlay(II)

/obj/screen/alert/power_manager/engines
	name = "Engine system power"
	icon_state = "engines"
	system = "engines"

/obj/screen/alert/power_manager/engines/remove_power()
	if(theship.engine_power > 0)
		theship.engine_power --
		update_icon()
		. = ..()

/obj/screen/alert/power_manager/engines/add_power()
	if(theship.power_slots <= 0)
		return
	if(theship.engine_power < theship.max_engine_power)
		theship.engine_power ++
	else
		return
	update_icon()
	. = ..()

/obj/screen/alert/power_manager/engines/update_icon()
	. = ..()
	var/num = theship.engine_power
	if(num > 4) //Only 4 states supported thus far!
		num = 4 //So the bars don't go all fucky
	var/image/I = image('DS13/icons/actions/power_management.dmi',icon_state = "[num]")
	var/image/II = image('DS13/icons/actions/power_management.dmi',icon_state = "c[theship.max_engine_power]")
	add_overlay(I)
	add_overlay(II)

/obj/screen/alert/power_manager/power_slot
	name = "Reactor core"
	desc = "The total power slots your ship has"
	icon_state = "power_slot"

/obj/screen/alert/power_manager/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess,src)

/obj/screen/alert/power_manager/process()
	update_icon()

/obj/screen/alert/power_manager/Destroy()
	STOP_PROCESSING(SSfastprocess,src)
	. = ..()

/obj/screen/alert/power_manager/power_slot/remove_power()
	return

/obj/screen/alert/power_manager/power_slot/add_power()
	return

/obj/screen/alert/power_manager/power_slot/update_icon()
	cut_overlays()
	if(!theship)
		var/mob/living/L = mob_viewer
		theship = L.overmap_ship
	var/num = theship.power_slots
	if(num > 4) //Only 4 states supported thus far!
		num = 4 //So the bars don't go all fucky
	var/image/I = image('DS13/icons/actions/power_management.dmi',icon_state = "[num]")
	add_overlay(I)

/obj/screen/alert/power_manager/power_slot/Click(location, control, params)
	var/mob/living/L = usr
	if(!theship)
		theship = L.overmap_ship
	update_icon()
	return

/obj/screen/alert/power_manager/Click(location, control, params)
	. = ..()
	var/paramslist = params2list(params)
	var/mob/living/L = usr
	if(!theship)
		theship = L.overmap_ship
	L.changeNext_move(CLICK_CD_RESIST)
	if(paramslist["ctrl"]) // screen objects don't do the normal Click() stuff so we'll cheat
		remove_power()
		theship.check_power(TRUE)
		return
	if(paramslist["alt"]) // screen objects don't do the normal Click() stuff so we'll cheat
		remove_power()
		theship.check_power(TRUE)
		return
	theship.check_power()//Ok first off, do we have any power to transfer?
	if(theship.power_slots > 0) //Looks like we do!
		add_power()
	else
		to_chat(usr, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>power transfer failed! divert power from another system first.</span>")
	theship.check_power(TRUE) //Now check the power after we're done modifying

/obj/structure/overmap/proc/route_controls() //Demo purposes. This means you can shoot, move, and manage all at the same time!
	if(!pilot)
		return
	to_chat(pilot, "<span class='boldnotice'>Emergency override engaged</span> - <span class='warning'>routing full controls to your station.</span>")
	if(tactical)
		exit(tactical)
	if(science)
		exit(science)
	science = pilot
	tactical = pilot
	after_enter(pilot)

/obj/structure/overmap/proc/cheat() //I am supremely lazy -Kmc
	route_controls()