SUBSYSTEM_DEF(docking)
	name = "Docking"
	init_order = INIT_ORDER_EVENTS //Same priority as events
	runlevels = RUNLEVEL_GAME
	var/list/ship_docking_ports = list() //All the docking ports a current shipmap has.
	var/frequency_lower = 1800	//3 minutes lower bound.
	var/frequency_upper = 6000	//10 minutes upper bound. Basically an event will happen every 3 to 10 minutes.
	var/scheduled = 0 //When are we scheduling a docking event for?
	var/list/events = list() //All the docking event datums we have.

/datum/controller/subsystem/docking/Initialize(time, zlevel)
	. = ..()
	for(var/type in typesof(/datum/ship_event))
		var/datum/ship_event/E = new type()
		if(!E)
			continue				//don't want this one! leave it for the garbage collector
		events += E				//add it to the list of all events (controls)
	schedule()
	return

/datum/controller/subsystem/docking/proc/schedule()
	scheduled = world.time + rand(frequency_lower, max(frequency_lower,frequency_upper))

/datum/controller/subsystem/docking/proc/checkEvent() //Logic copied from subsystems/events.dm
	if(scheduled <= world.time)
		spawnEvent()
		schedule()

/datum/controller/subsystem/docking/proc/spawnEvent()
	if(!events.len)
		return
	var/datum/ship_event/F = pick(events)
	F.fire()
	events -= F

/datum/controller/subsystem/docking/fire(resumed = 0)
	checkEvent()
	return