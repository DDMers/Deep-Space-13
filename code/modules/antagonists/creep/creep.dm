/datum/antagonist/creep
	name = "Creep"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	job_rank = ROLE_CREEP
	show_name_in_check_antagonists = TRUE
	roundend_category = "creeps"
	silent = TRUE //not actually silent, because greet will be called by the trauma anyway.
	var/datum/brain_trauma/special/creep/trauma

/datum/antagonist/creep/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		to_chat(admin, "[roundend_category] come from a brain trauma, so they need to at least be a carbon!")
		return
	if(!C.getorgan(/obj/item/organ/brain)) // If only I had a brain
		to_chat(admin, "[roundend_category] come from a brain trauma, so they need to HAVE A BRAIN.")
		return
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	//PRESTO FUCKIN MAJESTO
	C.gain_trauma(/datum/brain_trauma/special/creep)//ZAP

/datum/antagonist/creep/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/creepalert.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner, "<span_class='boldannounce'>You are the Creep!</span>")
	to_chat(owner, "<B>They would call it an obsession. They would call you crazy, because they don't understand your unrequited love.<br>All you know is that you love [trauma.obsession]. And you. will. show them.</B>")
	to_chat(owner, "<B>I will surely go insane if I don't spend enough time around [trauma.obsession], but when i'm near them too long it gets too difficult to speak properly, making me look like a CREEP!</B>")
	to_chat(owner, "<span_class='boldannounce'>The gods would like to remind you that this role, as with all other antags, does not allow you to break ANY server rules, especially Rule 8 (These rules being listed from the \"Rules\" button at the top right of your mind's screen). Feel free to murder and pillage just like any other antag, though.</span>")
	owner.announce_objectives()

/datum/antagonist/creep/Destroy()
	if(trauma)
		qdel(trauma)
	. = ..()

/datum/antagonist/creep/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_creep_icons_added(M)

/datum/antagonist/creep/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_creep_icons_removed(M)

/datum/antagonist/creep/proc/forge_objectives(var/datum/mind/obsessionmind)
	var/list/objectives_left = list("spendtime", "polaroid", "hug")
	var/datum/objective/assassinate/creep/kill = new
	kill.owner = owner
	kill.target = obsessionmind
	var/datum/quirk/family_heirloom/family_heirloom

	for(var/datum/quirk/quirky in obsessionmind.current.roundstart_quirks)
		if(istype(quirky, /datum/quirk/family_heirloom))
			family_heirloom = quirky
			break
	if(family_heirloom)//oh, they have an heirloom? Well you know we have to steal that.
		objectives_left += "heirloom"

	if(obsessionmind.assigned_role && obsessionmind.assigned_role != "Captain" && !(obsessionmind.assigned_role in GLOB.nonhuman_positions))
		objectives_left += "jealous"//while this will sometimes be a free objective during lowpop, this works fine most of the time and is less intensive

	for(var/i in 1 to 3)
		var/chosen_objective = pick(objectives_left)
		objectives_left.Remove(chosen_objective)
		switch(chosen_objective)
			if("spendtime")
				var/datum/objective/spendtime/spendtime = new
				spendtime.owner = owner
				spendtime.target = obsessionmind
				objectives += spendtime
			if("polaroid")
				var/datum/objective/polaroid/polaroid = new
				polaroid.owner = owner
				polaroid.target = obsessionmind
				objectives += polaroid
			if("hug")
				var/datum/objective/hug/hug = new
				hug.owner = owner
				hug.target = obsessionmind
				objectives += hug
			if("heirloom")
				var/datum/objective/steal/heirloom_thief/heirloom_thief = new
				heirloom_thief.owner = owner
				heirloom_thief.target = obsessionmind//while you usually wouldn't need this for stealing, we need the name of the obsession
				heirloom_thief.steal_target = family_heirloom.heirloom
				objectives += heirloom_thief
			if("jealous")
				var/datum/objective/assassinate/jealous/jealous = new
				jealous.owner = owner
				jealous.target = obsessionmind//will reroll into a coworker on the objective itself
				objectives += jealous

	objectives += kill//finally add the assassinate last, because you'd have to complete it last to greentext.
	for(var/datum/objective/O in objectives)
		O.update_explanation_text()

/datum/antagonist/creep/roundend_report_header()
	return 	"<span_class='header'>Someone became a creep!</span><br>"

/datum/antagonist/creep/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += "<b>[printplayer(owner)]</b>"

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break
	if(trauma)
		if(trauma.total_time_creeping > 0)
			report += "<span_class='greentext'>The [name] spent a total of [DisplayTimeText(trauma.total_time_creeping)] being near [trauma.obsession]!</span>"
		else
			report += "<span_class='redtext'>The [name] did not go near their obsession the entire round! That's extremely impressive, but you are a shit [name]!</span>"
	else
		report += "<span_class='redtext'>The [name] had no trauma attached to their antagonist ways! Either it bugged out or an admin incorrectly gave this good samaritan antag and it broke! You might as well show yourself!!</span>"

	if(objectives.len == 0 || objectives_complete)
		report += "<span_class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span_class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

//////////////////////////////////////////////////
///CREEPY objectives (few chosen per obsession)///
//////////////////////////////////////////////////

/datum/objective/assassinate/creep //just a creepy version of assassinate

