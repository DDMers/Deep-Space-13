/client/proc/get_all()
	set category = "Special Verbs"
	set desc="Teleport people to you en masse."
	set name="Get all players"
	var/turf/target = mob.loc
	var/teleportall = null
	teleportall = alert("Teleport who?","teleportation panel","everyone","this z level only")
	if(!teleportall)
		return
	switch(teleportall)
		if("everyone")
			var/list/mobs = GLOB.player_list.Copy()
			for(var/X in mobs)
				if(X && ismob(X) && !istype(X, /mob/dead/new_player))
					var/mob/player = X
					SEND_SOUND(player, 'DS13/sound/effects/qflash.ogg')
					player.forceMove(target)
		else
			var/list/mobs = GLOB.player_list.Copy()
			for(var/X in mobs)
				if(X && ismob(X) && !istype(X, /mob/dead/new_player))
					var/mob/player = X
					if(player.z != mob.z)
						continue
					SEND_SOUND(player, 'DS13/sound/effects/qflash.ogg')
					player.forceMove(target)
	message_admins("[ADMIN_LOOKUPFLW(mob)] teleported all players to their location.")