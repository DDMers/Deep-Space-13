#define isBorgDrone(D) (D in GLOB.borg_collective.drones)

/datum/antagonist/borg_drone
	name = "Borg Drone"
	antagpanel_category = "Borg Drone"
	job_rank = ROLE_BORG_DRONE
	show_name_in_check_antagonists = TRUE
	antag_moodlet = /datum/mood_event/focused

/datum/antagonist/borg_drone/on_gain()
	. = ..()
	antag_memory += "We are a <font color='red'><B>borg drone</B></font>. We must assimilate the station at all costs."
	if(!isBorgDrone(src))
		GLOB.borg_collective.drones += owner.current //They're in the collective, but need the conversion table for all their upgrades like the tool etc.
		GLOB.borg_collective.check_completion()
	var/datum/objective/O = new /datum/objective/survive() //Change this later
	O.owner = owner
	objectives += O
	borgify(owner.current)

/datum/antagonist/borg_drone/on_removal()
	unborgify(owner.current)
	GLOB.borg_collective.drones -= owner.current //They're in the collective, but need the conversion table for all their upgrades like the tool etc.
	. = ..()

/datum/antagonist/borg_drone/greet()
	SEND_SOUND(owner.current, 'DS13/sound/effects/borg/collectivewhisper.ogg')
	to_chat(owner.current, "<span_class='bigbold'>We are borg.</span>")
	to_chat(owner.current, "<span_class='danger'>We require additional parts. We must seek out an assimilation bench to improve ourselves.</span>")
	owner.announce_objectives()

/datum/antagonist/borg_drone/proc/borgify(mob/living/carbon/human/H = owner.current)
	H.skin_tone = "albino"
	H.eye_color = "red"
	H.underwear = "Nude"
	H.undershirt = "Nude"
	H.socks = "Nude"
	H.hair_style = "Bald"
	H.hygiene = 100000000 //Smelly borg BEGONE
	H.dna.species.species_traits |= TRAIT_CLUMSY
	H.dna.species.species_traits |= TRAIT_NOHUNGER
	H.dna.species.species_traits |= TRAIT_NOGUNS
	H.dna.species.species_traits |= TRAIT_NOBREATH
	H.dna.species.species_traits |= TRAIT_RESISTCOLD
	H.dna.species.species_traits |= TRAIT_NOHUNGER
	H.update_body()

/datum/antagonist/borg_drone/proc/unborgify(mob/living/carbon/human/H = owner.current)
	H.real_name = random_unique_name(H.gender)
	H.name = H.real_name
	H.underwear = random_underwear(H.gender)
	H.skin_tone = random_skin_tone()
	H.hair_style = random_hair_style(H.gender)
	H.facial_hair_style = random_facial_hair_style(H.gender)
	H.hair_color = random_short_color()
	H.facial_hair_color = H.hair_color
	H.eye_color = random_eye_color()
	H.dna.blood_type = random_blood_type()
	H.hygiene = HYGIENE_LEVEL_NORMAL
	H.dna.species.species_traits ^= TRAIT_CLUMSY
	H.dna.species.species_traits ^= TRAIT_NOHUNGER
	H.dna.species.species_traits ^= TRAIT_NOGUNS
	H.dna.species.species_traits ^= TRAIT_NOBREATH
	H.dna.species.species_traits ^= TRAIT_RESISTCOLD
	H.dna.species.species_traits ^= TRAIT_NOHUNGER
	H.update_body()

/datum/antagonist/borg_drone/proc/equip(mob/living/carbon/human/H = owner.current)
	return H.equipOutfit(/datum/outfit/borg, visualsOnly = FALSE)

/datum/antagonist/borg_drone/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = ROLE_BORG_DRONE
	new_owner.special_role = ROLE_BORG_DRONE
	new_owner.add_antag_datum(src)
	switch(input("Equip this new borg drone?", "Borg Drone") as null|anything in list("Yes","No"))
		if("Yes")
			equip()
	message_admins("[key_name_admin(admin)] has assimilated [key_name_admin(new_owner)] into the borg collective.")
	log_admin("[key_name(admin)] has assimilated [key_name(new_owner)] into the borg collective.")

