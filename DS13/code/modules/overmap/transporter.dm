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
	var/mob/living/carbon/operator
//	var/confinement_beam = ANNULAR_CONFINEMENT_NARROW //Narrow = only pickup humans, wide = pick up everything that isnt bolted to the ground
	req_access = list(ACCESS_SEC_DOORS)

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

/obj/effect/transporter_block
	name = "transporter interference"
	desc = "Try boosting power to the annular confinement beam?"
	alpha = 0

/mob/camera/aiEye/remote/setLoc(T)
	if(eye_user)
		if(!isturf(eye_user.loc))
			return
		T = get_turf(T)
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

/obj/machinery/computer/camera_advanced/transporter_control/proc/transporters_retrieve()
//	if(!powered())
//		return
	var/area/A = get_area(eyeobj)
	if(A.linked_overmap)
		if(!A.linked_overmap.shields.check_vulnerability())
			playsound(loc, 'DS13/sound/effects/transporter/malfunction.ogg', 100, 4)
			to_chat(operator, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>unable to establish transporter lock.</span>")
			return
	var/sound/S = pick('DS13/sound/effects/transporter/transporter_beep.ogg','DS13/sound/effects/transporter/transporter_beep2.ogg')
	playsound(loc, S, 100)
	for(var/mob/living/thehewmon in orange(eyeobj,1))
		var/obj/machinery/transporter_pad/T = pick(linked)
		T.retrieve(thehewmon)
	playsound(loc, 'DS13/sound/effects/transporter/retrieve.ogg', 100, 4)

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
		user.remote_control = eyeobj
		user.reset_perspective(eyeobj)
		eyeobj.loc = pick(L)
		user.sight = 60 //see through walls
		//user.lighting_alpha = 0 //night vision (doesn't work for some reason)
	else
		to_chat(user, "This is already in use!")

/obj/machinery/computer/camera_advanced/transporter_control/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/L = user
	if(L.wear_id)
		var/obj/item/card/id/ID = L.wear_id
		if(ID && istype(ID))
			if(!check_access(ID))
				to_chat(L, "You require a security level access card to use this console!.")
				return
		else
			to_chat(L, "You require a security level access card to use this console!.")
			return
	else
		to_chat(L, "You require a security level access card to use this console!.")
		return
	if(operator)
		remove_eye_control(operator)
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
	for(var/obj/structure/overmap/S in orange(thearea.linked_overmap, thearea.linked_overmap.transporter_range))
		if(S.shields.check_vulnerability() && S != src)
			ships += S
	if(!ships.len)
		to_chat(user, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>there are no suitable ships nearby. Target shields must be weakened to initiate transport</span>")
		return
	shipchoice = input(user, "Target", "Transporter Control", shipchoice) as null|anything in ships
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

/obj/machinery/transporter_pad/proc/send(turf/open/teleport_target)
//	if(!powered())
	//	return
	flick("alien-pad", src)
	var/mob/living/target = locate(/mob/living) in loc
	if(target)
		if(target != src)
			new /obj/effect/temp_visual/transporter(get_turf(target))
			target.forceMove(teleport_target)
			new /obj/effect/temp_visual/transporter/mob(get_turf(target))
			playsound(target.loc, 'DS13/sound/effects/transporter/retrieve.ogg', 100, 4)

/obj/machinery/transporter_pad/proc/retrieve(mob/living/target)
//	if(!powered())
//		return
	flick("alien-pad", src)
	if(!target.buckled)
		new /obj/effect/temp_visual/transporter(get_turf(target))
		playsound(target.loc, 'DS13/sound/effects/transporter/retrieve.ogg', 100, 4)
		target.forceMove(get_turf(src))
		new /obj/effect/temp_visual/transporter/mob(get_turf(target))

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