//Lets you change your theme because some people are weird and like white theme//

/client/proc/force_white_theme() //There's no way round it. We're essentially changing the skin by hand. It's painful but it works, and is the way Lummox suggested.
	//Main windows
	winset(src, "infowindow", "background-color = #2c2f33;background-color = none")
	winset(src, "infowindow", "text-color = #99aab5;text-color = #000000")
	winset(src, "info", "background-color = #272727;background-color = none")
	winset(src, "info", "text-color = #99aab5;text-color = #000000")
	winset(src, "browseroutput", "background-color = #272727;background-color = none")
	winset(src, "browseroutput", "text-color = #99aab5;text-color = #000000")
	winset(src, "outputwindow", "background-color = #272727;background-color = none")
	winset(src, "outputwindow", "text-color = #99aab5;text-color = #000000")
	winset(src, "mainwindow", "background-color = #2c2f33;background-color = none")
	winset(src, "split", "background-color = #272727;background-color = none")
	//Buttons
	winset(src, "changelog", "background-color = #494949;background-color = none")
	winset(src, "changelog", "text-color = #99aab5;text-color = #000000")
	winset(src, "rules", "background-color = #494949;background-color = none")
	winset(src, "rules", "text-color = #99aab5;text-color = #000000")
	winset(src, "wiki", "background-color = #494949;background-color = none")
	winset(src, "wiki", "text-color = #99aab5;text-color = #000000")
	winset(src, "forum", "background-color = #494949;background-color = none")
	winset(src, "forum", "text-color = #99aab5;text-color = #000000")
	winset(src, "github", "background-color = #3a3a3a;background-color = none")
	winset(src, "github", "text-color = #99aab5;text-color = #000000")
	winset(src, "report-issue", "background-color = #492020;background-color = none")
	winset(src, "report-issue", "text-color = #99aab5;text-color = #000000")
	//Status and verb tabs
	winset(src, "output", "background-color = #272727;background-color = none")
	winset(src, "output", "text-color = #99aab5;text-color = #000000")
	winset(src, "outputwindow", "background-color = #272727;background-color = none")
	winset(src, "outputwindow", "text-color = #99aab5;text-color = #000000")
	winset(src, "statwindow", "background-color = #272727;background-color = none")
	winset(src, "statwindow", "text-color = #eaeaea;text-color = #000000")
	winset(src, "stat", "background-color = #2c2f33;background-color = #FFFFFF")
	winset(src, "stat", "tab-background-color = #272727;tab-background-color = none")
	winset(src, "stat", "text-color = #99aab5;text-color = #000000")
	winset(src, "stat", "tab-text-color = #99aab5;tab-text-color = #000000")
	winset(src, "stat", "prefix-color = #ebebeb;prefix-color = #000000")
	winset(src, "stat", "suffix-color = #ebebeb;suffix-color = #000000")
	//Say, OOC, me Buttons etc.
	winset(src, "saybutton", "background-color = #272727;background-color = none")
	winset(src, "saybutton", "text-color = #99aab5;text-color = #000000")
	winset(src, "oocbutton", "background-color = #272727;background-color = none")
	winset(src, "oocbutton", "text-color = #99aab5;text-color = #000000")
	winset(src, "mebutton", "background-color = #272727;background-color = none")
	winset(src, "mebutton", "text-color = #99aab5;text-color = #000000")
	winset(src, "asset_cache_browser", "background-color = #272727;background-color = none")
	winset(src, "asset_cache_browser", "text-color = #99aab5;text-color = #000000")
	winset(src, "tooltip", "background-color = #272727;background-color = none")
	winset(src, "tooltip", "text-color = #99aab5;text-color = #000000")