/mob/living/carbon/human/proc/make_borg()
	if(mind)
		mind.add_antag_datum(/datum/antagonist/borg_drone)

/obj/item/borg_tool
	name = "Primary prosthetic interaction node"
	desc = "This massive prosthetic houses a vicious claw and a full replicator suite for the rapid conversion of an area into God knows what. Click it while holding it to change its mode."
	icon = 'DS13/icons/weapons/melee.dmi'
	item_state = "borgtool"
	icon_state = "borgtool"
	lefthand_file = 'DS13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'DS13/icons/mob/inhands/weapons/guns_righthand.dmi'
	resistance_flags = UNACIDABLE
	var/mode = "assimilate"
	var/convert_time = 30 //3 seconds
	item_flags = NODROP
	force = 18 //hella strong
	var/removing_airlock = FALSE
	var/dismantling_machine = 0
	var/blacklistedmachines = list(/obj/machinery/computer/communications, /obj/machinery/computer/card)
	var/saved_time
	var/cooldown = 10
	var/resource_amount = 10 //Starts with a bit so you can build a structure from the get-go
	var/resource_cost = 10
	var/building = FALSE //We building summ't? if so stop trying to break things and spam it
	var/stopspammingturfs = FALSE //English reported a bug where you can spam click one tile for infinite resources...say bye to that lol

/obj/item/borg_tool/attack_self(mob/user)
	var/list/options = list("build", "combat", "assimilate")
	for(var/option in options)
		options[option] = image(icon = 'DS13/icons/actions/actions_borg.dmi', icon_state = "[option]")
	var/dowhat = show_radial_menu(user,user,options)
	if(!dowhat)
		return
	mode = dowhat
	to_chat(user,"<font color='green' size='2'><b>[src] is now set to [dowhat] mode.</b></font>")
	playsound(user.loc, 'sound/items/jaws_pry.ogg', 100,1)

/obj/item/borg_tool/attackby(obj/item/stack/I, mob/user)
	if(istype(I, /obj/item/stack))
		resource_amount += I.amount
		to_chat(user, "We have inserted [I] into our [src], its current resource count is: [resource_amount]")
		qdel(I)

/obj/item/borg_tool/examine(mob/user)
	. = ..()
	to_chat(user, "it has [resource_amount] units of resources stored, with a construction cost of [resource_cost] units per structure built")

/obj/item/borg_tool/proc/build_on_turf(turf/open/T, mob/user)
	if(!building)
		var/obj/structure/CP = locate() in T
		var/obj/machinery/CA = locate() in T
		if(CP || CA)
			to_chat(user,"<span class='danger'>[T] already has a structure on it.</span>")
			return
		var/mode = input("Borg construction.", "Build what?")in list("conversion suite", "borg alcove","wall","cancel")
		var/obj/structure/chair/borg/suite
		switch(mode)
			if("conversion suite")
				suite = /obj/structure/chair/borg/conversion
			if("borg alcove")
				suite = /obj/structure/chair/borg/charging
			if("wall")
				suite = /turf/closed/wall/trek_smooth/borg
			if("cancel")
				return
		if(resource_amount >= resource_cost)
			building = TRUE //stop spamming
			to_chat(user, "<span class='danger'>We are building a structure ontop of [T].</span>")
			playsound(user.loc, 'sound/items/rped.ogg',100,1)
			if(do_after(user, convert_time, target = T)) //doesnt get past here
				var/atom/newsuite = new suite(get_turf(T))
				building = FALSE
				to_chat(user, "We have built a [newsuite.name]")
				resource_amount -= resource_cost
				return
			building = FALSE //Catch
		else
			to_chat(user, "Our borg tool does not have enough stored material, it has [resource_amount], but it needs [resource_cost] to build a structure")

