//nutrition
/datum/mood_event/fat
	description = "<span_class='warning'><B>I'm so fat...</B></span>\n" //muh fatshaming
	mood_change = -4

/datum/mood_event/wellfed
	description = "<span_class='nicegreen'>I'm stuffed!</span>\n"
	mood_change = 6

/datum/mood_event/fed
	description = "<span_class='nicegreen'>I have recently had some food.</span>\n"
	mood_change = 3

/datum/mood_event/hungry
	description = "<span_class='warning'>I'm getting a bit hungry.</span>\n"
	mood_change = -8

/datum/mood_event/starving
	description = "<span_class='boldwarning'>I'm starving!</span>\n"
	mood_change = -15

//charge
/datum/mood_event/charged
	description = "<span_class='nicegreen'>I feel the power in my veins!</span>\n"
	mood_change = 6

/datum/mood_event/lowpower
	description = "<span_class='warning'>My power is running low, I should go charge up somewhere.</span>\n"
	mood_change = -7

/datum/mood_event/decharged
	description = "<span_class='boldwarning'>I'm in desperate need of some electricity!</span>\n"
	mood_change = -12

//Disgust
/datum/mood_event/gross
	description = "<span_class='warning'>I saw something gross.</span>\n"
	mood_change = -2

/datum/mood_event/verygross
	description = "<span_class='warning'>I think I'm going to puke...</span>\n"
	mood_change = -5

/datum/mood_event/disgusted
	description = "<span_class='boldwarning'>Oh god that's disgusting...</span>\n"
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = "<span_class='warning'>You smell something horribly decayed inside this room.</span>\n"
	mood_change = -3

/datum/mood_event/disgust/nauseating_stench
	description = "<span_class='warning'>The stench of rotting carcasses is unbearable!</span>\n"
	mood_change = -7

//Hygiene Events
/datum/mood_event/neat
	description = "<span_class='nicegreen'>I'm so clean, I love it.</span>\n"
	mood_change = 3

/datum/mood_event/dirty
	description = "<span_class='warning'>I smell horrid.</span>\n"
	mood_change = -5

/datum/mood_event/happy_neet
	description = "<span_class='nicegreen'>I smell horrid.</span>\n"
	mood_change = 2

//Generic needs events
/datum/mood_event/favorite_food
	description = "<span_class='nicegreen'>I really enjoyed eating that.</span>\n"
	mood_change = 3
	timeout = 2400

/datum/mood_event/gross_food
	description = "<span_class='warning'>I really didn't like that food.</span>\n"
	mood_change = -2
	timeout = 2400

/datum/mood_event/disgusting_food
	description = "<span_class='warning'>That food was disgusting!</span>\n"
	mood_change = -4
	timeout = 2400

/datum/mood_event/nice_shower
	description = "<span_class='nicegreen'>I have recently had a nice shower.</span>\n"
	mood_change = 2
	timeout = 1800
