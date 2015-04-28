/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)	return

	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			usr << "<span class='warning'>You cannot pray (muted).</span>"
			return
		if(src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	log_admin("PRAY: [key_name(src)]: [msg]")

	var/image/cross = image('icons/obj/storage.dmi',"bible")
	msg = "<span class='info'>\icon[cross] <b><font color=purple>PRAY: </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>):</b> [msg]</span>"

	for(var/client/C in admins)
		if(C.prefs.toggles & CHAT_PRAYER)
			C << msg
	usr << "Your prayers have been received by the gods."
