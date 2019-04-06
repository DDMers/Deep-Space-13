GLOBAL_LIST_INIT(escape_pod_objects, list()) //Shit that needs to be modified with escape pod events.
GLOBAL_VAR_INIT(pods_armed, FALSE) //Are the escape pods armed and ready to launch?

/obj/structure/overmap/escape_pod
	name = "Escape pod"
	desc = "A small pod capable of supporting up to 12 people ."
	icon = 'DS13/icons/overmap/escape_pod.dmi'
	icon_state = "pod"
	main_overmap = FALSE
	damage = 0 //These things aren't meant to be powerful
	max_shield_health = 50
	max_health = 50
	class = "escapepod1"
	damage_states = FALSE //Damage FX
	max_speed = 2
	turnspeed = 0.5
	power_slots = 1

/obj/structure/overmap_component/helm/escape_pod
	name = "Escape pod piloting console"
	desc = "This console will allow you to pilot an escape pod to fly your crew to safety."
	icon_state = "pilot"
	position = "pilot"
	req_access = null
	flags_1 = HEAR_1

/obj/structure/overmap_component/helm/escape_pod/attack_ai(mob/user)
	return attack_hand(user)

/obj/structure/overmap_component/helm/escape_pod/attack_hand(mob/user)
	if(!GLOB.pods_armed)
		to_chat(user, "<span class='notice'>Unable to comply. Escape pod not armed.</span>")
		return
	if(!linked || !istype(linked, /obj/structure/overmap/escape_pod))
		var/answer = alert("Launch escape pod and abandon ship?",name,"Yes","No")
		if(answer == "No" || !answer)
			return
		create_pod()
	. = ..()

/obj/structure/overmap_component/helm/escape_pod/proc/create_pod()
	for(var/X in GLOB.overmap_ships)
		var/obj/structure/overmap/OM = X
		if(OM.main_overmap)
			linked = new /obj/structure/overmap/escape_pod(get_turf(OM))
			linked.linked_area = get_area(src)
			linked.name = "Escape pod ([OM])"
			linked.class = get_area(src).class
			var/area/A = get_area(src)
			A.parallax_movedir = NORTH
			A.linked_overmap = linked //We're doing this again so we can rapidly assign vars with 0 wait.
			linked.vel = 3 //Blast off.
			for(var/obj/structure/overmap_component/XR in get_area(src)) //We call this to update the components with our new pod object, as it wasn't created at runtime!
				XR.find_overmap()
			break
	if(!linked)
		return
	for(var/mob/player in get_area(src))
		if(prob(50))
			shake_camera(player, 2,3)
		else
			shake_camera(player, 2,2)
		SEND_SOUND(player, 'DS13/sound/effects/pod_launch.ogg')
		if(ishuman(player))
			var/mob/living/carbon/human/H = player
			if(H.buckled)
				to_chat(H, "<span_class='notice'><b>Acceleration presses you into your seat!</b></span>")
				continue
			to_chat(H, "<span_class='notice'><b>You feel your insides lurch as acceleration slams you into the wall.</b></span>")
			var/atom/throw_target = get_edge_target_turf(H, SOUTH)
			H.throw_at(throw_target, 4, 3)
			H.Stun(20)
	for(var/XX in GLOB.escape_pod_objects)
		if(istype(XX, /obj/structure/escape_pod_ladder))
			var/obj/structure/escape_pod_ladder/EPL = XX
			if(EPL.class == linked.class)
				EPL.retract()



/obj/structure/escape_pod_ladder
	name = "Escape pod entry hatch"
	desc = "A ladder which allows you to enter an escape pod. It will automatically retract once the escape pod is launched."
	var/class = "escapepod1"
	var/obj/structure/escape_pod_ladder/linked
	anchored = TRUE
	density = FALSE
	icon_state = "ladder01"

/obj/structure/escape_pod_ladder/two
	name = "Escape pod entry hatch"
	desc = "A ladder which allows you to enter an escape pod. It will automatically retract once the escape pod is launched."
	class = "escapepod2"

/obj/structure/escape_pod_ladder/proc/retract()
	visible_message("<span class='warning'[src] quickly retracts as its boarding hatch closes!</span>")
	playsound(src, 'DS13/sound/effects/warpcore/loader_step1.ogg', 50, 1)
	if(linked)
		linked.visible_message("<span class='warning'[linked] quickly retracts as its boarding hatch closes!</span>")
		playsound(linked, 'DS13/sound/effects/warpcore/loader_step1.ogg', 50, 1)
		qdel(linked)
	qdel(src)

/obj/structure/escape_pod_ladder/attack_ghost(mob/user)
	return attack_hand(user)

