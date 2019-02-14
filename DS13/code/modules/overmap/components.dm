/obj/structure/overmap_component
	name = "thing"
	icon = 'DS13/icons/overmap/components.dmi'
	anchored = TRUE
	can_be_unanchored = TRUE
	var/obj/structure/overmap/linked
	var/id = "nothing"
	var/position = null //Set this to either "pilot", "tactical" or "science"

/obj/structure/overmap_component/attack_hand(mob/user) //this doesnt work!!
	if(!linked || QDELETED(linked))
		find_overmap()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/L = user
	if(!position)
		return ..()
	if(L.wear_id)
		var/obj/item/card/id/ID = L.wear_id
		if(ID && istype(ID))
			if(!check_access(ID))
				to_chat(L, "You require a high level access card to use this console!.")
				return
			linked.enter(L, position)
		else
			to_chat(L, "You require a high level access card to use this console!.")
			return


/obj/structure/overmap_component/Initialize()
	. = ..()
	find_overmap()

/obj/structure/overmap_component/examine(mob/user)
	. = ..()
	if(!linked)
		return
	to_chat(user, "-it seems to be connected to [linked]")

/obj/structure/overmap_component/proc/find_overmap()
	for(var/obj/structure/overmap/OM in GLOB.overmap_ships)
		if(OM.class == id)
			linked = OM

/obj/structure/overmap_component/viewscreen
	name = "Viewscreen"
	desc = "Allows you to see your ship."
	icon_state = "viewscreen"
	icon = 'DS13/icons/obj/decor/viewscreen.dmi'
	id = "nope"


/obj/structure/overmap_component/viewscreen
	name = "Viewscreen"
	desc = "Allows you to see your ship."
	icon_state = "viewscreen"
	icon = 'DS13/icons/obj/decor/viewscreen.dmi'
	id = "miranda"

/obj/structure/overmap_component/viewscreen/examine(mob/user)
	if(!linked || QDELETED(linked))
		find_overmap()
	if(isobserver(user) && linked)
		user.forceMove(get_turf(linked))
		return
	linked.CreateEye(user)
	. = ..()

/obj/structure/overmap_component/helm
	name = "Piloting station"
	desc = "This console gives you the power to control a starship."
	icon_state = "pilot"
	position = "pilot"
	req_access = list(ACCESS_HEADS)

/obj/structure/overmap_component/science
	name = "Science station"
	desc = "This console gives you the power to control a starship."
	icon_state = "science"
	position = "science"
	req_access = list(ACCESS_RESEARCH)

/obj/structure/overmap_component/tactical
	name = "Weapons station"
	desc = "This console gives you the power to control a starship."
	icon_state = "tactical"
	position = "tactical"
	req_access = list(ACCESS_SECURITY)

/obj/structure/overmap_component/helm/miranda
	name = "Piloting station"
	desc = "This console gives you the power to control a starship."
	icon_state = "pilot"
	position = "pilot"
	id = "miranda"

/obj/structure/overmap_component/science/miranda
	name = "Science station"
	desc = "This console gives you the power to control a starship."
	icon_state = "science"
	position = "science"
	id = "miranda"

/obj/structure/overmap_component/tactical/miranda
	name = "Weapons station"
	desc = "This console gives you the power to control a starship."
	icon_state = "tactical"
	position = "tactical"
	id = "miranda"

/obj/structure/overmap_component/helm/warbird
	name = "Piloting station"
	desc = "This console gives you the power to control a starship."
	icon_state = "pilot"
	position = "pilot"
	id = "warbird"

/obj/structure/overmap_component/science/warbird
	name = "Science station"
	desc = "This console gives you the power to control a starship."
	icon_state = "science"
	position = "science"
	id = "warbird"

/obj/structure/overmap_component/tactical/warbird
	name = "Weapons station"
	desc = "This console gives you the power to control a starship."
	icon_state = "tactical"
	position = "tactical"
	id = "warbird"