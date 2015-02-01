/mob/living/silicon/say(var/message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat == 2)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		return say_dead(message)

	//Must be concious to speak
	if (stat)
		return

	message = trim(message)

	if (length(message) >= 2)
		var/prefix = copytext(message, 1, 3)
		if ((prefix == ":b") || (prefix == ":B") || \
			(prefix == "#b") || (prefix == "#B") || \
			(prefix == ".b") || (prefix == ".B") || \
			(prefix == ":�") || (prefix == ":�") || \
			(prefix == "#�") || (prefix == "#�") || \
			(prefix == ".�") || (prefix == ".�"))
			if(istype(src, /mob/living/silicon/pai))
				return ..(message, "R")
			message = copytext(message, 3)
			message = copytext(sanitize(message), 1, MAX_MESSAGE_LEN)
			robot_talk(message)
		else if ((prefix == ":h") || (prefix == ":H") || \
				(prefix == "#h") || (prefix == "#H") || \
				(prefix == ".h") || (prefix == ".H") || \
				(prefix == ":�") || (prefix == ":�") || \
				(prefix == "#�") || (prefix == "#�") || \
				(prefix == ".�") || (prefix == ".�"))
			if(isAI(src)&&client)//For patching directly into AI holopads.
				var/mob/living/silicon/ai/U = src
				message = copytext(message, 3)
				message = copytext(sanitize(message), 1, MAX_MESSAGE_LEN)
				U.holopad_talk(message)
			else//Will not allow anyone by an active AI to use this function.
				src << "This function is not available to you."
				return
		else
			return ..(message, "R")
	else
		return ..(message, "R")

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(var/message)

	if (!message)
		return

	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/obj/machinery/hologram/holopad/T = src.current
	if(istype(T) && T.hologram && T.master == src)//If there is a hologram and its master is the user.
		var/message_a = say_quote(message)

		//Human-like, sorta, heard by those who understand humans.
		var/rendered_a = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message_a]</span></span>"

		//Speach distorted, heard by those who do not understand AIs.
		message = stars(message)
		var/message_b = say_quote(message)
		var/rendered_b = "<span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span>"

		src << "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> <span class='message'>[message_a]</span></span></i>"//The AI can "hear" its own message.
		var/list/speech_bubble_recipients = list()
		for(var/mob/M in hearers(T.loc))//The location is the object, default distance.
			if(M.say_understands(src))//If they understand AI speak. Humans and the like will be able to.
				M.show_message(rendered_a, 2)
			else//If they do not.
				M.show_message(rendered_b, 2)
			if(M.client)
				speech_bubble_recipients.Add(M.client)

		//speech bubble
		spawn(0)
			flick_overlay(image('icons/mob/talk.dmi', src, "hR[say_test(message)]",MOB_LAYER+1), speech_bubble_recipients, 30)

		/*Radios "filter out" this conversation channel so we don't need to account for them.
		This is another way of saying that we won't bother dealing with them.*/
	else
		src << "No holopad connected."
	return

/mob/living/proc/robot_talk(var/message)

	if (!message)
		return

	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/desig = "Default Cyborg" //ezmode for taters
	if(istype(src, /mob/living/silicon))
		var/mob/living/silicon/S = src
		desig = trim_left(S.designation + " " + S.job)
	var/message_a = say_quote(message)
	var/rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"

	for (var/mob/living/S in living_mob_list)
		if(S.robot_talk_understand && (S.robot_talk_understand == robot_talk_understand)) // This SHOULD catch everything caught by the one below, but I'm not going to change it.
			if(istype(S , /mob/living/silicon/ai))
				var/renderedAI = "<i><span class='game say'>Robotic Talk, <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[src]'><span class='name'>[name] ([desig])</span></a> <span class='message'>[message_a]</span></span></i>"
				S.show_message(renderedAI, 2)
			else
				S.show_message(rendered, 2)


		else if (S.binarycheck())
			if(istype(S , /mob/living/silicon/ai))
				var/renderedAI = "<i><span class='game say'>Robotic Talk, <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[src]'><span class='name'>[name] ([desig])</span></a> <span class='message'>[message_a]</span></span></i>"
				S.show_message(renderedAI, 2)
			else
				S.show_message(rendered, 2)

	var/list/listening = hearers(1, src)
	listening -= src
	listening += src

	var/list/heard = list()
	for (var/mob/M in listening)
		if(!istype(M, /mob/living/silicon) && !M.robot_talk_understand)
			heard += M

	if (length(heard))
		var/message_b

		message_b = "beep beep beep"
		message_b = say_quote(message_b)
		message_b = "<i>[message_b]</i>"

		rendered = "<i><span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span></i>"

		for (var/mob/M in heard)
			M.show_message(rendered, 2)

	message = say_quote(message)

	rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"

	for (var/mob/M in dead_mob_list)
		if(!istype(M,/mob/new_player) && !(istype(M,/mob/living/carbon/brain)))//No meta-evesdropping
			M.show_message(rendered, 2)