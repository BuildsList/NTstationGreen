/datum/game_mode/traitor/double_agents
	name = "double agents"
	traitor_name = "double agent"
	rtraior_name = "??????? ?????"
	rtraior_endname = "???????? ????????"
	config_tag = "double_agents"
	restricted_jobs = list("Security Officer", "Warden", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer") // Human / Minor roles only.
	required_players = 20
	required_enemies = 5
	recommended_enemies = 8

	traitor_name = "double agent"

	traitors_possible = 6 //hard limit on traitors if scaling is turned off
	scale_modifier = 0.75 // Nearly twice as many double agents

	var/list/target_list = list()
	var/list/late_joining_list = list()

/datum/game_mode/traitor/double_agents/announce()
	world << "<B>??????? ??????? ????? -  - ??????? ??????!</B>"
	world << "<B>?? ??????? ????????? ??????? ??????, ??????? ??????? ???? ?????! ?? ????? ?? ????????? ?? ????.</B>"

/datum/game_mode/traitor/double_agents/post_setup()
	var/i = 0
	for(var/datum/mind/traitor in traitors)
		i++
		if(i + 1 > traitors.len)
			i = 0
		target_list[traitor] = traitors[i + 1]
	..()

/datum/game_mode/traitor/double_agents/forge_traitor_objectives(var/datum/mind/traitor)

	if(target_list.len && target_list[traitor]) // Is a double agent

		// Assassinate
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = traitor
		kill_objective.target = target_list[traitor]
		kill_objective.explanation_text = "????? [kill_objective.target.current.real_name], [kill_objective.target.assigned_role]."
		traitor.objectives += kill_objective

		// Escape
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = traitor
		traitor.objectives += escape_objective

	else
		..() // Give them standard objectives.
	return

/datum/game_mode/traitor/double_agents/add_latejoin_traitor(var/datum/mind/character)

	check_potential_agents()

	// As soon as we get 3 or 4 extra latejoin traitors, make them traitors and kill each other.
	if(late_joining_list.len >= rand(3, 4))
		// True randomness
		shuffle(late_joining_list)
		// Reset the target_list, it'll be used again in force_traitor_objectives
		target_list = list()

		// Basically setting the target_list for who is killing who
		var/i = 0
		for(var/datum/mind/traitor in late_joining_list)
			i++
			if(i + 1 > late_joining_list.len)
				i = 0
			target_list[traitor] = late_joining_list[i + 1]
			traitor.special_role = traitor_name

		// Now, give them their targets
		for(var/datum/mind/traitor in target_list)
			..(traitor)

		late_joining_list = list()
	else
		late_joining_list += character
	return

/datum/game_mode/traitor/double_agents/proc/check_potential_agents()

	for(var/M in late_joining_list)
		if(istype(M, /datum/mind))
			var/datum/mind/agent_mind = M
			if(ishuman(agent_mind.current))
				var/mob/living/carbon/human/H = agent_mind.current
				if(H.stat != DEAD)
					if(H.client)
						continue // It all checks out.

		// If any check fails, remove them from our list
		late_joining_list -= M