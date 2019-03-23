/*
Cadet
*/
/datum/job/cadet
	title = "Cadet"
	description = "'I want to join Starfleet!' As a Cadet you have no responsibilities and are expected to be new / learning the game. While ensigns are still expected to perform basic engineering tasks it's assumed that cadets don't really know how. <br> You have still received formal training at Starfleet Academy but you're on a field trip aboard a starship and are expected to listen to qualified crewmembers aboard (even ensigns!). <br> Primary roles: Learn the game, assist departments where possible"
	flag = CADET
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "all members of the crew"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	outfit = /datum/outfit/job/cadet
	paycheck = PAYCHECK_ASSISTANT // >getting paid to study
	paycheck_department = ACCOUNT_CIV

/datum/job/cadet/get_access()
	if(CONFIG_GET(flag/assistants_have_maint_access) || !CONFIG_GET(flag/jobs_have_minimal_access)) //Config has assistant maint access set
		. = ..()
		. |= list(ACCESS_MAINT_TUNNELS)
	else
		return ..()

/datum/outfit/job/cadet
	name = "Cadet"
	jobtype = /datum/job/cadet
	uniform = /obj/item/clothing/under/trek/cadet
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset
	id = /obj/item/card/id

/datum/outfit/job/cadet/post_equip(mob/living/carbon/human/H)
	. = ..()
	to_chat(H, "<span class='nicegreen'><b>Welcome to starfleet! As a cadet you have no responsibilities and are free to roam the ship. Other crewmembers will assist / teach you if you ask them, or you can ask our admin team for more information.</b></span>")

/obj/effect/landmark/start/cadet
	name = "Cadet"
	icon_state = "Cadet"
	icon = 'DS13/icons/effects/landmarks_static.dmi'