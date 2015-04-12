#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Arial Black"

//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

///////////////////////////////////////////////////////////////////////////////////////////////
// Brig Door control displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/September/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_timer_common
	name = "door timer"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(access_brig)
	anchored = 1.0    		// can't pick it up
	density = 0       		// can walk through it
	layer = 3.3
	var/id = null     		// id of door it controls.
	var/releasetime = 0		// when world.time reaches it - release the prisoneer
	var/timelength = 0		// the length of time this door will be set for
	var/timing = 1    		// boolean, true/1 timer is on, false/0 means it's not timing
	var/picture_state		// icon_state of alert picture, if not displaying text/numbers
	var/obj/item/weapon/card/id/prisoner_id = null

	maptext_height = 26
	maptext_width = 32

	New()
		..()

		pixel_x = ((src.dir & 3)? (0) : (src.dir == 4 ? 32 : -32))
		pixel_y = ((src.dir & 3)? (src.dir ==1 ? 32 : -32) : (0))
		update_icon()

//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
	process()
		if(stat & (NOPOWER|BROKEN))	return
		if(timing)
			if(world.time > src.releasetime)
				timing = 0
				timeset(0)
			src.updateUsrDialog()
			src.update_icon()
		return


// has the door power sitatuation changed, if so update icon.
	power_change()
		..()
		update_icon()
		return

	proc/timeleft()
		. = (timing ? (releasetime-world.time) : timelength)/10
		if(. < 0)
			. = 0

	proc/timeset(var/seconds)
		if(timing)
			releasetime=world.time+seconds*10
		else
			timelength=seconds*10
		return

//Allows AIs to use door_timer, see human attack_hand function below
	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)


//Allows humans to use door_timer
//Opens dialog window when someone clicks on door timer
// Allows altering timer and the timing boolean.
// Flasher activation limited to 150 seconds
	attack_hand(var/mob/user as mob)
		if(..())
			return
		var/second = round(timeleft() % 60)
		var/minute = round((timeleft() - second) / 60)
		user.set_machine(src)
		var/dat = "<HTML><BODY><TT>"
		dat += "<HR>Timer System:</hr>"
		dat += "<b>Door [src.id] controls</b><br/>"
		if (timing)
			dat += "<a href='?src=\ref[src];timing=0'>Stop Timer</a><br/>"
		else
			dat += "<a href='?src=\ref[src];timing=1'>Activate Timer</a><br/>"

		dat += "Time Left: [(minute ? text("[minute]:") : null)][second] <br/>"
		dat += "<a href='?src=\ref[src];tp=-60'>-</a> <a href='?src=\ref[src];tp=-1'>-</a> <a href='?src=\ref[src];tp=1'>+</a> <A href='?src=\ref[src];tp=60'>+</a><br/>"
		if(prisoner_id)
			dat += "<a href='?src=\ref[src];take_id=1'>Take ID ([prisoner_id.registered_name])</a><br>"
		else
			dat += "<a href='?src=\ref[src];insert_id=1'>Insert ID</a><br>"

		dat += "<br/><br/><a href='?src=\ref[user];mach_close=computer'>Close</a>"
		dat += "</TT></BODY></HTML>"
		user << browse(dat, "window=computer;size=400x500")
		onclose(user, "computer")
		return


//Function for using door_timer dialog input, checks if user has permission
// href_list to
//  "timing" turns on timer
//  "tp" value to modify timer
//  "fc" activates flasher
// Also updates dialog window and timer icon
	Topic(href, href_list)
		if(..())
			return
		if(!src.allowed(usr))
			return

		usr.set_machine(src)
		if(href_list["timing"]) //switch between timing and not timing
			if(prisoner_id)
				var/timeleft = timeleft()
				timeleft = min(max(round(timeleft), 0), 6000)
				timing = text2num(href_list["timing"])
				timeset(timeleft)
		else if(href_list["tp"]) //adjust timer
			var/timeleft = timeleft()
			var/tp = text2num(href_list["tp"])
			timeleft += tp
			timeleft = min(max(round(timeleft), 0), 6000)
			timeset(timeleft)
			//src.timing = 1
			//src.closedoor()
		else if(href_list["take_id"])
			if(prisoner_id)
				usr.put_in_hands(prisoner_id)
				prisoner_id = null
				timing = 0
				timeset(0)
				update_icon()
		else if(href_list["insert_id"])
			if(!prisoner_id)
				var/obj/item/weapon/card/id/id = usr.get_active_hand()
				if(istype(id))
					usr.drop_item()
					id.loc = src
					prisoner_id = id
					update_icon()

		src.add_fingerprint(usr)
		src.updateUsrDialog()
		src.update_icon()
		return


//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
	update_icon()
		if(stat & (NOPOWER))
			icon_state = "frame"
			return
		if(stat & (BROKEN))
			set_picture("ai_bsod")
			return
		if(timing)
			if(!prisoner_id)
				timing = 0
				timeset(0)
				maptext = ""
			var/disp1 = "[copytext(prisoner_id.registered_name, 1, 7)].."
			var/timeleft = timeleft()
			var/disp2 = "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
			if(length(disp2) > CHARS_PER_LINE)
				disp2 = "Error"
			update_display(disp1, disp2)
		else
			if(prisoner_id)
				update_display("Prisoner", "Released")
			else if(maptext)
				maptext = ""
		return


// Adds an icon in case the screen is broken/off, stolen from status_display.dm
	proc/set_picture(var/state)
		if(maptext)	maptext = ""
		picture_state = state
		overlays.Cut()
		overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)


//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
	proc/update_display(line1, line2)
		var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
		if(maptext != new_text)
			maptext = new_text


/obj/machinery/door_timer_common/north
	name = "Common Timer"
	dir = 1
	pixel_y = 32

/obj/machinery/door_timer_common/west
	name = "Common Timer"
	dir = 8
	pixel_x = -32

#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef CHARS_PER_LINE
