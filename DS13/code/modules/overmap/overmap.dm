/*

Hey! Listen!
Stuff you need to know:
When making a new ship, please include its directional shields in the SAME ICON AS THE SHIP so you can ensure they fit!

*/
GLOBAL_LIST_INIT(overmap_ships, list())

/obj/structure/overmap
	name = "Ship"
	desc = "Since Zephram cochrane's first flight, humanity has always had its head in the stars."
	icon = 'DS13/icons/overmap/pancake.dmi'
	icon_state = "pancake"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/obj/shield_overlay/shield_overlay
	var/class = "nothing" //This is a nothing class heavy cruiser

/obj/shield_overlay
	name = ""
	animate_movement = 0

//Combat variables
/obj/structure/overmap
	max_integrity = 200
	var/ammo_type = /obj/item/ammo_casing/energy/laser
	var/datum/shield_controller/shields
	var/max_shield_health = 100 //Change this if you want STRONG shields
	var/health = 0
	var/max_health = 200
	var/area/override_linked_ship //If we're not the main overmap, we'd best link to an area! If you place an overmap in /area/ship it will NOT be the main overmap, so use station areas instead!
	var/main_overmap = FALSE //Is this the main overmap? Is it gonna be linked to all station areas?

/obj/structure/overmap/proc/OvermapInitialize() //Called before the while loop which allows movement
	shield_overlay = new(get_turf(src))
	shields = new(src)
	shields.holder = src
	shields.max_health = max_shield_health
	shields.generate_overlays()
	health = max_health
	check_power()
	GLOB.overmap_ships += src


//	var/area/A = get_area(src)
//	if(istype(A, /area/ship))		UNCOMMENT THIS WHEN DOCKING IS DONE!
	//	override_linked_ship = A
	//	return

/obj/structure/overmap/Destroy()
	. = ..()


/obj/structure/overmap/proc/apply_shield_boost() //If you want to start out with some shields that are stronger than others
	return
