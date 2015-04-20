/obj/item/device/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices."
	icon_state = "signaller"
	item_state = "signaler"
	m_amt = 400
	g_amt = 120
	origin_tech = "magnets=1"
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE

	secured = 1

	var/code = 30
	var/frequency = 1457
	var/delay = 0
	var/datum/wires/connected = null
	var/tmp/datum/radio_frequency/radio_connection

	New()
		..()
		spawn(40)
			set_frequency(frequency)
		return


	activate(var/source = "*No Source*", var/usr_name = "*No mob*")
		if(cooldown > 0)	return 0
		cooldown = 2
		spawn(10)
			process_cooldown()

		signal(source ,usr_name)
		return 1

	update_icon()
		if(holder)
			holder.update_icon()
		return

	interact(mob/user as mob, flag1)
		var/t1 = "-------"
//		if ((src.b_stat && !( flag1 )))
//			t1 = text("-------<BR>\nGreen Wire: []<BR>\nRed Wire:   []<BR>\nBlue Wire:  []<BR>\n", (src.wires & 4 ? text("<A href='?src=\ref[];wires=4'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=4'>Mend Wire</A>", src)), (src.wires & 2 ? text("<A href='?src=\ref[];wires=2'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=2'>Mend Wire</A>", src)), (src.wires & 1 ? text("<A href='?src=\ref[];wires=1'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=1'>Mend Wire</A>", src)))
//		else
//			t1 = "-------"	Speaker: [src.listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
		var/dat = {"
	<TT>

	<A href='byond://?src=\ref[src];send=1'>Send Signal</A><BR>
	<B>Frequency/Code</B> for signaler:<BR>
	Frequency:
	<A href='byond://?src=\ref[src];freq=-10'>-</A>
	<A href='byond://?src=\ref[src];freq=-2'>-</A>
	[format_frequency(src.frequency)]
	<A href='byond://?src=\ref[src];freq=2'>+</A>
	<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

	Code:
	<A href='byond://?src=\ref[src];code=-5'>-</A>
	<A href='byond://?src=\ref[src];code=-1'>-</A>
	[src.code]
	<A href='byond://?src=\ref[src];code=1'>+</A>
	<A href='byond://?src=\ref[src];code=5'>+</A><BR>
	[t1]
	</TT>"}
		user << browse(dat, "window=radio")
		onclose(user, "radio")
		return


	Topic(href, href_list)
		..()

		if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			usr << browse(null, "window=radio")
			onclose(usr, "radio")
			return

		if (href_list["freq"])
			var/new_frequency = (frequency + text2num(href_list["freq"]))
			if(new_frequency < 1200 || new_frequency > 1600)
				new_frequency = sanitize_frequency(new_frequency)
			set_frequency(new_frequency)

		if(href_list["code"])
			src.code += text2num(href_list["code"])
			src.code = round(src.code)
			src.code = min(100, src.code)
			src.code = max(1, src.code)

		if(href_list["send"])
			spawn( 0 )
				signal("Player","[usr.name]([usr.key])")

		if(usr)
			attack_self(usr)

		return


	proc/signal(var/source = "*No Source*", var/usr_name = "*No mob*")
		if(!radio_connection) return

		var/datum/signal/signal = new
		signal.source = src
		signal.encryption = code
		signal.data["message"] = "ACTIVATE"
		signal.send_by = usr_name
		signal.start_source = source
		radio_connection.post_signal(src, signal)

		var/time = time2text(world.realtime,"hh:mm:ss")
		var/turf/T = get_turf(src)
		lastsignalers.Add("[time] <B>:</B> [usr_name] used [src](Activate By: [source]) @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")
		log_game("[usr_name] used [src](Activate By: [source]) @ location ([T.x],[T.y],[T.z]) : [format_frequency(frequency)]/[code]")

		return
/*
		for(var/obj/item/device/assembly/signaler/S in world)
			if(!S)	continue
			if(S == src)	continue
			if((S.frequency == src.frequency) && (S.code == src.code))
				spawn(0)
					if(S)	S.pulse(0)
		return 0*/


	pulse(var/radio = 0, var/source = "*No Source*", var/usr_name = "*No mob*")
		if(src.connected && src.wires)
			connected.Pulse(src)
		else
			return ..(radio,source,usr_name)


	receive_signal(datum/signal/signal)
		if(!signal)	return 0
		if(signal.encryption != code)	return 0
		if(!(src.wires & WIRE_RADIO_RECEIVE))	return 0
		pulse(1,signal.start_source,signal.send_by)
		for(var/mob/O in hearers(1, src.loc))
			O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		return


	proc/set_frequency(new_frequency)
		if(!radio_controller)
			sleep(20)
		if(!radio_controller)
			return
		radio_controller.remove_object(src, frequency)
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)
		return

// Embedded signaller used in grenade construction.
// It's necessary because the signaler doens't have an off state.
// Generated during grenade construction.  -Sayu
/obj/item/device/assembly/signaler/reciever
	var/on = 0

	proc/toggle_safety()
		on = !on

	activate()
		toggle_safety()
		return 1

	describe()
		return "The radio reciever is [on?"on":"off"]."

	receive_signal(datum/signal/signal)
		if(!on) return
		return ..(signal)


// Embedded signaller used in anomalies.
/obj/item/device/assembly/signaler/anomaly
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "anomaly core"
	item_state = "electronic"

/obj/item/device/assembly/signaler/anomaly/receive_signal(datum/signal/signal)
	..()
	for(var/obj/effect/anomaly/A in orange(0, src))
		A.anomalyNeutralize()

/obj/item/device/assembly/signaler/anomaly/attack_self()
	return