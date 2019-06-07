GLOBAL_LIST_INIT(overmap_event_spawns, list())

//NOTES:
// IF YOU ARE MAKING AN OPEN ENDED MISSION, SET ITS COMPLETED TO TRUE SO IT DOESNT HOLD UP OTHER MISSIONS!//

/datum/overmap_event
	var/name = "Romulan freighter attack"
	var/desc = "DISTRESS CALL: A fortunate class freighter is under attack by a Romulan battle group! Requesting immediate assistance."
	var/fail_text = "The freighter has been destroyed. All hands lost."
	var/succeed_text = "Incoming hail. You turned up at just the right time, we owe you one!."
	var/obj/effect/landmark/overmap_event_spawn/spawner
	var/list/elements = list() //All the shit we're gonna spawn, yeah.
	var/obj/structure/overmap/ai/target //In this case, the freighter. If this dies then fail the mission!
	var/reward = 10000 //10 K Credits? Sheesh what a rip off!
	var/completed = FALSE //stop repeat confirmation of completion.

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
	if(completed)
		return
	to_chat(world, "<span class='notice'>Starfleet command has issued a commendation to the crew of [station_name()]. The ship has been allocated extra operational budget ([reward]) by Starfleet command.</span>")
	priority_announce(succeed_text,"Incoming hail:",'sound/ai/commandreport.ogg')
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(reward)
	spawner.used = FALSE
	target.vel = 10 //Make them warp away
	completed = TRUE
	addtimer(CALLBACK(src, .proc/clear_elements), 60) //Clear up everything after 6 seconds

/datum/overmap_event/proc/clear_elements()
	if(target)
		qdel(target)

/datum/overmap_event/proc/fail()
	if(completed)
		return
	to_chat(world, "<span class='warning'>Starfleet command has issued an official reprimand on [station_name()]'s permanent record.</span>")
	priority_announce(fail_text)
	spawner.used = FALSE
	completed = TRUE

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
	var/obj/structure/overmap/ai/simulated/bigbird = new /obj/structure/overmap/ai/simulated(get_turf(pick(orange(spawner,6)))) //Make one warbird that can be salvaged / boarded.
	bigbird.force_target = target //That freighter ain't no fortunate oneeeee n'aw lord IT AINT HEEEE IT AINT HEEEE
	bigbird.nav_target = target
	bigbird.target = target
	bigbird.linked_event = src
	elements += bigbird

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
	var/obj/structure/overmap/freighter

/obj/structure/meteor
	name = "Meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	var/meteor_damage = 10 //She's takin' a beating captain!
	density = TRUE

/obj/structure/meteor/Bumped(atom/movable/AM)
	. = ..()
	crash(AM)

/obj/structure/meteor/Initialize()
	. = ..()
	icon_state = pick("small", "large", "glowing","sharp","small1","dust")
	SpinAnimation(1000,1000)

/obj/structure/meteor/proc/crash(atom/target)
	if(!istype(target, /obj/structure/overmap))
		return
	var/obj/structure/overmap/SS = target
	SS.vel = 0
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
	if(completed)
		return
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
	completed = TRUE

/datum/overmap_event/comet //A harmless comet
	name = "Comet flyby"
	desc = "A harmless comet rich in minerals is entering your system."
	fail_text = "The comet has been destroyed."
	succeed_text = "Good work. That should allow for some nice upgrades."
	reward = 5000
	completed = TRUE //Open ended mission that you can't complete traditionally

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
	completed = TRUE //Open ended mission that you can't complete traditionally

/datum/overmap_event/crashed_borg/start() //Now we have a spawn. Let's do whatever this mission is supposed to. Override this when you make new missions
	target = new /obj/structure/overmap/moon(get_turf(spawner))
	priority_announce("Attention [station_name()]. We have received a priority one distress call from a prison transport vessel. We believe the vessel had to make an emergency landing, check for any survivors. The transmission appears to lead to a small moon","Priority one distress signal:",'sound/ai/commandreport.ogg')
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
	layer = 2.9
	movement_block = TRUE

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
	completed = TRUE //Open ended mission that you can't complete traditionally

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
	looping_ambience = 'DS13/sound/ambience/tos_bridge.ogg'

