
/datum/outfit/borg
	name = "Borg drone"
	id = /obj/item/card/id/silver
	uniform =  /obj/item/clothing/under/abductor
	suit = /obj/item/clothing/suit/space/borg
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet/space/borg
	l_hand = /obj/item/borg_tool
	mask = /obj/item/clothing/mask/gas/borg

/datum/outfit/borg/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.unequip_everything() //they gotta be naked first or they won't get their implants :(

/datum/outfit/borg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	augment_organs(H)

/datum/outfit/borg/proc/delete_organs(var/mob/living/carbon/human/H) //Remove their old organs
	var/obj/item/organ/o = H.getorganslot(ORGAN_SLOT_HEART)
	if(o)
		qdel(o)
	var/obj/item/organ/L = H.getorganslot(ORGAN_SLOT_EYES)
	if(L)
		qdel(L)
	var/obj/item/organ/x = H.getorganslot(ORGAN_SLOT_LUNGS)
	if(x)
		qdel(x)
	return TRUE

/obj/item/organ/body_egg/borgNanites
	name = "Nanite cluster"
	desc = "A metal lattice, every part of it moves and swims at its own will."
	zone = BODY_ZONE_CHEST
	slot = "borg_infection"
	icon_state = "heart-c-on"
	color = "#008000"

/obj/item/organ/body_egg/borgNanites/Remove(mob/living/carbon/M, special = 0) //Allows for deborging
	if(owner && owner.mind)
		owner.mind.remove_antag_datum(/datum/antagonist/borg_drone)
	qdel(src)

/datum/outfit/borg/proc/augment_organs(var/mob/living/carbon/human/H) //Give them the organs. Used for roundstart borg and admin borg too!
	delete_organs(H)
	var/obj/item/organ/eyes/robotic/thermals/blinkingisfutile = new(get_turf(H))
	blinkingisfutile.Insert(H)
	var/obj/item/organ/heart/cybernetic/upgraded/faithoftheheart = new(get_turf(H))
	faithoftheheart.Insert(H)
	var/obj/item/organ/lungs/cybernetic/borg/breathingisfutile = new(get_turf(H))
	breathingisfutile.Insert(H)
	if(!locate(/obj/item/organ/body_egg/borgNanites) in H.internal_organs) //For the borg that spawn, we need a way for them to be deconverted.
		var/obj/item/organ/body_egg/borgNanites/nanitelattice = new(get_turf(H))
		nanitelattice.Insert(H)
	insert_upgrades(H)

/datum/outfit/borg/proc/insert_upgrades(var/mob/living/carbon/human/H) //Give them feeding tube and toolset
	if(locate(/obj/item/organ/cyberimp/arm/toolset) in H.internal_organs)
		return
	if(locate(/obj/item/organ/cyberimp/chest/nutriment/plus) in H.internal_organs)
		return
	var/obj/item/organ/cyberimp/arm/toolset/stored = new(get_turf(H))
	stored.Insert(H)
	var/obj/item/organ/cyberimp/chest/nutriment/plus/feedmeseymour = new(get_turf(H))
	feedmeseymour.Insert(H)


/obj/item/organ/lungs/cybernetic/borg
	name = "borg cybernetic lungs"
	desc = "An astonishingly powerful lung prosthetic which uses borg nanoprobes to directly supply the energy needed for cell respiration, lessening the need to breathe. This organ has the ability to filter out lower levels of toxins and carbon dioxide."
	icon_state = "lungs-c-u"
	color = "#008000"
	safe_toxins_max = 20 //It can survive low levels of toxins
	safe_co2_max = 20
	safe_oxygen_min = 1 //Means you barely need to breathe

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 100


/datum/action/item_action/futile
	name = "Resistance is futile!"

/datum/action/item_action/futile/Trigger()
	var/obj/item/clothing/mask/gas/borg/FT = target
	if(istype(FT))
		FT.futile()
	return ..()

//Items, from top to bottom

/obj/item/clothing/head/helmet/space/borg
	name = "Cranial prosthesis"
	desc = "Starfleet medical research states that borg implants can cause severe irritation, perhaps an analgesic cream would fix the constant itching this prosthetic causes?"
	icon_state = "hostile_env"
	alternate_worn_icon = 'DS13/icons/mob/suit.dmi' //Hides it when worn, but gives it an icon in inv
	item_state = null
	cold_protection = HEAD
	heat_protection = HEAD
	resistance_flags = FIRE_PROOF | ACID_PROOF
	item_flags = NODROP
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SHOWEROKAY
	permeability_coefficient = 0.01

