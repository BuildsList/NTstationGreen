/datum/game_mode
	var/list/datum/mind/wizards = list()

/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"
	antag_flag = BE_WIZARD
	required_players = 15
	required_enemies = 1
	recommended_enemies = 1
	pre_setup_before_jobs = 1

	uplink_welcome = "Wizardly Uplink Console:"
	uplink_uses = 10

	var/finished = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/wizard/announce()
	world << "<B>??????? ??????? ????? - ?????????!</B>"
	world << "<B>\red ??????????? ?????????\black ????? ???????? ???????. ?? ????? ??? ????????? ?????????.</B>"

/datum/game_mode/wizard/pre_setup()

	var/datum/mind/wizard = pick(antag_candidates)
	wizards += wizard
	modePlayer += wizard
	wizard.assigned_role = "MODE" //So they aren't chosen for other jobs.
	wizard.special_role = "Wizard"
	if(wizardstart.len == 0)
		wizard.current << "<B>\red A starting location for you could not be found, please report this bug!</B>"
		return 0
	for(var/datum/mind/wiz in wizards)
		wiz.current.loc = pick(wizardstart)

	return 1


/datum/game_mode/wizard/post_setup()
	for(var/datum/mind/wizard in wizards)
		log_game("[wizard.key] (ckey) has been selected as a Wizard")
		forge_wizard_objectives(wizard)
		//learn_basic_spells(wizard.current)
		equip_wizard(wizard.current)
		name_wizard(wizard.current)
		greet_wizard(wizard)

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return


