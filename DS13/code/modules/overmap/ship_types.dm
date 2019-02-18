/area/ship
	name = "generic"
	icon = 'DS13/icons/turf/areas.dmi'
	icon_state = "ship"
	var/class = "none"

/area/ship/miranda
	name = "Miranda class light cruiser"
	icon_state = "miranda"
	class = "miranda"

/area/ship/warbird
	name = "Romulan warbird class light cruiser"
	icon_state = "warbird"
	class = "warbird"

/obj/structure/overmap/miranda
	name = "Miranda class light cruiser"
	desc = "An all purpose, reliable starship. It's a tried and tested design that has served the federation for hundreds of years. Despite its aging design, it has a modest armament."
	icon = 'DS13/icons/overmap/miranda.dmi'
	icon_state = "miranda"
	main_overmap = FALSE
	damage = 10 //Will turn into 20 assuming weapons powered
	class = "miranda"
	damage_states = TRUE //Damage FX

/obj/structure/overmap/miranda/apply_shield_boost() //Miranda starts with some boosted shields
	shields.north_max += max_shield_health //Start with some double shields
	shields.south_max += max_shield_health

/obj/structure/overmap/ds13
	name = "Starbase 13"
	desc = "A starbase is almost its own ecosystem due to their massive size, this one is no exception. It has excellent defensive capabilities."
	icon = 'DS13/icons/overmap/station.dmi'
	icon_state = "station"
	main_overmap = TRUE
	damage = 10 //Will turn into 20 assuming weapons powered
	class = "ds13"
	max_speed = 0
	turnspeed = 0
	movement_block = TRUE //You can't turn a station :)
	pixel_x = -32
	pixel_y = -32

/obj/structure/overmap/ds13/apply_shield_boost() //Miranda starts with some boosted shields
	shields.north_max += max_shield_health //Start with some double shields
	shields.north_max += max_shield_health
	shields.south_max += max_shield_health
	shields.east_max += max_shield_health
	shields.west_max += max_shield_health

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
	faction = "romulan"

/obj/structure/overmap/warbird/apply_shield_boost() //Miranda starts with some boosted shields
	shields.north_max += max_shield_health //Start with some double shields
	shields.south_max += max_shield_health