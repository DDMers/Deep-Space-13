/*
How this works:
Bridge gets a comms console. Ships occasionally try and dock with DS13, if they bring cargo (people included) they declare it on a manifest

Encounters can either be positive, neutral, or negative.
Positive means the documentation is correct and they're not smuggling
Neutral means they may have misfiled the documentation but not smuggling
Negative means it can devolve into a space-battle. Or they're smugglers trying to sneak antags aboard.

When a ship is nearby, the bridge is pinged as well as the HOS + Shitsec.
HOS requests the cargo manifest and pilot's license from the docking ship
He can choose to clear the ship with a cursory scan, or he can order his men to board it. Boarding takes time and could provoke some aliens into fighting.
Once they're done. You can clear the ship or detain it which brings a penalty if you're wrong.

If theyre cleared to dock, the ship flies onto the station and offloads their cargo via NPC. Antags may be stowing away so watch out!

Respawns will be offered on positive encounter ships, where crew can fly in from all over the place to join the crew.
---But can you trust that random civilian that just came aboard?...Or are they a romulan spy!

HOS gets a special console
*/

//Lists and code mods!
/datum/controller/subsystem/mapping
	var/list/ship_templates = list()

/datum/controller/subsystem/mapping/proc/preloadShipTemplates()
	for(var/item in typecacheof(/datum/map_template/ship))
		var/datum/map_template/ship/ship_type = item
		if(!(initial(ship_type.mappath)))
			continue
		var/datum/map_template/ship/S = new ship_type()
		ship_templates[S.name] = S
		map_templates[S.name] = S

/datum/controller/subsystem/mapping/preloadTemplates(path = "_maps/templates/")
	. = ..()
	preloadShipTemplates()

//Datums!

/datum/ship_event
	var/name = "Trading ship"
	var/target_ship = "trading" //The name of the map template we seek to load
	var/desc = "Greetings! I hope I find you well, I am a trader seeking to exchange goods...for the right price, of course!"

/datum/ship_event/ling
	name = "Frozen ship"
	target_ship = "lingtransport" //The name of the map template we seek to load
	desc = "Automated distress signal detected. Contents unknown"

/datum/ship_event/klingon_friendly
	name = "ISS Vor'Cha"
	target_ship = "klingon_friendly" //The name of the map template we seek to load
	desc = "Qap'la! My crew requires good food in their stomachs and a safe place to practice combat. We are landing now!"

//datum/ship_event/positive

/datum/ship_event/proc/fire()
	message_admins("A [name] is approaching DS13.")
	priority_announce("[desc].", "Incoming Transmission", 'sound/ai/commandreport.ogg')
	for(var/obj/effect/landmark/ShipSpawner/SS in GLOB.landmarks_list)
		if(SS && !SS.loaded)
			SS.load(target_ship)
			return

//Ships!

/datum/map_template/ship
	name = "generic"
	mappath = "_maps/templates/DS13/default.dmm"

/datum/map_template/ship/trading
	name = "trading"
	mappath = "_maps/templates/DS13/trading.dmm"

/datum/map_template/ship/lingtransport
	name = "lingtransport"
	mappath = "_maps/templates/DS13/lingtransport.dmm"

/datum/map_template/ship/klingon_friendly
	name = "klingon_friendly"
	mappath = "_maps/templates/DS13/klingon_ship.dmm"

/obj/effect/landmark/ShipSpawner
	name = "Ship spawning warp beacon"
	desc = "Spawns new ships!"
	var/loading = FALSE //To avoid spam
	var/loaded = FALSE //Is there a ship?

/obj/effect/landmark/ShipSpawner/proc/unload()
	loaded = FALSE

/obj/effect/landmark/ShipSpawner/proc/load(var/template)//Call load("name of the ship map template")
	if(loading || loaded)
		return FALSE
	if(!template)
		return FALSE
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	loading = TRUE
	var/datum/map_template/template_to_load = SSmapping.ship_templates[template]
	if(template_to_load.load(T, centered = FALSE))
		loading = FALSE
	loaded = TRUE
	return TRUE

/obj/structure/docking_port //Click this to board a ship
	name = "Docking access"
	icon = 'DS13/goonstation/external_airlock.dmi'
	desc = "A sleek airlock for walking through. This one looks futuristic"
	icon_state = "closed"
	var/obj/structure/docking_port/linked
	density = TRUE
	anchored = TRUE
	opacity = TRUE
	CanAtmosPass = ATMOS_PASS_NO
	var/exit_dir = SOUTH //This menas you step onto the turf below the airlock

/obj/structure/docking_port/north
	exit_dir = NORTH

/obj/structure/docking_port/east
	exit_dir = EAST

/obj/structure/docking_port/west
	exit_dir = WEST

/obj/structure/docking_port/Initialize()
	. = ..()
	SSdocking.ship_docking_ports += src

/obj/structure/docking_port/Destroy()
	SSdocking.ship_docking_ports -= src
	. = ..()