/obj/item/clothing/mask/gas/borg
	name = "Borg mask"
	desc = "A built in respirator that covers our face, it provides everything we need."
	icon = 'DS13/icons/obj/masks.dmi'
	icon_state = "borg"
	item_state = null
	siemens_coefficient = 0
	item_flags = NODROP
	clothing_flags = SHOWEROKAY | MASKINTERNALS
	var/cooldown2 = 300 //30 second cooldown
	var/saved_time = 0
	actions_types = list(/datum/action/item_action/futile, /datum/action/item_action/message_collective)

/datum/action/item_action/message_collective
	name = "Message the collective"
	icon_icon = 'DS13/icons/actions/actions_borg.dmi'
	button_icon_state = "message_collective"

/datum/action/item_action/message_collective/Trigger()
	var/obj/item/clothing/mask/gas/borg/FT = target
	if(istype(FT))
		FT.message_collective()
	return ..()

/obj/item/clothing/mask/gas/borg/AltClick(mob/user)
	futile()

/obj/item/clothing/mask/gas/borg/CtrlClick(mob/user)
	futile()

/obj/item/clothing/mask/gas/borg/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/futile)
		futile(user)
	else if(actiontype == /datum/action/item_action/message_collective)
		message_collective(user)

/obj/item/clothing/mask/gas/borg/proc/message_collective(var/mob/living/carbon/human/user)
	if(!user)
		user = src.loc
		if(!istype(user, /mob))
			return
	if(user.stat == DEAD || user.IsUnconscious() || !src in user.contents)
		return
	var/message = stripped_input(user,"Communicate with the collective.","Send Message")
	if(!message)
		return
	GLOB.borg_collective.message_collective(user.real_name, message)

/obj/item/clothing/mask/gas/borg/proc/futile()
	if(world.time >= saved_time + cooldown2)
		saved_time = world.time
		var/sound = pick('DS13/sound/effects/borg/withstandassault.ogg','DS13/sound/effects/borg/dontresist.ogg')
		var/phrase_text = "Resistance is futile."
		src.audible_message("<font color='green' size='4'><b>[phrase_text]</b></font>")
		playsound(src.loc,sound, 85, 0, 4)

/obj/item/clothing/suit/space/borg
	name = "Borg exoskeleton"
	desc = "A heavily armoured exoskeletal system held in place via multiple attachment points which are embedded painfully into the skin."
	icon = 'DS13/icons/obj/suits.dmi'
	alternate_worn_icon = 'DS13/icons/mob/suit.dmi'
	icon_state = "borg"
	item_state = null
	body_parts_covered = FULL_BODY
	cold_protection = FULL_BODY
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	slowdown = 2
	item_flags = NODROP
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SHOWEROKAY
	armor = list(melee = 40, bullet = 5, laser = 15, energy = 0, bomb = 15, bio = 100, rad = 70) //they can't react to bombs that well, and emps will rape them
	resistance_flags = FIRE_PROOF
	allowed = list(/obj/item/flashlight)
	heat_protection = FULL_BODY
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	permeability_coefficient = 0.01
	gas_transfer_coefficient = 0.01
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	var/datum/component/mobhook

/obj/item/clothing/suit/space/borg/IsReflect() //Watch your lasers, they adapt quickly
	if(prob(GLOB.borg_collective.adaptation))
		var/sound = pick('DS13/sound/effects/borg/borg_adapt.ogg','DS13/sound/effects/borg/borg_adapt2.ogg','DS13/sound/effects/borg/borg_adapt3.ogg','DS13/sound/effects/borg/borg_adapt4.ogg')
		playsound(loc, sound, 100, 1)
		return 1
	else
		if(GLOB.borg_collective.adaptation < 100)
			GLOB.borg_collective.adaptation += 10 //More you shoot them, the stronger they become. They are still naturally weak to bullets
		return 0

/obj/item/clothing/suit/space/borg/proc/on_mob_move()
	var/mob/living/carbon/human/H = loc
	if(!istype(H) || H.wear_suit != src)
		return
	if(prob(50))
		playsound(src, 'sound/effects/servostep.ogg', 100, 1)

