var/global/datum/controller/gameticker/ticker
var/round_start_time = 0

#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4

/datum/controller/gameticker
	var/const/restart_timeout = 600
	var/current_state = GAME_STATE_PREGAME

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/login_music			// music played in pregame lobby

	var/list/datum/mind/minds = list()//The people in the game. Used for objective tracking.

	var/list/syndicate_coalition = list() // list of traitor-compatible factions
	var/list/factions = list()			  // list of all factions
	var/list/availablefactions = list()	  // list of factions with openings

	var/pregame_timeleft = 0

	var/delay_end = 0	//if set to nonzero, the round will not restart on it's own

	var/triai = 0//Global holder for Triumvirate

/datum/controller/gameticker/proc/pregame()

	login_music = pickweight(list('sound/ambience/magicfly.ogg' = 20,'sound/ambience/rocketman.ogg' = 20, 'sound/ambience/stayinalive.ogg' = 20, 'sound/ambience/dare.ogg' = 20, 'sound/ambience/title2.ogg' = 5, 'sound/ambience/title1.ogg' = 5, 'sound/ambience/clown.ogg' = 5)) // choose title music!
	if(events.holiday == "April Fool's Day")
		login_music = 'sound/ambience/clown.ogg'
	for(var/client/C in clients)
		C.playtitlemusic()

	do
		if(config)
			pregame_timeleft = config.lobby_countdown
		else
			ERROR("configuration was null when retrieving the lobby_countdown value.")
			pregame_timeleft = 120
		world << "<B><FONT color='blue'>����� ���������� � �����!</FONT></B>"
		world << "��������� ������ ��������� � ������������� � ������ ����. ����� �������&#255; ����� [pregame_timeleft] ������"
		while(current_state == GAME_STATE_PREGAME)
			sleep(10)
			if(going)
				pregame_timeleft--

			if(pregame_timeleft <= 0)
				current_state = GAME_STATE_SETTING_UP
	while (!setup())

