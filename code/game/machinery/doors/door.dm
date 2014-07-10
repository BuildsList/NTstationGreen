/obj/machinery/door
	name = "door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	layer = 2.7

	var/secondsElectrified = 0
	var/visible = 1
	var/p_open = 0
	var/operating = 0
	var/glass = 0
	var/normalspeed = 1
	var/heat_proof = 0 // For glass airlocks/opacity firedoors
	var/emergency = 0 // Emergency access override
	var/air_properties_vary_with_direction = 0

	//Multi-tile doors
	dir = EAST
	var/width = 1

/obj/machinery/door/New()
	..()
	if(density)
		layer = 3.1 //Above most items if closed
		explosion_resistance = initial(explosion_resistance)
	else
		layer = 2.7 //Under all objects if opened. 2.7 due to tables being at 2.6
		explosion_resistance = 0
	update_freelook_sight()
	update_nearby_tiles(need_rebuild=1)
	return


/obj/machinery/door/Destroy()
	density = 0
	update_nearby_tiles()
	update_freelook_sight()
	..()
	return

//process()
	//return


/obj/machinery/door/proc/update_nearby_tiles(need_rebuild)
	if(!air_master) return 0

	var/turf/simulated/source = loc
	var/turf/simulated/north = get_step(source,NORTH)
	var/turf/simulated/south = get_step(source,SOUTH)
	var/turf/simulated/east = get_step(source,EAST)
	var/turf/simulated/west = get_step(source,WEST)

	update_heat_protection(loc)

	if(istype(source)) air_master.tiles_to_update += source
	if(istype(north)) air_master.tiles_to_update += north
	if(istype(south)) air_master.tiles_to_update += south
	if(istype(east)) air_master.tiles_to_update += east
	if(istype(west)) air_master.tiles_to_update += west

	if(width > 1)
		var/turf/simulated/next_turf = src
		var/step_dir = turn(dir, 180)
		for(var/current_step = 2, current_step <= width, current_step++)
			next_turf = get_step(src, step_dir)
			north = get_step(next_turf, step_dir)
			east = get_step(next_turf, turn(step_dir, 90))
			south = get_step(next_turf, turn(step_dir, -90))

			update_heat_protection(next_turf)

			if(istype(north)) air_master.tiles_to_update |= north
			if(istype(south)) air_master.tiles_to_update |= south
			if(istype(east)) air_master.tiles_to_update |= east

	return 1

/obj/machinery/door/proc/update_heat_protection(var/turf/simulated/source)
	if(istype(source))
		if(src.density && (src.opacity || src.heat_proof))
			source.thermal_conductivity = DOOR_HEAT_TRANSFER_COEFFICIENT
		else
			source.thermal_conductivity = initial(source.thermal_conductivity)


/obj/machinery/door/Bumped(atom/AM)
	if(operating || emagged) return
	if(ismob(AM))
		var/mob/M = AM
		if(world.time - M.last_bumped <= 10) return	//Can bump-open one airlock per second. This is to prevent shock spam.
		M.last_bumped = world.time
		if(!M.restrained())
			bumpopen(M)
		return

	if(istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/bot = AM
		if(src.check_access(bot.botcard) || emergency == 1)
			if(density)
				open()
		return

	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access) || emergency == 1))
				open()
			else
				flick("door_deny", src)
		return
	return


/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density


/obj/machinery/door/proc/bumpopen(mob/user as mob)
	if(operating)	return
	src.add_fingerprint(user)
	if(!src.requiresID())
		user = null

	if(density && !emagged)
		if(allowed(user) || src.emergency == 1)	open()
		else				flick("door_deny", src)
	return


/obj/machinery/door/attack_ai(mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/door/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/door/attack_hand(mob/user as mob)
	return src.attackby(user, user)


/obj/machinery/door/attack_tk(mob/user as mob)
	if(requiresID() && !allowed(null))
		return
	..()

/obj/machinery/door/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/device/detective_scanner))
		return
	if(isrobot(user))	return //borgs can't attack doors open because it conflicts with their AI-like interaction with them.
	src.add_fingerprint(user)
	if(operating || emagged)	return
	if(!Adjacent(user))
		user = null
	if(!src.requiresID())
		user = null
	if(src.density && (istype(I, /obj/item/weapon/card/emag)||istype(I, /obj/item/weapon/melee/energy/blade)))
		flick("door_spark", src)
		sleep(6)
		open()
		emagged = 1
		if(istype(src, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/A = src
			A.lights = 0
			A.locked = 1
			A.loseMainPower()
			A.loseBackupPower()
			A.update_icon()
		return 1
	if(src.allowed(user) || src.emergency == 1)
		if(src.density)
			open()
		else
			close()
		return
	if(src.density)
		flick("door_deny", src)
	return


/obj/machinery/door/blob_act()
	if(prob(40))
		qdel(src)
	return


/obj/machinery/door/emp_act(severity)
	if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
		open()
	if(prob(40/severity))
		if(secondsElectrified == 0)
			secondsElectrified = -1
			spawn(300)
				secondsElectrified = 0
	..()


/obj/machinery/door/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(25))
				qdel(src)
		if(3.0)
			if(prob(80))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
	return


/obj/machinery/door/update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"
	return


/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(p_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(p_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("deny")
			flick("door_deny", src)
	return


/obj/machinery/door/proc/open()
	if(!density)		return 1
	if(operating)		return
	if(!ticker)			return 0
	operating = 1

	do_animate("opening")
	icon_state = "door0"
	src.SetOpacity(0)
	sleep(10)
	src.layer = 2.7
	src.density = 0
	explosion_resistance = 0
	update_icon()
	SetOpacity(0)
	update_nearby_tiles()
	update_freelook_sight()

	if(operating)	operating = 0

	return 1


/obj/machinery/door/proc/close()
	if(density)	return 1
	if(operating)	return
	operating = 1

	do_animate("closing")
	src.density = 1
	explosion_resistance = initial(explosion_resistance)
	src.layer = 3.1
	sleep(10)
	update_icon()
	if(visible && !glass)
		SetOpacity(1)	//caaaaarn!
	operating = 0
	update_nearby_tiles()
	update_freelook_sight()
	return

/obj/machinery/door/proc/crush()
	for(var/mob/living/L in get_turf(src))
		if(isalien(L))  //For xenos
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE * 1.5) //Xenos go into crit after aproximately the same amount of crushes as humans.
			L.emote("roar")
		else if(ishuman(L)) //For humans
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
			L.emote("scream")
			L.Weaken(5)
		else if(ismonkey(L)) //For monkeys
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
			L.Weaken(5)
		else //for simple_animals & borgs
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
		var/turf/location = src.loc
		if(istype(location, /turf/simulated)) //add_blood doesn't work for borgs/xenos, but add_blood_floor does.
			location.add_blood_floor(L)

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'