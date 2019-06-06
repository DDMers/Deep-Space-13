/area
	var/explosion_exempt = FALSE //For any tiny ships that would get oneshotted by an explosion.
	var/looping_ambience = null //If you want an ambient sound to play on loop while theyre in a specific area, set this

/area/ship/bridge
	name = "Starship bridge" //Special areas for extra ambience. This also protects pilots from explosions
	looping_ambience = 'DS13/sound/ambience/bridge.ogg'

/area/ship/bridge/miranda
	name = "Bridge (Miranda class)"
	class = "miranda"

/area/ship/bridge/warbird
	name = "Bridge (warbird)"
	class = "warbird"
	has_gravity = STANDARD_GRAVITY

/area/ship/bridge/akira
	name = "Bridge"
	class = "akira"
	noteleport = FALSE

/area/ship/bridge/saladin
	name = "Bridge (saladin)"
	class = "saladin"

/area/ship/engineering
	name = "Starship engineering" //Special areas for extra ambience
	looping_ambience = 'DS13/sound/ambience/engineering.ogg'

/area/ship/engineering/miranda
	name = "Engineering (Miranda class)"
	class = "miranda"

/area/ship/engineering/warbird
	name = "Engineering (warbird)"
	class = "warbird"

/area/ship/engineering/saladin
	name = "Engineering (saladin)"
	class = "saladin"

/area/ship/engineering/akira
	name = "Engineering"
	class = "akira"
	noteleport = FALSE

/area/maintenance
	looping_ambience = 'DS13/sound/ambience/jeffries_hum.ogg'

/area/medical
	looping_ambience = 'DS13/sound/ambience/sickbay.ogg'

/area/science
	looping_ambience = 'DS13/sound/ambience/science.ogg'

/area/hallway/primary/aft //Engineering hallway
	looping_ambience = 'DS13/sound/ambience/engineering_hall.ogg'

/area/Entered(atom/movable/M)
	// Ambience goes down here -- make sure to list each area separately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, M)
	SEND_SIGNAL(M, COMSIG_ENTER_AREA, src) //The atom that enters the area
	if(!isliving(M))
		return

	var/mob/living/L = M
	if(!L.ckey)
		return
	if(!looping_ambience)
		return
	if(L.client && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
		L.client.ambience_playing = 1
		SEND_SOUND(L, sound(looping_ambience, repeat = 1, wait = 0, volume = 100, channel = CHANNEL_BUZZ)) //DeepSpace13 - engine hum
	if(prob(35))
		if(!ambientsounds.len)
			return
		var/sound = pick(ambientsounds)

		if(!L.client.played)
			SEND_SOUND(L, sound(sound, repeat = 0, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE))
			L.client.played = TRUE
			addtimer(CALLBACK(L.client, /client/proc/ResetAmbiencePlayed), 600)

/area/Exited(atom/movable/M)
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
		SEND_SOUND(L, sound('DS13/sound/ambience/enginehum2.ogg', repeat = 1, wait = 0, volume = 100, channel = CHANNEL_BUZZ)) //DeepSpace13 - engine hum