/datum/controller/gameticker/proc/setup()
	//Create and announce mode
	if(master_mode=="secret")
		src.hide_mode = 1
	var/list/datum/game_mode/runnable_modes
	if((master_mode=="random") || (master_mode=="secret"))
		if((master_mode=="secret") && (secret_force_mode != "secret"))
			var/datum/game_mode/smode = config.pick_mode(secret_force_mode)
			if (!smode.can_start())
				message_admins("<span class='info'>Unable to force secret [secret_force_mode]. [smode.required_players] players and [smode.required_enemies] eligible antagonists needed.</span>", 1)
			else
				src.mode = smode

		if(!src.mode)
			runnable_modes = config.get_runnable_modes()
			if (runnable_modes.len==0)
				current_state = GAME_STATE_PREGAME
				world << "<B>���������� ������� ����������� �����.</B> �����������&#255; � �����."
				return 0
			src.mode = pickweight(runnable_modes)

	else
		src.mode = config.pick_mode(master_mode)
		if (!src.mode.can_start())
			world << "<B>���������� ������ [mode.name].</B> ������������ �������, ��������&#255; [mode.required_players] ������� �� ������� [mode.required_enemies] ����� ���� ���&#255;��. �����������&#255; � �����."
			del(mode)
			current_state = GAME_STATE_PREGAME
			job_master.ResetOccupations()
			return 0

	//Configure mode and assign player to special mode stuff
	var/can_continue = 0
	if (src.mode.pre_setup_before_jobs)	can_continue = src.mode.pre_setup()
	job_master.DivideOccupations() 				//Distribute jobs
	if (!src.mode.pre_setup_before_jobs)	can_continue = src.mode.pre_setup()

	if(!Debug2)
		if(!can_continue)
			del(mode)
			current_state = GAME_STATE_PREGAME
			world << "<B>������ � ������ [master_mode].</B> �����������&#255; � �����."
			job_master.ResetOccupations()
			return 0
	else
		world << "<span class='notice'>DEBUG: Bypassing prestart checks..."

	if(hide_mode)
		var/list/modes = new
		for (var/datum/game_mode/M in runnable_modes)
			modes+=M.name
		modes = sortList(modes)
		world << "<B>������� ������� ����� - ������!</B>"
		world << "<B>��������� ������:</B> [english_list(modes)]"
	else
		src.mode.announce()

	round_start_time = world.time

	supply_shuttle.process() 		//Start the supply shuttle regenerating points
	master_controller.process()		//Start master_controller.process()
	lighting_controller.process()	//Start processing DynamicAreaLighting updates

	sleep(10)

	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	data_core.manifest()
	current_state = GAME_STATE_PLAYING

	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.post_setup()
		//Cleanup some stuff
		for(var/obj/effect/landmark/start/S in landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if (S.name != "AI")
				qdel(S)
		world << "<FONT color='blue'><B>����� � ������ ����!</B></FONT>"
		world << sound('sound/AI/welcome.ogg') // Skie
		//Holiday Round-start stuff	~Carn
		if(events.holiday)
			world << "<font color='blue'>�...</font>"
			world << "<h4>Happy [events.holiday] Everybody!</h4>"

	auto_toggle_ooc(0) // Turn it off
	return 1

/datum/controller/gameticker
	//station_explosion used to be a variable for every mob's hud. Which was a waste!
	//Now we have a general cinematic centrally held within the gameticker....far more efficient!
	var/obj/screen/cinematic = null

	//Plus it provides an easy way to make cinematics for other events. Just use this as a template
	proc/station_explosion_cinematic(var/station_missed=0, var/override = null)
		if( cinematic )	return	//already a cinematic in progress!
		auto_toggle_ooc(1) // Turn it on
		//initialise our cinematic screen object
		cinematic = new(src)
		cinematic.icon = 'icons/effects/station_explosion.dmi'
		cinematic.icon_state = "station_intact"
		cinematic.layer = 20
		cinematic.mouse_opacity = 0
		cinematic.screen_loc = "1,0"

		var/obj/structure/stool/bed/temp_buckle = new(src)
		if(station_missed)
			for(var/mob/M in mob_list)
				M.buckled = temp_buckle				//buckles the mob so it can't do anything
				if(M.client)
					M.client.screen += cinematic	//show every client the cinematic
		else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
			for(var/mob/M in mob_list)
				M.buckled = temp_buckle
				if(M.client)
					M.client.screen += cinematic
				if(M.stat != DEAD)
					var/turf/T = get_turf(M)
					if(T && T.z==1 && !istype(M.loc, /obj/structure/closet/secure_closet/freezer))
						M.death(0) //no mercy

		//Now animate the cinematic
		switch(station_missed)
			if(1)	//nuke was nearby but (mostly) missed
				if( mode && !override )
					override = mode.name
				switch( override )
					if("nuclear emergency") //Nuke wasn't on station when it blew up
						flick("intro_nuke",cinematic)
						sleep(35)
						world << sound('sound/effects/explosionfar.ogg')
						flick("station_intact_fade_red",cinematic)
						cinematic.icon_state = "summary_nukefail"
					else
						flick("intro_nuke",cinematic)
						sleep(35)
						world << sound('sound/effects/explosionfar.ogg')
						//flick("end",cinematic)


			if(2)	//nuke was nowhere nearby	//TODO: a really distant explosion animation
				sleep(50)
				world << sound('sound/effects/explosionfar.ogg')


			else	//station was destroyed
				if( mode && !override )
					override = mode.name
				switch( override )
					if("nuclear emergency") //Nuke Ops successfully bombed the station
						flick("intro_nuke",cinematic)
						sleep(35)
						flick("station_explode_fade_red",cinematic)
						world << sound('sound/effects/explosionfar.ogg')
						cinematic.icon_state = "summary_nukewin"
					if("AI malfunction") //Malf (screen,explosion,summary)
						flick("intro_malf",cinematic)
						sleep(76)
						flick("station_explode_fade_red",cinematic)
						world << sound('sound/effects/explosionfar.ogg')
						cinematic.icon_state = "summary_malf"
					if("blob") //Station nuked (nuke,explosion,summary)
						flick("intro_nuke",cinematic)
						sleep(35)
						flick("station_explode_fade_red",cinematic)
						world << sound('sound/effects/explosionfar.ogg')
						cinematic.icon_state = "summary_selfdes"
					else //Station nuked (nuke,explosion,summary)
						flick("intro_nuke",cinematic)
						sleep(35)
						flick("station_explode_fade_red", cinematic)
						world << sound('sound/effects/explosionfar.ogg')
						cinematic.icon_state = "summary_selfdes"
		//If its actually the end of the round, wait for it to end.
		//Otherwise if its a verb it will continue on afterwards.
		sleep(300)

		if(cinematic)	qdel(cinematic)		//end the cinematic
		if(temp_buckle)	qdel(temp_buckle)	//release everybody
		return


	proc/create_characters()
		for(var/mob/new_player/player in player_list)
			if(player.ready && player.mind)
				joined_player_list += player.ckey
				if(player.mind.assigned_role=="AI")
					player.close_spawn_windows()
					player.AIize()
				else
					player.create_character()
					qdel(player)
			else
				player.new_player_panel()


	proc/collect_minds()
		for(var/mob/living/player in player_list)
			if(player.mind)
				ticker.minds += player.mind


	proc/equip_characters()
		var/captainless=1
		for(var/mob/living/carbon/human/player in player_list)
			if(player && player.mind && player.mind.assigned_role)
				if(player.mind.assigned_role == "Captain")
					captainless=0
				if(player.mind.assigned_role != "MODE")
					job_master.EquipRank(player, player.mind.assigned_role, 0)
		if(captainless)
			for(var/mob/M in player_list)
				if(!istype(M,/mob/new_player))
					M << "������� ����������� �� �������."


	proc/process()
		if(current_state != GAME_STATE_PLAYING)
			return 0

		mode.process()

		emergency_shuttle.process()

		if(!mode.explosion_in_progress && mode.check_finished())
			current_state = GAME_STATE_FINISHED
			auto_toggle_ooc(1) // Turn it on
			spawn
				declare_completion()

			spawn(50)
				showcredits()
				if (mode.station_was_nuked)
					if(!delay_end)
						world << "<span class='info'><B>������&#255; ���� ����������, ������������ ����� [restart_timeout/10] ������</B></span>"
				else
					if(!delay_end)
						world << "<span class='info'><B>������������ ����� [restart_timeout/10] ������</B></span>"

				if(!delay_end)
					sleep(restart_timeout)
					kick_clients_in_lobby("<span class='warning'>�������� ��������������, ��� &#255; �������� ����� ������.</span>", 1) //second parameter ensures only afk clients are kicked
					world.Reboot()
				else
					world << "<span class='info'><B>������������� ������� ����� ������.</B></span>"

		return 1

	proc/getfactionbyname(var/name)
		for(var/datum/faction/F in factions)
			if(F.name == name)
				return F


/datum/controller/gameticker/proc/declare_completion()

	for (var/mob/living/silicon/ai/aiPlayer in mob_list)
		if (aiPlayer.stat != 2 && aiPlayer.mind)
			world << "<b>������ [aiPlayer.name] (�����: [aiPlayer.mind.key]) � ����� ����� ����:</b>"
			aiPlayer.show_laws(1)
		else if (aiPlayer.mind) //if the dead ai has a mind, use its key instead
			world << "<b>������ [aiPlayer.name] (�����: [aiPlayer.mind.key]) ����� ������������ ����:</b>"
			aiPlayer.show_laws(1)

		if (aiPlayer.connected_robots.len)
			var/robolist = "<b>��&#255;������ ��������� [aiPlayer.real_name] ����:</b> "
			var/vsrobolist = "<span class='warning'><b>�������&#255;�������� ��������� [aiPlayer.real_name] ����:</b> \black</span>"
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				if (is_special_character(robo) && robo.mind)
					vsrobolist += "[robo.name][robo.stat?" (�������������) (�����: [robo.mind.key]), ":" (�����: [robo.mind.key]), "]"
					continue
				robolist += "[robo.name][robo.stat?" (�������������) (�����: [robo.mind.key]), ":" (�����: [robo.mind.key]), "]"
			world << "[robolist]"
			world << "[vsrobolist]"
	for (var/mob/living/silicon/robot/robo in mob_list)
		if (!robo.connected_ai && robo.mind)
			if (robo.stat != 2)
				world << "<b>[robo.name] (�����: [robo.mind.key]) ��� �������&#255;������� ��������. ��� ������:</b>"
			else
				world << "<b>[robo.name] (�����: [robo.mind.key]) �� ���� ������, ������ �������&#255;������� ��������. ��� ������:</b>"

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				robo.laws.show_laws(world)

	mode.declare_completion()//To declare normal completion.

	//calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if (findtext("[handler]","auto_declare_completion_"))
			call(mode, handler)()

	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/mind/Mind in minds)
		var/temprole = Mind.special_role
		if(temprole)							//if they are an antagonist of some sort.
			if(temprole in total_antagonists)	//If the role exists already, add the name to it
				total_antagonists[temprole] += ", [Mind.name]([Mind.key])"
			else
				total_antagonists.Add(temprole) //If the role doesnt exist in the list, create it and add the mob
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])"

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

	return 1
