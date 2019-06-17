/*
Bridge crew
*/
/datum/job/bridge_crew
	title = "Bridge Officer"
	description = "'Attack pattern omega!' Bridge officers are still ensigns, but with added duties. As a bridge officer you will take up one of the three stations on the bridge and follow any orders the captain gives. <br> When you spawn, you should decide what station you're going to take amongst yourselves but if you encounter a problem , defer to the captain's judgement. <br> If you're playing this role, you should be familiar with our mechanics and comfortable with combat as this role will test you.<br> Primary roles: Operate the ship."
	flag = BRIDGE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the first officer"
	selection_color = "#ccccff"
	access = list(ACCESS_HEADS, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_HEADS, ACCESS_MAINT_TUNNELS)
	outfit = /datum/outfit/job/bridge
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

/datum/outfit/job/bridge
	name = "Bridge Officer"
	jobtype = /datum/job/bridge_crew
	uniform = /obj/item/clothing/under/trek/command/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset/heads/hop
	id = /obj/item/card/id

/obj/effect/landmark/start/bridge_officer
	name = "Bridge Officer"
	icon_state = "Bridge Officer"
	icon = 'DS13/icons/effects/landmarks_static.dmi'