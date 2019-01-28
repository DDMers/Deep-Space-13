GLOBAL_DATUM_INIT(borg_collective, /datum/borg_collective, new)

/datum/borg_collective
	var/name = "Collective node 01"
	var/list/drones = list() //Who's a borg? You're a borg!
	var/last_alert = 0 //At what %age completion did we last alert our drones? Do we value our drones' hearing?

/datum/borg_collective/proc/message_collective(var/what, var/who) //Both as strings, please!
	if(!who)
		who = "Unknown"
	for(var/mob/living/S in drones)
		if(!S || !istype(S))
			continue
		to_chat(S, "<font color='#19CF44'>[who]: [what]</font>")

/datum/borg_collective/proc/send_sound_collective(var/sound)
	for(var/mob/living/S in drones)
		if(!S || !istype(S))
			continue
		SEND_SOUND(S, sound)

/datum/borg_collective/proc/check_completion()
	var/converted = drones.len //%age of people on the station who are borg'd
	var/targets = 0
	for(var/mob/living/player in GLOB.player_list)
		if(player.stat != DEAD)
			if(!player.client)
				continue //No AFKS because we can't actually borgify them.
			if(player.onCentCom())
				continue
			else if(player.onSyndieBase())
				continue
			targets ++
	converted = CLAMP(converted, 0, targets)
	var/rounded = round(((converted / targets) * 100), 10)
	switch(rounded)
		if(10 to 20)
			if(last_alert >= 1)
				return
			send_sound_collective('DS13/sound/effects/borg/progress/10.ogg')
			last_alert = 1
		if(40 to 50)
			if(last_alert >= 2)
				return
			send_sound_collective('DS13/sound/effects/borg/progress/40.ogg')
			last_alert = 2
		if(51 to 60)
			if(last_alert >= 3)
				return
			send_sound_collective('DS13/sound/effects/borg/progress/60.ogg')
			last_alert = 3
		if(70 to 100)
			if(last_alert >= 4)
				return
			send_sound_collective('DS13/sound/effects/borg/progress/70.ogg')
			last_alert = 4
		if(75 to 100)//75% of the station converted is a win for me
			SSticker.mode.check_finished(TRUE)
			SSticker.force_ending = 1
			to_chat(world, "<span_class='ratvar'The borg have assimilated the station!/span>")
			SEND_SOUND(world,'DS13/sound/effects/borg/progress/victory.ogg')


/turf/closed/wall/trek_smooth/borg
	name = "Assimilated wall"
	desc = "An oddly tinted wall with bits of metal, piping and green lights all over it."
	mod = null
	icon = 'DS13/icons/turf/trek_wall_borg.dmi'
	icon_state = "0"
	sheet_type = /obj/item/stack/sheet/metal
	light_color = LIGHT_COLOR_GREEN

/turf/open/floor/plating/borg
	name = "Assimilated plating"
	desc = "It glows with a green light...This can't be good."
	icon = 'DS13/icons/turf/floors.dmi'
	icon_state = "borg"

/obj/effect/mob_spawn/human/alive/trek/borg
	name = "borg drone"
	assignedrole = "borg drone"
	outfit = /datum/outfit/borg

/datum/outfit/borg
	name = "borg drone"
	glasses = /obj/item/clothing/glasses/night/borg
	uniform =  /obj/item/clothing/under/abductor
	suit = /obj/item/clothing/suit/space/borg
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet/space/borg
	l_hand = /obj/item/borg_tool
	mask = /obj/item/clothing/mask/gas/borg
	belt = /obj/item/storage/belt/utility/full/engi

/datum/outfit/borg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	var/possible_names1 = list("First of","Second of","Third of","Fourth of","Five of","Six of","Seven of","Eight of","Nine of","Ten of","Eleven of","Twelve of","Thirteen of","Fourteen of","Fifteen of")
	var/possible_names2 = list("one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen")
	H.real_name = pick(possible_names1)+" "+pick(possible_names2)
	H.name = H.real_name

/datum/action/item_action/futile
	name = "resistance is futile!"

/datum/action/item_action/futile/Trigger()
	var/obj/item/clothing/mask/gas/borg/FT = target
	if(istype(FT))
		FT.futile()
	return ..()

//Items, from top to bottom

/obj/item/clothing/head/helmet/space/borg
	name = "cranial prosthesis"
	desc = "Starfleet medical research states that borg implants can cause severe irritation, perhaps an analgesic cream would fix the constant itching this prosthetic causes?"
	icon_state = "hostile_env"
	item_state = null
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	item_flags = ABSTRACT | NODROP | STOPSPRESSUREDAMAGE

/obj/item/clothing/mask/gas/borg
	name = "borg mask"
	desc = "A built in respirator that covers our face. Alt click or CTRL click it to play a sound."
	icon = 'DS13/icons/obj/masks.dmi'
	icon_state = "borg"
	item_state = null
	siemens_coefficient = 0
	item_flags = NODROP | MASKINTERNALS
	var/cooldown2 = 60 //6 second cooldown
	var/saved_time = 0
	actions_types = list(/datum/action/item_action/futile)

/obj/item/clothing/mask/gas/borg/AltClick(mob/user)
	futile()

/obj/item/clothing/mask/gas/borg/CtrlClick(mob/user)
	futile()

/obj/item/clothing/mask/gas/borg/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/futile)
		futile(user)

/obj/item/clothing/mask/gas/borg/proc/futile()
	if(world.time >= saved_time + cooldown2)
		saved_time = world.time
		var/sound = pick('DS13/sound/effects/borg/withstandassault.ogg','DS13/sound/effects/borg/dontresist.ogg')
		var/phrase_text = "Resistance is futile."
		src.audible_message("<font color='green' size='4'><b>[phrase_text]</b></font>")
		playsound(src.loc,sound, 100, 0, 4)

/obj/item/clothing/glasses/night/borg
	name = "occular implant"
	desc = "A cyborg eye linked directly to our brain allowing for massively enhanced vision. They are extremely light sensitive."
	icon_state = "godeye"
	item_state = null
	vision_flags = SEE_MOBS
	darkness_view = 8
	invis_view = 2
	flash_protect = -1
	resistance_flags = FIRE_PROOF | ACID_PROOF
	item_flags = ABSTRACT | NODROP
	alpha = 0

/obj/item/clothing/suit/space/borg
	name = "borg exoskeleton"
	desc = "A heavily armoured exoskeletal system held in place via multiple attachment points which are embedded painfully into the skin."
	icon = 'DS13/icons/obj/suits.dmi'
	alternate_worn_icon = 'DS13/icons/mob/suit.dmi'
	icon_state = "borg"
	item_state = null
	body_parts_covered = FULL_BODY
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	slowdown = 3
	item_flags = NODROP | ABSTRACT | THICKMATERIAL | STOPSPRESSUREDAMAGE
	armor = list(melee = 40, bullet = 5, laser = 5, energy = 0, bomb = 15, bio = 100, rad = 70) //they can't react to bombs that well, and emps will rape them
	resistance_flags = FIRE_PROOF
	allowed = list(/obj/item/flashlight)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/space/borg/Initialize()
	. = ..()
	icon_state = "borg[pick(1,2)]"