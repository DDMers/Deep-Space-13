/obj/machinery/power/apc/auto_name/ds13
	auto_name = TRUE
	icon = 'DS13/icons/obj/power.dmi' //DeepSpace13 - APC resprite
	dir = NORTHEAST //Stops them from getting the wrong pixel X, Y
	pixel_y = 32 //It goes up so only viewable from south

/obj/machinery/power/apc/auto_name/ds13/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(loc)
	terminal.setDir(1) //To avoid fuckines. Trust me, it just works
	terminal.master = src

/obj/machinery/power/apc/auto_name/ds13/highcap
	cell_type = /obj/item/stock_parts/cell/upgraded/plus