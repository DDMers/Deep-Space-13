//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 												D O C U M E N T A T I O N  			K m c 2 0 0 0 -> 22/01/2019																				//
// Turbolifts and you! How to make elevators with little to no effort.																														//
// ENSURE that the turbolift object ITSELF lines up with the others. This is to prevent the panel jumping about wildly and looking stupid													//
// If you want to make a multi door turbolift, place the controls at least 1 tile away from the doors. That way it switches to the more CPU intensive area based door acquisition system 	//
// This is area based! Ensure each turbolift is in a unique area, or things will get fucky																									//
// Ensure that turbolift doors are at least one tile away from the next lift. See DeepSpace13.dmm for examples. 																			//
// Use the indestructible elevator turfs or it'll look terrible!				  																											//
// Modify pixel_x and y as needed, it starts off snapped to the tile below a wall.																											//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Areas//

/area/turbolift
	name = "Primary turbolift"
	requires_power = FALSE //no APCS in the lifts please
	noteleport = TRUE

/area/turbolift/secondary
	name = "Secondary turbolift"

/area/turbolift/tertiary
	name = "Tertiary turbolift"

/area/turbolift/quanery
	name = "Quanery turbolift"

/area/turbolift/quintessential
	name = "Quintessential turbolift"

//Structures and logic//

/obj/structure/turbolift
	name = "Turbolift control console"
	icon = 'DS13/icons/obj/decor/wall_decor.dmi'
	icon_state = "lift-off"
	density = FALSE
	anchored = TRUE
	can_be_unanchored = FALSE
	mouse_over_pointer = MOUSE_HAND_POINTER
	desc = "Starfleet's decision to replace the iconic turboladder was not met with unanimous praise, experts citing increased obesity figures from crewmen no longer needing to climb vertically through several miles of deck to reach their target. However this is undoubtedly much faster."
	var/list/turbolift_turfs = list()
	var/floor = 0 //This gets assigned on init(). Allows us to calculate where the lift needs to go next.
	var/list/destinations = list() //Any elevator that's on our path.
	pixel_y = 32 //This just makes it easier for locate...
	var/in_use = FALSE //Is someone using a lift? If they are, then don't let anyone in the lift.
	var/max_floor = 0 //Highest floor we can go to?
	var/bolted = FALSE //Is this door bolted or unbolted? do we need to change that if a person walks into our lift?
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/is_controller = FALSE //Are we controlling the other lifts?
	var/obj/structure/turbolift/master = null //Who is the one pulling the strings
	var/obj/machinery/door/airlock/linked_door = null //Linked elevator door
	flags_1 = HEAR_1
	var/list/deck_1 = list("bridge","ready room","computer core","command escape pod") //Change these lists so that people know where to go! This one's the sovereign as it's the default map (for now)
	var/list/deck_2 = list("brig","armoury","transporter","cargo") //MAKE SURE THAT EACH THING IS UNIQUE. Escape pod 1 and escape pod 2 may cause issues!
	var/list/deck_3 = list("mess hall", "bar", "kitchen", "holodeck", "crew quarters", "sickbay", "research", "weapons locker", "janitorial supplies", "arrivals", "escape shuttle dock", "airponics", "botany", "medbay") //I'm going to add in the SS13 equivalents here too, as this whole feature is to help newbies
	var/list/deck_4 = list("warp core", "engineering", "atmospherics", "telecomms", "warp nacelles")

