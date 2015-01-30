/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisibility = INVISIBILITY_OBSERVER

	pass_flags = PASSBLOB
	factions = list("blob")

	var/obj/effect/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100

/mob/camera/blob/New()
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	..()

/mob/camera/blob/Login()
	..()
	sync_mind()
	src << "<span class='notice'>�� ������ �������!</span>"
	src << "��� ������� �� ������ ������&#255;�� &#255;���� �����. ������ �� ������ ������&#255;���&#255;, ����� ������� ���&#255;� � ������� ����� �����, �����  ���..."
	src << "<b>Normal Blob</b>: &#255;��&#255;���&#255; ����������� ������, ������� ������� ��������� �������."
	src << "<b>Shield Blob</b>: ����� ����������&#255; � ������&#255; �����&#255; �������� �����, ������&#255; ���������� � ����� ����������� ������. ������� ������ �����������-������������. "
	src << "<b>Resource Blob</b>: ������ ��� �����, ������� ����� ������ ��� ���� �� ���������, ��������� � ����� ������ ������� �����, ����� �������� ���������� ������ ��������.  ����� ������� ������������, ���� ��������� ����� &#255;��� ��� �����; � �������� ��������� ���� �� ����� ����������� ��������."
	src << "<b>Node Blob</b>: ��� �� ��� � &#255;���, ��� �������&#255;, �� �� ���� ��������� �������� � ��������. ����������� ���, ��� �������������� ���������������� ���������� ������ � � ��&#255;��� � ���������� �������.."
	src << "<b>Factory Blob</b>: ����, ������� ����� ��������� �����, ������� �����  �������� &#255;��� � ��������� ����� �������� �����. ��� �� ��� � ��������� ����, ������ ��������&#255; ����� &#255;��� ��� ����, ����� ��������� ������� ������������ ����; � �������� ��� �� ����� ��������."
	src << "<b>������:</b> CTRL Click = ������� Normal Blob / Middle Mouse Click = ������� ����� / Alt Click = ������� Shield Blob"
	update_health()

/mob/camera/blob/proc/update_health()
	if(blob_core)
		hud_used.blobhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#e36600'>[blob_core.health]</font></div>"

/mob/camera/blob/proc/add_points(var/points)
	if(points != 0)
		blob_points = Clamp(blob_points + points, 0, max_blob_points)
		hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#82ed00'>[src.blob_points]</font></div>"

/mob/camera/blob/say(var/message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	blob_talk(message)

/mob/camera/blob/proc/blob_talk(message)
	log_say("[key_name(src)] : [message]")

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	var/message_a = say_quote(message)
	var/rendered = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i></font>"

	for (var/mob/M in mob_list)
		if(isovermind(M) || isobserver(M))
			M.show_message(rendered, 2)

/mob/camera/blob/emote(var/act,var/m_type=1,var/message = null)
	return

/mob/camera/blob/blob_act()
	return

/mob/camera/blob/Stat()

	statpanel("Status")
	..()
	if (client.statpanel == "Status")
		if(blob_core)
			stat(null, "Core Health: [blob_core.health]")
		stat(null, "Power Stored: [blob_points]/[max_blob_points]")
	return

/mob/camera/blob/Move(var/NewLoc, var/Dir = 0)
	var/obj/effect/blob/B = locate() in range("3x3", NewLoc)
	if(B)
		loc = NewLoc
	else
		return 0


