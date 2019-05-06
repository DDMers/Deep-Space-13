/datum/cinematic/romulan
	id = CINEMATIC_ROMULAN
	is_global = TRUE
	cleanup_time = 50

/datum/cinematic/romulan/content()
	screen.icon = 'icons/effects/trek_cinematics.dmi'
	flick("romulan",screen)
	sleep(50)
	screen.icon_state = "romulan_end"

/datum/cinematic/shipexplode
	id = CINEMATIC_SHIPEXPLODE
	is_global = TRUE
	cleanup_time = 10

/datum/cinematic/shipexplode/content()
	screen.icon = 'DS13/icons/effects/shipexplode.gif'
	sleep(40)
	screen.alpha = 0