//This is a temporary measure. The server refuses to accept our map_change configs so I'm overriding it here pending a fix.


//-------
//Command
//-------

/datum/job/ai
	title = "Ship computer"

/datum/job/captain
	outfit = /datum/outfit/job/captain/DS13

/datum/outfit/job/captain/DS13
	name = "Trek-Captain"
	uniform = /obj/item/clothing/under/trek/command/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/command
	l_pocket = /obj/item/pda
	belt = /obj/item/gun/energy/phaser
	shoes = /obj/item/clothing/shoes/jackboots
	suit = null
	gloves = /obj/item/clothing/gloves/color/black
	head = null
	backpack_contents = list(/obj/item/clothing/accessory/ds9_jacket/formal/captain=1)

/datum/job/hop
	outfit = /datum/outfit/job/hop/DS13
	title = "First Officer"

/datum/outfit/job/hop/DS13
	name = "Trek-Head of Personnel"
	uniform = /obj/item/clothing/under/trek/command/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots
	head = null
	gloves = /obj/item/clothing/gloves/color/black
	l_pocket = /obj/item/pda
	belt = /obj/item/gun/energy/phaser

//------
//EngSec
//------

//Security

/datum/job/hos
	outfit = /datum/outfit/job/hos/DS13
	title = "Security Chief"

/datum/outfit/job/hos/DS13
	name = "Trek-Head of Security"
	uniform = /obj/item/clothing/under/trek/command/ds9
	suit = null
	accessory = /obj/item/clothing/accessory/ds9_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda
	r_pocket = /obj/item/phaser_pack
	head = /obj/item/clothing/head/beret/sec/navyofficer
	belt = /obj/item/gun/energy/phaser

/datum/job/warden
	outfit = /datum/outfit/job/warden/DS13
	title = "Master at arms"

/datum/outfit/job/warden/DS13
	name = "Trek-Warden"
	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda
	r_pocket = /obj/item/phaser_pack
	belt = /obj/item/gun/energy/phaser
	suit = null

/datum/job/officer
	outfit = /datum/outfit/job/officer/DS13

/datum/outfit/job/officer/DS13
	name = "Trek-Security Officer"
	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda
	r_pocket = /obj/item/phaser_pack
	head = /obj/item/clothing/head/beret/sec/navyofficer
	belt = /obj/item/gun/energy/phaser


//Engineering

/datum/job/chief_engineer
	outfit = /datum/outfit/job/ce/DS13

/datum/outfit/job/ce/DS13
	name = "Trek-Chief Engineer"
	uniform = /obj/item/clothing/under/trek/command/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda


/datum/job/engineer
	outfit = /datum/outfit/job/engineer/DS13


/datum/outfit/job/engineer/DS13
	name = "Trek-Station Engineer"
	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

/datum/job/atmos
	outfit = /datum/outfit/job/atmos/DS13

/datum/outfit/job/atmos/DS13
	name = "Trek-Atmospheric Technician"
	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots


/datum/job/qm
	outfit = /datum/outfit/job/quartermaster

/datum/outfit/job/quartermaster
	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda
	r_pocket = /obj/item/carkey

/datum/outfit/job/qm/DS13
	name = "Trek-Quartermaster"
	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda
	r_pocket = /obj/item/carkey

/datum/job/cargo_tech
	outfit = /datum/outfit/job/cargo_tech/DS13


/datum/outfit/job/cargo_tech/DS13
	name = "Trek-Cargo Technician"
	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda


//--------
//Sciences
//--------

//Medbay

/datum/job/cmo
	outfit = /datum/outfit/job/cmo/DS13

/datum/outfit/job/cmo/DS13
	name = "Trek-Chief Medical Officer"
	uniform = /obj/item/clothing/under/trek/command/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda


/datum/job/doctor
	outfit = /datum/outfit/job/doctor/DS13

/datum/outfit/job/doctor/DS13
	name = "Trek-Medical Doctor"
	uniform = /obj/item/clothing/under/trek/medsci/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

