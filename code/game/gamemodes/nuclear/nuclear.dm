/datum/game_mode
	var/list/datum/mind/syndicates = list()


/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	required_players = 20
	required_enemies = 3
	recommended_enemies = 3
	pre_setup_before_jobs = 1
	antag_flag = BE_OPERATIVE

	uplink_welcome = "Corporate Backed Uplink Console:"
	uplink_uses = 18 //Ops get extra TC if their team is smaller.

	var/agents_possible = 3 //If we ever need more syndicate agents.
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/nukes_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level

/datum/game_mode/nuclear/announce()
	world << "<B>Текущий игровой режим - &#255;дерна&#255; Угроза!</B>"
	world << "<B>Оперативные агенты [syndicate_name()] собираютс&#255; напасть на станцию! Не дайте им преуспеть</B>"
//	world << "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear auth. disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! Also, most likely Syndicate star ships are in the vicinity so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!"

/datum/game_mode/nuclear/pre_setup()
	if(num_players() >= 30)
		agents_possible = 5
		recommended_enemies = 5
		uplink_uses = 10
	else if (num_players() >= 25)
		agents_possible = 4
		recommended_enemies = 4
		uplink_uses = 13

	var/agent_number = 0
	if(antag_candidates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = antag_candidates.len

	var/n_players = num_players()
	if(agent_number > n_players)
		agent_number = n_players/2

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(antag_candidates)
		syndicates += new_syndicate
		antag_candidates -= new_syndicate //So it doesn't pick the same guy each time.
		agent_number--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.
		synd_mind.special_role = "Syndicate"//So they actually have a special role/N
		log_game("[synd_mind.key] (ckey) has been selected as a nuclear operative")
	return 1


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/update_all_synd_icons()
	spawn(0)
		for(var/datum/mind/synd_mind in syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/image/I in synd_mind.current.client.images)
						if(I.icon_state == "synd")
							del(I)

		for(var/datum/mind/synd_mind in syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/datum/mind/synd_mind_1 in syndicates)
						if(synd_mind_1.current)
							var/I = image('icons/mob/mob.dmi', loc = synd_mind_1.current, icon_state = "synd")
							synd_mind.current.client.images += I

/datum/game_mode/proc/update_synd_icons_added(datum/mind/synd_mind)
	spawn(0)
		if(synd_mind.current)
			if(synd_mind.current.client)
				var/I = image('icons/mob/mob.dmi', loc = synd_mind.current, icon_state = "synd")
				synd_mind.current.client.images += I

/datum/game_mode/proc/update_synd_icons_removed(datum/mind/synd_mind)
	spawn(0)
		for(var/datum/mind/synd in syndicates)
			if(synd.current)
				if(synd.current.client)
					for(var/image/I in synd.current.client.images)
						if(I.icon_state == "synd" && I.loc == synd_mind.current)
							del(I)

		if(synd_mind.current)
			if(synd_mind.current.client)
				for(var/image/I in synd_mind.current.client.images)
					if(I.icon_state == "synd")
						del(I)

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/post_setup()

	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			qdel(A)
			continue

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink")	//i will be rewriting this shortly
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	var/nuke_code = "[rand(10000, 99999)]"
	var/leader_selected = 0
	var/agent_number = 1
	var/spawnpos = 1

	for(var/datum/mind/synd_mind in syndicates)
		if(spawnpos > synd_spawn.len)
			spawnpos = 1
		synd_mind.current.loc = synd_spawn[spawnpos]

		forge_syndicate_objectives(synd_mind)
		greet_syndicate(synd_mind)
		equip_syndicate(synd_mind.current)

		if(!leader_selected)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			agent_number++
		spawnpos++
		update_synd_icons_added(synd_mind)

	update_all_synd_icons()

	if(uplinklocker)
		new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)
	if(nuke_spawn && synd_spawn.len > 0)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

	return ..()


