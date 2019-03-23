SUBSYSTEM_DEF(overmap)
	name = "Overmap"
	init_order = INIT_ORDER_EVENTS //Same priority as events
	runlevels = RUNLEVEL_GAME
	var/list/events = list() //All the docking event datums we have.
	var/list/used = list() //events we've already used
	var/frequency_lower = 6000	//10 minutes lower bound.
	var/frequency_upper = 9000	//15 minutes upper bound. Basically an event will happen every 10 to 15 minutes.
	var/scheduled = 0 //When are we scheduling a event for?

/datum/controller/subsystem/overmap/Initialize(time, zlevel)
	. = ..()
	for(var/type in typesof(/datum/overmap_event))
		var/datum/overmap_event/E = new type()
		if(!E)
			continue				//don't want this one! leave it for the garbage collector
		events += E				//add it to the list of all events (controls)
	scheduled = world.time + 9000 //Give them about 20 minutes of prep time before we start throwing shit at them.
	return

/datum/controller/subsystem/overmap/proc/schedule()
	scheduled = world.time + rand(frequency_lower, max(frequency_lower,frequency_upper))

/datum/controller/subsystem/overmap/proc/checkEvent() //Logic copied from subsystems/events.dm
	if(scheduled <= world.time)
		spawnEvent()
		schedule()

/datum/controller/subsystem/overmap/proc/spawnEvent()
	if(!events.len)
		priority_announce("Excellent work [station_name()], you have completed your patrol for the day. We are sending a crew transfer shuttle","Incoming hail:",'sound/ai/commandreport.ogg')
		SSshuttle.emergency.request()
		return
	var/datum/overmap_event/F = pick(events)
	F.fire()
	events -= F
	used += F

/datum/controller/subsystem/overmap/fire(resumed = 0)
	checkEvent()
	return