/area/ship/borg_cube
	name = "Borg cube"
	class = "borg-cube"
	ambientsounds = list('DS13/sound/ambience/ambiborg1.ogg','DS13/sound/ambience/ambiborg2.ogg','DS13/sound/ambience/ambiborg3.ogg')
	requires_power = FALSE
	has_gravity = TRUE
	looping_ambience = 'DS13/sound/ambience/jeffries_hum.ogg'

/obj/effect/mob_spawn/human/corpse/borg_drone
	name = "Deactivated borg drone"
	suit = /obj/item/clothing/suit/space/borg

/mob/living/simple_animal/hostile/retaliate/borg_drone
	name = "Tactical drone"
	desc = "A mindless drone. It will not attack unless provoked"
	icon = 'DS13/icons/mob/simple_human.dmi'
	icon_state = "borg_drone"
	icon_living = "borg_drone"
	icon_dead = "borg_drone_dead"
	icon_gib = "borg_drone_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "probes"
	response_disarm = "wrestles aside"
	response_harm = "assimilates"
	speak = list("Priority alert received: Grid. 235. Subjunction 4-beta", "Moving to intercept", "Tertiary subprocessor confirmed", "We are the borg")
	emote_see = list("processes its surroundings", "points its laser at something")
	speak_chance = 1
	a_intent = INTENT_HARM
	maxHealth = 105
	health = 105
	speed = 1
	harm_intent_damage = 12
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "attacks"
	attack_sound = 'DS13/sound/effects/borg/grab.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = TRUE
	loot = list(/obj/effect/mob_spawn/human/corpse/borg_drone)

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 500
	unsuitable_atmos_damage = 0

/mob/living/simple_animal/hostile/retaliate/borg_drone/AttackingTarget()
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.Jitter(3)
		M.visible_message("<span class='warning'>[src] pierces [M] with their assimilation tubules!</span>")
		playsound(M.loc, 'sound/weapons/pierce.ogg', 100,1)
		if(do_after(src, 50, target = M)) //5 seconds
			M.mind.make_borg()
			var/obj/item/organ/body_egg/borgNanites/nanitelattice = new(get_turf(M))
			nanitelattice.Insert(M)
			playsound(src.loc, 'DS13/sound/effects/borg/resistanceisfutile.ogg', 100, 0)
			enemies -= M
			return

/obj/structure/overmap_component/borg_relay
	name = "Auxiliary processor subjunction"
	desc = "A machine of inordinate parts which helps to coordinate the thousands of drones present on borg ships... It would probably weaken the borg considerably if you destroyed this."
	icon_state = "subjunction"
	pixel_y = 32
	density = FALSE

/obj/structure/overmap_component/borg_relay/take_damage(amount)
	if(!linked)
		find_overmap()
	if(obj_integrity <= amount)
		Destroy()
		return
	. = ..()

/obj/structure/overmap_component/borg_relay/Destroy()
	if(!linked)
		find_overmap()
	obj_integrity = 1000
	alpha = 0
	mouse_opacity = FALSE
	if(linked.health >= 300)
		linked.health -= 100
		linked.max_health -= 100
	if(linked.weapon_power >= 3)
		linked.weapon_power -= 1
	say("Subprocessor inoperative. Unable to coordinate weapon systems. Maneuver drones to subjunction [rand(0-100)] to compensate.")
	. = ..()

/datum/overmap_event/borg_cube //This is a challenge. You SERIOUSLY need to board the cube and weaken it first, or youre in for a bad time.
	name = "Borg cube"
	desc = "Board the borg cube to weaken it, then blast it!"
	fail_text = "All hands, set condition 1 throughout the fleet. This is not a drill."
	succeed_text = "Thank god. It's gone... We'll send some ships to pick through the debris."
	reward = 20000

/datum/overmap_event/borg_cube/start()
	target = new /obj/structure/overmap/ai/assimilated/cube(get_turf(spawner))
	priority_announce("Attention all ships. Set condition RED throughout the fleet. A damaged borg cube has been sighted in your system. Stand-by for instructions","Intercepted subspace transmission:",'DS13/sound/effects/borg/borg_flyby.ogg')
	elements += target
	target.linked_event = src
	sleep(60)
	priority_announce("Long range scans have detected structural weak points in the borg cube. You need to destroy the borg processor subjunctions in order to stand any chance of facing the borg cube. Good luck, and godspeed. You're all that we can spare, [station_name()].","Starfleet critical priority comminication:",'sound/ai/commandreport.ogg')

