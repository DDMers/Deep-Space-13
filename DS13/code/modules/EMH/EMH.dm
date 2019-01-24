GLOBAL_LIST_INIT(EMH_blacklist, list())

//EMITTER

/obj/machinery/emh_emitter
	name = "Emergency medical hologram emitter"
	desc = "Simply click this device and an emergency medical hologram will be summoned. Swipe it with a high level ID to terminate the current EMH if it's misbehaving."
	icon = 'DS13/icons/obj/decor/wall_decor.dmi'
	icon_state = "emh-off"
	anchored = TRUE
	density = FALSE
	pixel_y = 32 //Put on the tile below a wall etc etc modular fun time mapping mayhem
	var/range = 10 //10 tiles? Pretty damn generous.
	var/mob/living/carbon/human/species/holographic/emh
	req_access = list(ACCESS_HEADS)
	var/locked = FALSE //Cooldown to prevent spam

/obj/machinery/emh_emitter/Initialize()
	. = ..()
	START_PROCESSING(SSmachines,src)
	var/area/A = get_area(src) //Unmovable
	name = "EMH emitter ([A])"

/obj/machinery/emh_emitter/proc/EMH_present()
	var/mob/living/carbon/human/species/holographic/S = locate(/mob/living/carbon/human/species/holographic) in GLOB.alive_mob_list
	if(istype(S) && !QDELETED(S))
		return TRUE
	else
		return FALSE

/obj/machinery/emh_emitter/examine(mob/user)
	. = ..()
	if(EMH_present())
		if(emh.client)
			to_chat(user, "<i>The panel shows that there is an active EMH on the network.</i>")
		else
			to_chat(user, "<i>The panel shows that there is an EMH on the network, but it is not responding (braindead). Click the panel to summon a new one.</i>")

/client/proc/editemhblacklist()
	set name = "Edit EMH blacklist"
	set desc = "Remove people from the EMH blacklist for this round."
	set category = "Admin"
	if(!check_rights(R_ADMIN, TRUE)) //We may want to change this to R_VAREDIT when we launch but for now I'd quite like mentors to have this too.
		return
	var/A
	var/list/temp = GLOB.EMH_blacklist.Copy()
	temp += "cancel" //To stop the input only having one option, which makes byond freak out.
	A = input("Remove whom from the blacklist?", "Admin tools", A) as null|anything in GLOB.EMH_blacklist
	if(!A)
		return
	if(A in GLOB.EMH_blacklist)
		GLOB.EMH_blacklist -= A
	log_admin("([worldtime2text()]):[src] / [key] removed [A] from the EMH blacklist for this round.")

/obj/machinery/emh_emitter/attackby(obj/I,mob/user)
	. = ..()
	if(!user.client)
		return
	var/obj/item/card/id/ID = I
	if(ID && istype(ID))
		if(check_access(ID))
			var/question = alert("Terminate the current EMH? (this kills the current EMH)",name,"yes","no")
			var/blacklist = alert("Blacklist the current EMH player for the duration of this round? ",name,"yes","no")
			if(question == "yes")
				if(!emh)
					emh = locate(/mob/living/carbon/human/species/holographic) in GLOB.alive_mob_list
				if(emh.client && emh.client.key && blacklist == "yes")
					GLOB.EMH_blacklist += emh.client.key
					to_chat(emh, "<span_class='boldnotice'>[user] has blacklisted you from becoming an EMH for the duration of this round! If you feel this was in error, please ahelp immediately.")
					log_game("[user] just blacklisted [emh.client.key] from becoming an EMH for the rest of the round")
				if(emh)
					emh.death()//Kill the emh.
					emh = null
				else
					to_chat(user, "Unable to locate an EMH on the network.")

/obj/machinery/emh_emitter/Destroy()
	if(emh)
		var/obj/machinery/emh_emitter/saveme = locate(/obj/machinery/emh_emitter) in GLOB.machines
		if(saveme)
			to_chat(emh, "The emitter you were using has been destroyed, your program has been transferred to avoid corruption.")
			saveme.activate(emh)
		else
			to_chat(emh, "The emitter you were using was destroyed! Your program could not be shunted to another emitter and will be shut down to avoid damage.")
			qdel(emh)
			emh = null
	STOP_PROCESSING(SSmachines,src)
	. = ..()

/obj/machinery/emh_emitter/proc/remove_cooldown()
	locked = FALSE

