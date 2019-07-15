//People with worm things inside them! It' literally that shit from stargate//
//The trill symbiont can be transferred between corpses just fine, even when its host dies//
//The trill symbiont is pooled from ghosts, the trill host can request a ghost to come play their trill too//

GLOBAL_LIST_INIT(trill_surnames, list("Aat","Tex","Dax","Jax","Kahn","Odan","Belar","Brota", "Tigan", "Tigris", "Vistaya", "Timor", "Tovin", "Kora", "Salid", "Tovid","Box", "Bax", "Max", "Jobel", "Vixar", "Vax", "Var", "Nax", "Prax", "Ax", "Lad"))

/datum/species/trill
	name = "Trill"
	id = "trill"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None", "hair" = "bowl")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW

/mob/living/simple_animal/trill_symbiont
	name = "trill" //They get a random name. When they go in a host,
	desc = "An ancient creature which is considered sacred by the trill race. If you find one of these, the federation urges you to keep it safe."
	icon_state = "trill"
	icon_living = "trill"
	icon_dead = "trill_dead"
	gender = NEUTER
	health = 50
	maxHealth = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = 1
	stat_attack = DEAD
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("trills")
	ventcrawler = VENTCRAWLER_ALWAYS

/mob/living/simple_animal/trill_symbiont/Initialize()
	. = ..()
	if(!GLOB.trill_surnames.len)
		name = "Dax"
		message_admins("All trill surnames used up, contact a coder please :)")
		return
	name = pick_n_take(GLOB.trill_surnames) //NO DUPLICATE TRILLS REEE

/mob/living/carbon/human/species/trill
	race = /datum/species/trill

/datum/species/trill/qualifies_for_rank(rank, list/features)
	return TRUE	//The federation isn't racist

/datum/species/trill/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	addtimer(CALLBACK(src, .proc/special_after_spawn, C), 30)

/datum/species/trill/proc/special_after_spawn(mob/living/carbon/C)
	to_chat(C, "<font size=3 color=green>You are a trill! You don't need to act in a specific way, but remember that you carry a precious symbiont containing the knowledge of hundreds of previous hosts.</font>")
	get_symbiont(C)

/datum/species/trill/proc/get_symbiont(mob/living/carbon/C) //Make the fucking worm thing
	var/mob/living/simple_animal/trill_symbiont/dax = new(src)