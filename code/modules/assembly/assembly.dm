/obj/item/device/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	flags = CONDUCT
	w_class = 2.0
	m_amt = 100
	g_amt = 0
	throwforce = 2
	throw_speed = 3
	throw_range = 7
	origin_tech = "magnets=1"

	var/secured = 1
	var/list/attached_overlays = null
	var/obj/item/device/assembly_holder/holder = null
	var/cooldown = 0//To prevent spam
	var/wires = WIRE_RECEIVE | WIRE_PULSE

	var/const/WIRE_RECEIVE = 1				//Allows Pulsed(0) to call Activate()
	var/const/WIRE_PULSE = 2				//Allows Pulse(0) to act on the holder
	var/const/WIRE_PULSE_SPECIAL = 4		//Allows Pulse(0) to act on the holders special assembly
	var/const/WIRE_RADIO_RECEIVE = 8		//Allows Pulsed(1) to call Activate()
	var/const/WIRE_RADIO_PULSE = 16			//Allows Pulse(1) to send a radio message

	proc/activate(var/source = "*No Source*", var/usr_name = "*No mob*")				//What the device does when turned on
		return

	proc/pulsed(var/radio = 0, var/source = "*No Source*", var/usr_name = "*No mob*")	//Called when another assembly acts on this one, var/radio will determine where it came from for wire calcs
		return

	proc/pulse(var/radio = 0, var/source = "*No Source*", var/usr_name = "*No mob*")	//Called when this device attempts to act on another device, var/radio determines if it was sent via radio or direct
		return

	proc/toggle_secure()																//Code that has to happen when the assembly is un\secured goes here
		return

	proc/attach_assembly(var/obj/A, var/mob/user)										//Called when an assembly is attacked by another
		return

	proc/process_cooldown()																//Called via spawn(10) to have it count down the cooldown var
		return

	proc/holder_movement()																//Called when the holder is moved
		return

	interact(mob/user as mob)															//Called when attack_self is called
		return

	proc/describe()																		// Called by grenades to describe the state of the trigger (time left, etc)
		return "The trigger assembly looks broken!"

	process_cooldown()
		cooldown--
		if(cooldown <= 0)	return 0
		spawn(10)
			process_cooldown()
		return 1


	pulsed(var/radio = 0, var/source = "*No Source*", var/usr_name = "*No mob*")
		if(holder && (wires & WIRE_RECEIVE))
			activate(source, usr_name)
		if(radio && (wires & WIRE_RADIO_RECEIVE))
			activate(source, usr_name)
		return 1


	pulse(var/radio = 0, var/source = "*No Source*", var/usr_name = "*No mob*")
		if(holder && (wires & WIRE_PULSE))
			holder.process_activation(src, 1, 0, source, usr_name)
		if(holder && (wires & WIRE_PULSE_SPECIAL))
			holder.process_activation(src, 0, 1, source, usr_name)

		if(istype(loc,/obj/item/weapon/grenade)) // This is a hack.  Todo: Manage this better -Sayu
			var/obj/item/weapon/grenade/G = loc
			G.prime() 							 // Adios, muchachos
//		if(radio && (wires & WIRE_RADIO_PULSE))
			//Not sure what goes here quite yet send signal?
		return 1


	activate(var/source = "*No Source*", var/usr_name = "*No mob*")
		if(!secured || (cooldown > 0))	return 0
		cooldown = 2
		spawn(10)
			process_cooldown()
		return 1


	toggle_secure()
		secured = !secured
		update_icon()
		return secured


	attach_assembly(var/obj/item/device/assembly/A, var/mob/user)
		holder = new/obj/item/device/assembly_holder(get_turf(src))
		if(holder.attach(A,src,user))
			user << "<span class='info'>You attach \the [A] to \the [src]!</span>"
			return 1
		return 0


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(isassembly(W))
			var/obj/item/device/assembly/A = W
			if((!A.secured) && (!secured))
				attach_assembly(A,user)
				return
		if(istype(W, /obj/item/weapon/screwdriver))
			if(toggle_secure())
				user << "<span class='info'>\The [src] is ready!</span>"
			else
				user << "<span class='info'>\The [src] can now be attached!</span>"
			return
		..()
		return


	process()
		processing_objects.Remove(src)
		return


	examine()
		set src in view()
		..()
		if((in_range(src, usr) || loc == usr))
			if(secured)
				usr << "\The [src] is ready!"
			else
				usr << "\The [src] can be attached!"
		return


	attack_self(mob/user as mob)
		if(!user)	return 0
		user.set_machine(src)
		interact(user)
		return 1


	interact(mob/user as mob)
		return //HTML MENU FOR WIRES GOES HERE



/*
	var/small_icon_state = null//If this obj will go inside the assembly use this for icons
	var/list/small_icon_state_overlays = null//Same here
	var/obj/holder = null
	var/cooldown = 0//To prevent spam

	proc
		Activate()//Called when this assembly is pulsed by another one
		Process_cooldown()//Call this via spawn(10) to have it count down the cooldown var
		Attach_Holder(var/obj/H, var/mob/user)//Called when an assembly holder attempts to attach, sets src's loc in here


	Activate()
		if(cooldown > 0)
			return 0
		cooldown = 2
		spawn(10)
			Process_cooldown()
		//Rest of code here
		return 0


	Process_cooldown()
		cooldown--
		if(cooldown <= 0)	return 0
		spawn(10)
			Process_cooldown()
		return 1


	Attach_Holder(var/obj/H, var/mob/user)
		if(!H)	return 0
		if(!H.IsAssemblyHolder())	return 0
		//Remember to have it set its loc somewhere in here


*/
