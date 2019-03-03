/client/proc/get_all()
	set category = "Special Verbs"
	set desc="Teleport people to you en masse."
	set name="Get all players"
	var/turf/target = get_turf(mob)
	var/teleportall = null
	teleportall = alert("Teleport who?","teleportation panel","everyone","this z level only")
	if(!teleportall)
		return
	switch(teleportall)
		if("everyone")
			for(var/X in GLOB.player_list)
				if(X && isliving(X))
					var/mob/player = X
					SEND_SOUND(player, 'DS13/sound/effects/qflash.ogg')
					player.forceMove(target)
		else
			for(var/X in GLOB.player_list)
				if(X && isliving(X))
					var/mob/player = X
					if(player.z != mob.z)
						continue
					SEND_SOUND(player, 'DS13/sound/effects/qflash.ogg')
					player.forceMove(target)
	message_admins("[ADMIN_LOOKUPFLW(mob)] teleported all players to their location.")