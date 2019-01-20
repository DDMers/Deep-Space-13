/turf/open/floor/carpet/trek
	name = "90s space carpet"
	desc = "Who said that structural components couldn't be stylish?."
	icon = 'DS13/icons/turf/beige_trek_carpet.dmi'
	icon_state = "beige"
	smooth = TRUE
	canSmoothWith = list(/turf/open/floor/carpet/trek)

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
	canSmoothWith = list(/turf/closed/wall/trek,/turf/closed/wall/trek/darksteel,/turf/closed/wall/trek/room,/obj/structure/window/reinforced/fulltile/trek,/obj/structure/window/reinforced/fulltile/trek/viewport,/obj/structure/window/reinforced/fulltile/trek/corridor,/obj/machinery/door/airlock/trek,/obj/machinery/door/airlock/trek/tng)

/turf/closed/wall/trek/darksteel
	name = "Starship corridor"
	icon = 'DS13/icons/turf/darksteel_wall.dmi'
	desc = "A large chunk of metal used to seperate rooms, decks and even build structures in space." //Emergency lighting
	icon_state = "wall"
	smooth = TRUE


/turf/closed/wall/trek/room
	name = "Starship corridor"
	icon = 'DS13/icons/turf/room-wall.dmi'
	desc = "A large chunk of metal used to seperate rooms, decks and even build structures in space." //Emergency lighting
	icon_state = "wall"
	smooth = TRUE

/turf/closed/wall/trek/Initialize()
	. = ..()
	set_light(6)

/obj/structure/window/reinforced/fulltile/trek
	name = "Viewport"
	icon = 'DS13/icons/obj/window.dmi'
	desc = "It's a pane of glass through which you look. It has a small certification stamp on it that reads 'Utopia Planetia shipyards'"
	icon_state = "darksteel_window"
	smooth = FALSE
	dir = 2

/obj/structure/window/reinforced/fulltile/trek/middle
	name = "Viewport"
	icon = 'DS13/icons/obj/window.dmi'
	desc = "It's a pane of glass through which you look. It has a small certification stamp on it that reads 'Utopia Planetia shipyards'"
	icon_state = "darksteel_window_middle"
	smooth = FALSE
	dir = 2

/obj/structure/window/reinforced/fulltile/trek/corridor
	name = "Viewport"
	icon = 'DS13/icons/obj/window.dmi'
	desc = "It's a pane of glass through which you look. It has a small certification stamp on it that reads 'Utopia Planetia shipyards'"
	icon_state = "trek_window"

/obj/structure/window/reinforced/fulltile/trek/viewport
	name = "Viewport"
	icon = 'DS13/icons/obj/window.dmi'
	desc = "It's a pane of glass through which you look. It has a small certification stamp on it that reads 'Utopia Planetia shipyards'"
	icon_state = "viewport"

/obj/structure/window/reinforced/fulltile/trek/porthole
	name = "Viewport"
	icon = 'DS13/icons/obj/window.dmi'
	desc = "It's a pane of glass through which you look. It has a small certification stamp on it that reads 'Utopia Planetia shipyards'"
	icon_state = "porthole"
	smooth = FALSE

/obj/machinery/door/airlock/trek
	name = "Airlock"
	icon = 'DS13/icons/obj/machinery/voy_door.dmi'
	desc = "A sleek airlock for walking through"
	icon_state = "closed"
	doorOpen = 'DS13/sound/effects/ds9_door.ogg'
	doorClose = 'DS13/sound/effects/ds9_door.ogg'
	doorDeni = 'DS13/sound/effects/denybeep.ogg' // i'm thinkin' Deni's

/obj/machinery/door/airlock/trek/tng
	name = "Airlock"
	icon = 'DS13/icons/obj/machinery/hall_door.dmi'
	desc = "A sleek airlock for walking through"
	icon_state = "closed"

/obj/structure/trek_decor
	name = "Fluff item"
	desc = "Add me!"
	icon = 'DS13/icons/obj/decor/wall_decor.dmi'
	icon_state = null
	anchored = TRUE
	density = FALSE

/obj/structure/trek_decor/rack
	name = "Rack"
	desc = "Imagine what you could store here!."
	icon_state = "rack"

/obj/structure/trek_decor/viewscreen
	name = "Viewscreen"
	desc = "Bits of information are flashing all over it, seems pretty useless..."
	icon_state = "viewscreen"

/obj/structure/trek_decor/trophies
	name = "Trophy rack"
	desc = "You've broken your little spaceships captain Ahab."
	icon_state = "trophies"

/obj/structure/table/trek
	name = "Epic sci fi space table"
	desc = "In the 24th century, people still need tables."
	icon = 'DS13/icons/obj/decor/tables.dmi'
	icon_state = "table1"
	anchored = TRUE
	density = FALSE
	smooth = FALSE
	layer = 3.1

/obj/structure/table/trek/continued
	name = "Epic sci fi space table"
	desc = "In the 24th century, people still need tables."
	icon = 'DS13/icons/obj/decor/tables.dmi'
	icon_state = "table1-contd"

/obj/structure/table/trek/medium
	name = "Epic sci fi space table"
	desc = "In the 24th century, people still need tables."
	icon = 'DS13/icons/obj/decor/tables.dmi'
	icon_state = "table2"

/obj/structure/table/optable/trek
	name = "biobed"
	desc = "A bed with surgical facilities built in."
	icon = 'DS13/icons/obj/decor/biobed.dmi'
	icon_state = "biobed"