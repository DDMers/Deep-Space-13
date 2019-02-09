/*

Hey! Listen!
Stuff you need to know:
When making a new ship, please include its directional shields in the SAME ICON AS THE SHIP so you can ensure they fit!

*/


/obj/structure/overmap
	name = "Ship"
	desc = "Since Zephram cochrane's first flight, humanity has always had its head in the stars."
	icon = 'DS13/icons/overmap/ships.dmi'
	icon_state = "pancake"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

//Combat variables
/obj/structure/overmap
	max_integrity = 200
	var/ammo_type = /obj/item/ammo_casing/energy/laser
	var/datum/shield_controller/shields
	var/max_shield_health = 100 //Change this if you want STRONG shields

/obj/structure/overmap/Initialize()
	. = ..()
	shields = new(src)
	shields.holder = src
	shields.max_health = max_shield_health
	shields.generate_overlays()

/obj/structure/overmap/examine(mob/living/user)
	. = ..()
	var/amount = 10 //Default damage for testing only
	var/damage_dir = get_dir(src, user) //Get dir, us, them.
	say("[damage_dir]")
	if(shields.absorb_damage(amount, damage_dir))
		say("Shields survived!")
		show_damage(amount, TRUE)
	else
		say("Ow fuck that hurt")
		show_damage(amount)

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