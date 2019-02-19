
/obj/structure/overmap //AI vars
	var/AI_enabled = FALSE //Do you want this ship to be computer controlled?
	var/faction = "starfleet" //Change this if you want to make teams of AIs
	var/obj/structure/overmap/target = null //Used for AIs, lets us track a target.
	var/behaviour = "retaliate" //By default. Ais will only shoot back.
	var/list/possible_behaviours = list("aggressive", "retaliate", "peaceful") //This will be admin selectable when I add an overmap panel
	var/range = 10 //Firing range.

/obj/structure/overmap/AI
	name = "Romulan warbird class light cruiser"
	desc = "A dangerous ship which resembles a bird. It has a modest armament and is highly maneuverable."
	icon = 'DS13/icons/overmap/warbird.dmi'
	icon_state = "warbird"
	main_overmap = FALSE
	class = "enemy-romulan" //Feel free to add overmap controls for AIs later, future me.
	damage_states = FALSE //Damage FX
	damage = 10 //Will turn into 20 assuming weapons powered
	AI_enabled = TRUE //Start with an AI by default
	faction = "romulan" //Placeholder

/obj/structure/overmap/proc/take_control() //Take control of our ship, make it into an AI
	START_PROCESSING(SSobj, src) //Need to process to check for targets and so on.
	name = "[name] ([rand(0,1000)])"
	shield_power = 2 //So theyre not ultra squishy
	weapon_power = 1
	engine_power = 1
	max_shield_power = 4
	max_weapon_power = 4
	max_engine_power = 4
	power_slots -= 4
	AI_enabled = TRUE //Let the computer take the wheel
	check_power()

/obj/structure/overmap/proc/remove_control() //Stop the AI from controlling the ship
	AI_enabled = FALSE
	STOP_PROCESSING(SSobj,src)
	name = initial(name)
	nav_target = null
	target = null

/obj/structure/overmap/process()
	if(!AI_enabled)
		return
	if(vel < max_speed)
		vel += acceleration
	if(!process)
		process = TRUE
		start_process()
	if(target)
		if(get_dist(src, target) > range) //Target ran away. Move on.
			target = null
			nav_target = null
			pick_target()
		if(behaviour == "peaceful") //Peaceful means never retaliate, so return
			return
		nav_target = target
		fire(target, damage)//If we've gotten this far, we've probably been attacked, if not that then we're aggressive and are looking for a fight.
		return //No need to pick another if we have one and theyre in range
	else
		pick_target()

/obj/structure/overmap/proc/pick_target()
	if(behaviour == "aggressive")
		for(var/obj/structure/overmap/OM in orange(src, range))
			if(istype(OM))
				if(OM.faction != faction)
					target = OM
					nav_target = OM
					return
	return

/obj/structure/overmap/take_damage(var/atom/source, var/amount = 10)
	. = ..()
	if(AI_enabled)
		if(istype(source, /obj/structure/overmap) && behaviour == "retaliate")
			if(source == target)
				return //Already our target. Ignore
			target = source
			process() //Instant retaliate. Don't delay!


/obj/structure/overmap/Destroy()
	if(AI_enabled)
		STOP_PROCESSING(SSobj,src)
	. = ..()