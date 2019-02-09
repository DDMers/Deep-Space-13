/*

Hey! Listen!
Stuff you need to know:
When making a new ship, please include its directional shields in the SAME ICON AS THE SHIP so you can ensure they fit!

*/
/obj/structure/overmap
	name = "Ship"
	desc = "Since Zephram cochrane's first flight, humanity has always had its head in the stars."
	icon = 'DS13/icons/overmap/pancake.dmi'
	icon_state = "pancake"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/obj/shield_overlay/shield_overlay

/obj/structure/overmap/miranda
	name = "Miranda class light cruiser"
	desc = "An all purpose, reliable starship. It has a modest armament."

/obj/shield_overlay
	name = "Shield effect"
	animate_movement = 0

//Combat variables
/obj/structure/overmap
	max_integrity = 200
	var/ammo_type = /obj/item/ammo_casing/energy/laser
	var/datum/shield_controller/shields
	var/max_shield_health = 100 //Change this if you want STRONG shields
	var/health
	var/max_health

/obj/structure/overmap/proc/OvermapInitialize() //Called before the while loop which allows movement
	shield_overlay = new(get_turf(src))
	shields = new(src)
	shields.holder = src
	shields.max_health = max_shield_health
	apply_shield_boost()
	shields.generate_overlays()
	health = max_health

/obj/structure/overmap/proc/apply_shield_boost() //If you want to start out with some shields that are stronger than others
	return

/obj/structure/overmap/miranda/apply_shield_boost() //Miranda starts with some boosted shields
	shields.north += max_shield_health
	shields.south += max_shield_health