/datum/overmap_event/borg_cube/check_completion(var/obj/structure/overmap/what)
	if(target)
		if(what == target) //This is the default one. If this is being called, the freighter has been destroyed and you fail!
			succeed()
			return

/obj/effect/mob_spawn/human/alive/trek/museum
	name = "Tal shiar agent"
	assignedrole = "romulan"
	outfit = /datum/outfit/talshiar
	flavour_text = "<span class='big bold'>You are a tal shiar agent!</span><br> You and your comrades have been dispatched to the museum ship Enterprise under the guise of starfleet inspectors. You're equipped with state of the art stealth tech, so you can assume any identity you need but be careful, and be subtle.<br> It is an incredibly weak ship, but it should provide enough cover for you to complete your true goal: <b>Capture the main ship for the romulan empire by using your ominous tricorder on the bridge!</b>"

/datum/outfit/talshiar
	name = "Tal shiar agent"
	uniform = /obj/item/clothing/under/trek/romulan
	accessory = null
	l_pocket = /obj/item/pda
	belt = /obj/item/gun/energy/phaser
	shoes = /obj/item/clothing/shoes/jackboots
	suit = null
	gloves = /obj/item/clothing/gloves/color/black
	head = null
	id = /obj/item/card/id
	back = /obj/item/storage/backpack/satchel
	ears = /obj/item/radio/headset/syndicate/alt
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(/obj/item/storage/box,/obj/item/storage/box/syndie_kit/chameleon=1,/obj/item/book/granter/martial/cqc=1,/obj/item/reagent_containers/syringe/mulligan=1,/obj/item/ship_hijack_spawner=1,/obj/item/phaser_pack/large=1)
	implants = list(/obj/item/implant/storage) //Eases up on the meta a bit

/obj/item/ship_hijack_spawner //Device used by tal shiar to formally take over the ship
	name = "Ominous tricorder"
	desc = "A device which allows you to summon a ship network hijacker, allowing one to take over a ship. ONCE YOU SPAWN THE HIJACKER, THERE IS NO TURNING BACK."
	icon = 'DS13/icons/obj/device.dmi'
	icon_state = "health"
	w_class = 1

/obj/item/ship_hijack_spawner/attack_self(mob/user)
	. = ..()
	var/area/AR = get_area(src)
	if(!AR.linked_overmap || !AR.linked_overmap.main_overmap)
		to_chat(user, "<span class='warning'>This device can only be used to capture [station_name()], starfleet's main ship in this sector.</span>")
		return
	var/obj/structure/overmap_component/helm/helmcheck = locate(/obj/structure/overmap_component/helm) in AR
	if(!helmcheck)
		to_chat(user, "<span class='warning>You can only do this from the bridge!</span>")
		return
	if(AR.linked_overmap.capture_in_progress)
		to_chat(user, "<span class='warning'>Someone else has already placed a capture device.</span>")
		return
	var/question = alert("Really spawn a ship capture device? THERE IS NO GOING BACK ONCE YOU DO THIS",name,"yes","no")
	if(question == "no" || !question)
		return
	new /obj/effect/temp_visual/transporter/mob(get_turf(src))
	playsound(src.loc, 'DS13/sound/effects/transporter/send.ogg', 100, 4)
	to_chat(user, "A capture device has been transported in, Jolan Tru!")
	new /obj/structure/ship_hijacker(get_turf(user))
	qdel(src)

/obj/structure/ship_hijacker
	name = "Optronic data hijacker"
	desc = "A huge device which will systematically purge pre-existing command codes from a ship's command subroutines while simultaneously plotting in a pre-programmed course for the ship to follow. <b> This can't be good...</b>"
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	obj_integrity = 250
	max_integrity = 250 //Takes a beating to remove.
	anchored = TRUE
	density = TRUE
	var/active = FALSE
	var/start_time = 0
	var/end_time = 0
	var/domtime = 1480 //2 : 30 minutes to capture the ship ((when the anthem stops, you lose)).

