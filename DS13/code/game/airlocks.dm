/obj/machinery/door/airlock/trek/ship
	name = "Airlock"
	icon = 'DS13/icons/obj/machinery/doors/standard.dmi'
	desc = "A sleek airlock for walking through."
	icon_state = "closed"
	doorOpen = 'DS13/sound/effects/tng_airlock.ogg'
	doorClose = 'DS13/sound/effects/tng_airlock.ogg'
	doorDeni = 'DS13/sound/effects/denybeep.ogg'

/obj/machinery/door/airlock/trek/ship/cargo
	name = "Cargo bay"
	icon = 'DS13/icons/obj/machinery/doors/standard.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_CARGO)

/obj/machinery/door/airlock/trek/ship/maint
	name = "Jefferies tubes"
	desc = "A low hanging hatch allowing you to crawl into the jefferies tubes."
	icon = 'DS13/icons/obj/machinery/doors/maint.dmi'
	icon_state = "closed"
	doorOpen = 'DS13/sound/effects/jeffries.ogg'
	doorClose = 'DS13/sound/effects/jeffries.ogg'
	req_one_access = list(ACCESS_MAINT_TUNNELS)

/obj/machinery/door/airlock/trek/ship/hydro
	name = "Airponics bay"
	icon_state = "closed"
	req_one_access = list(ACCESS_HYDROPONICS)

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

/obj/machinery/door/airlock/trek/ship/sec/torpedo
	name = "Torpedo bay"
	icon = 'DS13/icons/obj/machinery/doors/security.dmi'
	desc = "The torpedo bay, where you load ammo for the ship's photonic launchers or say goodbye to dead crewmates. Doctors and counselors have access to this too."
	icon_state = "closed"
	req_one_access = list(ACCESS_MORGUE) //Doctors and chaplain can conduct funerals.

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

/obj/machinery/door/airlock/trek/ship/command/qm
	name = "Quartermaster's office"
	icon = 'DS13/goonstation/engineering_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_QM)