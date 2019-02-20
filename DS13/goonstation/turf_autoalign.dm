// maps: COG2 causes nornwalls, DESTINY causes gannetwalls, anything else doesn't get saved
//GOONSTATION CODE IN SEPERATE FOLDER FOR LICENSE AGREEMENT//

/* =================================================== */
/* -------------------- SIMULATED -------------------- */
/* =================================================== */

/turf/closed/wall/trek_smooth
	icon = 'DS13/goonstation/walls_supernorn.dmi'
	name = "Metallic duranium hull"
	desc = "A massive chunk of metal which subdivides rooms, corridors, and even keeps you safe from space."
	var/mod = null //Such as R then the numbers, so R10
	var/light_mod = null
	var/connect_overlay = TRUE // do we have wall connection overlays, ex nornwalls?
	var/list/connects_to = list(/turf/closed/wall/trek_smooth,/obj/machinery/door,/obj/structure/window)
	canSmoothWith = list(/turf/closed/wall/trek_smooth,/obj/machinery/door,/obj/structure/window)
	var/list/connects_with_overlay = list()
	var/image/connect_image = null
	var/d_state = 0
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	smooth = TRUE
	var/connect_universally = TRUE //Connect to every subtype of the walls?

	Initialize()
		. = ..()
		set_light(6)
		if(connect_universally)
			connects_to += typecacheof(/turf/closed/wall/trek_smooth)
			canSmoothWith += typecacheof(/turf/closed/wall/trek_smooth)
			canSmoothWith += typecacheof(/obj/structure/window)
			canSmoothWith += typecacheof(/obj/machinery/door) //tg smoothing is finnicky

	// ty to somepotato for assistance with making this proc actually work right :I

	legacy_smooth() //overwrite the smoothing to use icon smooth SS
		var/builtdir = 0
		var/overlaydir = 0
		for (var/dir in GLOB.cardinals)
			var/turf/T = get_step(src, dir)
			if (T.type == src.type || (T.type in connects_to))
				builtdir |= dir
			else if (connects_to)
				for (var/i=1, i <= connects_to.len, i++)
					var/atom/A = locate(connects_to[i]) in T
					if (!isnull(A))
						if (istype(A, /atom/movable))
							var/atom/movable/M = A
							if (!M.anchored)
								continue
						builtdir |= dir
						break
			if (connect_overlay && connects_with_overlay)
				if (T.type in connects_with_overlay)
					overlaydir |= dir
				else
					for (var/i=1, i <= connects_with_overlay.len, i++)
						var/atom/A = locate(connects_with_overlay[i]) in T
						if (!isnull(A))
							if (istype(A, /atom/movable))
								var/atom/movable/M = A
								if (!M.anchored)
									continue
							overlaydir |= dir

		src.icon_state = "[mod][builtdir][src.d_state ? "C" : null]"

		if (connect_overlay)
			if (overlaydir)
				if (!src.connect_image)
					add_overlay(connect_image)
				else
					src.connect_image.icon_state = "connect[overlaydir]"
				add_overlay(connect_image)
			else
				cut_overlays()

//END OF GOON STUFF

/turf/closed/wall/trek_smooth/room
	name = "Duotanium alloy hull"
	icon = 'DS13/icons/turf/smooth_trek_walls.dmi'
	mod = null
	sheet_type = /obj/item/stack/sheet/duotanium
	sheet_amount = 1

/turf/closed/wall/trek_smooth/reinforced
	name = "Reinforced tritanium hull"
	mod = "R"
	icon_state = "R0"
	sheet_type = /obj/item/stack/sheet/plasteel

/turf/closed/wall/trek_smooth/corridor
	name = "Duranium alloy hull"
	icon = 'DS13/icons/turf/trek_wall_bright.dmi'
	mod = null
	sheet_type = /obj/item/stack/sheet/duranium
	sheet_amount = 1

//Mats to make new walls:

/datum/design/duranium_alloy
	name = "Duranium alloy"
	id = "duranium"
	build_type = SMELTER | PROTOLATHE
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT, MAT_SILVER = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/duranium
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50

/obj/item/stack/sheet/duranium
	name = "duranium alloy"
	singular_name = "duranium alloy sheet"
	desc = "This sheet is an alloy of iron and silver."
	icon = 'DS13/icons/obj/stack_objects.dmi'
	icon_state = "sheet-duranium"
	item_state = "sheet-metal"
	materials = list(MAT_METAL=2000, MAT_SILVER=2000)
	throwforce = 5
	flags_1 = CONDUCT_1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/duranium
	grind_results = list("iron" = 20, "silver" = 20)
	point_value = 10

/obj/item/stack/sheet/duranium/twenty
	amount = 20

/obj/item/stack/sheet/duranium/fifty
	amount = 50

/datum/design/duotanium_alloy
	name = "Duotanium alloy"
	id = "duotanium"
	build_type = SMELTER | PROTOLATHE
	materials = list(MAT_WOOD = MINERAL_MATERIAL_AMOUNT, MAT_SILVER = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/duotanium
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50

/obj/item/stack/sheet/duotanium
	name = "duotanium alloy"
	singular_name = "duotanium alloy sheet"
	desc = "This sheet is an alloy of wood and silver, giving a strong but pleasant looking hull segment."
	icon = 'DS13/icons/obj/stack_objects.dmi'
	icon_state = "sheet-duotanium"
	item_state = "sheet-metal"
	materials = list(MAT_METAL=2000, MAT_WOOD=2000)
	throwforce = 5
	flags_1 = CONDUCT_1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/duotanium
	grind_results = list("iron" = 20, "plasma" = 20)
	point_value = 10

/obj/item/stack/sheet/duotanium/twenty
	amount = 20

/obj/item/stack/sheet/duotanium/fifty
	amount = 50

/obj/structure/girder/attackby(obj/item/W, mob/user, params) //Time to add support for our walls..
	. = ..()
	if(istype(W, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = W
		if(istype(S, /obj/item/stack/sheet/duranium))
			if(S.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need two sheets of duranium to finish a wall!</span>")
				return
			if (do_after(user, 40, target = src))
				if(S.get_amount() < 2)
					return
				S.use(2)
				to_chat(user, "<span class='notice'>You add the hull plating.</span>")
				var/turf/T = get_turf(src)
				T.PlaceOnTop(/turf/closed/wall/trek_smooth/corridor)
				transfer_fingerprints_to(T)
				qdel(src)
			return

		if(istype(S, /obj/item/stack/sheet/duotanium))
			if(S.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need two sheets of duotanium to finish a wall!</span>")
				return
			if (do_after(user, 40, target = src))
				if(S.get_amount() < 2)
					return
				S.use(2)
				to_chat(user, "<span class='notice'>You add the hull plating.</span>")
				var/turf/T = get_turf(src)
				T.PlaceOnTop(/turf/closed/wall/trek_smooth/room)
				transfer_fingerprints_to(T)
				qdel(src)
			return
