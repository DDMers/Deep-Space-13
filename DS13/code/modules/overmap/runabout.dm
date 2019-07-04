/obj/structure/overmap
	var/list/docking_points = list() //Where can runabouts dock? You should place these in your hangar bar, with plenty of room!

/area/lavaland
	class = "lavaland"

/obj/structure/fans/tiny/shuttlebay
	name = "Shuttlebay energy field"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldwall"
	layer = 2.5
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/overmap/lavaland
	name = "Class Y 'Demon' planet"
	icon = 'DS13/icons/overmap/planets.dmi'
	icon_state = "lavaland"
	class = "lavaland"
	max_shield_health = 0
	power_slots = 0
	layer = 2.9
	max_health = 10000 //Yeah, if you really put your mind to it you can destroy lavaland.
	movement_block = TRUE

/obj/structure/overmap/runabout
	name = "Danube class runabout"
	desc = "A small, self contained starship which is often used for ferrying goods and personnel from station to station. It has minimal shields and weapons"
	icon = 'DS13/icons/overmap/runabout.dmi'
	icon_state = "runabout"
	max_health = 100 //Really weak. Don't take this into combat!
	damage = 0 //Will turn into 10 assuming weapons powered
	max_shield_health = 65 //Pathetic shields
	class = "runabout"
	turnspeed = 1
	acceleration = 0.4
	pixel_w = -120
	pixel_z = -128
	layer = LARGE_MOB_LAYER //3.9 -> Below mob. Change this if it becomes cancerous.
	damage_states = TRUE
	anchored = TRUE
	var/list/ladders = list() //Where can you board, where can you exit?
	var/locked = FALSE //Allows the keyholder to prevent people entering the runabout. Use this if you park it in a dodgy neighbourhood!
	var/obj/item/carkey/key = null //Linked key which can control us.
	var/lights_enabled = FALSE //Lets you activate your headlights if you want to go exploring / mining with it.

/obj/structure/overmap/runabout/Bumped(atom/movable/AM)
	if(ismob(AM))
		return FALSE
	else
		. = ..()

/obj/structure/overmap/runabout/OvermapInitialize()
	. = ..()
	name = pick("USS Yangtzee Kiang", "USS Ganges", "USS Mekong", "USS Orinoco", "USS Rio Grande", "USS Danube", "USS Rubicon", "USS Shenandoah", "USS Volga", "USS Yukon")
	if(linked_area)
		linked_area.name = name

/obj/structure/overmap/runabout/try_warp() //Overwriting it so I dont have to phyiscally give it a warp core.
	if(engine_power <= 0)
		if(pilot)
			to_chat(pilot, "<span class='notice'>Unable to comply, engine subsystem is disabled.</span>")
		return
	var/area/A = get_area(src)
	if(!istype(A, /area/space))
		to_chat(pilot, "<span class='notice'>SAFETY PROTOCOL VIOLATION. You cannot warp while docked to something.</span>")
		return
	if(warping)
		if(pilot)
			to_chat(pilot, "<span class='notice'>Disengaging warp engines.</span>")
		vel = 0.5
		stop_warping()
		return
	if(!warp_ready)
		if(pilot)
			to_chat(pilot, "<span class='notice'>Warp engines are recharging.</span>")
		return
	addtimer(CALLBACK(src, .proc/reset_warp_cooldown), 300)//One warp per 30 seconds.
	warp_ready = FALSE
	if(pilot)
		to_chat(pilot, "<span class='notice'>Charging warp engines. Please stand by.</span>")
	addtimer(CALLBACK(src, .proc/finish_warp), 45)
	if(!linked_area)
		return
	linked_area.parallax_movedir = NORTH
	for(var/X in linked_area)
		if(ismob(X))
			var/mob/player = X
			SEND_SOUND(player, 'DS13/sound/effects/warpcore/warp.ogg')

