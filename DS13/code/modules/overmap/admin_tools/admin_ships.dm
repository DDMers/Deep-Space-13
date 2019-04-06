/obj/structure/overmap_component/helm/spawner //A helm console which when clicked by an admin, will spawn a new overmap ship (unless it's already linked to one!) This is used for the preset adminbus ships.
	var/ship_type = null //Set this to !null and it'll spawn a ship when clicked if one doesn't exist.

/obj/structure/overmap_component/helm/spawner/dderidex
	ship_type = /obj/structure/overmap/dderidex
	redalert_sound = 'DS13/sound/effects/redalert-rom.ogg'

/obj/structure/overmap_component/helm/spawner/attack_hand(mob/user)
	if(!linked && ship_type) //If we have something to make, make it.
		if(check_rights_for(user.client, R_ADMIN))
			var/question = alert("This area does not have a linked ship, would you like to create one?",name,"Yes","No")
			if(question == "No" || !question)
				return
			var/obj/effect/landmark/overmap_event_spawn/S = pick(GLOB.overmap_event_spawns)
			linked = new ship_type(get_turf(S))
			var/area/A = get_area(src)
			linked.linked_area = A
			linked.class = A.class
			A.linked_overmap = linked //We're doing this again so we can rapidly assign vars with 0 wait.
			for(var/obj/structure/overmap_component/XR in A) //We call this to update the components with our new ship object, as it wasn't created at runtime!
				XR.find_overmap()
			to_chat(user, "<span class='notice>Ship successfully spawned in a random location!</span>")
			log_game("[key_name(user)] created a [linked].")
			message_admins("[key_name(user)] created a [linked].")
		else
			to_chat(user, "<span class='notice'>The console doesn't respond to anyone lower than an a fleet admiral in rank (contact the admins).</span>")
		return
	. = ..()

/obj/structure/overmap/proc/cloak()
	if(!cloaked)
		send_sound_all('DS13/sound/effects/cloak.ogg', "<span class='notice'> You can feel the deck fade slightly as the ship cloaks. </span>")
		icon_state = "cloak"
		cloaked = TRUE //They can be fired at, but can't shoot or hail or do anything.
		sleep(10) //Tiny sleeps are fine.
		alpha = 0
		mouse_opacity = 0 //You cannot hover over it.
	else
		send_sound_all('DS13/sound/effects/decloak.ogg', "<span class='notice'> You can feel the deck fade slightly as the ship decloaks. </span>")
		icon_state = "decloak"
		alpha = 255
		mouse_opacity = 1 //You can fire at a decloaking ship, but they can't shoot you.
		sleep(10) //Tiny sleeps are fine.
		cloaked = FALSE
		icon_state = initial(icon_state)
		visual_damage()

/obj/structure/overmap_component/cloaking //WARNING: PROBABLY OP :b1:
	name = "Cloaking device control console."
	desc = "A console with Romulan writing flashing all over it, when clicked with an open hand this console will let you cloak or decloak the ship. Fancy..."
	icon_state = "cloaking"

/obj/structure/overmap_component/cloaking/attack_hand()
	. = ..()
	if(!linked)
		return
	if(!linked.cloaked)
		var/question = alert("Activate this ship's cloaking device?",name,"Yes","No")
		if(question == "No" || !question)
			return
		linked.cloak()
	else
		var/question = alert("Deactivate this ship's cloaking device?",name,"Yes","No")
		if(question == "No" || !question)
			return
		linked.cloak()