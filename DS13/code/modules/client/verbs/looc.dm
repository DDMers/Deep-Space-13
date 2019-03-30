/client/verb/looc(msg as text) //not stolen from yog I promise ((thanks nich))
	set name = "LOOC"
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(QDELETED(src))
		return

	if(!mob)
		return

	if(!holder)
		if(!GLOB.looc_allowed)
			to_chat(src, "<span class='danger'>LOOC is globally muted.</span>")
			return

		if(!GLOB.dlooc_allowed && (mob.stat == DEAD || isobserver(mob)))
			to_chat(usr, "<span class='danger'>LOOC for dead mobs has been turned off.</span>")
			return

		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use LOOC (muted).</span>")
			return

	if(is_banned_from(ckey, "OOC"))
		to_chat(src, "<span class='danger'>You have been banned from LOOC.</span>")
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if(!holder)
		if(handle_spam_prevention(msg, MUTE_OOC))
			return

		if(findtext(msg, "byond://"))
			to_chat(src, "<span class='bold'>Advertising other servers is not allowed.</span>")
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in LOOC: [msg]")
			return

	mob.log_talk(raw_msg, LOG_OOC)

	var/list/clients_to_hear = list()
	var/turf/looc_source = get_turf(mob.get_looc_source())
	var/list/stuff_that_hears = list()
	for(var/mob/M in get_hear(7, looc_source))
		stuff_that_hears += M

	for(var/mob/M in stuff_that_hears)
		if((((M.client_mobs_in_contents) && (M.client_mobs_in_contents.len <= 0)) || !M.client_mobs_in_contents))
			continue

		if(M.client)
			clients_to_hear += M.client

		for(var/mob/mob in M.client_mobs_in_contents)
			if(mob.client && mob.client.prefs)
				clients_to_hear += mob.client

	var/message_admin = "<span class='looc'>LOOC: [ADMIN_LOOKUPFLW(mob)]: [msg]</span>"
	var/message_admin_remote = "<span class='looc'><font color='black'>(R)</font>LOOC: [ADMIN_LOOKUPFLW(mob)]: [msg]</span>"
	var/message_regular
	if(isobserver(mob)) //if you're a spooky ghost
		var/key_to_print = mob.key
		if(holder && holder.fakekey)
			key_to_print = holder.fakekey //stealthminning

		message_regular = "<span class='looc'>LOOC: [key_to_print]: [msg]</span>"
	else
		message_regular = "<span class='looc'>LOOC: [mob.name]: [msg]</span>"

	for(var/T in GLOB.clients)
		var/client/C = T
		if(C in GLOB.admins)
			if(C in clients_to_hear)
				to_chat(C, message_admin)
			else
				to_chat(C, message_admin_remote)

		else if(C in clients_to_hear)
			to_chat(C, message_regular)

/mob/proc/get_looc_source()
	return src

/mob/living/silicon/ai/get_looc_source()
	if(eyeobj)
		return eyeobj

	return src

/proc/toggle_looc(toggle = null)
	if(toggle != null) //if we're specifically en/disabling ooc
		if(toggle != GLOB.looc_allowed)
			GLOB.looc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.looc_allowed = !GLOB.looc_allowed
	to_chat(world, "<B>The LOOC channel has been globally [GLOB.looc_allowed ? "enabled" : "disabled"].</B>")

/proc/toggle_dlooc(toggle = null)
	if(toggle != null)
		if(toggle != GLOB.dlooc_allowed)
			GLOB.dlooc_allowed = toggle
		else
			return
	else
		GLOB.dlooc_allowed = !GLOB.dlooc_allowed

/client/proc/get_looc()
	var/msg = input(src, null, "looc \"text\"") as text|null
	looc(msg)