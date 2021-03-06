/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/status = ORGAN_ORGANIC
	var/state = ORGAN_FINE



/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	var/beating = 1

/obj/item/organ/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"


/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	var/inflamed = 1

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
	else
		icon_state = "appendix"


//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

//Old Datum Limbs:
// code/modules/unused/limbs.dm


/obj/item/organ/limb
	name = "limb"
	origin_tech = "biotech=3"
	var/mob/living/carbon/human/owner = null
	var/body_part = null
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/dam_icon = ""
	var/visibly_dismembers = 1

/obj/item/organ/limb/chest
	name = "chest"
	desc = "why is it detached..."
	icon_state = "chest"
	max_damage = 200
	body_part = CHEST
	dam_icon = "chest"
	visibly_dismembers = 0

/obj/item/organ/limb/head
	name = "head"
	desc = "what a way to get a head in life..."
	icon_state = "head"
	max_damage = 200
	body_part = HEAD
	dam_icon = "head"

/obj/item/organ/limb/l_arm
	name = "l_arm"
	desc = "why is it detached..."
	icon_state = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT
	dam_icon = "l_arm"


/obj/item/organ/limb/l_leg
	name = "l_leg"
	desc = "why is it detached..."
	icon_state = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT
	dam_icon = "l_leg"


/obj/item/organ/limb/r_arm
	name = "r_arm"
	desc = "why is it detached..."
	icon_state = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT
	dam_icon = "r_arm"


/obj/item/organ/limb/r_leg
	name = "r_leg"
	desc = "why is it detached..."
	icon_state = "r_leg"
	max_damage = 75
	body_part = LEG_RIGHT
	dam_icon = "r_leg"

/////AUGMENTATION\\\\\

/obj/item/organ/limb/augment
	name = "cyberlimb"
	desc = "You should never be seeing this!"
	icon = 'icons/obj/surgery.dmi'
	origin_tech = "programming=2;biotech=3"
	status = ORGAN_ROBOTIC
	body_part = null
	var/list/construction_cost = list("metal"=250)
	var/construction_time = 75

/obj/item/organ/limb/augment/chest
	name = "robotic chest"
	desc = "A Robotic chest"
	max_damage = 200
	icon_state = "chest_m_s"
	body_part = CHEST
	construction_cost = list("metal"=350)

/obj/item/organ/limb/augment/head
	name = "robotic head"
	desc = "A Robotic head"
	max_damage = 200
	icon_state = "head_m_s"
	body_part = HEAD
	construction_cost = list("metal"=350)
	var/obj/item/organ/brain/brain

/obj/item/organ/limb/augment/l_arm
	name = "robotic left arm"
	desc = "A Robotic arm"
	max_damage = 75
	icon_state = "l_arm_s"
	body_part = ARM_LEFT

/obj/item/organ/limb/augment/l_leg
	name = "robotic left leg"
	desc = "A Robotic leg"
	max_damage = 75
	icon_state = "l_leg_s"
	body_part = LEG_LEFT

/obj/item/organ/limb/augment/r_arm
	name = "robotic right arm"
	desc = "A Robotic arm"
	max_damage = 75
	icon_state = "r_arm_s"
	body_part = ARM_RIGHT

/obj/item/organ/limb/augment/r_leg
	name = "robotic right leg"
	desc = "A Robotic leg"
	max_damage = 75
	icon_state = "r_leg_s"
	body_part = LEG_RIGHT