/datum/game_mode/proc/forge_wizard_objectives(var/datum/mind/wizard)
	switch(rand(1,100))
		if(1 to 30)

			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = wizard
			kill_objective.find_target()
			wizard.objectives += kill_objective

			if (!(locate(/datum/objective/escape) in wizard.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = wizard
				wizard.objectives += escape_objective
		if(31 to 60)
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = wizard
			steal_objective.find_target()
			wizard.objectives += steal_objective

			if (!(locate(/datum/objective/escape) in wizard.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = wizard
				wizard.objectives += escape_objective

		if(61 to 85)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = wizard
			kill_objective.find_target()
			wizard.objectives += kill_objective

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = wizard
			steal_objective.find_target()
			wizard.objectives += steal_objective

			if (!(locate(/datum/objective/survive) in wizard.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = wizard
				wizard.objectives += survive_objective

		else
			if (!(locate(/datum/objective/hijack) in wizard.objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = wizard
				wizard.objectives += hijack_objective
	return


/datum/game_mode/proc/name_wizard(mob/living/carbon/human/wizard_mob)
	//Allows the wizard to choose a custom name or go with a random one. Spawn 0 so it does not lag the round starting.
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	spawn(0)
		var/newname = copytext(sanitize(input(wizard_mob, "You are the Space Wizard. Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = randomname

		wizard_mob.real_name = newname
		wizard_mob.name = newname
		if(wizard_mob.mind)
			wizard_mob.mind.name = newname
	return


/datum/game_mode/proc/greet_wizard(var/datum/mind/wizard, var/you_are=1)
	if (you_are)
		wizard.current << "<B>\red ?? ??????????? ?????????!</B>"
	wizard.current << "<B>????????&#255; ??????????? ??????????? ???????? ??? ????? ??????&#255;:</B>"

	var/obj_count = 1
	for(var/datum/objective/objective in wizard.objectives)
		wizard.current << "<B>??????? #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return

/datum/game_mode/proc/equip_wizard(mob/living/carbon/human/wizard_mob)
	if (!istype(wizard_mob))
		return

	//So zards properly get their items when they are admin-made.
	qdel(wizard_mob.wear_suit)
	qdel(wizard_mob.head)
	qdel(wizard_mob.shoes)
	qdel(wizard_mob.r_hand)
	qdel(wizard_mob.r_store)
	qdel(wizard_mob.l_store)

	wizard_mob.equip_to_slot_or_del(new /obj/item/device/radio/headset(wizard_mob), slot_ears)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(wizard_mob), slot_w_uniform)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(wizard_mob), slot_shoes)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(wizard_mob), slot_wear_suit)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(wizard_mob), slot_head)
	if(wizard_mob.backbag == 2) wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(wizard_mob), slot_back)
	if(wizard_mob.backbag == 3) wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(wizard_mob), slot_back)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(wizard_mob), slot_in_backpack)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(wizard_mob), slot_r_store)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/spellbook(wizard_mob), slot_r_hand)

	wizard_mob << "?? ??????? ???????? ????????? ?????????? ? ????? ?????. ????????? ?  ????."
	wizard_mob << "? ????? ??????? ????? ?????? ????????????. ??????????? ?? ?????????????"
	wizard_mob.mind.store_memory("<B>?????????:</B> ?? ???????? ??????? ?????????&#255;, ????? ??? ??? ?????? ?? ???????.")
	wizard_mob.update_icons()
	return 1


/datum/game_mode/wizard/check_finished()

	if(config.continuous_round_wiz)
		return ..()

	var/wizards_alive = 0
	var/traitors_alive = 0
	for(var/datum/mind/wizard in wizards)
		if(!istype(wizard.current,/mob/living/carbon))
			continue
		if(wizard.current.stat==2)
			continue
		wizards_alive++

	if(!wizards_alive)
		for(var/datum/mind/traitor in traitors)
			if(!istype(traitor.current,/mob/living/carbon))
				continue
			if(traitor.current.stat==2)
				continue
			traitors_alive++

	if (wizards_alive || traitors_alive)
		return ..()
	else
		finished = 1
		return 1



/datum/game_mode/wizard/declare_completion()
	if(finished)
		world << "<span class='warning'><FONT size = 3><B>[(wizards.len>1)?"??????????":"?????????"] ??? ???? ??????????! ????????&#255; ??????????? ??????????? ?? ????? ??????? ???? ????.</B></FONT></span>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_wizard()
	if(wizards.len)
		var/text = "<br><font size=3><b>[(wizards.len>1)?"???????????? ????":"??????????? ???"]:</b></font>"

		for(var/datum/mind/wizard in wizards)

			text += "<br><b>[wizard.key]</b> ??? <b>[wizard.name]</b> ("
			if(wizard.current)
				if(wizard.current.stat == DEAD)
					text += "?????"
				else
					text += "?????"
				if(wizard.current.real_name != wizard.name)
					text += " ??? <b>[wizard.current.real_name]</b>"
			else
				text += "???? ??????????"
			text += ")"

			var/count = 1
			var/wizardwin = 1
			for(var/datum/objective/objective in wizard.objectives)
				if(objective.check_completion())
					text += "<br><B>??????? #[count]</B>: [objective.explanation_text] <font color='green'><B>?????!</B></font>"
				else
					text += "<br><B>??????? #[count]</B>: [objective.explanation_text] <font color='red'>??????.</font>"
					wizardwin = 0
				count++

			if(wizard.current && wizard.current.stat!=2 && wizardwin)
				text += "<br><font color='green'><B>????????? ???????? ??? ???? ??????&#255;!</B></font>"
			else
				text += "<br><font color='red'><B>????????? ???????? ???? ??? ????????? ?? ????? ???????!</B></font>"
			if(wizard.spell_list.len>0)
				text += "<br><B>[wizard.name] ??????????? ????? ?????????&#255;: </B>"
				var/i = 1
				for(var/obj/effect/proc_holder/spell/S in wizard.spell_list)
					text += "[S.name]"
					if(wizard.spell_list.len > i)
						text += ", "
					i++
			text += "<br>"

		world << text
	return 1

//OTHER PROCS

//To batch-remove wizard spells. Linked to mind.dm.
/mob/proc/spellremove(var/mob/M as mob)
	if(!mind)
		return
	for(var/obj/effect/proc_holder/spell/spell_to_remove in src.mind.spell_list)
		qdel(spell_to_remove)
		mind.spell_list -= spell_to_remove

/*Checks if the wizard can cast spells.
Made a proc so this is not repeated 14 (or more) times.*/
/mob/proc/casting()
//Removed the stat check because not all spells require clothing now

	if(ishuman(src))
		var/mob/living/carbon/human/H = src

		if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
			usr << "&#255; ???????? ???&#255; ???????????? ??????? ??? ???? ????????? ????."
			return 0
		if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
			usr << "&#255; ???????? ???&#255; ???????????? ??????? ??? ???? ????????? ????????."
			return 0
		if(!istype(H.head, /obj/item/clothing/head/wizard))
			usr << "&#255; ???????? ???&#255; ???????????? ??????? ??? ???? ????????? ??&#255;??."
			return 0
		else
			return 1
	return 0
