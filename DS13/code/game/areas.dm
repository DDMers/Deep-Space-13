/area/ship/bridge
	name = "Starship bridge" //Special areas for extra ambience. This also protects pilots from explosions

/area/ship/bridge/miranda
	name = "Bridge (Miranda class)"
	class = "miranda"

/area/ship/bridge/warbird
	name = "Bridge (warbird)"
	class = "warbird"

/area/ship/bridge/saladin
	name = "Bridge (saladin)"
	class = "saladin"

/area/ship/engineering
	name = "Starship engineering" //Special areas for extra ambience

/area/ship/engineering/miranda
	name = "Engineering (Miranda class)"
	class = "miranda"

/area/ship/engineering/warbird
	name = "Engineering (warbird)"
	class = "warbird"

/area/ship/engineering/saladin
	name = "Engineering (saladin)"
	class = "saladin"

/area/ship/bridge/Entered(atom/movable/M)
	// Ambience goes down here -- make sure to list each area separately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
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
		SEND_SOUND(L, sound('DS13/sound/ambience/bridge.ogg', repeat = 1, wait = 0, volume = 100, channel = CHANNEL_BUZZ)) //DeepSpace13 - engine hum

/area/ship/engineering/Entered(atom/movable/M)
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
		SEND_SOUND(L, sound('DS13/sound/ambience/engineering.ogg', repeat = 1, wait = 0, volume = 80, channel = CHANNEL_BUZZ)) //DeepSpace13 - engine hum

/area/ship/engineering/Exited(atom/movable/M)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, M)
	SEND_SIGNAL(M, COMSIG_EXIT_AREA, src) //The atom that exits the area
	if(!isliving(M))
		return

	var/mob/living/L = M
	if(!L.ckey)
		return
	L.client.ResetAmbiencePlayed()
	L.client.ambience_playing = 0
	if(L.client && !L.client.ambience_playing && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
		L.client.ambience_playing = 1
		SEND_SOUND(L, sound('DS13/sound/ambience/enginehum.ogg', repeat = 1, wait = 0, volume = 100, channel = CHANNEL_BUZZ)) //DeepSpace13 - engine hum

/area/ship/bridge/Exited(atom/movable/M)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, M)
	SEND_SIGNAL(M, COMSIG_EXIT_AREA, src) //The atom that exits the area
	if(!isliving(M))
		return

	var/mob/living/L = M
	if(!L.ckey)
		return
	L.client.ResetAmbiencePlayed()
	L.client.ambience_playing = 0
	if(L.client && !L.client.ambience_playing && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
		L.client.ambience_playing = 1
		SEND_SOUND(L, sound('DS13/sound/ambience/enginehum.ogg', repeat = 1, wait = 0, volume = 100, channel = CHANNEL_BUZZ)) //DeepSpace13 - engine hum