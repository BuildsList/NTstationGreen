// To add a rev to the list of revolutionaries, make sure it's rev (with if(game_is_rev_mode(ticker.mode)),
// then typecast the game mode to rev: var/datum/game_mode/revolution/Rev = ticker.mode
// then call Rev.add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call Rev.remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the rev icons start going wrong for some reason, ticker.mode:update_all_rev_icons() can be called to correct them.
// If the game somtimes isn't registering a win properly, then Rev.check_win() isn't being called somewhere.

/datum/game_mode
	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	antag_flag = BE_REV
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 3


	uplink_welcome = "Revolutionary Uplink Console:"
	uplink_uses = 10

	var/finished = 0
	var/checkwin_counter = 0
	var/const/max_headrevs = 3
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	world << "<B>Текущий игровой режим - Революци&#255;!</B>"
	world << "<B>Кто-то из члена персонала решил свергнуть глав! Ло&#255;льные члены персонала должны защитить глав любой ценой. "//<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>"


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/head_check = 0
	for(var/mob/new_player/player in player_list)
		if(player.mind.assigned_role in command_positions)
			head_check = 1
			break

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				antag_candidates -= player

	for (var/i=1 to max_headrevs)
		if (antag_candidates.len==0)
			break
		var/datum/mind/lenin = pick(antag_candidates)
		antag_candidates -= lenin
		head_revolutionaries += lenin
		log_game("[lenin.key] (ckey) has been selected as a head rev")

	if((head_revolutionaries.len < required_enemies)||(!head_check))
		return 0

	return 1


/datum/game_mode/revolution/post_setup()
	var/list/heads = get_living_heads()

	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/mutiny/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Убить [head_mind.name], [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj

	//	equip_traitor(rev_mind.current, 1) //changing how revs get assigned their uplink so they can get PDA uplinks. --NEO
	//	Removing revolutionary uplinks.	-Pete
		equip_revolutionary(rev_mind.current)
		update_rev_icons_added(rev_mind)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revolutionary(rev_mind)
	modePlayer += head_revolutionaries
	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 1
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()


/datum/game_mode/revolution/process()
	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0


/datum/game_mode/proc/forge_revolutionary_objectives(var/datum/mind/rev_mind)
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/mutiny/rev_obj = new
		rev_obj.owner = rev_mind
		rev_obj.target = head_mind
		rev_obj.explanation_text = "Убить [head_mind.name], [head_mind.assigned_role]."
		rev_mind.objectives += rev_obj

/datum/game_mode/proc/greet_revolutionary(var/datum/mind/rev_mind, var/you_are=1)
	var/obj_count = 1
	if (you_are)
		rev_mind.current << "\red <FONT size = 3><B>Вы &#255;вл&#255;етесь одним из глав революционного движени&#255;!</B></FONT>"
	for(var/datum/objective/objective in rev_mind.objectives)
		rev_mind.current << "<B>Задание #[obj_count]</B>: [objective.explanation_text]"
		rev_mind.special_role = "Head Revolutionary"
		obj_count++

/////////////////////////////////////////////////////////////////////////////////
//This are equips the rev heads with their gear, and makes the clown not clumsy//
/////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_revolutionary(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			mob << "Професси&#255; клоуна было лишь прикрытие, чтобы проникнуть на станцию. Теперь мы можете не притвор&#255;тс&#255; и пользоватьс&#255; оружием нормально."
			mob.remove_organic_effect(/datum/organic_effect/clumsy)


	var/obj/item/device/flash/T = new(mob)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if (!where)
		mob << "Синдикат не смог снабдить вас флешкой."
	else
		mob << "Флешка находитьс&#255; в [where]. Она поможет вам в продвижени&#255; революции в массы."
		mob.update_icons()
		return 1

//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/revolution/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/revolution/check_finished()
	if(config.continuous_round_rev)
		if(finished != 0)
			if(emergency_shuttle)
				emergency_shuttle.always_fake_recall = 0
		return ..()
	if(finished != 0)
		return 1
	else
		return 0

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind)
	if(rev_mind.assigned_role in command_positions)
		return 0
	var/mob/living/carbon/human/H = rev_mind.current//Check to see if the potential rev is implanted
	if(isloyal(H))
		return 0
	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries))
		return 0
	revolutionaries += rev_mind
	rev_mind.current << "\red <FONT size = 3> Вы теперь революционер! Продвигайте свою идею в массы. Не вредите тем, кто с вами по одну сторону барикад. Ваши товарищи будут отмечены красной буквой \"R\" над головой, а ваши лидеры будут отмечены синей буквой \"R\" над головой. Помогите им свергнуть глав и сделайте вашу революцию успешной!</FONT>"
	rev_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been converted to the revolution!</font>"
	rev_mind.special_role = "Revolutionary"
	update_rev_icons_added(rev_mind)
	return 1
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind , beingborged)
	if(rev_mind in revolutionaries)
		revolutionaries -= rev_mind
		rev_mind.special_role = null
		rev_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has renounced the revolution!</font>"

		if(beingborged)
			rev_mind.current << "\red <FONT size = 3><B>Программное обеспечение уничтожило последстви&#255; нейронного перепрограммировани&#255; и вы забыли всё, чтобыло после вспышки.</B></FONT>"

		else
			rev_mind.current << "\red <FONT size = 3><B>Вам промыли мозги! Вы больше не верите в идеалы революции! Вы забыли всё, чтобыло после вспышки... в голове только им&#255; того, кто ослепил вас...</B></FONT>"

		update_rev_icons_removed(rev_mind)
		for(var/mob/living/M in view(rev_mind.current))
			if(beingborged)
				M << "Програмное обеспечение полностью очистило мозг после его использовани&#255;."

			else
				M << "[rev_mind.current] кажетс&#255; вспомнил то, кем он &#255;вл&#255;лс&#255; на самом деле!"


