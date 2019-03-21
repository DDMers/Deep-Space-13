GLOBAL_LIST_INIT(overmap_event_spawns, list())

/datum/overmap_event
	var/name = "Romulan freighter attack"
	var/desc = "DISTRESS CALL: A fortunate class freighter is under attack by a Romulan battle group! Requesting immediate assistance."
	var/fail_text = "The freighter has been destroyed. All hands lost."
	var/succeed_text = "Incoming hail. You turned up at just the right time, we owe you one!."
	var/obj/effect/landmark/overmap_event_spawn/spawner
	var/list/elements = list() //All the shit we're gonna spawn, yeah.
	var/obj/structure/overmap/ai/target //In this case, the freighter. If this dies then fail the mission!
	var/reward = 10000 //10 K Credits? Sheesh what a rip off!

/datum/overmap_event/proc/check_completion(var/obj/structure/overmap/what)
	if(target)
		if(what == target) //This is the default one. If this is being called, the freighter has been destroyed and you fail!
			fail()
			return
	elements -= what
	if(!elements.len)
		succeed()
		return

/datum/overmap_event/proc/succeed()
	to_chat(world, "<span class='notice'>Starfleet command has issued a commendation to the crew of [station_name()]. The ship has been allocated extra operational budget ([reward]) by Starfleet command.</span>")
	priority_announce(succeed_text,"Incoming hail:",'sound/ai/commandreport.ogg')
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(reward)
	spawner.used = FALSE
	target.vel = 10 //Make them warp away
	addtimer(CALLBACK(src, .proc/clear_elements), 60) //Clear up everything after 6 seconds

/datum/overmap_event/proc/clear_elements()
	if(target)
		var/obj/structure/overmap/saved = target
		target = null //So that QDEL'ing it doesn't cause the mission to fail after it's already complete
		qdel(saved)

/datum/overmap_event/proc/fail()
	to_chat(world, "<span class='warning'>Starfleet command has issued an official reprimand on [station_name()]'s permanent record.</span>")
	priority_announce(fail_text)
	spawner.used = FALSE

/datum/overmap_event/proc/fire()
	for(var/x in GLOB.overmap_event_spawns)
		var/obj/effect/landmark/overmap_event_spawn/X = x
		if(X.used)
			continue
		spawner = X
		break
	if(!spawner)
		return //:( All spawns are used up.
	start()
	spawner.used = TRUE
	for(var/mob/dead/observer/F in GLOB.dead_mob_list)
		var/turf/turfy = get_turf(spawner)
		var/link = TURF_LINK(F, turfy)
		to_chat(F, "<span class='purple'><b>[name] spawning at [link]</b></span>")

/datum/overmap_event/proc/start() //Now we have a spawn. Let's do whatever this mission is supposed to. Override this when you make new missions
	var/I = rand(1,2)
	target = new /obj/structure/overmap/ai/freighter(get_turf(spawner))
	target.linked_event = src
	priority_announce("DISTRESS CALL: A fortunate class freighter ([target]) is under attack by a Romulan battle group! Requesting immediate assistance!","Incoming hail:",'sound/ai/commandreport.ogg')
	for(var/num = 0 to I)
		var/obj/structure/overmap/ai/warbird = new /obj/structure/overmap/ai(get_turf(pick(orange(spawner, 6))))
		warbird.force_target = target //That freighter ain't no fortunate oneeeee n'aw lord IT AINT HEEEE IT AINT HEEEE
		warbird.nav_target = target
		warbird.target = target
		warbird.linked_event = src
		elements += warbird

/obj/effect/landmark/overmap_event_spawn
	name = "Overmap event spawner"
	icon = 'DS13/icons/effects/effects.dmi'
	icon_state = "event_spawn"
	var/used = FALSE

/obj/effect/landmark/overmap_event_spawn/Initialize()
	. = ..()
	GLOB.overmap_event_spawns += src

/datum/overmap_event/freighter_stuck
	name = "Stranded freighter"
	desc = "A miranda class cruiser has gotten stuck in an asteroid storm. Her engines are down"
	fail_text = "The freighter has been destroyed. All hands lost."
	succeed_text = "Excellent work, the cruiser will now resume escort duty."
	reward = 5000
	var/obj/structure/overmap/meteor_storm/MS

