/turf/open/floor/carpet/trek
	name = "90s space carpet"
	desc = "The merits of having a static charge generating material on every surface of the ship are questionable, but you can't deny how cool it looks."
	icon = 'DS13/icons/turf/beige_trek_carpet.dmi'
	icon_state = "beige"
	smooth = TRUE
	canSmoothWith = list(/turf/open/floor/carpet/trek)
	floor_tile = /obj/item/stack/tile/carpet/trek

/obj/item/stack/tile/carpet/trek
	name = "carpet"
	singular_name = "carpet"
	icon_state = "tile-carpet"
	turf_type = /turf/open/floor/carpet/trek
	resistance_flags = FLAMMABLE
	icon = 'DS13/icons/obj/stack_objects.dmi'
	icon_state = "carpet"

/obj/item/stack/tile/carpet/trek/fifty
	amount = 50

/turf/open/floor/carpet/trek/romulan
	name = "dark carpet"
	desc = "Jolan Tru!"
	icon = 'DS13/icons/turf/romulan_carpet.dmi'
	icon_state = "romulan"
	smooth = TRUE
	canSmoothWith = list(/turf/open/floor/carpet/trek,/turf/open/floor/carpet/trek/romulan)
	floor_tile = /obj/item/stack/tile/carpet/trek/romulan

/obj/item/stack/tile/carpet/trek/romulan
	name = "carpet"
	singular_name = "carpet"
	icon_state = "tile-carpet"
	turf_type = /turf/open/floor/carpet/trek/romulan
	resistance_flags = FLAMMABLE
	icon = 'DS13/icons/obj/stack_objects.dmi'
	icon_state = "carpet-rom"

/obj/item/stack/tile/carpet/trek/voy
	name = "carpet"
	singular_name = "carpet"
	turf_type = /turf/open/floor/carpet/trek/voy
	resistance_flags = FLAMMABLE
	icon = 'DS13/icons/obj/stack_objects.dmi'
	icon_state = "carpet-voy"

/obj/item/stack/tile/carpet/trek/fifty
	amount = 50

/obj/item/stack/tile/carpet/trek/romulan/fifty
	amount = 50

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

/turf/open/floor/trek/bsg
	name = "Pressed steel hull plating"
	desc = "A very militaristic looking hull segment"
	icon = 'DS13/icons/turf/floors.dmi'
	icon_state = "bsg1"
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_PLATING
	clawfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/trek/bsg/tile
	name = "Padded steel tile"
	icon = 'DS13/icons/turf/floors.dmi'
	icon_state = "bsg2"

/turf/open/floor/trek/bsg/corrugated
	name = "Corrugated steel hull segment"
	icon = 'DS13/icons/turf/floors.dmi'
	icon_state = "corrugated"

/turf/open/floor/carpet/trek/voy
	name = "dark carpet"
	desc = "a more muted palette for a more professional starship"
	icon = 'DS13/icons/turf/intrepid_carpet.dmi'
	icon_state = "intrepid"
	smooth = TRUE
	canSmoothWith = list(/turf/open/floor/carpet/trek,/turf/open/floor/carpet/trek/voy)
	floor_tile = /obj/item/stack/tile/carpet/trek/voy

/obj/structure/chair/trek
	name = "padded leather chair"
	desc = "Just looking at this thing makes you feel comfy."
	icon = 'DS13/icons/obj/chairs.dmi'
	icon_state = "comfy"
	item_chair = null
	anchored = FALSE

/obj/structure/chair/trek/standard
	name = "chair"
	desc = "This chair looks comfortable, but not the best starfleet has to offer.."
	icon = 'DS13/icons/obj/chairs.dmi'
	icon_state = "chair"

/obj/structure/chair/trek/dark
	name = "tactical chair"
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

/obj/structure/window/reinforced/fulltile/trek/bsg
	name = "Viewport"
	icon = 'DS13/icons/obj/window.dmi'
	desc = "A heavyset window surrounded by thick steel."
	icon_state = "bsg"
	smooth = FALSE
	dir = 2

/obj/structure/window/reinforced/fulltile/trek/bsg/middle
	icon_state = "bsg_mid"
	smooth = FALSE
	dir = 2

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

/obj/structure/trek_decor/romulan
	name = "Romulan wall covering"
	desc = "A panel which is glued over a wall, giving it a more neutral feel."
	icon_state = "rom-room"

