/obj/item/projectile/beam/laser/phaser
	hitscan = TRUE
	light_color = LIGHT_COLOR_ORANGE
	hitsound = 'DS13/sound/effects/weapons/phaser_hit.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/phaser

/obj/item/projectile/energy/electrode/phaser
	hitscan = TRUE //beams
	light_color = LIGHT_COLOR_ORANGE
	icon_state = "laser"
	hitsound = 'DS13/sound/effects/weapons/phaser_hit.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/phaser
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/heavylaser/phaser
	hitscan = TRUE
	light_color = LIGHT_COLOR_ORANGE
	hitsound = 'DS13/sound/effects/weapons/phaser_hit.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/phaser

/obj/item/projectile/beam/laser/heavylaser/widebeam
	damage = 5 //Low damage to people, rips through walls
	hitscan = TRUE
	light_color = LIGHT_COLOR_ORANGE
	hitsound = 'DS13/sound/effects/weapons/phaser_hit.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/phaser

/obj/item/projectile/beam/laser/heavylaser/widebeam/prehit(atom/target)
	if(isturf(target))
		target.AddComponent(/datum/component/thermite, 50)
		new /obj/effect/hotspot(target)
		var/datum/component/thermite/thermite = target.GetComponent(/datum/component/thermite)
		thermite.thermite_melt()
	. = ..()

/obj/effect/temp_visual/impact_effect/phaser
	icon_state = "impact_phaser"
	duration = 6

/obj/effect/projectile/muzzle/phaser
	icon_state = "muzzle_solar"

/obj/effect/projectile/tracer/phaser
	name = "phaser beam"
	icon_state = "solar"

/obj/item/ammo_casing/energy/electrode/phaserstun
	e_cost = 160
	fire_sound = 'DS13/sound/effects/weapons/phaser.ogg'
	select_name = "stun"
	projectile_type = /obj/item/projectile/energy/electrode/phaser

/obj/item/ammo_casing/energy/laser/phaserkill
	select_name = "kill"
	fire_sound = 'DS13/sound/effects/weapons/phaser.ogg'
	projectile_type = /obj/item/projectile/beam/laser/phaser

/obj/item/ammo_casing/energy/laser/phaser_rifle
	select_name = "kill"
	fire_sound = 'DS13/sound/effects/weapons/phaser_rifle.ogg'
	projectile_type = /obj/item/projectile/beam/laser/heavylaser/phaser

/obj/item/ammo_casing/energy/laser/widebeam
	select_name = "wide beam"
	e_cost = 500
	fire_sound = 'DS13/sound/effects/weapons/phasercut.ogg'
	projectile_type = /obj/item/projectile/beam/laser/heavylaser/widebeam

/obj/item/phaser_pack
	name = "Phaser cell"
	desc = "This tiny and convenient device lets you fully recharge a hand phaser. <i>Simply click a phaser with it.</i>"
	icon = 'DS13/icons/weapons/energy.dmi'
	icon_state = "phaserpack"
	var/uses = 2 //How many recharge cycles is it good for?
	w_class = 1 //Fits in your pocket

/obj/item/phaser_pack/large
	name = "Extended capacity phaser cell"
	icon_state = "phaserpack_large"
	uses = 4

/datum/supply_pack/security/phaserpacks
	name = "Phaser power cells"
	desc = "A supply of 3 standard phaser power packs guaranteed for at least 2 charge cycles."
	cost = 3500
	contains = list(/obj/item/phaser_pack,
					/obj/item/phaser_pack,
					/obj/item/phaser_pack)
	crate_name = "phaser cell crate"
	crate_type = /obj/structure/closet/crate

