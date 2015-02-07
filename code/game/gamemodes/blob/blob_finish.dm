/datum/game_mode/blob/check_finished()
	if(!declared)//No blobs have been spawned yet
		return 0
	if(blobwincount <= blobs.len)//Blob took over
		return 1
	if(!blob_cores.len) // blob is dead
		return 1
	if(station_was_nuked)//Nuke went off
		return 1
	return 0


/datum/game_mode/blob/declare_completion()
	if(blobwincount <= blobs.len)
		world << "<FONT size = 3><B>Блоб захватил всю станцию!</B></FONT>"
		world << "<B>Цела&#255; станци&#255; была сожрана Блобом.</B>"
		log_game("Blob mode was lost.")

	else if(station_was_nuked)
		world << "<FONT size = 3><B>Ничь&#255;: Станци&#255; была унчтожена!</B></FONT>"
		world << "<B>Устройство 7-12 было успешно применено на станции, чтобы избежать распространени&#255; инфекции.</B>"
		log_game("Blob mode was tie (station destroyed).")

	else if(!blob_cores.len)
		world << "<FONT size = 3><B>Победа персонала!</B></FONT>"
		world << "<B>Все споры опасного организма были искоренены!</B>"

		var/datum/station_state/end_state = new /datum/station_state()
		end_state.count()
		var/percent = round( 100.0 *  start_state.score(end_state), 0.1)
		world << "<B>Станци&#255; была захвачена на [percent]%</B>"
		log_game("Blob mode was won with station [percent]% intact.")
		world << "\blue Перезагрузка через 30 секунд"
	..()
	return 1

datum/game_mode/proc/auto_declare_completion_blob()
	if(istype(ticker.mode,/datum/game_mode/blob) )
		var/datum/game_mode/blob/blob_mode = src
		if(blob_mode.infected_crew.len)
			var/text = "<FONT size = 2><B>[(blob_mode.infected_crew.len > 1 ? "Исполн&#255;ли" : "Исполн&#255;л")] роль Надмозга:</B></FONT>"

			for(var/datum/mind/blob in blob_mode.infected_crew)
				text += "<br><b>[blob.key]</b> был <b>[blob.name]</b>"
			world << text
		return 1
