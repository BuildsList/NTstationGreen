/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		message_admins("<span class='info'>[usr.key] tried to use the admin panel without authorization.</span>")
		return

	if(href_list["makeAntag"])
		if(!check_rights(R_SERVER))	return
		switch(href_list["makeAntag"])
			if("1")
				message_admins("[key_name(usr)] created traitors.")
				if(!src.makeTraitors())
					usr << "<span class='warning'>Unfortunatly there were no candidates available</span>"
			if("2")
				message_admins("[key_name(usr)] created changelings.")
				if(!src.makeChanglings())
					usr << "<span class='warning'>Unfortunatly there were no candidates available</span>"
			if("3")
				message_admins("[key_name(usr)] started a revolution.")
				if(!src.makeRevs())
					usr << "<span class='warning'>Unfortunatly there were no candidates available</span>"
			if("4")
				message_admins("[key_name(usr)] created cultists.")
				if(!src.makeCult())
					usr << "<span class='warning'>Unfortunatly there were no candidates available</span>"
			if("5")
				message_admins("[key_name(usr)] caused an AI to malfunction.")
				if(!src.makeMalfAImode())
					usr << "<span class='warning'>Unfortunatly there were no candidates available</span>"
			if("6")
				message_admins("[key_name(usr)] created a wizard.")
				if(!src.makeWizard())
					usr << "<span class='warning'>Unfortunatly there were no candidates available</span>"
			if("7")
				message_admins("[key_name(usr)] created a nuke team.")
				if(!src.makeNukeTeam())
					usr << "<span class='warning'>Unfortunatly there were no candidates available</span>"
			if("8")
				message_admins("[key_name(usr)] spawned a ninja.")
				src.makeSpaceNinja()
			if("9")
				message_admins("[key_name(usr)] started an alien infestation.")
				src.makeAliens()