/////////////////////////////////////////////////////////////////////////////////////////////////
//Keeps track of players having the correct icons////////////////////////////////////////////////
//CURRENTLY CONTAINS BUGS:///////////////////////////////////////////////////////////////////////
//-PLAYERS THAT HAVE BEEN REVS FOR AWHILE OBTAIN THE BLUE ICON WHILE STILL NOT BEING A REV HEAD//
// -Possibly caused by cloning of a standard rev/////////////////////////////////////////////////
//-UNCONFIRMED: DECONVERTED REVS NOT LOSING THEIR ICON PROPERLY//////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/update_all_rev_icons()
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							del(I)

		for(var/datum/mind/rev_mind in revolutionaries)
			if(rev_mind.current)
				if(rev_mind.current.client)
					for(var/image/I in rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							del(I)

		for(var/datum/mind/head_rev in head_revolutionaries)
			if(head_rev.current)
				if(head_rev.current.client)
					for(var/datum/mind/rev in revolutionaries)
						if(rev.current)
							var/I = image('icons/mob/mob.dmi', loc = rev.current, icon_state = "rev")
							head_rev.current.client.images += I
					for(var/datum/mind/head_rev_1 in head_revolutionaries)
						if(head_rev_1.current)
							var/I = image('icons/mob/mob.dmi', loc = head_rev_1.current, icon_state = "rev_head")
							head_rev.current.client.images += I

		for(var/datum/mind/rev in revolutionaries)
			if(rev.current)
				if(rev.current.client)
					for(var/datum/mind/head_rev in head_revolutionaries)
						if(head_rev.current)
							var/I = image('icons/mob/mob.dmi', loc = head_rev.current, icon_state = "rev_head")
							rev.current.client.images += I
					for(var/datum/mind/rev_1 in revolutionaries)
						if(rev_1.current)
							var/I = image('icons/mob/mob.dmi', loc = rev_1.current, icon_state = "rev")
							rev.current.client.images += I

////////////////////////////////////////////////////
//Keeps track of converted revs icons///////////////
//Refer to above bugs. They may apply here as well//
////////////////////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_added(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					var/I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev")
					head_rev_mind.current.client.images += I
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = head_rev_mind.current, icon_state = "rev_head")
					rev_mind.current.client.images += J

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					var/I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev")
					rev_mind_1.current.client.images += I
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = rev_mind_1.current, icon_state = "rev")
					rev_mind.current.client.images += J