/obj/item/carkey
	name = "runabout key fob (unlinked)"
	desc = "A small transceiver array which can interface with a linked runabout."
	icon = 'DS13/icons/overmap/components.dmi'
	icon_state = "carkey"
	w_class = 1
	var/obj/structure/overmap/runabout/linked //The ship to which we link, allowing us to unlock its doors and rename it.

/obj/item/carkey/attack_self(mob/user)
	. = ..()
	if(!linked)
		var/obj/structure/overmap/runabout/R = locate(/obj/structure/overmap/runabout) in get_area(user)
		if(!R)
			to_chat(user, "<span class='warning'>[src] couldn't find a runabout in the room you're in.</span>")
			return
		var/question = alert("Program [src] to work with [R] in [get_area(user)]?",name,"yes","no")
		if(question == "no" || !question)
			return
		message_admins("[key_name(user)] added a runabout key to [R] in [get_area(user)]")
		linked = R
		linked.key = src
		name = "runabout key fob ([linked])"
		playsound(linked, 'DS13/sound/effects/runaboutlock.ogg', 100, 1)
	else
		linked.visible_message("<span class='danger'>[linked]'s bolts shift</span>")
		playsound(linked, 'sound/machines/terminal_insert_disc.ogg', 100, 1)
		sleep(5)
		playsound(linked, 'DS13/sound/effects/runaboutlock.ogg', 50, 1)
		if(linked.locked)
			to_chat(user, "<span class='warning'>[linked] is now unlocked</span>")
			linked.locked = FALSE
		else
			to_chat(user, "<span class='notice'>[linked] is now locked, preventing anyone from entering it.</span>")
			linked.locked = TRUE


/obj/item/carkey/examine(mob/user)
	. = ..()
	to_chat(user, "<b>To use it, click it while it's in your hand</b>")
	to_chat(user, "<b>If you want to repaint [src] or to rename its linked runabout, <i>ALT</i> click it.</b>")

/obj/item/carkey/AltClick(mob/user)
	. = ..()
	var/list/options = list("rename", "reskin", "headlights")
	for(var/option in options)
		options[option] = image(icon = 'DS13/icons/actions/weaponselect.dmi', icon_state = "[option]")
	var/dowhat = show_radial_menu(user,src,options)
	if(!dowhat)
		return
	switch(dowhat)
		if("rename")
			rename(user)
		if("reskin")
			reskin(user)
		if("headlights")
			toggle_headlights(user)

/obj/item/carkey/proc/toggle_headlights(mob/user)
	if(!linked)
		to_chat(user, "<span class='notice'>[src] hasn't been linked yet!</span>")
		return FALSE
	if(linked.lights_enabled)
		to_chat(user, "<span class='notice'>You dip [src]'s headlights.</span>")
		linked.set_light(0)
		linked.lights_enabled = FALSE
	else
		to_chat(user, "<span class='notice'>You set [src]'s headlights onto main beam.</span>")
		linked.set_light(10)
		linked.lights_enabled = TRUE

/obj/item/carkey/proc/reskin(mob/user)
	var/list/options = list("carkey", "carkey_cargonia", "carkey_fed", "carkey_rom", "carkey_klingon")
	for(var/option in options)
		options[option] = image(icon = src.icon, icon_state = "[option]")
	var/dowhat = show_radial_menu(user,src,options)
	if(!dowhat)
		return
	icon_state = dowhat

/obj/item/carkey/proc/rename(mob/user)
	if(!linked)
		to_chat(user, "<span class='notice'>[src] hasn't been linked yet!</span>")
		return FALSE
	var/message = stripped_input(user,"Select a name for [linked]","Unsuitable names will be removed.")
	if(!message)
		return
	if(findtext(message, "nigger") || findtext(message, "[station_name()]") || findtext(message, "faggot") || findtext(message, "http") || length(message) > 20) //Don't name it the same as the main ship, anything outright offensive, or a link to meatspin
		to_chat(user, "<span class='notice'>[src] flashes a red light,  forbidding you from naming the ship [message]</span>")
		return
	message_admins("[key_name(user)] just renamed a runabout to [message]")
	to_chat(user, "[src] buzzes softly.")
	linked.name = message
	linked.linked_area.name = message
	name = "runabout key fob ([linked])"
	name = "key fob ([linked.name])"