/obj/item/clothing/suit/space/borg/equipped(mob/user, slot)
	. = ..()
	if (slot == SLOT_WEAR_SUIT)
		if (mobhook && mobhook.parent != user)
			QDEL_NULL(mobhook)
		if (!mobhook)
			mobhook = user.AddComponent(/datum/component/redirect, list(COMSIG_MOVABLE_MOVED = CALLBACK(src, .proc/on_mob_move)))
	else
		QDEL_NULL(mobhook)

/obj/item/clothing/suit/space/borg/dropped()
	. = ..()
	QDEL_NULL(mobhook)

/obj/item/clothing/suit/space/borg/Destroy()
	QDEL_NULL(mobhook) // mobhook is not our component
	return ..()

/obj/item/clothing/suit/space/borg/Initialize()
	. = ..()
	icon_state = "borg[pick(1,2)]"


/obj/effect/mob_spawn/human/alive/trek/borg
	name = "Borg drone"
	assignedrole = "borg drone"
	outfit = /datum/outfit/borg

/obj/effect/mob_spawn/human/alive/trek/borg/special(mob/M)
	if(M.mind)
		M.mind.make_borg()

/obj/structure/chair/borg
	name = "If you see this, tell a coder"
	desc = "Stop looking at me."
	max_integrity = 100

/obj/structure/chair/borg/conversion
	name = "Assimilation chamber"
	desc = "A horrifying machine used to rob people of their individuality."
	icon_state = "borg_off"
	icon = 'DS13/icons/borg/borg.dmi'
	anchored = TRUE
	can_buckle = TRUE
	can_be_unanchored = FALSE
	max_buckled_mobs = 1
	buildstacktype = null
	item_chair = null // if null it can't be picked up
	var/restrained = FALSE //can they unbuckle easily?


/obj/structure/chair/borg/conversion/user_buckle_mob(mob/living/carbon/human/M, mob/user)
	if(!isBorgDrone(M))
		to_chat(M, "Assimilate them first")
		return
	M.unequip_everything()
	icon_state = "borg_off"
	visible_message("parts of [src] start to shift and move")
	playsound(loc, 'DS13/sound/effects/borg/machines/convert_table.ogg', 50, 1, -1)
	var/image/armoverlay = image('DS13/icons/borg/borg.dmi')
	armoverlay.icon_state = "borg_arms"
	armoverlay.layer = ABOVE_MOB_LAYER
	overlays += armoverlay
	var/image/armoroverlay = image('DS13/icons/borg/borg.dmi')
	armoroverlay.icon_state = "borgarmour"
	armoroverlay.layer = ABOVE_MOB_LAYER
	overlays += armoroverlay
	sleep(35)
	playsound(loc, 'DS13/sound/effects/borg/machines/convert_table2.ogg', 50, 1, -1)
	icon_state = "borg_off"
	M.equipOutfit(/datum/outfit/borg, visualsOnly = FALSE) //Outfit handles name etc.
	playsound(src.loc, 'DS13/sound/effects/borg/machines/assimilation_chamber.ogg', 100, 0)
	cut_overlays()
	overlays -= armoverlay
	overlays -= armoroverlay
	qdel(armoroverlay)
	qdel(armoverlay)
	return TRUE


/obj/structure/chair/borg/charging
	name = "Recharging alcove"
	desc = "A device which can heal, revive and recharge members of the borg collective. It has several specialised anti bacterial nozzles to remove unpleasant smells from drones."
	icon_state = "borgcharger"
	icon = 'DS13/icons/borg/borg.dmi'
	anchored = TRUE
	can_buckle = TRUE
	can_be_unanchored = FALSE
	max_buckled_mobs = 1
	resistance_flags = FIRE_PROOF
	buildstacktype = null
	item_chair = null // if null it can't be picked up
	var/cooldown2 = 110 //music loop cooldowns
	var/saved_time2 = 0
	var/sound = 'DS13/sound/effects/borg/machines/alcove.ogg'
	var/mob/living/carbon/human/user

/obj/structure/chair/borg/charging/Initialize()
	. = ..()