/obj/structure/overmap/meteor_storm
	name = "Meteor storm"
	icon = 'DS13/icons/obj/meteor_storm.dmi'
	icon_state = "storm"
	var/meteor_damage = 20 //She's takin' a beating captain!
	var/datum/overmap_event/linked_event
	var/obj/structure/overmap/freighter

/obj/structure/meteor
	name = "Meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	var/meteor_damage = 10 //She's takin' a beating captain!
	density = TRUE

/obj/structure/meteor/Initialize()
	. = ..()
	icon_state = pick("small", "large", "glowing","sharp","small1","dust")
	SpinAnimation(1000,1000)

/obj/structure/meteor/proc/crash(atom/target)
	if(!istype(target, /obj/structure/overmap))
		return
	var/obj/structure/overmap/SS = target
	SS.take_damage(null, meteor_damage)
	qdel(src)

/obj/structure/overmap/meteor_storm/Initialize()
	. = ..()
	SpinAnimation(1000,1000)
	START_PROCESSING(SSobj,src)

/obj/structure/overmap/meteor_storm/process()
	if(prob(40))
		for(var/obj/structure/overmap/OM in GLOB.overmap_ships)
			if(!OM || OM == src)
				continue
			if(istype(OM) && OM.z == z && get_dist(src, OM) <= 5)
				OM.take_damage(null, meteor_damage)
	if(linked_event && freighter)
		if(get_dist(src, freighter) >= 5) //Hooray! They towed the ship away.
			linked_event.succeed()

/datum/overmap_event/freighter_stuck/start() //Really simple. You just need to tow the freighter out of the asteroid belt :b1:
	target = new /obj/structure/overmap/ai/miranda(get_turf(spawner))
	target.linked_event = src
	priority_announce("DISTRESS CALL: A miranda class light cruiser ([target]) has sustained heavy damage in a meteor storm! Tow the ship to safety before she is destroyed.","Incoming hail:", 'sound/ai/commandreport.ogg')
	MS = new(get_turf(target)) //Put the meteor storm over the target
	MS.linked_event = src
	elements += MS
	elements += target
	MS.freighter = target
	var/I = rand(1,9)
	for(var/num = 0 to I)
		new /obj/structure/meteor(get_turf(pick(orange(spawner, 6))))

/datum/overmap_event/freighter_stuck/succeed()
	target.engine_power = 4 //Let her move again
	target.max_shield_health = 100
	target.shields.max_health = 100
	to_chat(world, "<span class='notice'>Starfleet command has issued a commendation to the crew of [station_name()]. The ship has been allocated extra operational budget ([reward]) by Starfleet command.</span>")
	priority_announce(succeed_text)
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(reward)
	target.max_health = 150
	target.health = 150 //So it's not too OP after completing the mission.
	target = null
	MS.freighter = null
	MS.linked_event = null

/datum/overmap_event/comet //A harmless comet
	name = "Comet flyby"
	desc = "A harmless comet rich in minerals is entering your system."
	fail_text = "The comet has been destroyed."
	succeed_text = "Good work. That should allow for some nice upgrades."
	reward = 5000

/datum/overmap_event/comet/start() //Now we have a spawn. Let's do whatever this mission is supposed to. Override this when you make new missions
	target = new /obj/structure/overmap/comet(get_turf(spawner))
	priority_announce("Attention [station_name()], an extremely mineral rich comet is due to pass through your current system. We recommend directing your miners to begin drilling.","Incoming hail:",'sound/ai/commandreport.ogg')
	elements += target

/obj/structure/overmap/comet
	name = "Ice comet"
	icon = 'DS13/icons/obj/meteor_storm.dmi'
	icon_state = "comet"
	class = "comet"
	max_shield_health = 0

/obj/structure/overmap/comet/Initialize()
	. = ..()
	SpinAnimation(1000,1000)
	shields.max_health = 0

/area/ship/comet
	name = "Comet"
	class = "comet"
	noteleport = FALSE

