/obj/item/pda
	name = "PaDd"
	desc = "A small tablet which can run a number of useful programs."
	icon = 'DS13/icons/obj/pda.dmi'
	icon_state = "pda"

/obj/item/card/id
	name = "Identification chip"
	icon = 'DS13/icons/obj/card.dmi'

/obj/item/healthanalyzer
	name = "medical tricorder"
	desc = "An advanced scanner which can monitor the health of a patient."
	icon = 'DS13/icons/obj/device.dmi'

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)
	. = ..()
	playsound(loc, 'DS13/sound/effects/items/tricorder.ogg',100)

/obj/item/healthanalyzer/attack_self(mob/user)
	. = ..()
	playsound(loc, 'DS13/sound/effects/items/tricorder_open.ogg',100)

/obj/item/plant_analyzer
	name = "botany tricorder"
	desc = "An advanced scanner which can monitor the health of plant-based life-forms."
	icon = 'DS13/icons/obj/device.dmi'

/obj/item/wrench
	name = "Sonic wrench"
	icon = 'DS13/icons/obj/tools.dmi'
	usesound = 'DS13/sound/effects/items/spanner.ogg'

/obj/item/crowbar
	name = "Decoupler"
	desc = "This tool uses a micro-laser to cut through and force open casings."
	icon = 'DS13/icons/obj/tools.dmi'
	usesound = 'DS13/sound/effects/items/laser_scalpel.ogg'

/obj/item/screwdriver
	name = "Phase discriminator"
	icon = 'DS13/icons/obj/tools.dmi'
	desc = "A screwdriver like device which allows you to open all kinds of access ports"

/obj/item/screwdriver/Initialize()
	. = ..()
	usesound = 'DS13/sound/effects/items/screwdriver.ogg'

/obj/item/weldingtool
	name = "Plasma welder"
	icon = 'DS13/icons/obj/tools.dmi'
	desc = "A powerful welding tool for cutting and mending"

/obj/item/multitool
	name = "ODN Scanner"
	desc = "Used for testing isolinear circuitry by sending controlled electrical pulses."
	icon = 'DS13/icons/obj/tools.dmi'

/obj/item/wirecutters
	name = "Phase calipers"
	desc = "These calipers can cut through a lot of things with their inbuilt micro laser."
	icon = 'DS13/icons/obj/tools.dmi'
	usesound = 'DS13/sound/effects/items/laser_scalpel.ogg'

/obj/item/defibrillator/compact
	name = "Cortical stimulator"
	desc = "A belt mounted device which allows you to resuscitate a patient when applied to the chest."
	icon = 'DS13/icons/obj/tools.dmi'

/obj/structure/closet/secure_closet/medical_trek
	name = "medical doctor's locker"
	req_access = list(ACCESS_SURGERY)
	icon_state = "med_secure"

/obj/structure/closet/secure_closet/medical_trek/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/defibrillator/compact/loaded(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	return