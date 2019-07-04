/obj/item/rc_ship_controller
	name = "NX-T subspace controller"
	desc = "A small controller which allows you to remotely control miniature starships for use in mock battles and general pranks. Simply <b>click</b> the remote controlled ship you want to link it to. Click it <b>in hand</b> to fly whatever it's linked to."
	icon_state = "remotecontroller"
	icon = 'DS13/icons/obj/device.dmi'
	w_class = 1 //Tiny
	var/obj/item/rc_ship/linked
	var/max_range = 30 //30 tile range.

/obj/item/rc_ship_controller/update_icon(var/badconnection)
	if(badconnection)
		icon_state = "remotecontroller-low"
	else
		icon_state = "remotecontroller"

/obj/item/rc_ship_controller/attack_self(mob/user)
	. = ..()
	if(!linked)
		to_chat(user, "<span class='warning'>You need to link a remote controlled ship by using [src] on it first!</span>")
		return
	linked.toggle(user)

/obj/item/rc_ship/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/rc_ship_controller))
		var/obj/item/rc_ship_controller/RC = I
		RC.linked = src
		controller = RC
		to_chat(user, "<span class='warning'>You have successfully linked [src] with [I]</span>")
	. = ..()

/obj/item/rc_ship //Mimicking the overmap movement straight up. It's an item so it can be stored in your bag. Swat it with something to stop it from flying.
	name = "miniature runabout"
	desc = "An extremely accurate replica of a Danube class runabout, it is powered by a small antigravity engine. Batteries not included."
	icon = 'DS13/icons/overmap/rc_ships.dmi'
	icon_state = "runabout"
	animate_movement = 0
	appearance_flags = PIXEL_SCALE //Makes the sprite look smooth when rotating
	density = TRUE
	var/mob/living/pilot
	var/angle = 0 //This replaces DIR with pixel move
	var/vel = 0 //How fast are we travelling? This behaves like a vector.
	var/turnspeed = 3 //Rate of turning. This can be a decimal
	var/max_speed = 5 //Maximum velocity
	var/acceleration = 0.5 //How quickly do you put on speed?
	var/process = FALSE //Movement animation loop
	var/list/crew = list()
	var/obj/item/rc_ship_controller/controller
	w_class = 2 //Fits in your bag
	layer = 4 //Layer over mobs and such

/obj/item/rc_ship/can_be_pulled(mob/user) //Hahahah NO
	return FALSE

/obj/item/rc_ship/Initialize()
	. = ..()
	pass_flags |= PASSTABLE
	spawn(0) //Branch off here so we can run our while loop.
		start_process()

/obj/item/rc_ship/proc/toggle(var/mob/living/user)
	if(!isturf(loc) || !controller)
		return //No moving while it's in your inventory.
	if(get_dist(src, controller) >= controller.max_range)
		to_chat(user, "<span class='notice'>You're too far away from [src] to control it remotely.</span>")
		return
	if(pilot)
		return
	else
		vel = 0
		user.overmap_ship = src
		CreateEye(user)
		pilot = user
		playsound(user.loc, 'DS13/sound/effects/pod_launch.ogg', 40, 1)
		visible_message("<span class='warning>[src] starts to hover a few meters off the ground.</span>")
		if(!process)
			spawn(0) //Branch off here so we can run our while loop.
				start_process()

/obj/item/rc_ship/proc/start_process()
	process = TRUE
	while(process)
		if(QDELETED(src))
			process = FALSE
			return
		stoplag()
		ProcessMove()

//Procs
/obj/item/rc_ship/proc/EditAngle() //Visibly rotate the sprite
	var/matrix/M = matrix() //create matrix for transformation
	if(angle <= -360)
		angle = 0
	if(angle >= 360)
		angle = 0
//	heading = -angle
	M.Turn(-angle) //reverse angle due to weird logic
	src.transform = M //set matrix

/obj/item/rc_ship/Bump(atom/movable/AM)
	if(istype(AM, /obj/machinery/door/airlock))
		if(pilot)
			AM.Bumped(pilot) //If the pilot has access, open the airlock.
	. = ..()

