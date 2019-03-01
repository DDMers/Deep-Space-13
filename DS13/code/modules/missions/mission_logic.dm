/datum/dispatch_mission
	var/name = "Rescue cargo"
	var/list/target_ships = list("warbird","freighter") //The name of the map templates we seek to load
	var/desc = "Automated distress call received: <i>This the USS Clementine to any ships in the area! we're taking a beating out here, request immediate assista''##---'"
	var/list/occupied_spawns = list() //Keep track of all the spawns we're taking up so we can free them when we're finished

/datum/dispatch_mission/proc/fire()
	var/list/targets = target_ships.Copy()
	for(var/obj/effect/landmark/ship_spawner/SS in GLOB.landmarks_list)
		if(SS && !SS.loaded)
			var/target_ship = pick_n_take(targets)
			SS.load(target_ship)
			message_admins("A [name] mission has been created.")
			priority_announce("[desc]. Security should search the ship via the transporter and process its crew through customs.", "Incoming Transmission: Ship docking request", 'sound/ai/commandreport.ogg')
	if(!occupied_spawns.len)
		log_game("All ship spawns have been used up. Unable to spawn further events.")
//Ships!

/datum/map_template/ship
	name = "generic"
	mappath = "_maps/templates/DS13/default.dmm"

/datum/map_template/ship/warbird
	name = "warbird"
	mappath = "_maps/templates/DS13/warbird.dmm"

/datum/map_template/ship/freighter
	name = "freighter"
	mappath = "_maps/templates/DS13/freighter.dmm"

/obj/effect/landmark/ship_spawner
	name = "Ship spawning warp beacon"
	desc = "Spawns new ships!"
	var/loading = FALSE //To avoid spam
	var/loaded = FALSE //Is there a ship?

/obj/effect/landmark/ship_spawner/proc/unload()
	loaded = FALSE

/obj/effect/landmark/ship_spawner/proc/load(var/template)//Call load("name of the ship map template")
	if(loading || loaded)
		return FALSE
	if(!template)
		return FALSE
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	loading = TRUE
	var/datum/map_template/template_to_load = SSmapping.ship_templates[template]
	if(template_to_load.load(T, centered = FALSE))
		loading = FALSE
	loaded = TRUE
	return TRUE

/obj/effect/mob_spawn/human/alive/trek/Initialize()
	. = ..()
	for(var/mob/dead/observer/F in GLOB.dead_mob_list)
		var/turf/turfy = get_turf(src)
		var/link = TURF_LINK(F, turfy)
		if(F)
			to_chat(F, "<font color='#EE82EE'><i>Spawn available! (just click the sleeper): [link]</i></font>")

/obj/effect/mob_spawn/human/alive/trek/saladin_crew
	name = "Independant crewman"
	assignedrole = "saladin crew"
	outfit = /datum/outfit/job/engineer/DS13
	flavour_text = "<span class='big bold'>You are an independant crewman!</span><b> Your party bought the ship you're currently on off of a dodgy ferengi merchant. Your ship: the USS Sherman has taken heavy damage due to an asteroid belt. \n</b> <i>You own the USS Sherman along with your fellow crew, you are free to behave as you see fit. But you must <b>only</b> kill in self-defense.</i> \n If you require further guidance, please ahelp."

/obj/effect/mob_spawn/human/alive/trek/saladin_crew/captain
	name = "Independant captain"
	assignedrole = "saladin captain"
	outfit = /datum/outfit/job/captain/DS13
