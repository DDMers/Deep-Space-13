/area/ship
	name = "generic"
	icon = 'DS13/icons/turf/areas.dmi'
	icon_state = "ship"
	noteleport = TRUE //Scrub it from teleportlocs

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

/obj/structure/overmap/miranda/starter
	name = "USS Sisko"
	desc = "A starship that's been to hell and back but is still somehow in one piece and is the veteran of countless battles. \n This ship is a testament to the crews that have staffed her over the years and despite her state, she'll get you where you need to go. Despite its aging design, it has a modest armament."

/obj/structure/trek_decor/plaque
	name = "Dedication plaque" //Right where it belongs
	desc = "A large, bronze plaque with a dedication: \n <b>USS Sisko. <b>Miranda-class <> Starfleet registry: NCC-2503 <>\n  Launched stardate: 0000.00 <> Utopia Planetia ShipYards <> United Federation Of Planets. \n</b>" //This ship has not yet been christened.
	icon_state = "plaque"
	var/list/supervisors = list("Captain Declan Reade, Admiral Nigel Schneider") //Put all the names of those who attended the launch here :)
	var/list/engineers = list("Captain Declan Reade, Ian Cooper")
	var/inscription = "Illegitimi non carborundum" //Don't let the bastards grind you down

/obj/structure/trek_decor/plaque/attack_hand(mob/user)
	. = ..()
	visible_message("[user] brushes some dust off [src]")

/obj/structure/trek_decor/plaque/proc/list2text(var/list/the_list, separator)
	var/total = the_list.len
	if (total == 0)														// Nothing to work with.
		return
	var/newText = "[the_list[1]]"										// Treats any object/number as text also.
	var/count
	for (count = 2, count <= total, count++)
		if (separator)
			newText += separator
		newText += "[the_list[count]]"
	return newText

/obj/structure/trek_decor/plaque/examine(mob/user)
	. = ..()
	to_chat(user, "<span_class='notice'><b>Launch supervised by: [list2text(supervisors)]</b></span>")
	to_chat(user, "<span_class='notice'><b>Retrofit conducted by: [list2text(supervisors)]</b></span>")
	to_chat(user, "<i>There is a small inscription underneath it: '[inscription]'</i>")

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

/obj/structure/overmap/saladin //A really underpowered destroyer / frying pan with a total of 4 power slots. Wow
	name = "Uss Sherman"
	desc = "An oddly designed ship featuring a saucer section applied directly onto a nacelle. It is extremely weak in battle, but posesses unusually high speed"
	icon = 'DS13/icons/overmap/saladin.dmi'
	icon_state = "saladin"
	main_overmap = FALSE
	class = "saladin"
	damage_states = TRUE //Damage FX
	damage = 5 //Will turn into 15 assuming weapons powered
	faction = "starfleet"
	turnspeed = 2.5
	max_speed = 10
	max_health = 120 //Weak as shit

/obj/structure/trek_decor/plaque/saladin
	name = "Dedication plaque"
	desc = "A large, bronze plaque with a dedication: \n <b>USS Sherman. <b>Saladin-class <> Starfleet registry: NCC-426 <>\n  Launched stardate: -72858.34459030957 <> Utopia Planetia ShipYards <> United Federation Of Planets. \n</b>"
	icon_state = "plaque"
	supervisors = list("Captain Caitlyn Sidower, Declan Reade, Art Cox")
	engineers = list("Caitlyn Sidower, Ian Cooper, Declan Reade")
	inscription = "Carpe diem"

/area/ship/saladin
	name = "Saladin class patrol craft"
	icon_state = "saladin"
	class = "saladin"