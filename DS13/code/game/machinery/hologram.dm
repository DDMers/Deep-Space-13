//Adapted from FTL 13. Allows admins to directly open a line to the bridge.

/obj/machinery/holopad/attack_ghost(mob/user)
	if(outgoing_call || !user || !check_rights(R_ADMIN))
		return
	if(alert(user,"Open a starfleet command priority channel with the crew?","Robust hologram creator","Yes","No") != "Yes")
		return
	var/mob/living/communicator/admin/C = new(get_turf(src))
	C.alpha = 0
	C.original_ghost = C
	C.admin_select_appearance()
	C.ckey = user.ckey
	playsound(loc, 'DS13/sound/effects/admin_message.ogg', 100) //You better pick up this goddamn channel boi
	to_chat(user, "<span_class='notice'>Click anywhere to terminate transmission. You can move as far from the transmitter as you like.</span>")

// This is basically a communications hologram mob. It can exist in nullspace
// or it can be manifested on a communications holopad. It usually controls a
// ship, unless it's adminspawned, then it's just a CC hologram or something.
/mob/living/communicator
	name = "Communicator"
	desc = "A communications hologram. This person is somewhere else, but they're being projected here via a communications device."
	var/mob/original_ghost
	density = FALSE
	status_flags = GODMODE  // You can't damage it.

/mob/living/communicator/New()
	gender = pick(MALE,FEMALE)
	name = random_unique_name(gender)
	..()

/mob/living/communicator/admin/ClickOn(target)
	. = ..()
	if(alert(src,"End communications?","Admin hologram panel","Yes","No") == "Yes")
		if(original_ghost && ckey)
			original_ghost.ckey = ckey
			qdel(src)

/mob/living/communicator/proc/update_hologram_to_outfit(datum/outfit/O)
	if(!O)
		return
	var/mob/living/carbon/human/dummy/mannequin = new(get_turf(pick(GLOB.prisonwarp)))
	mannequin.equipOutfit(O)
	CHECK_TICK
	var/icon/mob_icon = icon('icons/effects/effects.dmi', "nothing")
	CHECK_TICK
	// This is a bit of extra work, but I find it really annoying when sprites
	// permanently face south (I'm looking at you, Paradise)
	for(var/cdir in GLOB.cardinals)
		mannequin.setDir(cdir)
		mob_icon.Insert(getFlatIcon(mannequin), dir=cdir)
		CHECK_TICK
	icon = getHologramIcon(mob_icon, 1, "green")
	alpha = 255
	qdel(mannequin)

/mob/living/communicator/proc/admin_select_appearance()
	name = input("Select a name for your communications hologram", "Robust hologram creator") as text
	var/list/outfits = list("Naked","Custom","As Job...")
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job)
	for(var/path in paths)
		var/datum/outfit/O = path //not much to initalize here but whatever
		if(initial(O.can_be_admin_equipped))
			outfits[initial(O.name)] = path

	var/dresscode = input("Select outfit", "Robust quick dress shop") as null|anything in outfits
	if (isnull(dresscode))
		return

	if (outfits[dresscode])
		dresscode = outfits[dresscode]

	if (dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path

		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in job_outfits
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if (dresscode == "Custom")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = input("Select outfit", "Robust quick dress shop") as null|anything in custom_names
		dresscode = custom_names[selected_name]
		if(isnull(dresscode))
			return
	update_hologram_to_outfit(dresscode)