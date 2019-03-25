/datum/preferences
	var/backstory_reason = "I joined starfleet to find purpose.<br>"
	var/backstory_academy = "At the Academy, I was a very average student. I paid attention in class and turned up when required but that was the limit.<br>"
	var/backstory_experience = "I'm a seasoned officer, I've been on multiple starship tours and am pretty competant.<br>"
	var/backstory_upbringing = "I had an easy childhood and always got what I needed and sometimes, what I wanted.<br>"
	var/backstory_parents = "My parents worked at Starfleet headquarters in secretarial positions, their careers weren't really important.<br>"
	var/backstory_accepted = "I loved my parents and have many fond memories of them.<br>"
	var/backstory_ambition = "Nothing"

/datum/mind
	var/backstory_set = FALSE //Don't CLOG UP MEMORIES with INFINITE COPIES OF BACKSTORY AAAAHHHHH

/datum/asset/simple/jobpreviews
	assets = list(
		"command.png"	= 'DS13/icons/previews/command.png',
		"engsec.png"	= 'DS13/icons/previews/engsec.png',
		"medsci.png"	= 'DS13/icons/previews/medsci.png')

/datum/preferences/proc/create_backstory(var/mob/user)
	var/responses = list("keen", "entitled", "neutral", "lazy", "rebel", "insane")
	var/choice = input(user,"Why did you join starfleet?", "Backstory", null) in responses
	if(!choice)
		return
	switch(choice)
		if("keen")
			backstory_reason = "I joined starfleet to uphold the principles of the federation!<br>"
		if("entitled")
			backstory_reason = "I joined starfleet because I deserve a good job.<br>"
		if("neutral")
			backstory_reason = "I joined starfleet to find purpose.<br>"
		if("lazy")
			backstory_reason = "I joined starfleet because my parents told me to.<br>"
		if("rebel")
			backstory_reason = "I joined starfleet to find somewhere I belong.<br>"
		if("insane")
			backstory_reason = "I joined starfleet to kill hostile aliens.<br>"
	choice = input(user,"What were you like at starfleet academy?", "Backstory", null) in responses
	if(!choice)
		return
	switch(choice)
		if("keen")
			backstory_academy = "At the Academy, I worked hard and received top marks in everything I did. It wasn't easy, but it was worth it. I was put on the fast track to the starfleet command training program.<br>"
		if("entitled")
			backstory_academy = "At the Academy, I was better than everyone else.<br>"
		if("neutral")
			backstory_academy = "At the Academy, I was a very average student. I paid attention in class and turned up when required but that was the limit.<br>"
		if("lazy")
			backstory_academy = "At the Academy, I did the bare minimum required.<br>"
		if("rebel")
			backstory_academy = "At the Academy, I had massive anger issues and was almost thrown out multiple times.<br>"
		if("insane")
			backstory_academy = "At the Academy, they always told me I was unhinged but I showed them when I graduated with honours.<br>"
	var/list/experience = list("First assignment", "Experienced", "Veteran")
	choice = input(user,"How experienced is your character?", "Backstory", null) in experience
	if(!choice)
		return
	switch(choice)
		if("First assignment")
			backstory_experience = "I just got assigned to this department, I'm pretty nervous but can't wait to prove myself<br>"
		if("Experienced")
			backstory_experience = "I'm an experienced officer and have been on multiple starship tours.<br>"
		if("Veteran")
			backstory_experience = "I've served on countless starships, I practically live in space. I can keep my cool in a crisis and am often right.<br>"
	var/list/ancestors = list("Military", "Neutral", "Failures")
	choice = input(user,"What's your family history?", "Backstory", null) in ancestors
	if(!choice)
		return
	switch(choice)
		if("Military")
			backstory_parents = "My family were career military, I come from a long line of distinguished Starfleet officers.<br>"
		if("Neutral")
			backstory_parents = "My family have performed a variety of roles.<br>"
		if("Failures")
			backstory_parents = "My parents were deadbeat layabouts who couldn't provide for me.<br>"
	choice = input(user,"What was your childhood like?", "Backstory", null) in responses
	if(!choice)
		return
	switch(choice)
		if("keen")
			backstory_upbringing = "My childhood wasn't easy, but I learned valuable lessons about hard work and dedication through a strictly regimented lifestyle.<br>"
		if("entitled")
			backstory_upbringing = "I have fond memories of my childhood. Mummy and Daddy always gave me what I wanted because I'm such a great person.<br>"
		if("neutral")
			backstory_upbringing = "I had an easy childhood and always got what I needed and sometimes, what I wanted.<br>"
		if("lazy")
			backstory_upbringing = "I had an easy childhood and always got what I needed and sometimes, what I wanted. I couldn't really be bothered to strive for anything more.<br>"
		if("rebel")
			backstory_upbringing = "I had a terrible childhood, there was never enough food to go round.<br>"
		if("insane")
			backstory_upbringing = "I had an exquisite childhood, I'd always try out new experiments on animals that got too close.<br>"
	var/list/accepted = list("I accepted my upbringing", "I rebelled against my parents", "My parents were completely terrible")
	choice = input(user,"Did you accept your upbringing?", "Backstory", null) in accepted
	if(!choice)
		return
	switch(choice)
		if("I accepted my upbringing")
			backstory_accepted = "I loved my parents and have many fond memories of them.<br>"
		if("I rebelled against my parents")
			backstory_accepted = "I didn't accept my upbringing and got into a lot of trouble as a kid.<br>"
		if("My parents were completely terrible")
			backstory_accepted = "I never forgave my parents for what they put me through.<br>"
	var/ambition = stripped_input(user,"Backstory.","What, if any, are your ambitions?")
	if(!ambition)
		return
	backstory_ambition = "My ambitions are: [ambition]<br>"
	var/output = compile_backstory()
	to_chat(user, "<b>Your backstory:</b> <br><br> [output]")
	SetChoices(user)

