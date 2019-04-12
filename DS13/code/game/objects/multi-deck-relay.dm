/obj/machinery/power/power_relay //Relays power from deck to deck
	name = "Secondary power relay"
	desc = "This huge box relays power across decks"
	icon = 'DS13/icons/obj/machinery/power_relay.dmi'
	icon_state = "base"
	var/toggled = TRUE
	var/transfer_rate = 10000 //How quickly do we transfer power?
	var/max_transfer_rate = 10000 //Max rate of transfer, 500 is default and sane.
	var/rate_cap = 10000 //What's the power rate capped at? This is off by default, but engineers can tweak this if they so need
	var/total_power_gen = 0 //Debugging only
	var/obj/machinery/power/power_relay/below //Take power from this one
	var/obj/machinery/power/power_relay/above //Give it to this one
	var/datum/looping_sound/generator/soundloop
	component_parts = list(/obj/item/stock_parts/capacitor=10)
	req_access = list(ACCESS_ENGINE)
	var/locked = TRUE //Are you authorized to dick with this?
	var/autobalance = TRUE //automatically detect what power we need to send? Or set it yourself for micro.

/obj/machinery/power/power_relay/attackby(obj/I,mob/user)
	. = ..()
	if(locked)
		var/obj/item/card/id/ID = I
		if(ID && istype(ID))
			if(check_access(ID))
				if(locked)
					locked = FALSE
					to_chat(user, "You unlock [src]'s controls")
				else
					locked = TRUE
					to_chat(user, "You lock [src]'s controls")

/obj/machinery/power/power_relay/attack_hand(mob/user)
	. = ..()
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		if(locked)
			to_chat(user, "[src]'s controls are locked! Swipe an engineering level ID to unlock them.")
			return
		else
			var/question = alert("Do what?",name,"Toggle power","Modify power distro rate","Toggle automatic APC charge")
			switch(question)
				if("Toggle power")
					to_chat(user, "You [toggled ? "deactivate": "activate"] [src]")
					toggled = !toggled
					return
				if("Modify power distro rate")
					var/num = input(user,"Limit rate of power transfer (Watts/Second) (Maximum: [max_transfer_rate])", "Limit rate of power transfer (Watts/Second) (Maximum: [max_transfer_rate])") as num
					if(num > 0 && num <= max_transfer_rate)
						rate_cap = num
						update_icon()
					else
						say("Error. Desired power value invalid.")
						return
				if("Toggle automatic APC charge")
					to_chat(user, "You [autobalance ? "disabled auto governance mode": "enabled auto governance mode"] ")
					autobalance = !autobalance

/obj/machinery/power/power_relay/examine(mob/user)
	. = ..()
	to_chat(user, "It's transferring power at a rate of [transfer_rate]. Its controls are [locked ? "locked": "unlocked"]")

/obj/machinery/power/power_relay/Initialize()
	. = ..()
	START_PROCESSING(SSmachines,src)
	soundloop = new(list(src), toggled)

/obj/machinery/power/power_relay/RefreshParts()
	transfer_rate = 0
	max_transfer_rate = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		max_transfer_rate += C.rating*1000 //We can improve it..


/obj/machinery/power/power_relay/proc/find_relays()
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return FALSE
	var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
	C.powernet.add_machine(src)
	below = locate(/obj/machinery/power/power_relay) in(SSmapping.get_turf_below(T))
	above = locate(/obj/machinery/power/power_relay) in(SSmapping.get_turf_above(T))
	return TRUE

/obj/machinery/power/power_relay/Destroy()
	if(below)
		below.above = null
	QDEL_NULL(soundloop)
	. = ..()

/obj/machinery/power/power_relay/process()
	transfer_rate = rate_cap
	update_icon()
	if(transfer_rate > max_transfer_rate)
		transfer_rate = rate_cap
	if(!toggled)
		soundloop.stop()
		return FALSE
	else
		if(!powernet || !anchored || !above)
			find_relays()
			return
		soundloop.start()
		if(above) //Transfer our power to the deck above, avail the above machine with our power.
			try_transfer_power()

/obj/machinery/power/power_relay/update_icon()
	. = ..()
	if(!toggled || !powernet || !anchored)
		icon_state = "off"
		return
	else
		icon_state = "active"
		return


/obj/machinery/power/power_relay/proc/try_transfer_power()
	if(powernet.avail >= transfer_rate) //If there's enough power being generated, take the power from there, else, look for stores like SMES and APC
		transfer_power(transfer_rate)
		return TRUE
	for(var/obj/machinery/power/terminal/term in powernet.nodes)
		var/obj/machinery/power/apc/A = term.master
		if(istype(A))
			if(!A.cell)
				continue
			if(A.cell.charge >= transfer_rate)
				transfer_power(transfer_rate)
				return TRUE
		else
			var/obj/machinery/power/smes/S = term.master
			if(istype(S))
				if(S.outputting && S.charge >= transfer_rate)
					transfer_power(transfer_rate)
					return TRUE
	soundloop.stop() //OK, 0 power, time to shutdown.
	icon_state = "off"
	return FALSE