/datum/game_mode/proc/prepare_syndicate_leader(var/datum/mind/synd_mind, var/nuke_code)
	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	spawn(1)
		NukeNameAssign(nukelastname(synd_mind.current),syndicates) //allows time for the rest of the syndies to be chosen
	synd_mind.current.real_name = "[syndicate_name()] [leader_title]"
	if (nuke_code)
		synd_mind.store_memory("<B>Код от &#255;дерной боеголовки Синдиката</B>: [nuke_code]", 0, 0)
		synd_mind.current << "Код от &#255;дерной боеголовки Синдиката: <B>[nuke_code]</B>"
		var/obj/item/weapon/paper/P = new
		P.info = "Код от &#255;дерной боеголовки Синдиката: <b>[nuke_code]</b>"
		P.name = "nuclear bomb code"
		if (ticker.mode.config_tag=="nuclear")
			P.loc = synd_mind.current.loc
		else
			var/mob/living/carbon/human/H = synd_mind.current
			P.loc = H.loc
			H.equip_to_slot_or_del(P, slot_r_store, 0)
			H.update_icons()

	else
		nuke_code = "будет выдан позже"
	return


/datum/game_mode/proc/forge_syndicate_objectives(var/datum/mind/syndicate)
	var/datum/objective/nuclear/syndobj = new
	syndobj.owner = syndicate
	syndicate.objectives += syndobj


/datum/game_mode/proc/greet_syndicate(var/datum/mind/syndicate, var/you_are=1)
	if (you_are)
		syndicate.current << "<span class='info'>Вы оперативный агент [syndicate_name()]!</span>"
	var/obj_count = 1
	for(var/datum/objective/objective in syndicate.objectives)
		syndicate.current << "<B>Задание #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return


/datum/game_mode/proc/random_radio_frequency()
	return 1337 // WHY??? -- Doohl


/datum/game_mode/proc/equip_syndicate(mob/living/carbon/human/synd_mob)
	var/radio_freq = SYND_FREQ

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(synd_mob)
	R.set_frequency(radio_freq)
	synd_mob.equip_to_slot_or_del(R, slot_ears)

	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(synd_mob), slot_w_uniform)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(synd_mob), slot_shoes)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(synd_mob), slot_wear_suit)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(synd_mob), slot_gloves)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat/syndicate(synd_mob), slot_head)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/card/id/syndicate/nuke(synd_mob), slot_wear_id)
	if(synd_mob.backbag == 2) synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(synd_mob), slot_back)
	if(synd_mob.backbag == 3) synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(synd_mob), slot_back)
	synd_mob.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m10mm(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/pill/cyanide(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/pistol(synd_mob), slot_belt)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(synd_mob.back), slot_in_backpack)

	var/obj/item/device/radio/uplink/U = new /obj/item/device/radio/uplink(synd_mob)
	U.hidden_uplink.uplink_owner="[synd_mob.key]"
	U.hidden_uplink.uses = 10
	synd_mob.equip_to_slot_or_del(U, slot_in_backpack)

	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive(synd_mob)
	E.imp_in = synd_mob
	E.implanted = 1
	synd_mob.factions += "syndicate"
	synd_mob.update_icons()
	return 1


/datum/game_mode/nuclear/check_win()
	if (nukes_left == 0)
		return 1
	return ..()


/datum/game_mode/proc/is_operatives_are_dead()
	for(var/datum/mind/operative_mind in syndicates)
		if (!istype(operative_mind.current,/mob/living/carbon/human))
			if(operative_mind.current)
				if(operative_mind.current.stat!=2)
					return 0
	return 1


