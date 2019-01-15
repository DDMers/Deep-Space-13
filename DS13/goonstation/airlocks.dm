/obj/machinery/door/airlock/trek/goon
	name = "Airlock"
	icon = 'DS13/goonstation/standard_airlock.dmi'
	desc = "A sleek airlock for walking through."
	icon_state = "closed"

/obj/machinery/door/airlock/trek/goon/maint
	name = "Airlock"
	icon = 'DS13/goonstation/maint_airlock.dmi'
	desc = "A sleek airlock for walking through."
	icon_state = "closed"

/obj/machinery/door/airlock/trek/goon/sec
	name = "Airlock"
	icon = 'DS13/goonstation/security_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_SEC_DOORS)

/obj/machinery/door/airlock/trek/goon/engi
	name = "Airlock"
	icon = 'DS13/goonstation/engineering_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_ENGINE)

/obj/machinery/door/airlock/trek/goon/command
	name = "Airlock"
	icon = 'DS13/goonstation/command_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_HEADS)

/obj/machinery/door/airlock/trek/goon/research
	name = "Airlock"
	icon = 'DS13/goonstation/medical_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_RESEARCH)

/obj/machinery/door/airlock/trek/goon/medical
	name = "Airlock"
	icon = 'DS13/goonstation/medical_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_one_access = list(ACCESS_MEDICAL)


/obj/machinery/door/airlock/trek/goon/glass
	name = "Airlock"
	icon = 'DS13/goonstation/glass_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks futuristic"
	icon_state = "closed"

/obj/machinery/door/airlock/trek/goon/external
	name = "Airlock"
	icon = 'DS13/goonstation/external_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks futuristic"
	icon_state = "closed"
	req_one_access = list(ACCESS_EXTERNAL_AIRLOCKS)

/obj/machinery/door/airlock/trek/goon/external/public
	name = "Airlock"
	icon = 'DS13/goonstation/external_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks futuristic"
	icon_state = "closed"
	req_one_access = null