/* DEATH SQUADS
			if("10")
				message_admins("[key_name(usr)] created a death squad.")
				if(!src.makeDeathsquad())
					usr << "<span class='warning'>Unfortunatly there were no candidates available</span>"
*/
	else if(href_list["dbsearchckey"] || href_list["dbsearchadmin"])
		var/adminckey = href_list["dbsearchadmin"]
		var/playerckey = href_list["dbsearchckey"]

		DB_ban_panel(playerckey, adminckey)
		return

	else if(href_list["dbbanedit"])
		var/banedit = href_list["dbbanedit"]
		var/banid = text2num(href_list["dbbanid"])
		if(!banedit || !banid)
			return

		DB_ban_edit(banid, banedit)
		return

	else if(href_list["dbbanaddtype"])

		var/bantype = text2num(href_list["dbbanaddtype"])
		var/banckey = href_list["dbbanaddckey"]
		var/banip = href_list["dbbanaddip"]
		var/bancid = href_list["dbbanaddcid"]
		var/banduration = text2num(href_list["dbbaddduration"])
		var/banjob = href_list["dbbanaddjob"]
		var/banreason = href_list["dbbanreason"]

		banckey = ckey(banckey)

		switch(bantype)
			if(BANTYPE_PERMA)
				if(!banckey || !banreason)
					usr << "Not enough parameters (Requires ckey and reason)"
					return
				banduration = null
				banjob = null
			if(BANTYPE_TEMP)
				if(!banckey || !banreason || !banduration)
					usr << "Not enough parameters (Requires ckey, reason and duration)"
					return
				banjob = null
			if(BANTYPE_JOB_PERMA)
				if(!banckey || !banreason || !banjob)
					usr << "Not enough parameters (Requires ckey, reason and job)"
					return
				banduration = null
			if(BANTYPE_JOB_TEMP)
				if(!banckey || !banreason || !banjob || !banduration)
					usr << "Not enough parameters (Requires ckey, reason and job)"
					return
			if(BANTYPE_APPEARANCE)
				if(!banckey || !banreason)
					usr << "Not enough parameters (Requires ckey and reason)"
					return
				banduration = null
				banjob = null
			if(BANTYPE_ADMIN_PERMA)
				if(!banckey || !banreason)
					usr << "Not enough parameters (Requires ckey and reason)"
					return
				banduration = null
				banjob = null
			if(BANTYPE_ADMIN_TEMP)
				if(!banckey || !banreason || !banduration)
					usr << "Not enough parameters (Requires ckey, reason and duration)"
					return
				banjob = null

		var/mob/playermob

		for(var/mob/M in player_list)
			if(M.ckey == banckey)
				playermob = M
				break

		if(!playermob)
			if(banip)
				banreason = "[banreason]"
			if(bancid)
				banreason = "[banreason]"
		else
			message_admins("Ban process: A mob matching [playermob.ckey] was found at location [playermob.x], [playermob.y], [playermob.z]. Custom ip and computer id fields replaced with the ip and computer id from the located mob")

		DB_ban_record(bantype, playermob, banduration, banreason, banjob, null, banckey, banip, bancid )

	else if(href_list["editrights"])
		if(!check_rights(R_PERMISSIONS))
			message_admins("[key_name(usr)] attempted to edit the admin permissions without sufficient rights.")
			return

		var/adm_ckey

		var/task = href_list["editrights"]
		if(task == "add")
			var/new_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
			if(!new_ckey)	return
			if(new_ckey in admin_datums)
				usr << "<font color='red'>Error: Topic 'editrights': [new_ckey] is already an admin</font>"
				return
			adm_ckey = new_ckey
			task = "rank"
		else if(task != "show")
			adm_ckey = ckey(href_list["ckey"])
			if(!adm_ckey)
				usr << "<font color='red'>Error: Topic 'editrights': No valid ckey</font>"
				return

		var/datum/admins/D = admin_datums[adm_ckey]

		if(task == "remove")
			if(alert("Are you sure you want to remove [adm_ckey]?","Message","Yes","Cancel") == "Yes")
				if(!D)	return
				admin_datums -= adm_ckey
				D.disassociate()

				message_admins("[key_name_admin(usr)] removed [adm_ckey] from the admins list")
				log_admin_rank_modification(adm_ckey, "Removed")

		else if(task == "rank")
			var/new_rank
			if(admin_ranks.len)
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in (admin_ranks|"*New Rank*")
			else
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in list("White Lord","Administrator", "Moderator", "*New Rank*")

			var/rights = 0
			if(D)
				rights = D.rights
			switch(new_rank)
				if(null,"") return
				if("*New Rank*")
					new_rank = input("Please input a new rank", "New custom rank", null, null) as null|text
					if(config.admin_legacy_system)
						new_rank = ckeyEx(new_rank)
					if(!new_rank)
						usr << "<font color='red'>Error: Topic 'editrights': Invalid rank</font>"
						return
					if(config.admin_legacy_system)
						if(admin_ranks.len)
							if(new_rank in admin_ranks)
								rights = admin_ranks[new_rank]		//we typed a rank which already exists, use its rights
							else
								admin_ranks[new_rank] = 0			//add the new rank to admin_ranks
				else
					if(config.admin_legacy_system)
						new_rank = ckeyEx(new_rank)
						rights = admin_ranks[new_rank]				//we input an existing rank, use its rights

			if(D)
				D.disassociate()								//remove adminverbs and unlink from client
				D.rank = new_rank								//update the rank
				D.rights = rights								//update the rights based on admin_ranks (default: 0)
			else
				D = new /datum/admins(new_rank, rights, adm_ckey)

			var/client/C = directory[adm_ckey]						//find the client with the specified ckey (if they are logged in)
			D.associate(C)											//link up with the client and add verbs

			message_admins("[key_name_admin(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin_rank_modification(adm_ckey, new_rank)

		else if(task == "permissions")
			if(!D)	return
			var/list/permissionlist = list()
			for(var/i=1, i<=R_MAXPERMISSION, i<<=1)		//that <<= is shorthand for i = i << 1. Which is a left bitshift
				permissionlist[rights2text(i)] = i
			var/new_permission = input("Select a permission to turn on/off", "Permission toggle", null, null) as null|anything in permissionlist
			if(!new_permission)	return
			D.rights ^= permissionlist[new_permission]

			message_admins("[key_name_admin(usr)] toggled the [new_permission] permission of [adm_ckey]")
			log_admin_permission_modification(adm_ckey, permissionlist[new_permission])

		edit_admin_permissions()

	else if(href_list["call_shuttle"])
		if(!check_rights(R_FUN))	return


		switch(href_list["call_shuttle"])
			if("1")
				if ((!( ticker ) || emergency_shuttle.location))
					return
				emergency_shuttle.incall()
				priority_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.", null,'sound/AI/shuttlecalled.ogg', "Priority")
				message_admins("<span class='info'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>")

			if("2")
				if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0))
					return
				switch(emergency_shuttle.direction)
					if(-1)
						emergency_shuttle.incall()
						priority_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.", null, 'sound/AI/shuttlerecalled.ogg', "Priority")
						message_admins("<span class='info'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>")
					if(1)
						emergency_shuttle.recall()
						message_admins("<span class='info'>[key_name_admin(usr)] sent the Emergency Shuttle back</span>")

		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["edit_shuttle_time"])
		if(!check_rights(R_DEBUG))	return

		emergency_shuttle.settimeleft( input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", emergency_shuttle.timeleft() ) as num )
		priority_announce("The emergency shuttle will reach its destination in [round(emergency_shuttle.timeleft()/60)] minutes.", null, null, "Priority")
		message_admins("<span class='info'>[key_name_admin(usr)] edited the Emergency Shuttle's timeleft to [emergency_shuttle.timeleft()]</span>")
		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["delay_round_end"])
		if(!check_rights(R_SERVER))	return

		ticker.delay_end = !ticker.delay_end
		message_admins("<span class='info'>[key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].</span>")
		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["simplemake"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return

		var/delmob = 0
		switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
			if("Cancel")	return
			if("Yes")		delmob = 1

		message_admins("<span class='info'>[key_name_admin(usr)] has used rudimentary transformation on [key_name_admin(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]</span>")

		switch(href_list["simplemake"])
			if("observer")			M.change_mob_type( /mob/dead/observer , null, null, delmob )
			if("drone")				M.change_mob_type( /mob/living/carbon/alien/humanoid/drone , null, null, delmob )
			if("hunter")			M.change_mob_type( /mob/living/carbon/alien/humanoid/hunter , null, null, delmob )
			if("queen")				M.change_mob_type( /mob/living/carbon/alien/humanoid/queen , null, null, delmob )
			if("sentinel")			M.change_mob_type( /mob/living/carbon/alien/humanoid/sentinel , null, null, delmob )
			if("larva")				M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob )
			if("human")				M.change_mob_type( /mob/living/carbon/human , null, null, delmob )
			if("slime")				M.change_mob_type( /mob/living/carbon/slime , null, null, delmob )
			if("monkey")			M.change_mob_type( /mob/living/carbon/monkey , null, null, delmob )
			if("robot")				M.change_mob_type( /mob/living/silicon/robot , null, null, delmob )
			if("cat")				M.change_mob_type( /mob/living/simple_animal/cat , null, null, delmob )
			if("runtime")			M.change_mob_type( /mob/living/simple_animal/cat/Runtime , null, null, delmob )
			if("corgi")				M.change_mob_type( /mob/living/simple_animal/corgi , null, null, delmob )
			if("ian")				M.change_mob_type( /mob/living/simple_animal/corgi/Ian , null, null, delmob )
			if("crab")				M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob )
			if("coffee")			M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob )
			if("parrot")			M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob )
			if("polyparrot")		M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob )
			if("constructarmoured")	M.change_mob_type( /mob/living/simple_animal/construct/armoured , null, null, delmob )
			if("constructbuilder")	M.change_mob_type( /mob/living/simple_animal/construct/builder , null, null, delmob )
			if("constructwraith")	M.change_mob_type( /mob/living/simple_animal/construct/wraith , null, null, delmob )
			if("shade")				M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob )


	/////////////////////////////////////new ban stuff
	else if(href_list["unbanf"])
		if(!check_rights(R_BAN))	return

		var/banfolder = href_list["unbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if(RemoveBan(banfolder))
				unbanpanel()
			else
				alert(usr, "This ban has already been lifted / does not exist.", "Error", "Ok")
				unbanpanel()

	else if(href_list["warn"])
		usr.client.warn(href_list["warn"])

	else if(href_list["unbane"])
		if(!check_rights(R_BAN))	return

		UpdateTime()
		var/reason

		var/banfolder = href_list["unbane"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/duration

		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				temp = 1
				var/mins = 0
				if(minutes > CMinutes)
					mins = minutes - CMinutes
				mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",mins ? mins : 1440) as num|null
				if(!mins)	return
				mins = min(525599,mins)
				minutes = CMinutes + mins
				duration = GetExp(minutes)
				reason = input(usr,"Reason?","reason",reason2) as text|null
				if(!reason)	return
			if("No")
				temp = 0
				duration = "Perma"
				reason = input(usr,"Reason?","reason",reason2) as text|null
				if(!reason)	return

		message_admins("<span class='info'>[key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]</span>")
		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << reason
		Banlist["temp"] << temp
		Banlist["minutes"] << minutes
		Banlist["bannedby"] << usr.ckey
		Banlist.cd = "/base"
		unbanpanel()

	/////////////////////////////////////new ban stuff

	else if(href_list["appearanceban"])
		if(!check_rights(R_BAN))
			return
		var/mob/M = locate(href_list["appearanceban"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(!M.ckey)	//sanity
			usr << "This mob has no ckey"
			return

		if(appearance_isbanned(M))
			usr << "\red<B>[M.client.ckey] already has identity ban.</B>"

		else switch(alert("Appearance ban [M.ckey]?",,"Yes","No", "Cancel"))
			if("Yes")
				var/reason = input(usr,"Reason?","reason","Trap") as text|null
				if(!reason)
					return
				DB_ban_record(BANTYPE_APPEARANCE, M, -1, reason)
				notes_add(M.ckey, "Appearance banned - [reason]")
				message_admins("<span class='info'>[key_name_admin(usr)] appearance banned [key_name_admin(M)]. \nReason: [reason]</span>")
				M << "\red<BIG><B>You have been appearance banned by [usr.client.ckey].</B></BIG>"
				M << "<span class='warning'><B>The reason is: [reason]</B></span>"
				M << "<span class='warning'>Appearance ban can be lifted only upon request.</span>"
				if(config.banappeals)
					M << "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>"
				else
					M << "<span class='warning'>No ban appeals URL has been set.</span>"
			if("No")
				return

	else if(href_list["jobban2"])
		var/mob/M = locate(href_list["jobban2"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return

		if(!M.ckey)	//sanity
			usr << "This mob has no ckey"
			return
		if(!job_master)
			usr << "Job Master has not been setup!"
			return

		var/dat = ""
		var/header = "<head><title>Job-Ban Panel: [M.name]</title></head>"
		var/body
		var/jobs = ""

	/***********************************WARNING!************************************
				      The jobban stuff looks mangled and disgusting
						      But it looks beautiful in-game
						                -Nodrak
	************************************WARNING!***********************************/
		var/counter = 0
//Regular jobs
	//Command (Blue)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(command_positions)]'><a href='?src=\ref[src];jobban3=commanddept;jobban4=\ref[M]'>Command Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in command_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 6) //So things dont get squiiiiished!
				jobs += "</tr><tr>"
				counter = 0
		jobs += "</tr></table>"

	//Security (Red)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffddf0'><th colspan='[length(security_positions)]'><a href='?src=\ref[src];jobban3=securitydept;jobban4=\ref[M]'>Security Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in security_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Engineering (Yellow)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='fff5cc'><th colspan='[length(engineering_positions)]'><a href='?src=\ref[src];jobban3=engineeringdept;jobban4=\ref[M]'>Engineering Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in engineering_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Medical (White)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeef0'><th colspan='[length(medical_positions)]'><a href='?src=\ref[src];jobban3=medicaldept;jobban4=\ref[M]'>Medical Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in medical_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Science (Purple)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='e79fff'><th colspan='[length(science_positions)]'><a href='?src=\ref[src];jobban3=sciencedept;jobban4=\ref[M]'>Science Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in science_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Civilian (Grey)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(civilian_positions)]'><a href='?src=\ref[src];jobban3=civiliandept;jobban4=\ref[M]'>Civilian Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in civilian_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Non-Human (Green)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccffcc'><th colspan='[length(nonhuman_positions)]'><a href='?src=\ref[src];jobban3=nonhumandept;jobban4=\ref[M]'>Non-human Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in nonhuman_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		//pAI isn't technically a job, but it goes in here.
		if(jobban_isbanned(M, "pAI"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=pAI;jobban4=\ref[M]'><font color=red>pAI</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=pAI;jobban4=\ref[M]'>pAI</a></td>"

		jobs += "</tr></table>"

	//Antagonist (Orange)
		var/isbanned_dept = jobban_isbanned(M, "Syndicate")
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=\ref[src];jobban3=Syndicate;jobban4=\ref[M]'>Antagonist Positions</a></th></tr><tr align='center'>"

		//Traitor
		if(jobban_isbanned(M, "traitor") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=traitor;jobban4=\ref[M]'><font color=red>[replacetext("Traitor", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=traitor;jobban4=\ref[M]'>[replacetext("Traitor", " ", "&nbsp")]</a></td>"

		//Changeling
		if(jobban_isbanned(M, "changeling") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=changeling;jobban4=\ref[M]'><font color=red>[replacetext("Changeling", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=changeling;jobban4=\ref[M]'>[replacetext("Changeling", " ", "&nbsp")]</a></td>"

		//Nuke Operative
		if(jobban_isbanned(M, "operative") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=operative;jobban4=\ref[M]'><font color=red>[replacetext("Nuke Operative", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=operative;jobban4=\ref[M]'>[replacetext("Nuke Operative", " ", "&nbsp")]</a></td>"

		//Revolutionary
		if(jobban_isbanned(M, "revolutionary") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=revolutionary;jobban4=\ref[M]'><font color=red>[replacetext("Revolutionary", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=revolutionary;jobban4=\ref[M]'>[replacetext("Revolutionary", " ", "&nbsp")]</a></td>"

		jobs += "</tr><tr align='center'>" //Breaking it up so it fits nicer on the screen every 5 entries

		//Cultist
		if(jobban_isbanned(M, "cultist") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=cultist;jobban4=\ref[M]'><font color=red>[replacetext("Cultist", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=cultist;jobban4=\ref[M]'>[replacetext("Cultist", " ", "&nbsp")]</a></td>"

		//Wizard
		if(jobban_isbanned(M, "wizard") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=wizard;jobban4=\ref[M]'><font color=red>[replacetext("Wizard", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=wizard;jobban4=\ref[M]'>[replacetext("Wizard", " ", "&nbsp")]</a></td>"

		jobs += "</tr></table>"

		body = "<body>[jobs]</body>"
		dat = "<tt>[header][body]</tt>"
		usr << browse(dat, "window=jobban2;size=800x450")
		return

	//JOBBAN'S INNARDS
	else if(href_list["jobban3"])
		if(!check_rights(R_BAN))	return

		var/mob/M = locate(href_list["jobban4"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return

		if(!job_master)
			usr << "Job Master has not been setup!"
			return

		//get jobs for department if specified, otherwise just returnt he one job in a list.
		var/list/joblist = list()
		switch(href_list["jobban3"])
			if("commanddept")
				for(var/jobPos in command_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("securitydept")
				for(var/jobPos in security_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in engineering_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in medical_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("sciencedept")
				for(var/jobPos in science_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("civiliandept")
				for(var/jobPos in civilian_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("nonhumandept")
				joblist += "pAI"
				for(var/jobPos in nonhuman_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			else
				joblist += href_list["jobban3"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_isbanned(M, job))
				notbannedlist += job

		//Banning comes first
		if(notbannedlist.len) //at least 1 unbanned job exists in joblist so we have stuff to ban.
			switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
				if("Yes")
					if(config.ban_legacy_system)
						usr << "<span class='warning'>Your server is using the legacy banning system, which does not support temporary job bans. Consider upgrading. Aborting ban.</span>"
						return
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(!mins)
						return
					var/reason = sanitize(input(usr,"Reason?","Please State Reason","") as text|null)
					if(!reason)
						return

					var/msg
					for(var/job in notbannedlist)
						DB_ban_record(BANTYPE_JOB_TEMP, M, mins, reason, job)
						jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]") //Legacy banning does not support temporary jobbans.
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					notes_add(M.ckey, "Banned  from [msg] - [reason]")
					message_admins("<span class='info'>[key_name_admin(usr)] jobbanned [key_name_admin(M)] from [msg] for [mins] minutes</span>")
					M << "\red<BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG>"
					M << "<span class='warning'><B>The reason is: [reason]</B></span>"
					M << "<span class='warning'>This jobban will be lifted in [mins] minutes.</span>"
					href_list["jobban2"] = 1 // lets it fall through and refresh
					return 1
				if("No")
					var/reason = sanitize(input(usr,"Reason?","Please State Reason","") as text|null)
					if(reason)
						var/msg
						for(var/job in notbannedlist)
							DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job)
							jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
							if(!msg)	msg = job
							else		msg += ", [job]"
						notes_add(M.ckey, "Banned  from [msg] - [reason]")
						message_admins("<span class='info'>[key_name_admin(usr)] permanently jobbanned [key_name_admin(M)] from [msg]</span>")
						M << "\red<BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG>"
						M << "<span class='warning'><B>The reason is: [reason]</B></span>"
						M << "<span class='warning'>Jobban can be lifted only upon request.</span>"
						href_list["jobban2"] = 1 // lets it fall through and refresh
						return 1
				if("Cancel")
					return

		//Unbanning joblist
		//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
		if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
			if(!config.ban_legacy_system)
				usr << "Unfortunately, database based unbanning cannot be done through this panel"
				DB_ban_panel(M.ckey)
				return
			var/msg
			for(var/job in joblist)
				var/reason = jobban_isbanned(M, job)
				if(!reason) continue //skip if it isn't jobbanned anyway
				switch(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No"))
					if("Yes")
						DB_ban_unban(M.ckey, BANTYPE_JOB_PERMA, job)
						jobban_unban(M, job)
						if(!msg)	msg = job
						else		msg += ", [job]"
					else
						continue
			if(msg)
				message_admins("<span class='info'>[key_name_admin(usr)] unbanned [key_name_admin(M)] from [msg]</span>")
				M << "\red<BIG><B>You have been un-jobbanned by [usr.client.ckey] from [msg].</B></BIG>"
				href_list["jobban2"] = 1 // lets it fall through and refresh
			return 1
		return 0 //we didn't do anything!

	else if(href_list["boot2"])
		var/mob/M = locate(href_list["boot2"])
		if (ismob(M))
			if(!check_if_greater_rights_than(M.client))
				return
			M << "<span class='warning'>You have been kicked from the server</span>"
			message_admins("<span class='info'>[key_name_admin(usr)] kicked [key_name_admin(M)].</span>")
			del(M.client)

	//Player Notes
	else if(href_list["notes"])
		var/ckey = href_list["ckey"]
		switch(href_list["notes"])
			if("show")
				notes_show(ckey)
			if("add")
				notes_add(ckey,href_list["text"], 1)
				notes_show(ckey)
			if("remove")
				notes_remove(ckey,text2num(href_list["from"]),text2num(href_list["to"]))
				notes_show(ckey)

	else if(href_list["removejobban"])
		if(!check_rights(R_BAN))	return

		var/t = href_list["removejobban"]
		if(t)
			if((alert("Do you want to unjobban [t]?","Unjobban confirmation", "Yes", "No") == "Yes") && t) //No more misclicks! Unless you do it twice.
				message_admins("<span class='info'>[key_name_admin(usr)] removed [t]</span>", 1)
				jobban_remove(t)
				href_list["ban"] = 1 // lets it fall through and refresh
				var/t_split = text2list(t, " - ")
				var/key = t_split[1]
				var/job = t_split[2]
				DB_ban_unban(ckey(key), BANTYPE_JOB_PERMA, job)

	else if(href_list["newban"])
		if(!check_rights(R_BAN))	return

		var/mob/M = locate(href_list["newban"])
		if(!ismob(M)) return

		if(M.client && M.client.holder)	return	//admins cannot be banned. Even if they could, the ban doesn't affect them anyway

		switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
			if("Yes")
				var/mins// = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
				var/bantime = input("How long (in minutes)?", "Ban Confirmation", "Cancel") in list("10 Minutes", "1 Hour", "1 Day", "1 Week", "1 Month", "Custom", "Cancel")
				if(bantime == "10 Minutes")
					mins = 10
				if(bantime == "1 Hour")
					mins = 60
				if(bantime == "1 Day")
					mins = 1440
				if(bantime == "1 Week")
					mins = 10080
				if(bantime == "1 Month")
					mins = 43829
				if(bantime == "Custom")
					mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(mins >= 525600) mins = 525599
				if(bantime == "Cancel")
					return
				if(!mins)
					return
				var/reason = input(usr,"Reason?","reason","Because I'm a shitty admin who doesn't type ban reasons and wants to be demoted.") as text|null
				if(!reason)
					return
				AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
				M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
				M << "<span class='warning'>This is a temporary ban, it will be removed in [mins] minutes.</span>"
				DB_ban_record(BANTYPE_TEMP, M, mins, reason)
				if(config.banappeals)
					M << "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>"
				else
					M << "<span class='warning'>No ban appeals URL has been set.</span>"
				message_admins("<span class='notice'>[usr.client.ckey] has banned [M.ckey]. \nReason: [reason] \nThis will be removed in [mins] minutes.</span>")

				del(M.client)
				//qdel(M)	// See no reason why to delete mob. Important stuff can be lost. And ban can be lifted before round ends.
			if("No")
				var/reason = input(usr,"Reason?","reason","Griefer") as text|null
				if(!reason)
					return
				switch(alert(usr,"IP ban?",,"Yes","No","Cancel"))
					if("Cancel")	return
					if("Yes")
						AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0, M.lastKnownIP)
					if("No")
						AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
				M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
				M << "<span class='warning'>This is a permanent ban.</span>"
				if(config.banappeals)
					M << "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>"
				else
					M << "<span class='warning'>No ban appeals URL has been set.</span>"
				message_admins("<span class='notice'>[usr.client.ckey] has banned [M.ckey]. \nReason: [reason] \nThis is a permanent ban.")
				DB_ban_record(BANTYPE_PERMA, M, -1, reason)

				del(M.client)
				//qdel(M)
			if("Cancel")
				return

	else if(href_list["unjobbanf"])
		if(!check_rights(R_BAN))	return

		var/banfolder = href_list["unjobbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if (RemoveBanjob(banfolder))
				unjobbanpanel()
			else
				alert(usr,"This ban has already been lifted / does not exist.","Error","Ok")
				unjobbanpanel()

	else if(href_list["showmultiacc"])
		if(!check_rights(R_ADMIN))	return
		showAccounts(src, href_list["showmultiacc"])

	else if(href_list["mute"])
		if(!check_rights(R_ADMIN))	return
		cmd_admin_mute(href_list["mute"], text2num(href_list["mute_type"]))

	else if(href_list["c_mode"])
		if(!check_rights(R_ADMIN))	return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		var/dat = {"<B>What mode do you wish to play?</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=\ref[src];c_mode2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='?src=\ref[src];c_mode2=secret'>Secret</A><br>"}
		dat += {"<A href='?src=\ref[src];c_mode2=random'>Random</A><br>"}
		dat += {"Now: [master_mode]"}
		usr << browse(dat, "window=c_mode")

	else if(href_list["f_secret"])
		if(!check_rights(R_SERVER))	return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		var/dat = {"<B>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=\ref[src];f_secret2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='?src=\ref[src];f_secret2=secret'>Random (default)</A><br>"}
		dat += {"Now: [secret_force_mode]"}
		usr << browse(dat, "window=f_secret")

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if (ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		master_mode = href_list["c_mode2"]
		message_admins("<span class='info'>[key_name_admin(usr)] set the mode as [master_mode].</span>")
		world << "<span class='info'><b>The mode is now: [master_mode]</b></span>"
		Game() // updates the main game menu
		world.save_mode(master_mode)
		.(href, list("c_mode"=1))

	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		secret_force_mode = href_list["f_secret2"]
		message_admins("<span class='info'>[key_name_admin(usr)] set the forced secret mode as [secret_force_mode].</span>")
		Game() // updates the main game menu
		.(href, list("f_secret"=1))

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["monkeyone"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		message_admins("<span class='info'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)]</span>")
		H.monkeyize()

	else if(href_list["humanone"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/monkey/Mo = locate(href_list["humanone"])
		if(!istype(Mo))
			usr << "This can only be used on instances of type /mob/living/carbon/monkey"
			return

		message_admins("<span class='info'>[key_name_admin(usr)] attempting to humanize [key_name_admin(Mo)]</span>")
		Mo.humanize()

	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["corgione"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		message_admins("<span class='info'>[key_name_admin(usr)] attempting to corgize [key_name_admin(H)]</span>")
		H.corgize()


	else if(href_list["forcespeech"])
		if(!check_rights(R_FUN))	return

		var/mob/M = locate(href_list["forcespeech"])
		if(!ismob(M))
			usr << "this can only be used on instances of type /mob"

		var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)	return
		M.say(speech)
		speech = sanitize(speech) // Nah, we don't trust them
		message_admins("<span class='info'>[key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]</span>")

	else if(href_list["tdome1"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdome1"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.dropped(M)

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdome1)
		spawn(50)
			M << "<span class='info'>You have been sent to the Thunderdome.</span>"
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 1)")

	else if(href_list["tdome2"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdome2"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.dropped(M)

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdome2)
		spawn(50)
			M << "<span class='info'>You have been sent to the Thunderdome.</span>"
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 2)")

	else if(href_list["ltdome1"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["ltdome1"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.dropped(M)

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(ltdome1)
		spawn(50)
			M << "<span class='info'>You have been sent to the Laser-Tag Thunderdome.</span>"
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the laser-tag thunderdome. (BLU)")

	else if(href_list["ltdome2"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["ltdome2"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.dropped(M)

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(ltdome2)
		spawn(50)
			M << "<span class='info'>You have been sent to the Laser-Tag Thunderdome.</span>"
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the laser-tag thunderdome. (RED)")

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeadmin"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdomeadmin)
		spawn(50)
			M << "<span class='info'>You have been sent to the Thunderdome.</span>"
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Admin.)")

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeobserve"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return
		if(istype(M, /mob/living/silicon/ai))
			usr << "This cannot be used on instances of type /mob/living/silicon/ai"
			return

		for(var/obj/item/I in M)
			M.unEquip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.dropped(M)

		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/observer = M
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(observer), slot_w_uniform)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(observer), slot_shoes)
		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdomeobserve)
		spawn(50)
			M << "<span class='info'>You have been sent to the Thunderdome.</span>"
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Observer.)")

	else if(href_list["revive"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/living/L = locate(href_list["revive"])
		if(!istype(L))
			usr << "This can only be used on instances of type /mob/living"
			return

		L.revive()
		message_admins("<span class='warning'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)].</span>")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		message_admins("<span class='warning'>Admin [key_name_admin(usr)] AIized [key_name_admin(H)]!</span>")
		H.AIize()

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		usr.client.cmd_admin_alienize(H)

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		usr.client.cmd_admin_slimeize(H)

	else if(href_list["makeblob"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeblob"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		usr.client.cmd_admin_blobize(H)


	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		usr.client.cmd_admin_robotize(H)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locate(href_list["makeanimal"])
		if(istype(M, /mob/new_player))
			usr << "This cannot be used on instances of type /mob/new_player"
			return

		usr.client.cmd_admin_animalize(M)

	// Mob Inventory Window
	else if(href_list["mobinvdrop"])
		if(!check_rights(R_ADMIN))	return
		var/mob/M = locate(href_list["mobinvdrop"])
		if (M)
			MobInventory(M)
		else
			usr << "No mob"

	else if(href_list["mobinventory"])
		if(!check_rights(R_ADMIN))	return
		var/mob/M = locate(href_list["mobinventory"])
		if (M)
			var/mobtype = text2num(href_list["mobinvdropmobtype"])
			if ((mobtype == 1 && iscarbon(M)) || (mobtype == 2 && ishuman(M)))
				var/obj/item/I = M.get_item_by_slot(text2num(href_list["mobinvdropitem"]))
				if (I)
					M.unEquip(I)
					message_admins("[key_name_admin(usr)] has unequip [I.name] from [M.name]([M.client ? "[M.key]": ""])")
				else
					usr << "No item in slot"
		MobInventory(M)

	else if(href_list["showlaws"])
		if(!check_rights(R_ADMIN))	return

		var/mob/living/silicon/M = locate(href_list["showlaws"])
		if(!ismob(M))	return
		if (M.laws)
			usr << "<B>[M.name] laws:</B>"
			M.laws.show_laws(usr)

	else if(href_list["adminplayeropts"])
		var/mob/M = locate(href_list["adminplayeropts"])
		show_player_panel(M)

	else if(href_list["later"])
		var/mob/M = locate(href_list["later"])
		cmd_admin_mute(M.ckey, 8)
		var/message = "? ?????? ?????? ????????????? ?????? ??????. ??????????, ?????????? ????? ????????? ?????."
		message = strip_html_properly(sanitize(message))
		M << "<span class='info'><b><font color=red>[message]</font></b></span>"
		spawn(600)
		cmd_admin_mute(M.ckey, 8)


	else if(href_list["adminplayerobservejump"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["adminplayerobservejump"])

		var/client/C = usr.client
		if(istype(usr, /mob/new_player))
			usr << "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or Observe first.</font>"
			return
		if(!isobserver(usr))	C.admin_ghost()
		sleep(2)
		C.jumptomob(M)

	else if(href_list["adminplayerobservecoodjump"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))	return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client
		if(!isobserver(usr))	C.admin_ghost()
		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["adminchecklaws"])
		output_ai_laws()

	else if(href_list["adminmoreinfo"])
		var/mob/M = locate(href_list["adminmoreinfo"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob"
			return

		var/location_description = ""
		var/special_role_description = ""
		var/health_description = ""
		var/gender_description = ""
		var/turf/T = get_turf(M)

		//Location
		if(isturf(T))
			if(isarea(T.loc))
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
			else
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

		//Job + antagonist
		if(M.mind)
			special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
		else
			special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

		//Health
		if(isliving(M))
			var/mob/living/L = M
			var/status
			switch (M.stat)
				if (0) status = "Alive"
				if (1) status = "<font color='orange'><b>Unconscious</b></font>"
				if (2) status = "<font color='red'><b>Dead</b></font>"
			health_description = "Status = [status]"
			health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
		else
			health_description = "This mob type has no health to speak of."

		//Gender
		switch(M.gender)
			if(MALE,FEMALE)	gender_description = "[M.gender]"
			else			gender_description = "<font color='red'><b>[M.gender]</b></font>"

		src.owner << "<b>Info about [M.name]:</b> "
		src.owner << "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]"
		src.owner << "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;"
		src.owner << "Location = [location_description];"
		src.owner << "[special_role_description]"
		src.owner << "(<a href='?priv_msg=[M.ckey]'>PM</a>) (<A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[M]'>VV</A>) (<A HREF='?src=\ref[src];subtlemessage=\ref[M]'>SM</A>) (<A HREF='?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</A>) (<A HREF='?src=\ref[src];secretsadmin=check_antagonist'>CA</A>)"

	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN|R_FUN))	return

		var/mob/living/carbon/human/H = locate(href_list["adminspawncookie"])
		if(!ishuman(H))
			usr << "This can only be used on instances of type /mob/living/carbon/human"
			return

		H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_l_hand )
		if(!(istype(H.l_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
			H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_r_hand )
			if(!(istype(H.r_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
				message_admins("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				return
			else
				H.update_inv_hands()//To ensure the icon appears in the HUD
		else
			H.update_inv_hands()
		message_admins("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
		H << "<span class='info'>Your prayers have been answered!! You received the <b>best cookie</b>!</span>"

	else if(href_list["jumpto"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["jumpto"])
		usr.client.jumptomob(M)

	else if(href_list["getmob"])
		if(!check_rights(R_DEBUG))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")	return
		var/mob/M = locate(href_list["getmob"])
		usr.client.Getmob(M)

	else if(href_list["sendmob"])
		if(!check_rights(R_DEBUG))	return

		var/mob/M = locate(href_list["sendmob"])
		usr.client.sendmob(M)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["narrateto"])
		usr.client.cmd_admin_direct_narrate(M)

	else if(href_list["subtlemessage"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["subtlemessage"])
		usr.client.cmd_admin_subtle_message(M)

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN))	return

		if(!ticker || !ticker.mode)
			alert("The game hasn't started yet!")
			return

		var/mob/M = locate(href_list["traitor"])
		if(!ismob(M))
			usr << "This can only be used on instances of type /mob."
			return
		show_traitor_panel(M)


//****** Mob Affect actions

	else if(href_list["mobstun"])
		if(!check_rights(R_DEBUG))	return

		var/mob/M = locate(href_list["mobstun"])
		if(M)
			var/number = input(usr, "How much stun you want to apply?", "Stun", 0) as num
			number = min(abs(number), 100)
			if(number && M && isnull(M.gc_destroyed))
				M.AdjustStunned(number)
				message_admins("[src.owner] apply stun [number] to [M.name]([M.client ? "[M.key]": ""]).")

	else if(href_list["mobparalyze"])
		if(!check_rights(R_DEBUG))	return

		var/mob/M = locate(href_list["mobparalyze"])
		if(M)
			var/number = input(usr, "How much paralysis you want to apply?", "Paralyze", 0) as num
			number = min(abs(number), 100)
			if(number && M && isnull(M.gc_destroyed))
				M.AdjustParalysis(number)
				message_admins("[src.owner] apply paralysis [number] to [M.name]([M.client ? "[M.key]": ""]).")

	else if(href_list["mobweak"])
		if(!check_rights(R_DEBUG))	return

		var/mob/M = locate(href_list["mobweak"])
		if(M)
			var/number = input(usr, "How much weaken you want to apply?", "Weak", 0) as num
			number = min(abs(number), 100)
			if(number && M && isnull(M.gc_destroyed))
				M.AdjustWeakened(number)
				message_admins("[src.owner] apply weak [number] to [M.name]([M.client ? "[M.key]": ""]).")

	else if(href_list["mobsleep"])
		if(!check_rights(R_DEBUG))	return

		var/mob/M = locate(href_list["mobsleep"])
		if(M)
			var/number = input(usr, "How much sleep you want to apply?", "Sleep", 0) as num
			number = min(abs(number), 100)
			if(number && M && isnull(M.gc_destroyed))
				M.AdjustSleeping(number)
				message_admins("[src.owner] apply sleep [number] to [M.name]([M.client ? "[M.key]": ""]).")

	else if(href_list["mobslip"])
		if(!check_rights(R_DEBUG))	return

		var/mob/M = locate(href_list["mobslip"])
		if(M && iscarbon(M))
			var/answer = alert("Sleep on lube?",,"Yes","No", "Cancel")
			if(answer !="Cancel" && M && isnull(M.gc_destroyed) && iscarbon(M))
				var/lube = 0
				if (answer == "Yes")
					lube = 1
				M.slip(5, 10, null, lube)
				message_admins("[src.owner] make [M.name]([M.client ? "[M.key]": ""]) to slip ([lube ? "lube" : "no lube"]).")

//****** End of Mob Affect actions


//****** Spawn(Game Panel)

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))	return
		return create_object(usr)

	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))	return
		return quick_create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))	return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))	return
		return create_mob(usr)

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))	return

		var/atom/loc = usr.loc

		var/dirty_paths
		if (istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if (istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()
		var/removed_paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				removed_paths += dirty_path
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				removed_paths += dirty_path
				continue
			else if(ispath(path, /obj/item/weapon/gun/energy/pulse_rifle))
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /obj/item/weapon/melee/energy/blade))//Not an item one should be able to spawn./N
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /obj/effect/anomaly/bhole))
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			paths += path

		if(!paths)
			alert("The path list you sent is empty")
			return
		if(length(paths) > 5)
			alert("Select fewer object types, (max 5)")
			return
		else if(length(removed_paths))
			alert("Removed:\n" + list2text(removed_paths, "\n"))

		var/list/offset = text2list(href_list["offset"],",")
		var/number = dd_range(1, 100, text2num(href_list["object_count"]))
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/tmp_dir = href_list["object_dir"]
		var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
		if(!obj_dir || !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = 2
		var/obj_name = sanitize(href_list["object_name"])
		var/where = href_list["object_where"]
		if (!( where in list("onfloor","inhand","inmarked") ))
			where = "onfloor"

		if( where == "inhand" )
			usr << "Support for inhand not available yet. Will spawn on floor."
			where = "onfloor"

		if ( where == "inhand" )	//Can only give when human or monkey
			if ( !( ishuman(usr) || ismonkey(usr) ) )
				usr << "Can only spawn in hand when you're a human or a monkey."
				where = "onfloor"
			else if ( usr.get_active_hand() )
				usr << "Your active hand is full. Spawning on floor."
				where = "onfloor"

		if ( where == "inmarked" )
			if ( !marked_datum )
				usr << "You don't have any object marked. Abandoning spawn."
				return
			else
				if ( !istype(marked_datum,/atom) )
					usr << "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn."
					return

		var/atom/target //Where the object will be spawned
		switch ( where )
			if ( "onfloor" )
				switch (href_list["offset_type"])
					if ("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if ("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if ( "inmarked" )
				target = marked_datum

		if(target)
			for (var/path in paths)
				for (var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N)
							if(obj_name)
								N.name = obj_name
					else
						var/atom/O = new path(target)
						if(O)
							O.dir = obj_dir
							if(obj_name)
								O.name = obj_name
								if(istype(O,/mob))
									var/mob/M = O
									M.real_name = obj_name

		if (number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created a [english_list(paths)]")
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)]")
					break
		return

//****** End of Spawn(Game Panel)

	else if(href_list["secretsfun"])
		if(!check_rights(R_FUN))	return
		var/datum/round_event/E
		var/ok = 0
		switch(href_list["secretsfun"])
			if("monkey")
				for(var/mob/living/carbon/human/H in mob_list)
					spawn(0)
						H.monkeyize()
				ok = 1
			if("corgi")
				for(var/mob/living/carbon/human/H in mob_list)
					spawn(0)
						H.corgize()
				ok = 1

			if("tripleAI")
				usr.client.triple_ai()
			if("gravity")
				alert("WIP - event unavailable")
/*				E = new /datum/round_event/weightless()
				message_admins("[key_name_admin(usr)] triggered a gravity-failure event.")	*/
			if("power")
				message_admins("[key_name_admin(usr)] made all areas powered")
				power_restore()
			if("unpower")
				message_admins("[key_name_admin(usr)] made all areas unpowered")
				power_failure()
			if("quickpower")
				message_admins("[key_name_admin(usr)] made all SMESs powered")
				power_restore_quick()
			if("traitor_all")
				if(!ticker)
					alert("The game hasn't started yet!")
					return
				var/objective = copytext(sanitize(input("Enter an objective")),1,MAX_MESSAGE_LEN)
				if(!objective)
					return
				for(var/mob/living/carbon/human/H in player_list)
					if(H.stat == 2 || !H.client || !H.mind) continue
					if(is_special_character(H)) continue
					//traitorize(H, objective, 0)
					ticker.mode.traitors += H.mind
					H.mind.special_role = "traitor"
					var/datum/objective/new_objective = new
					new_objective.owner = H
					new_objective.explanation_text = objective
					H.mind.objectives += new_objective
					ticker.mode.greet_traitor(H.mind)
					//ticker.mode.forge_traitor_objectives(H.mind)
					ticker.mode.finalize_traitor(H.mind)
				for(var/mob/living/silicon/A in player_list)
					if(A.stat == 2 || !A.client || !A.mind) continue
					if(ispAI(A)) continue
					else if(is_special_character(A)) continue
					ticker.mode.traitors += A.mind
					A.mind.special_role = "traitor"
					var/datum/objective/new_objective = new
					new_objective.owner = A
					new_objective.explanation_text = objective
					A.mind.objectives += new_objective
					ticker.mode.greet_traitor(A.mind)
					ticker.mode.finalize_traitor(A.mind)
				message_admins("[key_name_admin(usr)] used everyone is a traitor secret. Objective is [objective]")
			if("togglebombcap")
				switch(MAX_EX_LIGHT_RANGE)
					if(14)
						MAX_EX_LIGHT_RANGE = 16
						MAX_EX_HEAVY_RANGE = 8
						MAX_EX_DEVESTATION_RANGE = 4
					if(16)
						MAX_EX_LIGHT_RANGE = 20
						MAX_EX_HEAVY_RANGE = 10
						MAX_EX_DEVESTATION_RANGE = 5
					if(20)
						MAX_EX_LIGHT_RANGE = 28
						MAX_EX_HEAVY_RANGE = 14
						MAX_EX_DEVESTATION_RANGE = 7
					if(28)
						MAX_EX_LIGHT_RANGE = 56
						MAX_EX_HEAVY_RANGE = 28
						MAX_EX_DEVESTATION_RANGE = 14
					if(56)
						MAX_EX_LIGHT_RANGE = 128
						MAX_EX_HEAVY_RANGE = 64
						MAX_EX_DEVESTATION_RANGE = 32
					if(128)
						MAX_EX_LIGHT_RANGE = 14
						MAX_EX_HEAVY_RANGE = 7
						MAX_EX_DEVESTATION_RANGE = 3
				message_admins("<span class='warning'><b> [key_name_admin(usr)] changed the bomb cap to [MAX_EX_DEVESTATION_RANGE], [MAX_EX_HEAVY_RANGE], [MAX_EX_LIGHT_RANGE]</b></span>")

			if("wave")
				message_admins("[key_name_admin(usr)] has spawned meteors")
				E = new /datum/round_event/meteor_wave()
			if("gravanomalies")
				message_admins("[key_name_admin(usr)] has spawned a gravitational anomaly")
				E = new /datum/round_event/anomaly/anomaly_grav()
			if("pyroanomalies")
				message_admins("[key_name_admin(usr)] has spawned a pyroclastic anomaly")
				E = new /datum/round_event/anomaly/anomaly_pyro()
			if("blackhole")
				message_admins("[key_name_admin(usr)] has spawned a vortex anomaly")
				E = new /datum/round_event/anomaly/anomaly_vortex()
/*			if("timeanomalies")	//dear god this code was awful :P Still needs further optimisation
				message_admins("[key_name_admin(usr)] has made wormholes")
				E = new /datum/round_event/wormholes() */
			if("npcblob")
				message_admins("[key_name_admin(usr)] has spawned an NPC blob")
				E = new /datum/round_event/blob()
			if("goblob")
				message_admins("[key_name_admin(usr)] has spawned a blob overmind")
				E = new /datum/round_event/blob/overmind()
			if("aliens")
				message_admins("[key_name_admin(usr)] has spawned aliens")
				E = new /datum/round_event/alien_infestation()
			if("alien_silent")								//replaces the spawn_xeno verb
				create_xeno()
			if("brand")
				E = new /datum/round_event/brand_intelligence()
				message_admins("[key_name_admin(usr)] started an aggressive marketing campaign")
			if("spiders")
				E = new /datum/round_event/spider_infestation()
				message_admins("[key_name_admin(usr)] has spawned spiders")
			if("bluespaceanomaly")
				E = new /datum/round_event/anomaly/anomaly_bluespace()
				message_admins("[key_name_admin(usr)] has triggered a bluespace anomaly")
			if("comms_blackout")
				E = new /datum/round_event/communications_blackout()
				message_admins("[key_name_admin(usr)] triggered a communications blackout.")
			if("spaceninja")
				message_admins("[key_name_admin(usr)] has sent in a space ninja")
				E = new /datum/round_event/ninja()
			if("carp")
				E = new /datum/round_event/carp_migration()
				message_admins("[key_name_admin(usr)] has spawned carp.")
			if("radiation")
				message_admins("[key_name_admin(usr)] has has irradiated the station")
				E = new /datum/round_event/radiation_storm()
			if("immovable")
				message_admins("[key_name_admin(usr)] has sent an immovable rod to the station")
				E = new /datum/round_event/immovable_rod()
			if("prison_break")
				message_admins("[key_name_admin(usr)] has allowed a prison break")
				E = new /datum/round_event/prison_break()
			if("lightsout")
				message_admins("[key_name_admin(usr)] has broke a lot of lights")
				E = new /datum/round_event/electrical_storm{lightsoutAmount = 2}()
			if("blackout")
				message_admins("[key_name_admin(usr)] broke all lights")
				for(var/obj/machinery/light/L in world)
					L.broken()
			if("whiteout")
				message_admins("[key_name_admin(usr)] fixed all lights")
				for(var/obj/machinery/light/L in world)
					L.fix()
			if("virus")
				switch(alert("Do you want this to be a random disease or do you have something in mind?",,"Make Your Own","Random","Choose"))
					if("Make Your Own")
						AdminCreateVirus(usr.client)
					if("Random")
						E = new /datum/round_event/disease_outbreak()
					if("Choose")
						var/virus = input("Choose the virus to spread", "BIOHAZARD") as null|anything in typesof(/datum/disease)
						E = new /datum/round_event/disease_outbreak{}()
						var/datum/round_event/disease_outbreak/DO = E
						DO.virus_type = virus
			if("retardify")
				for(var/mob/living/carbon/human/H in player_list)
					H << "<span class='warning'><B>You suddenly feel stupid.</B></span>"
					H.setBrainLoss(60)
				message_admins("[key_name_admin(usr)] made everybody retarded")
			if("eagles")//SCRAW
				for(var/obj/machinery/door/airlock/W in world)
					if(W.z == 1 && !istype(get_area(W), /area/bridge) && !istype(get_area(W), /area/crew_quarters) && !istype(get_area(W), /area/security/prison))
						W.req_access = list()
				message_admins("[key_name_admin(usr)] activated Egalitarian Station mode")
				priority_announce("Centcom airlock control override activated. Please take this time to get acquainted with your coworkers.", null, 'sound/AI/commandreport.ogg')
			if("guns")
				usr.magic_summon("guns")
			if("magic")
				usr.magic_summon("magic")
			if("mechs")
				usr.magic_summon("mechs")
			if("melee")
				usr.magic_summon("melee")
			if("dorf")
				for(var/mob/living/carbon/human/B in mob_list)
					B.facial_hair_style = "Dward Beard"
					B.update_hair()
				message_admins("[key_name_admin(usr)] activated dorf mode")
			if("ionstorm")
				message_admins("[key_name_admin(usr)] triggered an ion storm")
				E = new /datum/round_event/ion_storm()
			if("spacevines")
				message_admins("[key_name_admin(usr)] has spawned spacevines")
				E = new /datum/round_event/spacevine()
			if("onlyone")
				usr.client.only_one()
				message_admins("[key_name_admin(usr)] has triggered a battle to the death (only one)")
			if("energeticflux")
				message_admins("[key_name_admin(usr)] has triggered an energetic flux")
				E = new /datum/round_event/anomaly/anomaly_flux()
		if(E)
			E.processing = 0
			if(E.announceWhen>0)
				if(alert(usr, "Would you like to alert the crew?", "Alert", "Yes", "No") == "No")
					E.announceWhen = -1
			E.processing = 1
		if(usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsfun"]]")
			if (ok)
				world << text("<B>A secret has been activated by []!</B>", usr.key)

	else if(href_list["secretsadmin"])
		if(!check_rights(R_ADMIN))	return

		var/ok = 0
		switch(href_list["secretsadmin"])
			if("clear_virus")
				var/choice = input("Are you sure you want to cure all disease?") in list("Yes", "Cancel")
				if(choice == "Yes")
					message_admins("[key_name_admin(usr)] has cured all diseases.")
					for(var/datum/disease/D in active_diseases)
						D.cure(D)
			if("list_bombers")
				var/dat = "<B>Bombing List<HR>"
				for(var/l in bombers)
					dat += text("[l]<BR>")
				usr << browse(dat, "window=bombers")
			if("list_signalers")
				var/dat = "<B>Showing last [length(lastsignalers)] signalers.</B><HR>"
				for(var/sig in lastsignalers)
					dat += "[sig]<BR>"
				usr << browse(dat, "window=lastsignalers;size=800x500")
			if("list_lawchanges")
				var/dat = "<B>Showing last [length(lawchanges)] law changes.</B><HR>"
				for(var/sig in lawchanges)
					dat += "[sig]<BR>"
				usr << browse(dat, "window=lawchanges;size=800x500")
			if("check_antagonist")
				check_antagonists()
			if("moveminingshuttle")
				var/datum/shuttle_manager/s = shuttles["mining"]
				if(istype(s)) s.move_shuttle(0,1)
				message_admins("[key_name_admin(usr)] moved mining shuttle")
			if("movelaborshuttle")
				var/datum/shuttle_manager/s = shuttles["laborcamp"]
				if(istype(s)) s.move_shuttle(0,1)
				message_admins("[key_name_admin(usr)] moved labor shuttle")
			if("moveferry")
				var/datum/shuttle_manager/s = shuttles["ferry"]
				if(istype(s)) s.move_shuttle(0,1)
				message_admins("[key_name_admin(usr)] moved the centcom ferry")
			if("kick_all_from_lobby")
				if(ticker && ticker.current_state == GAME_STATE_PLAYING)
					var/afkonly = text2num(href_list["afkonly"])
					if(alert("Are you sure you want to kick all [afkonly ? "AFK" : ""] clients from the lobby??","Message","Yes","Cancel") != "Yes")
						usr << "Kick clients from lobby aborted"
						return
					var/list/listkicked = kick_clients_in_lobby("<span class='warning'>The admin [usr.ckey] issued a 'kick all clients from lobby' command.</span>", afkonly)
					var/strkicked = ""
					for(var/name in listkicked)
						strkicked += "[name], "
					message_admins("[key_name_admin(usr)] has kicked [afkonly ? "all AFK" : "all"] clients from the lobby. [length(listkicked)] clients kicked: [strkicked ? strkicked : "--"]")
				else
					usr << "You may only use this when the game is running"
			if("showailaws")
				output_ai_laws()
			if("showgm")
				if(!ticker)
					alert("The game hasn't started yet!")
				else if (ticker.mode)
					alert("The game mode is [ticker.mode.name]")
				else alert("For some reason there's a ticker, but not a game mode")
			if("manifest")
				var/dat = "<B>Showing Crew Manifest.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
				for(var/datum/data/record/t in data_core.general)
					dat += "<tr><td>[t.fields["name"]]</td><td>[t.fields["rank"]]</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=manifest;size=440x410")
			if("DNA")
				var/dat = "<B>Showing DNA from blood.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.dna && H.ckey)
						dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.blood_type]</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=DNA;size=440x410")
			if("fingerprints")
				var/dat = "<B>Showing Fingerprints.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.ckey)
						if(H.dna && H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
						else if(H.dna && !H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>H.dna.uni_identity = null</td></tr>"
						else if(!H.dna)
							dat += "<tr><td>[H]</td><td>H.dna = null</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=fingerprints;size=440x410")
			else
		if (usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsadmin"]]")
			if (ok)
				world << text("<B>A secret has been activated by []!</B>", usr.key)

	else if(href_list["secretsgeneral"])
		switch(href_list["secretsgeneral"])
			if("spawn_objects")
				var/dat = "<B>Admin Log<HR></B>"
				for(var/l in admin_log)
					dat += "<li>[l]</li>"
				if(!admin_log.len)
					dat += "No-one has done anything this round!"
				usr << browse(dat, "window=admin_log")
			if("list_job_debug")
				var/dat = "<B>Job Debug info.</B><HR>"
				if(job_master)
					for(var/line in job_master.job_debug)
						dat += "[line]<BR>"
					dat+= "*******<BR><BR>"
					for(var/datum/job/job in job_master.occupations)
						if(!job)	continue
						dat += "job: [job.title], current_positions: [job.current_positions], total_positions: [job.total_positions] <BR>"
					usr << browse(dat, "window=jobdebug;size=600x500")
			if("show_admins")
				var/dat = "<B>Current admins:</B><HR>"
				if(admin_datums)
					for(var/ckey in admin_datums)
						var/datum/admins/D = admin_datums[ckey]
						dat += "[ckey] - [D.rank]<br>"
					usr << browse(dat, "window=showadmins;size=600x500")

	else if(href_list["secretscoder"])
		if(!check_rights(R_DEBUG))	return

		switch(href_list["secretscoder"])
			if("maint_access_brig")
				for(var/obj/machinery/door/airlock/maintenance/M in world)
					M.check_access()
					if (access_maint_tunnels in M.req_access)
						M.req_access = list(access_brig)
				message_admins("[key_name_admin(usr)] made all maint doors brig access-only.")
			if("maint_access_engiebrig")
				for(var/obj/machinery/door/airlock/maintenance/M in world)
					M.check_access()
					if (access_maint_tunnels in M.req_access)
						M.req_access = list()
						M.req_one_access = list(access_brig,access_engine)
				message_admins("[key_name_admin(usr)] made all maint doors engineering and brig access-only.")
			if("infinite_sec")
				var/datum/job/J = job_master.GetJob("Security Officer")
				if(!J) return
				J.total_positions = -1
				J.spawn_positions = -1
				message_admins("[key_name_admin(usr)] has removed the cap on security officers.")

	else if(href_list["ac_view_wanted"])            //Admin newscaster Topic() stuff be here
		src.admincaster_screen = 18                 //The ac_ prefix before the hrefs stands for AdminCaster.
		src.access_news_network()

	else if(href_list["ac_set_channel_name"])
		src.admincaster_feed_channel.channel_name = strip_html(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", ""))
		while (findtext(src.admincaster_feed_channel.channel_name," ") == 1)
			src.admincaster_feed_channel.channel_name = copytext(src.admincaster_feed_channel.channel_name,2,lentext(src.admincaster_feed_channel.channel_name)+1)
		src.access_news_network()

	else if(href_list["ac_set_channel_lock"])
		src.admincaster_feed_channel.locked = !src.admincaster_feed_channel.locked
		src.access_news_network()

	else if(href_list["ac_submit_new_channel"])
		var/check = 0
		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == src.admincaster_feed_channel.channel_name)
				check = 1
				break
		if(src.admincaster_feed_channel.channel_name == "" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]" || check )
			src.admincaster_screen=7
		else
			var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
			if(choice=="Confirm")
				news_network.CreateFeedChannel(src.admincaster_feed_channel.channel_name, src.admincaster_signature, src.admincaster_feed_channel.locked, 1)
				log_admin("[key_name(usr)] created command feed channel: [src.admincaster_feed_channel.channel_name].")
				src.admincaster_screen=5
		src.access_news_network()

	else if(href_list["ac_set_channel_receiving"])
		var/list/available_channels = list()
		for(var/datum/feed_channel/F in news_network.network_channels)
			available_channels += F.channel_name
		src.admincaster_feed_channel.channel_name = adminscrub(input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels )
		src.access_news_network()

	else if(href_list["ac_set_new_message"])
		src.admincaster_feed_message.body = adminscrub(input(usr, "Write your Feed story", "Network Channel Handler", ""))
		while (findtext(src.admincaster_feed_message.body," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.body,2,lentext(src.admincaster_feed_message.body)+1)
		src.access_news_network()

	else if(href_list["ac_submit_new_message"])
		if(src.admincaster_feed_message.body =="" || src.admincaster_feed_message.body =="\[REDACTED\]" || src.admincaster_feed_channel.channel_name == "" )
			src.admincaster_screen = 6
		else
			news_network.SubmitArticle(src.admincaster_feed_message.body, src.admincaster_signature, src.admincaster_feed_channel.channel_name, null, 1)
			src.admincaster_screen=4

		for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
			NEWSCASTER.newsAlert(src.admincaster_feed_channel.channel_name)

		log_admin("[key_name(usr)] submitted a feed story to channel: [src.admincaster_feed_channel.channel_name].")
		src.access_news_network()

	else if(href_list["ac_create_channel"])
		src.admincaster_screen=2
		src.access_news_network()

	else if(href_list["ac_create_feed_story"])
		src.admincaster_screen=3
		src.access_news_network()

	else if(href_list["ac_menu_censor_story"])
		src.admincaster_screen=10
		src.access_news_network()

	else if(href_list["ac_menu_censor_channel"])
		src.admincaster_screen=11
		src.access_news_network()

	else if(href_list["ac_menu_wanted"])
		var/already_wanted = 0
		if(news_network.wanted_issue)
			already_wanted = 1

		if(already_wanted)
			src.admincaster_feed_message.author = news_network.wanted_issue.author
			src.admincaster_feed_message.body = news_network.wanted_issue.body
		src.admincaster_screen = 14
		src.access_news_network()

	else if(href_list["ac_set_wanted_name"])
		src.admincaster_feed_message.author = adminscrub(input(usr, "Provide the name of the Wanted person", "Network Security Handler", ""))
		while (findtext(src.admincaster_feed_message.author," ") == 1)
			src.admincaster_feed_message.author = copytext(admincaster_feed_message.author,2,lentext(admincaster_feed_message.author)+1)
		src.access_news_network()

	else if(href_list["ac_set_wanted_desc"])
		src.admincaster_feed_message.body = adminscrub(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", ""))
		while (findtext(src.admincaster_feed_message.body," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.body,2,lentext(src.admincaster_feed_message.body)+1)
		src.access_news_network()

	else if(href_list["ac_submit_wanted"])
		var/input_param = text2num(href_list["ac_submit_wanted"])
		if(src.admincaster_feed_message.author == "" || src.admincaster_feed_message.body == "")
			src.admincaster_screen = 16
		else
			var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
					var/datum/feed_message/WANTED = new /datum/feed_message
					WANTED.author = src.admincaster_feed_message.author               //Wanted name
					WANTED.body = src.admincaster_feed_message.body                   //Wanted desc
					WANTED.backup_author = src.admincaster_signature                  //Submitted by
					WANTED.is_admin_message = 1
					news_network.wanted_issue = WANTED
					for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
						NEWSCASTER.newsAlert()
						NEWSCASTER.update_icon()
					src.admincaster_screen = 15
				else
					news_network.wanted_issue.author = src.admincaster_feed_message.author
					news_network.wanted_issue.body = src.admincaster_feed_message.body
					news_network.wanted_issue.backup_author = src.admincaster_feed_message.backup_author
					src.admincaster_screen = 19
				log_admin("[key_name(usr)] issued a Station-wide Wanted Notification for [src.admincaster_feed_message.author].")
		src.access_news_network()

	else if(href_list["ac_cancel_wanted"])
		var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
		if(choice=="Confirm")
			news_network.wanted_issue = null
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.update_icon()
			src.admincaster_screen=17
		src.access_news_network()

	else if(href_list["ac_censor_channel_author"])
		var/datum/feed_channel/FC = locate(href_list["ac_censor_channel_author"])
		if(FC.author != "<B>\[REDACTED\]</B>")
			FC.backup_author = FC.author
			FC.author = "<B>\[REDACTED\]</B>"
		else
			FC.author = FC.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_author"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_author"])
		if(MSG.author != "<B>\[REDACTED\]</B>")
			MSG.backup_author = MSG.author
			MSG.author = "<B>\[REDACTED\]</B>"
		else
			MSG.author = MSG.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_body"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_body"])
		if(MSG.body != "<B>\[REDACTED\]</B>")
			MSG.backup_body = MSG.body
			MSG.body = "<B>\[REDACTED\]</B>"
		else
			MSG.body = MSG.backup_body
		src.access_news_network()

	else if(href_list["ac_pick_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_d_notice"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen=13
		src.access_news_network()

	else if(href_list["ac_toggle_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_toggle_d_notice"])
		FC.censored = !FC.censored
		src.access_news_network()

	else if(href_list["ac_view"])
		src.admincaster_screen=1
		src.access_news_network()

	else if(href_list["ac_setScreen"]) //Brings us to the main menu and resets all fields~
		src.admincaster_screen = text2num(href_list["ac_setScreen"])
		if (src.admincaster_screen == 0)
			if(src.admincaster_feed_channel)
				src.admincaster_feed_channel = new /datum/feed_channel
			if(src.admincaster_feed_message)
				src.admincaster_feed_message = new /datum/feed_message
		src.access_news_network()

	else if(href_list["ac_show_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_show_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 9
		src.access_news_network()

	else if(href_list["ac_pick_censor_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_censor_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 12
		src.access_news_network()

	else if(href_list["ac_refresh"])
		src.access_news_network()

	else if(href_list["ac_set_signature"])
		src.admincaster_signature = adminscrub(input(usr, "Provide your desired signature", "Network Identity Handler", ""))
		src.access_news_network()