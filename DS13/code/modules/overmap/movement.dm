/*
	 	|||||||||||||||||WARNING|||||||||||||||||||||||
				SHITCODE QUARANTINE AREA
		|||||||||||||||||WARNING|||||||||||||||||||||||
*/

/obj/structure/overmap
	animate_movement = 0
	appearance_flags = PIXEL_SCALE //Makes the sprite look smooth when rotating
	var/list/crew = list()
	var/mob/living/pilot
	var/mob/living/tactical
	var/mob/living/science
	var/list/operators = list()
	var/sprite_size = 96 //Change this per ship!

//Movement variables
/obj/structure/overmap
	var/angle = 0 //This replaces DIR with pixel move
	var/vel = 0 //How fast are we travelling? This behaves like a vector.
	var/turnspeed = 0.8 //Rate of turning. This can be a decimal
	var/max_speed = 3 //Maximum velocity
	var/acceleration = 0.5 //How quickly do you put on speed?
	var/obj/structure/overmap/nav_target
	var/process = FALSE
	var/movement_block = FALSE //If you make a planet, station etc. Set this to TRUE or it'll be movable!
	var/orbit = FALSE //are we an AI that wants to orbit?

/obj/structure/overmap/Initialize()
	. = ..()
	OvermapInitialize()
	spawn(0) //Branch off here so we can run our while loop.
		start_process()

/obj/structure/overmap/proc/start_process()
	process = TRUE
	while(process)
		if(QDELETED(src))
			process = FALSE
			return
		stoplag()
		ProcessMove()
		if(nav_target && !movement_block)
			TurnTo(nav_target)
		if(tractor_target)
			tractor_pull()
		if(orbit)
			overmap_orbit()

/obj/structure/overmap/proc/overmap_orbit() //Ultra simple orbit proc. This is used so that AIs can kite around
	angle -= turnspeed

//Procs
/obj/structure/overmap/proc/EditAngle() //Visibly rotate the sprite
	var/matrix/M = matrix() //create matrix for transformation
	if(angle <= -360)
		angle = 0
	if(angle >= 360)
		angle = 0
//	heading = -angle
	M.Turn(-angle) //reverse angle due to weird logic
	src.transform = M //set matrix

/obj/structure/overmap/proc/ProcessMove()
	if(movement_block)
		return
	EditAngle() //we need to edit the transform just incase
	var/x_speed = vel * cos(angle)
	var/y_speed = vel * sin(angle)
	PixelMove(x_speed,y_speed)
	parallax_update()
	for(var/mob/M in operators)
		if(M.client)
			M.client.AdjustView()
	if(vel < 9 && warping)//Are we warping and have slowed down? Trigger the exiting warp sound effect!
		stop_warping()
	if(nav_target)
		if(nav_target in orange(src, 1)) //if we're near our navigational target, slam on the brakes
			if(vel > 0)
				if(vel >= 40)
					vel -= 10
				else if(vel >= 20)
					vel -= 2 //Smooth stop, even at high warp.
				else
					vel -= acceleration

/obj/structure/overmap/proc/parallax_update()
	if(pilot && pilot.client)
		for(var/PP in pilot.client.parallax_layers)
			var/obj/screen/parallax_layer/P = PP
			var/x_speed = 5 * cos(angle)
			var/y_speed = 5 * sin(angle)
			P.PixelMove(x_speed,y_speed) //Cause the parallax to move as the ship does
			pilot.hud_used.update_parallax()
	if(tactical && tactical.client)
		for(var/PP in tactical.client.parallax_layers)
			var/obj/screen/parallax_layer/P = PP
			var/x_speed = 5 * cos(angle)
			var/y_speed = 5 * sin(angle)
			P.PixelMove(x_speed,y_speed) //Cause the parallax to move as the ship does
			tactical.hud_used.update_parallax()
	if(science && science.client)
		for(var/PP in science.client.parallax_layers)
			var/obj/screen/parallax_layer/P = PP
			var/x_speed = 5 * cos(angle)
			var/y_speed = 5 * sin(angle)
			P.PixelMove(x_speed,y_speed) //Cause the parallax to move as the ship does
			science.hud_used.update_parallax()