/obj/structure/ship_hijacker/examine(mob/user)
	. = ..()
	if(!active)
		return
	to_chat(user, "<span class='warning'>It is currently attempting to hijack [station_name()]!</span>")
	var/timeleft = (end_time - world.time)/10
	to_chat(user, "<span class='warning'>A display shows that there's [timeleft] seconds left until the takeover is complete!</span>")


/obj/structure/ship_hijacker/attack_hand(mob/user)
	if(active)
		to_chat(user, "<span class='notice'>There is already an active system takeover in progress!</span>")
		return
	var/question = alert("Are you ready to begin a system takeover of [station_name()]?",name,"yes","no")
	if(question == "no" || !question)
		return
	active = TRUE
	var/area/AR = get_area(src)
	if(AR.linked_overmap)
		AR.linked_overmap.capture_in_progress = TRUE
	priority_announce("WARNING: Optronic data pathway decription attempt detected in [AR]. Hostile takeover in progress!","LCARS computer subsystem:",'sound/ai/commandreport.ogg')
	start_time = world.time
	end_time = start_time + domtime
	to_chat(user, "<span class='notice'>You have begun a system takeover, defend this device for the romulan empire!</span>")
	light_color = LIGHT_COLOR_RED
	set_light(5)
	icon_state = "dominator-red"
	sound_to_playing_players('DS13/sound/ambience/ship_takeover.ogg') //ALL CREDIT GOES TO: Volker400 https://www.youtube.com/watch?v=ooS0Hop_zhk
	GLOB.music_controller.force_stop() //Avoids annoying overlapping music.
	START_PROCESSING(SSobj,src)

/obj/structure/ship_hijacker/process()
	if(!active)
		return
	if(world.time >= end_time)
		active = FALSE
		priority_announce("Ieiuqh warp drive avaihh'etrehh-capable rrhiet khina 'hh ours. Temmehrr'dochai ch'rihan. Jolan Tru!","LCARS computer subsystem:",'sound/ai/commandreport.ogg')
		Cinematic(CINEMATIC_ROMULAN,world)
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = 1
		STOP_PROCESSING(SSobj,src)
		qdel(src)

/obj/structure/ship_hijacker/Destroy()
	if(active)
		for(var/mob/M in GLOB.player_list) //Stop the romulan anthem.
			if(M.client)
				SEND_SOUND(M, sound(null))
		priority_announce("Hostile takeover attempt ceased. Cycling encryption and command codes.","LCARS computer subsystem:",'sound/ai/commandreport.ogg')
		GLOB.music_controller.reset()
	var/area/AR = get_area(src)
	if(AR.linked_overmap)
		AR.linked_overmap.capture_in_progress = FALSE
	. = ..()

/area/ship/bridge/museum
	name = "USS Enterprise (NX-01)"
	class = "nx01"
	looping_ambience = 'DS13/sound/ambience/nx01.ogg'
	has_gravity = TRUE

/datum/overmap_event/museum_hijack //Star trekkin' a...wait where the fuck are we?
	name = "Hijacked museum ship (spawns available on spawners menu!)"
	desc = "Capture the main ship"
	fail_text = "You just let one of the most historically important ships in starfleet history be destroyed! You'll be lucky to wear a starfleet uniform ever again after the inquiry's over!."
	succeed_text = "The distress call has terminated"
	reward = 5000
	completed = TRUE //Open ended mission that you can't complete traditionally

/datum/overmap_event/museum_hijack/start() //Now we have a spawn. Let's do whatever this mission is supposed to. Override this when you make new missions
	target = new /obj/structure/overmap/nx01(get_turf(spawner))
	priority_announce("[station_name()]. We've just received a report from the NX01-Enterprise exhibit. It appears the enterprise is missing...? You are ordered to investigate what has happened, but be advised that this could possibly just be a clerical error.","Intercepted subspace transmission:",'sound/ai/commandreport.ogg')
	elements += target
	sleep(20)//Give it a chance to link.
	if(target.linked_area)
		for(var/obj/structure/overmap_component/XR in target.linked_area) //We call this to update the components with our new ship object, as it wasn't created at runtime!
			XR.find_overmap()