/obj/item/rc_ship/proc/ProcessMove()
	EditAngle() //we need to edit the transform just incase
	var/x_speed = vel * cos(angle)
	var/y_speed = vel * sin(angle)
	PixelMove(x_speed,y_speed)
	parallax_update()
	if(controller)
		var/dist = get_dist(src, controller)
		if(dist >= controller.max_range/2)
			controller.icon_state = "remotecontroller-medium"
		if(dist >= controller.max_range)
			controller.update_icon(TRUE)
	if(pilot && pilot.client)
		pilot.client.AdjustView()

/obj/item/rc_ship/proc/parallax_update()
	if(pilot && pilot.client)
		for(var/PP in pilot.client.parallax_layers)
			var/obj/screen/parallax_layer/P = PP
			var/x_speed = 5 * cos(angle)
			var/y_speed = 5 * sin(angle)
			P.PixelMove(x_speed,y_speed) //Cause the parallax to move as the ship does
			pilot.hud_used.update_parallax()


/obj/item/rc_ship/proc/CreateEye(mob/user)
	if(!user.client)
		return
	user.client.AdjustView()
	user.update_sight()
	var/mob/camera/aiEye/remote/overmap_observer/eyeobj = new
	crew += eyeobj
	eyeobj.origin = src
	eyeobj.off_action = new
	eyeobj.off_action.remote_eye = eyeobj
	eyeobj.eye_user = user
	eyeobj.name = "[name] observer"
	eyeobj.off_action.target = user
	eyeobj.off_action.user = user
	eyeobj.off_action.Grant(user)
	eyeobj.setLoc(eyeobj.loc)
	eyeobj.forceMove(get_turf(src))
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)

/obj/item/rc_ship/equipped(mob/user)
	. = ..()
	vel = 0

/obj/item/rc_ship/proc/exit(mob/user)
	if(user.client)
		user.client.AdjustView()
	user.sight = initial(user.sight)
	user.update_sight()
	user.overmap_ship = null
	user.update_sight()
	user.cancel_camera()
	if(user.client)
		user.client.AdjustView()
		user.reset_perspective(null)
	if(user == pilot)
		pilot = null
	process = FALSE //No need to waste performance
	vel = 0
	return

/obj/item/rc_ship/relaymove(mob/mob,dir)
	if(!pilot || mob != pilot)
		return //Only pilot can steer :)
	if(controller)
		if(get_dist(src, controller) >= controller.max_range)
			to_chat(pilot, "<span class='warning'>Remote control signal range exceeded. Get closer to [src]</span>")
			return
		else
			controller.update_icon(FALSE)
	if(mob.client)
		switch(dir)
			if(NORTH)
				if(mob.overmap_ship)
					if(mob.overmap_ship.vel < max_speed) //burn to speed up
						mob.overmap_ship.vel += acceleration
					else
						mob.overmap_ship.vel = max_speed
					mob.client.AdjustView()
				else
					..()
			if(SOUTH)
				if(mob.overmap_ship)
					if(mob.overmap_ship.vel > 0)
						mob.overmap_ship.vel -= acceleration
					else
						mob.overmap_ship.vel = 0
					mob.overmap_ship.ProcessMove()
					mob.client.AdjustView()
				else
					..()
			if(EAST)
				if(mob.overmap_ship)
					mob.overmap_ship.angle = mob.overmap_ship.angle - turnspeed
					mob.overmap_ship.EditAngle()
				else
					..()
			if(NORTHEAST)
				if(mob.overmap_ship)
					if(mob.overmap_ship.vel < max_speed) //burn to speed up
						mob.overmap_ship.vel += acceleration
					else
						mob.overmap_ship.vel = max_speed
					mob.overmap_ship.angle = mob.overmap_ship.angle - turnspeed
					mob.client.AdjustView()
				else
					..()
			if(WEST)
				if(mob.overmap_ship)
					mob.overmap_ship.angle = mob.overmap_ship.angle + turnspeed
					mob.overmap_ship.EditAngle()
			if(NORTHWEST)
				if(mob.overmap_ship)
					if(mob.overmap_ship.vel < max_speed) //burn to speed up
						mob.overmap_ship.vel += acceleration
					else
						mob.overmap_ship.vel = max_speed
					mob.overmap_ship.angle = mob.overmap_ship.angle + turnspeed
					mob.client.AdjustView()
				else
					..()