/obj/structure/overmap/runabout/attack_hand(mob/user, proximity)
	if(!proximity)
		if(get_dist(user, src) > 7)
			return
	if(locked)
		to_chat(user, "<span class='notice'>[src]'s airlock handles won't budge! Looks like it's locked...</span>")
		return
	if(ladders.len)
		to_chat(user, "<span class='notice'>You start to enter [src]...</span>")
		if(do_after(user, 50, target = src))
			var/turf/target = get_turf(pick(ladders))
			if(ishuman(user))
				var/mob/living/carbon/human/F = user
				if(F.pulling)
					F.pulling.forceMove(target)
			user.forceMove(target)
			playsound(user, 'sound/effects/footstep/catwalk5.ogg', 100, 1)
	else
		to_chat(user, "<span class='notice'>You can't find a way to enter [src]...</span>")

/obj/effect/landmark/runabout_dock
	name = "Runabout docking point"

/obj/effect/landmark/runabout_dock/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/find_overmap), 40)

/obj/effect/landmark/runabout_dock/proc/find_overmap()
	var/area/A = get_area(src)
	if(A.linked_overmap)
		A.linked_overmap.docking_points += src //This tells the ship's runabouts where to land.

/obj/structure/overmap_component/runabout_ladder
	name = "Runabout exit hatch"
	desc = "A ladder which allows you to exit a runabout."
	anchored = TRUE
	density = FALSE
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder10"

/obj/structure/overmap_component/runabout_ladder/find_overmap()
	. = ..()
	if(linked)
		if(istype(linked, /obj/structure/overmap/runabout))
			var/obj/structure/overmap/runabout/S = linked
			S.ladders += src

/obj/structure/overmap_component/runabout_ladder/attack_ghost(mob/user)
	return attack_hand(user)

