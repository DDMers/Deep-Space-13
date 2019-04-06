/obj/item/radio/headset
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "headset"
	item_state = "headset"
	icon = 'DS13/icons/obj/radio.dmi'
	var/speak_sound = 'DS13/sound/effects/combadge.ogg'

/obj/item/radio/headset/syndicate //disguised to look like a normal headset for stealth ops

/obj/item/radio/headset/syndicate/alt //undisguised bowman with flash protection
	name = "syndicate combadge"
	desc = "A syndicate combadge that can be used to hear all radio frequencies. Protects ears from flashbangs."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"

/obj/item/radio/headset/syndicate/alt/leader
	name = "team leader combadge"
	command = TRUE

/obj/item/radio/headset/headset_sec
	name = "combadge"
	icon_state = "sec_headset"

/obj/item/radio/headset/headset_sec/alt
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. This one protects you from flashbangs."
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/radio/headset/headset_eng
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."

/obj/item/radio/headset/headset_rob
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "rob_headset"

/obj/item/radio/headset/headset_med
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "med_headset"

/obj/item/radio/headset/headset_sci
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "sci_headset"

/obj/item/radio/headset/headset_medsci
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "medsci_headset"

/obj/item/radio/headset/headset_com
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "com_headset"

/obj/item/radio/headset/heads
	command = TRUE

/obj/item/radio/headset/heads/captain
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "com_headset"


/obj/item/radio/headset/heads/captain/alt
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Protects ears from flashbangs."
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/rd
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "com_headset"

/obj/item/radio/headset/heads/hos
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "com_headset"

/obj/item/radio/headset/heads/hos/alt
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Protects ears from flashbangs."
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/ce
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "com_headset"

/obj/item/radio/headset/heads/cmo
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "com_headset"

/obj/item/radio/headset/heads/hop
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "com_headset"

/obj/item/radio/headset/headset_cargo
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "cargo_headset"

/obj/item/radio/headset/headset_cargo/mining
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "mine_headset"

/obj/item/radio/headset/headset_srv
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "srv_headset"

/obj/item/radio/headset/headset_cent
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Takes encryption keys."
	icon_state = "cent_headset"

/obj/item/radio/headset/headset_cent/alt
	name = "combadge"
	desc = "A pin which bears the starfleet insignia, this combination of a badge and a radio allows you to talk over comms!. Protects ears from flashbangs."
	icon_state = "cent_headset_alt"
	item_state = "cent_headset_alt"

/obj/item/radio/headset/talk_into(atom/movable/M, message, channel, list/spans, datum/language/language)
	playsound(M.loc,speak_sound,80,1)
	. = ..()