/obj/structure/turbolift/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(speaker == src)
		return
	if(findtext(raw_message, "?"))
		return
	if(get_area(speaker) == get_area(src)) //You have to be in our area. This avoids having to expend energy typing "computer, deck 4" etc. This is also what they do in the show :)
		var/target_department = department_parse(raw_message)
		if(findtext(raw_message, "deck") || findtext(raw_message, "floor") || target_department)
			if(in_use)
				to_chat(speaker, "The turbolift is already moving!")
				return FALSE
			send_sound_lift('DS13/sound/effects/turbolift/turbolift-close.ogg')
			in_use = TRUE
			if(!bolt_door())
				to_chat(speaker, "<span class='notice'> The door cannot close when someone is standing in it.</span>")
				bolted = FALSE
				in_use = FALSE
				return
			var/target_floor = target_department //What floor we looking for? This first checks if they've said something like "cargo"
			if(!target_floor) //We couldnt match a department to what they say. See if they asked for a specific floor.
				for(var/I = 0, I <= max_floor, I++)
					if(findtext(raw_message, num2text(I)) && I != floor) //Can't go to our floor idiot.
						target_floor = I
			if(!target_floor || !isnum(target_floor) || target_floor == floor) //Still havent found a floor? That means theyre a bloody idiot who can't make their mind up, or something has gone hideously wrong.
				if(target_floor == floor) to_chat(speaker, "<span class='notice'>That department is on this deck, deck [floor]") //Quick bit of info so people dont get as lost.
				unbolt_door()
				return
			for(var/obj/structure/turbolift/TS in destinations)
				if(TS.floor == target_floor)
					send_sound_lift('DS13/sound/effects/turbolift/turbolift.ogg', TRUE)
					addtimer(CALLBACK(src, .proc/lift, TS, TRUE), 90)
					icon_state = "lift-on"
					return

/obj/structure/turbolift/proc/department_parse(var/raw_message)
	if(!deck_1.len)
		return
	for(var/entry in deck_1) //We have a list of every dept. sorted by floor. If they say they want a department on deck 1, then they want to go to deck 1.
		if(findtext(raw_message, entry))
			return 1
	if(!deck_2.len) //We do this to avoid a runtime as it looks through an empty directory of deck_2.
		return
	for(var/entry in deck_2)
		if(findtext(raw_message, entry))
			return 2
	if(!deck_3.len)
		return
	for(var/entry in deck_3)
		if(findtext(raw_message, entry))
			return 3
	if(!deck_4.len)
		return
	for(var/entry in deck_4)
		if(findtext(raw_message, entry))
			return 4

/obj/machinery/door/airlock/trek/goon/turbolift
	name = "Turbolift airlock"
	icon = 'DS13/icons/obj/machinery/doors/standard.dmi'
	desc = "A sleek airlock for walking through."
	icon_state = "closed"
	doorOpen = 'DS13/sound/effects/tng_airlock.ogg'
	doorClose = 'DS13/sound/effects/tng_airlock.ogg'
	doorDeni = 'DS13/sound/effects/denybeep.ogg'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/turf/closed/wall/trek_smooth/indestructible
	name = "Duotanium alloy hull"
	icon = 'DS13/icons/turf/smooth_trek_walls.dmi'
	desc = "A large chunk of metal used to seperate rooms, decks and even build structures in space."
	icon_state = "wall"
	smooth = TRUE
	legacy_smooth = TRUE
	canSmoothWith = list(/turf/closed/wall/trek,/turf/closed/wall/trek/darksteel,/turf/closed/wall/trek/room,/obj/structure/window/reinforced/fulltile/trek,/obj/structure/window/reinforced/fulltile/trek/viewport,/obj/structure/window/reinforced/fulltile/trek/corridor,/obj/machinery/door/airlock/trek,/obj/machinery/door/airlock/trek/tng)
	explosion_block = 50