/obj/item/borg_tool/proc/assimilate(mob/user,mob/living/carbon/human/I)
	var/mob/living/carbon/human/M = I
	if(user == M)
		to_chat(user, "<span class='warning'>There is no use in assimilating ourselves.</span>")
		return
	if(isBorgDrone(M))
		to_chat(user, "<span class='warning'>They are already in the collective.</span>")
		return
	if(!M.mind)
		to_chat(user, "[M] does not have a consciousness, they would add nothing to the collective. Disposal of this life-form is recommended.")
		return
	to_chat(M, "<span class='warning'>[user] pierces you with their assimilation tubules!</span>")
	SEND_SIGNAL(M, COMSIG_LIVING_MINOR_SHOCK)
	M.Jitter(3)
	M.visible_message("<span class='warning'>[user] pierces [M] with their assimilation tubules!</span>")
	playsound(M.loc, 'sound/weapons/pierce.ogg', 100,1)
	if(do_after(user, 50, target = M)) //5 seconds
		M.make_borg()
		return

/obj/item/borg_tool/afterattack(atom/I, mob/living/user, proximity)
	if(proximity)
		if(mode == "assimilate") //assimilate
			if(ishuman(I))
				assimilate(user, I)
			if(istype(I, /turf/open))
				if(istype(I, /turf/open/floor/plating/borg))
					return
				if(stopspammingturfs)
					return 0
				var/turf/open/A = I
				to_chat(user, "<span class='danger'>We are assimilating [I].</span>")
				stopspammingturfs = TRUE
				if(do_after(user, convert_time, target = A))
					for(var/turf/open/TA in orange(user,1))
						if(!istype(TA, /turf/open/floor/plating/borg) && !istype(TA, /turf/open/openspace))
							TA.ChangeTurf(/turf/open/floor/plating/borg)
							resource_amount += 5
				stopspammingturfs = FALSE
			if(istype(I, /turf/closed/wall) && !istype(I, /turf/closed/wall/trek_smooth/borg))
				if(stopspammingturfs)
					return
				playsound(src.loc, 'DS13/sound/effects/borg/machines/convertx.ogg', 40, 4)
				to_chat(user, "<span class='danger'>We are assimilating [I].</span>")
				var/turf/closed/wall/A = I
				if(do_after(user, convert_time, target = A))
					A.ChangeTurf(/turf/closed/wall/trek_smooth/borg)
					stopspammingturfs = FALSE
					resource_amount += 5
		if(mode == "combat")
			if(istype(I, /obj/machinery/door/airlock) && !removing_airlock)
				tear_airlock(I, user)
				return
			if(istype(I, /mob/living/carbon/human))
				if(world.time <= saved_time + cooldown)
					return ..()
				saved_time = world.time
				var/mob/living/carbon/human/target = I
				user.start_pulling(target, supress_message = TRUE) //Instant aggro-grab combo. Borg need a really strong close range attack.
				target.grabbedby(user, 1)
				if(user.grab_state >= GRAB_NECK)
					target.grabbedby(user, 1)
				else
					user.start_pulling(target, supress_message = TRUE)
					if(user.pulling)
						target.stop_pulling()
						log_combat(user, target, "grabbed", addition="aggressively")
						user.grab_state = GRAB_NECK //Instant neck grab
				target.visible_message("<span class='warning'>[user] violently grabs [target]!</span>", \
				"<span class='userdanger'>[user] violently grabs you!</span>")
				target.Jitter(3)
				playsound(target.loc, 'DS13/sound/effects/borg/grab.ogg', 100,1)
				assimilate(user, target)
		if(mode == "build")
			if(istype(I, /turf/open))
				var/turf/open/T = I
				build_on_turf(T, user)
				return
	else
		. = ..()

/obj/item/borg_tool/proc/tear_airlock(obj/machinery/door/airlock/A, mob/user)
	removing_airlock = TRUE
	to_chat(user,"<span class='notice'>You start tearing apart the airlock...\
		</span>")
	playsound(src.loc, 'DS13/sound/effects/borg/machines/borgforcedoor.ogg', 100, 4)
	A.audible_message("<span class='italics'>You hear a loud metallic \
		grinding sound.</span>")
	if(do_after(user, delay=80, needhand=FALSE, target=A, progress=TRUE))
		A.audible_message("<span class='danger'>[A] is ripped \
			apart by [user]!</span>")
		qdel(A)
	removing_airlock = FALSE