/datum/overmap_event/crashed_borg //Not so harmless borg
	name = "Ominous broadcast (spawns available on spawners menu!)"
	desc = "Something about this doesn't seem right..."
	fail_text = "The distress call has terminated"
	succeed_text = "The distress call has terminated"
	reward = 5000

/datum/overmap_event/crashed_borg/start() //Now we have a spawn. Let's do whatever this mission is supposed to. Override this when you make new missions
	target = new /obj/structure/overmap/moon(get_turf(spawner))
	priority_announce("Attention [station_name()]. Long range telemetry picked up the following broadcast approximately 5 minutes ago: \n41-20-62-6f-72-67-20-70-72-6f-78-69-6d-69-74-79-20-73-69-67-6e-61-6c-20-68-61-73-20-62-65-65-6e-20-64-65-74-65-63-74-65-64-2e-20-44-72-6f-6e-65-73-20-64-61-6d-61-67-65-64-2e-20-52-65-70-61-69-72-73-20-69-72-72-65-6c-65-76-65-6e-74-2e-20-44-6f-20-6e-6f-74-20-61-6c-74-65-72-20-63-6f-75-72-73-65 \n It appears to lead to a small moon.","Intercepted subspace transmission:",'sound/ai/commandreport.ogg')
	elements += target

/area/ship/crashed_borg
	name = "Unimatrix wreck"
	class = "crashed_borg"

/obj/structure/overmap/moon
	name = "Small Moon"
	icon = 'DS13/icons/overmap/planets.dmi'
	icon_state = "moon"
	class = "crashed_borg"
	max_shield_health = 0

/datum/overmap_event/crashed_borg/succeed()
	return //Impossible to succeed, or fail.

/datum/overmap_event/crashed_borg/fail()
	return //Impossible to succeed, or fail.


/datum/overmap_event/assimilated_miranda //Bossfight!
	name = "Assimilated ship"
	desc = "Red alert! A miranda class vessel is transmitting borg transponder codes. Eliminate it before it can upgrade itself!"
	fail_text = "All hands, set condition 1 throughout the fleet. This is not a drill."
	succeed_text = "It seems the vessel was assimilated by the borg. Excellent work dispatching it, crew. We'll notify their families."
	reward = 20000

/datum/overmap_event/assimilated_miranda/start() //Now we have a spawn. Let's do whatever this mission is supposed to. Override this when you make new missions
	target = new /obj/structure/overmap/ai/assimilated(get_turf(spawner))
	priority_announce("Attention [station_name()]. We just lost contact with one of our patrol frigates, they're not responding to hails and their transponder code has changed. You are ordered to investigate as soon as possible, we recommend you go to red alert.","Intercepted subspace transmission:",'sound/ai/commandreport.ogg')
	elements += target
	target.linked_event = src

/datum/overmap_event/assimilated_miranda/check_completion(var/obj/structure/overmap/what)
	if(target)
		if(what == target) //This is the default one. If this is being called, the freighter has been destroyed and you fail!
			succeed()
			return


/datum/outfit/retro_trek
	name = "Retro captain"
	uniform = /obj/item/clothing/under/trek/command
	shoes = /obj/item/clothing/shoes/jackboots
	head = null
	gloves = /obj/item/clothing/gloves/color/black
	l_pocket = /obj/item/pda
	belt = /obj/item/gun/energy/phaser

/datum/outfit/retro_trek/eng
	name = "Retro engineer"
	uniform = /obj/item/clothing/under/trek/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	head = null
	l_pocket = /obj/item/pda
	belt = /obj/item/storage/belt/utility/full

/datum/outfit/retro_trek/medsci
	name = "Retro doctor"
	uniform = /obj/item/clothing/under/trek/medsci
	shoes = /obj/item/clothing/shoes/jackboots
	head = null
	l_pocket = /obj/item/pda
	belt = /obj/item/storage/belt/utility/full

/obj/effect/mob_spawn/human/alive/trek/retro
	name = "Stranded crewman"
	assignedrole = "stranded crewman"
	outfit = /datum/outfit/retro_trek
	flavour_text = "<span class='big bold'>You are a stranded crewman!</span> <b> Your ship went wildly off course and your crew were knocked out. You have been hurled hundreds of years into the future, and should be confused by the new technology. <br> Your ship has sustained irreperable damage, and you should seek help from whoever's still around..."

