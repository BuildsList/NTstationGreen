/obj/item/stack/tile/plasteel
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon"
	icon_state = "tile"
	w_class = 3.0
	m_amt = 937.5
	force = 5
	throwforce = 7
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60

/obj/item/stack/tile/plasteel/cyborg
	desc = "The ground you walk on" //Not the usual floor tile desc as that refers to throwing, Cyborgs can't do that - RR
	m_amt = 0 // All other Borg versions of items have no Metal or Glass - RR
	max_amount = 50

/obj/item/stack/tile/plasteel/New(var/loc, var/amount=null)
	..()
	src.pixel_x = rand(1, 14)
	src.pixel_y = rand(1, 14)
	return

/obj/item/stack/tile/plasteel/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(amount < 4)
			user << "<span class='warning'>You need at least four tiles to do this.</span>"
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			new_item.add_to_stacks(usr)
			for (var/mob/M in viewers(src))
				M.show_message("<span class='warning'>[src] is shaped into metal by [user.name] with the weldingtool.</span>", 3, "<span class='warning'>You hear welding.</span>", 2)
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(4)
			if (!R && replace)
				user.put_in_hands(new_item)
		return
	..()

/*
/obj/item/stack/tile/plasteel/attack_self(mob/user as mob)
	if (usr.stat)
		return
	var/T = user.loc
	if (!( istype(T, /turf) ))
		user << "<span class='warning'>You must be on the ground!</span>"
		return
	if (!( istype(T, /turf/space) ))
		user << "<span class='warning'>You cannot build on or repair this turf!</span>"
		return
	src.build(T)
	src.add_fingerprint(user)
	use(1)
	return
*/

/obj/item/stack/tile/plasteel/proc/build(turf/S as turf)
	S.ChangeTurf(/turf/simulated/floor/plating)
//	var/turf/simulated/floor/W = S.ReplaceWithFloor()
//	W.make_plating()
	return