/obj/machinery/emh_emitter/attack_hand(mob/user)
	if(istype(user, /mob/living/carbon/human/species/holographic)) //Allow them to jump to different locs.
		emh_jumpto(user)
		return
	if(locked)
		to_chat(user, "Unable to comply, interface cooldown in effect.")
		return
	if(is_occupied()) //If we have an EMH, or there is an EMH in the world
		to_chat(user, "There is already an EMH active, summon it?")
		var/question = alert("Summon an EMH?",name,"yes","no")
		locked = TRUE
		addtimer(CALLBACK(src, .proc/remove_cooldown), 30) //Add timer to cooldown
		if(question == "yes")
			var/mob/living/carbon/human/species/holographic/S = locate(/mob/living/carbon/human/species/holographic) in GLOB.alive_mob_list
			if(S)
				var/emhconsent = alert(S, "You have been summoned by [user] in [get_area(src)]. Transfer to their location?",name,"accept","reject")
				if(emhconsent == "accept")
					activate(S)
					user.say("Computer, transfer emergency medical holographic program to [get_area(src)]")
				else
					to_chat(user, "The EMH has declined your summons.")
					return ..()
	else
		locked = TRUE
		addtimer(CALLBACK(src, .proc/remove_cooldown), 30) //Add timer to prevent spam clicking
		if(emh)
			emh.death()
		if(user)
			user.say("Computer, activate emergency medical hologram")
			to_chat(user, "Attempting to activate EMH ((This requires a ghost willing to control it...))")
		activate(null) //No EMH present, try to make one!

/obj/machinery/emh_emitter/proc/emh_jumpto(mob/living/user)
	var/list/jumplocs = list()
	for(var/obj/machinery/emh_emitter/EM in GLOB.machines)
		if(istype(EM))
			jumplocs += EM
	var/A
	A = input(user,"Transfer program to where?", "EMH subsystem", A) as null|anything in jumplocs
	if(!A)
		return
	user.say("Computer, transfer emergency medical holographic program to [get_area(A)]")
	new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(user), user.dir)
	user.forceMove(get_turf(A))
	playsound(user.loc, 'DS13/sound/effects/holofizzle.ogg', 100, 0)
	var/obj/machinery/emh_emitter/S = A
	emh = null
	S.emh = user //transfer silently.


/obj/machinery/emh_emitter/process()
	if(!emh || !is_occupied()) //If we don't have an EMH, no need to process
		return
	if(QDELETED(emh)) //Same goes here
		emh = null
		icon_state = "emh-off"
		return
	icon_state = "emh-on" //Well we have an EMH, let's check if he's nearby
	if(get_dist(emh, src) >= range || emh.z != z) //Out of range, try find the EMH another emitter or tele him back to us.
		var/obj/machinery/emh_emitter/closest = null //Find our closest distance
		var/closest_dist = 10 //Distance of closest emitter
		for(var/obj/machinery/emh_emitter/em in GLOB.machines)
			if(em == src || !emh in orange(em, em.range))
				return
			if(get_dist(emh, em) <= closest_dist && em.z == emh.z)
				closest = em
				closest_dist = get_dist(emh, em)
		if(closest)
			closest.emh = emh //Transfer his program seamlessly
			emh = null
			closest.icon_state = "emh-on"
			icon_state = "emh-off"
		else
			to_chat(emh, "You cannot move beyond the range of your holo-emitters!")
			emh.forceMove(get_turf(src))

/obj/machinery/emh_emitter/proc/activate(var/mob/living/carbon/human/species/holographic/transferred = null) //Activate, if we're not transferring an existing EMH over, then make a new one!
	if(transferred)
		emh = transferred
		new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(emh), emh.dir)
		transferred.forceMove(get_turf(src))
		to_chat(transferred, "You have been transferred to [get_area(src)]")
		emh.say("Please state the nature of the medical emergency.")
		playsound(loc, 'DS13/sound/effects/medicalemergency.ogg', 50, 0)
		return
	if(is_occupied())
		say("Unable to comply, there is already an EMH active on the network.")
		return
	if(emh) //AFK emh can get replaced with a live one!
		qdel(emh)
	emh = new /mob/living/carbon/human/species/holographic(get_turf(src)) //Please state th-
	emh.name = "Emergency Medical Hologram"
	emh.real_name = "Emergency Medical Hologram"
	emh.alpha = 0 //So that it "pops" out of nowhere with a mind in it, or else it deletes
	emh.equipOutfit(/datum/outfit/emh)
	offer_control_emh(emh)
	if(emh.client && emh.mind) //Hitchiking off of this until I can make a new jobban
		emh.say("Please state the nature of the medical emergency.")
		emh.hair_style = random_hair_style(emh.gender)
		playsound(loc, 'DS13/sound/effects/medicalemergency.ogg', 50, 0)
		emh.alpha = 255
		new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(emh), emh.dir)
		var/datum/browser/popup = new(emh, "EMH rules", "EMH rules") // Pop up the rules so they can't be ignored
		var/s = "<h1> -=ALL PAST LIVES ARE FORGOTTEN=- </h1> <br>\
		<h2> You are an emergency medical hologram! </h2>\
		<p> <b> -You are a holographic program designed to give emergency medical treatment. You are well versed in surgery and medical practice</b>\
		<ul>\
		<li> You must not intentionally harm another living creature</li>\
		<li> You may perform surgery to save lives however, in a conflict: prefer saving the lives of a human over another organism </li>\
		<li> The captain has the power to delete you and blacklist you from being an EMH for the duration of the shift if you misbehave!</li>\
		<li> You are a hologram, not a person! Do not expect the same rights as people. If you must die to save a life, you must sacrifice yourself </li>\
		<li> You must not put the security of the ship / station in danger, you are free to take reasonable risk </li>\
		<li> If you have any further questions, please ahelp! </li>\
		</ul>"
		popup.set_title_image(emh.browse_rsc_icon(src.icon, src.icon_state))
		popup.set_content(s)
		popup.open()
	else
		qdel(emh)
		say("Unable to comply, could not activate EMH")

