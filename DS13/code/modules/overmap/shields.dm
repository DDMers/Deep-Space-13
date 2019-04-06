/*

Each ship has 8 directional shields

The ship sits in the middle like this

			S 	S	S
			S   (-= S
			S	S	S
As the ship turns with pixelmove, we do "angle to dir" to find which way it's facing
When we're shot at, we use a get_dir for the projectile that hits us
This then damages the appropriate shield

Dirs! (nicked from byond forum)
    if(1) return "North"
    if(2) return "South"
    if(4) return "East"
    if(5) return "Northeast"
    if(6) return "Southeast"
    if(8) return "West"
    if(9) return "Northwest"
    if(10) return "Southwest"

*/

#define FRONT 0
#define RIGHT 1
#define REAR 2
#define LEFT 3

/datum/shield_controller
	var/name = "Shield subsystem"
	var/health //Un-used for now
	var/max_health = 100	//Max health for each individual shield. Keep in mind a laser does about 20 damage
	var/obj/structure/overmap/holder //Whose shield am I?
	var/chargerate = 0.5 //How quickly do shields charge (per tick)

//Directional shield vars
/datum/shield_controller
	var/north = 0 //The following refer to the individual HPS of the directional shields. These will all get set accordingly based on get_dir
	var/south = 0
	var/east = 0
	var/west = 0

/datum/shield_controller/New()
	. = ..()
	START_PROCESSING(SSobj,src)
	addtimer(CALLBACK(src, .proc/replenish_shields), 20)//Allow time to pick up the max shields HP stat from our holder
	if(holder)
		max_health = holder.max_shield_health

/datum/shield_controller/proc/replenish_shields()
	adjust_all_shields(max_health) //Let's heal
	holder.apply_shield_boost()

/datum/shield_controller/proc/depower()
	north = 0
	south = 0
	east = 0
	west = 0
	generate_overlays()

/datum/shield_controller/process()
	if(!holder || holder.cloaked) //:^)
		return
	adjust_all_shields(chargerate)

//Damage logic. This is a looot of finite state machines :b1:

/datum/shield_controller/proc/absorb_damage(num, dir) //Damage the directional shields. If it returns TRUE then it blocked the attack successfully
	if(!isnum(dir) || !isnum(num))
		return
	switch(dir)
		if(FRONT)
			if(north >= num)
				north -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE //Captain, our shields are down!. This means the ship takes the damage instead of the shields :(

		if(REAR)
			if(south >= num)
				south -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE

		if(RIGHT)
			if(west >= num)
				west -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE

		if(LEFT)
			if(east >= num)
				east -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE


/datum/shield_controller/proc/adjust_all_shields(var/num)
	if(north < max_health)north += num 		//Set all the directionals to a desired num. Useful when spawning a ship or if you want to fully disable all shields
	if(south < max_health)south += num
	if(east < max_health)east += num
	if(west < max_health)west += num
	generate_overlays()
	return TRUE

/datum/shield_controller/proc/get_total_health()
	var/num = 0
	num += north 		//Set all the directionals to a desired num. Useful when spawning a ship or if you want to fully disable all shields
	num += south
	num += east
	num += west
	return num

/datum/shield_controller/proc/check_vulnerability()
	var/num = get_total_health()
	holder.check_power()
	if(num <= 0 || max_health <= 10)
		return TRUE
	var/total = (max_health * 4) //4 directional shields, each with a max of maxhealth.
	var/required = total/1.4 //Shields must be at least 60% healthy to resist transports and tractor beams
	if(num <= required)
		return TRUE //AKA it IS vulnerable
	else
		return FALSE //Above 70% health, so NOT vulnerable

