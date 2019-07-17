//People with worm things inside them! It' literally that shit from stargate//
//The trill symbiont can be transferred between corpses just fine, even when its host dies//
//The trill symbiont is pooled from ghosts, the trill host can request a ghost to come play their trill too//

GLOBAL_LIST_INIT(trill_surnames, list("Aat","Tex","Dax","Jax","Kahn","Odan","Belar","Brota", "Tigan", "Tigris", "Vistaya", "Timor", "Tovin", "Kora", "Salid", "Tovid","Box", "Bax", "Max", "Jobel", "Vixar", "Vax", "Var", "Nax", "Prax", "Ax", "Lad", "Velkoz", "Rhi", "Rhys", "Zac", "Mar", "Said", "Rhexum", "Pellal", "Muzin", "Mohn", "Maan"))
GLOBAL_LIST_INIT(trill_names, world.file2list("strings/names/trill.txt")) //Trill forename. Surname is inherited from their symbiont (if theyre lucky enough to get one!)

/datum/species/trill
	name = "Trill"
	id = "trill"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None", "hair" = "bowl")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW

/mob/living/carbon/human/species/trill
	race = /datum/species/trill

/obj/item/organ/body_egg/trill
	name = "Trill symbiont"
	desc = "A small creature which bonds to a host with a form of symbiosis. These creatures are sacred to the trill race and must be preserved at ALL costs."
	zone = BODY_ZONE_CHEST
	slot = "trill"
	icon_state = "trill"
	var/mob/living/trill/player = null //The player who's able to speak
	var/name_acquired = FALSE //Have we generated a symbiont, and got their surname? Even if the trill is removed and goes back to sleep, its name persists so you can have multiple "Dax"es.

/obj/item/organ/body_egg/trill/proc/get_player()
	if(!player)
		player = new(src)
	if(!owner)
		return FALSE
	var/poll_message = "Do you want to play as [owner]'s trill symbiont?"
	var/list/mob/dead/observer/candidates = pollCandidatesForMob(poll_message, ROLE_PAI, null, FALSE, 100, player)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		to_chat(player, "Your mob has been taken over by a ghost!")
		message_admins("[key_name_admin(C)] has taken control of ([ADMIN_LOOKUPFLW(player)])")
		player.ghostize(0)
		player.key = C.key
		after_spawn()
		return TRUE
	else
		to_chat(owner, "<span class='notice'>You don't feel any different.. (Failed to find a player for your symbiont)</span>")
		return FALSE

/obj/item/organ/body_egg/trill/proc/after_spawn()
	if(!player)
		return
	to_chat(player, "<span class='warning'>You are a trill symbiont!. While you can't directly speak, you can use the communicate button to speak to your host privately. You have been bonded to several other previous hosts in the past, and should be experienced and knowledgeable in most things.</span>")
	player.owner = owner
	player.forceMove(owner)
	var/prefix = owner.first_name()
	if(!name_acquired)
		if(!GLOB.trill_surnames.len)
			name = "Dax"
			message_admins("All trill surnames used up, contact a coder please :)")
			return
		name = pick_n_take(GLOB.trill_surnames)
		player.name = name
		owner.name = "[prefix] [name]" //EG. Johar Ez becomes Johar Dax when they get their symbiont registered.
		owner.real_name = owner.name
		name_acquired = TRUE //We've got our trill surname now, don't change it if the symbiont goes AFK or dies.
	else
		player.name = name
		owner.name = "[prefix] [name]" //EG. Johar Ez becomes Johar Dax when they get their symbiont registered.
		owner.real_name = owner.name
	to_chat(owner, "<span class='notice'>You can feel your symbiont awaken! You are now joined with [name] and share their invaluable knowledge and experience!</span>")
	to_chat(player, "<span class='notice'>You awaken, your name is [name]. You have been joined with [owner.first_name()]!. You are there to guide them, let them make use of your endless experience and knowledge and the memories of your previous hosts.</span>")
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "trill", /datum/mood_event/trill)

