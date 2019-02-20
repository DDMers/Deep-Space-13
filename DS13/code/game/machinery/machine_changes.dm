/obj/machinery
	var/list/zaps = list('DS13/sound/effects/damage/consolehit.ogg','DS13/sound/effects/damage/consolehit2.ogg','DS13/sound/effects/damage/consolehit3.ogg','DS13/sound/effects/damage/consolehit4.ogg')
	var/list/bleeps = list('DS13/sound/effects/computer/bleep1.ogg','DS13/sound/effects/computer/bleep2.ogg')

/obj/machinery/proc/explode_effect()
	var/sound = pick(zaps)
	playsound(src.loc, sound, 70,1)
	var/bleep = pick(bleeps)
	playsound(src.loc, bleep, 70,1)
	do_sparks(5, 8, src)