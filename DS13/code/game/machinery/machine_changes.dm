GLOBAL_LIST_INIT(zaps, list('DS13/sound/effects/damage/consolehit.ogg','DS13/sound/effects/damage/consolehit2.ogg','DS13/sound/effects/damage/consolehit3.ogg','DS13/sound/effects/damage/consolehit4.ogg'))
GLOBAL_LIST_INIT(bleeps, list('DS13/sound/effects/computer/bleep1.ogg','DS13/sound/effects/computer/bleep2.ogg','DS13/sound/effects/computer/beep.ogg','DS13/sound/effects/computer/beep2.ogg','DS13/sound/effects/computer/beep3.ogg'))

/obj/machinery/proc/explode_effect()
	var/sound = pick(GLOB.zaps)
	playsound(src.loc, sound, 70,1)
	var/bleep = pick(GLOB.bleeps)
	playsound(src.loc, bleep, 70,1)
	do_sparks(5, 8, src)