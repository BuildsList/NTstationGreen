/obj/item/device/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustable substances."
	icon_state = "igniter"
	m_amt = 500
	g_amt = 50
	origin_tech = "magnets=1"

	activate(var/source = "*No Source*", var/usr_name = "*No mob*")
		if(!..())	return 0//Cooldown check
		var/turf/location = get_turf(loc)
		if(location)	location.hotspot_expose(1000,1000)
		return 1


	attack_self(mob/user as mob)
		activate("Player","[user.name]([user.key])")
		add_fingerprint(user)
		return