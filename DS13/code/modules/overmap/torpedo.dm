#define INSERT 1
#define SCANNING_MODULE 2
#define SCREWDRIVER 3
#define MATTER_BIN 4
#define CROWBAR 5
#define BODY 6

GLOBAL_LIST_EMPTY(used_names) //For NLR. What characters have already been used and have fallen in battle?

/obj/structure/overmap_component/torpedo_tube
	name = "Torpedo tube"
	desc = "A tube hooked directly into the ship's main photon torpedo launchers. You can use this to fire torpedoes, or perform burial ceremonies for your dead crew <b>this allows them to respawn</b>. Simply push a torpedo into it to load it."
	icon_state = "launcher"
	var/step = INSERT
	var/cooldown = 20 //Small delay in loading torpedoes to prevent lag.
	var/ready = TRUE //Delay stuff
	pixel_y = 32

/obj/structure/overmap_component/torpedo_tube/Bumped(atom/movable/AM)
	if(!ready)
		return ..()
	if(!linked)
		find_overmap()
		return FALSE
	addtimer(CALLBACK(src, .proc/reset), cooldown)
	if(istype(AM, /obj/structure/photon_torpedo))
		var/obj/structure/photon_torpedo/S = AM
		playsound(src, 'DS13/sound/effects/FTL/load.ogg', 50, 1)
		if(S.damage)
			linked.photons ++
			linked.torpedo_damage_list += S.damage
		if(S.stored) //Press F to pay respects
			lay_to_rest(S.stored) //Bottom of file as it's a meaty proc.
			playsound(src, 'DS13/sound/effects/weapons/torpedo.ogg', 50, 1)
		CHECK_TICK
		qdel(AM)
	else
		return ..()

/obj/structure/overmap_component/torpedo_tube/proc/reset()
	ready = TRUE

/obj/structure/torpedo_casing //Scanning, screw, matter, crowbar
	name = "Photon torpedo casing"
	desc = "A basic shell for a warhead, it requires a targeting system (scanning module) to be screwed in, a payload (matter bin) and a cover which must be crowbar'd into place. It can also be loaded with a body instead, to lay their <b>soul</b> to rest."
	icon = 'DS13/icons/overmap/components.dmi'
	icon_state = "torpedo_casing"
	var/state = INSERT
	var/damage = 0 //How effective this torpedo is. Starts at 20
	var/adminabuse = FALSE //Testing var
	density = TRUE

/obj/structure/torpedo_casing/MouseDrop_T(mob/living/target, mob/living/user)
	if(!istype(target))
		return
	if(isliving(target))
		load_human(target, user)

/obj/structure/torpedo_casing/proc/load_human(mob/living/target, mob/living/user)
	if(!istype(target))
		return
	if(state > INSERT)
		to_chat(user, "<span class='warning'>This torpedo is already full. Make a new casing with some metal.</span>")
		return
	if(target != user)
		if(target.stat == CONSCIOUS && !adminabuse) //Yes. You can drug the clown and fire them out the torpedo tube. Or varedit it.
			to_chat(user, "<span class='warning'>They seem a bit lively for a burial!</span>")
			return
	if(target.buckled || target.has_buckled_mobs())
		to_chat(user, "<span class='warning'>This person is attached to something.</span>")
		return
	if(do_after(user,30, target = src))
		state = BODY
		damage = 0
		finish(target)
		to_chat(user, "<span class='notice'>You lay [target] into the coffin, and place a flag over them.</span>")

/obj/structure/torpedo_casing/proc/finish(mob/living/target) //If target. Make a coffin torpedo.
	var/obj/structure/photon_torpedo/torpedo = new(get_turf(src))
	torpedo.damage = damage
	if(target)
		target.forceMove(torpedo)
		torpedo.stored = target //Tells the launcher to just jettison them instead of having the ship use them in combat.
		playsound(src, 'sound/effects/roll.ogg', 5, 1)
		playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
		torpedo.icon_state = "torpedo_flag"
	for(var/atom/I in contents)
		qdel(I)
	CHECK_TICK
	qdel(src)

/obj/structure/torpedo_casing/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stock_parts/scanning_module) && state == INSERT)
		if (do_after(user,30, target = src))
			to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
			I.forceMove(src)
			state = SCANNING_MODULE
			icon_state = "torpedo1"
	if(istype(I, /obj/item/stock_parts/matter_bin) && state == SCREWDRIVER)
		if (do_after(user,30, target = src))
			to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
			I.forceMove(src)
			state = MATTER_BIN
			var/obj/item/stock_parts/matter_bin/S = I
			damage = 10 + (10*S.rating) //Basic torps do 20. Maximum upgraded torps can steamroll everything at 50 damage.
			icon_state = "torpedo3"


