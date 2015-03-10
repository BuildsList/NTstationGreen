//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/mob/new_player
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

	New()
		tag = "mob_[next_mob_id++]"
		mob_list += src

	proc/new_player_panel()

		var/output = "<center><p><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A></p>"

		if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
			if(!ready)	output += "<p><a href='byond://?src=\ref[src];ready=1'>Declare Ready</A></p>"
			else	output += "<p><b>You are ready</b> <a href='byond://?src=\ref[src];ready=0'>Cancel</A></p>"

		else
			output += "<a href='byond://?src=\ref[src];manifest=1'>Crew Manifest</A><br><br>"
			output += "<p><a href='byond://?src=\ref[src];late_join=1'>Join Game!</A></p>"

		output += "<p><a href='byond://?src=\ref[src];observe=1'>Observe</A></p>"
		output += "</center>"

		var/datum/browser/popup = new(src, "playersetup", "<div align='center'>New Player Options</div>", 210, 240)
		popup.set_window_options("can_close=0")
		popup.set_content(output)
		popup.open(0)
		return

	Stat()
		..()

		statpanel("Lobby")
		if(client.statpanel == "Lobby" && ticker)
			if(ticker.hide_mode)
				stat("Game Mode:", "Secret")
			else
				stat("Game Mode:", "[master_mode]")

			if((ticker.current_state == GAME_STATE_PREGAME) && going)
				stat("Time To Start:", ticker.pregame_timeleft)
			if((ticker.current_state == GAME_STATE_PREGAME) && !going)
				stat("Time To Start:", "DELAYED")

			if(ticker.current_state == GAME_STATE_PREGAME)
				stat("Players: [totalPlayers]", "Players Ready: [totalPlayersReady]")
				totalPlayers = 0
				totalPlayersReady = 0
				for(var/mob/new_player/player in player_list)
					stat("[player.key]", (player.ready)?("(Playing)"):(null))
					totalPlayers++
					if(player.ready)totalPlayersReady++

	Topic(href, href_list[])
		if(src != usr)
			return 0

		if(!client)	return 0

		if(href_list["show_preferences"])
			client.prefs.ShowChoices(src)
			return 1

		if(href_list["ready"])
			ready = text2num(href_list["ready"])

		if(href_list["refresh"])
			src << browse(null, "window=playersetup") //closes the player setup window
			new_player_panel()

		if(href_list["observe"])

			if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
				if(!client)	return 1
				var/mob/dead/observer/observer = new()

				spawning = 1
				src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS cant last forever yo

				observer.started_as_observer = 1
				close_spawn_windows()
				var/obj/O = locate("landmark*Observer-Start")
				src << "<span class='info'>Now teleporting.</span>"
				observer.loc = O.loc
				if(client.prefs.be_random_name)
					client.prefs.real_name = random_name(gender)
				observer.real_name = client.prefs.real_name
				observer.name = observer.real_name
				observer.key = key

				qdel(src)
				return 1

		if(href_list["late_join"])
			if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
				usr << "<span class='warning'>The round is either not ready, or has already finished...</span>"
				return
			LateChoices()

		if(href_list["manifest"])
			ViewManifest()

		if(href_list["SelectedJob"])

			if(!enter_allowed)
				usr << "<span class='info'>There is an administrative lock on entering the game!</span>"
				return

			AttemptLateSpawn(href_list["SelectedJob"])
			return


		if(!ready && href_list["preference"])
			if(client)
				client.prefs.process_link(src, href_list)
		else if(!href_list["late_join"])
			new_player_panel()


	proc/IsJobAvailable(rank)
		var/datum/job/job = job_master.GetJob(rank)
		if(!job)	return 0
		if((job.current_positions >= job.total_positions) && job.total_positions != -1)	return 0
		if(jobban_isbanned(src,rank))	return 0
		if(!job.player_old_enough(src.client))	return 0
		return 1


	proc/AttemptLateSpawn(rank)
		if(!IsJobAvailable(rank))
			src << alert("[rank] is not available. Please try another.")
			return 0

		job_master.AssignRole(src, rank, 1)

		var/mob/living/carbon/human/character = create_character()	//creates the human and transfers vars and mind
		job_master.EquipRank(character, rank, 1)					//equips the human
		character.loc = pick(latejoin)
		character.lastarea = get_area(loc)

		if(character.mind.assigned_role != "Cyborg")
			data_core.manifest_inject(character)
			ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
			AnnounceArrival(character, rank)
		else
			character.Robotize()

		joined_player_list += character.ckey

		if(config.allow_latejoin_antagonists && emergency_shuttle.timeleft() > 300) //Don't make them antags if the station is evacuating
			ticker.mode.make_antag_chance(character)
		qdel(src)

	proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank)
		if (ticker.current_state == GAME_STATE_PLAYING)
			var/ailist[] = list()
			for (var/mob/living/silicon/ai/A in living_mob_list)
				ailist += A
			if (ailist.len)
				var/mob/living/silicon/ai/announcer = pick(ailist)
				if(character.mind)
					if((character.mind.assigned_role != "Cyborg") && (character.mind.special_role != "MODE"))
						announcer.say("[character.real_name] has signed up as [rank].")

	proc/LateChoices()
		var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
		//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
		var/mins = (mills % 36000) / 600
		var/hours = mills / 36000

		var/dat = "<div class='notice'>Round Duration: [round(hours)]h [round(mins)]m</div>"

		if(emergency_shuttle) //In case Nanotrasen decides reposess Centcom's shuttles.
			if(emergency_shuttle.direction == 2) //Shuttle is going to centcom, not recalled
				dat += "<div class='notice red'>The station has been evacuated.</div><br>"
			if(emergency_shuttle.direction == 1 && emergency_shuttle.timeleft() < 300) //Shuttle is past the point of no recall
				dat += "<div class='notice red'>The station is currently undergoing evacuation procedures.</div><br>"

		var/limit = 17
		var/list/splitJobs = list("Chief Engineer")
		var/widthPerColumn = 295
		var/width = widthPerColumn
		dat += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='50%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		dat += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob

		for(var/datum/job/job in job_master.occupations)
			if(job.title in nonhuman_positions)
				continue
			index += 1
			if((index >= limit) || (job.title in splitJobs))
				width += 295
				if((index < limit) && (lastJob != null))
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i = 0, i < (limit - index), i += 1)
						dat += "<tr bgcolor='[lastJob.selection_color]'><td >&nbsp</td></tr>"
				dat += "</table></td><td width='50%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			dat += "<tr bgcolor='[job.selection_color]'><td align='center'>"
			var/rank = job.title
			lastJob = job
			var/rank_full_name = rank
			if(job.total_positions > 1)
				rank_full_name += " ([job.current_positions])"

			if(jobban_isbanned(src, rank))
				dat += "<a class='linkOff'><font color=red>[rank_full_name]</font></a><font color=red><b> \[BANNED\]</b></font></td></tr>"
				continue
			if(!job.player_old_enough(src.client))
				var/available_in_days = job.available_in_days(src.client)
				dat += "<a class='linkOff'><font color=red>[rank_full_name]</font></a><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
				continue
			if(!IsJobAvailable(rank))
				dat += "<a class='linkOff'>[rank_full_name]</a></td></tr>"
				continue
			if((rank in command_positions) || (rank == "AI"))//Bold head jobs
				dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'><b>[rank_full_name]</b></a>"
			else
				dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[rank_full_name]</a>"
			dat += "</td></tr>"

		for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
			dat += "<tr bgcolor='[lastJob.selection_color]'><td>&nbsp</td></tr>"

		dat += "</td'></tr></table>"

		dat += "</center></table>"

		// Added the new browser window method
		var/datum/browser/popup = new(src, "latechoices", "Choose Profession", width, 450)
		popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
		popup.set_content(dat)
		popup.open(0) // 0 is passed to open so that it doesn't use the onclose() proc


	proc/create_character()
		spawning = 1
		close_spawn_windows()

		var/mob/living/carbon/human/new_character = new(loc)
		new_character.lastarea = get_area(loc)

		create_dna(new_character)

		if(config.force_random_names || appearance_isbanned(src))
			client.prefs.random_character()
			client.prefs.real_name = random_name(gender)
		client.prefs.copy_to(new_character)

		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS cant last forever yo

		if(mind)
			mind.active = 0					//we wish to transfer the key manually
			mind.transfer_to(new_character)					//won't transfer key since the mind is not active

		new_character.name = real_name

		ready_dna(new_character, client.prefs.blood_type)

		new_character.key = key		//Manually transfer the key to log them in

		return new_character

	proc/ViewManifest()
		var/dat = "<html><body>"
		dat += "<h4>Crew Manifest</h4>"
		dat += data_core.get_manifest(OOC = 1)

		src << browse(dat, "window=manifest;size=370x420;can_close=1")

	Move()
		return 0


	proc/close_spawn_windows()

		src << browse(null, "window=latechoices") //closes late choices window
		src << browse(null, "window=playersetup") //closes the player setup window
		src << browse(null, "window=preferences") //closes job selection
		src << browse(null, "window=mob_occupation")
		src << browse(null, "window=latechoices") //closes late job selection
