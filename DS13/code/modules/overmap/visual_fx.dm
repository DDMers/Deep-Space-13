/obj/structure/overmap
	var/damage_states = FALSE //If you want to display damage states, set this to true and follow the template found in miranda.dmi! It's icon_state-multiple of 20 (how damaged)
	var/voice_cooldown = 40 //4 second voice cooldown to prevent SPAM.
	var/voice_ready = TRUE //Is the voice alert stuff on cooldown?
	var/last_hull_warned = 0 //AT what %age did we warn our captain that the hull was? Avoids spam of HULL IS AT 75% CAPTAIN!!!!!!
	var/hull_warn_countdown = FALSE //Are we counting down to reset the warnings? This takes a minute.
	var/last_shields_warned = 0

/obj/structure/overmap/proc/visual_damage()
	if(!damage_states)
		return
	var/progress = health //How damaged is this shield? We examine the position of index "I" in the for loop to check which directional we want to check
	var/goal = max_health //How much is the max hp of the shield? This is constant through all of them
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 20)//Round it down to 20%. We now apply visual damage
	icon_state = "[initial(icon_state)]-[progress]"
	progress = health
	goal = max_health
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 5)//Round it down to 5s so the voice lines work
	var/sound/sound
	switch(progress)
		if(100)
			if(last_hull_warned == 100) return
			sound = 'DS13/sound/effects/voice/Hull100.ogg'
			last_hull_warned = 100
		if(70 to 75)
			if(last_hull_warned == 80) return
			sound = 'DS13/sound/effects/voice/Hull75.ogg'
			last_hull_warned = 80
		if(45 to 50)
			if(last_hull_warned == 50) return
			sound = 'DS13/sound/effects/voice/Hull50.ogg'
			last_hull_warned = 50
		if(20 to 25)
			if(last_hull_warned == 25) return
			sound = 'DS13/sound/effects/voice/Hull25.ogg'
			last_hull_warned = 25
		if(15 to 19)
			if(last_hull_warned == 20) return
			sound = 'DS13/sound/effects/voice/Hull20.ogg'
			last_hull_warned = 20
		if(10 to 15)
			if(last_hull_warned == 15) return
			sound = 'DS13/sound/effects/voice/Hull15.ogg'
			last_hull_warned = 15
		if(6 to 10)
			if(last_hull_warned == 10) return
			sound = 'DS13/sound/effects/voice/Hull10.ogg'
			last_hull_warned = 10
		if(0 to 5)
			if(last_hull_warned == 5) return
			sound = 'DS13/sound/effects/voice/Hull05.ogg'
			last_hull_warned = 5
	if(!hull_warn_countdown)
		addtimer(CALLBACK(src, .proc/reset_hull_warning), 600)
		hull_warn_countdown = TRUE
	if(sound)
		voice_alert(sound, override)

/obj/structure/overmap/proc/shield_alert()
	var/progress = shields.get_total_health()
	var/goal = shields.max_health * 8 //Remember, 8 directionals, so 8 max healths
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 5)//Round it down to 5s so the voice lines work
	var/sound/sound
	switch(progress)
		if(100)
			if(last_shields_warned == 100) return
			last_shields_warned = 100
			sound = 'DS13/sound/effects/voice/shields100.ogg'
		if(51 to 80)
			if(last_shields_warned == 75) return
			last_shields_warned = 75
			sound = 'DS13/sound/effects/voice/shields50.ogg'
		if(26 to 50)
			if(last_shields_warned == 25) return
			last_shields_warned = 25
			sound = 'DS13/sound/effects/voice/MultipleShieldsOffline.ogg'
		if(0 to 25)
			if(last_shields_warned == 0) return
			last_shields_warned = 0
			sound = 'DS13/sound/effects/voice/ShieldsFailed.ogg'
	if(!hull_warn_countdown)
		addtimer(CALLBACK(src, .proc/reset_hull_warning), 60)
		hull_warn_countdown = TRUE
	if(sound)
		voice_alert(sound, override)

/obj/structure/overmap/proc/reset_hull_warning()
	hull_warn_countdown = FALSE
	last_hull_warned = 0

/obj/structure/overmap/proc/reset_voice()
	voice_ready = TRUE

/obj/structure/overmap/proc/voice_alert(var/sound/S, var/override = FALSE) //Play voice alerts for things like hull damage, shields breaking etc.
	if(!voice_ready && !override)
		return FALSE
	if(!S)
		return
	addtimer(CALLBACK(src, .proc/reset_voice), voice_cooldown)
	voice_ready = FALSE
	send_sound_crew(S)