/obj/structure/torpedo_casing/screwdriver_act(mob/user, obj/item/I)
	if(state != SCANNING_MODULE)
		return
	playsound(loc,I.usesound,100,1)
	to_chat(user, "<span class='notice'>You start to secure [src]'s targeting array.</span>")
	if(do_after(user, 30, target = src))
		to_chat(user, "<span class='notice'>You secure [src]'s targeting array. You should probably install a payload now.</span>")
		state = SCREWDRIVER
		icon_state = "torpedo2"

/obj/structure/torpedo_casing/crowbar_act(mob/user, obj/item/I)
	if(state != MATTER_BIN)
		return
	playsound(loc,I.usesound,100,1)
	to_chat(user, "<span class='notice'>You start to secure [src]'s protective casings.</span>")
	if(do_after(user, 30, target = src))
		to_chat(user, "<span class='notice'>You finish [src]</span>")
		finish()

/obj/structure/photon_torpedo
	name = "Photon torpedo"
	desc = "An extremely powerful warhead which uses the power of antimatter to wreak havoc on unfortunate enemies."
	icon = 'DS13/icons/overmap/components.dmi'
	icon_state = "torpedo"
	var/mob/living/stored //Anyone inside us?
	var/breaking_out = FALSE //Anyone trying to escape us?
	var/damage = 0
	density = TRUE

/obj/structure/photon_torpedo/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='warning'>Its explosive yield is [damage] isotonnes.</span>")

/obj/structure/photon_torpedo/relaymove(mob/living/user, direction)
	if(!breaking_out)
		to_chat(user, "<span class='warning'>You start frantically shaking to try and escape [src]!</span>")
		var/offset = prob(50) ? -2 : 2
		animate(src, pixel_x = pixel_x + offset, time = 8, loop = 200) //start shaking
		addtimer(VARSET_CALLBACK(src, pixel_x, initial(pixel_x)))
		breaking_out = TRUE
		if (do_after(user,80, target = src))
			user.forceMove(get_turf(src))
			visible_message("<span class='notice'>[user] breaks open [src]!</span>")
			new /obj/structure/torpedo_casing(get_turf(src)) //They break open the coffin.
			qdel(src)
		breaking_out = FALSE
	else
		return FALSE //You can't move a torp from the inside :b1:



/datum/controller/subsystem/job/proc/FreeRole(var/rank)	//making additional slot on the fly
	var/datum/job/job = GetJob(rank)
	if(job && job.current_positions >= job.total_positions && job.total_positions != -1)
		job.total_positions++
		return 1
	return 0

/obj/structure/overmap_component/torpedo_tube/proc/lay_to_rest(mob/living/user)
	if(user.mind && user.mind.assigned_role)
		//Handle job slot/tater cleanup.
		var/job = user.mind.assigned_role

		SSjob.FreeRole(job)
		user.mind.special_role = null

	// Delete them from datacore.
	for(var/datum/data/record/R in GLOB.data_core.medical)
		if((R.fields["name"] == user.real_name))
			GLOB.data_core.medical -= R
			qdel(R)
	for(var/datum/data/record/T in GLOB.data_core.security)
		if((T.fields["name"] == user.real_name))
			GLOB.data_core.security -= T
			qdel(T)
	for(var/datum/data/record/G in GLOB.data_core.general)
		if((G.fields["name"] == user.real_name))
			GLOB.data_core.general -= G
			qdel(G)

	log_game("[user] has been laid to rest. They may now respawn as a randomized character.")

	// Ghost and delete the mob.
	user.ghostize(0)
	var/mob/dead/observer/G = user.get_ghost(TRUE)
	GLOB.used_names += user.real_name
	if(G)
		to_chat(G, "<span class='notice'>Your body has been laid to rest. You will be able to respawn in 5 minutes if you wish (you'll be notified when this timer is up).</span>")
		addtimer(CALLBACK(G, /mob/dead/observer/proc/notify_respawn), 5 MINUTES)
	qdel(user)
	user = null

/mob/dead/observer/proc/notify_respawn()
	if(client)
		window_flash(client)
	SEND_SOUND(src, 'sound/machines/defib_success.ogg')
	to_chat(src, "<span class='warning'>You can now respawn! If you choose to do so, you MUST remember that this is a completely seperate character from your normal one!</span>")
	to_chat(src, "<span class='ghostalert'><a href=?src=\ref[src];respawnrandom=1>(Click to respawn)</a></span>")

/mob/dead/observer/proc/respawn_random()//Kick them back to the lobby.
	if(!client)
		return
	var/mob/dead/new_player/NP = new()
	NP.ckey = client.ckey
	qdel(src)

#undef INSERT
#undef SCANNING_MODULE
#undef SCREWDRIVER
#undef MATTER_BIN
#undef CROWBAR
#undef BODY