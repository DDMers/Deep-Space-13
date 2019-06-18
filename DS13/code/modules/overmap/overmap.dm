/*

Hey! Listen!
Stuff you need to know:
When making a new ship, please include its directional shields in the SAME ICON AS THE SHIP so you can ensure they fit!

*/
GLOBAL_LIST_INIT(overmap_ships, list())

#define WARP_5 15 //FAST

/area
	var/obj/structure/overmap/linked_overmap
	var/class = "none" //Make sure this matches the "class" of an overmap if you want them to autolink.

/obj/structure/overmap
	name = "Ship"
	desc = "Since Zephram cochrane's first flight, humanity has always had its head in the stars."
	icon = 'DS13/icons/overmap/pancake.dmi'
	icon_state = "pancake"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	density = TRUE
	var/obj/shield_overlay/shield_overlay
	var/class = "nothing" //This is a nothing class heavy cruiser
	var/transporter_range = 8 //N Tile transporter range
	var/list/linked_areas = list()
	var/list/attackers = list() //Which ships have attacked us? for AI mode.
	var/list/components = list() //stuff that's linked to us
	var/obj/machinery/power/warp_core/warp_core
	var/warp_ready = TRUE //Are we ready to warp?
	var/warping = FALSE //Are we mid warp? This tells movement code to do the special FX for when we exit warp if we slow down too much.
	var/datum/action/innate/warp/warp_action = new
	var/max_warp = WARP_5
	var/capture_in_progress = FALSE //Is someone trying to hijack the ship?

/obj/structure/overmap/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/structure/overmap)) //overmaps may pass other overmaps
		return TRUE
	else
		. = ..()

/obj/structure/overmap/can_be_pulled(mob/user) //Hahahah NO
	return FALSE

/obj/shield_overlay
	name = ""
	animate_movement = 0

//Combat variables
/obj/structure/overmap
	max_integrity = 200
	var/ammo_type = /obj/item/ammo_casing/energy/laser
	var/datum/shield_controller/shields
	var/max_shield_health = 100 //Change this if you want STRONG shields
	var/health = 0
	var/max_health = 200
	var/area/override_linked_ship //If we're not the main overmap, we'd best link to an area! If you place an overmap in /area/ship it will NOT be the main overmap, so use station areas instead!
	var/main_overmap = FALSE //Is this the main overmap? Is it gonna be linked to all station areas?
	var/list/powered_components = list() //Used in components.dm, do we have any system components that require power?
	var/list/subsystem_controllers = list() //What subsystem controllers do we have? (components.dm, bottom of page)
	var/obj/structure/overmap/force_target //Used in AI / event code

/obj/structure/overmap/proc/OvermapInitialize() //Called before the while loop which allows movement
	shield_overlay = new(get_turf(src))
	shields = new(src)
	shields.holder = src
	shields.max_health = max_shield_health
	shields.generate_overlays()
	health = max_health
	check_power()
	GLOB.overmap_ships += src
	find_area()

/obj/structure/overmap/Destroy()
	. = ..()

/obj/structure/overmap/proc/apply_shield_boost() //If you want to start out with some shields that are stronger than others
	return

/obj/structure/overmap/proc/find_area()
	if(main_overmap)
		for(var/X in GLOB.teleportlocs) //Apply us to all the station areas then
			var/area/area = GLOB.teleportlocs[X] //Pick a station area and yeet it.
			area.linked_overmap = src
	for(var/area/AR in GLOB.sortedAreas)
		if(AR.class == class)
			AR.linked_overmap = src
			linked_area = AR

/datum/action/innate/warp
	name = "Engage warp"
	icon_icon = 'DS13/icons/actions/actions_ship.dmi'
	button_icon_state = "warp"
	var/obj/structure/overmap/our_ship

/datum/action/innate/warp/Activate()
	our_ship.try_warp()

/obj/structure/overmap/proc/GrantActions(mob/living/user)
	if(warp_action)
		warp_action.target = user
		warp_action.Grant(user)
		warp_action.our_ship = src

