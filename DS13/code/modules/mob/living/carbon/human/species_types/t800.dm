/datum/species/t800 //Badmin robot of death.
	name = "T-800"
	id = "t800"
	say_mod = "states"
	sexes = FALSE
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYES)
	inherent_traits = list(TRAIT_VIRUSIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOLIMBDISABLE,TRAIT_NOHUNGER,TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	meat = null
	damage_overlay_type = "synth"
	limbs_id = "t800"
	armor = 80 //Considering they can just transporter it off...
	punchdamagelow = 10
	punchdamagehigh = 19
	punchstunthreshold = 14 //about 50% chance to stun
	no_equip = list(SLOT_WEAR_MASK, SLOT_WEAR_SUIT, SLOT_GLOVES, SLOT_SHOES, SLOT_W_UNIFORM, SLOT_S_STORE)
	nojumpsuit = TRUE
	stunmod = 0 //Can't be stunned
	speedmod = 3 //pretty fucking slow
	attack_sound = 'sound/weapons/resonator_blast.ogg'
	miss_sound = 'sound/weapons/parry.ogg'


/datum/species/t800/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	if(user.a_intent != INTENT_HELP)//Help intent to heal
		return ..()
	if(istype(I, /obj/item/weldingtool))
		var/obj/item/weldingtool/W = I
		if(!W.tool_start_check(user, amount=3))
			return
		playsound(H.loc,I.usesound,100,1)
		to_chat(user, "<span class='notice'>You start repairing [H]...</span>")
		if(do_after(user, 100, target = H))
			playsound(H.loc,I.usesound,100,1)
			to_chat(user, "<span class='warning'>Repairs complete</span>")
			H.set_hygiene(HYGIENE_LEVEL_CLEAN)
			H.adjustBruteLoss(-10)
			H.adjustFireLoss(-10)
			return FALSE
	. = ..()

/datum/species/t800/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "iron")
		chem.reaction_mob(H, TOUCH, 2 ,0) //heal a little
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return TRUE
	else
		return FALSE //We don't want them to be morphine'd

/obj/item/organ/body_egg/t800chip
	name = "Neural net processor"
	desc = "An advanced processor unit which uses machine learning to drive robotic exoskeletons. <b> You could probably reprogram it with a multitool...</b>"
	zone = BODY_ZONE_HEAD
	slot = "t800_chip"
	icon_state = "neural_cpu"
	var/mob/living/carbon/human/protect_target //Allows you to reprogram its cpu so it has to protect someone instead of murdering them.
	var/mob/living/carbon/human/assasinate_target //Allows you to send a killer robot after someone.
	var/datum/antagonist/objective_holder

/obj/item/organ/body_egg/t800chip/multitool_act(mob/living/user, obj/item/I)
	var/list/options = list("assasinate", "protect", "clear")
	for(var/option in options)
		options[option] = image(icon = 'DS13/icons/actions/weaponselect.dmi', icon_state = "[option]")
	var/dowhat = show_radial_menu(user,src,options)
	if(!dowhat)
		return
	var/list/targets = list()
	for(var/mob/M in GLOB.player_list)
		if(M && is_station_level(M.z) && M.mind)
			targets += M
	switch(dowhat)
		if("assasinate")
			var/mob/selection = input("Select a new target", "Neural net processor", null, null) as null|anything in targets
			to_chat(user, "<span class='warning'>Extermination target set. Re-insert neural net processor to complete reprogramming...</span>")
			if(!selection)
				return
			assasinate_target = selection
		if("protect")
			var/mob/selection = input("Who do you want this unit to protect?", "Neural net processor", null, null) as null|anything in targets
			to_chat(user, "<span class='warning'>Target set. New directive: protect [selection]. Re-insert neural net processor to complete reprogramming...</span>")
			if(!selection)
				return
			protect_target = selection
		if("clear")
			to_chat(user, "<span class='warning'>All targets reset.</span>")
			protect_target = null
			assasinate_target = null

/obj/item/organ/body_egg/t800chip/Remove(mob/living/carbon/M, special = 0) //Allows for deborging
	. = ..()
	to_chat(M, "<span class='warning'>WARNING: Neural net processor removed. Targetting parameters reset. Directive: Await new target.</span>")
	if(objective_holder)
		objective_holder.objectives = list()
		objective_holder = null
	if(M.mind)
		M.mind.remove_antag_datum(/datum/antagonist/custom)

/obj/item/organ/body_egg/t800chip/Insert(mob/living/carbon/M, special = 0) //Allows for deborging
	. = ..()
	if(!M.mind)
		return
	if(!objective_holder)
		objective_holder = M.mind.add_antag_datum(/datum/antagonist/custom)//To hold objectives.
	if(protect_target)
		var/datum/objective/protect/X = new
		X.owner = M.mind
		if(protect_target.mind)
			X.target = protect_target.mind
		X.explanation_text = "Protect [protect_target] at all costs. Accept any commands they give you..."
		objective_holder.objectives += X
		to_chat(M, "<span class='warning'>Mission parameters modified: Protect [protect_target]</span>")
	if(assasinate_target)
		var/datum/objective/assassinate/X = new
		X.owner = M.mind
		if(assasinate_target.mind)
			X.target = assasinate_target.mind
		X.explanation_text = "Terminate [protect_target] at all costs. Casualties are acceptable."
		objective_holder.objectives += X
		to_chat(M, "<span class='warning'>Mission parameters modified: New target: [assasinate_target]</span>")
	to_chat(M, "<span class='warning'>WARNING: Neural net processor connection re-established.</span>")

