/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(check_shields(0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	switch(M.a_intent)
		if ("help")
			visible_message("<span class='warning'> [M] caresses [src] with its scythe like arm.</span>")
		if ("grab")
			if(M == src || anchored)
				return
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)

			M.put_in_active_hand(G)

			G.synch()
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='danger'>[M] has grabbed [src] passively!</span>")

		if("harm")
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = rand(15, 30)
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>", \
					"<span class='userdanger'>[M] has lunged at [src]!</span>")
				return 0
			var/obj/item/organ/limb/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
				"<span class='userdanger'>[M] has slashed at [src]!</span>")

			apply_damage(damage, BRUTE, affecting, armor_block)
			if (damage >= 25)
				visible_message("<span class='danger'>[M] has wounded [src]!</span>", \
					"<span class='userdanger'>[M] has wounded [src]!</span>")
				apply_effect(4, WEAKEN, armor_block)
			updatehealth()

		if("disarm")
			var/randn = rand(1, 100)
			if (randn <= 80)
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				Weaken(5)
				visible_message("<span class='danger'>[M] has tackled down [src]!</span>", \
					"<span class='userdanger'>[M] has tackled down [src]!</span>")
			else
				if (randn <= 99)
					playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
					drop_item()
					visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
						"<span class='userdanger'>[M] disarmed [src]!</span>")
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has tried to disarm [src]!</span>", \
						"<span class='userdanger'>[M] has tried to disarm [src]!</span>")
	return

/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L as mob)
	switch(L.a_intent)
		if("help")
			visible_message("<span class='info'>[L] rubs it's head against [src]</span>")
		else
			var/damage = rand(5, 10)
			visible_message("<span class='warning'><B>[L] bites [src]!</B></span>")
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			adjustBruteLoss(damage)