//Now it's time to handle people observing the ship.
/mob/camera/aiEye/remote/overmap_observer
	name = "Inactive Camera Eye"
	var/datum/action/innate/camera_off/overmap/off_action

/datum/action/innate/camera_off/overmap
	name = "Stop observing"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"
	var/mob/camera/aiEye/remote/overmap_observer/remote_eye
	var/mob/living/user

/datum/action/innate/camera_off/overmap/Activate()
	if(!target || !isliving(target))
		return
	var/obj/structure/overmap/ship = remote_eye.origin
	ship.crew -= remote_eye
	ship.exit(target)
	qdel(remote_eye)
	target = null
	user.remote_control = null
	user.overmap_ship = null
	if(user.client)
		user.reset_perspective(null)
	user = null
	qdel(src)

/obj/structure/overmap/proc/remove_eye_control(mob/living/user)

/mob/camera/aiEye/remote/overmap_observer/relaymove(mob/user,direct)
	origin.relaymove(user,direct) //Move the ship. Means our pilots don't fucking suffocate because space is C O L D
	return

/mob/camera/aiEye/remote/overmap_observer/Initialize()
	. = ..()
	while(!QDELETED(src) && origin && !QDELETED(origin))
		forceMove(get_turf(origin))
		if(eye_user && eye_user.client)
			eye_user.client.AdjustView()

/obj/structure/overmap/proc/enter(mob/living/carbon/human/user, var/what = "pilot")
	if(user.client)
		if(!what)
			what = alert(user,"What role would you like to pick?","[name]","pilot","tactical","science")
		switch(what)
			if("pilot")
				if(pilot)
					if(alert("Kick [pilot] off of the ship controls?","[name]","Yes","No") == "No")
						return
					to_chat(user, "you kick [pilot] off the ship controls!")
					exit(pilot)
				pilot = user
				GrantActions(user)
			if("tactical")
				if(tactical)
					if(alert("Kick [tactical] off of the ship controls?","[name]","Yes","No") == "No")
						return
					to_chat(user, "you kick [tactical] off the ship controls!")
					exit(tactical)
				tactical = user
			if("science")
				if(science)
					if(alert("Kick [science] off of the ship controls?","[name]","Yes","No") == "No")
						return
					to_chat(user, "you kick [science] off the ship controls!")
					exit(science)
				science = user
	operators += user
	user.overmap_ship = src
	CreateEye(user) //Your body stays there but your mind stays with me - 6 (Battlestar galactica)
	after_enter(user)
	if(!process)
		spawn(0) //We need to process to move. We spawn() here so we don't hold up the proc based on the while loop, same as initialize.
			start_process()

/obj/structure/overmap/proc/CreateEye(mob/user)
	if(!user.client)
		return
	user.client.AdjustView()
	user.update_sight()
	var/mob/camera/aiEye/remote/overmap_observer/eyeobj = new
	eyeobj.origin = src
	crew += eyeobj
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

/obj/structure/overmap/proc/exit(mob/user) //You don't get to leave
	if(user.client)
		user.client.AdjustView()
	after_exit(user)
	user.sight = initial(user.sight)
	user.update_sight()
	user.overmap_ship = null
	user.update_sight()
	user.cancel_camera()
	if(user.client)
		user.client.AdjustView()
		user.reset_perspective(null)
	operators -= user
	if(user == pilot)
		RemoveActions(user)
		pilot = null
	if(user == tactical)
		tactical = null
	if(user == science)
		science = null
	return

/mob
	var/obj/structure/overmap/overmap_ship = null

/client
	perspective = EYE_PERSPECTIVE //Use this perspective or else shit will break! (sometimes screen will turn black)

