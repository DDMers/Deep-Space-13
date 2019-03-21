/obj/structure/trek_catwalk
	name = "catwalk"
	desc = "Cats really don't like these things."
	icon = 'DS13/icons/turf/catwalk.dmi'
	icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER + 0.5
	smooth = TRUE
	canSmoothWith = list(/obj/structure/trek_catwalk, /turf/closed/wall)

/obj/structure/trek_catwalk/attack_hand(mob/user)
	var/turf/T = get_turf(src)
	return T.attack_hand(user)

/obj/structure/trek_catwalk/attackby(obj/item/C as obj, mob/user as mob)
	if(istype(C, /obj/item/wirecutters))
		to_chat(user, "<span_class='notice'>You start to cut [src] up!</span>")
		if(do_after(user, 50, target = src))
			new /obj/item/stack/rods(src.loc)
			qdel(src)
		return
	else
		var/turf/T = get_turf(src)
		return T.attack_hand(C, user)