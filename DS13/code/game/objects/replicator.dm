#define READY 1
#define REPLICATING 2

/obj/machinery/replicator //Coded by "AbsurdlyLudicrous", tweaked to use voice + cleaned up by Kmc.
	name = "Replicator"
	desc = "An advanced energy to matter synthesizer which is charged by <i>biomatter</i> and power. Click it to see the menu and simply say what you want to it."
	icon = 'DS13/icons/obj/replicator.dmi'
	icon_state = "replicator"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	pixel_y = 32 //So it glues to the wall
	anchored = TRUE
	flags_1 = HEAR_1 //So it can hear you order your food
	circuit = /obj/item/circuitboard/machine/replicator
	var/list/menutier1 = list("rice", "egg", "ration pack", "glass") //It starts off terribly so the chef isn't replaced. You can then upgrade it via RnD to give actual food.
	var/list/menutier2 = list("burger", "steak", "tea earl grey", "coffee", "fries","onion rings", "pancakes")
	var/list/menutier3 = list("cheese pizza", "meat pizza", "mushroom pizza", "meat pizza", "pineapple pizza", "donkpocket pizza", "vegetable pizza")
	var/list/menutier4 = list("cake batter", "dough","egg box", "flour", "milk", "enzymes", "cheese wheel", "meat slab","an insult to pizza")
	var/list/all_menus = list() //All the menu items. Built on init(). We scan for menu items that've been ordered here.
	var/list/menualtnames = list("nutrients", "donk pizza", "veggie pizza", "surprise me", "you choose", "something", "i dont care","slab of meat","nutritional supplement")
	var/list/temps = list("cold", "warm", "hot", "extra hot")
	var/activator = "computer"
	var/menutype = READY //Tracks what stage the machine's at. If it's replicating the UI pops up with "please wait!"
	var/fuel = 50 //Starts with a bit of fuel for lazy chefs.
	var/capacity_multiplier = 1
	var/failure_grade = 1
	var/speed_grade = 1
	var/menu_grade = 1
	var/emagged = FALSE
	var/ready = TRUE //Are we ready to make some food?

/obj/machinery/replicator/Initialize()
	. = ..()
	all_menus += menutier1.Copy()
	all_menus += menutier2.Copy()
	all_menus += menutier3.Copy()
	all_menus += menutier4.Copy()
	all_menus += menualtnames.Copy()

/obj/machinery/replicator/ui_interact(mob/user) // The microwave Menu //I am reasonably certain that this is not a microwave
	if(!is_operational())
		return
	if(panel_open)
		return
	. = ..()
	var/dat
	if(menutype == REPLICATING)
		dat += "REPLICATING FOOD, PLEASE WAIT.<br>"
	dat += "<br><h1>MENU:</h1> "
	dat += "<br><b>This machine is voice activated. To order food, say <i>computer</i> and then the food item you want. (Eg. Computer, Tea earl grey. Hot)</b><br> <hr><h2>Nutritional supplements:</h2>"

	for(var/foodname in menutier1)
		dat += "<br>[foodname]"
	if(menu_grade >= 2)
		dat += "<h2>Basic dishes:</h2><br>"
		for(var/foodname in menutier2)
			dat += "<br>[foodname] "
	if(menu_grade >= 3)
		dat += "<h2>Complex dishes:</h2><br>"
		for(var/foodname in menutier3)
			dat += "<br>[foodname] "
	if(menu_grade >= 4)
		dat += "<h2>Ingredients:</h2><br>"
		for(var/foodname in menutier4)
			dat += "<br>[foodname] "
	dat += "<h2>Temperatures:</h2>"
	for(var/foodname in temps)
		dat += "<br>[foodname] "
	var/datum/browser/popup = new(user, "replicator menu", name, 450, 520)
	popup.set_content(dat)
	popup.open()

/obj/machinery/replicator/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You corrupt the chemical processors.</span>")
		emagged = TRUE

/obj/machinery/replicator/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
		idle_power_usage = 40

/obj/item/circuitboard/machine/replicator
	name = "Food Replicator (Machine Board)"
	build_path = /obj/machinery/replicator
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/micro_laser = 1)

/obj/machinery/replicator/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		capacity_multiplier = B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		speed_grade = M.rating
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		menu_grade = S.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		failure_grade = L.rating

/obj/machinery/replicator/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>fuel reserves: <b>[fuel]/[capacity_multiplier*600]</b>. Click it with any biomatter to recharge [src].</span>")
	ui_interact(user)

/obj/machinery/replicator/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(speaker == src)
		return
	else
		check_activation(speaker, raw_message)

