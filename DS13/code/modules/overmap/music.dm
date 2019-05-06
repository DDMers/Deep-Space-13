GLOBAL_LIST_INIT(trek_music, world.file2list("strings/battle_music.txt"))
GLOBAL_DATUM_INIT(music_controller, /datum/music_controller, new)


/datum/music_controller
	var/name = "Music controller"
	var/list/possible_sounds = list()
	var/playing = FALSE //Failsafes to stop megaspam

/datum/music_controller/proc/stop()
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			var/client/CCE = M.client
			CCE.chatOutput.stopMusic()

/datum/music_controller/proc/force_stop() //When we're playing music and want it to STFU.
	stop()
	playing = TRUE
	for(var/datum/X in active_timers)
		qdel(X)

/datum/music_controller/proc/play(var/danger = FALSE)
	if(!playing) //no random switching to calm orchestral music mid fight!
		stop()
		playing = TRUE
		var/web_sound_input
		web_sound_input = "[pick(GLOB.trek_music)]"
		var/ytdl = CONFIG_GET(string/invoke_youtubedl)
		if(!ytdl)
			to_chat(world, "<span class='boldwarning'>Youtube-dl was not configured, unable to play battle music.</span>") //Check config.txt for the INVOKE_YOUTUBEDL value
			return
		if(istext(web_sound_input))
			var/web_sound_url = ""
			var/pitch
			if(length(web_sound_input))
				web_sound_input = trim(web_sound_input)
				if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
					to_chat(src, "<span class='boldwarning'>Non-http(s) URIs are not allowed.</span>")
					to_chat(src, "<span class='warning'>For youtube-dl shortcuts like ytsearch: please use the appropriate full url from the website.</span>")
					return
				var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
				var/list/output = world.shelleo("[ytdl] --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
				var/errorlevel = output[SHELLEO_ERRORLEVEL]
				var/stdout = output[SHELLEO_STDOUT]
				var/stderr = output[SHELLEO_STDERR]
				if(!errorlevel)
					var/list/data
					try
						data = json_decode(stdout)
					catch(var/exception/e)
						to_chat(src, "<span class='boldwarning'>Youtube-dl JSON parsing FAILED:</span>")
						to_chat(src, "<span class='warning'>[e]: [stdout]</span>")
						return

					if (data["url"])
						web_sound_url = data["url"]
				else
					to_chat(src, "<span class='boldwarning'>Youtube-dl URL retrieval FAILED:</span>")
					to_chat(src, "<span class='warning'>[stderr]</span>")
			if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
				return
			if(web_sound_url)
				for(var/mob/M in GLOB.player_list)
					if(M.client)
						var/client/C = M.client
						if((C.prefs.toggles & SOUND_MIDI) && C.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
							C.chatOutput.sendMusic(web_sound_url, pitch)
		addtimer(CALLBACK(src, .proc/reset), 3600) //6 mins. This will allow a new song to be selected after 6 minutes. If there is no further conflict when this timer runs out. Music will stop.

/datum/music_controller/proc/reset()
	playing = FALSE