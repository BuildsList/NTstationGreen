//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done

/client/proc/restart_controller(controller in list("Master","Failsafe","Lighting","Supply Shuttle"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	usr = null
	src = null
	switch(controller)
		if("Master")
			new /datum/controller/game_controller()
			master_controller.process()
		if("Failsafe")
			new /datum/controller/failsafe()
		if("Lighting")
			new /datum/controller/lighting()
			lighting_controller.process()
		if("Supply Shuttle")
			supply_shuttle.process()
	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")
	return


/client/proc/debug_controller(controller in list("Master","Failsafe","Ticker","Lighting","Garbage","Air","Jobs","Sun","Radio","Supply Shuttle","Emergency Shuttle","Configuration","pAI", "Cameras", "Events", "Transfer Controller"))
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	switch(controller)
		if("Master")
			debug_variables(master_controller)
		if("Failsafe")
			debug_variables(Failsafe)
		if("Ticker")
			debug_variables(ticker)
		if("Lighting")
			debug_variables(lighting_controller)
		if("Garbage")
			debug_variables(garbage)
		if("Air")
			debug_variables(air_master)
		if("Jobs")
			debug_variables(job_master)
		if("Sun")
			debug_variables(sun)
		if("Radio")
			debug_variables(radio_controller)
		if("Supply Shuttle")
			debug_variables(supply_shuttle)
		if("Emergency Shuttle")
			debug_variables(emergency_shuttle)
		if("Configuration")
			debug_variables(config)
		if("pAI")
			debug_variables(paiController)
		if("Cameras")
			debug_variables(cameranet)
		if("Events")
			debug_variables(events)
		if("Transfer Controller")
			debug_variables(transfer_controller)
	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return