/obj/machinery/replicator/proc/check_activation(atom/movable/speaker, raw_message)
	if(!powered() || !ready || panel_open)//Shut down.
		return
	if(!findtext(raw_message, activator))
		return FALSE //They have to say computer, like a discord bot prefix.
	if(menutype == READY)
		if(findtext(raw_message, "?")) //Burger? no be SPECIFIC. REEE
			return
		var/target
		var/temp = null
		for(var/X in all_menus)
			var/tofind = X
			if(findtext(raw_message, tofind))
				target = tofind //Alright they've asked for something on the menu.
		for(var/Y in temps) //See if they want it hot, or cold.
			var/hotorcold = Y
			if(findtext(raw_message, hotorcold))
				temp = hotorcold //If they specifically request a temperature, we'll oblige. Else it doesn't rename.
		if(target && powered())
			menutype = REPLICATING
			idle_power_usage = 400
			icon_state = "replicator-on"
			playsound(src, 'DS13/sound/effects/replicator.ogg', 100, 1)
			ready = FALSE
			var/speed_mult = 60 //Starts off hella slow.
			speed_mult -= (speed_grade*10) //Upgrade with manipulators to make this faster!
			addtimer(CALLBACK(src, .proc/replicate, target,temp,speaker), speed_mult)
			addtimer(CALLBACK(src, .proc/set_ready, TRUE), speed_mult)

/obj/machinery/replicator/proc/set_ready()
	icon_state = "replicator"
	idle_power_usage = 40
	menutype = READY
	ready = TRUE

/obj/machinery/replicator/proc/grind(obj/item/reagent_containers/food/snacks/grown/G)
	var/nutrimentgain = G.reagents.get_reagent_amount("nutriment")
	fuel += nutrimentgain
	if(fuel >= capacity_multiplier*600)
		fuel = capacity_multiplier*600
	qdel(G)

/obj/machinery/replicator/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "replicator-o", "replicator", O))
		return FALSE
	if(default_unfasten_wrench(user, O))
		return FALSE
	var/success = FALSE
	if(istype(O, /obj/item/reagent_containers/glass) || istype(O, /obj/item/trash))
		visible_message("<span class='warning'>[O] is vaporized by [src]</span>")
		playsound(src, 'DS13/sound/effects/replicator-vaporize.ogg', 100, 1)
		qdel(O)
		return FALSE
	if(fuel < capacity_multiplier*600)
		if(istype(O, /obj/item/reagent_containers/food/snacks/grown))
			grind(O)
			success = TRUE
		else if(istype(O, /obj/item/storage/bag/plants))
			var/obj/item/storage/bag/plants/P = O
			for(var/obj/item/reagent_containers/food/snacks/grown/G in P.contents)
				if(fuel < capacity_multiplier*600)
					grind(G)
				success = TRUE
	else
		to_chat(user, "<span class='warning'>[src]'s chemical fuel cells are full.</span>")
		return FALSE

	if(success)
		visible_message("<span class='warning'>[O] is vaporized by [src]</span>")
		playsound(src, 'DS13/sound/effects/replicator-vaporize.ogg', 100, 1)
		use_power(50)
		return
	. = ..()

