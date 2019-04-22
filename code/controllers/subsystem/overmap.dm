SUBSYSTEM_DEF(overmap)
	name = "Overmap"
	init_order = INIT_ORDER_EVENTS //Same priority as events
	runlevels = RUNLEVEL_GAME
	var/list/events = list() //All the docking event datums we have.
	var/list/all_events = list() //Every event. This means admins can force them
	var/list/used = list() //events we've already used
	var/frequency_lower = 6000	//10 minutes lower bound.
	var/frequency_upper = 9000	//15 minutes upper bound. Basically an event will happen every 10 to 15 minutes.
	var/scheduled = 0 //When are we scheduling a event for?
	var/missions_per_rotation = 6 //Change this if you want a longer round, admins.
	var/datum/overmap_event/next_event //What's firing next? This is here so admins can force stuff.
	var/datum/overmap_event/previous_event //What did we last fire? and have they dealt with it? This stops starfleet asking the crew to save a freighter from meteors AND kill borg AND rescue people.

/datum/controller/subsystem/overmap/Initialize(time, zlevel)
	. = ..()
	var/list/potential = list()
	for(var/type in typesof(/datum/overmap_event))
		var/datum/overmap_event/E = new type()
		if(!E)
			continue				//don't want this one! leave it for the garbage collector
		potential += E				//add it to the list of all events (controls)
		all_events += E
	for(var/i = 0 to missions_per_rotation) //Choose a list of missions that you'll be doing
		var/datum/overmap_event/chosen = pick_n_take(potential)
		events += chosen
	schedule()

/datum/controller/subsystem/overmap/proc/schedule()
	scheduled = world.time + rand(frequency_lower, max(frequency_lower,frequency_upper))
	var/datum/overmap_event/F = pick(events)
	next_event = F

/datum/controller/subsystem/overmap/proc/checkEvent() //Logic copied from subsystems/events.dm
	if(scheduled <= world.time)
		if(previous_event)
			if(!previous_event.completed)
				message_admins("An overmap mission tried to spawn, but the crew hadn't completed their current one ([previous_event])")
				scheduled = world.time+frequency_lower //Reschedule, but for the shorter bound. This means you don't get 20 minute periods of nothing.
				return
		spawnEvent()
		schedule()

/datum/controller/subsystem/overmap/proc/spawnEvent() //This means that the shuttle gets called 10-15 minutes after the last event fired, giving them enough time to complete it.
	if(!events.len || !next_event)
		priority_announce("Excellent work [station_name()], you have completed your patrol for the day. We are sending a crew transfer shuttle to relieve you.","Incoming hail:",'sound/ai/commandreport.ogg')
		SSshuttle.emergency.request(null, set_coefficient = 0.6)
		SSshuttle.emergencyNoRecall = TRUE //We want to end the round.
		return
	next_event.fire()
	previous_event = next_event //Store this one.
	events -= next_event
	used += next_event
	next_event = null

/datum/controller/subsystem/overmap/fire(resumed = 0)
	checkEvent()
	return