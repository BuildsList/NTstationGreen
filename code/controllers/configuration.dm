//Configuraton defines //TODO: Move all yes/no switches into bitflags

/datum/configuration
	var/server_name = null				// server name (for world name / status)
	var/lobby_countdown = 180			// In between round countdown.

	var/allow_admin_ooccolor = 0		// Allows admins with relevant permissions to have their own ooc colour
	var/allow_vote_restart = 0 			// allow votes to restart
	var/allow_vote_mode = 0				// allow votes to change mode
	var/allow_vote_transfer = 0			// allow votes to call transfer shuttle
	var/vote_delay = 6000				// minimum time between voting sessions (deciseconds, 10 minute default)
	var/vote_period = 600				// length of voting period (deciseconds, default 1 minute)
	var/vote_autotransfer_initial = 72000 // Length of time before the first autotransfer vote is called
	var/vote_autotransfer_interval = 36000 // length of time before next sequential autotransfer vote
	var/vote_no_default = 0				// vote does not default to nochange/norestart (tbi)
	var/vote_no_dead = 0				// dead people can't vote (tbi)
	var/Ticklag = 0.7
	var/Tickcomp = 1

	var/hostedby = null
	var/respawn = 1
	var/jobs_have_minimal_access = 0	//determines whether jobs use minimal access or expanded access.
	var/sec_start_brig = 0				//makes sec start in brig or dept sec posts

	var/server
	var/banappeals = "http://forum.ss13.ru/index.php?showforum=37"
	var/wikiurl = "http://wiki.animus13.ru"
	var/forumurl = "http://forum.ss13.ru/index.php?act=idx"

	var/forbid_singulo_possession = 0

	var/admin_legacy_system = 0	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system. Config option in config.txt
	var/ban_legacy_system = 0	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt

	//game_options.txt configs
	var/force_random_names = 0
	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode


	var/traitor_scaling_coeff = 6		//how much does the amount of players get divided by to determine traitors
	var/changeling_scaling_coeff = 7	//how much does the amount of players get divided by to determine changelings

	var/continuous_round_rev = 0			// Gamemodes which end instantly will instead keep on going until the round ends by escape shuttle or nuke.
	var/continuous_round_wiz = 0
	var/continuous_round_malf = 0
	var/shuttle_refuel_delay = 12000
	var/mutant_races = 0				//players can choose their mutant race before joining the game

	var/alert_desc_green = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."
	var/alert_desc_blue_upto = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."
	var/alert_desc_blue_downto = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	var/alert_desc_red_upto = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	var/alert_desc_red_downto = "The self-destruct mechanism has been deactivated, there is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."
	var/alert_desc_delta = "The station's self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

	var/health_threshold_crit = 0
	var/health_threshold_dead = -100

	var/revival_pod_plants = 0
	var/revival_cloning = 0
	var/revival_brain_life = -1

	var/rename_cyborg = 0
	var/borg_remembers = 0
	var/ooc_during_round = 0

	//Used for modifying movement speed for mobs.
	//Unversal modifiers
	var/run_speed = 1.2
	var/walk_speed = 4

	//Mob specific modifiers. NOTE: These will affect different mob types in different ways
	var/human_delay = 0
	var/robot_delay = 0
	var/monkey_delay = 0
	var/alien_delay = 0
	var/slime_delay = 0
	var/animal_delay = 0

	var/use_recursive_explosions = 0//Defines whether the server uses recursive or circular explosions.

	var/gateway_delay = 18000 //How long the gateway takes before it activates. Default is half an hour.
	var/ghost_interaction = 0

	var/sandbox_autoclose = 0 // close the sandbox panel after spawning an item, potentially reducing griff

	var/default_laws = 0 //Controls what laws the AI spawns with.

/datum/configuration/New()
	var/list/L = typesof(/datum/game_mode) - /datum/game_mode
	for(var/T in L)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()

		if(M.config_tag)
			if(!(M.config_tag in modes))		// ensure each mode is added only once
				diary << "Adding game mode [M.name] ([M.config_tag]) to configuration."
				modes += M.config_tag
				mode_names[M.config_tag] = M.name
				probabilities[M.config_tag] = M.probability
				if(M.votable)
					votable_modes += M.config_tag
		del(M)
	votable_modes += "secret"

