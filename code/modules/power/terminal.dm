// the underfloor wiring terminal for the APC
// autogenerated when an APC is placed
// all conduit connects go to this object instead of the APC
// using this solves the problem of having the APC in a wall yet also inside an area

/obj/machinery/power/terminal
	name = "terminal"
	icon_state = "term"
	desc = "It's an underfloor wiring terminal for power equipment."
	level = 1
	layer = TURF_LAYER
	var/obj/machinery/power/master = null
	anchored = 1
	directwired = 0		// must have a cable on same turf connecting to terminal
	layer = 2.6 // a bit above wires


/obj/machinery/power/terminal/New()
	..()
	var/turf/T = src.loc
	if(level == 1)
		hide(T.intact)

/obj/machinery/power/terminal/Destroy()
	if(master)
		master.disconnect_terminal()
	return ..()

/obj/machinery/power/terminal/hide(var/i)
	if(i)
		invisibility = 101
		icon_state = "term-f"
	else
		invisibility = 0
		icon_state = "term"

/obj/machinery/power/terminal/attackby(var/obj/item/weapon/W, var/mob/user)
	if(!istype(W, /obj/item/weapon/crowbar))
		return ..()
	user.visible_message("<span class='warning'>[user.name] starts removing [src].</span>", "<span class='notice'>You start removing [src].</span>")
	if(!do_after(user, 20))	return
	user.visible_message("<span class='warning'>[user.name] removed [src].</span>", "<span class='notice'>You successfully removed [src].</span>")

	new /obj/item/stack/cable_coil(src.loc, 5)
	new /obj/item/stack/sheet/metal(src.loc, 2)

	del(src)