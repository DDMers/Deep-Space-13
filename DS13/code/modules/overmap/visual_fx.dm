/obj/structure/overmap
	var/damage_states = FALSE //If you want to display damage states, set this to true and follow the template found in miranda.dmi! It's icon_state-multiple of 20 (how damaged)

/obj/structure/overmap/proc/visual_damage()
	if(!damage_states)
		return
	var/progress = health //How damaged is this shield? We examine the position of index "I" in the for loop to check which directional we want to check
	var/goal = max_health //How much is the max hp of the shield? This is constant through all of them
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 20)//Round it down to 20%. We now change colours accordingly
	icon_state = "[initial(icon_state)]-[progress]"