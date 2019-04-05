#define SECTION31_HUMAN "human"
#define SECTION31_AI "AI"

/datum/antagonist/section31
	name = "Section 31 Agent"
	roundend_category = "Section 31 Agents"
	antagpanel_category = "Section 31 Agent"
	job_rank = ROLE_SECTION31
	antag_moodlet = /datum/mood_event/focused
	var/special_role = ROLE_SECTION31
	var/employer = "Section 31"
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	var/should_equip = TRUE
	var/section31_outfit = /datum/outfit/section31
	var/section31_kind = SECTION31_HUMAN //Set on initial assignment
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/section31/on_gain()
	if(owner.current && isAI(owner.current))
		section31_kind = SECTION31_AI

	SSticker.mode.traitors += owner
	owner.special_role = special_role
	if(give_objectives)
		forge_section31_objectives()
	equip_op()
	finalize_section31()
	..()

/datum/antagonist/section31/apply_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/section31_mob = owner.current
		if(section31_mob && istype(section31_mob))
			if(!silent)
				to_chat(section31_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			section31_mob.dna.remove_mutation(CLOWNMUT)

/datum/antagonist/section31/remove_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/section31_mob = owner.current
		if(section31_mob && istype(section31_mob))
			section31_mob.dna.add_mutation(CLOWNMUT)

/datum/antagonist/section31/proc/equip_op()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current

	H.set_species(/datum/species/human) // All Section 31 members seen so far are human.

	H.equipOutfit(section31_outfit)
	return TRUE

/datum/antagonist/section31/on_removal()
	//Remove malf powers.
	if(section31_kind == SECTION31_AI && owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.set_zeroth_law("")
		A.verbs -= /mob/living/silicon/ai/proc/choose_modules
		A.malf_picker.remove_malf_verbs(A)
		qdel(A.malf_picker)

	SSticker.mode.traitors -= owner
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'> You are no longer the [special_role]! </span>")
	owner.special_role = null
	..()

/datum/antagonist/section31/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/section31/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/section31/proc/forge_section31_objectives()
	switch(section31_kind)
		if(SECTION31_AI)
			forge_ai_objectives()
		else
			forge_human_objectives()

/datum/antagonist/section31/proc/forge_human_objectives()
	var/is_hijacker = FALSE
	if (GLOB.joined_player_list.len >= 30) // Less murderboning on lowpop thanks
		is_hijacker = prob(10)
	var/martyr_chance = prob(20)
	var/objective_count = is_hijacker 			//Hijacking counts towards number of objectives
	if(!SSticker.mode.exchange_blue && SSticker.mode.traitors.len >= 8) 	//Set up an exchange if there are enough traitors
		if(!SSticker.mode.exchange_red)
			SSticker.mode.exchange_red = owner
		else
			SSticker.mode.exchange_blue = owner
			assign_exchange_role(SSticker.mode.exchange_red)
			assign_exchange_role(SSticker.mode.exchange_blue)
		objective_count += 1					//Exchange counts towards number of objectives
	var/toa = CONFIG_GET(number/traitor_objectives_amount)
	for(var/i = objective_count, i < toa, i++)
		forge_single_objective()

	if(is_hijacker && objective_count <= toa) //Don't assign hijack if it would exceed the number of objectives set in config.traitor_objectives_amount
		if (!(locate(/datum/objective/hijack) in objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
			return


	var/martyr_compatibility = 1 //You can't succeed in stealing if you're dead.
	for(var/datum/objective/O in objectives)
		if(!O.martyr_compatible)
			martyr_compatibility = 0
			break

	if(martyr_compatibility && martyr_chance)
		var/datum/objective/martyr/martyr_objective = new
		martyr_objective.owner = owner
		add_objective(martyr_objective)
		return

	else
		if(!(locate(/datum/objective/escape) in objectives))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			add_objective(escape_objective)
			return

/datum/antagonist/section31/proc/forge_ai_objectives()
	var/objective_count = 0

	if(prob(30))
		objective_count += forge_single_objective()

	for(var/i = objective_count, i < CONFIG_GET(number/traitor_objectives_amount), i++)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.find_target()
		add_objective(kill_objective)

	var/datum/objective/survive/exist/exist_objective = new
	exist_objective.owner = owner
	add_objective(exist_objective)


/datum/antagonist/section31/proc/forge_single_objective()
	switch(section31_kind)
		if(SECTION31_AI)
			return forge_single_AI_objective()
		else
			return forge_single_human_objective()

/datum/antagonist/section31/proc/forge_single_human_objective() //Returns how many objectives are added
	.=1
	if(prob(50))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			add_objective(maroon_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		if(prob(15) && !(locate(/datum/objective/download) in objectives) && !(owner.assigned_role in list("Research Director", "Scientist", "Roboticist")))
			var/datum/objective/download/download_objective = new
			download_objective.owner = owner
			download_objective.gen_amount_goal()
			add_objective(download_objective)
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			add_objective(steal_objective)

/datum/antagonist/section31/proc/forge_single_AI_objective()
	.=1
	var/special_pick = rand(1,4)
	switch(special_pick)
		if(1)
			var/datum/objective/block/block_objective = new
			block_objective.owner = owner
			add_objective(block_objective)
		if(2)
			var/datum/objective/purge/purge_objective = new
			purge_objective.owner = owner
			add_objective(purge_objective)
		if(3)
			var/datum/objective/robot_army/robot_objective = new
			robot_objective.owner = owner
			add_objective(robot_objective)
		if(4) //Protect and strand a target
			var/datum/objective/protect/yandere_one = new
			yandere_one.owner = owner
			add_objective(yandere_one)
			yandere_one.find_target()
			var/datum/objective/maroon/yandere_two = new
			yandere_two.owner = owner
			yandere_two.target = yandere_one.target
			yandere_two.update_explanation_text() // normally called in find_target()
			add_objective(yandere_two)
			.=2

/datum/antagonist/section31/greet()
	SEND_SOUND(owner.current, 'DS13/sound/effects/section31/section31.ogg')
	to_chat(owner.current, "<B><font size=3 color=red>You are the [owner.special_role].</font></B>")
	to_chat(owner.current, "<span class='danger'>We are here under best interests of the higher echelons of Federation Command, we are the never blinking eye.</span>")
	to_chat(owner.current, "<span class='danger'>No one of any authority is permitted to interfere with your objectives, complete them at all costs. Do not allow yourself to be captured, you are armed with a cyanide pill and various implants of explosives. Remove all nuisances and potential threats to yourself and the Federation by all means necessary.</span>")
	owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()

/datum/antagonist/section31/proc/update_section31_icons_added(datum/mind/section31_mind)
	var/datum/atom_hud/antag/section31hud = GLOB.huds[ANTAG_HUD_TRAITOR]
	section31hud.join_hud(owner.current)
	set_antag_hud(owner.current, "Section 31")

/datum/antagonist/section31/proc/update_section31_icons_removed(datum/mind/section31_mind)
	var/datum/atom_hud/antag/section31hud = GLOB.huds[ANTAG_HUD_TRAITOR]
	section31hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/section31/proc/finalize_section31()
	switch(section31_kind)
		if(SECTION31_AI)
			add_law_zero()
			owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE)
			owner.current.grant_language(/datum/language/codespeak)
		if(SECTION31_HUMAN)
			if(should_equip)
				equip(silent)
			owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/section31/apply_innate_effects(mob/living/mob_override)
	. = ..()
	update_section31_icons_added()
	var/mob/living/silicon/ai/A = mob_override || owner.current
	if(istype(A) && section31_kind == SECTION31_AI)
		A.hack_software = TRUE

/datum/antagonist/section31/remove_innate_effects(mob/living/mob_override)
	. = ..()
	update_section31_icons_removed()
	var/mob/living/silicon/ai/A = mob_override || owner.current
	if(istype(A)  && section31_kind == SECTION31_AI)
		A.hack_software = FALSE

/datum/antagonist/section31/proc/give_codewords()
	if(!owner.current)
		return
	var/mob/section31_mob=owner.current

	to_chat(section31_mob, "<U><B>Section 31 Headquarters has provided you with the following information on how to identify fellow agents:</B></U>")
	to_chat(section31_mob, "<B>Code Phrase</B>: <span class='danger'>[GLOB.syndicate_code_phrase]</span>")
	to_chat(section31_mob, "<B>Code Response</B>: <span class='danger'>[GLOB.syndicate_code_response]</span>")

	antag_memory += "<b>Code Phrase</b>: [GLOB.syndicate_code_phrase]<br>"
	antag_memory += "<b>Code Response</b>: [GLOB.syndicate_code_response]<br>"

	to_chat(section31_mob, "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")

/datum/antagonist/section31/proc/add_law_zero()
	var/mob/living/silicon/ai/killer = owner.current
	if(!killer || !istype(killer))
		return
	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	killer.set_zeroth_law(law, law_borg)
	killer.set_syndie_radio()
	to_chat(killer, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	killer.add_malf_picker()

/datum/antagonist/section31/proc/equip(var/silent = FALSE)
	if(section31_kind == SECTION31_HUMAN)
		owner.equip_traitor(employer, silent, src)

/datum/antagonist/section31/proc/assign_exchange_role()
	//set faction
	var/faction = "red"
	if(owner == SSticker.mode.exchange_blue)
		faction = "blue"

	//Assign objectives
	var/datum/objective/steal/exchange/exchange_objective = new
	exchange_objective.set_faction(faction,((faction == "red") ? SSticker.mode.exchange_blue : SSticker.mode.exchange_red))
	exchange_objective.owner = owner
	add_objective(exchange_objective)

	if(prob(20))
		var/datum/objective/steal/exchange/backstab/backstab_objective = new
		backstab_objective.set_faction(faction)
		backstab_objective.owner = owner
		add_objective(backstab_objective)

	//Spawn and equip documents
	var/mob/living/carbon/human/mob = owner.current

	var/obj/item/folder/syndicate/folder
	if(owner == SSticker.mode.exchange_red)
		folder = new/obj/item/folder/syndicate/red(mob.loc)
	else
		folder = new/obj/item/folder/syndicate/blue(mob.loc)

	var/list/slots = list (
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE
	)

	var/where = "At your feet"
	var/equipped_slot = mob.equip_in_one_of_slots(folder, slots)
	if (equipped_slot)
		where = "In your [equipped_slot]"
	to_chat(mob, "<BR><BR><span class='info'>[where] is a folder containing <b>secret documents</b> that another agent group wants. We have set up a meeting with one of our agents on station to make an exchange. Exercise extreme caution as they cannot be trusted and may be hostile.</span><BR>")

//TODO Collate
/datum/antagonist/section31/roundend_report()
	var/list/result = list()

	var/section31win = TRUE

	result += printplayer(owner)

	var/TC_uses = 0
	var/uplink_true = FALSE
	var/purchases = ""
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[owner.key]
	if(H)
		TC_uses = H.total_spent
		uplink_true = TRUE
		purchases += H.generate_render(FALSE)

	var/objectives_text = ""
	if(objectives.len)//If the Section 31 Agent had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				section31win = FALSE
			count++

	if(uplink_true)
		var/uplink_text = "(used [TC_uses] TC) [purchases]"
		if(TC_uses==0 && section31win)
			var/static/icon/badass = icon('icons/badass.dmi', "badass")
			uplink_text += "<BIG>[icon2html(badass, world)]</BIG>"
		result += uplink_text

	result += objectives_text

	var/special_role_text = lowertext(name)

	if(section31win)
		result += "<span class='greentext'>The [special_role_text] was successful!</span>"
	else
		result += "<span class='redtext'>The [special_role_text] has failed!</span>"
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")

/datum/antagonist/section31/roundend_report_footer()
	return "<br><b>The code phrases were:</b> <span class='codephrase'>[GLOB.syndicate_code_phrase]</span><br>\
		<b>The code responses were:</b> <span class='codephrase'>[GLOB.syndicate_code_response]</span><br>"

/datum/antagonist/section31/is_gamemode_hero()
	return SSticker.mode.name == "section31"
