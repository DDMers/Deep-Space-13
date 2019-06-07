#define ANNULAR_CONFINEMENT_NARROW = 1
#define ANNULAR_CONFINEMENT_WIDE = 2

/obj/machinery/computer/camera_advanced/transporter_control
	name = "transporter control station"
	icon = 'DS13/icons/obj/transporter.dmi'
	icon_state = "control"
	icon_keyboard = null
	icon_screen = null
	anchored = TRUE
	can_be_unanchored = TRUE
	var/list/retrievable = list()
	var/list/linked = list()
	var/datum/action/innate/beamdown/down_action = new
	var/datum/action/innate/beamup/up_action = new
	var/datum/action/innate/changearea/changearea = new
	var/datum/action/innate/transporterlock/lock = new
	var/datum/action/innate/cleartransporterlock/clearlock = new
	var/mob/living/operator
	req_one_access = list(ACCESS_SEC_DOORS,ACCESS_ENGINE_EQUIP)
	var/list/log = list() //Logging to check if anyone's marooned.
	var/list/locked_on = list() //Who have we locked onto?
	var/locked = FALSE //Cooldown to prevent spam
	var/datum/component/movement_check

/obj/item/pattern_enhancer
	name = "Pattern enhancer (inactive)"
	desc = "A large rod which, when activated, will boost transporter confinement beams, allowing it to transport objects!"
	icon = 'DS13/icons/overmap/components.dmi'
	icon_state = "pattern_enhancer"
	var/active = FALSE

/obj/item/pattern_enhancer/attack_self(mob/user)
	if(active)
		to_chat(user, "You de-activate [src]")
		icon_state = initial(icon_state)
		name = initial(name)
		active = FALSE
	else
		to_chat(user, "You activate [src]")
		icon_state = "pattern_enhancer_active"
		name = "Pattern enhancer (active)"
		active = TRUE

/obj/machinery/computer/camera_advanced/transporter_control/examine(mob/user)
	. = ..()
	var/dat
	dat += "<br><h1>Transporter operation log:</h1> "
	for(var/x in log)
		dat += "<br>[x]"
	var/datum/browser/popup = new(user, "transporter log", name, 450, 520)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/camera_advanced/transporter_control/GrantActions(mob/living/user)
	//dont need jump cam action
	if(user != operator)
		to_chat(user, "This is already in use!")
		return
	if(off_action)
		off_action.target = user
		off_action.Grant(user)
		actions += off_action

	if(down_action)
		down_action.target = user
		down_action.Grant(user)
		down_action.console = src
		actions += down_action

	if(up_action)
		up_action.target = user
		up_action.Grant(user)
		up_action.console = src
		actions += up_action

	if(changearea)
		changearea.target = user
		changearea.Grant(user)
		changearea.console = src
		actions += changearea
	if(lock)
		lock.target = user
		lock.Grant(user)
		lock.console = src
		actions += lock
	if(clearlock)
		clearlock.target = user
		clearlock.Grant(user)
		clearlock.console = src
		actions += clearlock

/datum/action/innate/beamup
	name = "Beam Up"
	icon_icon = 'DS13/icons/actions/actions_transporter.dmi'
	button_icon_state = "beam_up"
	var/obj/machinery/computer/camera_advanced/transporter_control/console

/datum/action/innate/beamup/Activate()
	console.transporters_retrieve()

/datum/action/innate/beamdown
	name = "Beam Down"
	icon_icon = 'DS13/icons/actions/actions_transporter.dmi'
	button_icon_state = "beam_down"
	var/obj/machinery/computer/camera_advanced/transporter_control/console

/datum/action/innate/beamdown/Activate()
	console.activate_pads()

/datum/action/innate/changearea
	name = "Switch area"
	icon_icon = 'DS13/icons/actions/actions_transporter.dmi'
	button_icon_state = "switcharea"
	var/obj/machinery/computer/camera_advanced/transporter_control/console

