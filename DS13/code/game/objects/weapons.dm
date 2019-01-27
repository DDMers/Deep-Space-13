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

/obj/effect/temp_visual/impact_effect/phaser
	icon_state = "impact_phaser"
	duration = 6

/obj/effect/projectile/muzzle/phaser
	icon_state = "muzzle_solar"

/obj/effect/projectile/tracer/phaser
	name = "phaser beam"
	icon_state = "solar"

/obj/item/ammo_casing/energy/electrode/phaserstun
	e_cost = 100
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

/obj/item/gun/energy/phaser
	name = "hand phaser"
	desc = "A standard issue phaser with two modes: Stun and Kill."
	icon = 'DS13/icons/weapons/energy.dmi'
	icon_state = "phaser"
	icon_state = "phaser"
	ammo_x_offset = 2
	selfcharge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/phaserstun, /obj/item/ammo_casing/energy/laser/phaserkill)

/obj/item/gun/energy/phaser/attack_self(mob/user)
	. = ..()
	playsound(loc, 'DS13/sound/effects/weapons/phaser_adjust.ogg', 100, 1)

/obj/item/gun/energy/phaser/rifle
	name = "Heavy phaser rifle"
	desc = "For suppressing large crowds or engaging the borg. This weapon requires you to use both hands."
	w_class = WEIGHT_CLASS_HUGE
	cell_type = /obj/item/stock_parts/cell/upgraded/plus
	icon_state = "phaserrifle"
	weapon_weight = WEAPON_HEAVY
	item_state = "phaserrifle"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/phaserstun, /obj/item/ammo_casing/energy/laser/phaser_rifle)
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