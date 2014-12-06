//This only assumes that the mob has a body and face with at least one mouth.
//Things like airguitar can be done without arms, and the flap thing makes so little sense it's a keeper.
//Intended to be called by a higher up emote proc if the requested emote isn't in the custom emotes.

/mob/living/emote(var/act,var/m_type=1,var/message = null)
	var/param = null

	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	switch(act)//Hello, how would you like to order? Alphabetically!
		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> ЗЛОСТНО хлопает крыль&#255;ми!"
				m_type = 2

		if ("blush")
			message = "<B>[src]</B> краснеет."
			m_type = 1

		if ("bow")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(1, src))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null
				if (param)
					message = "<B>[src]</B> кланитс&#255; дл&#255; [param]."
				else
					message = "<B>[src]</B> кланитс&#255;."
			m_type = 1

		if ("burp")
			message = "<B>[src]</B> рыгает."
			m_type = 2

		if ("choke")
			message = "<B>[src]</B> давитс&#255;!"
			m_type = 2

		if ("chuckle")
			message = "<B>[src]</B> хихикает."
			m_type = 2

		if ("collapse")
			Paralyse(2)
			message = "<B>[src]</B> падает!"
			m_type = 2

		if ("cough")
			message = "<B>[src]</B> задыхаетс&#255;!"
			m_type = 2

		if ("dance")
			if (!src.restrained())
				message = "<B>[src]</B> радостно танцует вокруг."
				m_type = 1

		if ("deathgasp")
			message = "<B>[src]</B> seizes up and falls limp, its eyes dead and lifeless..."
			m_type = 1

		if ("drool")
			message = "<B>[src]</B> пускает слюни."
			m_type = 1

		if ("faint")
			message = "<B>[src]</B> падает в обморок."
			if(src.sleeping)
				return //Can't faint while asleep
			src.sleeping += 10 //Short-short nap
			m_type = 1

		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> хлопает крыль&#255;ми."
				m_type = 2

		if ("flipoff")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(1, src))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null
				if (param)
					message = "<B>[src]</B> поворачивает птицу на [param]!"
				else
					message = "<B>[src]</B> переворачивает птицу."
			m_type = 1

		if ("frown")
			message = "<B>[src]</B> хмуритс&#255;."
			m_type = 1

		if ("gasp")
			message = "<B>[src]</B> задыхаетс&#255;!"
			m_type = 2

		if ("giggle")
			message = "<B>[src]</B> хихикает."
			m_type = 2

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null
			if (param)
				message = "<B>[src]</B> свирепо смотрит на [param]."
			else
				message = "<B>[src]</B> свирепо смотрит."

		if ("grin")
			message = "<B>[src]</B> скалитс&#255;."
			m_type = 1

		if ("jump")
			message = "<B>[src]</B> прыгает!"
			m_type = 1

		if ("laugh")
			message = "<B>[src]</B> смеетс&#255;."
			m_type = 2

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null
			if (param)
				message = "<B>[src]</B> смотрит на [param]."
			else
				message = "<B>[src]</B> смотрит."
			m_type = 1

		if ("me")
			if (src.client)
				if(client.prefs.muted & MUTE_IC)
					src << "You cannot send IC messages (muted)."
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			else
				message = "<B>[src]</B> [message]"

		if ("nod")
			message = "<B>[src]</B> кивает."
			m_type = 1

		if ("point")
			if (!src.restrained())
				var/mob/M = null
				if (param)
					for (var/atom/A as mob|obj|turf|area in view(1, src))
						if (param == A.name)
							M = A
							break
				if (!M)
					message = "<B>[src]</B> показывает."
				else
					M.point()
				if (M)
					message = "<B>[src]</B> показывает на [M]."
				else
			m_type = 1

		if ("pout")
			message = "<B>[src]</B> дуетс&#255;."
			m_type = 1

		if ("rude")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(1, src))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null
				if (param)
					message = "<B>[src]</B> делает неприличный жест дл&#255; [param]!"
				else
					message = "<B>[src]</B> делает неприличный жест."
			m_type = 1

		if ("scream")
			message = "<B>[src]</B> кричит!"
			m_type = 2

		if ("shake")
			message = "<B>[src]</B> тр&#255;сет своей головой."
			m_type = 1

		if ("sigh")
			message = "<B>[src]</B> вздыхает."
			m_type = 2

		if ("sit")
			message = "<B>[src]</B> садитс&#255;."
			m_type = 1

		if ("smile")
			message = "<B>[src]</B> улыбаетс&#255;."
			m_type = 1

		if ("smirk")
			message = "<B>[src]</B> ухмыл&#255;етс&#255;."
			m_type = 1

		if ("snap")
			message = "<B>[src]</B> щелкает пальцами."
			m_type = 2

		if ("sneeze")
			message = "<B>[src]</B> чихает."
			m_type = 2

		if ("sniff")
			message = "<B>[src]</B> шмыгает носом."
			m_type = 2

		if ("snore")
			message = "<B>[src]</B> сопит."
			m_type = 2

		if ("snort")
			message = "<B>[src]</B> фыркает."
			m_type = 2

		if ("spit")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(1, src))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null
				if (param)
					message = "<B>[src]</B> плюёт на [param]."
				else
					message = "<B>[src]</B> плюёт на пол."
			m_type = 1

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(1, src))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null
			if (param)
				message = "<B>[src]</B> п&#255;литс&#255; на [param]."
			else
				message = "<B>[src]</B> п&#255;литс&#255;."

		if ("sulk")
			message = "<B>[src]</B> кукситс&#255;."
			m_type = 1

		if ("sway")
			message = "<B>[src]</B> в&#255;ло пошатываетс&#255;."
			m_type = 1

		if ("tap")
			message = "<B>[src]</B> уныло потапывает ногой."
			m_type = 1

		if ("thumbsdown")
			message = "<B>[src]</B> показывает большой палец вниз."
			m_type = 1

		if ("thumbsup")
			message = "<B>[src]</B> показывает большой палец вверх!"
			m_type = 1

		if ("tremble")
			message = "<B>[src]</B> дрожит в страхе!"
			m_type = 1

		if ("twitch")
			message = "<B>[src]</B> &#255;ростно дергаетс&#255;."
			m_type = 1

		if ("twitch_s")
			message = "<B>[src]</B> дергаетс&#255;."
			m_type = 1

		if ("wave")
			message = "<B>[src]</B> машет рукой."
			m_type = 1

		if ("whimper")
			message = "<B>[src]</B> хнычет."
			m_type = 2

		if ("whistle")
			message = "<B>[src]</B> присвистывает."
			m_type = 2

		if ("whistle2")
			message = "<B>[src]</B> насвистывает мелодию."
			m_type = 2

		if ("yawn")
			message = "<B>[src]</B> зевает."
			m_type = 2

		if ("help")
			src << "Справка по эмоци&#255;м. Вы можете использовать эмоции через say: \"*emote\":\n\naflap, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough, dance, deathgasp, drool, flap, flipoff, frown, gasp, giggle, glare-(none)/mob, grin, jump, laugh, look, me, nod, point-atom, pout, rude, scream, shake, sit, sigh, smile, smirk, snap, sneeze, sniff, snore, snort, spit, stare-(none)/mob, sulk, sway, tap, thumbsup, thumbsdown, tremble, twitch, twitch_s, wave, whimper, whistle, whistle2 yawn"

		else
			src << "<span class='notice'> Неиспользуема&#255; эмоци&#255; '[act]'. Наберите *help дл&#255; полного списка.</span>"





	if (message)
		log_emote("[name]/[key] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)


		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src.loc, null))
				O.show_message(message, m_type)
