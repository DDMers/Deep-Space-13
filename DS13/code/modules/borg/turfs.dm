/turf/closed/wall/trek_smooth/borg
	name = "Assimilated wall"
	desc = "An oddly tinted wall with bits of metal, piping and green lights all over it."
	mod = null
	icon = 'DS13/icons/turf/trek_wall_borg.dmi'
	icon_state = "0"
	sheet_type = /obj/item/stack/sheet/metal //So it doesnt drop duotanium
	light_color = LIGHT_COLOR_GREEN

/turf/closed/wall/trek_smooth/borg/Initialize()
	. = ..()
	var/area/a = get_area(src)
	a.ambientsounds = list('DS13/sound/ambience/ambiborg1.ogg','DS13/sound/ambience/ambiborg2.ogg','DS13/sound/ambience/ambiborg3.ogg')

/turf/open/floor/plating/borg
	name = "Assimilated plating"
	desc = "It glows with a green light...This can't be good."
	icon = 'DS13/icons/turf/floors.dmi'
	icon_state = "borg"

/turf/open/floor/plating/borg/Initialize()
	. = ..()
	var/area/a = get_area(src)
	a.ambientsounds = list('DS13/sound/ambience/ambiborg1.ogg','DS13/sound/ambience/ambiborg2.ogg','DS13/sound/ambience/ambiborg3.ogg')