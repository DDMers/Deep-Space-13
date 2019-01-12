/obj/machinery/door/airlock/trek/goon
	name = "Airlock"
	icon = 'DS13/goonstation/standard_airlock.dmi'
	desc = "A sleek airlock for walking through."
	icon_state = "closed"

/obj/machinery/door/airlock/trek/goon/sec
	name = "Airlock"
	icon = 'DS13/goonstation/security_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_access = ACCESS_SEC_DOORS
	req_access_txt = "63"

/obj/machinery/door/airlock/trek/goon/engi
	name = "Airlock"
	icon = 'DS13/goonstation/engineering_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_access = ACCESS_ENGINE
	req_access_txt = "10"

/obj/machinery/door/airlock/trek/goon/command
	name = "Airlock"
	icon = 'DS13/goonstation/command_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_access = ACCESS_HEADS
	req_access_txt = "19"

/obj/machinery/door/airlock/trek/goon/research
	name = "Airlock"
	icon = 'DS13/goonstation/medical_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks extra secure"
	icon_state = "closed"
	req_access = ACCESS_RESEARCH
	req_access_txt = "47"

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
	req_access = ACCESS_EXTERNAL_AIRLOCKS
	req_access_txt = "13"