/mob/living/carbon/human/species/t800
	race = /datum/species/t800

/mob/living/carbon/human/species/t800/adjust_hygiene(amount)
	return //Fuck off stinky robot

/obj/item/organ/cyberimp/arm/t800
	name = "eradication toolset"
	desc = "A highly dangerous implant set allowing t-800 model eradication units to hunt down their targets relentlessly."
	contents = newlist(/obj/item/borg/stun,/obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/power, /obj/item/wirecutters/cyborg, /obj/item/multitool/cyborg,/obj/item/card/emag)

/datum/species/t800/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	..()
	var/obj/item/organ/eyes/E = H.getorganslot(ORGAN_SLOT_EYES)
	E.sight_flags |= SEE_MOBS | SEE_OBJS | SEE_TURFS //Add sight flags to the user's eyes
	E.flash_protect = 2 //Adjust the user's eyes' flash protection
	H.overlay_fullscreen("t800_hud", /obj/screen/fullscreen/t800, 1)
	var/obj/item/organ/cyberimp/arm/t800/stored = new(get_turf(H))
	stored.Insert(H)
	H.AddComponent(/datum/component/redirect, list(COMSIG_MOVABLE_MOVED = CALLBACK(src, .proc/on_mob_move, H))) //Allows it to stomp around when it moves
	H.grant_all_languages(omnitongue=TRUE)
	var/obj/item/organ/body_egg/t800chip/brain = new(get_turf(H))
	brain.Insert(H)
	H.throw_alert("t800tracking", /obj/screen/alert/t800_radar)
	spawn(0)
		addtimer(CALLBACK(src, .proc/adjust_name, H), 20) //Delay to reset name.

/datum/species/t800/proc/adjust_name(var/mob/living/H)
	if(!H)
		return
	var/series = rand(100-1000)
	H.name = "T[series] model eradication unit" //DESTROY TSERIES
	H.real_name = H.name

/datum/species/t800/on_species_loss(mob/living/carbon/human/H, datum/species/old_species)
	..()
	var/obj/item/organ/eyes/E = H.getorganslot(ORGAN_SLOT_EYES)
	E.sight_flags ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Add sight flags to the user's eyes
	E.flash_protect = 2 //Adjust the user's eyes' flash protection
	H.clear_fullscreen("t800_hud")
	if(H.mind)
		H.mind.remove_traitor()
	H.clear_alert("t800tracking")

/datum/species/t800/proc/on_mob_move(var/mob/living/owner)
	if(!owner)
		return
	var/chosen = pick('DS13/sound/effects/robot_steps/step1.ogg','DS13/sound/effects/robot_steps/step2.ogg','DS13/sound/effects/robot_steps/step3.ogg')
	playsound(owner, chosen, 50, 1)
	if(owner.client && !owner.client.played)
		owner.client.played = TRUE
		SEND_SOUND(owner, sound('DS13/sound/effects/robot_steps/vision.ogg', repeat = 1, wait = 0, volume = 80, channel = CHANNEL_AMBIENCE))

/obj/screen/fullscreen/t800
	icon_state = "t800"
	icon = 'DS13/icons/mob/screen_full.dmi'
	layer = BLIND_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/alert/t800_radar
	name = "Target acquisition"
	desc = "Select target for acquisition."
	icon_state = "t800"
	icon = 'DS13/icons/actions/t800.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/mob/living/carbon/human/owner
	var/mob/living/target

/obj/screen/alert/t800_radar/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess,src)

/obj/screen/alert/t800_radar/Destroy()
	STOP_PROCESSING(SSfastprocess,src)
	. = ..()

/obj/screen/alert/t800_radar/Click(location, control, params)
	var/mob/living/L = usr
	owner = L
	var/list/targets = list()
	for(var/mob/M in GLOB.player_list)
		if(M && is_station_level(M.z))
			targets += M
	var/mob/selection = input("Track whom?", "Neural net processor", null, null) as null|anything in targets
	if(!selection)
		return
	target = selection

/obj/screen/alert/t800_radar/process()
	if(!target)
		icon_state = "t800_blank"
		return
	if(!is_station_level(target.z))
		target = null
		return
	if(target.z > owner.z)
		icon_state = "t800_above"
		return
	if(target.z < owner.z)
		icon_state = "t800_below"
		return
	icon_state = "t800"
	var/turf/here = get_turf(owner)
	var/turf/there = get_turf(target)
	setDir(get_dir(here, there))