/obj/structure/trek_decor/viewscreen
	name = "Viewscreen"
	desc = "Bits of information are flashing all over it, seems pretty useless..."
	icon_state = "viewscreen"

/obj/structure/trek_decor/trophies
	name = "Trophy rack"
	desc = "You've broken your little spaceships captain Ahab."
	icon_state = "trophies"

/obj/structure/trek_decor/ai_wall
	name = "Optronic data core"
	desc = "A huge databank which is part of the ship's computer"
	icon_state = "aibits"

/obj/structure/trek_decor/ai_wall/grille
	icon_state = "aibits-grille"

/obj/structure/trek_decor/ai_wall/optronic
	name = "Optronic data relay"
	icon_state = "ai_panel"

/obj/structure/trek_decor/cargo
	name = "Shuttle bay wall covering"
	desc = "A panel which is glued over a wall, giving it extra protection"
	icon_state = "cargo"

/obj/structure/table/trek
	name = "Duranium alloy table"
	desc = "A smooth table with a nice wooden finish. It's cold to the touch."
	icon = 'DS13/icons/obj/decor/tables.dmi'
	icon_state = "table1"
	anchored = TRUE
	density = FALSE
	smooth = FALSE
	layer = 3.1

/obj/structure/table/trek/continued
	icon = 'DS13/icons/obj/decor/tables.dmi'
	icon_state = "table1-contd"

/obj/structure/table/trek/medium
	icon = 'DS13/icons/obj/decor/tables.dmi'
	icon_state = "table2"

/obj/structure/table/optable/trek
	name = "biobed"
	desc = "A bed with surgical facilities built in."
	icon = 'DS13/icons/obj/decor/biobed.dmi'
	icon_state = "biobed" //X - 15, y - 7

/obj/structure/table/trek/desk
	name = "Desk"
	desc = "A sleek, glass panelled desk"
	icon_state = "desk"
	anchored = TRUE
	density = FALSE
	smooth = FALSE
	layer = 3

/obj/structure/table/optable/trek/tablepush(mob/living/user, mob/living/pushed_mob)
	pushed_mob.forceMove(loc)
	pushed_mob.set_resting(TRUE, TRUE)
	visible_message("<span class='notice'>[user] has laid [pushed_mob] on [src].</span>")
	check_patient()

/obj/structure/table/optable/trek/check_patient()
	var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, loc)
	if(M)
		if(M.resting)
			patient = M
			patient.pixel_x = 15 //So they actually lie on the bed
			patient.pixel_y = 7
			return TRUE
	else
		patient.pixel_x = initial(patient.pixel_x)
		patient.pixel_y = initial(patient.pixel_y)
		patient = null
		return FALSE

/obj/effect/baseturf_helper/open_space //Put this on any deck that isn't the lowest deck so that explosions cause holes to open up and stuff to fall down from above!
	name = "open space baseturf editor"
	icon = 'DS13/icons/effects/mapping_helpers.dmi'
	icon_state = "baseturf"
	baseturf = /turf/open/openspace
	baseturf_to_replace = list(/turf/open/space/basic)

/obj/effect/mob_spawn/human/alive/trek/Initialize()
	. = ..()
	for(var/mob/dead/observer/F in GLOB.dead_mob_list)
		var/turf/turfy = get_turf(src)
		var/link = TURF_LINK(F, turfy)
		if(F)
			to_chat(F, "<font color='#EE82EE'><i>Spawn available! (just click the sleeper): [link]</i></font>")

/obj/effect/mob_spawn/human/alive/trek/saladin_crew
	name = "Independant crewman"
	assignedrole = "saladin crew"
	outfit = /datum/outfit/job/engineer/DS13
	flavour_text = "<span class='big bold'>You are an independant crewman!</span><b> Your party bought the ship you're currently on off of a dodgy ferengi merchant. Your ship: the USS Sherman has taken heavy damage due to an asteroid belt. \n</b> <i>You own the USS Sherman along with your fellow crew, you are free to behave as you see fit. But you must <b>only</b> kill in self-defense.</i> \n If you require further guidance, please ahelp."

/obj/effect/mob_spawn/human/alive/trek/saladin_crew/captain
	name = "Independant captain"
	assignedrole = "saladin captain"
	outfit = /datum/outfit/job/captain/DS13