/datum/job/chemist
	outfit = /datum/outfit/job/chemist/DS13

/datum/outfit/job/chemist/DS13
	name = "Chemist (Trek)"
	uniform = /obj/item/clothing/under/trek/medsci/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda


/datum/job/geneticist
	outfit = /datum/outfit/job/geneticist/DS13

/datum/outfit/job/geneticist/DS13
	name = "Trek-Geneticist"
	uniform = /obj/item/clothing/under/trek/medsci/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

/datum/job/virologist
	outfit = /datum/outfit/job/virologist/DS13

/datum/outfit/job/virologist/DS13
	name = "Trek-Virologist"
	uniform = /obj/item/clothing/under/trek/medsci/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

//Research

/datum/job/rd
	outfit = /datum/outfit/job/rd/DS13
	title = "Chief Science Officer"

/datum/outfit/job/rd/DS13
	name = "Trek-Research Director"
	uniform = /obj/item/clothing/under/trek/command/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

/datum/job/scientist
	outfit = /datum/outfit/job/scientist/DS13
	title = "Science Officer"

/datum/outfit/job/scientist/DS13
	name = "Trek-Scientist"
	uniform = /obj/item/clothing/under/trek/medsci/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

//Civilian

/datum/job/assistant
	outfit = /datum/outfit/job/assistant/DS13
	title = "Ensign"

/datum/outfit/job/assistant/DS13
	name = "Trek-Assistant"
	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

/datum/outfit/job/assistant/DS13/pre_equip(mob/living/carbon/human/H)
	..()
	uniform = /obj/item/clothing/under/trek/engsec/ds9

/datum/job/chaplain
	title = "Counselor"
	outfit = /datum/outfit/job/chaplain/DS13

/datum/outfit/job/chaplain/DS13
	name = "Trek-Chaplain"
	uniform = /obj/item/clothing/under/trek/medsci/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

/datum/job/janitor
	outfit = /datum/outfit/job/janitor/DS13

/datum/outfit/job/janitor/DS13
	name = "Trek-Janitor"
	uniform = /obj/item/clothing/under/trek/medsci/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

/datum/job/hydro
	outfit = /datum/outfit/job/hydro/DS13

/datum/outfit/job/hydro/DS13
	name = "Trek-Botanist"
	uniform = /obj/item/clothing/under/trek/medsci/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

/datum/job/cook
	outfit = /datum/outfit/job/cook/DS13

/datum/outfit/job/cook/DS13
	name = "Trek-Cook"
	uniform = /obj/item/clothing/under/trek/medsci/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

/datum/job/bartender
	outfit = /datum/outfit/job/cook/DS13

/datum/outfit/job/bartender/DS13
	name = "Trek-Bartender"
	uniform = /obj/item/clothing/under/trek/engsec/ds9
	accessory = /obj/item/clothing/accessory/ds9_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/pda

/datum/job/ai
	title = "Ship Computer"

// START LANDMARKS FOLLOW. We change this shit because we changed their names o7
/obj/effect/landmark/start/assistant
	name = "Ensign"
	icon_state = "Ensign"

/obj/effect/landmark/start/clown
	name = "Morale Officer"
	icon_state = "Clown"

/obj/effect/landmark/start/head_of_security
	name = "Security Chief"
	icon_state = "Security Chief"

/obj/effect/landmark/start/warden
	name = "Master at arms"
	icon_state = "Master at arms"

/obj/effect/landmark/start/head_of_personnel
	name = "First Officer"
	icon_state = "First Officer"

/obj/effect/landmark/start/medical_doctor
	name = "Medical Doctor"
	icon_state = "Medical Doctor"

/obj/effect/landmark/start/scientist
	name = "Science Officer"
	icon_state = "Science Officer"

/obj/effect/landmark/start/research_director
	name = "Chief Science Officer"
	icon_state = "Chief Science Officer"

/obj/effect/landmark/start/chaplain
	name = "Counselor"
	icon_state = "Counselor"

/obj/effect/landmark/start/ai
	name = "Ship Computer"
	icon_state = "Ship Computer"