/turf/closed/wall/trek_smooth/indestructible/TerraformTurf(path, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/closed/wall/trek_smooth/indestructible/acid_act(acidpwr, acid_volume, acid_id)
	return 0

/turf/closed/wall/trek_smooth/indestructible/attackby()
	return FALSE //No deconning them

/obj/structure/turbolift/process()
	if(!is_controller)
		return
	if(loc_check())
		bolt_other_doors()
		return
	if(!in_use)
		unbolt_door()
	for(var/obj/structure/turbolift/S in destinations)
		if(S.loc_check()) //Someone's standing in the lift
			S.bolt_other_doors() //So bolt the other lifts
			return
		if(!S.in_use)
			S.unbolt_door() //No one's in the lift, and the lift is not moving, so allow entrance
	if(!loc_check()) //If we've gotten this far, there's no one in the lift. We're not moving, so let's unbolt.
		unbolt_other_doors()
		in_use = FALSE
		unbolt_door()

/obj/structure/turbolift/proc/loc_check() //Is there someone in the lift? if so, we need to stop other lifts from being used.
	for(var/turf/T in turbolift_turfs)
		if(locate(/mob/living) in T) //If there's a mob in these then bolt the other lifts so no one else can get on.
			return TRUE
	return FALSE


/obj/structure/turbolift/Destroy()
	STOP_PROCESSING(SSobj,src)
	. = ..()

/obj/structure/turbolift/attack_robot(mob/user)
	return attack_hand(user)

/obj/structure/turbolift/attack_animal(mob/user)
	return attack_hand(user)

/obj/structure/turbolift/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'> Deck 1: [list2text(deck_1)]\
	<br>Deck 2: [list2text(deck_2)]\
	<br>Deck 3: [list2text(deck_3)]\
	<br>Deck 4: [list2text(deck_4)]\
	</span>")

/obj/structure/turbolift/attack_hand(mob/user)
	. = ..()
	if(in_use)
		to_chat(user, "The turbolift is already moving!")
		return FALSE
	send_sound_lift('DS13/sound/effects/turbolift/turbolift-close.ogg')
	if(!bolt_door())
		to_chat(user, "<span class='notice'> The door cannot close when someone is standing in it.</span>")
		bolted = FALSE
		in_use = FALSE
		return
	in_use = TRUE
	icon_state = "lift-off"
	var/S = input(user,"Select a deck (max: [max_floor])") as num
	if(S > max_floor || S <= 0 || S == floor)
		in_use = FALSE
		unbolt_door()
		return
	if(!S)
		return
	for(var/obj/structure/turbolift/TS in destinations)
		if(TS.floor == S)
			user.say("Deck [S], fore.")
			send_sound_lift('DS13/sound/effects/turbolift/turbolift.ogg', TRUE)
			addtimer(CALLBACK(src, .proc/lift, TS, TRUE), 90)
			icon_state = "lift-on"
			return

/obj/structure/turbolift/proc/send_sound_lift(var/sound,var/shake = FALSE)
	if(!sound)
		return
	for(var/turf/T in turbolift_turfs)
		for(var/mob/AM in T)
			SEND_SOUND(AM, sound)
			if(shake && AM.client)
				shake_camera(AM, 2, 2)


/obj/structure/turbolift/proc/lift(var/obj/structure/turbolift/target, var/affects_others = FALSE)
	if(destinations.len && affects_others)//only one lift needs to tell the others to teleport people.
		for(var/X in destinations)
			var/obj/structure/turbolift/TS = X
			TS.lift(target, FALSE)//Just in case someone got stuck in the lift.
	in_use = FALSE
	icon_state = "lift-off"
	if(!target)
		return
	target.in_use = FALSE
	target.unbolt_door()
	for(var/turf/T in turbolift_turfs)
		for(var/atom/movable/AM in T)
			if(AM.anchored) //Don't teleport things that shouldn't go through
				continue
			if(isobserver(AM)) //Don't teleport ghosts
				continue
			if(isliving(AM))
				var/mob/living/M = AM
				if(M.client)
					shake_camera(M, 2,2)
			AM.z = target.z //Avoids the teleportation effect of zooming to random tiles

//Door management//

/obj/structure/turbolift/proc/bolt_other_doors()
	for(var/obj/structure/turbolift/SS in destinations)
		SS.in_use = TRUE
		SS.bolt_door(TRUE)

/obj/structure/turbolift/proc/unbolt_other_doors()
	for(var/obj/structure/turbolift/SS in destinations)
		SS.in_use = FALSE
		SS.unbolt_door()

/obj/structure/turbolift/proc/bolt_door(var/forced = FALSE) //if we really need some people to get out the FUCKING WAY
	if(bolted)
		return FALSE
	bolted = TRUE//Tones down the processing use
	if(!in_use)
		in_use = TRUE //so no one can ride the lift when it's locked
	if(!linked_door)
		find_door()
	if(linked_door)
		if(forced) //Forced means get out the FUCKING WAY.
			for(var/atom/movable/M in get_turf(linked_door))
				if(M.density && M != linked_door) //something is blocking the door
					to_chat(M, "<span class='warning'>You step away from [linked_door] to avoid getting crushed.</span>")
					M.forceMove(get_step(M, NORTH)) //get them out of my way, REEE
		if(linked_door.close())
			linked_door.bolt()
			return TRUE
		else
			bolted = FALSE
			in_use = FALSE
			return FALSE

/obj/structure/turbolift/proc/unbolt_door()
	if(!bolted)
		return
	bolted = FALSE//Tones down the processing use
	if(in_use)
		in_use = FALSE
	if(!linked_door)
		find_door()
	if(linked_door)
		linked_door.unbolt()

/obj/structure/turbolift/proc/find_door()
	linked_door = locate(/obj/machinery/door/airlock) in get_step(src, SOUTH)
	if(!linked_door || !istype(linked_door, /obj/machinery/door))
		for(var/obj/machinery/door/airlock/AS in get_area(src))  //If you have a big turbolift with multiple airlocks
			if(AS.z == z)
				linked_door = AS

/obj/structure/turbolift/Initialize()
	. = ..()
	get_position()
	get_turfs()

//Find positions and related turfs//

/obj/structure/turbolift/proc/get_turfs()
	var/list/temp = get_area_turfs(get_area(src))
	for(var/turf/T in temp)
		if(T.z == z)
			turbolift_turfs += T

/obj/structure/turbolift/proc/get_position() //Let's see where I am in this world...
	var/obj/structure/turbolift/above = locate(/obj/structure/turbolift) in SSmapping.get_turf_above(get_turf(src))
	if(above) //We need to be the top lift for this to work.
		return
	START_PROCESSING(SSobj, src)
	floor = 1
	name = "[initial(name)] (Deck [floor])"
	is_controller = TRUE
	var/obj/structure/turbolift/previous
	var/obj/structure/turbolift/next
	for(var/II = 0 to world.maxz) //AKA 1 to 6 for example
		if(!previous)
			var/turf/T = SSmapping.get_turf_below(get_turf(src))
			var/obj/structure/turbolift/target = locate(/obj/structure/turbolift) in T
			next = target

		else
			var/turf/T = SSmapping.get_turf_below(get_turf(previous))
			var/obj/structure/turbolift/target = locate(/obj/structure/turbolift) in T
			next = target
		if(next)
			previous = next
			II ++
			next.master = src
			next.floor = II+1
			next.name = "[initial(next.name)] (Deck [next.floor])"
			destinations += next
		else
			max_floor = II+1
			for(var/obj/structure/turbolift/SSS in destinations)
				SSS.max_floor = max_floor
				SSS.destinations = destinations.Copy()
				SSS.destinations += src
				SSS.destinations -= SSS
			break //No more lifts, no need to loop again.

/area/turbolift/Entered(atom/movable/M)
	. = ..()
	if(isliving(M))
		to_chat(M, "<span class='notice'>You have now entered a turbolift. Either say which department / floor you want to go to, or click the turbolift interface.</span>")

/area/turbolift/ship //These areas MUST be unique if youre using manuals lifts!
	name = "Ship turbolift"

/area/turbolift/ship/secondary
	name = "Ship secondary turbolift"

/area/turbolift/ship/romulan //These areas MUST be unique if youre using manuals lifts!
	name = "Romulan ascendior"

/area/turbolift/ship/romulan/secondary
	name = "Romulan secondary ascendior"

/area/turbolift/ship/saladin //These areas MUST be unique if youre using manuals lifts!
	name = "Saladin class elevator"

/area/turbolift/ship/saladin/secondary
	name = "Saladin class elevator (2)"

//////////////////////////////////
// These lifts work differently!//
// Put all lift objects in the same area//
// Set height manually//
// These ones ignore multiZ and are used for ships only!//

/obj/structure/turbolift/manual //These are manually set and used for ships, as the maps themselves aren't actually multiZ enabled
	var/height = 1

/obj/structure/turbolift/manual/height1
	height = 2

/obj/structure/turbolift/manual/height2
	height = 3

/obj/structure/turbolift/manual/height3
	height = 4

/obj/structure/turbolift/manual/romulan //These are manually set and used for ships, as the maps themselves aren't actually multiZ enabled
	height = 1

/obj/structure/turbolift/manual/romulan/height1
	height = 2

/obj/structure/turbolift/manual/romulan/height2
	height = 3

/obj/structure/turbolift/manual/get_position()
	if(height > 1) //We need to be the bottom lift for this to work.
		return
	START_PROCESSING(SSobj, src)
	floor = 1
	name = "[initial(name)] (Deck [floor])"
	is_controller = TRUE
	var/last_height = 1 //Store this one
	for(var/obj/structure/turbolift/manual/X in get_area(src))
		if(X && X != src && X.height == last_height + 1)
			X.master = src
			last_height ++
			X.floor = height+1
			X.name = "[initial(X.name)] (Deck [X.floor])"
			destinations += X
			if(max_floor < 2)
				max_floor = height+1
		if(X && X != src && X.height == last_height + 2)
			X.master = src
			X.floor = height+2
			X.name = "[initial(X.name)] (Deck [X.floor])"
			destinations += X
			max_floor = X.height

	for(var/obj/structure/turbolift/SSS in destinations)
		SSS.max_floor = max_floor
		SSS.destinations = destinations.Copy()
		SSS.destinations += src
		SSS.destinations -= SSS

/obj/structure/turbolift/manual/get_turfs()
	for(var/turf/T in orange(src, 3))
		if(!istype(T,/turf/open/space/basic))
			var/area/A = get_area(T)
			var/area/AA = get_area(src)
			if(A == AA)
				turbolift_turfs += T

/obj/structure/turbolift/manual/lift(var/obj/structure/turbolift/target)
	in_use = FALSE
	icon_state = "lift-off"
	if(!target)
		return
	target.in_use = FALSE
	target.unbolt_door()
	for(var/turf/T in turbolift_turfs)
		for(var/atom/movable/AM in T)
			if(AM.anchored) //Don't teleport things that shouldn't go through
				if(istype(AM, /obj/structure/turbolift) || istype(AM, /obj/machinery/light) || istype(AM, /obj/machinery/door/airlock)) //Allow things that aren't part of the lift up
					continue
			if(isobserver(AM)) //Don't teleport ghosts
				continue
			if(isliving(AM))
				var/mob/living/M = AM
				if(M.client)
					shake_camera(M, 2,2)
			AM.forceMove(safepick(target.turbolift_turfs)) //Avoids the teleportation effect of zooming to random tiles


/obj/machinery/door/airlock/close(forced=0)
	if(operating || welded || locked)
		return
	if(density)
		return TRUE
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_BOLTS))
			return FALSE
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && M != src) //something is blocking the door
				autoclose_in(60)
				return FALSE //So elevator code can refuse to start the lift.

	if(forced < 2)
		if(obj_flags & EMAGGED)
			return
		use_power(50)
		playsound(src, doorClose, 30, TRUE)
	else
		playsound(src, 'sound/machines/airlockforced.ogg', 30, TRUE)

	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(EXPLODE_HEAVY)//Smashin windows

	operating = TRUE
	update_icon(2, 1)
	layer = CLOSED_DOOR_LAYER
	if(air_tight)
		density = TRUE
		air_update_turf(1)
	sleep(1)
	if(!air_tight)
		density = TRUE
		air_update_turf(1)
	sleep(4)
	if(!safe)
		crush()
	if(visible && !glass)
		set_opacity(1)
	update_freelook_sight()
	sleep(1)
	update_icon(1, 1)
	operating = FALSE
	delayed_close_requested = FALSE
	if(safe)
		CheckForMobs()
	return TRUE
//end//