/obj/structure/chair/borg/charging/process()
	if(user && user in get_turf(src))
		user.set_hygiene(HYGIENE_LEVEL_CLEAN)
		user.adjustBruteLoss(-3)
		user.adjustFireLoss(-3)
		user.adjustOxyLoss(-3)
		user.restoreEars()
		user.adjust_eye_damage(-5)
		if(user.eye_blind || user.eye_blurry)
			user.set_blindness(0)
			user.set_blurriness(0)
		if(user.blood_volume < BLOOD_VOLUME_NORMAL)
			user.blood_volume += 5 // regenerate blood rapidly
		if(user.stat == DEAD)
			user.updatehealth() // Previous "adjust" procs don't update health, so we do it manually.
			user.set_heartattack(FALSE)
			user.revive()
			user.adjustBruteLoss(-20) //give them a real kick so they do actually revive
			user.adjustFireLoss(-20)
			user.adjustOxyLoss(-20)
			user.adjustToxLoss(-20)
	else
		STOP_PROCESSING(SSobj, src)
		user = null
		return

	if(world.time >= saved_time2 + cooldown2)
		saved_time2 = world.time
		playsound(src,sound,10,0)
	else
		return

/obj/structure/chair/borg/charging/user_buckle_mob(mob/living/M, mob/User)
	if(!M.client)
		to_chat(User, "Unable to locate neural link in [M]. Aborting. (Perhaps they're AFK?")
		return FALSE
	if(ishuman(M) && M.loc == loc)
		var/mob/living/carbon/human/H = M
		if(isBorgDrone(H))
			user = H
			to_chat(H, "<span class='warning'>Establishing connection...</span>")
			to_chat(H, "<span class='warning'>Success!</span>")
			to_chat(H, "<span class='warning'>Connection established with [src]</span>")
			. = ..()
			user = H
			START_PROCESSING(SSobj, src)
		else
			src.visible_message("<span class='warning'>[M] cannot be recharged as they are not borg.</span>")
			unbuckle_mob(M)
			return TRUE
	else
		src.visible_message("<span class='warning'>[M] cannot be recharged.</span>")
		unbuckle_mob(M)
		return TRUE



/obj/structure/borg_teleporter
	name = "Subspace vector translocator"
	desc = "A device which opens a transwarp conduit to rapidly translate a unimatrix across subspace through a transwarp conduit. Walk/run into it to engage translocation (run right into the middle of it) after it has activated."
	icon = 'DS13/icons/borg/large_machines.dmi'
	icon_state = "teleporter-off"
	var/turf/open/target
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/teleport_sound = 'DS13/sound/effects/borg/borg_transporter.ogg'
	anchored = TRUE
	can_be_unanchored = FALSE
	density = TRUE
	pixel_x = -32

/obj/structure/borg_teleporter/Initialize()
	. = ..()
	GLOB.borg_collective.teleporters += src

/obj/structure/borg_teleporter/examine(mob/user)
	. = ..()
	if(!GLOB.borg_collective.teleporters_allowed)
		to_chat(user, "No unimatrix in range of teleporter. This component will activate automatically upon arrival at a compatible spatial matrix.")
		return
	if(target)
		to_chat(user, "<I> Translocation matrix assigned: Unimatrix 325, grid 006. [get_area(target)]</I>")

/obj/structure/borg_teleporter/Bumped(atom/movable/AM)
	if(!target || !GLOB.borg_collective.teleporters_allowed)
		return ..()
	if(isliving(AM))
		new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(AM), AM.dir)
		do_sparks(1, 8, src)
		visible_message("[AM] enters a transwarp conduit!")
		AM.forceMove(target)
		playsound(AM.loc, teleport_sound, 100,1)
		new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(AM), AM.dir)

/obj/structure/borg_teleporter/proc/activate()
	icon_state = "teleporter-off"
	target = null
	var/list/A = list()
	A = GLOB.borg_collective.poll_drones_for_teleport()
	var/area/thearea
	if(A.len)
		thearea = pick(A)
	if(!A.len || !thearea || QDELETED(thearea))
		var/xd = pick(GLOB.teleportlocs)
		thearea = GLOB.teleportlocs[xd]
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!is_blocked_turf(T) && !istype(T, /turf/open/openspace))
			L += T
	target = pick(L)
	if(!target) //Aaaand it still couldn't find an exit turf....somehow...
		visible_message("Unable to set translocation target, could not locate a suitable subspace exit point. Contact an admin immediately.")
		return
	GLOB.borg_collective.message_collective("The collective", "Translocation matrix coordinates locked: [target.x],[target.y] in [get_area(target)]. Unimatrix 325, grid 006. Step through the teleporter to beam down.")
	icon_state = "teleporter-on"

//Borg tool

