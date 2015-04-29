#define SOUND_CHANNEL_ADMIN 777
var/sound/admin_sound

/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	admin_sound = sound(S, repeat = 0, wait = 1, channel = SOUND_CHANNEL_ADMIN)
	admin_sound.priority = 250
	admin_sound.status = SOUND_UPDATE|SOUND_STREAM

	message_admins("[key_name_admin(src)] played sound [S]")

	if(events.holiday == "April Fool's Day")
		admin_sound.frequency = pick(0.5, 0.7, 0.8, 0.85, 0.9, 0.95, 1.1, 1.2, 1.4, 1.6, 2.0, 2.5)
		src << "You feel the Honkmother messing with your song..."

	for(var/mob/M in player_list)
		if(M.client.prefs.toggles & SOUND_MIDI)
			M << admin_sound

	admin_sound.frequency = 1 //Remove this line when the AFD stuff above is gone
	admin_sound.wait = 0

/client/proc/play_local_sound(S as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))	return

	message_admins("[key_name_admin(src)] played a local sound [S]")
	playsound(get_turf(src.mob), S, 50, 0, 0)

/client/proc/stop_sounds()
	set category = "Debug"
	set name = "Stop Sounds"
	if((check_rights(R_SOUNDS)) || (check_rights(R_DEBUG)))

		message_admins("[key_name_admin(src)] stopped all currently playing sounds.")
		for(var/mob/M in player_list)
			if(M.client)
				M << sound(null)
	else
		return
#undef SOUND_CHANNEL_ADMIN