/proc/offer_control_emh(mob/M) //Specialist proc to check they've not been blacklisted by the captain from being an EMH
	var/poll_message = "Do you want to play as an emergency medical hologram?"
	var/list/mob/dead/observer/candidates = pollCandidatesForMob(poll_message, ROLE_EMH, null, FALSE, 100, M)
	for(var/mob/dead/observer/S in candidates)
		if(S.key in GLOB.EMH_blacklist)
			candidates -= S
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		to_chat(M, "Your mob has been taken over by a ghost!")
		message_admins("[key_name_admin(C)] has taken control of ([ADMIN_LOOKUPFLW(M)])")
		M.ghostize(0)
		M.key = C.key
		return TRUE


/obj/machinery/emh_emitter/proc/is_occupied()
	var/mob/living/global_emh = null //For deactivation of AFK EMHs
	global_emh = emh
	if(!emh)
		var/mob/living/carbon/human/species/holographic/S = locate(/mob/living/carbon/human/species/holographic) in GLOB.alive_mob_list
		if(istype(S) && !QDELETED(S))
			global_emh = S
	if(global_emh && !QDELETED(global_emh))
		if(global_emh.mind && global_emh.client)
			return TRUE
		else
			return FALSE
	if(EMH_present())
		return TRUE
	return FALSE

//SPECIES AND OUTFIT

/datum/species/holographic
	name = "Hologram"
	id = "hologram" //Because we need an emergency reference (for such like limbs).
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	use_skintones = 1
	skinned_type = null
	species_traits = list(NOBLOOD)
	inherent_traits = list(TRAIT_RADIMMUNE,TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_NOFIRE,TRAIT_PIERCEIMMUNE,TRAIT_NOHUNGER,TRAIT_NODISMEMBER, TRAIT_PACIFISM,TRAIT_POOR_AIM)//EMHs are not programmed to fire weapons / cause harm
	inherent_biotypes = list(MOB_HUMANOID)
	meat = null
	mutantlungs = null
	mutantliver = null
	mutantstomach = null
	brutemod = 2
	heatmod = 2
	breathid = null //You don't need air, you're a hologram.
	damage_overlay_type = ""//You're a hologram, you don't bleed.

/datum/species/holographic/spec_death(gibbed = FALSE, mob/living/carbon/human/H)
	H.unequip_everything() //Don't spawn in as an EMH, rush the spare, then suicide so it deletes
	playsound(H.loc, 'DS13/sound/effects/holofizzle.ogg', 100, 0)
	H.visible_message("[H] fizzles away quietly...")
	qdel(H)
	. = ..()

/mob/living/carbon/human/species/holographic
	race = /datum/species/holographic

/datum/outfit/emh //This gives him some NODROP items so he doesn't spawn naked like the EMHs of yore. The ID has preset access and cannot be removed. If they're being a little shit and greytiding, then ban them / execute them.
	uniform = /obj/item/clothing/under/trek/medsci/ds9/emh
	shoes = /obj/item/clothing/shoes/jackboots/emh
	ears = /obj/item/radio/headset/headset_med/emh
	id = /obj/item/card/id/silver/emh

/obj/item/card/id/silver/emh
	name = "Holographic ID"
	desc = "An ID designed to give an emergency medical hologram access to key areas of the ship."
	icon_state = "silver"
	item_state = "silver_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	registered_name = "Emergency Medical Hologram"
	assignment = "EMH"
	item_flags = NODROP

/obj/item/card/id/silver/emh/Initialize()
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	. = ..()

/obj/item/clothing/shoes/jackboots/emh
	name = "holographic boots"
	item_flags = NODROP

/obj/item/radio/headset/headset_med/emh
	name = "holographic radio headset"
	item_flags = NODROP

/obj/item/clothing/under/trek/medsci/ds9/emh
	name = "holographic uniform"
	icon = 'DS13/icons/obj/clothing/uniforms.dmi' //Modularity, nich would be proud
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "trek_medsci_ds9"
	item_color = "trek_medsci_ds9"
	item_state = "bl_suit"
	item_flags = NODROP