/client/proc/AdjustView()
	if(mob.overmap_ship)
		pixel_x = mob.overmap_ship.pixel_x
		pixel_y = mob.overmap_ship.pixel_y
		eye = mob.overmap_ship
	else
		pixel_x = 0
		pixel_y = 0
		eye = mob


/atom/movable
	var/real_pixel_x = 0 //variables for the real pixel_x
	var/real_pixel_y = 0 //variables for shit

/atom/movable/proc/PixelMove(var/x_to_move,var/y_to_move) //Don't ask. It just works
	var/obj/structure/overmap/O = src
	var/icon/I = icon(icon,icon_state,SOUTH) //SOUTH because all overmaps only ever face right, no other dirs.
	var/pixel_collision_size_x = I.Width()
	var/pixel_collision_size_y = I.Height()
	for(var/atom/e in obounds(src, real_pixel_x + x_to_move + pixel_collision_size_x/4, real_pixel_y + y_to_move + pixel_collision_size_y/4, real_pixel_x + x_to_move + -pixel_collision_size_x/4, real_pixel_y + y_to_move + -pixel_collision_size_x/4) )//Basic block collision
		if(e.density)
			if(ismob(e))
				return //Ignore mobs. Prevents the glitchy runabout behaviour
			if(istype(e, /obj/structure/meteor))
				var/obj/structure/meteor/S = e
				S.crash(src)
				O.vel = 0
			else
				if(e.CanPass(src))
					continue
				else
					if(!e.mouse_opacity) //Ignore any kind of blockers that aren't truly there
						continue
					Bump(e)
					if(istype(src, /obj/structure/overmap))
						O.vel = 0
					return FALSE

	real_pixel_x = real_pixel_x + x_to_move
	real_pixel_y = real_pixel_y + y_to_move
	while(real_pixel_x > 32) //Modulo doesn't work with this kind of stuff, don't know if there's a better method.
		real_pixel_x = real_pixel_x - 32
		var/turf/T = get_step(src, EAST)
		if(T)
			forceMove(T)
	while(real_pixel_x < -32)
		real_pixel_x = real_pixel_x + 32
		var/turf/T = get_step(src, WEST)
		if(T)
			forceMove(T)
	while(real_pixel_y > 32) //Modulo doesn't work with this kind of stuff, don't know if there's a better method.
		real_pixel_y = real_pixel_y - 32
		var/turf/T = get_step(src, NORTH)
		if(T)
			forceMove(T)
	while(real_pixel_y < -32)
		real_pixel_y = real_pixel_y + 32
		var/turf/T = get_step(src, SOUTH)
		if(T)
			forceMove(T)
	pixel_x = real_pixel_x
	pixel_y = real_pixel_y
	if(istype(src, /obj/structure/overmap))
		O.shield_overlay.pixel_x = pixel_x
		O.shield_overlay.pixel_y = pixel_y
		O.shield_overlay.forceMove(get_turf(src))

/obj/structure/overmap/relaymove(mob/mob,dir)
	if(!pilot || mob != pilot || movement_block || engine_power <= 0)
		return //Only pilot can steer :)
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
					nav_target = null
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
					nav_target = null
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

/obj/structure/overmap/proc/TurnTo(atom/target)
	if(target)
		var/obj/structure/overmap/self = src //I'm a reel cumputer syentist :)
		var/target_angle = 450 - SIMPLIFY_DEGREES(ATAN2((32*target.y+target.pixel_y) - (32*self.y+self.pixel_y), (32*target.x+target.pixel_x) - (32*self.x+self.pixel_x)))
		EditAngle()
	//	target_angle = closer_angle_difference(angle, target_angle)
		target_angle = MODULUS(target_angle, 360)
		if(angle == target_angle)
			return
		if(angle > target_angle) //This one works
			var/goal = angle - target_angle
			if(goal < turnspeed)
				angle -= goal
				return
			angle -= turnspeed
		if(angle < target_angle)
			var/goal = target_angle - angle
			if(goal < turnspeed)
				angle += goal
				return
			angle += turnspeed
