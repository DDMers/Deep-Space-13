/*
Clown
*/
/datum/job/clown
	title = "Morale Officer"
	flag = CLOWN
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	description = "The morale officer is responsible for the wellbeing of the crew as much as the counselor. You bring joy and brighten up their lives by slipping and honking in finest starfleet tradition. <br> Primary roles: Make terrible jokes, keep the crew entertained."

	outfit = /datum/outfit/job/clown

	access = list(ACCESS_THEATRE)
	minimal_access = list(ACCESS_THEATRE)
	paycheck = PAYCHECK_MINIMAL
	paycheck_department = ACCOUNT_SRV


/datum/job/clown/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	H.apply_pref_name("clown", M.client)

/datum/outfit/job/clown
	name = "Morale Officer"
	jobtype = /datum/job/clown

	belt = /obj/item/pda/clown
	uniform = /obj/item/clothing/under/trek/neelix //Deep Space 13. Deep clown lore change :)
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_pocket = /obj/item/bikehorn
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/clothing/mask/gas/clown_hat = 1
		)

	implants = list(/obj/item/implant/sad_trombone)

	box = /obj/item/storage/box/hug/survival

	chameleon_extras = /obj/item/stamp/clown

/datum/outfit/job/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

	H.fully_replace_character_name(H.real_name, pick(GLOB.clown_names)) //rename the mob AFTER they're equipped so their ID gets updated properly.
	H.dna.add_mutation(CLOWNMUT)
	to_chat(H, "<span class='warning'>You've picked morale officer! This role is different from the traditional clown, so here's a few rules:<br>-You must not interfere with the ship during red alert.<br>-You must make a legitimate attempt at being funny<br>-While you have your clown mask, remember that you're still a crewman and are working for the good of the ship.</span>")

/*
Mime
*/
/datum/job/mime
	title = "Mime"
	flag = MIME
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	description = ".... --- ...... .... ...?"

	outfit = /datum/outfit/job/mime

	access = list(ACCESS_THEATRE)
	minimal_access = list(ACCESS_THEATRE)
	paycheck = PAYCHECK_MINIMAL
	paycheck_department = ACCOUNT_SRV


/datum/job/mime/after_spawn(mob/living/carbon/human/H, mob/M)
	H.apply_pref_name("mime", M.client)

/datum/outfit/job/mime
	name = "Mime"
	jobtype = /datum/job/mime

	belt = /obj/item/pda/mime
	uniform = /obj/item/clothing/under/rank/mime
	mask = /obj/item/clothing/mask/gas/mime
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/frenchberet
	suit = /obj/item/clothing/suit/suspenders
	backpack_contents = list(/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing=1)

	accessory = /obj/item/clothing/accessory/pocketprotector/cosmetology
	backpack = /obj/item/storage/backpack/mime
	satchel = /obj/item/storage/backpack/mime


/datum/outfit/job/mime/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		H.mind.miming = 1

/*
Curator
*/
/datum/job/curator
	title = "Curator"
	flag = CURATOR
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/curator

	access = list(ACCESS_LIBRARY)
	minimal_access = list(ACCESS_LIBRARY, ACCESS_CONSTRUCTION,ACCESS_MINING_STATION)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV


/datum/outfit/job/curator
	name = "Curator"
	jobtype = /datum/job/curator

	belt = /obj/item/pda/curator
	uniform = /obj/item/clothing/under/rank/curator
	l_hand = /obj/item/storage/bag/books
	r_pocket = /obj/item/key/displaycase
	l_pocket = /obj/item/laser_pointer
	accessory = /obj/item/clothing/accessory/pocketprotector/full
	backpack_contents = list(
		/obj/item/choice_beacon/hero = 1,
		/obj/item/soapstone = 1,
		/obj/item/barcodescanner = 1
	)


/datum/outfit/job/curator/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	H.grant_all_languages(omnitongue=TRUE)
/*
Internal Affairs
*/
/datum/job/lawyer
	title = "Internal Affairs Officer"
	flag = LAWYER
	department_head = list("Admiral")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "starfleet command"
	selection_color = "#dddddd"
	description = "Captain, you are in violation of the federation charter! <br> As an internal affairs liason, your job is to ensure the captain is held accountable to the laws of the federation. You should remind them of appropriate regulations and contact the admiralty using your pager if they are in severe violation of the law. Your job is to make sure the federation's principals are upheld, NOT to persecute the command staff."

	outfit = /datum/outfit/job/lawyer

	access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS,ACCESS_HEADS)
	minimal_access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)


/datum/outfit/job/lawyer
	name = "Internal Affairs Officer"
	jobtype = /datum/job/lawyer

	belt = /obj/item/pda
	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/heads/hop
	gloves = /obj/item/clothing/gloves/color/black
	uniform =  /obj/item/clothing/under/trek/command/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket
	shoes = /obj/item/clothing/shoes/jackboots
	backpack_contents = list(/obj/item/clipboard=1)
	r_pocket = /obj/item/clothing/accessory/lawyers_badge
	l_pocket = /obj/item/admiralty_pager

	chameleon_extras = /obj/item/stamp/law