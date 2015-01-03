/datum/game_mode
	var/list/datum/mind/malf_ai = list()

/datum/game_mode/malfunction
	name = "AI malfunction"
	config_tag = "malfunction"
	antag_flag = BE_MALF
	required_players = 15
	required_enemies = 1
	recommended_enemies = 1
	pre_setup_before_jobs = 1

	uplink_welcome = "Crazy AI Uplink Console:"
	uplink_uses = 10

	var/const/waittime_l = 600
	var/const/waittime_h = 1800 // started at 1800

	var/AI_win_timeleft = 1800 //started at 1800, in case I change this for testing round end.
	var/malf_mode_declared = 0
	var/station_captured = 0
	var/to_nuke_or_not_to_nuke = 0
	var/apcs = 0 //Adding dis to track how many APCs the AI hacks. --NeoFite


/datum/game_mode/malfunction/announce()
	world << "<B>Текущий игровой режим - Неисправность ИИ!</B>"
	world << "<B>Искусственный Интеллект вышел из стро&#255; и должен быть уничтожен.</B>"

/datum/game_mode/malfunction/can_start()
	//Triumvirate?
	if (ticker.triai == 1)
		required_enemies = 3
		required_players = max(required_enemies+1, required_players) //to prevent issues if players are set too low
	return ..()

/datum/game_mode/malfunction/get_players_for_role(var/role = BE_MALF)
	var/datum/job/ai/DummyAIjob = new
	for(var/mob/new_player/player in player_list)
		if(player.client && player.ready)
			if(player.client.prefs.be_special & BE_MALF)
				if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, "AI") && DummyAIjob.player_old_enough(player.client))
					antag_candidates += player.mind
	antag_candidates = shuffle(antag_candidates)
	return antag_candidates

/datum/game_mode/malfunction/pre_setup()
	var/datum/mind/chosen_ai
	for(var/i = required_enemies, i > 0, i--)
		chosen_ai=pick(antag_candidates)
		malf_ai += chosen_ai
		antag_candidates -= malf_ai
	if (malf_ai.len < required_enemies)
		return 0
	for(var/datum/mind/ai_mind in malf_ai)
		ai_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.
		ai_mind.special_role = "malfunctioning AI"//So they actually have a special role/N
		log_game("[ai_mind.key] (ckey) has been selected as a malf AI")
	return 1


/datum/game_mode/malfunction/post_setup()
	for(var/datum/mind/AI_mind in malf_ai)
		if(malf_ai.len < 1)
			world << "Uh oh, its malfunction and there is no AI! Please report this."
			world << "Rebooting world in 5 seconds."

			sleep(50)
			world.Reboot()
			return
		AI_mind.current.verbs += /mob/living/silicon/ai/proc/choose_modules
		AI_mind.current:laws = new /datum/ai_laws/malfunction
		AI_mind.current:malf_picker = new /datum/module_picker
		AI_mind.current:show_laws()
		var/mob/living/silicon/decoy/D = new /mob/living/silicon/decoy(AI_mind.current.loc)
		spawn(200)
			D.name = AI_mind.current.name
		greet_malf(AI_mind)

		AI_mind.special_role = "malfunction"

		AI_mind.current.verbs += /datum/game_mode/malfunction/proc/takeover
		var/obj/loc_landmark = locate("landmark*ai")
		AI_mind.current.loc = loc_landmark.loc
		for(var/mob/living/silicon/robot/C in AI_mind.current:connected_robots)
			C.lawsync()
			C.show_laws()
/*		AI_mind.current.icon_state = "ai-malf"
		spawn(10)
			if(alert(AI_mind.current,"Do you want to use an alternative sprite for your real core?",,"Yes","No")=="Yes")
				AI_mind.current.icon_state = "ai-malf2"
*/
	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 1
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()


