/proc/new_station_name()
	var/name = "USS [pick(GLOB.station_names)] (NCC[rand(40000,100000)])"
	return name