/datum/overmap_event/museum_hijack/succeed()
	return //This is an open ended objective, really. It's designed for RP


//Space UPS. Originally coded by alexkar, fixed by kmc//

/area/ship/station/delivery_destination
	name = "Relief Station"
	class = "delivery_destination"
	noteleport = TRUE
	requires_power = FALSE
	has_gravity = TRUE

/area/ship/station/delivery_source
	name = "Supply Outpost"
	class = "delivery_source"
	noteleport = TRUE
	requires_power = FALSE
	has_gravity = TRUE

/obj/structure/sealedcrate
	name = "Relief supplies crate"
	desc = "A crate filled with relief supplies for the people of betazed, it'd be best to not touch it.."
	icon = 'icons/obj/crates.dmi'
	icon_state = "reliefsupplies"
	var/datum/overmap_event/linked_event
	max_integrity = 120
	density = TRUE

/obj/structure/sealedcrate/attack_hand(mob/user)
	. = ..()
	to_chat(user,"<span class='warning'>An indicator flashes on [src]: ACCESS DENIED</span>") //HEY LEAVE THIS ALONE OR YOUR SCRUBBING PLASMA CONDUITS

/obj/structure/sealedcrate/Destroy()
	if(linked_event)
		linked_event.fail()
	if(prob(30))
		new /obj/item/storage/firstaid/regular(get_turf(src)) //Yes. You can totally steal food and medical supplies from a dying planet
		new /obj/item/storage/firstaid/toxin(get_turf(src))
	else
		new /obj/item/reagent_containers/food/snacks/rationpack(get_turf(src))
		new /obj/item/reagent_containers/food/snacks/rationpack(get_turf(src))
		new /obj/item/reagent_containers/food/snacks/rationpack(get_turf(src))
	. = ..()

/obj/structure/overmap_component/crate_receiver
	name = "Crate delivery point"
	desc = "A storage device which automatically sorts crates for planetary delivery."
	icon_state = "cratepad"
	density = FALSE
	anchored = TRUE
	opacity = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/busy = FALSE //Stops crossed firing over and over
	layer = 2.7

/obj/structure/overmap_component/crate_receiver/Crossed(atom/movable/AM)
	. = ..()
	if(busy)
		return
	if(istype(AM,/obj/structure/sealedcrate))
		say("Scanning crate..")
		busy = TRUE
		var/obj/structure/sealedcrate/SC = AM
		if(SC.linked_event)
			var/datum/overmap_event/deliver_item/DI = SC.linked_event
			DI.crate_amount --
			DI.check_completion(SC)
			say("Crate receipt: CONFIRMED!")
			AM.forceMove(src)
		busy = FALSE

/obj/effect/landmark/sealed_crate_spawn
	name = "Sealed crate spawn point"

/datum/overmap_event/deliver_item
	name = "Relief supplies delivery"
	desc = "There's been a massive natural disaster on Betazed! We need you to transfer some humanitarian supplies to a nearby relief outpost so they can be circulated amongst the population."
	fail_text = "The relief supplies have been destroyed..."
	succeed_text = "Excellent work, the items were succesfully delivered. Our humanitarian teams will work on distributing them now."
	reward = 10000
	var/crate_amount = 0 //How many crates do they have to deliver?
	var/obj/structure/overmap/delivery_source/source
	var/obj/structure/overmap/delivery_destination/destination
	var/sourceoutpostid = 2
	var/destinationoutpostid = 1
	var/list/crates = list()

/datum/overmap_event/deliver_item/New()
	. = ..()
	sourceoutpostid = rand(150,265)
	destinationoutpostid = rand(1,3)
	desc = "[station_name()]. There's been a massive natural disaster on Betazed! We need you to transfer some humanitarian supplies from Outpost [sourceoutpostid] to Relief Station [destinationoutpostid]. To help them recover. We can't afford to lose any of the supplies..."

