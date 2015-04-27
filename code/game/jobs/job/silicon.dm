/*
AI
*/
/datum/job/ai
	title = "AI"
	r_title = "������������� ���������"
	flag = AI
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	r_supervisors = "����� �������"
	req_admin_notify = 1

/datum/job/ai/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0

/*
Cyborg
*/
/datum/job/cyborg
	title = "Cyborg"
	r_title = "������"
	flag = CYBORG
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	supervisors = "your laws and the AI"	//Nodrak
	r_supervisors = "����� ������� � ��"
	selection_color = "#ddffdd"

/datum/job/cyborg/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	return H.Robotize()
