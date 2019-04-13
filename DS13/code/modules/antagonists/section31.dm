/datum/antagonist/section31
	name = "Section 31 Agent"
	roundend_category = "Section 31 Agents"
	antagpanel_category = "Section 31 Agent"
	job_rank = ROLE_SECTION31
	antag_moodlet = /datum/mood_event/focused
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/section31/on_gain()
	owner.special_role = ROLE_SECTION31
	equip_op()
	..()

/datum/antagonist/section31/proc/equip_op()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current

	H.set_species(/datum/species/human) // All Section 31 members seen so far are human.
	H.grant_language(/datum/language/codespeak)
	H.equipOutfit(/datum/outfit/section31)
	return TRUE

/datum/antagonist/section31/on_removal()
	if(!owner.current)
		return ..()
	to_chat(owner.current,"<span class='userdanger'>You have been deactivated, and are no longer a section 31 agent!</span>")
	var/mob/living/carbon/human/H = owner.current
	owner.special_role = null
	H.remove_language(/datum/language/codespeak)
	..()

/datum/antagonist/section31/greet()
	SEND_SOUND(owner.current, 'DS13/sound/effects/section31_anthem.ogg') //Sound by Revkor on youtube: https://www.youtube.com/watch?v=xUkSVM6tc6M
	give_codewords()
	to_chat(owner.current, "<B><font size=3 color=cyan>You are a [owner.special_role]! A highly trained agent operating in absolute secrecy.</font></B>")
	to_chat(owner.current, "<font size=2 color=cyan>https://en.wikipedia.org/wiki/Section_31</font>")
	to_chat(owner.current, "<font size=2 color=cyan>You are here under best interests of the higher echelons of Starfleet Command, we operate under what is known as Section 31.</font>")
	to_chat(owner.current, "<font size=2 color=cyan>You are allowed to kill, torture and maim in the interests of your objectives. But remember that the crew of the [station_name()] are your allies. You are equipped with several nonlethal options for dealing with your comrades.</font>")
	to_chat(owner.current, "<font size=2 color=cyan>No one of any authority is permitted to interfere with your objectives, complete them at all costs. Do not allow yourself to be captured. To this effect you are armed with a cyanide pill and an explosive implant. Remove all nuisances and potential threats to yourself and the Federation by any means necessary.</font>")
	var/datum/objective/O = new /datum/objective/survive() //Change this later
	O.owner = owner
	objectives += O
	owner.announce_objectives()

/datum/antagonist/section31/proc/update_section31_icons_added(datum/mind/section31_mind)
	var/datum/atom_hud/antag/section31hud = GLOB.huds[ANTAG_HUD_TRAITOR]
	section31hud.join_hud(owner.current)
	set_antag_hud(owner.current, "Section 31")

/datum/antagonist/section31/proc/update_section31_icons_removed(datum/mind/section31_mind)
	var/datum/atom_hud/antag/section31hud = GLOB.huds[ANTAG_HUD_TRAITOR]
	section31hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

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

/obj/item/storage/box/section31
	name = "box of syringes"
	desc = "A box full of syringes."
	illustration = "syringe"

/obj/item/storage/box/section31/combat
	name = "box of spare silver IDs"
	desc = "Shiny IDs for important people."
	illustration = "id"

/obj/item/storage/box/section31/PopulateContents()
	new /obj/item/reagent_containers/pill/cyanide(src)
	new /obj/item/reagent_containers/glass/bottle/chloralhydrate(src)
	new /obj/item/reagent_containers/hypospray(src)
	new /obj/item/reagent_containers/syringe/mulligan(src)
	new /obj/item/reagent_containers/syringe/mulligan(src)

/obj/item/storage/box/section31/combat/PopulateContents()
	new /obj/item/card/emag(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/chameleon(src)
	new /obj/item/clothing/under/trek/section31(src)
	new /obj/item/book/granter/martial/cqc(src)

/datum/outfit/section31
	name = "Section 31 Agent"
	uniform = /obj/item/clothing/under/chameleon/section31
	accessory = /obj/item/clothing/accessory/ds9_jacket
	id = /obj/item/card/id/syndicate
	belt = /obj/item/gun/energy/phaser
	l_pocket = /obj/item/pda
	r_pocket = /obj/item/melee/classic_baton/telescopic
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/jackboots
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(/obj/item/storage/box/syndie_kit/chameleon=1,/obj/item/storage/box/section31=1, /obj/item/storage/box/section31/combat=1)
	implants = list(/obj/item/implant/explosive, /obj/item/implant/mindshield, /obj/item/implant/freedom)

/obj/item/clothing/under/chameleon/section31
	name = "Black leather turtleneck"
	desc = "A armour laced black turtleneck made of leather. It bears no inscriptions or markings whatsoever"
	icon = 'DS13/icons/obj/clothing/uniforms.dmi'
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "section31"
	item_color = "section31"
	item_state = "bl_suit"
	armor = list("melee" = 20, "bullet" = 10, "laser" = 20,"energy" = 20, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 40)

/datum/outfit/section31/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.access = get_all_accesses()
	W.access += get_centcom_access("Admiral")