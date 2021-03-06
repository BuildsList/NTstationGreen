/obj/item/device/assembly/voice
	name = "voice analyzer"
	desc = "A small electronic device able to record a voice sample, and send a signal when that sample is repeated."
	icon_state = "voice"
	m_amt = 500
	g_amt = 50
	origin_tech = "magnets=1"
	var/listening = 0
	var/recorded	//the activation message

	hear_talk(mob/living/M as mob, msg)
		if(listening)
			recorded = msg
			listening = 0
			var/turf/T = get_turf(src)	//otherwise it won't work in hand
			T.visible_message("\icon[src] beeps, \"Activation message is '[recorded]'.\"")
		else
			if(findtext(msg, recorded))
				var/usr_n = M.name
				if (M.client)
					usr_n +="([M.key])"
				else
					usr_n +="(*No Key*)"
				pulse(0, src.name, usr_n)

	activate()
		if(secured)
			if(!holder)
				listening = !listening
				var/turf/T = get_turf(src)
				T.visible_message("\icon[src] beeps, \"[listening ? "Now" : "No longer"] recording input.\"")


	attack_self(mob/user)
		if(!user)	return 0
		activate()
		return 1


	toggle_secure()
		. = ..()
		listening = 0