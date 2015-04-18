/obj/item/weapon/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	m_amt = 2000
	w_class = 3.0
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = "gunshot"
	var/silenced = 0
	var/recoil = 0
	var/clumsy_check = 1
	var/obj/item/ammo_casing/chambered = null
	var/trigger_guard = 1
	var/proj_num = 0

	var/list/upgrades = list()

/obj/item/weapon/gun/proc/process_chamber()
	return 0

/obj/item/weapon/gun/proc/special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
	return 1

/obj/item/weapon/gun/proc/shoot_with_empty_chamber(mob/living/user as mob|obj)
	user << "<span class='warning'>*click*</span>"
	playsound(user, 'sound/weapons/emptyclick.ogg', 40, 1)
	return

/obj/item/weapon/gun/proc/shoot_live_shot(mob/living/user as mob|obj, var/pointblank = 0, var/mob/pbtarget = null, atom/ftarget = null)
	if(recoil)
		spawn()
			shake_camera(user, recoil + 1, recoil)

	if(silenced)
		playsound(user, fire_sound, 10, 1)
	else
		playsound(user, fire_sound, 50, 1)
		if(pointblank)
			user.visible_message("<span class='danger'>[user] fires [src] point blank at [pbtarget]!</span>", "<span class='danger'>You fire [src] point blank at [pbtarget]!</span>", "You hear a [istype(src, /obj/item/weapon/gun/energy) ? "laser blast" : "gunshot"]!")
		else
			user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear a [istype(src, /obj/item/weapon/gun/energy) ? "laser blast" : "gunshot"]!")
			var/from = "[user.loc.x],[user.loc.y],[user.loc.z]"
			var/dest = ""
			if (ftarget && isnull(ftarget.gc_destroyed))
				dest = "[ftarget.loc.x],[ftarget.loc.y],[ftarget.loc.z]"
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has firing from [src] with [src.chambered.projectile_type] from tile ([from]) at ([dest])</font>")
			log_attack("<font color='red'>[user]([user.key]) firing from [src] with [src.chambered.projectile_type] from tile ([from]) at ([dest])(Gun: \ref[src]; Num:[proj_num])</font>")
			proj_num++

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params)//TODO: go over this
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(istype(target, /mob/) && target != user && !(target in user.contents)) //We make sure that it is a mob, it's not us or part of us.
			if(user.a_intent == "harm") //Flogging action
				return
		else
			return

	//Exclude lasertag guns from the CLUMSY check.
	if(clumsy_check)
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if (M.has_organic_effect(/datum/organic_effect/clumsy) && prob(40))
				M << "<span class='danger'>You shoot yourself in the foot with \the [src]!</span>"
				afterattack(user, user)
				M.drop_item()
				return

	if (!user.IsAdvancedToolUser())
		user << "<span class='notice'>You don't have the dexterity to do this!</span>"
		return

	if(trigger_guard)
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if (M.has_organic_effect(/datum/organic_effect/hulk))
				M << "<span class='notice'>Your meaty finger is much too large for the trigger guard!</span>"
				return
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.dna && H.dna.mutantrace == "adamantine")
				user << "<span class='notice'>Your metal fingers don't fit in the trigger guard!</span>"
				return

	add_fingerprint(user)

	if(!special_check(user))
		return
	if(chambered)
		if(!chambered.fire(target, user, params, , silenced, "\ref[src]", proj_num))
			shoot_with_empty_chamber(user)
		else
			if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
				shoot_live_shot(user, 1, target)
			else
				shoot_live_shot(user, 0, null, target)
	else
		shoot_with_empty_chamber(user)
	process_chamber()
	update_icon()

	user.update_inv_hands(0)

/obj/item/weapon/gun/attack(mob/M as mob, mob/user)
	if(user.a_intent == "harm") //Flogging
		..()
	else
		return