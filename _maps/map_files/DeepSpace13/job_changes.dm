#define JOB_MODIFICATION_MAP_NAME "DeepSpace13"


//-------
//Command
//-------

/datum/job/captain/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/captain/DS13

/datum/outfit/job/captain/DS13
	name = "Trek-Captain"
	uniform = /obj/item/clothing/under/trek/command/next


/datum/job/hop/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/hop/DS13

/datum/outfit/job/hop/DS13
	name = "Trek-Head of Personnel"
	uniform = /obj/item/clothing/under/trek/command/next


//------
//EngSec
//------

//Security

/datum/job/hos/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/hos/DS13

/datum/outfit/job/hos/DS13
	name = "Trek-Head of Security"
	uniform = /obj/item/clothing/under/trek/command/next


/datum/job/warden/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/warden/DS13

/datum/outfit/job/warden/DS13
	name = "Trek-Warden"
	uniform = /obj/item/clothing/under/trek/engsec/next

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/officer/DS13

/datum/outfit/job/officer/DS13
	name = "Trek-Security Officer"
	uniform = /obj/item/clothing/under/trek/engsec/next


//Engineering

/datum/job/chief_engineer/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/ce/DS13

/datum/outfit/job/ce/DS13
	name = "Trek-Chief Engineer"
	uniform = /obj/item/clothing/under/trek/command/next


/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/engineer/DS13
	minimal_access += ACCESS_ATMOSPHERICS


/datum/outfit/job/engineer/DS13
	name = "Trek-Station Engineer"
	uniform = /obj/item/clothing/under/trek/engsec/next

MAP_REMOVE_JOB(atmos)

//--------
//Sciences
//--------

//Medbay

/datum/job/cmo/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/cmo/DS13

/datum/outfit/job/cmo/DS13
	name = "Trek-Chief Medical Officer"
	uniform = /obj/item/clothing/under/trek/command/next


/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/doctor/DS13

/datum/outfit/job/doctor/DS13
	name = "Trek-Medical Doctor"
	uniform = /obj/item/clothing/under/trek/medsci/next


/datum/job/chemist/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/chemist/DS13

/datum/outfit/job/chemist/DS13
	name = "Chemist (Trek)"
	uniform = /obj/item/clothing/under/trek/medsci/next


/datum/job/geneticist/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/geneticist/DS13

/datum/outfit/job/geneticist/DS13
	name = "Trek-Geneticist"
	uniform = /obj/item/clothing/under/trek/medsci/next


/datum/job/virologist/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/virologist/DS13

/datum/outfit/job/virologist/DS13
	name = "Trek-Virologist"
	uniform = /obj/item/clothing/under/trek/medsci/next


//Research

/datum/job/rd/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/rd/DS13

/datum/outfit/job/rd/DS13
	name = "Trek-Research Director"
	uniform = /obj/item/clothing/under/trek/command/next


/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	outfit = /datum/outfit/job/scientist/DS13
	access += ACCESS_MORGUE
	minimal_access += list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE)

/datum/outfit/job/scientist/DS13
	name = "Trek-Scientist"
	uniform = /obj/item/clothing/under/trek/medsci/next

MAP_REMOVE_JOB(roboticist)