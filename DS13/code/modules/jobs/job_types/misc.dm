/datum/job/yeoman
	title = "Yeoman"
	flag = YEOMAN
	department_head = list("Captain")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "The first officer"
	selection_color = "#ccccff"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	description = "Get me a drink.<br>As a yeoman, your job is to look after the captain so they can remain effective. This usually translates into fetching food, relaying messages, fetching things.<br>\
	As a Yeoman, you hold the rank of ensign, and if there is no current captain you should make yourself useful elsewhere.<br>\
	Primary roles: Assist the captain and follow their orders.\
	"
	outfit = /datum/outfit/job/yeoman

	access = list(ACCESS_HEADS,ACCESS_MAINT_TUNNELS,ACCESS_EVA,ACCESS_BAR,ACCESS_KITCHEN)
	minimal_access = list(ACCESS_HEADS,ACCESS_MAINT_TUNNELS,ACCESS_EVA,ACCESS_BAR,ACCESS_KITCHEN)
	paycheck = PAYCHECK_ASSISTANT
	paycheck_department = ACCOUNT_ENG

/datum/outfit/job/yeoman
	name = "Yeoman"
	jobtype = /datum/job/yeoman

	id = /obj/item/card/id/silver
	belt = /obj/item/pda
	ears = /obj/item/radio/headset/heads/hop
	gloves = /obj/item/clothing/gloves/color/black
	uniform =  /obj/item/clothing/under/trek/command/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots
	backpack_contents = list(/obj/item/reagent_containers/food/drinks/shaker=1,/obj/item/clipboard=1, /obj/item/clothing/accessory/ds9_jacket/formal=1)

/obj/effect/landmark/start/yeoman
	name = "Yeoman"
	icon_state = "Yeoman"


/datum/job/offduty_sec
	title = "Security Officer (off duty)"
	flag = OFFDUTY_SEC
	department_head = list("Head of Security")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of security, though you aren't obligated to do your job outside of an emergency"
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	description = "You are a security officer who is currently off duty. Relax, kick back at the bar, talk to people... The choice is yours. You may be called upon / promoted in emergency situations however you're generally expected to just roleplay."

	outfit = /datum/outfit/job/offduty_sec

	access = list(ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS)
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

/datum/outfit/job/offduty_sec
	name = "Security Officer (off duty)"
	jobtype = /datum/job/offduty_sec

	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda
	r_pocket = /obj/item/phaser_pack
	head = /obj/item/clothing/head/beret/sec/navyofficer

/obj/effect/landmark/start/offduty/sec
	name = "Security Officer (off duty)"
	icon_state = "Security Officer (off duty)"


/datum/job/offduty_doctor
	title = "Medical Doctor (off duty)"
	flag = OFFDUTY_DOCTOR
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer, though you aren't obligated to do your job outside of an emergency"
	selection_color = "#ffeef0"
	description = "You are a medical officer who is currently off duty and thus have fewer responsibilities. Relax, kick back at the bar, talk to people... The choice is yours. You may be called upon / promoted in emergency situations however you're generally expected to just roleplay."

	outfit = /datum/outfit/job/offduty_doctor

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE,ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE,ACCESS_MAINT_TUNNELS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

/datum/outfit/job/offduty_doctor
	name = "Medical Doctor (off duty)"
	uniform = /obj/item/clothing/under/trek/medsci/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda
	belt = /obj/item/pda/medical
	ears = /obj/item/radio/headset/headset_med
	suit_store = /obj/item/flashlight/pen

/obj/effect/landmark/start/offduty/doctor
	name = "Medical Doctor (off duty)"
	icon_state = "Medical Doctor (off duty)"


/datum/job/offduty_engineer
	title = "Engineer (off duty)"
	flag = OFFDUTY_ENGINEER
	department_head = list("Chief Engineer")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief engineer, though you aren't obligated to do your job outside of an emergency"
	selection_color = "#fff5cc"
	exp_requirements = 20
	exp_type = EXP_TYPE_CREW
	description = "You are an engineering officer who is currently off duty and thus have fewer responsibilities. Relax, kick back at the bar, talk to people... The choice is yours. You may be called upon / promoted in emergency situations however you're generally expected to just roleplay."

	outfit = /datum/outfit/job/offduty_engineer

	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG

/datum/outfit/job/offduty_engineer
	name = "Engineer (off duty)"
	jobtype = /datum/job/offduty_engineer
	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda
	ears = /obj/item/radio/headset/headset_eng

/obj/effect/landmark/start/offduty/engineer
	name = "Engineer (off duty)"
	icon_state = "Engineer (off duty)"


/datum/job/offduty_bridge_officer
	title = "Bridge Officer (off duty)"
	description = "You are a bridge officer who is currently off duty and thus have fewer responsibilities. Relax, kick back at the bar, talk to people... The choice is yours. You may be called upon / promoted in emergency situations however you're generally expected to just roleplay."
	flag = OFFDUTY_BRIDGE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the first officer, though you aren't obligated to do your job outside of an emergency"
	selection_color = "#ccccff"
	access = list(ACCESS_HEADS, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_HEADS, ACCESS_MAINT_TUNNELS)
	outfit = /datum/outfit/job/bridge/offduty
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

/datum/outfit/job/bridge/offduty
	name = "Bridge Officer (off duty)"
	jobtype = /datum/job/offduty_bridge_officer
	uniform = /obj/item/clothing/under/trek/command/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset/heads/hop
	id = /obj/item/card/id

/obj/effect/landmark/start/offduty/bridge
	name = "Bridge Officer (off duty)"
	icon_state = "Bridge Officer (off duty)"

//Used by internal affairs for a direct line to starfleet.
/obj/item/admiralty_pager
	name = "Priority one 'Gold' channel communicator"
	desc = "A highly advanced communicator which can secure a priority-1 channel to starfleet command for quick and direct communication. It is made out of the finest materials to make it hazard resistant, however it must recharge between uses."
	icon = 'DS13/icons/obj/device.dmi'
	icon_state = "pager"
	w_class = 1
	var/ready = TRUE //Avoids spamming the admins too hard.
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/admiralty_pager/proc/reset()
	icon_state = "pager"
	ready = TRUE

/obj/item/admiralty_pager/attack_self(mob/user)
	. = ..()
	if(!ready)
		to_chat(user, "<span class='notice'>Subspace broadcaster recharging. Please stand-by.</span>")
		return
	var/input = stripped_input(user, "Please type your message. The contents will be sent over an encrypted channel, however transmission does not guarantee a response", "Send a message to starfleet command.", "")
	if(!input || !(user in view(1,src)))
		return
	ready = FALSE
	addtimer(CALLBACK(src, .proc/reset), 100)//One msg per 10 seconds.
	icon_state = "pager-recharge"
	playsound(src, pick(GLOB.bleeps), 100, 0)
	to_chat(user, "<span class='notice'>|Connection established with relay 'Echo-[rand(1,999)]|'.</span>")
	sleep(rand(2,7))
	to_chat(user, "<span class='notice'>--Establishing gold channel link...--</span>")
	sleep(rand(2,7))
	to_chat(user, "<span class='notice'>---Sending encrypted message...---</span>")
	sleep(rand(2,7))
	to_chat(user, "<span class='notice'>|Transmission successful. Cycling command codes.|</span>")
	CentCom_announce(input, user)