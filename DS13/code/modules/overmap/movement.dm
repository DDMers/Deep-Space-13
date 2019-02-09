/*
	 	|||||||||||||||||WARNING|||||||||||||||||||||||
				SHITCODE QUARANTINE AREA
		|||||||||||||||||WARNING|||||||||||||||||||||||
*/

/obj/structure/overmap
	animate_movement = 0
	appearance_flags = PIXEL_SCALE //Makes the sprite look smooth when rotating
	pixel_collision_size_x = 48
	pixel_collision_size_y = 48
	var/list/crew = list()
	var/mob/living/pilot
	var/mob/living/tactical
	var/mob/living/science

//Movement variables
/obj/structure/overmap
	var/angle = 0 //This replaces DIR with pixel move
	var/vel = 0 //How fast are we travelling? This behaves like a vector.
	var/turnspeed = 2.2 //Rate of turning. This can be a decimal
	var/max_speed = 4 //Maximum velocity
	var/acceleration = 0.5 //How quickly do you put on speed?
	var/obj/structure/overmap/nav_target

/obj/structure/overmap/Initialize()
	. = ..()
	OvermapInitialize()
	while(!QDELETED(src)) // This is the highest possible process speed we can get in ss13, and boy do we need it.
		stoplag()
		ProcessMove()
//Procs
/obj/structure/overmap/proc/EditAngle() //Visibly rotate the sprite
	var/matrix/M = matrix() //create matrix
	M.Turn(-angle) //reverse angle
	src.transform = M //set matrix

/obj/structure/overmap/proc/ProcessMove()
	EditAngle() //we need to edit the transform just incase
	var/x_speed = vel * cos(angle)
	var/y_speed = vel * sin(angle)
	PixelMove(x_speed,y_speed)
	parallax_update()
	if(pilot && pilot.client)
		pilot.client.AdjustView()
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
	while(!QDELETED(src) && origin)
		forceMove(get_turf(origin))

/obj/structure/overmap/proc/enter(mob/living/carbon/human/user, var/what = "pilot")
	if(user.client)
		what = alert("What role would you like to pick?","[name]","pilot","tactical","science")
		switch(what)
			if("pilot")
				if(pilot)
					if(alert("Kick [pilot] off of the ship controls?","[name]","Yes","No") == "Yes")
						to_chat(user, "you kick [pilot] off the ship controls!")
						exit(pilot)
				pilot = user
			if("tactical")
				if(tactical)
					if(alert("Kick [tactical] off of the ship controls?","[name]","Yes","No") == "Yes")
						to_chat(user, "you kick [tactical] off the ship controls!")
						exit(tactical)
				tactical = user
			if("science")
				return
	user.overmap_ship = src
	user.client.AdjustView()
	user.update_sight()
	CreateEye(user) //Your body stays there but your mind stays with me - 6 (Battlestar galactica)

/obj/structure/overmap/proc/CreateEye(mob/user)
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
	user.sight = initial(user.sight)
	user.update_sight()
	qdel(user.remote_control)
	user.overmap_ship = null
	user.update_sight()
	if(user.client)
		user.client.AdjustView()
		user.reset_perspective(null)
	if(user == pilot)
		pilot = null
		return
	if(user == tactical)
		tactical = null
		return
	if(user == science)
		science = null
		return
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


atom/movable
	var
		real_pixel_x = 0 //variables for the real pixel_x
		real_pixel_y = 0 //variables for shit
		pixel_collision_size_x = 0
		pixel_collision_size_y = 0
	proc
		PixelMove(var/x_to_move,var/y_to_move) //Don't ask. It just works
			var/obj/structure/overmap/O = src
			for(var/turf/e in obounds(src, real_pixel_x + x_to_move + pixel_collision_size_x/4, real_pixel_y + y_to_move + pixel_collision_size_y/4, real_pixel_x + x_to_move + -pixel_collision_size_x/4, real_pixel_y + y_to_move + -pixel_collision_size_x/4) )//Basic block collision
				if(e.density == 1) //We can change this so the ship takes damage later
					if(istype(src, /obj/structure/overmap))
						O.angle -= 180
						O.EditAngle()
						O.vel = 1
						sleep(10)
						O.vel = 0
					return 0
			real_pixel_x = real_pixel_x + x_to_move
			real_pixel_y = real_pixel_y + y_to_move
			while(real_pixel_x > 32) //Modulo doesn't work with this kind of stuff, don't know if there's a better method.
				real_pixel_x = real_pixel_x - 32
				x = x + 1
			while(real_pixel_x < -32)
				real_pixel_x = real_pixel_x + 32
				x = x - 1
			while(real_pixel_y > 32) //Modulo doesn't work with this kind of stuff, don't know if there's a better method.
				real_pixel_y = real_pixel_y - 32
				y = y + 1
			while(real_pixel_y < -32)
				real_pixel_y = real_pixel_y + 32
				y = y - 1
			pixel_x = real_pixel_x
			pixel_y = real_pixel_y
			if(istype(src, /obj/structure/overmap))
				O.shield_overlay.pixel_x = pixel_x
				O.shield_overlay.pixel_y = pixel_y
				O.shield_overlay.forceMove(get_turf(src))

/obj/structure/overmap/relaymove(mob/mob,dir)
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

/obj/structure/overmap/proc/TurnTo(atom/target)
	if(target)
		var/obj/structure/overmap/self = src //I'm a reel cumputer syentist :)
		EditAngle()
		var/target_angle = 450 - SIMPLIFY_DEGREES(ATAN2((32*target.y+target.pixel_y) - (32*self.y+self.pixel_y), (32*target.x+target.pixel_x) - (32*self.x+self.pixel_x)))
		if(angle > target_angle)
			angle -= turnspeed
		if(angle < target_angle)
			angle += turnspeed
		if(angle == target_angle)
			return