/datum/overmap_event/deliver_item/start()
	var/obj/effect/landmark/sealed_crate_spawn/CS
	for(var/X in GLOB.landmarks_list)
		if(istype(X, /obj/effect/landmark/sealed_crate_spawn))
			CS = X
	if(!CS)
		message_admins("[name] tried to spawn, but there's no crate spawners in your map!")
		completed = TRUE
		return
	for(var/i = 0 to rand(10,15)) //Need to make it at least somewhat challenging eh?
		var/obj/structure/sealedcrate/supplies = new /obj/structure/sealedcrate(get_turf(pick(orange(CS,3))))
		crates += supplies
		supplies.linked_event = src
	crate_amount = crates.len
	source = new /obj/structure/overmap/delivery_source(get_turf(spawner))
	source.name = "Outpost [sourceoutpostid]"
	var/newx = CLAMP(spawner.x + rand(-10,25),world.maxx - 10,0)
	var/newy = CLAMP(spawner.y + rand(-10,25),world.maxy - 10,0)
	var/turf/other_spawn = locate(newx,newy,spawner.z)
	destination = new /obj/structure/overmap/delivery_destination(get_turf(other_spawn))
	destination.name = "Relief Station [destinationoutpostid]"
	priority_announce(desc)

/datum/overmap_event/deliver_item/succeed()
	if(completed)
		return
	to_chat(world, "<span class='notice'>Starfleet command has issued a commendation to the crew of [station_name()]. The ship has been allocated extra operational budget ([reward]) by Starfleet command.</span>")
	priority_announce(succeed_text,"Incoming hail:",'sound/ai/commandreport.ogg')
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(reward)
	spawner.used = FALSE
	completed = TRUE

/datum/overmap_event/deliver_item/clear_elements()
	return FALSE //Dont delete the stations!

/datum/overmap_event/deliver_item/check_completion(var/atom/what)
	if(what == destination || what == source)
		fail()
	if(crate_amount <= 0)
		succeed()

/obj/structure/overmap/delivery_source
	name = "Delivery source"
	desc = "A secure outpost said to house humanitarian supplies"
	icon = 'DS13/icons/overmap/station.dmi'
	icon_state = "station"
	main_overmap = FALSE
	damage = 10 //Will turn into 20 assuming weapons powered //what does this var even do?who cares.
	class = "delivery_source"
	max_speed = 0
	turnspeed = 0
	movement_block = TRUE //You can't turn a station :) //YES YOU CAN! YOU JUST CANT SEE IT!
	pixel_x = -32
	pixel_y = -32
	max_shield_power = 0

/obj/structure/overmap/delivery_destination
	name = "Delivery destination"
	desc = "A humanitarian outpost which can distribute relief supplies"
	icon = 'DS13/icons/overmap/station.dmi'
	icon_state = "station"
	main_overmap = FALSE
	damage = 10 //Will turn into 20 assuming weapons powered //what does this var even do?who cares.
	class = "delivery_destination"
	max_speed = 0
	turnspeed = 0
	movement_block = TRUE //You can't turn a station :) //YES YOU CAN! YOU JUST CANT SEE IT!
	pixel_x = -32
	pixel_y = -32

/obj/structure/overmap/delivery_destination/Destroy()
	if(linked_event)
		linked_event.fail()
	. = ..()

/obj/structure/overmap/delivery_source/Destroy()
	if(linked_event)
		linked_event.fail()
	. = ..()

/area/ship/m_class
	name = "Minshara class planet"
	class = "mclass"
	noteleport = TRUE
	requires_power = FALSE
	has_gravity = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	looping_ambience = 'DS13/sound/ambience/m_class.ogg' //Credit: https://www.youtube.com/watch?v=FFtrUH4sdNI

/obj/structure/overmap/mclass
	name = "M class planet"
	icon = 'DS13/icons/overmap/planets.dmi'
	icon_state = "mclass"
	class = "mclass"
	max_shield_health = 0
	layer = 2.9

/datum/mood_event/shoreleave
	description = "<span class='nicegreen'>What a lovely day.</span>\n"
	mood_change = 4
	timeout = 4000

