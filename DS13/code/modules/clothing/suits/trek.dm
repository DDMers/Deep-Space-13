/obj/item/clothing/head/helmet/space/hardsuit/trek
	name = "EV suit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has thermal shielding."
	alternate_worn_icon = 'DS13/icons/mob/head.dmi'
	icon = 'DS13/icons/obj/clothing/hats.dmi'
	item_state = "bl_suit"
	icon_state = "hardsuit0-federation"
	item_state = "federation"
	item_color = "federation"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 100, "rad" = 90, "fire" = 100, "acid" = 75)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/trek
	name = "EV suit"
	desc = "A standard issue hardsuit developed in the 24th century, it has heat shielding and specialized enviornmental plating to protect its wearer from most hazardous situations."
	alternate_worn_icon = 'DS13/icons/mob/suit.dmi'
	icon = 'DS13/icons/obj/suits.dmi'
	icon_state = "hardsuit-federation"
	item_state = "hardsuit-federation"
	armor = list("melee" = 30, "bullet" = 15, "laser" = 20, "energy" = 15, "bomb" = 20, "bio" = 100, "rad" = 90, "fire" = 100, "acid" = 75)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/trek
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/machinery/suit_storage_unit/trek
	suit_type = /obj/item/clothing/suit/space/hardsuit/trek
	mask_type = /obj/item/clothing/mask/breath