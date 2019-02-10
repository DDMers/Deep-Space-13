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

/datum/shield_controller
	var/name = "Shield subsystem"
	var/health //Un-used for now
	var/max_health = 100	//Max health for each individual shield. Keep in mind a laser does about 20 damage
	var/obj/structure/overmap/holder //Whose shield am I?
	var/chargerate = 2.5 //How quickly do shields charge (per tick)

//Directional shield vars
/datum/shield_controller
	var/north = 0 //The following refer to the individual HPS of the directional shields. These will all get set accordingly based on get_dir
	var/south = 0
	var/east = 0
	var/west = 0
	var/northeast = 0
	var/northwest = 0
	var/southeast = 0
	var/southwest = 0

/datum/shield_controller/New()
	. = ..()
	START_PROCESSING(SSobj,src)
	addtimer(CALLBACK(src, .proc/replenish_shields), 20)//Allow time to pick up the max shields HP stat from our holder

/datum/shield_controller/proc/replenish_shields()
	adjust_all_shields(max_health) //Let's heal
	holder.apply_shield_boost()

/datum/shield_controller/proc/depower()
	north = 0
	south = 0
	east = 0
	west = 0
	northeast = 0
	northwest = 0
	southeast = 0
	southwest = 0
	generate_overlays()


/datum/shield_controller/process()
	adjust_all_shields(chargerate)

//Damage logic. This is a looot of finite state machines :b1:

/datum/shield_controller/proc/absorb_damage(num, dir) //Damage the directional shields. If it returns TRUE then it blocked the attack successfully
	switch(dir)
		if(1)
			if(north >= num)
				north -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE //Captain, our shields are down!. This means the ship takes the damage instead of the shields :(

		if(2)
			if(south >= num)
				south -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE

		if(4)
			if(east >= num)
				east -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE

		if(5)
			if(southwest >= num)
				southwest -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE

		if(6)
			if(southeast >= num)
				southeast -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE

		if(8)
			if(west >= num)
				west -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE

		if(9)
			if(northwest >= num)
				northwest -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE

		if(10)
			if(northeast >= num)
				northeast -= num
				generate_overlays() //Took a hit, so visually update the shields :)
				return TRUE //Took the hit successfully
			return FALSE

/datum/shield_controller/proc/adjust_all_shields(var/num)
	if(north < max_health)north += num 		//Set all the directionals to a desired num. Useful when spawning a ship or if you want to fully disable all shields
	if(south < max_health)south += num
	if(east < max_health)east += num
	if(west < max_health)west += num
	if(northeast < max_health)northeast += num
	if(northwest < max_health)northwest += num
	if(southeast < max_health)southeast += num
	if(southwest < max_health)southwest += num
	generate_overlays()
	return TRUE

/datum/shield_controller/proc/generate_overlays()
	if(!holder)
		return
	holder.shield_overlay.cut_overlays()
	var/progress = 0 //How damaged is this shield? We examine the position of index "I" in the for loop to check which directional we want to check
	var/goal = max_health //How much is the max hp of the shield? This is constant through all of them
	for(var/I = 0, I < 11, I++) //Time to run through our dirs!
		switch(I)
			if(1) progress = north //So what HP are we looking at here?
			if(2) progress = south
			if(3) continue //Not a cardinal
			if(4) progress = east
			if(5) progress = southwest
			if(6) progress = southeast //Remember, max health is the max health any directional shield can have at any given time.
			if(7) continue //Not a cardinal
			if(8) progress = west
			if(9) progress = northwest
			if(10) progress = northeast
		var/stored = 0
		var/test = max_health*2
		if(progress >= test)
			stored = progress //To apply the double shield visual FX for when you overcharge one specific shield.
		progress = CLAMP(progress, 0, goal)
		progress = round(((progress / goal) * 100), 20)//Round it down to 20%. We now change colours accordingly
		var/image/shield = new
		shield.icon = holder.icon
		shield.icon_state = "[I]"
		if(stored >= 1)
			shield.icon_state = "[I]-d" //Double shield! Shows you've boosted this specific shield
		shield.color = "#CE8D34" //orange, just in case the number falls out of range
		switch(progress) //Colour in our shields based on damage
			if(0 to 10) shield.color = "#000000"//black
			if(11 to 39) shield.color = "#FF0000"//Red
			if(40 to 59)	shield.color = "#CE8D34" //orange
			if(60 to 79)	shield.color = "#FF9300"//Light orange
			if(80 to 90)	shield.color = "#4EC3D3" //Light ish green
			if(91 to 100) shield.color = "#00E0FF"//Very light blue
		holder.shield_overlay.add_overlay(shield)

