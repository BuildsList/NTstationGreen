/obj/item/weapon/holosign_creator
	name = "holographic sign projector"
	desc = "A handy-dandy projector that displays a janitorial sign."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "signmaker"
	item_state = "electronic"
	force = 5
	w_class = 2
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	origin_tech = "programming=3"
	var/list/signs = list()
	var/max_signs = 10

/obj/item/weapon/holosign_creator/afterattack(atom/target, mob/user, flag)
	if(flag)
		var/turf/T = get_turf(target)
		var/obj/effect/overlay/holograph/H = locate() in T
		if(istype(target, /obj/structure/janitorialcart))	return
		if(istype(target, /obj/item/weapon/storage)) 		return
		else if(H)
			user << "<span class='notice'>You use [src] to destroy [H].</span>"
			qdel(H)
		else
			if(signs.len < max_signs)
				H = new(get_turf(target))
				signs += H
				user << "<span class='notice'>You create \a [H] with [src].</span>"
			else
				user << "<span class='notice'>[src] is projecting at max capacity!</span>"

/obj/item/weapon/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/weapon/holosign_creator/attack_self(mob/user)
	if(signs.len)
		var/list/L = signs.Copy()
		for(var/sign in L)
			qdel(sign)
			signs -= sign
		user << "<span class='notice'>You clear all active holograms.</span>"


/obj/effect/overlay/holograph
	name = "wet floor sign"
	desc = "The words flicker as if they mean nothing."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "holosign"
	anchored = 1


/obj/item/weapon/caution	//Old lame signs
	name = "wet floor sign"
	desc = "Caution! Wet Floor!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = 2
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/weapon/caution/cone
	name = "warning cone"
	desc = "This cone is trying to warn you of something!"
	icon_state = "cone"