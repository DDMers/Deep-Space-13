//Makes end credits happen after round end!
//Inspired by baystation, optimized for /tg/

/datum/asset/simple/credits
	assets = list("credits.gif"	= 'DS13/icons/stars2.gif')

/proc/names2credits()
	var/credits = "Starring the crew of [station_name()]<br>"
	for(var/datum/data/record/t in GLOB.data_core.general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		credits += "[rank] [name]<br>"
	credits += "Directed by: Kmc2000 <br> Executive producer: Francinum <br> Technical supervisor: Bass-ic <br>"
	return credits

/proc/start_credits_global()
	var/text = names2credits()
	SEND_SOUND(world, 'DS13/sound/effects/endcredits.ogg')
	for(var/X in GLOB.clients)
		var/client/C = X
		if(C.mob)
			C.mob.roll_credits(text)

/mob/proc/roll_credits(var/credits_list)
	if(!client)
		return
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/credits)
	assets.send(client)
	var/thing = credits_list
	var/credits = "\
	<body bgcolor='#000000'>\
	<body background='credits.gif'>\
	<div class='scroll-left'>\
	<p><font-family: 'Arial Black', sans-serif;color='blue'><b><i>Star Trek Episode [pick(1,50)]: The [pick("Phantom of", "Scar of", "Chalice of", "Deception of", "Planet of", "Downfall of", "Rise of", "Search for", "Trial of", "Discovery of", "First contact with")] [pick("Spock", "Vulcan", "Romulus", "Qu'on os", "The borg", "Space", "the USS Kobayashi Maru", "Rixx", "Orion Slave Girls", "the warp 10 barrier", "Captain Jean Luc Picard", "Cargonia", "a bunch of spiders in a swat suit", "the destroyer of worlds", "Captain Proton", "Lieutenant Barclay", "crippling holodeck addiction", "the fully functional android")] </b><br>[thing]</p></i></font>\
	\
	</div>"
	var/datum/browser/popup = new(src, "Credits", "Credits", 600, 320)
	popup.add_stylesheet("credits", 'html/browser/credits.css')
	popup.set_content(credits)
	popup.open()