/datum/shield_controller/proc/generate_overlays()
	if(!holder || max_health <= 0)
		return
	holder.cut_overlays()
	var/progress = 0 //How damaged is this shield? We examine the position of index "I" in the for loop to check which directional we want to check
	var/goal = max_health //How much is the max hp of the shield? This is constant through all of them
	var/shield_state
	for(var/I = 0 to 4) //Time to run through our dirs!
		switch(I)
			if(1)
				progress = north //So what HP are we looking at here?
				shield_state = "1"
			if(2)
				progress = south
				shield_state = "2"
			if(3)
				progress = east
				shield_state = "4"
			if(4 to 5) //JUST TRUST ME IT'S BYOND
				progress = west
				shield_state = "8"
		progress = CLAMP(progress, 0, goal)
		if(progress > 0)
			progress = round(((progress / goal) * 100), 20)//Round it down to 20%. We now change colours accordingly
		var/image/shield = new
		shield.icon = holder.icon
		shield.icon_state = shield_state
		switch(progress) //Colour in our shields based on damage
			if(0 to 19) shield.alpha = 0 //Blacked out
			if(20 to 39) shield.color = "#FF0000"//Red
			if(40 to 59)	shield.color = "#CE8D34" //orange
			if(60 to 79)	shield.color = "#FF9300"//Light orange
			if(80 to 90)	shield.color = "#FFFF00" //Yellow
			if(91 to 100) shield.color = "#4EC3D3"//Very light blue
		holder.add_overlay(shield)

/obj/structure/overmap
	var/heading = 0 // up is 0, down 180, right 90, left 270

/proc/get_quadrant_hit(var/obj/structure/overmap/firer, var/obj/structure/overmap/target) //The problem is sprite offsets! the sprites sit at the bottom left corner of ships. This will cause fuckery with shield hits
	var/hit_angle = find_hit_angle(firer, target)
	if(!target.heading)
		target.heading = target.angle
	if(target.heading < 0)
		target.heading = 450 + target.heading

	hit_angle += (450 - target.heading)
	hit_angle = SIMPLIFY_DEGREES(hit_angle)
//	to_chat(world, "ha [hit_angle], f x[firer.x]y[firer.y], t x[target.x]y[target.y] T heading:[target.angle] F heading: [firer.angle]") // Uncomment me for debug!

	switch(hit_angle)
		if(135 to 224, 0 to 44)
			return FRONT
		if(45 to 134)
			return RIGHT
		if(315 to 360)
			return REAR //rear
		if(225 to 314)
			return LEFT
	stack_trace("error with quadrant calc")


/proc/Get_Angle_Overmap(atom/movable/self,atom/movable/target)//For beams.
	if(!self || !target)
		return FALSE
	var/turf/us = get_center(self)
	var/turf/them = get_center(target)
	return 450 - SIMPLIFY_DEGREES(ATAN2((32*them.y+target.real_pixel_y) - (32*us.y+self.real_pixel_y), (32*them.x+target.real_pixel_x) - (32*us.x+self.real_pixel_x)))

/obj/structure/overmap/proc/center()
	get_center(src)

/proc/get_center(var/obj/structure/overmap/ship)	//Ex: 64 x 64. Starts at bottom left of the ship.
	var/turf/displaced = get_turf(ship) //First. Get our starting point, then add Xs and Ys onto it.
	var/xx = displaced.x
	var/yy = displaced.y//Offset time, based off of sprite size, we attempt to find the center of an overmap ship.
	var/icon/I = icon(ship.icon,ship.icon_state,SOUTH) //Again, all our sprites are done in the "south" dir, facing right
	var/target_x = I.Width()/2
	var/target_y = I.Height()/2
	xx += target_x / 32 //Now we have half the icon size, how many turfs of an offset do we need?
	yy += target_y / 32
	var/turf/T = locate(xx,yy,ship.z)
	return T

/proc/find_hit_angle(atom/firer, atom/target)
	var/target_angle = Get_Angle_Overmap(firer, target)
	return(target_angle)

#undef FRONT
#undef RIGHT
#undef REAR
#undef LEFT