/obj/item/clothing/under/trek/command/ds9
	icon = 'DS13/icons/obj/clothing/uniforms.dmi' //Modularity, nich would be proud
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "trek_command_ds9"
	item_color = "trek_command_ds9"
	item_state = "bl_suit"

/obj/item/clothing/under/trek/engsec/ds9
	icon = 'DS13/icons/obj/clothing/uniforms.dmi' //Modularity, nich would be proud
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "trek_engsec_ds9"
	item_color = "trek_engsec_ds9"
	item_state = "bl_suit"

/obj/item/clothing/under/trek/medsci/ds9
	icon = 'DS13/icons/obj/clothing/uniforms.dmi' //Modularity, nich would be proud
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "trek_medsci_ds9"
	item_color = "trek_medsci_ds9"
	item_state = "bl_suit"

/obj/item/clothing/accessory/ds9_jacket
	name = "uniform jacket"
	desc = "An extremely comfortable jacket with some storage pockets for tools."
	icon = 'DS13/icons/obj/clothing/accessories.dmi'
//	alternate_worn_icon = 'DS13/icons/mob/accessories.dmi' Due to specialist TG shitcode I cannot change this for accessories
	icon_state = "trekjacket"
	item_color = "trekjacket"
	item_state = "trekjacket"

/obj/item/clothing/accessory/ds9_jacket/department/command
	name = "uniform jacket"
	desc = "An extremely comfortable jacket with some storage pockets for tools."
	icon = 'DS13/icons/obj/clothing/accessories.dmi'
	icon_state = "trekjacket_command"
	item_color = "trekjacket_command"
	item_state = "trekjacket_command"

/obj/item/clothing/accessory/ds9_jacket/department/engsec
	name = "uniform jacket"
	desc = "An extremely comfortable jacket with some storage pockets for tools."
	icon = 'DS13/icons/obj/clothing/accessories.dmi'
	icon_state = "trekjacket_engsec"
	item_color = "trekjacket_engsec"
	item_state = "trekjacket_engsec"

/obj/item/clothing/accessory/ds9_jacket/department/medsci
	name = "uniform jacket"
	desc = "An extremely comfortable jacket with some storage pockets for tools"
	icon = 'DS13/icons/obj/clothing/accessories.dmi'
	icon_state = "trekjacket_medsci"
	item_color = "trekjacket_medsci"
	item_state = "trekjacket_medsci"

/obj/item/clothing/accessory/ds9_jacket/formal
	name = "dress jacket"
	desc = "An extremely comfortable jacket laced with gold silk, such a piece is usually reserved for diplomatic occasions."
	icon = 'DS13/icons/obj/clothing/accessories.dmi'
	icon_state = "trekjacket_formal"
	item_color = "trekjacket_formal"
	item_state = "trekjacket_formal"

/obj/item/clothing/accessory/ds9_jacket/formal/captain
	name = "captain's dress jacket"
	desc = "An extremely comfortable jacket laced with gold silk, such a piece is usually reserved for diplomatic occasions. This one is reserved for starship captains and above, and is emblazened with the federation's crest."
	icon = 'DS13/icons/obj/clothing/accessories.dmi'
	icon_state = "trekjacket_captain"
	item_color = "trekjacket_captain"
	item_state = "trekjacket_captain"

/obj/item/clothing/under/trek/neelix
	name = "Civilian clothes"
	desc = "An odd assortment of colours fashioned together into something only a morale officer would wear."
	icon = 'DS13/icons/obj/clothing/uniforms.dmi' //Modularity, nich would be proud
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "neelix"
	item_color = "neelix"
	item_state = "bl_suit"

/obj/item/clothing/under/trek/cadet
	name = "Cadet jumpsuit"
	desc = "A comfortable and practical jumpsuit worn by starfleet officer candidates undergoing training."
	icon = 'DS13/icons/obj/clothing/uniforms.dmi' //Modularity, nich would be proud
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "cadet"
	item_color = "cadet"
	item_state = "bl_suit"

/obj/item/clothing/under/trek/klingon
	name = "Klingon battle uniform"
	desc = "A heavily armour plated uniform worn by the finest Quon'os has to offer. Qap'la!"
	icon = 'DS13/icons/obj/clothing/uniforms.dmi'
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "klingon"
	item_color = "klingon"
	item_state = "bl_suit"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 40)

