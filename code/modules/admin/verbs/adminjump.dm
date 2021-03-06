/client/proc/Jump(var/area/A in return_sorted_areas())
	set name = "Jump to Area"
	set desc = "Area to jump to"
	set category = "Admin"
	if(!src.holder)
		src << "Only administrators may use this command."
		return

	usr.loc = pick(get_area_turfs(A))
	log_admin("[key_name(usr)] jumped to [A]")
	message_admins("[key_name_admin(usr)] jumped to [A]", 1)

/client/proc/jumptoturf(var/turf/T in world)
	set name = "Jump to Turf"
	set category = "Admin"
	if(!src.holder)
		src << "Only administrators may use this command."
		return

	message_admins("[key_name_admin(usr)] jumped to [T.x],[T.y],[T.z] in [T.loc]")
	usr.loc = T
	return

/client/proc/jumptomob(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Jump to Mob"

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]")
	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = get_turf(M)
		if(T && isturf(T))
			A.loc = T
		else
			A << "This mob is not located in the game world."

/client/proc/jumptocoord(tx as num, ty as num, tz as num)
	set category = "Admin"
	set name = "Jump to Coordinate"

	if (!holder)
		src << "Only administrators may use this command."
		return

	if(src.mob)
		var/mob/A = src.mob
		A.x = tx
		A.y = ty
		A.z = tz
	message_admins("[key_name_admin(usr)] jumped to coordinates [tx], [ty], [tz]")

/client/proc/jumptokey()
	set category = "Admin"
	set name = "Jump to Key"

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	var/list/keys = list()
	for(var/mob/M in player_list)
		keys += M.client
	var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
	if(!selection)
		src << "No keys found."
		return
	var/mob/M = selection:mob
	message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]")
	usr.loc = M.loc

/client/proc/Getmob(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Get Mob"
	set desc = "Mob to teleport"

	if(!check_rights(R_DEBUG))	return

	message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)]")
	M.loc = get_turf(usr)

/client/proc/Getkey()
	set category = "Admin"
	set name = "Get Key"
	set desc = "Key to teleport"

	if(!check_rights(R_DEBUG))	return

	var/list/keys = list()
	for(var/mob/M in player_list)
		keys += M.client
	var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
	if(!selection)
		return
	var/mob/M = selection:mob

	if(!M)
		return
	message_admins("[key_name_admin(usr)] teleported [key_name(M)]")
	if(M)
		M.loc = get_turf(usr)

/client/proc/sendmob(var/mob/M in sortmobs())
	set category = "Admin"
	set name = "Send Mob"

	if(!check_rights(R_DEBUG))	return

	var/area/A = input(usr, "Pick an area.", "Pick an area") in return_sorted_areas()
	if(A)
		M.loc = pick(get_area_turfs(A))
		message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)] to [A]")