/obj/effect/mob_spawn/human/alive/trek/retro/eng
	name = "Stranded crewman"
	assignedrole = "stranded crewman"
	outfit = /datum/outfit/retro_trek/eng
	flavour_text = "<span class='big bold'>You are a stranded crewman!</span> <b> Your ship went wildly off course and your crew were knocked out. You have been hurled hundreds of years into the future, and should be confused by the new technology. <br> Your ship has sustained irreperable damage, and you should seek help from whoever's still around..."

/obj/effect/mob_spawn/human/alive/trek/retro/doctor
	name = "Stranded crewman"
	assignedrole = "stranded crewman"
	outfit = /datum/outfit/retro_trek/medsci
	flavour_text = "<span class='big bold'>You are a stranded crewman!</span> <b> Your ship went wildly off course and your crew were knocked out. You have been hurled hundreds of years into the future, and should be confused by the new technology. <br> Your ship has sustained irreperable damage, and you should seek help from whoever's still around..."

/datum/overmap_event/tos_stranded //Star trekkin' a...wait where the fuck are we?
	name = "Kirk era ship (spawns available on spawners menu!)"
	desc = "Where are we?"
	fail_text = "The distress call has terminated"
	succeed_text = "The distress call has terminated"
	reward = 5000

/datum/overmap_event/tos_stranded/start() //Now we have a spawn. Let's do whatever this mission is supposed to. Override this when you make new missions
	target = new /obj/structure/overmap/constitution/wrecked(get_turf(spawner))
	priority_announce("Short range telemetry just detected a tachyon surge in your system, a ship appears to have materialized out of it. It appears to match archival designs but its transponder code is several hundred years out of date... Proceed to the ship and investigate.","Intercepted subspace transmission:",'sound/ai/commandreport.ogg')
	elements += target

/datum/overmap_event/tos_stranded/succeed()
	return //Impossible to succeed, or fail.

/datum/overmap_event/tos_stranded/fail()
	return //Impossible to succeed, or fail.

/area/ship/bridge/tos
	name = "Retro ship"
	class = "constitution"

/area/ship/bridge/tos/Entered(atom/movable/M)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, M)
	SEND_SIGNAL(M, COMSIG_ENTER_AREA, src) //The atom that enters the area
	if(!isliving(M))
		return

	var/mob/living/L = M
	if(!L.ckey)
		return
	if(L.client && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
		L.client.ambience_playing = 1
		SEND_SOUND(L, sound('DS13/sound/ambience/tos_bridge.ogg', repeat = 1, wait = 0, volume = 100, channel = CHANNEL_BUZZ)) //DeepSpace13 - engine hum

/*

/datum/overmap_event/defend_colony
	name = "Colony Assimilation"
	desc = "A mining colony faces assimilation! Protect the colony until help can arrive!"
	fail_text = "The colony has been assimilated...."
	succeed_text = "Fantastic work, the remaining civilians were evacuated before the borg cube could arrive!"
	reward = 15000
	var/wave = 1 // 1 / 3 attack stages.

/obj/structure/overmap/planet
	name = "Endaru"
	icon = 'DS13/icons/obj/meteor_storm.dmi'
	icon_state = "comet"
	class = "comet"
	max_shield_health = 0


/datum/overmap_event/defend_colony/start()
	START_PROCESSING(SSobj,src)
	var/I = rand(1,2)
	target = new /obj/structure/overmap/planet(get_turf(spawner))
	target.linked_event = src
	priority_announce("DISTRESS CALL: The civilian colony of [target.name] just finished developing experimental farming techniques. We're detecting multiple borg signatures converging on the colony. Protect [target.name] while we raise a fleet to deal with the borg!","Incoming hail:",'sound/ai/commandreport.ogg')



	for(var/num = 0 to I)
		var/obj/structure/overmap/ai/warbird = new /obj/structure/overmap/ai(get_turf(pick(orange(spawner, 6))))
		warbird.force_target = target //That freighter ain't no fortunate oneeeee n'aw lord IT AINT HEEEE IT AINT HEEEE
		warbird.nav_target = target
		warbird.target = target
		warbird.linked_event = src
		elements += warbird
*/