/obj/structure/overmap/proc/RemoveActions(mob/living/user)
	if(warp_action)
		warp_action.target = null
		warp_action.Remove(user)
		warp_action.our_ship = null

/obj/structure/overmap/proc/try_warp()
	if(engine_power <= 0)
		if(pilot)
			to_chat(pilot, "<span class='notice'>Unable to comply, engine subsystem is disabled.</span>")
		return
	if(warping)
		if(pilot)
			to_chat(pilot, "<span class='notice'>Disengaging warp engines.</span>")
		vel = 0.5
		stop_warping()
		return
	if(!warp_core || !warp_ready)
		if(pilot)
			to_chat(pilot, "<span class='notice'>Warp engines are recharging.</span>")
		return
	if(!warp_core.try_warp())
		if(pilot)
			to_chat(pilot, "<span class='notice'>Insufficient power. Ensure the warp core is active, and that the warp coils are charged.</span>")
		return
	addtimer(CALLBACK(src, .proc/reset_warp_cooldown), 300)//One warp per 30 seconds.
	addtimer(CALLBACK(src, .proc/finish_warp), 45)
	warp_ready = FALSE
	if(pilot)
		to_chat(pilot, "<span class='notice'>Charging warp engines. Please stand by.</span>")
	warp_fx()

/obj/structure/overmap/proc/warp_fx()
	if(main_overmap)
		for(var/mob/player in GLOB.player_list)
			if(is_station_level(player.z))
				SEND_SOUND(player, 'DS13/sound/effects/warpcore/warp.ogg')
				to_chat(player, "<span_class='notice'><b>You feel the deck plating under your feet lurch forwards slightly.</b></span>")
		var/list/areas = list()
		areas = GLOB.teleportlocs.Copy()
		for(var/AR in areas)
			var/area/ARR = areas[AR]
			if(istype(ARR, /area/space))
				continue
			ARR.parallax_movedir = NORTH
	else
		if(!linked_area)
			return
		linked_area.parallax_movedir = NORTH
		for(var/X in linked_area)
			if(!X)
				continue
			if(ismob(X))
				var/mob/player = X
				SEND_SOUND(player, 'DS13/sound/effects/warpcore/warp.ogg')
				to_chat(player, "<span_class='notice'><b>You feel the deck plating under your feet lurch forwards slightly.</b></span>")

/obj/structure/overmap/proc/stop_warping()
	warping = FALSE
	if(main_overmap)
		var/list/areas = list()
		areas = GLOB.teleportlocs.Copy()
		for(var/AR in areas)
			var/area/ARR = areas[AR]
			ARR.parallax_movedir = null
		for(var/mob/player in GLOB.player_list)
			if(is_station_level(player.z))
				if(prob(50))
					shake_camera(player, 1,3)
				else
					shake_camera(player, 2,2)
				to_chat(player, "<span_class='notice'><b>You can feel a jolt as the ship slows down.</b></span>")
				SEND_SOUND(player, 'DS13/sound/effects/warpcore/warp_exit.ogg')
	else
		if(!linked_area)
			return
		linked_area.parallax_movedir = null
		for(var/X in linked_area)
			if(ismob(X))
				var/mob/player = X
				to_chat(player, "<span_class='notice'><b>You can feel a jolt as the ship slows down.</b></span>")
				SEND_SOUND(player, 'DS13/sound/effects/warpcore/warp_exit.ogg')

/obj/structure/overmap/proc/reset_warp_cooldown()
	warp_ready = TRUE

/obj/structure/overmap/proc/finish_warp()
	warping = TRUE
	vel = max_warp
	if(main_overmap)
		for(var/mob/player in GLOB.player_list)
			if(is_station_level(player.z))
				if(prob(50))
					shake_camera(player, 1,3)
				else
					shake_camera(player, 2,2)
				if(ishuman(player))
					var/mob/living/carbon/human/H = player
					if(H.buckled)
						to_chat(H, "<span_class='notice'><b>Acceleration presses you into your seat!</b></span>")


#undef WARP_5