/datum/configuration/proc/load(filename, type = "config") //the type can also be game_options, in which case it uses a different switch. not making it separate to not copypaste code - Urist
	var/list/Lines = file2list(filename)

	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if(pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if(!name)
			continue

		if(type == "config")
			switch(name)
				if("admin_legacy_system")
					config.admin_legacy_system = 1
				if("ban_legacy_system")
					config.ban_legacy_system = 1
				if("lobby_countdown")
					config.lobby_countdown = text2num(value)
				if("allow_admin_ooccolor")
					config.allow_admin_ooccolor = 1
				if("allow_vote_restart")
					config.allow_vote_restart = 1
				if("allow_vote_mode")
					config.allow_vote_mode = 1
				if("allow_vote_transfer")
					config.allow_vote_transfer = 1
				if("no_dead_vote")
					config.vote_no_dead = 1
				if("default_no_vote")
					config.vote_no_default = 1
				if("vote_delay")
					config.vote_delay = text2num(value)
				if("vote_period")
					config.vote_period = text2num(value)
				if("vote_autotransfer_initial")
					config.vote_autotransfer_initial = text2num(value)
				if("vote_autotransfer_interval")
					config.vote_autotransfer_interval = text2num(value)
				if("norespawn")
					config.respawn = 0
				if("servername")
					config.server_name = value
				if("hostedby")
					config.hostedby = value
				if("server")
					config.server = value
				if("banappeals")
					config.banappeals = value
				if("wikiurl")
					config.wikiurl = value
				if("forumurl")
					config.forumurl = value
				if("forbid_singulo_possession")
					forbid_singulo_possession = 1
				if("ticklag")
					Ticklag = text2num(value)
				if("tickcomp")
					Tickcomp = 1
				if("comms_key")
					global.comms_key = value
					if(value != "default_pwd" && length(value) > 6) //It's the default value or less than 6 characters long, warn badmins
						global.comms_allowed = 1
				if("health_threshold_crit")
					config.health_threshold_crit	= text2num(value)
				if("health_threshold_dead")
					config.health_threshold_dead	= text2num(value)
				if("revival_pod_plants")
					config.revival_pod_plants		= 1
				if("borg_remembers")
					config.borg_remembers			= text2num(value)
				if("revival_cloning")
					config.revival_cloning			= 1
				if("revival_brain_life")
					config.revival_brain_life		= text2num(value)
				if("rename_cyborg")
					config.rename_cyborg			= 1
				if("ooc_during_round")
					config.ooc_during_round			= 1
				if("run_delay")
					config.run_speed				= text2num(value)
				if("walk_delay")
					config.walk_speed				= text2num(value)
				if("human_delay")
					config.human_delay				= text2num(value)
				if("robot_delay")
					config.robot_delay				= text2num(value)
				if("monkey_delay")
					config.monkey_delay				= text2num(value)
				if("alien_delay")
					config.alien_delay				= text2num(value)
				if("slime_delay")
					config.slime_delay				= text2num(value)
				if("animal_delay")
					config.animal_delay				= text2num(value)
				if("alert_red_upto")
					config.alert_desc_red_upto		= value
				if("alert_red_downto")
					config.alert_desc_red_downto	= value
				if("alert_blue_downto")
					config.alert_desc_blue_downto	= value
				if("alert_blue_upto")
					config.alert_desc_blue_upto		= value
				if("alert_green")
					config.alert_desc_green			= value
				if("alert_delta")
					config.alert_desc_delta			= value
				if("sec_start_brig")
					config.sec_start_brig			= 1
				if("gateway_delay")
					config.gateway_delay			= text2num(value)
				if("continuous_round_rev")
					config.continuous_round_rev		= 1
				if("continuous_round_wiz")
					config.continuous_round_wiz		= 1
				if("continuous_round_malf")
					config.continuous_round_malf	= 1
				if("shuttle_refuel_delay")
					config.shuttle_refuel_delay     = text2num(value)
				if("ghost_interaction")
					config.ghost_interaction		= 1
				if("traitor_scaling_coeff")
					config.traitor_scaling_coeff	= text2num(value)
				if("changeling_scaling_coeff")
					config.changeling_scaling_coeff	= text2num(value)
				if("probability")
					var/prob_pos = findtext(value, " ")
					var/prob_name = null
					var/prob_value = null

					if(prob_pos)
						prob_name = lowertext(copytext(value, 1, prob_pos))
						prob_value = copytext(value, prob_pos + 1)
						if(prob_name in config.modes)
							config.probabilities[prob_name] = text2num(prob_value)
						else
							diary << "Unknown game mode probability configuration definition: [prob_name]."
					else
						diary << "Incorrect probability configuration definition: [prob_name]  [prob_value]."

				if("jobs_have_minimal_access")
					config.jobs_have_minimal_access	= 1
				if("use_recursive_explosions")
					use_recursive_explosions		= 1
				if("force_random_names")
					config.force_random_names		= 1
				if("sandbox_autoclose")
					config.sandbox_autoclose		= 1
				if("default_laws")
					config.default_laws				= text2num(value)
				if("join_with_mutant_race")
					config.mutant_races				= 1
				else
					diary << "Unknown setting in configuration: '[name]'"

/datum/configuration/proc/loadsql(filename)
	var/list/Lines = file2list(filename)
	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if(pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if(!name)
			continue

		switch(name)
			if("address")
				sqladdress = value
			if("port")
				sqlport = value
			if("database")
				sqlfdbkdb = value
			if("login")
				sqlfdbklogin = value
			if("password")
				sqlfdbkpass = value
			else
				diary << "Unknown setting in configuration: '[name]'"

/datum/configuration/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	for(var/T in (typesof(/datum/game_mode) - /datum/game_mode))
		var/datum/game_mode/M = new T()
		if(M.config_tag && M.config_tag == mode_name)
			return M
		del(M)
	return new /datum/game_mode/extended()

/datum/configuration/proc/get_runnable_modes()
	var/list/datum/game_mode/runnable_modes = new
	for(var/T in (typesof(/datum/game_mode) - /datum/game_mode))
		var/datum/game_mode/M = new T()
		//world << "DEBUG: [T], tag=[M.config_tag], prob=[probabilities[M.config_tag]]"
		if(!(M.config_tag in modes))
			del(M)
			continue
		if(probabilities[M.config_tag]<=0)
			del(M)
			continue
		if(M.can_start())
			runnable_modes[M] = probabilities[M.config_tag]
			//world << "DEBUG: runnable_mode\[[runnable_modes.len]\] = [M.config_tag]"
	return runnable_modes