/client/proc/force_dark_theme() //There's no way round it. We're essentially changing the skin by hand. It's painful but it works, and is the way Lummox suggested.
	//Main windows
	winset(src, "infowindow", "background-color = none;background-color = #2c2f33")
	winset(src, "infowindow", "text-color = #000000;text-color = #99aab5")
	winset(src, "info", "background-color = none;background-color = #272727")
	winset(src, "info", "text-color = #000000;text-color = #99aab5")
	winset(src, "browseroutput", "background-color = none;background-color = #272727")
	winset(src, "browseroutput", "text-color = #000000;text-color = #99aab5")
	winset(src, "outputwindow", "background-color = none;background-color = #272727")
	winset(src, "outputwindow", "text-color = #000000;text-color = #99aab5")
	winset(src, "mainwindow", "background-color = none;background-color = #2c2f33")
	winset(src, "split", "background-color = none;background-color = #272727")
	//Buttons
	winset(src, "changelog", "background-color = none;background-color = #494949")
	winset(src, "changelog", "text-color = #000000;text-color = #99aab5")
	winset(src, "rules", "background-color = none;background-color = #494949")
	winset(src, "rules", "text-color = #000000;text-color = #99aab5")
	winset(src, "wiki", "background-color = none;background-color = #494949")
	winset(src, "wiki", "text-color = #000000;text-color = #99aab5")
	winset(src, "forum", "background-color = none;background-color = #494949")
	winset(src, "forum", "text-color = #000000;text-color = #99aab5")
	winset(src, "github", "background-color = none;background-color = #3a3a3a")
	winset(src, "github", "text-color = #000000;text-color = #99aab5")
	winset(src, "report-issue", "background-color = none;background-color = #492020")
	winset(src, "report-issue", "text-color = #000000;text-color = #99aab5")
	//Status and verb tabs
	winset(src, "output", "background-color = none;background-color = #272727")
	winset(src, "output", "text-color = #000000;text-color = #99aab5")
	winset(src, "outputwindow", "background-color = none;background-color = #272727")
	winset(src, "outputwindow", "text-color = #000000;text-color = #99aab5")
	winset(src, "statwindow", "background-color = none;background-color = #272727")
	winset(src, "statwindow", "text-color = #000000;text-color = #eaeaea")
	winset(src, "stat", "background-color = #FFFFFF;background-color = #2c2f33")
	winset(src, "stat", "tab-background-color = none;tab-background-color = #272727")
	winset(src, "stat", "text-color = #000000;text-color = #99aab5")
	winset(src, "stat", "tab-text-color = #000000;tab-text-color = #99aab5")
	winset(src, "stat", "prefix-color = #000000;prefix-color = #ebebeb")
	winset(src, "stat", "suffix-color = #000000;suffix-color = #ebebeb")
	//Say, OOC, me Buttons etc.
	winset(src, "saybutton", "background-color = none;background-color = #272727")
	winset(src, "saybutton", "text-color = #000000;text-color = #99aab5")
	winset(src, "oocbutton", "background-color = none;background-color = #272727")
	winset(src, "oocbutton", "text-color = #000000;text-color = #99aab5")
	winset(src, "mebutton", "background-color = none;background-color = #272727")
	winset(src, "mebutton", "text-color = #000000;text-color = #99aab5")
	winset(src, "asset_cache_browser", "background-color = none;background-color = #272727")
	winset(src, "asset_cache_browser", "text-color = #000000;text-color = #99aab5")
	winset(src, "tooltip", "background-color = none;background-color = #272727")
	winset(src, "tooltip", "text-color = #000000;text-color = #99aab5")


/datum/chatOutput/proc/swaptolightmode()
	owner.force_white_theme()

/datum/chatOutput/proc/swaptodarkmode()
	owner.force_dark_theme()

/datum/chatOutput/load()
	set waitfor = FALSE
	if(!owner)
		return
	var/datum/asset/group/stuff = get_asset_datum(/datum/asset/group/goonchat)
	stuff.send(owner)
	owner << browse(file('code/modules/goonchat/browserassets/html/browserOutput.html'), "window=browseroutput")

/datum/asset/simple/goonchat
	verify = FALSE
	assets = list(
		"json2.min.js"             = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"errorHandler.js"          = 'code/modules/goonchat/browserassets/js/errorHandler.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"fontawesome-webfont.eot"  = 'tgui/assets/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.svg"  = 'tgui/assets/fonts/fontawesome-webfont.svg',
		"fontawesome-webfont.ttf"  = 'tgui/assets/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.woff" = 'tgui/assets/fonts/fontawesome-webfont.woff',
		"font-awesome.css"	       = 'code/modules/goonchat/browserassets/css/font-awesome.css',
		"browserOutput.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput.css',
		"browserOutput_white.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput_white.css',
	)