/mob/living/verb/looc(message as text)
	set name = "Backstory"
	set desc = "Show your character's backstory"
	set category = "IC"
	if(client && mind)
		var/output = client.prefs.compile_backstory()
		to_chat(src, "<b>Your backstorystory:</b> <br> [output]")

/datum/preferences/proc/compile_backstory()
	return "<span class='notice'>[backstory_reason][backstory_academy][backstory_experience][backstory_parents][backstory_upbringing][backstory_accepted][backstory_ambition]</span>"

/datum/preferences/proc/create_job_description(var/mob/user) //Adapted from CEV-Eris
	var/datum/job/previewJob //For what job will we show a description?
	var/highRankFlag = job_civilian_high | job_medsci_high | job_engsec_high

	if(job_civilian_low & ASSISTANT)
		previewJob = SSjob.GetJob("Assistant")
	else if(highRankFlag)
		var/highDeptFlag
		if(job_civilian_high)
			highDeptFlag = CIVILIAN
		else if(job_medsci_high)
			highDeptFlag = MEDSCI
		else if(job_engsec_high)
			highDeptFlag = ENGSEC

		for(var/datum/job/job in SSjob.occupations)
			if(job.flag == highRankFlag && job.department_flag == highDeptFlag)
				previewJob = job
				break
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/jobpreviews)
	assets.send(user)
	var/preview = "engsec.png"
	switch(previewJob.title) //Find out what preview to show
		if("Chief Medical Officer" || "Medical Doctor" || "Chemist" || "Geneticist" || "Virologist" || "Chief Science Officer" || "Science Officer")
			preview = "medsci.png"
		if("Captain" || "First Officer")
			preview = "command.png"

	var/string = "<h1>[previewJob.title]</h1>"
	string += "<img src=[preview] style='margin: 0px; position: relative;'></img>"
	if(previewJob.supervisors)
		string += "<p>You answer to <b>[previewJob.supervisors]</b></p>"

	string += "<p>[previewJob.description]</p>"
	var/backstory = compile_backstory()
	var/job_desc = "<!DOCTYPE html>\
	<html>\
	<head>\
	<style>\
	div.transbox {\
		margin: 30px;\
		opacity: 1;\
		width:90%;\
		filter: alpha(opacity=100);\
		padding: 12px 20px;\
		box-sizing: border-box;\
		border: 2px solid [previewJob.selection_color];\
		border-radius: 4px;\
		border-style: outset;\
		background-color: #383838;\
		max-height: 200px;\
		overflow-y: auto;\
		align-content: left;\
		scrollbar-face-color:[previewJob.selection_color];\
		scrollbar-arrow-color:[previewJob.selection_color];\
		scrollbar-track-color:[previewJob.selection_color];\
		scrollbar-highlight-color:[previewJob.selection_color];\
		scrollbar-darkshadow-Color:[previewJob.selection_color];\
	}\
	</style>\
	</head>\
	<body>\
	<div class='transbox'>\
		<p><FONT color='#98b0c3'>[string]</font></p>\
		<p><FONT color='#98b0c3'><b> Your backstory: </b> <br>[backstory]</font></p>\
	</div>\
	</body>\
	</html>"
	return job_desc
