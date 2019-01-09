// maps: COG2 causes nornwalls, DESTINY causes gannetwalls, anything else doesn't get saved
//GOONSTATION CODE IN SEPERATE FOLDER FOR LICENSE AGREEMENT//

/* =================================================== */
/* -------------------- SIMULATED -------------------- */
/* =================================================== */

/turf/closed/wall/trek_smooth
	icon = 'DS13/goonstation/walls_supernorn.dmi'
	var/mod = null //Such as R then the numbers, so R10
	var/light_mod = null
	var/connect_overlay = TRUE // do we have wall connection overlays, ex nornwalls?
	var/list/connects_to = list(/turf/closed/wall/trek_smooth,/obj/machinery/door,/obj/structure/window)
	var/list/connects_with_overlay = list()
	var/image/connect_image = null
	var/d_state = 0
	smooth = FALSE //Override /tg/ iconsmooths
	var/connect_universally = FALSE //Connect to every subtype of the walls?

	Initialize()
		..()
		START_PROCESSING(SSfastprocess,src)
		src.update_icon()
		set_light(6)
		if(connect_universally)
			connects_to += typecacheof(/turf/closed/wall/trek_smooth)
	process()
		update_icon() ///Tg/ code change, so these beauties actually smooth

	// ty to somepotato for assistance with making this proc actually work right :I
	proc/update_icon()
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
	name = "Wall"
	icon = 'DS13/icons/turf/smooth_trek_walls.dmi'
	mod = null

/turf/closed/wall/trek_smooth/reinforced
	name = "Outer hull"
	mod = "R"
	icon_state = "R0"

/turf/closed/wall/trek_smooth/corridor
	name = "Wall"
	icon = 'DS13/icons/turf/trek_wall_bright.dmi'
	mod = null