/obj/item/weapon/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	var/mob/affecting = null
	var/deity_name = "Christ"
	interaction_sound = "pageturn"//bibles sound like paper when opening/dropping/picking up

/obj/item/weapon/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/weapon/storage/bible/booze/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)

/obj/item/weapon/storage/bible/proc/bless(mob/living/carbon/M as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/heal_amt = 10
		for(var/obj/item/organ/limb/affecting in H.organs)
			if(affecting.status == ORGAN_ORGANIC) //No Bible can heal a robotic arm!
				if(affecting.heal_damage(heal_amt, heal_amt, 0))
					H.update_damage_overlays(0)
	return

/obj/item/weapon/storage/bible/attack(mob/living/M as mob, mob/living/user as mob)

	var/chaplain = 0
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		chaplain = 1

	add_logs(user, M, "attacked", object="[src.name]")

	if (!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return
	if(!chaplain)
		user << "<span class='warning'>The book sizzles in your hands.</span>"
		user.take_organ_damage(0,10)
		return

	if (user.has_organic_effect(/datum/organic_effect/clumsy) && prob(50))
		user << "<span class='warning'>The [src] slips out of your hand and hits your head.</span>"
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

//	if(..() == BLOCKED)
//		return

	if (M.stat !=2)
	//	if(M.mind && (M.mind.assigned_role == "Chaplain"))
	//		user << "<span class='warning'>You can't heal yourself!</span>"
	//		return
		/*if((M.mind in ticker.mode.cult) && (prob(20)))
			M << "<span class='warning'>The power of [src.deity_name] clears your mind of heresy!</span>"
			user << "<span class='warning'>You see how [M]'s eyes become clear, the cult no longer holds control over him!</span>"
			ticker.mode.remove_cultist(M.mind)*/
		if ((istype(M, /mob/living/carbon/human) && prob(60)))
			bless(M)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/message_halt = 0
				for(var/obj/item/organ/limb/affecting in H.organs)
					if(affecting.status == ORGAN_ORGANIC)
						if(message_halt == 0)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("<span class='warning'><B>[] heals [] with the power of [src.deity_name]!</B></span>", user, M), 1)
							M << "<span class='warning'>May the power of [src.deity_name] compel you to be healed!</span>"
							playsound(src.loc, "punch", 25, 1, -1)
							message_halt = 1
					else
						src << "<span class='warning'>[src.deity_name] refuses to heal this metalic taint!</span>"
						return




		else
			if(ishuman(M) && !istype(M:head, /obj/item/clothing/head/helmet))
				M.adjustBrainLoss(10)
				M << "<span class='warning'>You feel dumber.</span>"
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='warning'><B>[] beats [] over the head with []!</B></span>", user, M, src), 1)
			playsound(src.loc, "punch", 25, 1, -1)

	else if(M.stat == 2)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class='warning'><B>[] smacks []'s lifeless corpse with [].</B></span>", user, M, src), 1)
		playsound(src.loc, "punch", 25, 1, -1)
	return

/obj/item/weapon/storage/bible/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if (istype(A, /turf/simulated/floor))
		user << "<span class='info'>You hit the floor with the bible.</span>"
		if(user.mind && (user.mind.assigned_role == "Chaplain"))
			call(/obj/effect/rune/proc/revealrunes)(src)
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		if(A.reagents && A.reagents.has_reagent("water")) //blesses all the water in the holder
			user << "<span class='info'>You bless [A].</span>"
			var/water2holy = A.reagents.get_reagent_amount("water")
			A.reagents.del_reagent("water")
			A.reagents.add_reagent("holywater",water2holy)
		if(A.reagents && A.reagents.has_reagent("unholywater")) //yeah yeah, copy pasted code - sue me
			user << "<span class='info'>You purify [A].</span>"
			var/unholy2clean = A.reagents.get_reagent_amount("unholywater")
			A.reagents.del_reagent("unholywater")
			A.reagents.add_reagent("cleaner",unholy2clean)		//it cleans their soul, get it? I'll get my coat...

/obj/item/weapon/storage/bible/attackby(obj/item/weapon/W as obj, mob/user as mob)
	playsound(src.loc, interaction_sound, 50, 1, -5)
	..()
