/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(!mob)	return

	msg = strip_html_properly(sanitize(msg))
	if(!msg)	return

	if(!(prefs.toggles & CHAT_OOC))
		src << "<span class='warning'>You have OOC muted.</span>"
		return

	if(!holder)
		if(!ooc_allowed)
			src << "<span class='warning'>OOC is globally muted</span>"
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			usr << "<span class='warning'>OOC for dead mobs has been turned off.</span>"
			return
		if(prefs.muted & MUTE_OOC)
			src << "<span class='warning'>You cannot use OOC (muted).</span>"
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			src << "<B>Advertising other servers is not allowed.</B>"
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	log_ooc("[mob.name]/[key] : [msg]")

	var/keyname = key

	for(var/client/C in clients)
		if(C.prefs.toggles & CHAT_OOC)
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						C << "<font color=[config.allow_admin_ooccolor ? prefs.ooccolor :"#b82e00" ]><b><span class='prefix'>OOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></b></font>"
					else
						C << "<span class='adminobserverooc'><span class='prefix'>OOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></span>"
				else
					C << "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message'>[msg]</span></span></font>"
			else
				C << "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[keyname]:</EM> <span class='message'>[msg]</span></span></font>"

/proc/toggle_ooc()
	ooc_allowed = !( ooc_allowed )
	if (ooc_allowed)
		world << "<B>The OOC channel has been globally enabled!</B>"
	else
		world << "<B>The OOC channel has been globally disabled!</B>"

/proc/auto_toggle_ooc(var/on)
	if(!config.ooc_during_round && ooc_allowed != on)
		toggle_ooc()

var/global/normal_ooc_colour = "#002eb8"

/client/proc/set_ooc(newColor as color)
	set name = "Set Player OOC Colour"
	set desc = "Set to yellow for eye burning goodness."
	set category = "Fun"
	normal_ooc_colour = newColor

/client/verb/colorooc()
	set name = "OOC Text Color"
	set category = "Preferences"

	if(!holder || check_rights_for(src, R_ADMIN))
		return

	var/new_ooccolor = input(src, "Please select your OOC colour.", "OOC colour", prefs.ooccolor) as color|null
	if(new_ooccolor)
		prefs.ooccolor = sanitize_ooccolor(new_ooccolor)
		prefs.save_preferences()
	return

//Checks admin notice
/client/verb/admin_notice()
	set name = "Adminnotice"
	set category = "Admin"
	set desc ="Check the admin notice if it has been set"

	if(admin_notice)
		src << "<span class='info'><b>Admin Notice:</b>\n \t [admin_notice]</span>"
	else
		src << "<span class='info'>There are no admin notices at the moment.</span>"

/client/verb/motd()
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"

	if(join_motd)
		src << "<div class=\"motd\">[join_motd]</div>"
	else
		src << "<span class='info'>The Message of the Day has not been set.</span>"