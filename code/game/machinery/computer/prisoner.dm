/obj/machinery/computer/prisoner
	name = "prisoner management console"
	icon = 'icons/obj/computer_old.dmi'
	icon_state = "explosive"
	req_access = list(access_brig)
	circuit = "/obj/item/weapon/circuitboard/prisoner"
	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed
	var/obj/item/weapon/card/id/prisoner/inserted_id
	circuit = /obj/item/weapon/circuitboard/prisoner

	attack_hand(var/mob/user as mob)
		if(..())
			return
		user.set_machine(src)
		var/dat = ""
		if(screen == 0)
			dat += "<HR><A href='?src=\ref[src];lock=1'>Unlock Console</A>"
		else if(screen == 1)
			dat += "<H3>Prisoner ID Management</H3>"
			if(istype(inserted_id))
				dat += text("<A href='?src=\ref[src];id=eject'>[inserted_id]</A><br>")
				dat += text("Collected Points: [inserted_id.points]. <A href='?src=\ref[src];id=reset'>Reset.</A><br>")
				dat += text("Card goal: [inserted_id.goal].  <A href='?src=\ref[src];id=setgoal'>Set </A><br>")
			else
				dat += text("<A href='?src=\ref[src];id=insert'>Insert Prisoner ID.</A><br>")
			dat += "<H3>Prisoner Implant Management</H3>"
			dat += "<HR>Chemical Implants<BR>"
			var/turf/Tr = null
			for(var/obj/item/weapon/implant/chem/C in world)
				if (!isnull(C.gc_destroyed)) continue
				Tr = get_turf(C)
				if((Tr) && (Tr.z != src.z))	continue//Out of range
				if(!C.implanted) continue
				dat += "[C.imp_in.name] | Remaining Units: [C.reagents.total_volume] | Inject: "
				dat += "<A href='?src=\ref[src];inject1=\ref[C]'>(<font class='bad'>(1)</font>)</A>"
				dat += "<A href='?src=\ref[src];inject5=\ref[C]'>(<font class='bad'>(5)</font>)</A>"
				dat += "<A href='?src=\ref[src];inject10=\ref[C]'>(<font class='bad'>(10)</font>)</A><BR>"
				dat += "********************************<BR>"
			dat += "<HR>Tracking Implants<BR>"
			for(var/obj/item/weapon/implant/tracking/T in world)
				if (!isnull(T.gc_destroyed))
					continue
				if(!iscarbon(T.imp_in))
					continue
				if(!T.implanted)
					continue
				Tr = get_turf(T)
				if((Tr) && (Tr.z != src.z))
					continue//Out of range

				var/loc_display = "Unknown"
				var/mob/living/carbon/M = T.imp_in
				if(Tr.z == 1 && !istype(M.loc, /turf/space))
					var/turf/mob_loc = get_turf(M)
					loc_display = mob_loc.loc

				dat += "ID: [T.id] | Location: [loc_display]<BR>"
				dat += "<A href='?src=\ref[src];warn=\ref[T]'>(<font class='bad'><i>Message Holder</i></font>)</A> |<BR>"
				dat += "********************************<BR>"
			dat += "<HR><A href='?src=\ref[src];lock=1'>Lock Console</A>"

		//user << browse(dat, "window=computer;size=400x500")
		//onclose(user, "computer")
		var/datum/browser/popup = new(user, "computer", "Prisoner Management Console", 400, 500)
		popup.set_content(dat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
		return

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I, /obj/item/weapon/card/id))
			return attack_hand(user)
		..()

	process()
		if(!..())
			src.updateDialog()
		return


	Topic(href, href_list)
		if(..())
			return
		if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
			usr.set_machine(src)

			if(href_list["id"])
				if(href_list["id"] =="insert" && !istype(inserted_id))
					var/obj/item/weapon/card/id/prisoner/I = usr.get_active_hand()
					if(istype(I))
						usr.drop_item()
						I.loc = src
						inserted_id = I
					else usr << "<span class='warning'>No valid ID.</span>"
				else if(istype(inserted_id))
					switch(href_list["id"])
						if("eject")
							inserted_id.loc = get_turf(src)
							inserted_id.verb_pickup()
							inserted_id = null
						if("reset")
							inserted_id.points = 0
						if("setgoal")
							var/num = round(input(usr, "Choose prisoner's goal:", "Input an Integer", null) as num|null)
							if(num >= 0)
								inserted_id.goal = num
			else if(href_list["inject1"])
				var/obj/item/weapon/implant/I = locate(href_list["inject1"])
				if(I)	I.activate(1)
			else if(href_list["inject5"])
				var/obj/item/weapon/implant/I = locate(href_list["inject5"])
				if(I)	I.activate(5)

			else if(href_list["inject10"])
				var/obj/item/weapon/implant/I = locate(href_list["inject10"])
				if(I)	I.activate(10)

			else if(href_list["lock"])
				if(src.allowed(usr))
					screen = !screen
				else
					usr << "Unauthorized Access."

			else if(href_list["warn"])
				var/warning = copytext(sanitize(input(usr,"Message:","Enter your message here!","")),1,MAX_MESSAGE_LEN)
				if(!warning) return
				var/obj/item/weapon/implant/I = locate(href_list["warn"])
				if((I)&&(I.imp_in))
					var/mob/living/carbon/R = I.imp_in
					R << "You hear a voice in your head saying: '[warning]'"
					log_say("[usr]/[usr.ckey] sent an implant message to [R]/[R.ckey]: '[warning]'")

			src.add_fingerprint(usr)
		src.updateUsrDialog()
		return


