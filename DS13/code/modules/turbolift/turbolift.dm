/area/turbolift
	name = "Primary turbolift"
	requires_power = FALSE //no APCS in the lifts please

/area/turbolift/secondary
	name = "Secondary turbolift"

/area/turbolift/tertiary
	name = "Tertiary turbolift"

/area/turbolift/quanery
	name = "Quanery turbolift"

/area/turbolift/quintessential
	name = "Quintessential turbolift"


/obj/structure/turbolift
	name = "Turbolift control console"
	icon = 'DS13/icons/obj/decor/wall_decor.dmi'
	icon_state = "lift-off"
	density = FALSE
	anchored = TRUE
	can_be_unanchored = FALSE
	mouse_over_pointer = MOUSE_HAND_POINTER
	desc = "Starfleet's decision to replace the iconic turboladder was not met with unanimous praise, experts citing increased obesity figures from crewmen no longer needing to climb vertically through several miles of deck to reach their target. However this is undoubtedly much faster."
	var/floor_directory = "<font color=blue>Deck 1: Engineering <br>\
		Deck 2: Promenade<br>\
		Deck 3: Bridge<br></font>" //Change this if you intend to make a new map. Helps players know where they're going.
	var/list/turbolift_turfs = list()
	var/floor = 0 //This gets assigned on init(). Allows us to calculate where the lift needs to go next.
	var/list/destinations = list() //Any elevator that's on our path.
	pixel_y = 32 //This just makes it easier for locate...
	var/in_use = FALSE //Is someone using a lift? If they are, then don't let anyone in the lift.
	var/max_floor = 0 //Highest floor we can go to?
	var/bolted = FALSE //Is this door bolted or unbolted? do we need to change that if a person walks into our lift?
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/machinery/door/airlock/trek/goon/turbolift
	name = "Turbolift airlock"
	icon = 'DS13/goonstation/glass_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extremely strong."
	icon_state = "closed"
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
	if(in_use) //Don't constant spam bolt if we're in use
		return
	for(var/turf/T in turbolift_turfs)
		if(locate(/mob/living) in T) //If there's a mob in these then bolt the other lifts so no one else can get on.
			bolt_other_doors()
			return
	unbolt_other_doors() //No one's in the lift, and the lift is not moving, so allow entrance

/obj/structure/turbolift/Destroy()
	STOP_PROCESSING(SSobj,src)
	. = ..()

/obj/structure/turbolift/attack_hand(mob/user)
	. = ..()
	if(in_use)
		to_chat(user, "The turbolift is already moving!")
		return FALSE
	send_sound_lift('DS13/sound/effects/turbolift/turbolift-close.ogg')
	bolt_door()
	bolt_other_doors() //Close the other elevator doors
	in_use = TRUE
	to_chat(user, floor_directory)
	icon_state = "lift-off"
	var/S = input(user,"Select a deck (max: [max_floor])") as num
	if(S > max_floor || S <= 0 || S == floor)
		in_use = FALSE
		unbolt_door()
		unbolt_other_doors()
		return
	if(S)
		for(var/obj/structure/turbolift/TS in destinations)
			if(TS.floor == S)
				user.say("Deck [S], fore.")
				send_sound_lift('DS13/sound/effects/turbolift/turbolift.ogg', TRUE)
				addtimer(CALLBACK(src, .proc/lift, TS), 90)
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


/obj/structure/turbolift/proc/lift(var/obj/structure/turbolift/target)
	in_use = FALSE
	icon_state = "lift-off"
	unbolt_door()
	unbolt_other_doors()
	if(!target)
		return
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
			AM.z = target.z //Avoids the teleportation effect of zooming to random tiles

/obj/structure/turbolift/proc/bolt_other_doors()
	for(var/obj/structure/turbolift/SS in destinations)
		if(SS.bolted)
			continue
		SS.bolt_door()
		SS.in_use = TRUE

/obj/structure/turbolift/proc/unbolt_other_doors()
	for(var/obj/structure/turbolift/SS in destinations)
		if(!SS.bolted)
			continue
		SS.unbolt_door()
		SS.in_use = FALSE

/obj/structure/turbolift/proc/bolt_door()
	var/obj/machinery/door/airlock/S = locate(/obj/machinery/door/airlock) in get_step(src, SOUTH)
	if(!S || !istype(S, /obj/machinery/door))
		for(var/obj/machinery/door/airlock/AS in get_area(src))  //If you have a big turbolift with multiple airlocks
			if(AS.z == z)
				S = AS
	if(S)
		S.close()
		S.bolt()
		bolted = TRUE//Tones down the processing use

/obj/structure/turbolift/proc/unbolt_door()
	var/obj/machinery/door/airlock/S = locate(/obj/machinery/door/airlock) in get_step(src, SOUTH)
	if(!S || !istype(S, /obj/machinery/door))
		for(var/obj/machinery/door/airlock/AS in get_area(src)) //If you have a big turbolift with multiple airlocks
			if(AS.z == z)
				S = AS
	if(S)
		S.close()
		S.unbolt()
		bolted = FALSE

/obj/structure/turbolift/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	get_position()
	get_turfs()

/obj/structure/turbolift/proc/get_turfs()
	var/list/temp = get_area_turfs(get_area(src))
	for(var/turf/T in temp)
		if(T.z == z)
			turbolift_turfs += T

/obj/structure/turbolift/proc/get_position() //Let's see where I am in this world...
	var/obj/structure/turbolift/below = locate(/obj/structure/turbolift) in SSmapping.get_turf_below(get_turf(src))
	if(below) //We need to be the bottom lift for this to work.
		return
	floor = 1
	name = "[initial(name)] (Deck [floor])"
	var/obj/structure/turbolift/previous
	var/obj/structure/turbolift/next
	for(var/II = 0 to world.maxz) //AKA 1 to 6 for example
		if(!previous)
			var/turf/T = SSmapping.get_turf_above(get_turf(src))
			var/obj/structure/turbolift/target = locate(/obj/structure/turbolift) in T
			next = target

		else
			var/turf/T = SSmapping.get_turf_above(get_turf(previous))
			var/obj/structure/turbolift/target = locate(/obj/structure/turbolift) in T
			next = target
		if(next)
			previous = next
			II ++
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