///////////////////////////////////
//Keeps track of deconverted revs//
///////////////////////////////////
/datum/game_mode/proc/update_rev_icons_removed(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if((I.icon_state == "rev" || I.icon_state == "rev_head") && I.loc == rev_mind.current)
							del(I)

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					for(var/image/I in rev_mind_1.current.client.images)
						if((I.icon_state == "rev" || I.icon_state == "rev_head") && I.loc == rev_mind.current)
							del(I)

		if(rev_mind.current)
			if(rev_mind.current.client)
				for(var/image/I in rev_mind.current.client.images)
					if(I.icon_state == "rev" || I.icon_state == "rev_head")
						del(I)

//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/mutiny/objective in rev_mind.objectives)
			if(!(objective.check_completion()))
				return 0

		return 1

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/turf/T = get_turf(rev_mind.current)
		if((rev_mind) && (rev_mind.current) && (rev_mind.current.stat != 2) && rev_mind.current.client && T && (T.z == 1))
			if(ishuman(rev_mind.current))
				return 0
	return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/declare_completion()
	if(finished == 1)
		world << "\red <FONT size = 3><B> Ло&#255;листы были убиты или покинули станцию. Победа революции!</B></FONT>"
	else if(finished == 2)
		world << "\red <FONT size = 3><B> Ло&#255;листы смогли остановить революцию!</B></FONT>"
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_revolution()
	var/list/targets = list()

	if(head_revolutionaries.len || gamemode_is("revolution"))
		var/text = "<br><font size=3><b>Главами революции были:</b></font>"

		for(var/datum/mind/headrev in head_revolutionaries)
			text += "<br><b>[headrev.key]</b> был <b>[headrev.name]</b> ("
			if(headrev.current)
				if(headrev.current.stat == DEAD)
					text += "мёртв"
				else if(headrev.current.z != 1)
					text += "покинул станцию"
				else
					text += "выжил во врем&#255; революции"
				if(headrev.current.real_name != headrev.name)
					text += " как <b>[headrev.current.real_name]</b>"
			else
				text += "тело уничтожено"
			text += ")"

			for(var/datum/objective/mutiny/objective in headrev.objectives)
				targets |= objective.target
		text += "<br>"

		world << text

	if(revolutionaries.len || gamemode_is("revolution"))
		var/text = "<br><font size=3><b>Революционерами были:</b></font>"

		for(var/datum/mind/rev in revolutionaries)
			text += "<br><b>[rev.key]</b> был <b>[rev.name]</b> ("
			if(rev.current)
				if(rev.current.stat == DEAD)
					text += "мёртв"
				else if(rev.current.z != 1)
					text += "покинул станцию"
				else
					text += "выжил во врем&#255; революции"
				if(rev.current.real_name != rev.name)
					text += " как <b>[rev.current.real_name]</b>"
			else
				text += "тело уничтожено"
			text += ")"
		text += "<br>"

		world << text


	if( head_revolutionaries.len || revolutionaries.len || gamemode_is("revolution") )
		var/text = "<br><font size=3><b>Цел&#255;ми революции были:</b></font>"

		var/list/heads = get_all_heads()
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			if(target)
				text += "<font color='red'>"
			text += "<br><b>[head.key]</b> был <b>[head.name]</b> ("
			if(head.current)
				if(head.current.stat == DEAD)
					text += "мёртв"
				else if(head.current.z != 1)
					text += "улетел  со станции"
				else
					text += "выжил во врем&#255; революции"
				if(head.current.real_name != head.name)
					text += " как <b>[head.current.real_name]</b>"
			else
				text += "тело уничтожено"
			text += ")"
			if(target)
				text += "</font>"
		text += "<br>"

		world << text

/proc/is_convertable_to_rev(datum/mind/mind)
	return istype(mind) && \
		istype(mind.current, /mob/living/carbon/human) && \
		!(mind.assigned_role in command_positions) && \
		!(mind.assigned_role in list("Security Officer", "Detective", "Warden"))
