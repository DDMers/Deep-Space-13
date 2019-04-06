/obj/screen/alert/radar
	name = "Navigational sensors"
	desc = "Tracks nearby warp signatures. Click it to track a ship."
	icon_state = "base"
	icon = 'DS13/icons/actions/radar.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/obj/structure/overmap/theship

/obj/screen/alert/radar/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess,src)

/obj/screen/alert/radar/Destroy()
	STOP_PROCESSING(SSfastprocess,src)
	. = ..()

/obj/screen/alert/radar/process()
	update_icon()

/obj/screen/alert/radar/Click(location, control, params)
	var/mob/living/L = usr
	if(!theship)
		theship = L.overmap_ship
	if(L != theship.pilot)
		return
	var/A
	var/list/targets = list() //Nav targets we can choose from
	for(var/obj/structure/overmap/OM in GLOB.overmap_ships)
		if(OM == theship)
			continue
		if(OM.cloaked)
			continue
		if(OM.z == theship.z)
			targets += OM
	A = input("Track a ship", "Ship navigation", A) as null|anything in targets//overmap_objects
	if(!A)
		return
	var/obj/structure/overmap/O = A
	theship.nav_target = O

/obj/screen/alert/radar/update_icon()
	cut_overlays()
	if(!theship)
		var/mob/living/L = mob_viewer
		theship = L.overmap_ship
	var/progress = theship.health
	var/goal = theship.max_health
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 20)
	var/image/I = image('DS13/icons/actions/radar.dmi',icon_state = "[progress]") //Display a little ship with your health stats
	add_overlay(I)
	for(var/obj/structure/overmap/OM in GLOB.overmap_ships) //Iterate thru ships, find ones close to us. Then update radar
		if(OM == theship)
			continue //No need to show ourselves on the radar!
		if(OM.z == theship.z)
			if(OM.cloaked)
				continue
			if(get_dist(theship, OM) <= 1)
				var/image/blip = image('DS13/icons/actions/radar.dmi',icon_state = "center") //They're right on top of you
				add_overlay(blip)
				continue
			var/target_angle = Get_Angle(theship, OM) //See combat.dm for explanation
			var/radar_dir = angle2dir(target_angle)
			if(get_dist(theship, OM) <= 5)
				var/image/blip = image('DS13/icons/actions/radar.dmi',icon_state = "[radar_dir]-near") //Display a blip that's near to us
				add_overlay(blip)
				continue
			var/image/blip = image('DS13/icons/actions/radar.dmi',icon_state = "[radar_dir]") //Display a blip that isn't near to us
			add_overlay(blip)
