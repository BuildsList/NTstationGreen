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
			if(jobban_isbanned(src, rank))
				dat += "<a class='linkOff'><font color=red>[rank]</font></a><font color=red><b> \[BANNED\]</b></font></td></tr>"
				continue
			if(!job.player_old_enough(src.client))
				var/available_in_days = job.available_in_days(src.client)
				dat += "<a class='linkOff'><font color=red>[rank]</font></a><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
				continue
			if(!IsJobAvailable(rank))
				dat += "<a class='linkOff'>[rank]</a></td></tr>"
				continue
			if((rank in command_positions) || (rank == "AI"))//Bold head jobs
				dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'><b>[rank]</b></a>"
			else
				dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[rank]"
				if(job.total_positions > 1)
					dat += " ([job.current_positions])"
				dat += "</a>"

			dat += "</td></tr>"

		for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
			dat += "<tr bgcolor='[lastJob.selection_color]'><td>&nbsp</td></tr>"

		dat += "</td'></tr></table>"

		dat += "</center></table>"

		//var/available_job_count = 0
		//for(var/datum/job/job in job_master.occupations)
		//	if(job && IsJobAvailable(job.title))
		//		available_job_count++;
		/*
		var/list/engineeringJobs = list()
		var/list/medicalJobs = list()
		var/list/scienceJobs = list()
		var/list/assistantJobs = list()
		var/list/securityJobs = list()
		var/list/civilianJobs = list()
		var/datum/job/captain = null
		var/datum/job/CE = null
		var/datum/job/RD = null
		var/datum/job/CMO = null
		var/datum/job/HoP = null
		var/datum/job/HoS = null

		for(var/datum/job/job in job_master.occupations)
			if(!job)
				continue
			if(job.title in command_positions)
				if(job.title in engineering_positions)
					CE = job
				else if(job.title in medical_positions)
					CMO = job
				else if(job.title in science_positions)
					RD = job
				else if(job.title in security_positions)
					HoS = job
				else if(job.title in civilian_positions)
					HoP = job
				else
					captain = job

			else if(job.title in engineering_positions)
				engineeringJobs.Add(job)
			else if(job.title in medical_positions)
				medicalJobs.Add(job)
			else if(job.title in science_positions)
				scienceJobs.Add(job)
			else if(job.title in security_positions)
				securityJobs.Add(job)
			else if(job.title in assistant_occupations) //Always before civilian
				assistantJobs.Add(job)
			else if(job.title in civilian_positions)
				civilianJobs.Add(job)

		dat += "<div class='clearBoth'>Choose from the following open positions:</div><br>"
		if(IsJobAvailable(captain.title))
			dat += "<center><a class='commandPosition' bgcolor='[captain.selection_color]' href='byond://?src=\ref[src];SelectedJob=[captain.title]'>[captain.title]</a></center><br>" //ONE ABOVE ALL
		else
			dat += "<a class='linkOff'>[captain.title]</a><br><br>"

		dat += "<table class='jobs'><td class='jobsColumn'>"

		if(IsJobAvailable(CE.title))
			dat += "<a class='commandPosition' bgcolor='[CE.selection_color]' href='byond://?src=\ref[src];SelectedJob=[CE.title]'>[CE.title]</a><br><br>"
		else
			dat += "<a class='linkOff'>[CE.title]</a><br><br>"

		for(var/datum/job/job in engineeringJobs)
			if(!job)
				continue
			if(IsJobAvailable(job.title))
				dat += "<a class='otherPositions' bgcolor='[job.selection_color]' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
			else
				dat += "<a class='linkOff'>[job.title]</a><br>"

		dat += "</td><td class='jobsColumn'>"

		if(IsJobAvailable(CMO.title))
			dat += "<a class='commandPosition' bgcolor='[CMO.selection_color]' href='byond://?src=\ref[src];SelectedJob=[CMO.title]'>[CMO.title]</a><br><br>"
		else
			dat += "<a class='linkOff'>[CMO.title]</a><br><br>"

		for(var/datum/job/job in medicalJobs)
			if(!job)
				continue
			if(IsJobAvailable(job.title))
				dat += "<a class='otherPositions' bgcolor='[job.selection_color]' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
			else
				dat += "<a class='linkOff'>[job.title]</a><br>"

		dat += "</td><td class='jobsColumn' bgcolor='#993399'>"

		if(IsJobAvailable(RD.title))
			dat += "<a class='commandPosition' bgcolor='[RD.selection_color]' href='byond://?src=\ref[src];SelectedJob=[RD.title]'>[RD.title]</a><br><br>"
		else
			dat += "<a class='linkOff'>[RD.title]</a><br><br>"

		for(var/datum/job/job in scienceJobs)
			if(!job)
				continue
			if(IsJobAvailable(job.title))
				dat += "<a class='otherPositions' bgcolor='[job.selection_color]' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
			else
				dat += "<a class='linkOff'>[job.title]</a><br>"

		dat += "</td><td class='jobsColumn' bgcolor='#B22222'>"

		if(IsJobAvailable(HoS.title))
			dat += "<a class='commandPosition' bgcolor='[HoS.selection_color]' href='byond://?src=\ref[src];SelectedJob=[HoS.title]'>[HoS.title]</a><br><br>"
		else
			dat += "<a class='linkOff'>[HoS.title]</a><br><br>"

		for(var/datum/job/job in securityJobs)
			if(!job)
				continue
			if(IsJobAvailable(job.title))
				dat += "<a class='otherPositions' bgcolor='[job.selection_color]' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
			else
				dat += "<a class='linkOff'>[job.title]</a><br>"

		dat += "</td><td class='jobsColumn' bgcolor='#6eaa2c'>"

		if(IsJobAvailable(HoP.title))
			dat += "<a class='commandPosition' bgcolor='[HoP.selection_color]' href='byond://?src=\ref[src];SelectedJob=[HoP.title]'>[HoP.title]</a><br><br>"
		else
			dat += "<a class='linkOff'>[HoP.title]</a><br><br>"

		for(var/datum/job/job in civilianJobs)
			if(!job)
				continue
			if(IsJobAvailable(job.title))
				dat += "<a class='otherPositions' bgcolor='[job.selection_color]' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
			else
				dat += "<a class='linkOff'>[job.title]</a><br>"

		dat += "</td><td class='jobsColumn' bgcolor='#ffffff'>"

		dat += "<a class='linkOff'>Any NT personnel</a><br><br>"

		for(var/datum/job/job in assistantJobs)
			if(!job)
				continue
			if(IsJobAvailable(job.title))
				dat += "<a class='otherPositions' bgcolor='[job.selection_color]' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
			else
				dat += "<a class='linkOff'>[job.title]</a><br>"

		dat += "</td></td>"
		*/
		/* //OLD VERSION//UNCOMMENT IT IF YOU ADDED NEW JOB
		dat += "<div class='clearBoth'>Choose from the following open positions:</div><br>"
		dat += "<div class='jobs'><div class='jobsColumn'>"
		var/job_count = 0
		for(var/datum/job/job in job_master.occupations)
			if(job && IsJobAvailable(job.title))
				job_count++;
				if (job_count > round(available_job_count / 2))
					dat += "</div><div class='jobsColumn'>"
				var/position_class = "otherPosition"
				if (job.title in command_positions)
					position_class = "commandPosition"
				dat += "<a class='[position_class]' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
		dat += "</div></div>"

		// Removing the old window method but leaving it here for reference
		//src << browse(dat, "window=latechoices;size=300x640;can_close=1")
		*/
		// Added the new browser window method
		var/datum/browser/popup = new(src, "latechoices", "Choose Profession", width, 620)
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