/datum/action/innate/changearea/Activate()
	console.choose_area(console.operator)

/datum/action/innate/transporterlock
	name = "Lock on"
	icon_icon = 'DS13/icons/actions/actions_transporter.dmi'
	button_icon_state = "lock"
	var/obj/machinery/computer/camera_advanced/transporter_control/console

/datum/action/innate/transporterlock/Activate()
	console.transporters_lock()

/datum/action/innate/cleartransporterlock
	name = "Clear pattern buffer"
	icon_icon = 'DS13/icons/actions/actions_transporter.dmi'
	button_icon_state = "clearlock"
	var/obj/machinery/computer/camera_advanced/transporter_control/console

/datum/action/innate/cleartransporterlock/Activate()
	console.locked_on = list()
	to_chat(console.operator, "<span class='warning'>Pattern buffer cleared. All locked on signatures ignored.</span>")

/obj/effect/transporter_block
	name = "transporter interference"
	desc = "Try boosting power to the annular confinement beam?"
	alpha = 0

/mob/camera/aiEye/remote/setLoc(T)
	if(eye_user)
		if(!isturf(eye_user.loc))
			return
		T = get_turf(T)
		if(istype(T, /turf/closed/indestructible))
			return FALSE
		if(T)
			if(locate(/obj/effect/transporter_block) in T) //To define borders of ships
				return FALSE
			forceMove(T)
		else
			moveToNullspace()
		if(use_static)
			GLOB.cameranet.visibility(src, GetViewerClient())
		if(visible_icon)
			if(eye_user.client)
				eye_user.client.images -= user_image
				user_image = image(icon,loc,icon_state,FLY_LAYER)
				eye_user.client.images += user_image

/obj/machinery/computer/camera_advanced/transporter_control/Initialize()
	. = ..()
	link_by_range()

/obj/machinery/computer/camera_advanced/transporter_control/proc/link_by_range()
	for(var/obj/machinery/transporter_pad/A in orange(10,src))
		if(istype(A, /obj/machinery/transporter_pad))
			linked += A
			A.transporter_controller = src


/obj/effect/temp_visual/transporter_lock
	name = "Transporter locking on"
	icon = 'DS13/icons/effects/effects.dmi'
	icon_state = "transporter_lock"
	duration = 30
	randomdir = 0
	layer = ABOVE_MOB_LAYER
	var/obj/machinery/transporter_pad/chosen

/obj/effect/temp_visual/transporter_patternbuffer_lock
	name = "Transporter locking on"
	icon = 'DS13/icons/effects/effects.dmi'
	icon_state = "transporter_lock_buffer"
	duration = 40
	randomdir = 0
	layer = ABOVE_MOB_LAYER
	var/obj/machinery/computer/camera_advanced/transporter_control/chosen

/obj/effect/temp_visual/transporter_patternbuffer_lock/Destroy()
	if(chosen)
		for(var/mob/M in get_turf(src))
			if(isliving(M))
				chosen.locked_on += M
				chosen.log += "[station_time_timestamp()] : [chosen.operator] locked onto <b>[M]</b>."
				to_chat(chosen.operator, "Stored [M] in pattern buffer. Use the beam down function to teleport them site-to-site.")
				to_chat(M, "<span class='warning'>A transporter has locked onto you...</span>")
		var/obj/item/pattern_enhancer/PE = locate(/obj/item/pattern_enhancer) in orange(src,3)
		if(PE && PE.active) //Enhancer. Is it active? If so, allow them to teleport objects.
			for(var/X in orange(src,1))
				if(isobj(X))
					var/obj/Y = X
					if(!Y.anchored && !istype(X, /obj/structure/overmap))
						chosen.locked_on += Y
						chosen.log += "[station_time_timestamp()] : [chosen.operator] locked onto <b>[Y]</b>."
						to_chat(chosen.operator, "Stored [Y] in pattern buffer. Use the beam down function to teleport it site-to-site.")
	. = ..()

