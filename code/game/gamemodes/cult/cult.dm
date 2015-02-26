//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/datum/game_mode
	var/list/datum/mind/cult = list()
	var/list/allwords = list("travel","self","see","hell","blood","join","tech","destroy", "other", "hide")
	var/list/grantwords = list("travel", "see", "hell", "tech", "destroy", "other", "hide")
	var/list/cult_objectives = list()


/proc/iscultist(mob/living/M as mob)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.cult)

/proc/is_convertable_to_cult(datum/mind/mind)
	if(!istype(mind))	return 0
	if(istype(mind.current, /mob/living/carbon/human) && (mind.assigned_role in list("Captain", "Chaplain")))	return 0
	if(isloyal(mind.current))
		return 0
	if(gamemode_is("cult"))
		if(mind.current == ticker.mode.sacrifice_target)	return 0
	return 1


/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	antag_flag = BE_CULTIST
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	protected_jobs = list()
	required_players = 15
	required_enemies = 3
	recommended_enemies = 3

	uplink_welcome = "Nar-Sie Uplink Console:"
	uplink_uses = 10

	var/finished = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/startwords = list("blood","join","self","hell")
	var/list/secondwords = list("travel", "see", "tech", "destroy", "other", "hide")

	var/eldergod = 1 //for the summon god objective

	var/acolytes_needed = 5 //for the survive objective
	var/acolytes_survived = 0


/datum/game_mode/cult/announce()
	world << "<B>Текущий игровой режим -  Культ!</B>"
	world << "<B>Часть персонала пытаетс&#255; возродить древний культ. Не дайте им выполнить предначертанное!</B>"


