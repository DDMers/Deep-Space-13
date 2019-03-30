/datum/species/klingon
	name = "Klingon"
	id = "klingon"
	default_color = "FFFFFF"
	exotic_blood = null
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = JUNKFOOD | FRIED //PEH'TAQ, WE EAT OUR MEAT RAW
	liked_food = GROSS | RAW
	attack_verb = "smash"
	armor = 1 //Klingons strong
	hair_color = "110909" //They have black / dark brown hair.

/mob/living/carbon/human/species/klingon
	race = /datum/species/klingon

/datum/species/klingon/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	addtimer(CALLBACK(src, .proc/give_language, C), 15)
	if(C.client)
		if(C.client.prefs.real_name) //Random name if this isnt their chosen name
			C.real_name = C.client.prefs.real_name
			return
	var/new_name = random_name()
	C.real_name = new_name
	C.name = new_name

/datum/species/klingon/proc/give_language(mob/living/carbon/C)
	C.grant_language(/datum/language/klingon)
	to_chat(C, "<font size=4 color=red>You are playing a roleplay heavy race! As a Klingon, you should be aggressive and short tempered, you despise romulans and tribbles in particular.</font>")
	var/datum/language_holder/H = C.get_language_holder()
	H.omnitongue = TRUE

/datum/species/klingon/qualifies_for_rank(rank, list/features)
	return TRUE	//Dog! A Klingon qualifies for any job a human does!

/datum/language/klingon
	name = "klingon"
	desc = "tlhIngan maH!, Heghlu'meH QaQ jajvam."
	speech_verb = "yells"
	whisper_verb = "shouts"
	ask_verb = "scoffs"
	exclaim_verb = "roars"
	key = "K"
	flags = TONGUELESS_SPEECH
	default_priority = 90
	icon_state = "klingon"
	syllables = list(
		"a", "b", "ch", "D", "e", "gh", "H", "I", "j", "l", "m", "n",
		"ng", "o", "p", "q", "Q", "r", "S", "t", "tlh", "u", "v", "w",
		"y", "'", "reh", "B", "s", "h", "G", "O", "P", "ul","P"
	)

GLOBAL_LIST_INIT(klingon_names, world.file2list("strings/names/klingon.txt"))

/datum/species/klingon/random_name()
	var/randname = random_unique_klingon_name()
	return randname

/proc/random_unique_klingon_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(klingon_name())
		if(!findname(.))
			break

/proc/klingon_name()
	return "[pick(GLOB.klingon_names)]"

