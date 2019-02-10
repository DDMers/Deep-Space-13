/obj/structure/overmap_component
	name = "thing"
	icon = 'DS13/icons/overmap/components.dmi'
	anchored = TRUE
	can_be_unanchored = TRUE
	var/obj/structure/overmap/linked
	var/id = "nothing"
	var/position = null //Set this to either "pilot", "tactical" or "science"

/obj/structure/overmap_component/attack_hand(mob/user)
	if(!position)
		return ..()
	if(!linked)
		find_overmap()
	linked.enter(user, position)

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

/obj/structure/overmap_component/helm
	name = "Piloting station"
	desc = "This console gives you the power to control a starship."
	icon_state = "pilot"
	position = "pilot"

/obj/structure/overmap_component/science
	name = "Science station"
	desc = "This console gives you the power to control a starship."
	icon_state = "science"
	position = "science"

/obj/structure/overmap_component/tactical
	name = "Weapons station"
	desc = "This console gives you the power to control a starship."
	icon_state = "tactical"
	position = "tactical"

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