/datum/design/phaserpack //See all_nodes.dm
	name = "Basic phaser cell"
	desc = "A plasma fuel cell that allows you to quickly recharge a phaser."
	id = "phasercell"
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 70)
	construction_time=100
	build_path = /obj/item/phaser_pack
	category = list("Misc","Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SECURITY

/datum/design/phaserpack_high
	name = "High capacity phaser cell"
	desc = "A large capacity phased-plasma fuel cell that allows you to quickly recharge a phaser."
	id = "phasercell_high"
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 80)
	construction_time=200
	build_path = /obj/item/phaser_pack/large
	category = list("Misc","Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SECURITY


/obj/item/phaser_pack/proc/used()
	uses --
	if(uses <= 0)
		icon_state = "[icon_state]_empty"

/obj/item/phaser_pack/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It has [uses] uses remaining.</span>")

/obj/item/gun/energy/phaser
	name = "hand phaser"
	desc = "A standard issue phaser which was widely used by starfleet in the 24th century. You can set it to <b>stun</b> or <b>kil</b>."
	icon = 'DS13/icons/weapons/energy.dmi'
	icon_state = "phaser"
	ammo_x_offset = 2
	selfcharge = FALSE //Angry reacts only boys.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/phaserstun, /obj/item/ammo_casing/energy/laser/phaserkill)

/obj/item/gun/energy/phaser/attack_self(mob/user)
	. = ..()
	playsound(loc, 'DS13/sound/effects/weapons/phaser_adjust.ogg', 100, 1)

/obj/item/gun/energy/phaser/attackby(obj/item/I, mob/user)
	. = ..()
	if(istype(I, /obj/item/phaser_pack) && cell.charge < cell.maxcharge)
		var/obj/item/phaser_pack/P = I
		if(!P.uses || P.uses <= 0)
			to_chat(user, "<span class='notice'>[P] is depleted, and can't charge anything.</span>")
			return
		var/stored_power = cell.charge //We're going to drain its cell while reloading
		cell.charge = 0
		cut_overlays()
		flick("[icon_state]_reload",src)
		user.visible_message("<span class ='warning'>[user] pops the lid off [src].</span>", "<span class ='warning'>You pop the lid off [src] and start recharging it.</span>")
		playsound(loc, 'sound/weapons/autoguninsert.ogg', 100, 1)
		if(do_after(user, 30, target = src))
			playsound(loc, 'sound/weapons/bulletinsert.ogg', 100, 1)
			playsound(loc, 'DS13/sound/effects/weapons/phaser_adjust.ogg', 100, 1)
			to_chat(user, "<span class='notice'>You fully recharge [src] with [I].</span>")
			P.used()
			cell.charge = cell.maxcharge
			return
		user.visible_message("<span class ='warning'>[user] quickly snaps [src]'s lid back on.</span>")
		cell.charge = stored_power //They cancelled reload. Give them firing perms back
		update_icon()

/obj/item/gun/energy/phaser/rifle
	name = "Heavy phaser rifle"
	desc = "For suppressing large crowds or engaging the borg. This weapon requires you to use both hands."
	w_class = WEIGHT_CLASS_HUGE
	cell_type = /obj/item/stock_parts/cell/upgraded
	icon_state = "phaserrifle"
	weapon_weight = WEAPON_HEAVY
	item_state = "phaserrifle"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/phaserstun, /obj/item/ammo_casing/energy/laser/phaser_rifle,/obj/item/ammo_casing/energy/laser/widebeam)
	lefthand_file = 'DS13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'DS13/icons/mob/inhands/weapons/guns_righthand.dmi'

/obj/item/kitchen/knife/combat/klingon
	name = "Kut'luch"
	desc = "A long bladed dagger used by the Klingons..."
	icon = 'DS13/icons/weapons/melee.dmi'
	icon_state = "kutluch"
	item_state = "kutluch"
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 35, "embedded_fall_chance" = 10)
	force = 15
	throwforce = 15
	lefthand_file = 'DS13/icons/mob/inhands/weapons/items_lefthand.dmi'
	righthand_file = 'DS13/icons/mob/inhands/weapons/items_righthand.dmi'

/obj/item/twohanded/required/klingon
	name = "Bat'Leth"
	desc = "An enormous sword which is the weapon of choice for most Klingons.. If you're reading this then perhaps today IS a good day to die!"
	w_class = WEIGHT_CLASS_HUGE
	sharpness = IS_SHARP
	attack_verb = list("cleaved", "slashed", "torn", "hacked", "ripped", "diced", "carved")
	icon = 'DS13/icons/weapons/melee.dmi'
	icon_state = "batleth"
	item_state = "batleth"
	hitsound = 'sound/weapons/rapierhit.ogg'
	block_chance = 30
	throwforce = 15
	force = 25
	lefthand_file = 'DS13/icons/mob/inhands/weapons/items_lefthand.dmi'
	righthand_file = 'DS13/icons/mob/inhands/weapons/items_righthand.dmi'