/area/ship/m_class/Entered(atom/movable/M)
	. = ..()
	to_chat(M, "<span class'nicegreen'>You feel the sun shining down on your back, what a lovely day.</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "shoreleave", /datum/mood_event/shoreleave)

/datum/overmap_event/m_class
	name = "M-class planet"
	desc = "Long range scans have detected an M-class planet near your location. We'd like you to beam down and perform some botanical surveys by scanning any interesting plants with a botany tricorder. We'd also like you to dig up a few soil samples with a shovel, there's some nice dense mud which seems to be teeming with life. If nothing else, this should be a great shore leave opportunity."
	fail_text = "Did you just destroy an entire planet..!?"
	succeed_text = "Good work crew, take those botanical specimens with you when you rotate back to earth."
	reward = 10000
	var/plant_amount = 0 //How many plants do they have to scan?
	var/list/plants = list()


/datum/overmap_event/m_class/start()
	var/obj/effect/landmark/plant_spawn/PS
	for(var/X in GLOB.landmarks_list)
		if(istype(X, /obj/effect/landmark/plant_spawn))
			PS = X
	if(!PS)
		message_admins("[name] tried to spawn, but there's no plant spawners in your map!")
		completed = TRUE
		return
	for(var/i = 0 to rand(5,10)) //Need to make it at least somewhat challenging eh?
		var/obj/item/twohanded/required/kirbyplants/random/obvious_plant = new /obj/item/twohanded/required/kirbyplants/random(get_turf(pick(orange(PS,12))))
		obvious_plant.linked_event = src
		obvious_plant.name = "Botanically interesting plant"
		plants += obvious_plant
	for(var/i = 0 to rand(2,4))
		var/obj/machinery/hydroponics/soil/dirt = new /obj/machinery/hydroponics/soil(get_turf(pick(orange(PS,12))))
		dirt.linked_event = src
		dirt.name = "Botanically interesting soil"
		dirt.desc = "A densely packed piece of earth, it should make for a great soil sample if you <b>dig it up</b> with a spade or shovel."
		plants += dirt
	plant_amount = plants.len
	target = new /obj/structure/overmap/mclass(get_turf(spawner))
	priority_announce("[desc]","Incoming hail:",'sound/ai/commandreport.ogg')

/datum/overmap_event/m_class/check_completion(var/atom/what)
	if(what == target)
		fail()
	if(plant_amount <= 0)
		succeed()

/datum/overmap_event/m_class/succeed()
	if(completed)
		return
	to_chat(world, "<span class='notice'>Starfleet command has issued a commendation to the crew of [station_name()]. The ship has been allocated extra operational budget ([reward]) by Starfleet command.</span>")
	priority_announce(succeed_text,"Incoming hail:",'sound/ai/commandreport.ogg')
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	completed = TRUE
	if(D)
		D.adjust_money(reward)
	return

/datum/overmap_event/m_class/clear_elements()
	return FALSE //Dont delete the M CLASS planet!

/obj/item/twohanded/required/kirbyplants
	var/datum/overmap_event/m_class/linked_event
	var/scanned = FALSE //Sanity check

/obj/machinery/hydroponics/soil
	var/datum/overmap_event/m_class/linked_event
	var/scanned = FALSE //Sanity check

/obj/item/twohanded/required/kirbyplants/attackby(obj/item/I, mob/user)
	. = ..()
	if(!linked_event)
		return
	if(scanned)
		to_chat(user, "You've already scanned [src], what more could you possibly want to know?")
		return
	if(istype(I, /obj/item/plant_analyzer))
		playsound(loc, 'DS13/sound/effects/items/tricorder.ogg',100)
		to_chat(user, "<span class='notice>You start to analyze [src].</span>")
		if(do_after(user,50, target=src))
			to_chat(user, "<span class='notice'>You've finished analyzing [src], what a fascinating plant!</span>")
			scanned = TRUE
			linked_event.plant_amount --
			linked_event.check_completion(src)
			playsound(loc, 'DS13/sound/effects/items/tricorder_open.ogg',100)

/obj/machinery/hydroponics/soil/attackby(obj/item/I, mob/user)
	if(scanned)
		to_chat(user, "You've already collected a soil sample from here...")
		return ..()
	if(istype(I, /obj/item/shovel/spade) || istype(I, /obj/item/shovel))
		if(!linked_event)
			return ..()
		playsound(loc, 'sound/effects/shovel_dig.ogg',100)
		to_chat(user, "<span class='notice>You start to collect a soil sample from [src].</span>")
		if(do_after(user,50, target=src))
			playsound(loc, 'sound/effects/shovel_dig.ogg',100)
			to_chat(user, "<span class='notice'>You collect a soil sample from [src].</span>")
			scanned = TRUE
			linked_event.plant_amount --
			linked_event.check_completion(src)
	. = ..()

/obj/effect/landmark/plant_spawn
	name = "Interesting plant spawner (away mission)"

/obj/effect/mob_spawn/human/alive/trek/m_class
	name = "M class planet tribesman"
	assignedrole = "stranded crewman"
	outfit = /datum/outfit/ashwalker
	flavour_text = "<span class='big bold'>You are a tribesman!</span> <b> The stories tell of a great voyage by your ancestors, but several generations have caused your origins to become unclear... <br> You are a peaceful tribe, but you may attack outsiders if provoked."

/area/ship/merc //Mercenary ship
	name = "CEV Whisp"
	class = "whisp"
	has_gravity = TRUE

/obj/effect/mob_spawn/human/alive/trek/merc
	name = "Mercenary"
	assignedrole = "mercenary"
	outfit = /datum/outfit/mercenary
	flavour_text = "<span class='big bold'>You are a mercenary!</span> <b> You're part of a ragtag crew who answer to no-one but themselves </b> <br> While you are able to kill, it must only be in the name of business or self-defense. Do not attack someone without getting paid for it - and remember, your true master is whoever pays you the most."

/obj/effect/mob_spawn/human/alive/trek/merc/special(mob/living/new_spawn)  //Give them a new name
	var/merc_prefix = pick("Agent", "Operative", "Specialist", "Privateer","Commander", "Solid", "Punished")
	var/merc_suffix = pick("kiefer", "wirewolf", "hunter", "able archer", "guardian", "bane", "rodriguez", "ripley", "archer", "neo", "darius", "wren", "koi", "viper", "grasshopper", "snake")
	var/species = pick(/datum/species/human, /datum/species/klingon, /datum/species/andorian) //very multicultural mercs.
	new_spawn.set_species(species)
	var/merc_name = "[merc_prefix] [merc_suffix]"
	new_spawn.fully_replace_character_name(null,merc_name)

/datum/outfit/mercenary
	name = "Mercenary"
	uniform = /obj/item/clothing/under/syndicate/camo
	accessory = /obj/item/clothing/accessory/ds9_jacket
	l_pocket = /obj/item/pda
	shoes = /obj/item/clothing/shoes/jackboots
	suit = null
	gloves = /obj/item/clothing/gloves/color/black
	head = null
	id = /obj/item/card/id
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(/obj/item/clothing/mask/gas/syndicate=1)

/obj/structure/overmap/whisp
	name = "CEV Whisp"
	desc = "An aging civilian ship that's been heavily modified with internal reinforcements and advanced weapon systems."
	icon = 'DS13/icons/overmap/whisp.dmi'
	icon_state = "whisp"
	max_health = 120 //Weak, but not trash
	damage = 10 //Will turn into 20 assuming weapons powered
	class = "whisp"
	turnspeed = 1
	acceleration = 0.4
	damage_states = FALSE

/datum/overmap_event/mercenaries
	name = "Mercenaries"
	desc = "A civilian ship has entered your system. Designation: CEV Whisp. You are ordered to investigate what they're doing in this system however, we have no reason to believe they're hostile."
	fail_text = "The ship has been destroyed"
	succeed_text = "It appeared to be harmless."
	reward = 5000
	completed = TRUE //Open ended mission that you can't complete traditionally

/datum/overmap_event/mercenaries/fail() //Open ended
	return FALSE

/datum/overmap_event/mercenaries/succeed()
	return FALSE

/datum/overmap_event/mercenaries/start() //Now we have a spawn. Let's do whatever this mission is supposed to. Override this when you make new missions
	target = new /obj/structure/overmap/whisp(get_turf(spawner))
	priority_announce("[desc]","Low priority alert:",'sound/ai/commandreport.ogg')
	elements += target
	for(var/obj/structure/overmap_component/XR in target.linked_area) //We call this to update the components with our new pod object, as it wasn't created at runtime!
		XR.find_overmap()
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