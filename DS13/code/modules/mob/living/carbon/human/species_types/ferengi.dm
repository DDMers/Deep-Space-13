/datum/species/ferengi
	name = "Ferengi"
	id = "ferengi"
	default_color = "873d18"
	exotic_blood = null
	species_traits = list(EYECOLOR,LIPS)
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS //Ew human food
	liked_food = RAW | JUNKFOOD
	attack_verb = "thwacks"

/mob/living/carbon/human/species/ferengi
	race = /datum/species/ferengi

/datum/species/ferengi/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	addtimer(CALLBACK(src, .proc/give_language, C), 15)
	C.verbs += /mob/living/carbon/human/proc/rules_of_acquisition
	C.dna.add_mutation(/datum/mutation/human/ferengi)
	if(!C.client) //Admin spawned ferengi need names too.
		var/new_name = random_name()
		C.real_name = new_name
		C.name = new_name

/mob/living/carbon/human/proc/rules_of_acquisition()
	set name = "Recall the rules of acquisition"
	set desc = "Turn to the rules of acquisition for some advice on how to get rich."
	set category = "Ferengi"
	var/count = 0 //For counting the rules
	for(var/line in world.file2list("strings/rules_of_acquisition.txt"))
		if(!line)
			continue
		count ++
		var/text = "[count]: [line]"
		to_chat(usr, "<span class='notice'>[text]</span>")

/datum/mutation/human/ferengi
	name = "Ferengi"
	desc = "Causes the victim to constantly think about profit."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>You feel greedy.</span>"
	text_lose_indication = "<span class='notice'>You feel like money can't buy you happiness.</span>"

/datum/mutation/human/ferengi/say_mod(message)
	if(message)
		message = replacetext(message,"money","gold pressed latinum")
		message = replacetext(message,"credits","gold pressed latinum")
		message = replacetext(message,"cash","gold pressed latinum")
		message = replacetext(message,"space cash","gold pressed latinum")
		message = replacetext(message,"space money","gold pressed latinum")
	return message

/datum/mutation/human/ferengi/get_spans()
	return list(SPAN_PAPYRUS)

/datum/species/ferengi/proc/give_language(mob/living/carbon/C)
	C.grant_language(/datum/language/ferengi)
	to_chat(C, "<font size=4 color=red>You are a ferengi! Your only goal in life is the acquisition of wealth. To this end, you should go to extreme lengths to get richer as long as you're not breaking server rules. If in doubt, follow the rules of acquisition (use the ferengi verb tab).</font>")
	var/datum/language_holder/H = C.get_language_holder()
	H.omnitongue = TRUE

/datum/species/ferengi/qualifies_for_rank(rank, list/features)
	return TRUE	//We ain't racist

/datum/language/ferengi
	name = "ferengi"
	desc = "A language with over 178 different words for rain"
	speech_verb = "snarls"
	whisper_verb = "hints"
	ask_verb = "questions"
	exclaim_verb = "declares"
	key = "F"
	flags = TONGUELESS_SPEECH
	default_priority = 90
	icon_state = "ferengi"
	syllables = list(
		"Yo", "P", "p", "s", "N", "Nah", "Je", "Ho", "Fo", "bb", "en", "ing",
		"ng", "o", "p", "q", "Q", "r", "S", "t", "tlh", "u", "v", "w",
		"y", "'", "reh", "B", "s", "h", "G", "O", "P", "ul","P"
	)

GLOBAL_LIST_INIT(ferengi_names, world.file2list("strings/names/ferengi.txt"))

/datum/species/ferengi/random_name()
	var/randname = random_unique_ferengi_name()
	return randname

/proc/random_unique_ferengi_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(ferengi_name())
		if(!findname(.))
			break

/proc/ferengi_name()
	return "[pick(GLOB.ferengi_names)]"