/obj/structure/chair/borg/conversion
	name = "assimilation bench"
	desc = "Submit yourself to the collective"
	icon_state = "borg_off"
	icon = 'DS13/icons/borg/borg.dmi'
	anchored = 1
	can_buckle = 1
	can_be_unanchored = 0
	max_buckled_mobs = 1
	buildstacktype = null
	item_chair = null // if null it can't be picked up
	var/restrained = 0 //can they unbuckle easily?


/obj/structure/chair/borg/conversion/user_buckle_mob(mob/living/carbon/human/M, mob/user)
	if(!isBorgDrone(M))
		to_chat(M, "Assimilate them first")
		return
	M.unequip_everything()
	icon_state = "borg_off"
	visible_message("parts of [src] start to shift and move")
	playsound(loc, 'DS13/sound/effects/borg/machines/convert_table.ogg', 50, 1, -1)
	var/image/armoverlay = image('DS13/icons/borg/borg.dmi')
	armoverlay.icon_state = "borg_arms"
	armoverlay.layer = ABOVE_MOB_LAYER
	overlays += armoverlay
	var/image/armoroverlay = image('DS13/icons/borg/borg.dmi')
	armoroverlay.icon_state = "borgarmour"
	armoroverlay.layer = ABOVE_MOB_LAYER
	overlays += armoroverlay
	sleep(35)
	playsound(loc, 'DS13/sound/effects/borg/machines/convert_table2.ogg', 50, 1, -1)
	icon_state = "borg_off"
	M.equipOutfit(/datum/outfit/borg, visualsOnly = FALSE) //Outfit handles name etc.
	cut_overlays()
	overlays -= armoverlay
	overlays -= armoroverlay
	qdel(armoroverlay)
	qdel(armoverlay)
	return TRUE


/obj/structure/chair/borg/charging
	name = "recharging alcove"
	desc = "We must recharge to regain"
	icon_state = "borgcharger"
	icon = 'DS13/icons/borg/borg.dmi'
	anchored = TRUE
	can_buckle = TRUE
	can_be_unanchored = FALSE
	max_buckled_mobs = 1
	resistance_flags = FIRE_PROOF
	buildstacktype = null
	item_chair = null // if null it can't be picked up
	var/cooldown2 = 110 //music loop cooldowns
	var/saved_time2 = 0
	var/sound = 'DS13/sound/effects/borg/machines/alcove.ogg'
	var/mob/living/carbon/human/user
	var/charge_time = 0
	var/charge_amount = 10 //10 per tick, with a max charge storage of 1000

/obj/structure/chair/borg/charging/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/chair/borg/charging/process()
	if(user)
		user.adjustBruteLoss(-3)
		user.adjustFireLoss(-3)
		user.adjustOxyLoss(-3)
		if(user.stat == DEAD)
			user.updatehealth() // Previous "adjust" procs don't update health, so we do it manually.
			user.set_heartattack(FALSE)
			user.revive()
			user.adjustBruteLoss(-20) //give them a real kick so they do actually revive
			user.adjustFireLoss(-20)
			user.adjustOxyLoss(-20)
			user.adjustToxLoss(-20)
			user.restoreEars()
			user.adjust_eye_damage(-5)
			if(user.eye_blind || user.eye_blurry)
				user.set_blindness(0)
				user.set_blurriness(0)
			if(user.blood_volume < BLOOD_VOLUME_NORMAL)
				user.blood_volume += 5 // regenerate blood rapidly

	if(world.time >= saved_time2 + cooldown2)
		saved_time2 = world.time
		playsound(src,sound,10,0)
	else
		return

/obj/structure/chair/borg/charging/user_buckle_mob(mob/living/M, mob/User)
	if(ishuman(M) && M.loc == loc)
		var/mob/living/carbon/human/H = M
		if(isBorgDrone(H))
			user = H
			to_chat(H, "<span class='warning'>Establishing connection...</span>")
			to_chat(H, "<span class='warning'>Success!</span>")
			to_chat(H, "<span class='warning'>Connection established with [src]</span>")
			. = ..()
			user = H
		else
			src.visible_message("<span class='warning'>[M] cannot be recharged as they are not borg.</span>")
			unbuckle_mob(M)
			return TRUE
	else
		src.visible_message("<span class='warning'>[M] cannot be recharged.</span>")
		unbuckle_mob(M)
		return TRUE