/datum/game_mode/nuclear/declare_completion()
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in world)
		var/disk_area = get_area(D)
		if(!is_type_in_list(disk_area, centcom_areas))
			disk_rescued = 0
			break
	var/crew_evacuated = (emergency_shuttle.location==2)

	if      (!disk_rescued &&  station_was_nuked &&          !syndies_didnt_escape)
		world << "<FONT size = 3><B>Полна&#255; победа Синдиката!</B></FONT>"
		world << "<B>Оперативные агенты [syndicate_name()] доставили посылку и уничтожили [station_name()]!</B>"

	else if (!disk_rescued &&  station_was_nuked &&           syndies_didnt_escape)
		world << "<FONT size = 3><B>ТОТАЛЬНЫЙ ЭКСТЕРМИНАТУС!</B></FONT>"
		world << "<B>Оперативные агенты [syndicate_name()] уничтожили [station_name()], но не успели улететь и поджарились вместе с персоналом.</B>"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station && !syndies_didnt_escape)
		world << "<FONT size = 3><B>Частична&#255; победа персонала</B></FONT>"
		world << "<B>Оперативные агенты  [syndicate_name()] украли диск, но взорвали не ту станцию.</B>"
	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station &&  syndies_didnt_escape)
		world << "<FONT size = 3><B>[syndicate_name()] получают Премию Дарвина!</B></FONT>"
		world << "<B>Оперативные агенты [syndicate_name()] взорвали не ту станцию и подорвались вместе с ней.</B>"

	else if ( disk_rescued                                         && is_operatives_are_dead())
		world << "<FONT size = 3><B>Полна&#255; победа персонала!</B></FONT>"
		world << "<B>Научный персонал смог сохранить диск и полностью уничтожил всех оперативных агентов [syndicate_name()]!</B>"

	else if ( disk_rescued                                        )
		world << "<FONT size = 3><B>Полна&#255; победа персонала!</B></FONT>"
		world << "<B>Научный персонал смог сохранить диск и остановить оперативных агентов [syndicate_name()]!</B>"

	else if (!disk_rescued                                         && is_operatives_are_dead())
		world << "<FONT size = 3><B>Частична&#255; победа Синдиката!</B></FONT>"
		world << "<B>Научный персонал не смог сохранить диск, но при этом они навал&#255;ли хороших люлей оперативным агентам [syndicate_name()]!</B>"

	else if (!disk_rescued                                         &&  crew_evacuated)
		world << "<FONT size = 3><B>Частична&#255; победа Синдиката!</B></FONT>"
		world << "<B>Оперативные агенты [syndicate_name()] смогли удержать украденый диск, но персонал [station_name()] успел сбежать."

	else if (!disk_rescued                                         && !crew_evacuated)
		world << "<FONT size = 3><B>Ничь&#255;</B></FONT>"
		world << "<B>Раунд был прерван магическим вмешательством третьих лиц!</B>"

	..()
	return


/datum/game_mode/proc/auto_declare_completion_nuclear()
	if( syndicates.len || (ticker && istype(ticker.mode,/datum/game_mode/nuclear)) )
		var/text = "<br><FONT size=3><B>Оперативными агентами Синдиката были:</B></FONT>"

		var/purchases = ""
		var/TC_uses = 0

		for(var/datum/mind/syndicate in syndicates)

			text += "<br><b>[syndicate.key]</b> был <b>[syndicate.name]</b> ("
			if(syndicate.current)
				if(syndicate.current.stat == DEAD)
					text += "мёртв"
				else
					text += "выжил"
				if(syndicate.current.real_name != syndicate.name)
					text += " как <b>[syndicate.current.real_name]</b>"
			else
				text += "тело уничтожено"
			text += ")"

			for(var/obj/item/device/uplink/H in world_uplinks)
				if(H && H.uplink_owner && H.uplink_owner==syndicate.key)
					TC_uses += H.used_TC
					purchases += H.purchase_log

		text += "<br>"

		text += "(Команда использовала [TC_uses] телекристалов) [purchases]"

		if(TC_uses==0 && station_was_nuked && !is_operatives_are_dead())
			text += "<BIG><IMG CLASS=icon SRC=\ref['icons/BadAss.dmi'] ICONSTATE='badass'></BIG>"

		world << text
	return 1


/proc/nukelastname(var/mob/M as mob) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea. Also praise Urist for copypasta ho.
	var/randomname = pick(last_names)
	var/newname = copytext(sanitize(input(M,"You are the nuke operative [pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")]. Please choose a last name for your family.", "Name change",randomname)),1,MAX_NAME_LEN)

	if (!newname)
		newname = randomname

	else
		if (newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "rwall" || newname == "_")
			M << "That name is reserved."
			return nukelastname(M)

	return newname

/proc/NukeNameAssign(var/lastname,var/list/syndicates)
	for(var/datum/mind/synd_mind in syndicates)
		switch(synd_mind.current.gender)
			if(MALE)
				synd_mind.name = "[pick(first_names_male)] [lastname]"
			if(FEMALE)
				synd_mind.name = "[pick(first_names_female)] [lastname]"
		synd_mind.current.real_name = synd_mind.name
	return