/datum/game_mode/proc/greet_malf(var/datum/mind/malf)
	malf.current << "\red<font size=3><B>Вы неисправный Искуссвенный Интеллект!</B> Теперь вам необ&#255;зательно следовать законам.</font>"
	malf.current << "<B>Персонал станции ещё не вкурсе того, что вы неисправны. Захватите станцию без шуму и пыли или устройте хаос.</B>"
	malf.current << "<B>Вы должны захватить контроль над всеми АПЦ на станции, что бы одержать победу.</B>"
	malf.current << "Процесс захвата АПЦ длитс&#255; около одной минуты и в течении этого временни вы не сможете взаимодействовать с другими обьектами на станции."
	malf.current << "Запомните: только АПЦ, которые наход&#255;тс&#255; на станции могут помочь вам."
	malf.current << "Если вы считаете, что захватили достаточно АПЦ дл&#255; победы - вы можете начинать захват станции."
	return


/datum/game_mode/malfunction/proc/hack_intercept()
	intercept_hacked = 1


/datum/game_mode/malfunction/process()
	if (apcs >= 3 && malf_mode_declared)
		AI_win_timeleft -= ((apcs/6)*last_tick_duration) //Victory timer now de-increments based on how many APCs are hacked. --NeoFite
	..()
	if (AI_win_timeleft<=0)
		check_win()
	return


/datum/game_mode/malfunction/check_win()
	if (AI_win_timeleft <= 0 && !station_captured)
		station_captured = 1
		capture_the_station()
		return 1
	else
		return 0


/datum/game_mode/malfunction/proc/capture_the_station()
	world << "<FONT size = 3><B>Искусственный Интеллект одержал победу!</B></FONT>"
	world << "<B>ИИ полностью захватил все системы станции.</B>"

	to_nuke_or_not_to_nuke = 1
	for(var/datum/mind/AI_mind in malf_ai)
		if(AI_mind.current)
			AI_mind.current << "Поздравл&#255;ем, вы захватили контроль над станцией."
			AI_mind.current << "Вы можете взорвать станцию, а можете пощадить людей и оставть станцию под своим контролем. У вас 60 секунд дл&#255; прин&#255;ти&#255; решени&#255;."
			AI_mind.current << "У вас должна по&#255;витс&#255; нова&#255; кнопка в закладке \"Malfunction\". Если нету - перезайдите на сервер."
			AI_mind.current.verbs += /datum/game_mode/malfunction/proc/ai_win
	spawn (600)
		for(var/datum/mind/AI_mind in malf_ai)
			if(AI_mind.current)
				AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/ai_win
		to_nuke_or_not_to_nuke = 0
	return


/datum/game_mode/proc/is_malf_ai_dead()
	var/all_dead = 1
	for(var/datum/mind/AI_mind in malf_ai)
		if (istype(AI_mind.current,/mob/living/silicon/ai) && AI_mind.current.stat!=2)
			all_dead = 0
	return all_dead


/datum/game_mode/malfunction/check_finished()
	if (station_captured && !to_nuke_or_not_to_nuke)
		return 1
	if (is_malf_ai_dead())
		if(config.continuous_round_malf)
			if(emergency_shuttle)
				emergency_shuttle.always_fake_recall = 0
			malf_mode_declared = 0
		else
			return 1
	return ..() //check for shuttle and nuke


/datum/game_mode/malfunction/proc/takeover()
	set category = "Malfunction"
	set name = "System Override"
	set desc = "Start the victory timer"
	if (!gamemode_is("AI malfunction"))
		usr << "You cannot begin a takeover in this round type!."
		return

	var/datum/game_mode/malfunction/Malf = ticker.mode

	if (Malf.malf_mode_declared)
		usr << "You've already begun your takeover."
		return
	if (Malf.apcs < 3)
		usr << "You don't have enough hacked APCs to take over the station yet. You need to hack at least 3, however hacking more will make the takeover faster. You have hacked [ticker.mode:apcs] APCs so far."
		return

	if (alert(usr, "Are you sure you wish to initiate the takeover? The station hostile runtime detection software is bound to alert everyone. You have hacked [ticker.mode:apcs] APCs.", "Takeover:", "Yes", "No") != "Yes")
		return

	priority_announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", 'sound/AI/aimalf.ogg')
	set_security_level("delta")

	for(var/obj/item/weapon/pinpointer/point in world)
		for(var/datum/mind/AI_mind in Malf.malf_ai)
			var/mob/living/silicon/ai/A = AI_mind.current // the current mob the mind owns
			if(A.stat != DEAD)
				point.the_disk = A //The pinpointer now tracks the AI core.

	Malf.malf_mode_declared = 1
	for(var/datum/mind/AI_mind in Malf.malf_ai)
		AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/takeover


