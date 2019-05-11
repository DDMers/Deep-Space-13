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
	nojumpsuit = 1
	stunmod = 0 //Can't be stunned
	speedmod = 3 //pretty fucking slow

/mob/living/carbon/human/species/t800
	race = /datum/species/t800

/obj/item/organ/cyberimp/arm/t800
	name = "eradication toolset"
	desc = "A highly dangerous implant set allowing t-800 model eradication units to hunt down their targets relentlessly."
	contents = newlist(/obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/power, /obj/item/wirecutters/cyborg, /obj/item/multitool/cyborg)

/datum/species/t800/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	..()
	var/obj/item/organ/eyes/E = H.getorganslot(ORGAN_SLOT_EYES)
	E.sight_flags |= SEE_MOBS | SEE_OBJS | SEE_TURFS //Add sight flags to the user's eyes
	E.flash_protect = -1 //Adjust the user's eyes' flash protection
	H.overlay_fullscreen("t800_hud", /obj/screen/fullscreen/t800, 1)
	var/obj/item/organ/cyberimp/arm/t800/stored = new(get_turf(H))
	stored.Insert(H)
	H.AddComponent(/datum/component/redirect, list(COMSIG_MOVABLE_MOVED = CALLBACK(src, .proc/on_mob_move, H))) //Allows it to stomp around when it moves
	H.grant_all_languages(omnitongue=TRUE)
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