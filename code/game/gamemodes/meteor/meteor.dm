/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/const/meteordelay = 2000
	var/nometeors = 1
	required_players = 0

	uplink_welcome = "EVIL METEOR Uplink Console:"
	uplink_uses = 10


/datum/game_mode/meteor/announce()
	world << "<B>������� ������� ����� - ������!</B>"
	world << "<B>����������&#255; ������&#255; ������ � ��������� ��������� ����������. �� ������ �������&#255; �� ������� �����. �����.</B>"


/datum/game_mode/meteor/post_setup()
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	spawn(meteordelay)
		nometeors = 0
	..()


/datum/game_mode/meteor/process()
	if(nometeors) return
	spawn() spawn_meteors(6)


/datum/game_mode/meteor/declare_completion()
	var/text
	var/survivors = 0
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)	continue
			switch(location.loc.type)
				if( /area/shuttle/escape/centcom )
					text += "<br><b><font size=2>[player.real_name] �����&#255; �� ��������� ������.</font></b>"
				if( /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod4/centcom )
					text += "<br><font size=2>[player.real_name] �����&#255; �� �����.</font>"
				else
					text += "<br><font size=1>[player.real_name] �����, �� �� ������.</font>"
			survivors++

	if(survivors)
		world << "\blue <B>�������� �� ����&#255; ������������ ����&#255;</B>:[text]"
	else
		world << "\blue <B>����� �� ����� ����� ������������ ����&#255;!</B>"

	..()
	return 1
