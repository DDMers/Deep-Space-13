//Nearsightedness restricts your vision by several tiles.
/datum/mutation/human/nearsight
	name = "Near Sightness"
	desc = "The holder of this mutation has poor eyesight."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span_class='danger'>You can't see very well.</span>"

/datum/mutation/human/nearsight/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.become_nearsighted(GENETIC_MUTATION)

/datum/mutation/human/nearsight/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.cure_nearsighted(GENETIC_MUTATION)


//Blind makes you blind. Who knew?
/datum/mutation/human/blind
	name = "Blindness"
	desc = "Renders the subject completely blind."
	quality = NEGATIVE
	text_gain_indication = "<span_class='danger'>You can't seem to see anything.</span>"

/datum/mutation/human/blind/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.become_blind(GENETIC_MUTATION)

/datum/mutation/human/blind/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.cure_blind(GENETIC_MUTATION)


//X-ray Vision lets you see through walls.
/datum/mutation/human/x_ray
	name = "X Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls." //actual x-ray would mean you'd constantly be blasting rads, wich might be fun for later //hmb
	quality = POSITIVE
	difficulty = 18
	text_gain_indication = "<span_class='notice'>The walls suddenly disappear!</span>"
	time_coeff = 2
	instability = 25

/datum/mutation/human/x_ray/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return

	owner.add_trait(TRAIT_XRAY_VISION, GENETIC_MUTATION)
	owner.update_sight()

/datum/mutation/human/x_ray/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_trait(TRAIT_XRAY_VISION, GENETIC_MUTATION)
	owner.update_sight()


//Laser Eyes lets you shoot lasers from your eyes!
/datum/mutation/human/laser_eyes
	name = "Laser Eyes"
	desc = "Reflects concentrated light back from the eyes."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span_class='notice'>You feel pressure building up behind your eyes.</span>"
	layer_used = FRONT_MUTATIONS_LAYER
	limb_req = BODY_ZONE_HEAD

/datum/mutation/human/laser_eyes/New()
	..()
	visual_indicators |= mutable_appearance('icons/effects/genetics.dmi', "lasereyes", -FRONT_MUTATIONS_LAYER)

/datum/mutation/human/laser_eyes/get_visual_indicator()
	return visual_indicators[1]

/datum/mutation/human/laser_eyes/on_ranged_attack(atom/target, mouseparams)
	if(owner.a_intent == INTENT_HARM)
		owner.LaserEyes(target, mouseparams)
