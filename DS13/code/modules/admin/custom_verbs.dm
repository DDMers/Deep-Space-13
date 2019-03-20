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

//Credit to yogstation! Right click any tile to revert atmos grief:
/client/proc/fix_air(var/turf/open/T in world)
	set name = "Fix Air"
	set category = "Admin"
	set desc = "Fixes air in specified radius."

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(check_rights(R_ADMIN))
		var/range=input("Enter range:","Num",2) as num
		message_admins("[key_name_admin(usr)] fixed air with range [range] in area [T.loc.name]")
		log_game("[key_name_admin(usr)] fixed air with range [range] in area [T.loc.name]")
		var/datum/gas_mixture/GM = new
		for(var/turf/open/F in range(range,T))
			if(F.blocks_air)
			//skip walls
				continue
			GM.parse_gas_string(F.initial_gas_mix)
			F.copy_air(GM)
			F.update_visuals()