/obj/item/borg_tool
	name = "Primary prosthetic interaction node"
	desc = "This massive prosthetic houses a vicious claw and a full replicator suite for the rapid conversion of an area into God knows what. Click it while holding it to change its mode."
	icon = 'DS13/icons/weapons/melee.dmi'
	item_state = "borgtool"
	icon_state = "borgtool"
	lefthand_file = 'DS13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'DS13/icons/mob/inhands/weapons/guns_righthand.dmi'
	resistance_flags = UNACIDABLE
	var/mode = "assimilate"
	var/convert_time = 30 //3 seconds
	item_flags = NODROP
	force = 18 //hella strong
	var/saved_time
	var/cooldown = 10
	var/resource_amount = 10 //Starts with a bit so you can build a structure from the get-go
	var/resource_cost = 10
	var/busy = FALSE //Are you performing an action already? This avoids infinite turf conversion

/obj/item/borg_tool/attack_self(mob/user)
	var/list/options = list("build", "combat", "assimilate")
	for(var/option in options)
		options[option] = image(icon = 'DS13/icons/actions/actions_borg.dmi', icon_state = "[option]")
	var/dowhat = show_radial_menu(user,user,options)
	if(!dowhat)
		return
	mode = dowhat
	to_chat(user,"<font color='green' size='2'><b>[src] is now set to [dowhat] mode.</b></font>")
	playsound(user.loc, 'sound/items/jaws_pry.ogg', 100,1)

/obj/item/borg_tool/attackby(obj/item/stack/I, mob/user)
	if(istype(I, /obj/item/stack))
		resource_amount += I.amount
		to_chat(user, "We have inserted [I] into our [src], its current resource count is: [resource_amount]")
		qdel(I)

/obj/item/borg_tool/examine(mob/user)
	. = ..()
	to_chat(user, "it has [resource_amount] units of resources stored, with a construction cost of [resource_cost] units per structure built")

/obj/item/borg_tool/proc/build_on_turf(turf/open/T, mob/user)
	if(!busy)
		var/obj/structure/CP = locate(/obj/structure) in T
		var/obj/machinery/CA = locate(/obj/machinery) in T
		if(CP || CA)
			to_chat(user,"<span class='danger'>[T] already has a structure on it.</span>")
			return
		var/mode = input("Borg construction.", "Build what?")in list("Conversion suite", "Borg alcove","Wall","Cancel")
		var/obj/structure/chair/borg/suite
		switch(mode)
			if("Conversion suite")
				suite = /obj/structure/chair/borg/conversion
			if("Borg alcove")
				suite = /obj/structure/chair/borg/charging
			if("Wall")
				suite = /turf/closed/wall/trek_smooth/borg
			if("Cancel")
				return
		if(resource_amount >= resource_cost)
			busy = TRUE //stop spamming
			to_chat(user, "<span class='danger'>We are constructing a structure ontop of [T].</span>")
			playsound(user.loc, 'sound/items/rped.ogg',100,1)
			if(do_after(user, convert_time, target = T)) //doesnt get past here
				var/atom/newsuite = new suite(get_turf(T))
				busy = FALSE
				to_chat(user, "We have built a [newsuite.name]")
				resource_amount -= resource_cost
				return
			busy = FALSE //Catch
		else
			to_chat(user, "Our borg tool does not have enough stored material, it has [resource_amount], but it needs [resource_cost] to build a structure")

/obj/item/borg_tool/proc/assimilate_human(mob/user,mob/living/carbon/human/I)
	var/mob/living/carbon/human/M = I
	if(user == M)
		to_chat(user, "<span class='warning'>There is no use in assimilating ourselves.</span>")
		return
	if(isBorgDrone(M))
		to_chat(user, "<span class='warning'>They are already in the collective.</span>")
		return
	if(!M.mind && M.stat != DEAD)
		to_chat(user, "[M] does not have a consciousness, they would add nothing to the collective. Nanites programmed for disposal of waste life-form.")
		M.death()
		return
	to_chat(M, "<span class='warning'>[user] pierces you with their assimilation tubules!</span>")
	SEND_SIGNAL(M, COMSIG_LIVING_MINOR_SHOCK)
	M.Jitter(3)
	M.visible_message("<span class='warning'>[user] pierces [M] with their assimilation tubules!</span>")
	playsound(M.loc, 'sound/weapons/pierce.ogg', 100,1)
	if(do_after(user, 50, target = M)) //5 seconds
		M.mind.make_borg()
		var/obj/item/organ/body_egg/borgNanites/nanitelattice = new(get_turf(M))
		nanitelattice.Insert(M)
		return