/obj/structure/escape_pod_ladder/attack_hand(mob/user)
	if(!linked)
		link_up()
		return
	to_chat(user, "<span class='notice'>You climb [src].</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/F = user
		if(F.pulling)
			F.pulling.forceMove(get_turf(linked))
	if(user.client)
		SEND_SOUND(user, sound(null, repeat = 0, wait = 0, volume = 100, channel = CHANNEL_REDALERT)) //Shuts up the red alert sound when you enter a pod.
	user.forceMove(get_turf(linked))
	playsound(src, 'sound/effects/footstep/catwalk5.ogg', 100, 1)

/obj/structure/escape_pod_ladder/attack_ai(mob/user)
	if(!linked)
		link_up()
		return
	var/mob/living/silicon/ai/A = user
	if(A.eyeobj)
		to_chat(user, "<span class='notice'>You move your camera down [src].</span>")
		A.eyeobj.forceMove(get_turf(linked))

/obj/structure/escape_pod_ladder/exit
	name = "Escape pod exit hatch"
	desc = "A ladder which allows you to exit an escape pod. It will automatically retract once the escape pod is launched."
	icon_state = "ladder10"

/obj/structure/escape_pod_ladder/exit/two
	name = "Escape pod exit hatch"
	desc = "A ladder which allows you to exit an escape pod. It will automatically retract once the escape pod is launched."
	icon_state = "ladder10"
	class = "escapepod2"

/obj/structure/escape_pod_ladder/Initialize(mapload)
	. = ..()
	GLOB.escape_pod_objects += src
	addtimer(CALLBACK(src, .proc/link_up), 60)

/obj/structure/escape_pod_ladder/proc/link_up()
	for(var/X in GLOB.escape_pod_objects)
		if(istype(X, /obj/structure/escape_pod_ladder/exit))
			var/obj/structure/escape_pod_ladder/exit/partner = X
			if(!linked && !partner.linked && partner.class == class)
				linked = partner
				partner.linked = src

/obj/structure/escape_pod_ladder/exit/link_up()
	return

/obj/structure/overmap_component/helm/escape_pod/examine(mob/user)
	. = ..()
	if(!GLOB.pods_armed)
		to_chat(user, "<span class='warning'>It is currently locked, as the escape pods are not armed.</span>")

/area/ship/escape_pod
	name = "Escape pod 1"
	class = "escapepod1"
	has_gravity = STANDARD_GRAVITY
	explosion_exempt = TRUE
	looping_ambience = 'DS13/sound/ambience/escape_pod.ogg'

/area/ship/escape_pod/two
	name = "Escape pod 2"
	class = "escapepod2"
	has_gravity = STANDARD_GRAVITY
	explosion_exempt = TRUE

/area/ship/escape_pod/three
	name = "Escape pod 3"
	class = "escapepod3"
	has_gravity = STANDARD_GRAVITY
	explosion_exempt = TRUE

/obj/structure/overmap_component/helm
	name = "Piloting station"
	desc = "This console gives you the power to control a starship. Screwdriver it to change its command codes."
	icon_state = "pilot"
	position = "pilot"
	req_access = list(ACCESS_HEADS)
	flags_1 = HEAR_1

/obj/machinery/computer/communications
	var/max_timer = 600 //Avoids infinitely big escape pods timers.

/obj/machinery/computer/communications/proc/arm_pods(var/mob/living/carbon/user)
	if(GLOB.pods_armed)
		var/question = alert("The escape pods are already armed. Disarm them?",name,"Yes","No")
		if(question == "No" || !question)
			return
		GLOB.pods_armed = FALSE
		priority_announce("Escape pods have been disarmed. All hands should return to their stations.","Escape pods disarmed",'sound/ai/commandreport.ogg')
		return
	var/question = alert("Arm the escape pods for emergency evacuation?.",name,"Yes","No")
	if(question == "No" || !question)
		return
	var/timer = input("Enter countdown timer until pods arm for launch.", "Set a countdown timer in seconds.") as num
	if(!timer)
		return
	message_admins("[key_name(user)] has armed the escape pods for launch in [timer] seconds.")
	priority_announce("All hands, prepare to abandon ship. The escape pods will be armed for launch in [timer] seconds.","Escape pods armed",'sound/ai/commandreport.ogg')
	if(timer >= max_timer)
		to_chat(user, "<span class='warning'>The maximum timer you can set is: [max_timer].")
	if(timer > 0)
		timer *= 10
		addtimer(CALLBACK(src, .proc/set_pods_armed), timer)
	else
		GLOB.pods_armed = TRUE
	var/obj/structure/overmap_component/helm/HH = locate(/obj/structure/overmap_component/helm) in get_area(src)
	if(HH)
		HH.redalert_start()

/obj/machinery/computer/communications/proc/set_pods_armed()
	priority_announce("All hands, abandon ship! All staff should now proceed to the escape pods. Pod piloting controls are now UNLOCKED, designate a pilot and clear the ship's area as you await rescue.","Escape pods armed",'sound/ai/commandreport.ogg')
	GLOB.pods_armed = TRUE //Launch away!
	addtimer(CALLBACK(src, .proc/auto_call_shuttle), 60)

/obj/machinery/computer/communications/proc/auto_call_shuttle()
	SSshuttle.emergency.request(null, set_coefficient = 0.7)