/* Using the HUD procs is simple. Call these procs in the life.dm of the intended mob.
Use the regular_hud_updates() proc before process_med_hud(mob) or process_sec_hud(mob) so
the HUD updates properly! */

//Deletes the current HUD images so they can be refreshed with new ones.
/image/var/hud_remove = 0


mob/proc/regular_hud_updates() //Used in the life.dm of mobs that can use HUDs.
	if(client)
		for(var/image/hud in client.images)
			if(hud.hud_remove)
				client.images -= hud
	if(src in med_hud_users)
		med_hud_users -= src
	if(src in sec_hud_users)
		sec_hud_users -= src
	if(src in mining_hud_users)
		mining_hud_users -= src


//Medical HUD procs

proc/RoundHealth(health)

	switch(health)
		if(100 to INFINITY)
			return "health100"
		if(70 to 100)
			return "health80"
		if(50 to 70)
			return "health60"
		if(30 to 50)
			return "health40"
		if(18 to 30)
			return "health25"
		if(5 to 18)
			return "health10"
		if(1 to 5)
			return "health1"
		if(-99 to 0)
			return "health0"
		else
			return "health-100"
	return "0"

//Medical HUD outputs. Called by the Life() proc of the mob using it, usually.
proc/process_med_hud(var/mob/M, var/mob/eye)
	if(!M)
		return
	if(!M.client)
		return
	if(!(M in med_hud_users))
		med_hud_users += M
	var/client/C = M.client
	var/image/holder
	var/turf/T
	if(eye)
		T = get_turf(eye)
	else
		T = get_turf(M)
	for(var/mob/living/carbon/human/patient in range(T))
		var/foundVirus = 0
		for(var/datum/disease/D in patient.viruses)
			if(!D.hidden[SCANNER])
				foundVirus++
		if(!C) continue

		holder = patient.hud_list[HEALTH_HUD]
		holder.hud_remove = 1
		if(patient.stat == 2)
			holder.icon_state = "hudhealth-100"
		else
			holder.icon_state = "hud[RoundHealth(patient.health)]"
		C.images += holder

		holder = patient.hud_list[STATUS_HUD]
		holder.hud_remove = 1
		if(patient.stat == 2)
			holder.icon_state = "huddead"
		else if(patient.status_flags & XENO_HOST)
			holder.icon_state = "hudxeno"
		else if(foundVirus)
			holder.icon_state = "hudill"
		else
			holder.icon_state = "hudhealthy"
		C.images += holder


//Security HUDs. Pass a value for the second argument to enable implant viewing or other special features.
proc/process_sec_hud(var/mob/living/M, var/advanced_mode,var/mob/eye)
	if(!M)
		return
	if(!M.client)
		return
	if(!(M in sec_hud_users))
		sec_hud_users += M
	var/client/C = M.client
	var/image/holder
	var/turf/T
	if(eye)
		T = get_turf(eye)
	else
		T = get_turf(M)
	for(var/mob/living/carbon/human/perp in range(T))
		holder = perp.hud_list[ID_HUD]
		holder.icon_state = "hudno_id"
		holder.hud_remove = 1
		if(perp.wear_id)
			holder.icon_state = "hud[ckey(perp.wear_id.GetJobName())]"
		C.images += holder

		if(advanced_mode) //If set, the SecHUD will display the implants a person has.
			for(var/obj/item/weapon/implant/I in perp)
				if(I.implanted)
					if(istype(I,/obj/item/weapon/implant/tracking))
						holder = perp.hud_list[IMPTRACK_HUD]
						holder.icon_state = "hud_imp_tracking"
					else if(istype(I,/obj/item/weapon/implant/loyalty))
						holder = perp.hud_list[IMPLOYAL_HUD]
						holder.icon_state = "hud_imp_loyal"
					else if(istype(I,/obj/item/weapon/implant/chem))
						holder = perp.hud_list[IMPCHEM_HUD]
						holder.icon_state = "hud_imp_chem"
					else
						continue
					holder.hud_remove = 1
					C.images += holder
					break

		var/perpname = perp.get_face_name(perp.get_id_name(""))
		if(perpname)
			var/datum/data/record/R = find_record("name", perpname, data_core.security)
			if(R)
				holder = perp.hud_list[WANTED_HUD]
				holder.hud_remove = 1 //We want to remove it at next tick
				switch(R.fields["criminal"])
					if("*Arrest*")		holder.icon_state = "hudwanted"
					if("Incarcerated")	holder.icon_state = "hudincarcerated"
					if("Parolled")		holder.icon_state = "hudparolled"
					if("Released")		holder.icon_state = "hudreleased"
					else
						continue
				C.images += holder


proc/process_mining_hud(var/mob/M, var/mob/eye)
	if(!M)
		return
	if(!M.client)
		return

	var/client/C = M.client

	var/turf/eye_turf
	if(eye)
		eye_turf = get_turf(eye)
	else
		eye_turf = get_turf(M)

	var/list/L = list()

	for(var/turf/simulated/mineral/MT in range(7, eye_turf))
		if(MT.scan_state)
			L += MT

	for(var/turf/simulated/mineral/MT in L)
		var/turf/T = get_turf(MT)
		var/image/I = image('icons/turf/walls.dmi', loc = T, icon_state = MT.scan_state, layer = 18)
		I.hud_remove = 1
		C.images += I