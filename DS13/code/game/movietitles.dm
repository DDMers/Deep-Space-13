//Makes end credits happen after round end!
//Inspired by baystation, optimized for /tg/

/datum/asset/simple/credits
	assets = list("credits.gif"	= 'DS13/icons/stars2.gif')

/proc/names2credits()
	var/credits = "Starring the crew of [station_name()]<br>"
	for(var/mob/living/M in GLOB.player_list)
		if(!isliving(M) || !M.mind || !M.client)
			continue //Ghosts don't get credit
		credits += "[M.client.ckey] as [M.mind.assigned_role] [M.name]<br>"
	credits += "Directed by: Kmc2000 <br> Executive producer: Francinum <br> Technical supervisor: Bass-ic <br>"
	return credits

/proc/roll_credits()
	var/text = names2credits()
	SEND_SOUND(world, 'DS13/sound/effects/endcredits.ogg')
	for(var/mob/M in GLOB.player_list)
		M.roll_credits(text)

/mob/proc/roll_credits(var/credits_list)
	var/mob/user = src
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/credits)
	assets.send(user)
	var/thing = credits_list
	var/credits = "\
	<body bgcolor='#000000'>\
	<body background='credits.gif'>\
	<style style='text/css'>\
	.scroll-left {\
	height: 280px;	\
	overflow: hidden;\
	position: relative;\
	}\
	.scroll-left p {\
	position: absolute;\
	width: 100%;\
	height: 100%;\
	margin: 0;\
	line-height: 50px;\
	text-align: center;\
	color: #ADD8E6;\
	font-family: 'Arial Black'\
	/* Starting position */\
	-moz-transform:translateY(100%);\
	-webkit-transform:translateY(100%);	\
	transform:translateY(100%);\
	/* Apply animation to this element */	\
	-moz-animation: scroll-left 40s linear infinite;\
	-webkit-animation: scroll-left 40s linear infinite;\
	animation: scroll-left 40s linear infinite;\
	}\
	/* Move it (define the animation) */\
	@-moz-keyframes scroll-left {\
	0%   { -moz-transform: translateY(100%); }\
	100% { -moz-transform: translateY(-100%); }\
	}\
	@-webkit-keyframes scroll-left {\
	0%   { -webkit-transform: translateY(100%); }\
	100% { -webkit-transform: translateY(-100%); }\
	}\
	@keyframes scroll-left {\
	0%   { \
	-moz-transform: translateY(100%); /* Browser bug fix */\
	-webkit-transform: translateY(100%); /* Browser bug fix */\
	transform: translateY(100%); 		\
	}\
	100% { \
	-moz-transform: translateY(-100%); /* Browser bug fix */\
	-webkit-transform: translateY(-100%); /* Browser bug fix */\
	transform: translateY(-100%); \
	}\
	}\
	</style>\
	<div class='scroll-left'>\
	<p><font-family: 'Arial Black', sans-serif;color='blue'><b><i>Star Trek Episode [pick(1,50)]: The [pick("Phantom of", "Scar of", "Chalice of", "Deception of", "Planet of", "Downfall of", "Rise of", "Search for", "Trial of", "Discovery of", "First contact with")] [pick("Spock", "Vulcan", "Romulus", "Qu'on os", "The borg", "Space", "the USS Kobayashi Maru", "Rixx", "Orion Slave Girls", "the warp 10 barrier", "Captain Jean Luc Picard", "Cargonia", "a bunch of spiders in a swat suit", "the destroyer of worlds", "Captain Proton", "Lieutenant Barclay", "crippling holodeck addiction", "the fully functional android")] </b><br>[thing]</p></i></font>\
	\
	</div>"
	var/datum/browser/popup = new(user, "Credits", "Credits", 600, 290)
	popup.set_content(credits)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()