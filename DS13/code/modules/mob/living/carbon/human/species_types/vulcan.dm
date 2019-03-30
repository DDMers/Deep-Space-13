GLOBAL_LIST_INIT(vulcan_names, world.file2list("strings/names/vulcan.txt"))

/datum/species/vulcan
	name = "Vulcan"
	id = "vulcan"
	default_color = "FFFFFF"
	exotic_blood = "romulanblood"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None", "hair" = "bowl")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW

/mob/living/carbon/human/species/vulcan
	race = /datum/species/vulcan

/datum/species/vulcan/qualifies_for_rank(rank, list/features)
	return TRUE	//The federation isn't racist

/datum/species/vulcan/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	addtimer(CALLBACK(src, .proc/special_after_spawn, C), 30)

/datum/species/vulcan/proc/special_after_spawn(mob/living/carbon/C)
	to_chat(C, "<font size=3 color=green>You are playing a roleplay heavy race! As a vulcan you must show no emotion at all.</font>")
	SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "vulcan", /datum/mood_event/vulcan)

/datum/species/vulcan/random_name()
	var/randname = random_unique_vulcan_name()
	return randname

/proc/random_unique_vulcan_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(vulcan_name())
		if(!findname(.))
			break

/proc/vulcan_name()
	return "[pick(GLOB.vulcan_names)]"

/datum/mood_event/vulcan
	description = "<span class='nicegreen'>Emotions are illogical, my mind is a temple.</span>\n" //Used for syndies, nukeops etc so they can focus on their goals
	mood_change = 0
	hidden = FALSE