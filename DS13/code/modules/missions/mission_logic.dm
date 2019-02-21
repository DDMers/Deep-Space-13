/datum/dispatch_mission
	var/name = "Rescue cargo"
	var/list/target_ships = list("warbird","freighter") //The name of the map templates we seek to load
	var/desc = "Automated distress call received: <i>This the USS Clementine to any ships in the area! we're taking a beating out here, request immediate assista''##---'"
	var/list/occupied_spawns = list() //Keep track of all the spawns we're taking up so we can free them when we're finished

/datum/dispatch_mission/proc/fire()
	var/list/targets = target_ships.Copy()
	for(var/obj/effect/landmark/ShipSpawner/SS in GLOB.landmarks_list)
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

/obj/effect/landmark/ShipSpawner
	name = "Ship spawning warp beacon"
	desc = "Spawns new ships!"
	var/loading = FALSE //To avoid spam
	var/loaded = FALSE //Is there a ship?

/obj/effect/landmark/ShipSpawner/proc/unload()
	loaded = FALSE

/obj/effect/landmark/ShipSpawner/proc/load(var/template)//Call load("name of the ship map template")
	if(loading || loaded)
		return FALSE
	if(!template)
		return FALSE
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	loading = TRUE
//	var/datum/map_template/template_to_load = SSmapping.ship_templates[template]
//	if(template_to_load.load(T, centered = FALSE))
//		loading = FALSE
//	loaded = TRUE
	return TRUE