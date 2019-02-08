GLOBAL_DATUM_INIT(borg_collective, /datum/borg_collective, new)

/datum/borg_collective
	var/name = "unassigned unimatrix"
	var/list/drones = list() //All of the current drones in our unimatrix
	var/last_alert = 0 //When did we last alert our drones? stops infinite repeating of "40% OF STATION ASSIMILATED"
	var/borg_whisper_chance = 30 //Chance to hear the collective speak when a message is sent
	var/adaptation = 0 //how adapted are they out of 100
	var/drone_count = 0 //Increments by one every conversion. Shows which drone was assimilated first and so on. "First of three, tertiary adjunct of unimatrix 115"

/datum/borg_collective/New()
	. = ..()
	name = "unimatrix [rand(0,999)]"

/datum/borg_collective/proc/message_collective(var/who, var/what) //Input both as text. Who and What are both strings.
	if(!who)
		who = "Unknown"
	for(var/mob/living/carbon/human/S in drones)
		if(!S || !istype(S))
			continue
		to_chat(S, "<b>[who]:</b><font color='#19CF44'>[what]</font>")
	if(prob(borg_whisper_chance))
		var/sound/picked = pick('DS13/sound/effects/borg/whisper-single.ogg','DS13/sound/effects/borg/whisper-double.ogg')
		send_sound_collective(picked)

/datum/borg_collective/proc/send_sound_collective(var/sound)
	for(var/mob/living/S in drones)
		if(!S || !istype(S))
			continue
		SEND_SOUND(S, sound)


/datum/borg_collective/proc/isplayervalid(var/mob/living/carbon/human/player)
	if(!player.client)
		return FALSE //No AFKS because we can't actually borgify them.
	if(player.onCentCom())
		return FALSE
	if(player.onSyndieBase())
		return FALSE
	return TRUE

/datum/borg_collective/proc/check_completion()
	if(world.time <= 100 || GLOB.player_list.len <= 1) //Round literally just started or it's a lone person testing, so don't instantly end the round!
		return
	var/converted = drones.len //%age of people on the station who are borg'd
	var/targets = 0
	for(var/mob/living/player in GLOB.player_list)
		if(player.stat != DEAD)
			if(!isplayervalid(player))
				continue
			targets ++
	converted = CLAMP(converted, 0, targets)
	var/rounded = round(((converted / targets) * 100), 10)
	switch(rounded)
		if(10 to 20)
			if(last_alert >= 1)
				return
			send_sound_collective('DS13/sound/effects/borg/progress/10.ogg')
			last_alert = 1
			return
		if(40 to 50)
			if(last_alert >= 2)
				return
			send_sound_collective('DS13/sound/effects/borg/progress/40.ogg')
			last_alert = 2
			return
		if(51 to 60)
			if(last_alert >= 3)
				return
			send_sound_collective('DS13/sound/effects/borg/progress/60.ogg')
			last_alert = 3
			return
		if(70 to 80)
			if(last_alert >= 4)
				return
			send_sound_collective('DS13/sound/effects/borg/progress/70.ogg')
			last_alert = 4
			return
		if(81 to 100)//80% of the station converted is a win
			SSticker.mode.check_finished(TRUE)
			SSticker.force_ending = 1
			to_chat(world, "<span_class='ratvar'>The borg have assimilated the station!</span>")
			SEND_SOUND(world,'DS13/sound/effects/borg/progress/victory.ogg')
