//People with worm things inside them! It' literally that shit from stargate//
//The trill symbiont can be transferred between corpses just fine, even when its host dies//
//The trill symbiont is pooled from ghosts, the trill host can request a ghost to come play their trill too//

GLOBAL_LIST_INIT(trill_surnames, list("Aat","Tex","Dax","Jax","Kahn","Odan","Belar","Brota", "Tigan", "Tigris", "Vistaya", "Timor", "Tovin", "Kora", "Salid", "Tovid","Box", "Bax", "Max", "Jobel", "Vixar", "Vax", "Var", "Nax", "Prax", "Ax", "Lad", "Velkoz", "Rhi", "Rhys", "Zac", "Mar"))

/datum/species/trill
	name = "Trill"
	id = "trill"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None", "hair" = "bowl")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW

/obj/item/organ/body_egg/trill
	name = "Trill symbiont"
	desc = "A small creature which bonds to a host with a form of symbiosis. These creatures are sacred to the trill race and must be preserved at ALL costs."
	zone = BODY_ZONE_CHEST
	slot = "trill"
	icon_state = "trill"
	var/mob/living/trill/player = null //The player who's able to speak

/obj/item/organ/body_egg/trill/proc/get_player()
	if(!player)
		player = new(src)
	if(!owner)
		return FALSE
	var/poll_message = "Do you want to play as [owner]'s trill symbiont?"
	var/list/mob/dead/observer/candidates = pollCandidatesForMob(poll_message, ROLE_PAI, null, FALSE, 100, M)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		to_chat(M, "Your mob has been taken over by a ghost!")
		message_admins("[key_name_admin(C)] has taken control of ([ADMIN_LOOKUPFLW(M)])")
		ghostize(0)
		player.key = C.key
		after_spawn()
		return TRUE
	else
		return FALSE

/obj/item/organ/body_egg/trill/proc/after_spawn()
	if(!player)
		return
	to_chat(player, "<span class='warning'>You are a trill symbiont!. While you can't directly speak, you can use the communicate verb in the trill tab to speak to your host privately. You have been bonded to several other previous hosts, and should be experienced and knowledgeable in most things.</span>")

/obj/item/organ/body_egg/trill/Initialize()
	. = ..()
	if(!owner)
		return
	if(!GLOB.trill_surnames.len)
		name = "Dax"
		message_admins("All trill surnames used up, contact a coder please :)")
		return
	var/prefix = owner.first_name()
	name = pick_n_take(GLOB.trill_surnames)
	player.name = name
	owner.name = "[prefix] [name]" //EG. Johar Ez becomes Johar Dax when they get their symbiont registered.
	to_chat(owner, "<span class='notice'>You can feel your symbiont awaken! You are now joined with [name] and share their timeless knowledge!</span>")
	to_chat(player, "<span class='notice'>You awaken. You have been joined with [owner.first_name()]!. You are there to guide them, let them make use of your endless experience and knowledge.</span>")

/obj/item/organ/body_egg/trill/Insert(mob/living/carbon/M) //Set the mob's owner so that it can communicate.
	if(player)
		player.owner = M
	. = ..()

/obj/item/organ/body_egg/trill/Remove(mob/living/carbon/M, special = 0) //Remove the mob's owner, making them unable to speak.
	if(player)
		player.owner = null
	. = ..()

/mob/living/trill //The actual trill holder mob
	name = "Trill"
	desc = "If you see this, call a coder immediately."
	see_in_dark = 5 //Enhanced vision
	AIStatus = AI_OFF

/mob/living/trill/can_speak_vocal(message)
	return FALSE //They can't speak. Only telepathy.

/mob/living/trill/Move()
	return FALSE

/mob/living/carbon/human/species/trill
	race = /datum/species/trill

/datum/species/trill/qualifies_for_rank(rank, list/features)
	return TRUE	//The federation isn't racist

/datum/species/trill/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	addtimer(CALLBACK(src, .proc/special_after_spawn, C), 30)
	C.verbs += trill_summon

/mob/living/carbon/human/proc/trill_summon()
	set name = "Awaken your trill symbiont"
	set desc = "Attempt to awaken your trill symbiont, gaining countless years of experience."
	var/obj/item/organ/body_egg/trill/dax = locate(/obj/item/organ/body_egg/trill) in internal_organs
	if(!dax || !istype(dax))
		to_chat(usr, "You lack a trill symbiont. Go get one installed.")
		return
	if(dax.get_player())
		usr.verbs -= src

/datum/species/trill/proc/special_after_spawn(mob/living/carbon/C)
	to_chat(C, "<font size=3 color=green>You are a trill! You don't need to act in a specific way, but remember that you carry a precious symbiont containing the knowledge of hundreds of previous hosts.</font>")
	get_symbiont(C)

/datum/species/trill/proc/get_symbiont(mob/living/carbon/C) //Make the fucking worm thing
	var/mob/living/simple_animal/trill_symbiont/dax = new(src)