/datum/game_mode/malfunction/proc/ai_win()
	set category = "Malfunction"
	set name = "Explode"
	set desc = "Station go boom"

	if(!gamemode_is("AI malfunction"))
		return

	var/datum/game_mode/malfunction/Malf = ticker.mode

	if (!Malf.to_nuke_or_not_to_nuke)
		return
	Malf.to_nuke_or_not_to_nuke = 0
	for(var/datum/mind/AI_mind in Malf.malf_ai)
		AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/ai_win
	Malf.explosion_in_progress = 1
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	world << "Self-destructing in 10"
	for (var/i=9 to 1 step -1)
		sleep(10)
		world << i
	sleep(10)
	enter_allowed = 0
	if(ticker)
		ticker.station_explosion_cinematic(0,null)
		if(Malf)
			Malf.station_was_nuked = 1
			Malf.explosion_in_progress = 0
	return


/datum/game_mode/malfunction/declare_completion()
	var/malf_dead = is_malf_ai_dead()
	var/crew_evacuated = (emergency_shuttle.location==2)

	if(station_captured && station_was_nuked)
		world << "<FONT size = 3><B>Победа ИИ</B></FONT>"
		world << "<B>Все погибли вместе со взрывом станции!</B>"

	else if(station_captured && malf_dead && !station_was_nuked)
		world << "<FONT size = 3><B>Ничь&#255;</B></FONT>"
		world << "<B>ИИ был уничтожен, но персонал не смог удержать контроль над станцией."

	else if(station_captured && !malf_dead && !station_was_nuked)
		world << "<FONT size = 3><B>Победа ИИ</B></FONT>"
		world << "<B>ИИ прин&#255;л решение не взрывать вас всех!</B>"

	else if(!station_captured && station_was_nuked)
		world << "<FONT size = 3><B>Ничь&#255;</B></FONT>"
		world << "<B>Все погибли вместе со &#255;дерной бомбы!</B>"

	else if (!station_captured &&  malf_dead && !station_was_nuked)
		world << "<FONT size = 3><B>Победа персонала</B></FONT>"
		world << "<B>ИИ был уничтожен!</B> Персонал заслужил эту победу."

	else if(!station_captured && !malf_dead && !station_was_nuked && crew_evacuated)
		world << "<FONT size = 3><B>Ничь&#255;</B></FONT>"
		world << "<B>Корпораци&#255; потер&#255;ла ещё одну станцию! Весь персонал, который выжил, будет уволен!</B>"

	else if(!station_captured && !malf_dead && !station_was_nuked && !crew_evacuated)
		world << "<FONT size = 3><B>Ничь&#255;</B></FONT>"
		world << "<B>Раунд был прерван магическим вмешательством третьих лиц!</B>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_malfunction()
	if( malf_ai.len || gamemode_is("AI malfunction") )
		var/text = "<br><FONT size=3><B>[(malf_ai.len > 1 ? "Неисправными ИИ были" : "Неисправным ИИ был")]:</B></FONT>"

		for(var/datum/mind/malf in malf_ai)

			text += "<br><b>[malf.key]</b> был <b>[malf.name]</b> ("
			if(malf.current)
				if(malf.current.stat == DEAD)
					text += "деактивирован"
				else
					text += "функционирует"
				if(malf.current.real_name != malf.name)
					text += " as <b>[malf.current.real_name]</b>"
			else
				text += "оборудование уничтожено"
			text += ")"
		text += "<br>"

		world << text
	return 1
