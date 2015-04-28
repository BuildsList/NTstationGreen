/mob/dead/observer/Login()
	..()
	if(!client)
		return
	if(!client.prefs)
		return
	icon_state = client.prefs.ghost_form
	update_interface()