/obj/machinery/replicator/proc/replicate(var/what, var/temp, var/mob/living/user)
	var/atom/food
	switch(what)
		if("egg")
			food = new /obj/item/reagent_containers/food/snacks/boiledegg(get_turf(src))
		if("rice")
			food = new /obj/item/reagent_containers/food/snacks/salad/boiledrice(get_turf(src))
		if("ration pack","nutrients","nutritional supplement")
			food = new /obj/item/reagent_containers/food/snacks/rationpack(get_turf(src))
		if("glass")
			food = new /obj/item/reagent_containers/food/drinks/drinkingglass(get_turf(src))
		if("surprise me","you choose","something","i dont care")
			if(emagged)
				switch(rand(1,6))
					if(1)
						new /mob/living/simple_animal/hostile/killertomato(get_turf(src))
					if(2)
						new /mob/living/simple_animal/hostile/netherworld(get_turf(src))
					if(3)
						new /mob/living/simple_animal/hostile/bear(get_turf(src))
					if(4)
						new /mob/living/simple_animal/hostile/blob/blobspore(get_turf(src))
					if(5)
						new /mob/living/simple_animal/hostile/carp(get_turf(src))
					if(6)
						food = new /obj/item/reagent_containers/food/snacks/soup/mystery(get_turf(src))
				playsound(src.loc, 'sound/effects/explosion3.ogg', 50, 1)
				var/datum/effect_system/smoke_spread/bad/smoke = new
				smoke.set_up(2, src.loc)
				smoke.start()
				del(src)
				return
			else
				food = new /obj/item/reagent_containers/food/snacks/soup/mystery(get_turf(src))
	if(menu_grade >= 2) //SCANNER GRADE 2 (or above)!
		switch(what)
			if("burger")
				food = new /obj/item/reagent_containers/food/snacks/burger/plain(get_turf(src))
			if("steak")
				food = new /obj/item/reagent_containers/food/snacks/meat/steak/plain(get_turf(src))
			if("fries")
				food = new /obj/item/reagent_containers/food/snacks/fries(get_turf(src))
			if("onion rings")
				food = new /obj/item/reagent_containers/food/snacks/onionrings(get_turf(src))
			if("pancakes")
				food = new /obj/item/reagent_containers/food/snacks/pancakes(get_turf(src))
			if("tea earl grey")
				food = new /obj/item/reagent_containers/food/drinks/mug/tea(get_turf(src))
				food.name = "Earl Grey tea"
				food.desc = "Just how Captain Picard likes it."
				if(emagged)
					var/tea = food.reagents.get_reagent_amount("tea")
					food.reagents.add_reagent("chloralhydrate", tea)
					food.reagents.remove_reagent("coffee",tea)
			if("coffee")
				food = new /obj/item/reagent_containers/food/drinks/coffee(get_turf(src))
				food.name = "coffee"
				food.desc = "A wise woman once said that coffee keeps you sane in deep space."
				if(emagged)
					var/coffee = food.reagents.get_reagent_amount("coffee")
					food.reagents.add_reagent("ethanol", coffee)
					food.reagents.remove_reagent("coffee",coffee)
	if(menu_grade >= 3) //SCANNER GRADE 3 (or above)!
		switch(what)
			if("cheese pizza")
				food = new /obj/item/reagent_containers/food/snacks/pizzaslice/margherita(get_turf(src))
			if("meat pizza")
				food = new /obj/item/reagent_containers/food/snacks/pizzaslice/meat(get_turf(src))
			if("mushroom pizza")
				food = new /obj/item/reagent_containers/food/snacks/pizzaslice/mushroom(get_turf(src))
			if("veggie pizza","vegetable pizza")
				food = new /obj/item/reagent_containers/food/snacks/pizzaslice/vegetable(get_turf(src))
			if("pineapple pizza","an insult to pizza")
				food = new /obj/item/reagent_containers/food/snacks/pizzaslice/pineapple(get_turf(src))
			if("donk pizza","donkpocket pizza")
				food = new /obj/item/reagent_containers/food/snacks/pizzaslice/donkpocket(get_turf(src))
	if(menu_grade >= 4)
		switch(what)
			if("cake batter")
				food = new /obj/item/reagent_containers/food/snacks/cakebatter(get_turf(src))
			if("dough")
				food = new /obj/item/reagent_containers/food/snacks/dough(get_turf(src))
			if("egg box")
				food = new /obj/item/storage/fancy/egg_box(get_turf(src))
			if("flour")
				food = new /obj/item/reagent_containers/food/condiment/flour(get_turf(src))
			if("milk")
				food = new /obj/item/reagent_containers/food/condiment/milk(get_turf(src))
			if("enzymes")
				food = new /obj/item/reagent_containers/food/condiment/enzyme(get_turf(src))
			if("cheese wheel")
				food = new /obj/item/reagent_containers/food/snacks/store/cheesewheel(get_turf(src))
			if("meat slab","slab of meat")
				food = new /obj/item/reagent_containers/food/snacks/meat/slab(get_turf(src))

	if(food)
		var/nutriment = food.reagents.get_reagent_amount("nutriment")
		if(fuel >= nutriment && fuel >= 5)
			//time to check laser power.
			if(prob(6-failure_grade)) //Chance to make a burned mess so the chef is still useful.
				var/obj/item/reagent_containers/food/snacks/badrecipe/neelixcooking = new /obj/item/reagent_containers/food/snacks/badrecipe(get_turf(src))
				neelixcooking.name = "replicator mess"
				neelixcooking.desc = "perhaps you should invest in some higher quality parts."
				fuel -= 5
				qdel(food) //NO FOOD FOR YOU!
				return
			else
				if(temp)
					food.name = "[temp] [food.name]"
				if(nutriment > 0)
					fuel -= nutriment
				else
					fuel -= 5 //Default, in case the food is useless.
				if(emagged)
					food.reagents.add_reagent("munchyserum", nutriment)
					food.reagents.remove_reagent("nutriment",nutriment)
				var/currentHandIndex = user.get_held_index_of_item(food)
				user.put_in_hand(food,currentHandIndex)

		else
			visible_message("<span_class='warning'> Insufficient fuel to create [food]. [src] requires [nutriment] U of biomatter.</span>")
			qdel(food) //NO FOOD FOR YOU!


/datum/reagent/toxin/munchyserum //Tasteless alternative to lipolicide, less powerful. This has the reverse of the intended effect of a replicator and makes you hungrier.
	name = "Metabolism Overide Toxin"
	id = "munchyserum"
	description = "A strong toxin that increases the appetite of their victim while dampening their ability to absorb nutrients for as long as it is in their system."
	silent_toxin = TRUE
	reagent_state = LIQUID
	taste_mult = 0 //no flavor
	color = "#F0FFF0"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/munchyserum/on_mob_life(mob/living/carbon/M)
	if(M.nutrition >= NUTRITION_LEVEL_STARVING+75)
		M.adjust_nutrition(-3)
		M.overeatduration = 0
	return ..()

#undef READY
#undef REPLICATING