/obj/item/clothing/under/trek/command/khan
	name = "Antique command uniform"
	desc = "An old uniform worn in the golden era of starfleet by legends such as Admiral James T. Kirk. It is extremely comfortable and shows that you're in charge. Owning one of these means you're in a high place."
	icon = 'DS13/icons/obj/clothing/uniforms.dmi'
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "trek_command_khan"
	item_color = "trek_command_khan"
	item_state = "bl_suit"
	can_adjust = TRUE

/obj/item/clothing/under/trek/admiral
	name = "Admiral's uniform"
	desc = "One of the highest ranks one can achieve in starfleet, the admirals coordinate the fleets of earth and her allies. This uniform is worn by those same people, and is made of extremely comfortable materials."
	icon = 'DS13/icons/obj/clothing/uniforms.dmi'
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "trek_admiral"
	item_color = "trek_admiral"
	item_state = "bl_suit"

/datum/outfit/admiral
	name = "Admiral"
	uniform = /obj/item/clothing/under/trek/admiral
	accessory = null
	l_pocket = /obj/item/pda
	belt = /obj/item/gun/energy/phaser
	shoes = /obj/item/clothing/shoes/jackboots
	suit = null
	gloves = /obj/item/clothing/gloves/color/black
	head = null
	id = /obj/item/card/id
	ears = /obj/item/radio/headset/heads/captain
	back = /obj/item/storage/backpack/satchel

/datum/outfit/admiral/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_centcom_access("Admiral")
	W.assignment = "Admiral"
	W.registered_name = H.real_name
	W.update_label()

/obj/item/clothing/under/trek/romulan
	name = "Romulan"
	desc = "A padded jumpsuit laced with nanoweave armour which is typically worn by officers of the romulan navy."
	icon = 'DS13/icons/obj/clothing/uniforms.dmi'
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "romulan"
	item_color = "romulan"
	item_state = "bl_suit"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 40)

/obj/item/clothing/under/trek/section31
	name = "Black leather turtleneck"
	desc = "A armour laced black turtleneck made of leather. It bears no inscriptions or markings whatsoever"
	icon = 'DS13/icons/obj/clothing/uniforms.dmi'
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "section31"
	item_color = "section31"
	item_state = "bl_suit"
	armor = list("melee" = 20, "bullet" = 10, "laser" = 20,"energy" = 20, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 40)

/obj/item/clothing/under/trek/shuttle
	name = "Starfleet shuttle pilot jumpsuit"
	desc = "A tight fitting but comfortable jumpsuit made of high quality materials. This particular uniform was designed for use by shuttle pilots in intense scenarios where endurance of multiple Gs was necessary. It comes fitted with a torsion system to keep you locked into your seat as well as fire retardant padding designed to extend the lifespan of combat pilots, though it's not designed to be worn for extended periods."
	icon = 'DS13/icons/obj/clothing/uniforms.dmi'
	alternate_worn_icon = 'DS13/icons/mob/uniform.dmi'
	icon_state = "trek_shuttle"
	item_color = "trek_shuttle"
	item_state = "bl_suit"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 10,"energy" = 10, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 10)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/under/trek/shuttle/equipped(mob/user, slot)
	. = ..()
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "tight suit", /datum/mood_event/tight_suit)

/obj/item/clothing/under/trek/shuttle/dropped(mob/user, slot)
	. = ..()
	SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "tight suit", /datum/mood_event/tight_suit)

/datum/mood_event/tight_suit
	description = "<span class='warning'>This jumpsuit sure is tight...</span>\n"
	mood_change = -1

/obj/item/clothing/suit/DS13
	name = "Placeholder"
	icon = 'DS13/icons/obj/suits.dmi'
	alternate_worn_icon = 'DS13/icons/mob/suit.dmi'

/datum/outfit/romulan
	name = "Romulan"
	uniform = /obj/item/clothing/under/trek/romulan
	accessory = null
	l_pocket = /obj/item/pda
	belt = /obj/item/gun/energy/phaser
	shoes = /obj/item/clothing/shoes/jackboots
	suit = null
	gloves = /obj/item/clothing/gloves/color/black
	head = null
	id = /obj/item/card/id
	back = /obj/item/storage/backpack/satchel
	ears = /obj/item/radio/headset/syndicate/alt
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(/obj/item/book/granter/martial/cqc=1)

/datum/outfit/romulan/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.assignment = "Romulan naval officer"
	W.registered_name = H.real_name
	W.update_label()
	H.set_species(/datum/species/vulcan) // :^)