//Adapted from FTL 13. Allows admins to directly open a line to the bridge.

/obj/machinery/holopad/attack_ghost(mob/user)
	if(outgoing_call || !user || !check_rights(R_ADMIN))
		return
	if(alert(user,"Open a starfleet command priority channel with the crew?","Robust hologram creator","Yes","No") != "Yes")
		return
	var/mob/living/carbon/human/communicator/admin/C = new(get_turf(src))
	C.alpha = 0
	C.emitter = src
	C.original_ghost = C
	C.admin_select_appearance()
	C.ckey = user.ckey
	playsound(loc, 'DS13/sound/effects/admin_message.ogg', 100) //You better pick up this goddamn channel boi
	to_chat(user, "<span class='notice'>Click anywhere to terminate transmission. You can move as far from the transmitter as you like.</span>")

// This is basically a communications hologram mob. It can exist in nullspace
// or it can be manifested on a communications holopad. It usually controls a
// ship, unless it's adminspawned, then it's just a CC hologram or something.
/mob/living/carbon/human/communicator
	name = "Communicator"
	desc = "A communications hologram. This person is somewhere else, but they're being projected here via a communications device."
	var/mob/original_ghost
	density = FALSE
	status_flags = GODMODE  // You can't damage it.
	var/obj/machinery/holopad/emitter

/mob/living/carbon/human/communicator/New()
	gender = pick(MALE,FEMALE)
	name = random_unique_name(gender)
	..()

/mob/living/carbon/human/communicator/admin/ClickOn(target)
	if(alert(src,"End communications?","Admin hologram panel","Yes","No") == "Yes")
		if(original_ghost && ckey)
			original_ghost.ckey = ckey
			qdel(src)

/mob/living/carbon/human/communicator/proc/update_hologram_to_outfit(datum/outfit/O)
	if(O)
		equipOutfit(O)
	alpha = 150
	add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)

/mob/living/carbon/human/communicator/proc/admin_select_appearance()
	real_name = input("Select a name for your communications hologram", "Robust hologram creator") as text
	name = real_name
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