/obj/effect/temp_visual/transporter_lock/Destroy()
	if(chosen)
		for(var/mob/M in get_turf(src))
			if(isliving(M))
				chosen.retrieve(M)
		var/obj/item/pattern_enhancer/PE = locate(/obj/item/pattern_enhancer) in orange(src,3)
		if(PE && PE.active) //Enhancer. Is it active? If so, allow them to teleport objects.
			for(var/X in orange(src,1))
				if(isobj(X))
					var/obj/Y = X
					if(!Y.anchored && !istype(X, /obj/structure/overmap))
						chosen.retrieve(Y)
	. = ..()

/obj/machinery/computer/camera_advanced/transporter_control/proc/activate_pads()
//	if(!powered())
	//	return
	var/sound/S = pick('DS13/sound/effects/transporter/transporter_beep.ogg','DS13/sound/effects/transporter/transporter_beep2.ogg')
	playsound(loc, S, 100)
	if(eyeobj.eye_user)
		for(var/obj/machinery/transporter_pad/T in linked)
			var/turf/open/Tu = get_turf(pick(orange(1, get_turf(eyeobj))))
			T.send(Tu)
		playsound(loc, 'DS13/sound/effects/transporter/send.ogg', 100, 4)
	if(locked_on.len)
		for(var/atom/H in locked_on)
			var/area/AR = get_area(H)
			if(!AR.linked_overmap)
				continue
			if(AR.linked_overmap.shields)
				if(AR.linked_overmap.shields.check_vulnerability() || AR.linked_overmap.main_overmap) //If they don't have shields, or you want to site to site transport.
					var/obj/machinery/transporter_pad/T = pick(linked)
					T.retrieve(H)
					var/turf/open/Tu = get_turf(pick(orange(1, get_turf(eyeobj))))
					T.send(Tu)
					locked_on -= H
				else
					locked_on -= H
			else
				var/obj/machinery/transporter_pad/T = pick(linked)
				T.retrieve(H)
				var/turf/open/Tu = get_turf(pick(orange(1, get_turf(eyeobj))))
				T.send(Tu)
				locked_on -= H

/obj/machinery/computer/camera_advanced/transporter_control/proc/remove_cooldown()
	locked = FALSE

