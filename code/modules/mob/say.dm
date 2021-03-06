/mob/proc/say()
	return

/mob/verb/whisper()
	set name = "Whisper"
	set category = "IC"
	return

/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"

	message = strip_html_properly(sanitize(message))
	usr.say(message)

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	message = trim(strip_html_properly(sanitize(message)))

	if(ishuman(src) || isrobot(src))
		usr.emote("me",1,message)
	else
		usr.emote(message)


/mob/proc/say_dead(var/message)
	var/name = src.real_name
	var/alt_name = ""

	if(mind && mind.name)
		name = "[mind.name]"
	else
		name = real_name
	if(name != real_name)
		alt_name = " (died as [real_name])"

	message = src.say_quote(message,1)
	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name] <span class='message'>[message]</span></span>"

	for(var/mob/M in player_list)
		if(istype(M, /mob/new_player))
			continue
		if(M.client && M.client.holder && (M.client.prefs.toggles & CHAT_DEAD)) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
			M << rendered	//Admins can hear deadchat, if they choose to, no matter if they're blind/deaf or not.
		else if(M.stat == DEAD)
			M.show_message(rendered, 2) //Takes into account blindness and such.
	return

/mob/proc/say_understands(var/mob/other)
	if (src.stat == 2)
		return 1
	else if (istype(other, src.type))
		return 1
	else if(other.universal_speak || src.universal_speak)
		return 1
	return 0

/mob/proc/say_quote(var/text, var/isdeadsay)
	if(!text)
		return "??????, \"...\"";	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code

	var/ending = copytext(text, length(text))
	if (src.stuttering)
		return "????????&#255;, \"[text]\"";
	if(isliving(src))
		var/mob/living/L = src
		if (L.getBrainLoss() >= 60)
			return "????????, \"[text]\"";
	if(ending=="!")
		ending = copytext(text, length(text) - 1)
		if(ending=="!!")
			ending = copytext(text, length(text) - 2)
			if(ending=="!!!")
				text = upperrustext(text);
				return "????, \"<b>[text]</b>\"";
			return "??????, \"<b>[text]</b>\"";
		else if(ending=="?!")
			return "????????, \"[text]\"";
		return "??????????, \"[text]\"";
	else if(ending=="?")
		ending = copytext(text, length(text) - 1)
		if(ending=="!?")
			return "???????, \"[text]\"";
		return "??????????, \"[text]\"";
	if(isdeadsay)
		return "[pick("????","???????&#255;","??????","?????")], \"[text]\"";
	return "???????, \"[text]\"";

/mob/proc/emote(var/act)
	return

/mob/proc/get_ear()
	// returns an atom representing a location on the map from which this
	// mob can hear things

	// should be overloaded for all mobs whose "ear" is separate from their "mob"

	return get_turf(src)
