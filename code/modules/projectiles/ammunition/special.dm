/obj/item/ammo_casing/magic
	name = "magic casing"
	desc = "I didn't even know magic needed ammo..."
	projectile_type = /obj/item/projectile/magic

/obj/item/ammo_casing/magic/change
	projectile_type = /obj/item/projectile/magic/change

/obj/item/ammo_casing/magic/animate
	projectile_type = /obj/item/projectile/magic/animate

/obj/item/ammo_casing/magic/heal
	projectile_type = /obj/item/projectile/magic/resurrection

/obj/item/ammo_casing/magic/death
	projectile_type = /obj/item/projectile/magic/death

/obj/item/ammo_casing/magic/teleport
	projectile_type = /obj/item/projectile/magic/teleport

/obj/item/ammo_casing/magic/door
	projectile_type = /obj/item/projectile/magic/door

/obj/item/ammo_casing/magic/fireball
	projectile_type = /obj/item/projectile/magic/fireball

/obj/item/ammo_casing/magic/chaos
	projectile_type = /obj/item/projectile/magic

/obj/item/ammo_casing/magic/chaos/newshot()
	projectile_type = pick(typesof(/obj/item/projectile/magic))
	..()

/obj/item/ammo_casing/syringegun
	name = "syringe gun spring"
	desc = "A high-power spring that throws syringes."
	projectile_type = null


/obj/item/ammo_casing/energy/meteor
	projectile_type = null
	var/meteor_type = /obj/effect/meteor/medium
	select_name = "meteor"

/obj/item/ammo_casing/energy/meteor/throw_proj(var/turf/targloc, mob/living/user as mob|obj, params)
	if (!istype(get_turf(targloc), /turf) || !istype(get_turf(user), /turf))
		return 0
	var/obj/effect/meteor/M = new meteor_type(get_turf(user))
	M.dest = get_turf(targloc)
	spawn(0)
		walk_towards(M, M.dest, 1)
	return 1

/obj/item/ammo_casing/energy/meteor/ready_proj()
	return

/obj/item/ammo_casing/energy/meteor/big
	meteor_type = /obj/effect/meteor/big
	select_name = "big meteor"

/obj/item/ammo_casing/energy/meteor/plasma
	meteor_type = /obj/effect/meteor/flaming
	select_name = "plasma meteor"

/obj/item/ammo_casing/energy/meteor/irradiated
	meteor_type = /obj/effect/meteor/irradiated
	select_name = "radioactive meteor"

/obj/item/ammo_casing/energy/meteor/meaty
	meteor_type = /obj/effect/meteor/meaty
	select_name = "meaty ore"

/obj/item/ammo_casing/energy/meteor/meaty/xeno
	meteor_type = /obj/effect/meteor/meaty/xeno
	select_name = "xeno meaty ore"

/obj/item/ammo_casing/energy/meteor/dust
	meteor_type = /obj/effect/meteor/dust
	select_name = "space dust"