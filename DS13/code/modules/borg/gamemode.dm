GLOBAL_LIST_EMPTY(borg_drone_spawns)

/datum/game_mode/borg_assimilation
	name = "borg assimilation"
	config_tag = "borg_assimilation"
	antag_flag = ROLE_BORG_DRONE
	announce_span = "danger"
	announce_text = "A borg proximity signal has been detected. Origin: Unimatrix 325, grid 006. Alter course to intercept.\n\
	<span class='danger'>Borg</span>: Assimilate over 70% of the crew to win!\n\
	<span class='notice'>Crew</span>: Defend the station and eliminate the borg. Dereliction of duty will cause a borg victory."
	required_players = 10 // 10 players - 3 players to be the borg = 7 players remaining. Yeah we're a very lowpop server >:(
	required_enemies = 2 //2
	recommended_enemies = 3
	var/antag_datum_type = /datum/antagonist/borg_drone
	var/list/pre_borgs = list()
	var/const/borg_possible = 6 //if we need lotsa borg due to highpop
	var/announce_sound = 'DS13/sound/effects/borg/announce.ogg'

/datum/game_mode/borg_assimilation/pre_setup()
	var/n_agents = min(round(num_players() / 10), antag_candidates.len, borg_possible)
	if(n_agents >= required_enemies)
		for(var/i = 0, i < n_agents, ++i)
			var/datum/mind/locutus_wannabee = pick_n_take(antag_candidates)
			pre_borgs += locutus_wannabee
			locutus_wannabee.assigned_role = ROLE_BORG_DRONE
			locutus_wannabee.special_role = ROLE_BORG_DRONE
			log_game("[key_name(locutus_wannabee)] has been selected as a borg drone")
		return TRUE
	else
		setup_error = "Not enough borg drone candidates"
		return FALSE

/datum/game_mode/borg_assimilation/post_setup() //now add a place for them to spawn :)
	for(var/i = 1 to pre_borgs.len)
		var/datum/mind/borg_mind = pre_borgs[i]
		borg_mind.add_antag_datum(antag_datum_type)
		var/mob/living/carbon/human/H = borg_mind.current
		H.equipOutfit(/datum/outfit/borg, visualsOnly = FALSE)
		borg_mind.current.forceMove(pick(GLOB.borg_drone_spawns))
	GLOB.borg_collective.send_sound_collective(announce_sound)
	GLOB.borg_collective.message_collective("The collective", "A borg proximity signal has been detected. Origin: Unimatrix 325, grid 006. Alter course to intercept.")
	GLOB.borg_collective.message_collective("The collective", "ETA: 2 minutes. Teleporter will activate when in-range of Unimatrix 325 : Deep Space 13.")
	addtimer(CALLBACK(src, .proc/activate_teleporters), 2 MINUTES) //2 minutes prep time before they're announced.
	return ..()

/datum/game_mode/borg_assimilation/proc/activate_teleporters()
	GLOB.borg_collective.message_collective("The collective", "Cube has arrived at Unimatrix 325. Proceed with assimilation of relevant technology and life-forms.")
	SEND_SOUND(world, 'DS13/sound/effects/borg/progress/borg_theme.ogg')
	GLOB.borg_collective.teleporters_allowed = TRUE
	GLOB.borg_collective.activate_teleporters()

/obj/effect/landmark/start/borg_drone
	name = "Borg Drone"
	icon = 'DS13/icons/effects/landmarks_static.dmi'
	icon_state = "borg"

/obj/effect/landmark/start/borg_drone/Initialize(mapload)
	. = ..()
	GLOB.borg_drone_spawns += get_turf(src)

/obj/effect/landmark/start/borg_drone/Destroy()
	GLOB.borg_drone_spawns -= get_turf(src)
	. = ..()

/area/borg_ship
	name = "Borg Cube"
	requires_power = FALSE
	has_gravity = TRUE