/obj/item/organ/body_egg/trill/Insert(mob/living/carbon/M) //Set the mob's owner so that it can communicate.
	if(player)
		player.owner = M
	M.verbs += /mob/living/carbon/human/proc/trill_summon
	. = ..()

/obj/item/organ/body_egg/trill/Remove(mob/living/carbon/M, special = 0) //Remove the mob's owner, making them unable to speak.
	if(player)
		to_chat(player, "<span class='warning'>Sensing your removal from your host, you go back into hibernation...</span>")
		qdel(player) //Clean up the player mob.
		player = null
	M.verbs -= /mob/living/carbon/human/proc/trill_summon
	to_chat(owner, "<span class='warning>You feel terribly alone...</span>")
	. = ..()

/mob/living/trill //The actual trill holder mob
	name = "Trill"
	desc = "If you see this, call a coder immediately."
	see_in_dark = 5 //Enhanced vision
	var/mob/living/owner = null //To whom are we bonded? We can communicate with them.
	hud_type = /datum/hud/trill

/datum/hud/trill/New(mob/living/trill/current)
	. = ..()
	var/obj/screen/using
	using = new /obj/screen/trill()
	using.screen_loc = "WEST,CENTER+5:27"
	static_inventory += using

/obj/screen/trill
	name = "Communicate"
	desc = "Talk to your current host."
	icon = 'icons/mob/guardian.dmi'
	icon_state = "communicate"

/obj/screen/trill/Click()
	if(istype(usr, /mob/living/trill))
		var/mob/living/trill/dax = usr
		dax.communicate()

/mob/living/trill/proc/communicate()
	if(!owner)
		to_chat(src, "<span class='warning'>You have no host!</span>")
		return
	var/input = sanitize(stripped_input(src, "Please enter a message to tell your host.", "Trill symbiont", ""))
	var/message = "<span class='neovgre'>[name] telepathically transmits, [input]</span>"
	to_chat(owner, message)
	to_chat(src, message)

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
	var/obj/item/organ/body_egg/trill/dax = new(get_turf(C))
	dax.Insert(C)
	addtimer(CALLBACK(src, .proc/special_after_spawn, C), 30)
	if(!C.client) //Admin spawned trill need names too.
		var/new_name = random_name()
		C.real_name = new_name
		C.name = new_name

/mob/living/carbon/human/proc/trill_summon()
	set name = "Awaken your trill symbiont"
	set desc = "Attempt to awaken your trill symbiont, gaining countless years of experience."
	set category = "Trill"
	var/obj/item/organ/body_egg/trill/dax = locate(/obj/item/organ/body_egg/trill) in internal_organs
	if(!dax || !istype(dax))
		to_chat(usr, "You lack a trill symbiont. Go get one installed.")
		return
	if(dax.player && dax.player.client) //Check for an AFK symbiont. If it's AFK you can summon a new one
		to_chat(usr, "Your symbiont is already awake!")
		return
	else
		to_chat(usr, "<span class='notice'>You concentrate, and try to awaken your symbiont...</span>")
		dax.get_player()


/datum/species/trill/random_name()
	var/randname = random_unique_trill_name()
	return randname

/proc/random_unique_trill_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(trill_name())
		if(!findname(.))
			break

/proc/trill_name()
	return "[pick(GLOB.trill_names)]"

/datum/species/trill/proc/special_after_spawn(mob/living/carbon/C)
	to_chat(C, "<font size=3 color=green>You are a trill! Use the trill verb tab to activate your symbiont so you can get the full benefit of this race (this requires a player willing to control it).</font>")

/datum/mood_event/trill
	description = "<span class='nicegreen'>I've been joined - What an honour! My symbiont's experiences are now mine too.</span>\n" //Used for syndies, nukeops etc so they can focus on their goals
	mood_change = 3
	timeout = 3000