/datum/game_mode/cult/pre_setup()
	if(prob(50))
		cult_objectives += "survive"
		cult_objectives += "sacrifice"
	else
		cult_objectives += "eldergod"
		cult_objectives += "sacrifice"

	if(num_players() >= 30)
		recommended_enemies = 9	// 3+3+3 - d' magic number o' magic numbars mon
		acolytes_needed = 15
	else if(num_players() >= 20)
		recommended_enemies = 6
		acolytes_needed = 10


	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				antag_candidates -= player

	for(var/cultists_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultist = pick(antag_candidates)
		antag_candidates -= cultist
		cult += cultist
		log_game("[cultist.key] (ckey) has been selected as a cultist")

	return (cult.len>=required_enemies)


/datum/game_mode/cult/post_setup()
	modePlayer += cult
	if("sacrifice" in cult_objectives)
		var/list/possible_targets = get_unconvertables()

		if(!possible_targets.len)
			message_admins("Cult Sacrifice: Could not find unconvertable target, checking for convertable target.")
			for(var/mob/living/carbon/human/player in player_list)
				if(player.mind && !(player.mind in cult))
					possible_targets += player.mind

		if(possible_targets.len > 0)
			sacrifice_target = pick(possible_targets)
			if(!sacrifice_target)
				message_admins("Cult Sacrifice: ERROR -  Null target chosen!")
		else
			message_admins("Cult Sacrifice: Could not find unconvertable or convertable target. WELP!")

	for(var/datum/mind/cult_mind in cult)
		equip_cultist(cult_mind.current)
		update_cult_icons_added(cult_mind)
		cult_mind.current << "<span class='info'>Вы член Культа!</span>"
		memorize_cult_objectives(cult_mind)
		cult_mind.special_role = "Cultist"

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()


/datum/game_mode/cult/proc/memorize_cult_objectives(var/datum/mind/cult_mind)
	for(var/obj_count = 1,obj_count <= cult_objectives.len,obj_count++)
		var/explanation
		switch(cult_objectives[obj_count])
			if("survive")
				explanation = "Наше учение должно жить. Сделайте так, чтобы [acolytes_needed] членов экипажа успешно эвакуировались со станции."
			if("sacrifice")
				if(sacrifice_target)
					explanation = "Принесите в жертву [sacrifice_target.name], the [sacrifice_target.assigned_role]. Вам понадобитьс&#255; жервенна&#255; руна (Hell blood join) и три культиста."
				else
					explanation = "Свободное задание."
			if("eldergod")
				explanation = "Призовите Нар-Си использу&#255; специальную руну призыва (Hell join self). Это сработает в случае, если дев&#255;ть членов культа будут сто&#255;ть вокруг."
		cult_mind.current << "<B>Задание #[obj_count]</B>: [explanation]"
		cult_mind.memory += "<B>Задание #[obj_count]</B>: [explanation]<BR>"
	cult_mind.current << "Геометр Крови дарует вам знание, которое поможет вам жертвовать неверующими. (Hell Blood Join)"
	cult_mind.memory += "Геометр Крови дарует вам знание, которое поможет вам жертвовать неверующими. (Hell Blood Join)<BR>"
	for(var/startingword in startwords)
		grant_runeword(cult_mind.current,startingword)

/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			mob << "Медитаци&#255; позволила вам отбросить вашу клоунскую натуру. Теперь вы можете использовать оружие без вреда себе."
			mob.remove_organic_effect(/datum/organic_effect/clumsy)
		if (mob.mind.assigned_role ==  "Mime")
			mob << "Геометр Крови даровал вам голос в обмен на служение, и теперь вы можете разговаривать."
			mob.mind.miming = !mob.mind.miming


	var/obj/item/weapon/paper/talisman/supply/T = new(mob)
	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if (!where)
		mob << "К сожалению вы не можете получить ваш талисман. Это очень плохо, вы должны обратитьс&#255; к администрации, чтобы получить его."
	else
		mob << "Ваш талисман находитс&#255; в [where], он поможет распространить культ по всей станции. Используйте его разумно."
		mob.update_icons()
		return 1

/datum/game_mode/proc/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	if(!wordtravel)
		runerandom()
	if (!word)
		word=pick(grantwords)
	var/wordexp
	switch(word)
		if("travel")
			wordexp = "[wordtravel] is travel..."
		if("blood")
			wordexp = "[wordblood] is blood..."
		if("join")
			wordexp = "[wordjoin] is join..."
		if("hell")
			wordexp = "[wordhell] is Hell..."
		if("self")
			wordexp = "[wordself] is self..."
		if("see")
			wordexp = "[wordsee] is see..."
		if("tech")
			wordexp = "[wordtech] is technology..."
		if("destroy")
			wordexp = "[worddestr] is destroy..."
		if("other")
			wordexp = "[wordother] is other..."
		if("hide")
			wordexp = "[wordhide] is hide..."
	cult_mob << "<span class='warning'>[pick("You remember something from the dark teachings of your master","You hear a dark voice on the wind","Black blood oozes into your vision and forms into symbols","You catch a brief glimmer of the otherside")]... [wordexp]</span>"
	cult_mob.mind.store_memory("<B>Вы помните, что...</B> [wordexp]", 0, 0)
	cult_mob.mind.cult_words += word
	if(cult_mob.mind.cult_words.len == allwords.len)
		cult_mob << "\green Вы чувствуете прикосновение Нар-Си, и теперь вам доступны все секреты его мира."


/datum/game_mode/proc/add_cultist(datum/mind/cult_mind) //BASE
	if (!istype(cult_mind))
		return 0
	if(!(cult_mind in cult) && is_convertable_to_cult(cult_mind))
		cult += cult_mind
		cult_mind.current.cult_add_comm()
		update_cult_icons_added(cult_mind)
		cult_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been converted to the cult!</font>"
		return 1


/datum/game_mode/cult/add_cultist(datum/mind/cult_mind) //INHERIT
	if (!..(cult_mind))
		return
	memorize_cult_objectives(cult_mind)


/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = 1)
	if(cult_mind in cult)
		cult -= cult_mind
		cult_mind.current.verbs -= /mob/living/proc/cult_innate_comm
		cult_mind.current << "<span class='warning'><FONT size = 3><B>&#255;рка&#255; бела&#255; вспышка проскользнула в глазах, забира&#255; с собой все воспоминани&#255; о служении тёмному богу и его приспешников.</B></FONT></span>"
		cult_mind.memory = ""
		cult_mind.cult_words = initial(cult_mind.cult_words)
		update_cult_icons_removed(cult_mind)
		cult_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has renounced the cult!</font>"
		if(show_message)
			for(var/mob/M in viewers(cult_mind.current))
				M << "<FONT size = 3>[cult_mind.current] потер&#255;л свою веру в культ. Теперь он не один из нас.</FONT>"

/datum/game_mode/proc/update_all_cult_icons()
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/image/I in cultist.current.client.images)
						if(I.icon_state == "cult")
							del(I)

		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/datum/mind/cultist_1 in cult)
						if(cultist_1.current)
							var/I = image('icons/mob/mob.dmi', loc = cultist_1.current, icon_state = "cult")
							cultist.current.client.images += I


