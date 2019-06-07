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
	to_chat(owner.current, "<font size=6 color=red>We are a <B>borg drone</B>! <br>We must help our fellow drones at all costs, and convert 70% of [station_name()]'s crew.</font>")

/datum/antagonist/borg_drone/on_removal()
	to_chat(owner.current,  "We are no longer a <font color='red'><B>borg drone</B></font>")
	unborgify(owner.current)
	GLOB.borg_collective.drones -= owner.current //They're in the collective, but need the conversion table for all their upgrades like the tool etc.
	owner.current.visible_message("[owner.current] looks slightly dazed, as if they've woken up from a bad dream..", "<span class='notice'>You feel disoriented as the voices in your head finally stop.</span>")
	. = ..()

/datum/antagonist/borg_drone/greet()
	SEND_SOUND(owner.current, 'DS13/sound/effects/borg/collectivewhisper.ogg')
	to_chat(owner.current, "<span class='bigbold'>We are borg.</span>")
	to_chat(owner.current, "<span class='danger'>We require additional parts, seek out an assimilation bench to improve ourselves.</span>")
	owner.announce_objectives()

/datum/antagonist/borg_drone/proc/borgify(mob/living/carbon/human/H = owner.current)
	GLOB.borg_collective.drone_count ++
	H.skin_tone = "albino"
	H.eye_color = "red"
	H.underwear = "Nude"
	H.undershirt = "Nude"
	H.socks = "Nude"
	H.hair_style = "Bald"
	H.hygiene = 100000000 //Smelly borg BEGONE
	H.add_trait(TRAIT_CLUMSY, "borg")
	H.add_trait(TRAIT_NOGUNS, "borg")
	H.add_trait(TRAIT_NOBREATH, "borg")
	H.add_trait(TRAIT_RESISTCOLD, "borg")
	var/possible_names1 = list("First of","Second of","Third of","Fourth of","Five of","Six of","Seven of","Eight of","Nine of","Ten of","Eleven of","Twelve of","Thirteen of","Fourteen of","Fifteen of")
	var/possible_names2 = list("one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen")
	H.real_name = "[pick(possible_names1)] "+"[pick(possible_names2)] "+"[text_to_assignment(GLOB.borg_collective.drone_count)]"
	H.name = H.real_name
	H.update_body()

/datum/antagonist/borg_drone/proc/text_to_assignment(var/what)
	switch(what)
		if(1)
			return "(primary adjunct of [GLOB.borg_collective.name])"
		if(2)
			return "(secondary adjunct of [GLOB.borg_collective.name])"
		if(3)
			return "(tertiary adjunct of [GLOB.borg_collective.name])"
		if(4)
			return "(quaternary adjunct of [GLOB.borg_collective.name])"
		if(5)
			return "(quinary adjunct of [GLOB.borg_collective.name])"
		if(6)
			return "(senary adjunct of [GLOB.borg_collective.name])"
		if(7)
			return "(septenary adjunct of [GLOB.borg_collective.name])"
		if(8)
			return "(octonary adjunct of [GLOB.borg_collective.name])"
		if(9)
			return "(nonary adjunct of [GLOB.borg_collective.name])"
		if(10)
			return "(denary adjunct of [GLOB.borg_collective.name])"
		if(11)
			return "(primary subprocessor of [GLOB.borg_collective.name])"
		if(12)
			return "(secondary subprocessor of [GLOB.borg_collective.name])"
		if(13)
			return "(tertiary subprocessor of [GLOB.borg_collective.name])"
		if(14)
			return "(quinary subprocessor of [GLOB.borg_collective.name])"
		if(15)
			return "(senary subprocessor of [GLOB.borg_collective.name])"
	return "(auxiliary subprocessor of [GLOB.borg_collective.name])"

/datum/antagonist/borg_drone/proc/unborgify(mob/living/carbon/human/H = owner.current)
	H.real_name = H.dna.species.random_name()
	H.name = H.real_name
	H.underwear = initial(H.underwear)
	H.skin_tone = initial(H.skin_tone)
	H.hair_style = initial(H.hair_style)
	H.facial_hair_style = initial(H.facial_hair_style)
	H.hair_color = initial(H.hair_color)
	H.facial_hair_color = initial(H.facial_hair_color)
	H.eye_color = initial(H.eye_color)
	H.dna.blood_type = initial(H.dna.blood_type)
	H.hygiene = HYGIENE_LEVEL_NORMAL
	H.remove_trait(TRAIT_CLUMSY, "borg")
	H.remove_trait(TRAIT_NOGUNS, "borg")
	H.remove_trait(TRAIT_NOBREATH, "borg")
	H.remove_trait(TRAIT_RESISTCOLD, "borg")
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

/datum/mind/proc/make_borg()
	if(!(has_antag_datum(/datum/antagonist/borg_drone)))
		add_antag_datum(/datum/antagonist/borg_drone)