/obj/item/borg_tool/afterattack(atom/I, mob/living/user, proximity)
	if(iscarbon(user))
		var/mob/living/carbon/thecarbon = user
		if(thecarbon.handcuffed)
			to_chat(thecarbon, "<span class='warning'>We cannot use our tool when handcuffed.</span>")
			return
	if(proximity)
		if(mode == "assimilate") //assimilate
			if(ishuman(I))
				assimilate_human(user, I)
			if(istype(I, /turf/open))
				if(istype(I, /turf/open/floor/plating/borg))
					return
				if(busy)
					return FALSE
				var/turf/open/A = I
				to_chat(user, "<span class='danger'>We are assimilating [I].</span>")
				busy = TRUE
				if(do_after(user, convert_time, target = A))
					if(A.TerraformTurf(/turf/open/floor/plating/borg, /turf/open/floor/plating/borg))
						resource_amount += 5
					for(var/turf/open/TA in orange(A,1))
						if(!istype(TA, /turf/open/floor/plating/borg) && !istype(TA, /turf/open/openspace))
							if(TA.TerraformTurf(/turf/open/floor/plating/borg, /turf/open/floor/plating/borg))
								resource_amount += 5
				busy = FALSE
			if(istype(I, /turf/closed/wall) && !istype(I, /turf/closed/wall/trek_smooth/borg))
				if(busy)
					return
				playsound(src.loc, 'DS13/sound/effects/borg/machines/convertx.ogg', 40, 4)
				to_chat(user, "<span class='danger'>We are assimilating [I].</span>")
				var/turf/closed/wall/A = I
				if(do_after(user, convert_time, target = A))
					if(A.TerraformTurf(/turf/closed/wall/trek_smooth/borg, /turf/closed/wall/trek_smooth/borg)) //if it's indestructible, this will fail
						for(var/turf/closed/TA in orange(A,1))
							if(!istype(TA, /turf/open) && !istype(TA, /turf/closed/wall/trek_smooth/borg) && !istype(TA, /turf/closed/indestructible))
								TA.ChangeTurf(/turf/closed/wall/trek_smooth/borg)
								resource_amount += 5
						return TRUE
					else
						to_chat(user, "Conversion failed. This structure is resistant to nanoprobes.")
						return FALSE
				busy = FALSE
		if(mode == "combat")
			if(istype(I, /obj/machinery/door/airlock) && !busy)
				tear_airlock(I, user)
				return
			if(istype(I, /mob/living/carbon/human))
				if(world.time <= saved_time + cooldown)
					return ..()
				saved_time = world.time
				var/mob/living/carbon/human/target = I
				user.start_pulling(target, supress_message = TRUE) //Instant aggro-grab combo. Borg need a really strong close range attack.
				target.grabbedby(user, 1)
				if(user.grab_state >= GRAB_NECK)
					target.grabbedby(user, 1)
				else
					user.start_pulling(target, supress_message = TRUE)
					if(user.pulling)
						target.stop_pulling()
						log_combat(user, target, "grabbed", addition="aggressively")
						user.grab_state = GRAB_NECK //Instant neck grab
				target.visible_message("<span class='warning'>[user] violently grabs [target]!</span>", \
				"<span class='userdanger'>[user] violently grabs you!</span>")
				target.Jitter(3)
				playsound(target.loc, 'DS13/sound/effects/borg/grab.ogg', 100,1)
				assimilate_human(user, target)
		if(mode == "build")
			if(istype(I, /turf/open))
				var/turf/open/T = I
				build_on_turf(T, user)
				return
	else
		. = ..()

/obj/item/borg_tool/proc/tear_airlock(obj/machinery/door/airlock/A, mob/user)
	busy = TRUE
	to_chat(user,"<span class='notice'>You start tearing apart the airlock...\
		</span>")
	playsound(src.loc, 'DS13/sound/effects/borg/machines/borgforcedoor.ogg', 100, 4)
	A.audible_message("<span class='italics'>You hear a loud metallic \
		grinding sound.</span>")
	if(do_after(user, delay=80, needhand=FALSE, target=A, progress=TRUE))
		A.audible_message("<span class='danger'>[A] is ripped \
			apart by [user]!</span>")
		qdel(A)
	busy = FALSE