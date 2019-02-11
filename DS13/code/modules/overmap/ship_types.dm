/obj/structure/overmap/miranda
	name = "Miranda class light cruiser"
	desc = "An all purpose, reliable starship. It has a modest armament."
	icon = 'DS13/icons/overmap/miranda.dmi'
	icon_state = "miranda"
	main_overmap = TRUE
	damage = 10 //Will turn into 20 assuming weapons powered
	class = "miranda"
	damage_states = TRUE //Damage FX

/obj/structure/overmap/miranda/apply_shield_boost() //Miranda starts with some boosted shields
	shields.north += max_shield_health
	shields.south += max_shield_health

/obj/structure/overmap/shuttle
	name = "Shuttlepod"
	desc = "A small, self contained starship. It has minimal shields and weapons"
	icon = 'DS13/icons/overmap/shuttle.dmi'
	icon_state = "shuttle"
	damage = 0 //Will turn into 10 assuming weapons powered
	max_shield_health = 75
	class = "shuttlepod"
	max_speed = 6
	turnspeed = 2

/obj/structure/overmap/warbird
	name = "Romulan warbird class light cruiser"
	desc = "A dangerous ship which resembles a bird. It has a modest armament and is highly maneuverable."
	icon = 'DS13/icons/overmap/warbird.dmi'
	icon_state = "warbird"
	main_overmap = FALSE
	class = "warbird"
	damage_states = FALSE //Damage FX
	damage = 10 //Will turn into 20 assuming weapons powered

/obj/structure/overmap/miranda/apply_shield_boost() //Miranda starts with some boosted shields
	shields.north += max_shield_health
	shields.south += max_shield_health