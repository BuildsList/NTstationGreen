//Look Sir, free crabs!
/mob/living/simple_animal/crab
	name = "crab"
	desc = "Free crabs!"
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks")
	emote_see = list("clacks")
	speak_chance = 1
	turns_per_move = 5
	meat_type = list(/obj/item/weapon/reagent_containers/food/snacks/meat)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	stop_automated_movement = 1
	friendly = "pinches"
	ventcrawler = 2
	var/obj/item/inventory_head
	var/obj/item/inventory_mask

/mob/living/simple_animal/crab/Life()
	..()
	//CRAB movement
	if(!ckey && !stat)
		if(isturf(src.loc) && !resting && !buckled)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				Move(get_step(src,pick(4,8)))
				turns_since_move = 0
	regenerate_icons()

//COFFEE! SQUEEEEEEEEE!
/mob/living/simple_animal/crab/Coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "It's Coffee, the other pet!"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"

//LOOK AT THIS - ..()??
/*/mob/living/simple_animal/crab/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/wirecutters))
		if(prob(50))
			user << "<span class='warning'>\b This kills the crab.</span>"
			health -= 20
			Die()
		else
			GetMad()
			get
	if(istype(O, /obj/item/stack/medical))
		if(stat != DEAD)
			var/obj/item/stack/medical/MED = O
			if(health < maxHealth)
				if(MED.amount >= 1)
					health = min(maxHealth, health + MED.heal_brute)
					MED.amount -= 1
					if(MED.amount <= 0)
						qdel(MED)
					for(var/mob/M in viewers(src, null))
						if ((M.client && !( M.blinded )))
							M.show_message("<span class='info'>[user] applies [MED] on [src]</span>")
		else
			user << "<span class='info'>this crab is dead, medical items won't bring it back to life.</span>"
	else
		if(O.force)
			health -= O.force
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='warning'>\b [src] has been attacked with [O] by [user]. </span>")
		else
			usr << "<span class='warning'>This weapon is ineffective, it does no damage.</span>"
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='warning'>[user] gently taps [src] with [O]. </span>")

/mob/living/simple_animal/crab/GetMad()
	name = "MEGAMADCRAB"
	real_name = "MEGAMADCRAB"
	desc = "OH NO YOU DUN IT NOW."
	icon = 'icons/mob/mob.dmi'
	icon_state = "madcrab"
	icon_living = "madcrab"
	icon_dead = "madcrab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks with fury", "clicks angrily")
	emote_see = list("clacks")
	speak_chance = 1
	turns_per_move = 15//Gotta go fast
	maxHealth = 100//So they don't die as quickly
	health = 100
	melee_damage_lower = 3
	melee_damage_upper = 10//Kill them. Kill them all
	if(inventory_head)//Drops inventory so it doesn't have to be dealt with
		inventory_head.loc = src.loc
		inventory_head = null
	if(inventory_mask)
		inventory_mask.loc = src.loc
		inventory_mask = null*/