/obj/structure/docking_port/Bumped(atom/movable/AM)
	if(!density)
		return ..()
	if(!linked)
		if(SSdocking.ship_docking_ports.len)
			for(var/obj/structure/docking_port/S in SSdocking.ship_docking_ports)
				if(S in get_area(src)) //Don't link with our own ports
					continue
				linked = S
				break
			if(!linked) //STILL nothing linked. So cancel
				to_chat(AM, "There is no ship docked.")
				return ..() //No docking ports so just slam into the door.
	var/turf/T = get_step(get_turf(linked),linked.exit_dir)
	if(T)
		AM.forceMove(T)
	playsound(T.loc, 'DS13/sound/effects/ds9_door.ogg', 100,1)
	return

//Areas!

/area/ship //This area will encompass all our ships
	name = "Docked ship"
	requires_power = FALSE
	has_gravity = TRUE
	var/list/crate_contents = list() //What crates do we have aboard? used for generating a customs report

//Customs mechanics!

/obj/item/paper/customs //Oi mate have you paid your import duty yeah?
	name = "Customs declaration" //Stop those fake chinese sneakers getting through customs
	var/manifest = "(0x) Example <br> (0x) Example 2" //What have they declared is here?
	var/font = "BMmini"
	var/counterfeit_font = "Comic Sans MS" //For reference
	info = "BEGONE THOT"

/datum/asset/simple/customs
	assets = list(
		"background.png"	= 'DS13/icons/paperwork/manifest_template.png',
		"BMmini.eot" = 'tgui/assets/fonts/BMmini.eot', //This doesn't work :(
		"BMmini.ttf" = 'tgui/assets/fonts/BMmini.ttf', //This doesn't work :(
	)

/obj/item/paper/customs/attack_hand(mob/user) //cba to make a new type just yet :devil:
	var/datum/asset/required = get_asset_datum(/datum/asset/simple/customs)
	required.send(user)
	var/datum/browser/popup = new(user, "Customs Declaration", "Customs Declaration")
	var/info = "		<!DOCTYPE html>\
	<style>\
	.container {\
	position: absolute;\
	left: auto;\
	color: black;\
	}\
	\
	.top-left {\
	position: absolute;\
	top: 50px;\
	left: 25px;\
	src:url('BBmini.eot') format('embedded-opentype'),url('BBmini.ttf') format('truetype');\
	font-family: 'BMmini.ttf', Lucida Console, serif;\
	font-weight: normal;\
	font-style: normal;\
	font-size: 13px;\
	color;#5a5559\
	}\
	</style>\
	<body>\
	<div class='container'>\
	<img src='background.png' alt='manifest' style='width:100%;'>\
	<div class='top-left'>[manifest]</div>\
	</div>\
	"//Use a font tag here ^ when I add fake versions
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(info)
	popup.open()

//Items and fluff!
/obj/effect/mob_spawn/human/alive/changeling
	name = "frozen sleeper"
	desc = "This stasis pod is frozen over, but contains some-thin..someone? Inside..."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	death = FALSE
	flavour_text = "<span class='big bold'>You are a survivor.</span><b> You killed the people who were trying to study you and have assumed a new form \
	but now you hunger for more genomes...</b>"
	outfit = /datum/outfit/job/doctor/DS13

/obj/effect/mob_spawn/human/alive/changeling/Initialize()
	. = ..()
	for(var/mob/dead/observer/F in GLOB.dead_mob_list)
		var/turf/turfy = get_turf(src)
		var/link = TURF_LINK(F, turfy)
		if(F)
			to_chat(F, "<font color='#EE82EE'><i>Antagonist spawn available (just click the sleeper): [link]</i></font>")


/obj/effect/mob_spawn/human/alive/changeling/special(mob/living/new_spawn)
	if(new_spawn.mind)
		new_spawn.mind.make_Changeling()
	. = ..()
/obj/effect/mob_spawn/human/alive/trek
	name = "Assistant"
	outfit = /datum/outfit/job/assistant/DS13


/obj/effect/mob_spawn/human/alive/trek/Initialize()
	. = ..()
	for(var/mob/dead/observer/F in GLOB.dead_mob_list)
		var/turf/turfy = get_turf(src)
		var/link = TURF_LINK(F, turfy)
		if(F)
			to_chat(F, "<span class='danger'><i>Visiting crew spawn as a [name] available (just click the sleeper): [link]</i></span>")

/datum/outfit/klingon
	uniform = /obj/item/clothing/under/trek/klingon
	accessory = null
	shoes = /obj/item/clothing/shoes/jackboots
	suit = null
	gloves = /obj/item/clothing/gloves/color/black
	head = null
	l_pocket = /obj/item/kitchen/knife/combat/klingon
	ears = /obj/item/radio/headset

/obj/effect/mob_spawn/human/alive/trek/klingon
	name = "Klingon Crewman"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	flavour_text = "<span class='big bold'>You are a Klingon</span><span class='big'> <span class='danger'><b>Your crew is taking some shore leave on DS13, a federation outpost.</b></span> You are agressive and short tempered and you will not accept insults to your honour!</b><br>\
	<br>\
	<span class='danger'><b>Klingons are bound by honour! do not murder without a good reason or fight an unarmed opponent with a weapon. You may start fights if your character has a reason to do so (being insulted, being robbed/cheated)</b></span></font>"
	outfit = /datum/outfit/klingon
	mob_species = /datum/species/klingon