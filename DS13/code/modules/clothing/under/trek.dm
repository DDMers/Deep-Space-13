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
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/trekjacket //Replaces toolbelt, which isn't very trek

/datum/component/storage/concrete/pockets/trekjacket
	max_items = 5
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 50
	silent = TRUE

/datum/component/storage/concrete/pockets/trekjacket/Initialize()
	. = ..()
	can_hold = typecacheof(list(
		/obj/item/kitchen/knife, /obj/item/switchblade, /obj/item/pen,
		/obj/item/scalpel, /obj/item/reagent_containers/syringe, /obj/item/dnainjector,
		/obj/item/reagent_containers/hypospray/medipen, /obj/item/reagent_containers/dropper,
		/obj/item/implanter, /obj/item/screwdriver,/obj/item/wrench,/obj/item/weldingtool,/obj/item/crowbar,/obj/item/wirecutters,/obj/item/analyzer,
		/obj/item/firing_pin
		))

/obj/item/clothing/under/attack_hand(mob/user)
	if(attached_accessory && ispath(attached_accessory.pocket_storage_component_path))
		attached_accessory.attack_hand(user)
		return
	else
		. = ..()

/obj/item/clothing/under/attackby(obj/I, mob/user)
	if(attached_accessory && ispath(attached_accessory.pocket_storage_component_path))
		attached_accessory.attackby(I, user)
		return
	else
		. = ..()