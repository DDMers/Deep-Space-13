/turf/open/floor/carpet/trek
	name = "90s space carpet"
	desc = "Who said that structural components couldn't be stylish?."
	icon = 'DS13/icons/turf/floors.dmi'
	icon_state = "beige"
	smooth = FALSE

/turf/open/floor/trek
	name = "Hull plating"
	desc = "Dark and to the point, very atypical of the federation"
	icon = 'DS13/icons/turf/floors.dmi'
	icon_state = "padded"

/turf/open/floor/trek/tile
	name = "Tiled hull plating"
	desc = "Dark and to the point, very atypical of the federation"
	icon = 'DS13/icons/turf/floors.dmi'
	icon_state = "dark-tile"

/obj/effect/turf_decal/trek
	icon = 'DS13/icons/turf/trek_turfs.dmi'
	icon_state = "trek_edge"

/obj/effect/turf_decal/trek/grey
	icon = 'DS13/icons/turf/trek_turfs.dmi'
	icon_state = "trek_edge3"

/obj/structure/chair/trek
	name = "Padded leather chair"
	desc = "Just looking at this thing makes you feel comfy."
	icon = 'DS13/icons/obj/chairs.dmi'
	icon_state = "comfy"

/obj/structure/chair/trek/standard
	name = "Chair"
	desc = "This chair looks comfortable, but not the best starfleet has to offer.."
	icon = 'DS13/icons/obj/chairs.dmi'
	icon_state = "chair"

/obj/structure/chair/trek/dark
	name = "Tactical chair"
	desc = "A sleek, dark chair with lumbar support."
	icon = 'DS13/icons/obj/chairs.dmi'
	icon_state = "dark"

/turf/closed/wall/trek //This is a showpiece! It does NOT match the new smoothing template. Update it asap and never mix it with other walls or it'll look strange
	name = "Starship corridor"
	icon = 'DS13/icons/turf/corridor.dmi'
	desc = "It seems to be giving off its own small source of light" //Emergency lighting
	icon_state = "wall"
	smooth = TRUE
	canSmoothWith = list(/turf/closed/wall/trek,/turf/closed/wall/trek/darksteel,/obj/structure/window/fulltile/trek,/obj/structure/window/fulltile/trek/viewport,/obj/machinery/door/airlock/trek,/obj/machinery/door/airlock/trek/tng)

/turf/closed/wall/trek/darksteel
	name = "Starship corridor"
	icon = 'DS13/icons/turf/darksteel_wall.dmi'
	desc = "A large chunk of metal used to seperate rooms, decks and even build structures in space." //Emergency lighting
	icon_state = "wall"
	smooth = TRUE


/turf/closed/wall/trek/Initialize()
	. = ..()
	set_light(6)

/obj/structure/window/fulltile/trek
	name = "Viewport"
	icon = 'DS13/icons/obj/window.dmi'
	desc = "It's a pane of glass through which you look. It has a small certification stamp on it that reads 'Utopia Planetia shipyards'"
	icon_state = "darksteel_window"
	smooth = FALSE

/obj/structure/window/fulltile/trek/corridor
	name = "Viewport"
	icon = 'DS13/icons/obj/window.dmi'
	desc = "It's a pane of glass through which you look. It has a small certification stamp on it that reads 'Utopia Planetia shipyards'"
	icon_state = "trek_window"

/obj/structure/window/fulltile/trek/viewport
	name = "Viewport"
	icon = 'DS13/icons/obj/window.dmi'
	desc = "It's a pane of glass through which you look. It has a small certification stamp on it that reads 'Utopia Planetia shipyards'"
	icon_state = "viewport"

/obj/machinery/door/airlock/trek
	name = "Airlock"
	icon = 'DS13/icons/obj/machinery/voy_door.dmi'
	desc = "A sleek airlock for walking through"
	icon_state = "closed"

/obj/machinery/door/airlock/trek/tng
	name = "Airlock"
	icon = 'DS13/icons/obj/machinery/hall_door.dmi'
	desc = "A sleek airlock for walking through"
	icon_state = "closed"
