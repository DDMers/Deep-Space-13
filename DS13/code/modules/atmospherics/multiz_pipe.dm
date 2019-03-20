/obj/machinery/atmospherics/components/unary/multiz //A special pipe which passes its air contents to the pipe above it.
	name = "multi deck pipe adapter"
	desc = "An adapter which allows pipes to connect to other pipenets on different decks."
	icon_state = "multiz_pipe"
	icon = 'DS13/icons/obj/atmos.dmi'
	density = TRUE
	anchored = TRUE
	var/obj/machinery/atmospherics/components/unary/multiz/above

/obj/machinery/atmospherics/components/unary/multiz/Initialize() //Atmos code. I fucking hate you, do you realize how much I fucking hate atmos code? you can't possibly comprehend HOW MUCH i GODDAMN HATE. ATMOS. CODE.
	. = ..()
	var/turf/T = get_turf(src)
	above = locate(/obj/machinery/atmospherics/components/unary/multiz) in(SSmapping.get_turf_above(T))
	SSair.atmos_machinery += src

/obj/machinery/atmospherics/components/unary/multiz/proc/fuckatmoscode()
	SSair.atmos_machinery += src

/obj/machinery/atmospherics/components/unary/multiz/process()
	. = ..()
	process_atmos()
	addtimer(CALLBACK(src, .proc/fuckatmoscode), 20)

/obj/machinery/atmospherics/components/unary/multiz/process_atmos()
	. = ..()
	addtimer(CALLBACK(src, .proc/fuckatmoscode), 20)
	if(!above || !anchored) //We've lost our link. Keep trying to restablish. If !anchored, it's assumed we're moving.
		var/turf/T = get_turf(src)
		above = locate(/obj/machinery/atmospherics/components/unary/multiz) in(SSmapping.get_turf_above(T))
		return
	var/datum/gas_mixture/air_contents = airs[1]
	var/datum/gas_mixture/above_air_contents = above.airs[1]
	above_air_contents.merge(air_contents)
	qdel(air_contents) //Don't dupe the air!

/obj/machinery/atmospherics/pipe/simple/multiz
	name = "multi deck pipe adapter"
	desc = "An adapter which allows pipes to connect to other pipenets on different decks."
	icon_state = "pipe11-2"
	icon = 'DS13/icons/obj/atmos.dmi'

/obj/machinery/atmospherics/pipe/simple/multiz/pipeline_expansion()
	icon = 'DS13/icons/obj/atmos.dmi' //Just to refresh.
	var/turf/T = get_turf(src)
	var/obj/machinery/atmospherics/pipe/simple/multiz/above = locate(/obj/machinery/atmospherics/pipe/simple/multiz) in(SSmapping.get_turf_above(T))
	if(above)
		to_chat(world, "above!")
		nodes += above
		above.nodes += src //Two way travel :)
		return ..()
	else
		return ..()