/obj/structure/overmap_component/runabout_ladder/attack_hand(mob/user)
	if(!linked)
		find_overmap()
		return
	var/area/A = get_area(linked)
	if(istype(A, /area/space))
		to_chat(user, "<span class='notice'>It would be unwise to climb out of [linked] when it's in flight!</span>")
		return
	to_chat(user, "<span class='notice'>You climb up [src].</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/F = user
		if(F.pulling)
			F.pulling.forceMove(get_turf(linked))
	if(user.client)
		SEND_SOUND(user, sound(null, repeat = 0, wait = 0, volume = 100, channel = CHANNEL_REDALERT)) //Shuts up the red alert sound when you exit a shuttle.
	user.forceMove(get_turf(linked))
	playsound(src, 'sound/effects/footstep/catwalk5.ogg', 100, 1)

/obj/structure/overmap_component/runabout_ladder/attack_ai(mob/user)
	if(!linked)
		find_overmap()
		return
	var/mob/living/silicon/ai/A = user
	if(A.eyeobj)
		to_chat(user, "<span class='notice'>You move your camera up [src].</span>")
		A.eyeobj.forceMove(get_turf(linked))

/area/ship/runabout
	name = "Danube class runabout"
	class = "runabout"
	has_gravity = STANDARD_GRAVITY
	explosion_exempt = TRUE
	looping_ambience = 'DS13/sound/ambience/escape_pod.ogg'

/obj/structure/overmap_component/docking_computer
	name = "Docking computer"
	desc = "An advanced computer which allows you to dock and undock ships from other ships."
	icon_state = "docking"
	var/locked = FALSE //Cooldown

/obj/structure/overmap_component/docking_computer/attack_hand(mob/user)
	if(!linked)
		find_overmap()
		return FALSE
	if(locked)
		to_chat(user, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>maneuvering thrusters are still recharging.</span>")
		return FALSE
	var/area/A = get_area(linked)
	if(!A.linked_overmap || istype(A, /area/space)) //If there's a linked overmap, that means we're docked to a ship. Space doesnt have a linked overmap.
		var/list/ships = list()
		for(var/obj/structure/overmap/S in GLOB.overmap_ships)
			if(get_dist(S, linked) > 5) //You need to be quite close to dock.
				continue
			if(S.docking_points.len) //We need somewhere to dock.
				if(S.shields.check_vulnerability() || S.faction == linked.faction) //If they don't have shields, or you're in the same faction.
					ships += S
		if(!ships.len)
			to_chat(user, "<span class='boldnotice'>Unable to comply</span> - <span class='warning'>there are no suitable ships nearby. Ensure you're near a ship, and that their shields are down (or they're a member of [linked.faction].)</span>")
			return
		var/shipchoice
		shipchoice = input(user, "Select docking target", "Docking Control", shipchoice) as null|anything in ships
		if(!shipchoice)
			return
		var/question = alert("Dock [linked] to [shipchoice]?",name,"yes","no")
		if(question == "no" || !question)
			return
		var/obj/structure/overmap/selected = shipchoice
		if(istype(linked, /obj/structure/overmap/runabout))
			linked.icon = 'DS13/icons/overmap/runabout.dmi'
			linked.icon_state = "runabout"
		linked.nav_target = null
		linked.pixel_z = 200 //Shove it offscreen so we can land!
		linked.angle = 0
		linked.EditAngle()
		linked.forceMove(get_turf(pick(selected.docking_points)))
		linked.visible_message("<span class='danger'>[linked] starts descending!</span>")
		playsound(linked, 'DS13/sound/effects/docking_alarm.ogg', 100, FALSE)
		playsound(linked, 'DS13/sound/effects/pod_launch.ogg', 100, 1)
		linked.send_sound_all('DS13/sound/effects/docking_alarm.ogg')
		linked.send_sound_all('DS13/sound/effects/pod_launch.ogg', "<span class='notice'>A huge force weighs down on you as the deck plating under you lurches downwards.</span>")
		linked.pixel_w = -120
		for(var/i = 0, i < 50, i++)
			linked.pixel_z -= 6
			sleep(1)
		linked.pixel_z = -128
		linked.visible_message("<span class='danger'>[linked] lands!</span>")
	else
		var/question = alert("Undock [linked] from [A.linked_overmap]?",name,"yes","no")
		if(question == "no" || !question)
			return
		var/stored_pixel_z = linked.pixel_z
		linked.visible_message("<span class='danger'>[linked] starts to hover!</span>")
		playsound(linked, 'DS13/sound/effects/docking_alarm.ogg', 100, FALSE)
		playsound(linked, 'DS13/sound/effects/pod_launch.ogg', 100, 1)
		linked.send_sound_all('DS13/sound/effects/docking_alarm.ogg')
		linked.send_sound_all('DS13/sound/effects/pod_launch.ogg', "<span class='notice'>The deck plating under your lurches upwards.</span>")
		for(var/i = 0, i < 50, i++) //Animate it flying upwards
			linked.pixel_z += 2
			sleep(1)
		linked.pixel_z = stored_pixel_z
		linked.forceMove(get_turf(A.linked_overmap))
		if(istype(linked, /obj/structure/overmap/runabout))
			linked.icon = 'DS13/icons/overmap/runabout_small.dmi'
			linked.icon_state = "runabout"
			linked.pixel_z = 0 //Adjust view
			linked.pixel_w = 0
	locked = TRUE
	linked.visual_damage()
	addtimer(CALLBACK(src, .proc/remove_cooldown), 300) //30 second docking cooldown to prevent total ear destruction

/obj/structure/overmap_component/docking_computer/proc/remove_cooldown()
	locked = FALSE