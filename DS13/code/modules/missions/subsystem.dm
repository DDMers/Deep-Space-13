SUBSYSTEM_DEF(dispatch_missions)
	name = "Dispatch missions"
	init_order = INIT_ORDER_EVENTS //Same priority as events
	runlevels = RUNLEVEL_GAME
	var/list/spawn_points = list() //All the docking ports a current shipmap has.
	var/frequency_lower = 1800	//3 minutes lower bound.
	var/frequency_upper = 6000	//10 minutes upper bound. Basically an event will happen every 3 to 10 minutes.
	var/scheduled = 0 //When are we scheduling a docking event for?
	var/list/events = list() //All the docking event datums we have.

/datum/controller/subsystem/dispatch_missions/Initialize(time, zlevel)
	. = ..()
	for(var/type in typesof(/datum/dispatch_mission))
		var/datum/dispatch_mission/E = new type()
		if(!E)
			continue				//don't want this one! leave it for the garbage collector
		events += E				//add it to the list of all events (controls)
	schedule()
	return

/datum/controller/subsystem/dispatch_missions/proc/schedule()
	scheduled = world.time + rand(frequency_lower, max(frequency_lower,frequency_upper))

/datum/controller/subsystem/dispatch_missions/proc/checkEvent() //Logic copied from subsystems/events.dm
	if(scheduled <= world.time)
		spawnEvent()
		schedule()

/datum/controller/subsystem/dispatch_missions/proc/spawnEvent()
	if(!events.len)
		return
	var/datum/dispatch_mission/F = pick(events)
	F.fire()
	events -= F

/datum/controller/subsystem/dispatch_missions/fire(resumed = 0)
	checkEvent()
	return

/datum/controller/subsystem/mapping
	var/list/ship_templates = list()

/datum/controller/subsystem/mapping/proc/preloadShipTemplates()
	for(var/item in typecacheof(/datum/map_template/ship))
		var/datum/map_template/ship/ship_type = item
		if(!(initial(ship_type.mappath)))
			continue
		var/datum/map_template/ship/S = new ship_type()
		ship_templates[S.name] = S
		map_templates[S.name] = S

/datum/controller/subsystem/mapping/preloadTemplates(path = "_maps/templates/")
	. = ..()
	preloadShipTemplates()