/datum/objective/assassinate/creep/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Murder [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		message_admins("WARNING! [ADMIN_LOOKUPFLW(owner)] creep objectives forged without an obsession!")
		explanation_text = "Free Objective"

/datum/objective/assassinate/jealous //assassinate, but it changes the target to someone else in the previous target's department. cool, right?
	var/datum/mind/old //the target the coworker was picked from.

/datum/objective/assassinate/jealous/update_explanation_text()
	..()
	old = find_coworker(target)
	if(target && target.current && old)
		explanation_text = "Murder [target.name], [old]'s coworker."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/jealous/proc/find_coworker(datum/mind/oldmind)//returning null = free objective
	if(!oldmind.assigned_role)
		return
	var/list/viable_coworkers = list()
	var/list/all_coworkers = list()
	var/chosen_department
	var/their_chosen_department
	//note that command and sillycone are gone because borgs can't be obsessions and the heads have their respective department. Sorry cap, your place is more with centcom or something
	if(oldmind.assigned_role in GLOB.security_positions)
		chosen_department = "security"
	if(oldmind.assigned_role in GLOB.engineering_positions)
		chosen_department = "engineering"
	if(oldmind.assigned_role in GLOB.medical_positions)
		chosen_department = "medical"
	if(oldmind.assigned_role in GLOB.science_positions)
		chosen_department = "science"
	if(oldmind.assigned_role in GLOB.supply_positions)
		chosen_department = "supply"
	if(oldmind.assigned_role in GLOB.civilian_positions)
		chosen_department = "civilian"
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.mind)
			continue
		if(!H.mind.assigned_role || H == oldmind.current || H.mind.has_antag_datum(/datum/antagonist/creep)) //the jealousy target has to have a job, and not be the obsession or creep.
			continue
		//this won't be called often thankfully.
		if(H.mind.assigned_role in GLOB.security_positions)
			their_chosen_department = "security"
		if(H.mind.assigned_role in GLOB.engineering_positions)
			their_chosen_department = "engineering"
		if(H.mind.assigned_role in GLOB.medical_positions)
			their_chosen_department = "medical"
		if(H.mind.assigned_role in GLOB.science_positions)
			their_chosen_department = "science"
		if(H.mind.assigned_role in GLOB.supply_positions)
			their_chosen_department = "supply"
		if(H.mind.assigned_role in GLOB.civilian_positions)
			their_chosen_department = "civilian"
		if(their_chosen_department != chosen_department)
			continue
		viable_coworkers += H

	if(viable_coworkers.len > 0)//find someone in the same department
		target = pick(viable_coworkers)
	else if(all_coworkers.len > 0)//find someone who works on the station
	else
		return//there is nobody but you and the obsession
	return oldmind

/datum/objective/spendtime //spend some time around someone, handled by the creep trauma since that ticks
	name = "spendtime"
	var/timer = 1800 //5 minutes

/datum/objective/spendtime/update_explanation_text()
	if(timer == initial(timer))//just so admins can mess with it
		timer += pick(-600, 0)
	var/datum/antagonist/creep/creeper = owner.has_antag_datum(/datum/antagonist/creep)
	if(target && target.current && creeper)
		creeper.trauma.attachedcreepobj = src
		explanation_text = "Spend [DisplayTimeText(timer)] around [target.name] while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/spendtime/check_completion()
	return timer <= 0 || explanation_text == "Free Objective"


/datum/objective/hug//this objective isn't perfect. hugging the correct amount of times, then switching bodies, might fail the objective anyway. maybe i'll come back and fix this sometime.
	name = "hugs"
	var/hugs_needed

/datum/objective/hug/update_explanation_text()
	..()
	if(!hugs_needed)//just so admins can mess with it
		hugs_needed = rand(4,6)
	var/datum/antagonist/creep/creeper = owner.has_antag_datum(/datum/antagonist/creep)
	if(target && target.current && creeper)
		explanation_text = "Hug [target.name] [hugs_needed] times while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/hug/check_completion()
	var/datum/antagonist/creep/creeper = owner.has_antag_datum(/datum/antagonist/creep)
	if(!creeper || !creeper.trauma || !hugs_needed)
		return TRUE//free objective
	return creeper.trauma.obsession_hug_count >= hugs_needed

/datum/objective/polaroid //take a picture of the target with you in it.
	name = "polaroid"

/datum/objective/polaroid/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Take a photo with [target.name] while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/polaroid/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue
		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
		for(var/obj/I in all_items) //Check for wanted items
			if(istype(I, /obj/item/photo))
				var/obj/item/photo/P = I
				if(P.picture.mobs_seen.Find(owner) && P.picture.mobs_seen.Find(target) && !P.picture.dead_seen.Find(target))//you are in the picture, they are but they are not dead.
					return TRUE
	return FALSE


/datum/objective/steal/heirloom_thief //exactly what it sounds like, steal someone's heirloom.
	name = "heirloomthief"

/datum/objective/steal/heirloom_thief/update_explanation_text()
	..()
	if(steal_target)
		explanation_text = "Steal [target.name]'s family heirloom, [steal_target] they cherish."
	else
		explanation_text = "Free Objective"

/datum/antagonist/creep/proc/update_creep_icons_added(var/mob/living/carbon/human/creep)
	var/datum/atom_hud/antag/creephud = GLOB.huds[ANTAG_HUD_CREEP]
	creephud.join_hud(creep)
	set_antag_hud(creep, "creep")

/datum/antagonist/creep/proc/update_creep_icons_removed(var/mob/living/carbon/human/creep)
	var/datum/atom_hud/antag/creephud = GLOB.huds[ANTAG_HUD_CREEP]
	creephud.leave_hud(creep)
	set_antag_hud(creep, null)