/obj/machinery/power/power_relay/proc/transfer_power(var/amount) //Transfer power to the one above us
	var/uncharged = 0 //Any uncharged APCs on the deck above? If not then why bother sending power upstairs??
	if(autobalance) //Allow the machine to automatically determine what power is needed based on APC charge?
		for(var/obj/machinery/power/terminal/term in above.powernet.nodes)
			var/obj/machinery/power/apc/A = term.master
			if(istype(A))
				if(!A.cell)
					continue
				if(A.cell.charge < A.cell.maxcharge) //Found an apc that needs power, so let's shunt some power up
					uncharged ++
		if(uncharged <= 0)
			return //No uncharged cells on the floor above, focus on ourselves. If not, then send power up
	if(above)
		var/to_transfer = 0
		if(below) //We've got one below us supplying us power, so keep half of what it sends up
			to_transfer = (amount / 2)
		else //In that case, no one's supplying us power. We don't need to keep any of this power so let's send it up.
			to_transfer = amount
		add_load(to_transfer) //Add what we're sending up to our powernet's current load.
		above.add_avail(to_transfer) //And give the other half to the one above
		above.total_power_gen += to_transfer //This is a debug stat
		return

/obj/machinery/power/deck_relay //This bridges powernets
	name = "Multi-deck power adapter"
	desc = "This impressive machine uses plasma based power transmission technology to supply power to alternate decks. It requires a steady power source. Click it with a multitool / ODN scanner to see stats and reacquire connections."
	icon = 'DS13/icons/obj/power.dmi'
	icon_state = "cablerelay-off"
	var/obj/machinery/power/deck_relay/below
	var/obj/machinery/power/deck_relay/above
	var/list/relays = list() //to bridge the powernets.
	anchored = TRUE
	density = FALSE

/obj/machinery/power/deck_relay/attackby(obj/item/I,mob/user)
	if(default_unfasten_wrench(user, I))
		return FALSE
	. = ..()

/obj/machinery/power/deck_relay/process()
	if(!anchored)
		icon_state = "cablerelay-off"
		if(above) //Lose connections
			above.below = null
			above.relays -= src
		if(below)
			below.above = null
			below.relays -= src
		relays = list()
		return
	refresh() //Sometimes the powernets get lost, so we need to keep checking.
	if(powernet && (powernet.avail <= 0))		// is it powered?
		icon_state = "cablerelay-off"
	else
		icon_state = "cablerelay-on"
	if(!below || QDELETED(below) || !above || QDELETED(above))
		icon_state = "cablerelay-off"
		find_relays()

/obj/machinery/power/deck_relay/multitool_act(mob/user, obj/item/I)
	if(powernet && (powernet.avail > 0))		// is it powered?
		to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
	if(!powernet || below.powernet != powernet)
		icon_state = "cablerelay-off"
		to_chat(user, "<span class='danger'>Powernet connection lost. Attempting to re-establish. Ensure the relays below this one are connected too.</span>")
		find_relays()
		addtimer(CALLBACK(src, .proc/refresh), 20) //Wait a bit so we can find the one below, then get powering
	return TRUE

/obj/machinery/power/deck_relay/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/find_relays), 30)
	addtimer(CALLBACK(src, .proc/refresh), 50) //Wait a bit so we can find the one below, then get powering

/obj/machinery/power/deck_relay/proc/refresh()
	var/turf/ours = get_turf(src)
	for(var/X in relays) //Typeless loops are apparently more efficient.
		var/obj/machinery/power/deck_relay/DR = X
		if(!DR)
			continue
		var/turf/T = get_turf(DR)
		var/obj/structure/cable/C = T.get_cable_node()
		var/obj/structure/cable/XR = ours.get_cable_node()
		if(C && XR)
			merge_powernets(XR.powernet,C.powernet)//Bridge the powernets.

/obj/machinery/power/deck_relay/proc/find_relays()
	relays = list()
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return FALSE
	below = null //in case we're re-establishing
	var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
	if(C && C.powernet)
		C.powernet.add_machine(src) //Nice we're in.
		powernet = C.powernet
	below = locate(/obj/machinery/power/deck_relay) in(SSmapping.get_turf_below(T))
	above = locate(/obj/machinery/power/deck_relay) in(SSmapping.get_turf_above(T))
	relays += below
	relays += above
	if(below || above)
		icon_state = "cablerelay-on"
	return TRUE