/obj/machinery/door/window/brigdoor/security/cell/trek
	name = "Brig force field"
	desc = "A high energy barrier designed to keep things contained."
	req_access = list(ACCESS_BRIG)
	id = "Cell 1"
	icon = 'DS13/icons/obj/decor/wall_decor.dmi'

/obj/machinery/door/window/brigdoor/security/cell/trek/cell2
	id = "Cell 2"

/obj/machinery/door/window/brigdoor/security/cell/trek/cell3
	id = "Cell 3"

/obj/machinery/door/window/brigdoor/security/cell/trek/cell4
	id = "Cell 4"

/obj/machinery/door/window/brigdoor/security/cell/trek/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'DS13/sound/effects/brigfield.ogg', 90, 1)
		if(BURN)
			playsound(src.loc, 'DS13/sound/effects/brigfield.ogg', 100, 1)

/obj/machinery/door/window/brigdoor/security/cell/trek/open(forced=0)
	if (src.operating == 1) //doors can still open when emag-disabled
		return 0
	if(!src.operating) //in case of emag
		operating = TRUE
	do_animate("opening")
	playsound(src.loc, 'DS13/sound/effects/brigfield.ogg', 100, 1)
	src.icon_state ="[src.base_state]open"
	sleep(10)

	density = FALSE
//	src.sd_set_opacity(0)	//TODO: why is this here? Opaque windoors? ~Carn
	air_update_turf(1)
	update_freelook_sight()

	if(operating == 1) //emag again
		operating = FALSE
	return 1

/obj/machinery/door/window/brigdoor/security/cell/trek/close(forced=0)
	if (src.operating)
		return 0
	operating = TRUE
	do_animate("closing")
	playsound(src.loc, 'DS13/sound/effects/brigfield.ogg', 100, 1)
	src.icon_state = src.base_state
	density = TRUE
	air_update_turf(1)
	update_freelook_sight()
	sleep(10)
	operating = FALSE
	return 1

/obj/structure/trek_decor/brig
	name = "Cell padding"
	desc = "Heavyset foam based padding designed to stop inmates from hurting themselves by accident."
	icon_state = "brigpadding"
	layer = 2.1

/obj/effect/mob_spawn/human/alive/trek/borg_guard
	name = "Starfleet security detail"
	assignedrole = "crashed security"
	outfit = /datum/outfit/job/officer/DS13
	flavour_text = "<span class='big bold'>You are a stranded starfleet security officer! Your ship was carrying experiments of questionable legality for starfleet intelligence but your ship has crashed. Make sure that the borg you were transporting remain contained at all costs.</span>"
	layer = 2.1

/obj/structure/curtain/black
	name = "black curtain"
	desc = "A sleek set of drapes which can block out irritating ambient light from space."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "open"
	color = "#696969"
	alpha = 255

/obj/structure/curtain/black/update_icon() //Non transparent curtains that actually block light.
	if(!open)
		icon_state = "closed"
		layer = WALL_OBJ_LAYER
		density = TRUE
		open = FALSE
		opacity = TRUE

	else
		icon_state = "open"
		layer = SIGN_LAYER
		density = FALSE
		open = TRUE
		opacity = FALSE

/obj/machinery/jukebox/trek
	name = "Shipwide music player"
	desc = "A shipwide interface modified by a bored cargo technician. It (ab)uses the ship's internal announcement subsystem to play music throughout the ship."
	icon = 'DS13/icons/obj/decor/wall_decor.dmi'
	pixel_y = 32
	density = FALSE
	mouse_over_pointer = MOUSE_HAND_POINTER

/obj/machinery/jukebox/trek/process()
	if(world.time < stop && active)
		var/sound/song_played = sound(selection.song_path)

		for(var/mob/M in get_area(src))
			if(!M.client || !(M.client.prefs.toggles & SOUND_INSTRUMENTS))
				continue
			if(!(M in rangers))
				rangers[M] = TRUE
				M.playsound_local(get_turf(M), null, 100, channel = CHANNEL_JUKEBOX, S = song_played)
		for(var/mob/L in rangers)
			if(get_area(L) != get_area(src))
				rangers -= L
				if(!L || !L.client)
					continue
				L.stop_sound_channel(CHANNEL_JUKEBOX)
	else if(active)
		active = FALSE
		STOP_PROCESSING(SSobj, src)
		dance_over()
		playsound(src,'DS13/sound/effects/computer/alert2.ogg',50,1)
		update_icon()
		stop = world.time + 100