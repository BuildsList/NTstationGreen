/mob/living/carbon/alien/larva/emote(var/act)

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	var/m_type = 1
	var/message

	switch(act) //Alphabetically sorted please.
		if ("burp")
			if (!muzzled)
				message = "<B>[src]</B> ������."
				m_type = 2
		if ("choke")
			message = "<B>[src]</B> ������&#255;."
			m_type = 2
		if ("collapse")
			Paralyse(2)
			message = "<B>[src]</B> ������&#255; � ���!"
			m_type = 2
		if ("dance")
			if (!src.restrained())
				message = "<B>[src]</B> ��������� ������� ������."
				m_type = 1
		if ("drool")
			message = "<B>[src]</B> ������� �����."
			m_type = 1
		if ("gasp")
			message = "<B>[src]</B> ���������&#255;."
			m_type = 2
		if ("gnarl")
			if (!muzzled)
				message = "<B>[src]</B> gnarls and shows its teeth.."
				m_type = 2
		if ("hiss")
			message = "<B>[src]</B> �&#255;��� �����."
			m_type = 1
		if ("jump")
			message = "<B>[src]</B> �������!"
			m_type = 1
		if ("moan")
			message = "<B>[src]</B> ������!"
			m_type = 2
		if ("nod")
			message = "<B>[src]</B> ������ ����� �������."
			m_type = 1
//		if ("roar")
//			if (!muzzled)
//				message = "<B>[src]</B> roars." Commenting out since larva shouldn't roar /N
//				m_type = 2
		if ("roll")
			if (!src.restrained())
				message = "<B>[src]</B> ����������&#255;."
				m_type = 1
		if ("scratch")
			if (!src.restrained())
				message = "<B>[src]</B> ���������&#255;."
				m_type = 1
		if ("scretch")
			if (!muzzled)
				message = "<B>[src]</B> ���������&#255;."
				m_type = 2
		if ("shake")
			message = "<B>[src]</B> ������ ����� �������."
			m_type = 1
		if ("shiver")
			message = "<B>[src]</B> ��&#255;����&#255;."
			m_type = 2
		if ("sign")
			if (!src.restrained())
				message = text("<B>�����</B> ����������[].", (text2num(param) ? text(" ����� []", text2num(param)) : null))
				m_type = 1
//		if ("sit")
//			message = "<B>[src]</B> sits down." //Larvan can't sit down, /N
//			m_type = 1
		if ("sulk")
			message = "<B>[src]</B> ������ �������&#255;."
			m_type = 1
		if ("sway")
			message = "<B>[src]</B> ����������������� �������&#255;."
			m_type = 1
		if ("tail")
			message = "<B>[src]</B> ��&#255;��� �������."
			m_type = 1
		if ("twitch")
			message = "<B>[src]</B> &#255;������ ��������&#255;."
			m_type = 1
		if ("whimper")
			if (!muzzled)
				message = "<B>[src]</B> ������."
				m_type = 2

		if ("help") //"The exception"
			src << "Help for larva emotes. You can use these emotes with say \"*emote\":\n\nburp, choke, collapse, dance, drool, gasp, gnarl, hiss, jump, moan, nod, roll, scratch,\nscretch, shake, shiver, sign-#, sulk, sway, tail, twitch, whimper"

		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."
	if ((message && src.stat == 0))
		log_emote("[name]/[key] : [message]")
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)
	return