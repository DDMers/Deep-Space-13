/area/ship
	var/occupied_by_ai = FALSE //Are we linked to an AI ship? If not, then let a simulated AI ship link to us.

/area/ship/ai_simulated
	name = "Salvageable romulan ship (1)"
	icon_state = "warbird"
	class = "fucknolmao" //This is not used as the AIs that need to grab an area do so manually.
	looping_ambience = 'DS13/sound/ambience/romulan.ogg'

/area/ship/ai_simulated_secondary //Turns out subtypes of areas share the same vars as the base area for no goddamn reason! Huzzah!
	name = "Salvageable romulan ship (2)"
	icon_state = "warbird"
	class = "fucknolmao" //This is not used as the AIs that need to grab an area do so manually.
	looping_ambience = 'DS13/sound/ambience/romulan.ogg'

/area/ship/ai_simulated_tertiary
	name = "Salvageable romulan ship (3)"
	icon_state = "warbird"
	class = "fucknolmao" //This is not used as the AIs that need to grab an area do so manually.
	looping_ambience = 'DS13/sound/ambience/romulan.ogg'

/obj/structure/overmap/ai/simulated //Subtypes of this use an interior. They don't blow up and allow the players to loot 'em. These ones are slightly more buff to signify how theyre simulated.
	name = "Alpha Warbird"
	desc = "The leader of a pack of warbirds"
	max_health = 175

/obj/structure/overmap/ai/simulated/OvermapInitialize()
	. = ..()
	var/area/ship/target = null
	for(var/area in GLOB.sortedAreas)
		var/area/AR = area
		if(istype(AR, /area/ship/ai_simulated) || istype(AR, /area/ship/ai_simulated_secondary) || istype(AR, /area/ship/ai_simulated_tertiary))
			var/area/ship/AI = AR
			if(AI.occupied_by_ai)
				continue
			target = AI
	if(target)
		target.linked_overmap = src
		target.occupied_by_ai = TRUE
		linked_area = target
		target.name = name

/obj/structure/overmap/ai/simulated/explode()
	send_sound_crew('DS13/sound/effects/damage/ship_explode.ogg')
	SpinAnimation(1000,1000)
	weapon_power = 0
	shield_power = 0
	engine_power = 0
	power_slots = 0
	movement_block = TRUE
	remove_control()
	icon_state = "[icon_state]-wrecked"
	health = 100
	check_power()
	destroyed = TRUE
	for(var/mob/A in operators)
		to_chat(A, "<span class='cult'><font size=3>Your ship has been destroyed!</font></span>")
		if(A.remote_control)
			A.remote_control.forceMove(get_turf(A))

/obj/structure/overmap/ai/simulated/dderidex //Simulated DDERI for loot purposes
	name = "Dderidex class heavy cruiser"
	desc = "Vicious, huge, fast. The Dderidex class is the Romulan navy's most popular warship for a reason. It has an impressive armament and cloaking technology."
	icon = 'DS13/icons/overmap/dderidex.dmi'
	icon_state = "dderidex"
	main_overmap = FALSE
	class = "dderidex"
	damage_states = TRUE //Damage FX
	damage = 10 //Will turn into 20 assuming weapons powered
	faction = "romulan"
	max_shield_health = 200
	max_health = 200 //Extremely fucking tanky
	pixel_z = -128
	pixel_w = -120

/obj/structure/overmap/ai/simulated/core_breach_finish()
	return FALSE

/area/ship/debrisfield
	name = "Debris field"
	class = "debris1"

/area/ship/asteroiddebris
	name = "Asteroid field"
	class = "debris2"

/obj/structure/overmap/debris_field
	name = "Debris field"
	icon = 'DS13/icons/obj/meteor_storm.dmi'
	icon_state = "debris"
	class = "debris1"

/obj/structure/overmap/debris_field/asteroid
	name = "Asteroid field"
	icon = 'DS13/icons/obj/meteor_storm.dmi'
	icon_state = "storm"
	class = "debris2"

/obj/structure/overmap/debris_field/Initialize()
	. = ..()
	SpinAnimation(1000,1000)