/obj/machinery/computer/camera_advanced/transporter_control/proc/transporters_retrieve()
//	if(!powered())
//		return
	if(locked)
		to_chat(operator, "Unable to comply, transporter pads are recharging.")
		return
	addtimer(CALLBACK(src, .proc/remove_cooldown), 50) //Spam protection, so you can't just SWARM the enemy ship with lockon visuals to force them to get beamed]
	locked = TRUE
	var/area/A = get_area(eyeobj)
	if(A.linked_overmap)
		if(A.linked_overmap.shields)
			if(!A.linked_overmap.shields.check_vulnerability())
				playsound(loc, 'DS13/sound/effects/transporter/malfunction.ogg', 100, 4)
				to_chat(operator, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>unable to establish transporter lock.</span>")
				return
	var/sound/S = pick('DS13/sound/effects/transporter/transporter_beep.ogg','DS13/sound/effects/transporter/transporter_beep2.ogg')
	playsound(loc, S, 100)
	var/obj/machinery/transporter_pad/T = pick(linked)
	var/obj/effect/temp_visual/transporter_lock/lockon = new(get_turf(eyeobj))
	lockon.chosen = T //This handles the actual "beaming"
	playsound(loc, 'DS13/sound/effects/transporter/retrieve.ogg', 100, 4)

/obj/machinery/computer/camera_advanced/transporter_control/proc/transporters_lock()
	if(locked)
		to_chat(operator, "Unable to comply, transporter pads are recharging.")
		return
	addtimer(CALLBACK(src, .proc/remove_cooldown), 50) //Spam protection, so you can't just SWARM the enemy ship with lockon visuals to force them to get beamed
	locked = TRUE
	var/obj/effect/temp_visual/transporter_patternbuffer_lock/stupidlizards = new(get_turf(eyeobj)) //In reference to the og transporter powergamers
	stupidlizards.chosen = src

/obj/machinery/computer/camera_advanced/transporter_control/CreateEye(var/turf/T)
	if(eyeobj)
		qdel(eyeobj)
	eyeobj = new()
	eyeobj.use_static = FALSE
	eyeobj.origin = src
	eyeobj.visible_icon = 1
	eyeobj.icon = 'icons/obj/abductor.dmi'
	eyeobj.icon_state = "camera_target"
	if(T)
		eyeobj.forceMove(T)

/obj/machinery/computer/camera_advanced/transporter_control/give_eye_control(mob/living/carbon/user, list/L)
	if(user == operator)
		GrantActions(user)
		current_user = user
		eyeobj.eye_user = user
		eyeobj.name = "Camera Eye ([user.name])"
		eyeobj.icon = icon
		eyeobj.icon_state = "camera"
		eyeobj.visible_icon = TRUE
		user.remote_control = eyeobj
		user.reset_perspective(eyeobj)
		eyeobj.loc = pick(L)
		//user.lighting_alpha = 0 //night vision (doesn't work for some reason)
	else
		to_chat(user, "This is already in use!")

/obj/machinery/computer/camera_advanced/transporter_control/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/camera_advanced/transporter_control/remove_eye_control(mob/living/user)
	..()
	user.unset_machine()
	operator = null
	qdel(eyeobj)
	eyeobj = null

/obj/machinery/computer/camera_advanced/transporter_control/proc/operator_check()
	if(!operator)
		return FALSE
	if(Adjacent(operator) || isAI(operator)) //Operator is in range, or is an AI and allowed to transport by default
		return TRUE
	remove_eye_control(operator)
	movement_check.RemoveComponent()

/obj/machinery/computer/camera_advanced/transporter_control/attack_hand(mob/user)
	if(!isliving(user))
		return
	if(!allowed(user))
		to_chat(user, "You require a security level access card to use this console!.")
		return FALSE
	if(operator)
		var/question = alert("[operator] is already using this console, kick them off it?.",name,"yes","no")
		if(question == "no" || !question)
			return
		to_chat(operator, "<span class='warning>[user] grabs your hands and forces you off of [src]!</span>")
		remove_eye_control(operator)
		return
	if(movement_check)//Add a component to see if theyve moved out of range. This way is cleaner than a process()
		user.TakeComponent(movement_check)
	else
		movement_check = user.AddComponent(/datum/component/redirect, list(COMSIG_MOVABLE_MOVED = CALLBACK(src, .proc/operator_check, user))) //This component checks whether the operator is in range of the console.
	choose_area(user)

/obj/machinery/computer/camera_advanced/transporter_control/proc/choose_area(mob/user)
	if(!user)
		user = operator
	link_by_range()
//	if(!powered())
	//	to_chat(user, "Insufficient power!")
	//	return
	var/area/thearea = get_area(src)
	var/input
	var/shipchoice
	if(!thearea.linked_overmap)
		return
	var/list/ships = list()
	var/area/shiparea = get_area(thearea.linked_overmap)
	if(!istype(shiparea, /area/space) && shiparea.linked_overmap) //If we're a runabout and are landed, let people beam to the current place we're landed on regardless of shield status
		ships += shiparea.linked_overmap
	for(var/obj/structure/overmap/S in GLOB.overmap_ships)
		if(get_dist(S, thearea.linked_overmap) > thearea.linked_overmap.transporter_range) //Is it in range for transport?
			continue
		if(!S.shields)
			ships += S
		if(S.shields.check_vulnerability() || thearea.linked_overmap.main_overmap) //If they don't have shields, or you want to site to site transport.
			ships += S
	if(!ships.len)
		to_chat(user, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>there are no suitable ships nearby. Target shields must be weakened to initiate transport</span>")
		return
	shipchoice = input(user, "Target", "Transporter Control", shipchoice) as null|anything in ships
	if(!shipchoice)
		return
	var/obj/structure/overmap/selected = shipchoice
	if(selected.main_overmap)
		var/list/areas = list()
		areas = GLOB.teleportlocs.Copy()
		for(var/AR in areas) //Strip out shit that shouldn't be there
			var/area/ARR = areas[AR]
			if(istype(ARR, /area/ship))
				areas -= AR
		input = input(user, "Lock on", "Transporter Control", input) as null|anything in areas
		if(!input)
			return
		thearea = areas[input]
		operator = user
		var/turf/L
		L = pick(get_area_turfs(thearea.type))
		if(!eyeobj)
			CreateEye(L)
		give_eye_control(user, L)
		return
	if(!selected.linked_area)
		to_chat(operator, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>that ship does not have any registered internal components.</span>")
		return
	operator = user
	var/turf/L
	L = pick(get_area_turfs(selected.linked_area.type))
	if(!eyeobj)
		CreateEye(L)
	give_eye_control(user, L)

/obj/effect/temp_visual/transporter
	icon = 'DS13/icons/misc/star_trek.dmi'
	icon_state = "beamup"
	duration = 10

/obj/effect/temp_visual/transporter/mob
	icon = 'DS13/icons/misc/star_trek.dmi'
	icon_state = "beamout"
	duration = 20

/obj/machinery/transporter_pad
	name = "transporter pad"
	desc = "A pad which can transfer your molecules across vast distances."
	density = 0
	anchored = 1
	can_be_unanchored = 1
	icon = 'DS13/icons/obj/transporter.dmi'
	icon_state = "1" //use generate instances by icon_state
	anchored = TRUE
	var/obj/machinery/computer/camera_advanced/transporter_control/transporter_controller = null
	layer = 2.7

/obj/machinery/transporter_pad/proc/send(turf/open/teleport_target)
//	if(!powered())
	//	return
	flick("alien-pad", src)
	for(var/atom/movable/target in loc)
		if(istype(target, /obj/effect) || istype(target, /atom/movable/lighting_object))
			continue
		if(target && target != src && !target.anchored)
			new /obj/effect/temp_visual/transporter(get_turf(target))
			target.forceMove(teleport_target)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if(H.pulling)
					H.pulling.forceMove(teleport_target)
			new /obj/effect/temp_visual/transporter/mob(get_turf(target))
			playsound(target.loc, 'DS13/sound/effects/transporter/retrieve.ogg', 100, 4)
			if(transporter_controller)
				transporter_controller.log += "[station_time_timestamp()] : [transporter_controller.operator] beamed <b>[target]</b> to [get_area(teleport_target)]."

/obj/machinery/transporter_pad/proc/retrieve(atom/movable/target)
//	if(!powered())
//		return
	flick("alien-pad", src)
	if(isliving(target))
		var/mob/living/H = target
		if(H.buckled)
			return
	new /obj/effect/temp_visual/transporter(get_turf(target))
	playsound(target.loc, 'DS13/sound/effects/transporter/retrieve.ogg', 100, 4)
	target.forceMove(get_turf(src))
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.pulling)
			H.pulling.forceMove(get_turf(src))
	new /obj/effect/temp_visual/transporter/mob(get_turf(target))
	if(target && transporter_controller)
		transporter_controller.log += "[station_time_timestamp()] : [transporter_controller.operator] beamed <b>[target]</b> back onto the ship."

/obj/machinery/transporter_pad/proc/retrieve_obj(obj/target)
	if(!powered())
		return
	flick("alien-pad", src)
	if(!target.anchored)
		new /obj/effect/temp_visual/transporter(get_turf(target))
		playsound(target.loc, 'DS13/sound/effects/transporter/retrieve.ogg', 100, 4)
		target.loc = get_turf(src)
		new /obj/effect/temp_visual/transporter(get_turf(target))


#undef ANNULAR_CONFINEMENT_NARROW
#undef ANNULAR_CONFINEMENT_WIDE