/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					var/I = image('icons/mob/mob.dmi', loc = cult_mind.current, icon_state = "cult")
					cultist.current.client.images += I
			if (cult_mind)
				if(cult_mind.current)
					if(cult_mind.current.client)
						var/image/J = image('icons/mob/mob.dmi', loc = cultist.current, icon_state = "cult")
						cult_mind.current.client.images += J


/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/image/I in cultist.current.client.images)
						if(I.icon_state == "cult" && I.loc == cult_mind.current)
							del(I)

		if(cult_mind.current)
			if(cult_mind.current.client)
				for(var/image/I in cult_mind.current.client.images)
					if(I.icon_state == "cult")
						del(I)


/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(player.mind && !is_convertable_to_cult(player.mind))
			ucs += player.mind
	return ucs


/datum/game_mode/cult/proc/check_cult_victory()
	var/cult_fail = 0
	if(cult_objectives.Find("survive"))
		cult_fail += check_survive() //the proc returns 1 if there are not enough cultists on the shuttle, 0 otherwise
	if(cult_objectives.Find("eldergod"))
		cult_fail += eldergod //1 by default, 0 if the elder god has been summoned at least once
	if(cult_objectives.Find("sacrifice"))
		if(sacrifice_target && !sacrificed.Find(sacrifice_target)) //if the target has been sacrificed, ignore this step. otherwise, add 1 to cult_fail
			cult_fail++

	return cult_fail //if any objectives aren't met, failure


/datum/game_mode/cult/proc/check_survive()
	acolytes_survived = 0
	for(var/datum/mind/cult_mind in cult)
		if (cult_mind.current && cult_mind.current.stat!=2)
			var/area/A = get_area(cult_mind.current )
			if ( is_type_in_list(A, centcom_areas))
				acolytes_survived++
	if(acolytes_survived>=acolytes_needed)
		return 0
	else
		return 1


/datum/game_mode/cult/declare_completion()

	if(!check_cult_victory())
		world << "<span class='warning'><FONT size = 3><B> Победа культистов! Они смогли выполнить все поручени&#255; тёмного господина.</B></FONT></span>"
	else
		world << "<span class='warning'><FONT size = 3><B> Персонал станции остановил культ! </B></FONT></span>"

	var/text = "<b>Культистов выжило:</b> [acolytes_survived]"

	if(cult_objectives.len)
		text += "<br><b>Задани&#255; культистов:</b>"
		for(var/obj_count=1, obj_count <= cult_objectives.len, obj_count++)
			var/explanation
			switch(cult_objectives[obj_count])
				if("survive")
					if(!check_survive())
						explanation = "Сделайте так, чтобы [acolytes_needed] членов экипажа успешно эвакуировались со станции. <font color='green'><B>Успех!</B></font>"
					else
						explanation = "Сделайте так, чтобы [acolytes_needed] членов экипажа успешно эвакуировались со станции. <font color='red'>Провал.</font>"
				if("sacrifice")
					if(sacrifice_target)
						if(sacrifice_target in sacrificed)
							explanation = "Принесите в жертву [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='green'><B>Успех!</B></font>"
						else if(sacrifice_target && sacrifice_target.current)
							explanation = "Принесите в жертву [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='red'>Провал.</font>"
						else
							explanation = "Принесите в жертву [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='red'>Провал (Тело было уничтожено).</font>"
				if("eldergod")
					if(!eldergod)
						explanation = "Призвать Нар-Си. <font color='green'><B>Успех!</B></font>"
					else
						explanation = "Призвать Нар-Си. <font color='red'>Провал.</font>"
			text += "<br><B>Задание #[obj_count]</B>: [explanation]"

	world << text
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_cult()
	if( cult.len || (ticker && istype(ticker.mode,/datum/game_mode/cult)) )
		var/text = "<br><font size=3><b>Культистами были:</b></font>"
		for(var/datum/mind/cultist in cult)

			text += "<br><b>[cultist.key]</b> был <b>[cultist.name]</b> ("
			if(cultist.current)
				if(cultist.current.stat == DEAD)
					text += "мёртв"
				else
					text += "выжил"
				if(cultist.current.real_name != cultist.name)
					text += " как <b>[cultist.current.real_name]</b>"
			else
				text += "тело уничтожено"
			text += ")"
		text += "<br>"

		world << text