/obj/item/organ/limb/augment/head/attackby(var/obj/item/I,var/mob/M)
	if(istype(I,/obj/item/organ/brain))
		var/obj/item/organ/brain/B = I

		if(!B.brainmob || !B.brainmob.mind)
			M << "<span class='warning'>This brain is unresponsive.</span>"
			return

		M.unEquip(B)
		B.loc = src
		brain = B
		M << "<span class='notice'>You insert the brain into [src].</span>"


	if(istype(I, /obj/item/weapon/crowbar))

		if(!brain)
			return

		brain.loc = get_turf(src)
		contents -= brain
		brain = null

		M << "<span class='notice'>You pop the brain out of the [src].</span>"

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/organ/limb/proc/take_damage(brute, burn)
	if(state == ORGAN_REMOVED)
		return

	if(owner && (owner.status_flags & GODMODE))	return 0	//godmode
	brute	= max(brute,0)
	burn	= max(burn,0)


	if(status == ORGAN_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
		brute = max(0, brute - 5)
		burn = max(0, burn - 4)

	var/can_inflict = max_damage - (brute_dam + burn_dam)
	if(!can_inflict)	return 0

	if((brute + burn) < can_inflict)
		brute_dam	+= brute
		burn_dam	+= burn
	else
		if(brute > 0)
			if(burn > 0)
				brute	= round( (brute/(brute+burn)) * can_inflict, 1 )
				burn	= can_inflict - brute	//gets whatever damage is left over
				brute_dam	+= brute
				burn_dam	+= burn
			else
				brute_dam	+= can_inflict
		else
			if(burn > 0)
				burn_dam	+= can_inflict
			else
				return 0
	return update_organ_icon()


//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/organ/limb/proc/heal_damage(brute, burn, var/robotic)
	if(state == ORGAN_REMOVED)
		return

	if(robotic && status != ORGAN_ROBOTIC) // This makes organic limbs not heal when the proc is in Robotic mode.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	if(!robotic && status == ORGAN_ROBOTIC) // This makes robolimbs not healable by chems.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
	return update_organ_icon()


/obj/item/proc/item_heal_robotic(var/mob/living/carbon/human/H, var/mob/user, var/brute, var/burn)
	var/obj/item/organ/limb/affecting = H.get_organ(check_zone(user.zone_sel.selecting))

	if(affecting.state == ORGAN_REMOVED)
		return

	var/dam //changes repair text based on how much brute/burn was supplied

	if(brute > burn)
		dam = 1
	else
		dam = 0

	if(affecting.status == ORGAN_ROBOTIC)
		if(brute > 0 && affecting.brute_dam > 0 || burn > 0 && affecting.burn_dam > 0)
			if (H != user)
				user.visible_message("<span class='notice'>[user] starts to repair [H]...</span>", "<span class='notice'>You begin repairing [H]...</span>")
				if(!do_mob(user, H, 20))	return
				user.visible_message("<span class='success'>[user] has fixed some of the [dam ? "dents on" : "burnt wires in"] [H]'s [affecting.getDisplayName()]!</span>",\
									"<span class='success'>You fix some of the [dam ? "dents on" : "burnt wires in"] [H]'s [affecting.getDisplayName()]</span>")
			else
				var/t_himself = "itself"
				if (user.gender == MALE)
					t_himself = "himself"
				else if (user.gender == FEMALE)
					t_himself = "herself"
				user.visible_message("<span class='notice'>[user] starts to repair [t_himself]...</span>", "<span class='notice'>You begin repairing yourself...</span>")
				if(!do_mob(user, H, 60))	return
				user.visible_message("<span class='success'>[user] fixes some [dam ? "dents on" : "burnt wires in"] [t_himself].</span>",\
									"<span class='success'>You fix some of the [dam ? "dents on" : "burnt wires in"] your [affecting.getDisplayName()].</span>")
			affecting.heal_damage(brute,burn,1)
			H.update_damage_overlays(0)
			H.updatehealth()
			for(var/mob/O in viewers(user, null))
				O.show_message(text("<span class='notice'>[user] has fixed some of the [dam ? "dents on" : "burnt wires in"] [H]'s [affecting.getDisplayName()]!</span>"), 1)
			return
		else
			user << "<span class='notice'>[H]'s [affecting.getDisplayName()] is already in good condition</span>"
			return
	else
		return

//Returns total damage...kinda pointless really
/obj/item/organ/limb/proc/get_damage()
	return brute_dam + burn_dam


//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/organ/limb/proc/update_organ_icon()
	if(status == ORGAN_ORGANIC) //Robotic limbs show no damage
		var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
		var/tburn	= round( (burn_dam/max_damage)*3, 1 )
		if((tbrute != brutestate) || (tburn != burnstate))
			brutestate = tbrute
			burnstate = tburn
			return 1
		return 0

//Returns a display name for the organ
/obj/item/organ/limb/proc/getDisplayName()
	switch(name)
		if("l_leg")		return "left leg"
		if("r_leg")		return "right leg"
		if("l_arm")		return "left arm"
		if("r_arm")		return "right arm"
		if("chest")     return "chest"
		if("head")		return "head"
		else			return name





/obj/item/organ/limb/head/attackby(var/obj/item/I,var/mob/M)
	if(istype(I, /obj/item/weapon/circular_saw))
		var/obj/item/organ/brain/B = locate(/obj/item/organ/brain) in contents
		if(B)
			B.loc = get_turf(src)
			contents -= B
			M << "<span class='notice'>You saw open [src] and remove their brain</span>"
