/obj/machinery/door/airlock/trek/ship
	name = "Airlock"
	icon = 'DS13/icons/obj/machinery/doors/standard.dmi'
	desc = "A sleek airlock for walking through."
	icon_state = "closed"
	doorOpen = 'DS13/sound/effects/tng_airlock.ogg'
	doorClose = 'DS13/sound/effects/tng_airlock.ogg'
	doorDeni = 'DS13/sound/effects/denybeep.ogg'

/obj/machinery/door/airlock/trek/ship/sec
	name = "Brig"
	icon = 'DS13/icons/obj/machinery/doors/security.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_SEC_DOORS)

/obj/machinery/door/airlock/trek/ship/sec/armoury
	name = "Armoury"
	icon = 'DS13/icons/obj/machinery/doors/security.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_ARMORY)

/obj/machinery/door/airlock/trek/ship/command
	name = "Command"
	icon = 'DS13/icons/obj/machinery/doors/command.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_HEADS)

/obj/machinery/door/airlock/trek/ship/command/captain
	name = "Captain's quarters"
	icon = 'DS13/icons/obj/machinery/doors/command.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_CAPTAIN)

/obj/machinery/door/airlock/trek/ship/command/hop
	name = "First Officer's quarters"
	icon = 'DS13/icons/obj/machinery/doors/command.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_HOP)

/obj/machinery/door/airlock/trek/ship/command/hos
	name = "Security Chief's quarters"
	icon = 'DS13/icons/obj/machinery/doors/command.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_HOS)

/obj/machinery/door/airlock/trek/ship/command/rd
	name = "Chief Science Officer's quarters"
	icon = 'DS13/icons/obj/machinery/doors/command.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_RD)

/obj/machinery/door/airlock/trek/ship/command/ce
	name = "Chief Engineer's quarters"
	icon = 'DS13/icons/obj/machinery/doors/command.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_CE)