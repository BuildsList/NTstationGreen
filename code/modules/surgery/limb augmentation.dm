//////////////////
// Augmentation //
//////////////////

//Augment a limb using an Augment

/datum/surgery_step/add_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
/mob/living/carbon/human/proc/augmentation(var/obj/item/organ/limb/affecting, var/mob/user, var/obj/item/I)
	if(affecting.state == ORGAN_REMOVED)
		var/obj/item/organ/limb/augment/AUG = I

		if(affecting.body_part == AUG.body_part)

			if(affecting.body_part == HEAD)
				if(istype(I, /obj/item/organ/limb/augment/head))
					var/obj/item/organ/limb/augment/head/H = I
					if(H.brain)
						user.unEquip(H)
						var/obj/item/organ/brain/B = H.brain
						B.loc = src
						internal_organs += B
						H.brain = null
						qdel(H)
						if(B.brainmob && B.brainmob.mind)
							B.brainmob.mind.transfer_to(src)
						else
							key = B.brainmob.key

						stat = CONSCIOUS //Revive em

					else
						user << "<span class='warning'>This [H] has no brain inside!</span>"
						return


			if(affecting.body_part == CHEST)
				for(var/datum/disease/D in viruses)
					D.cure(1)

			affecting.change_organ(ORGAN_ROBOTIC)

			var/who = "[src]'s"
			if(user == src)
				who = "their"

			visible_message("<span class='notice'>[user] has attached [who] new limb!</span>")


		else
			user << "<span class='notice'>[AUG.name] doesn't go there!</span>"
			return

		user.drop_item()
		qdel(AUG)
		regenerate_icons()
		update_canmove()
		user.attack_log += "\[[time_stamp()]\]<font color ='red'> Augmented [src.name]'s ([src.ckey])'s [parse_zone(user.zone_sel.selecting)] </font>"
		src.attack_log += "\[[time_stamp()]\]<font color='orange'> [parse_zone(user.zone_sel.selecting)] Augmented by [user.name] ([user.ckey])</font"

/////////////////
// Limb status //
/////////////////

//Obtain the number of limbs of limb_type that are limb_state
//symmetry_type deals with requests for example, all arms

/mob/living/carbon/human/proc/get_num_limbs_of_state(var/limb_type,var/limb_state)
	var/limb_num = 0
	var/symmetry_type

	for(var/obj/item/organ/limb/affecting in organs)
		switch(limb_type)
			if(ARM_LEFT)
				symmetry_type = ARM_RIGHT
			if(ARM_RIGHT)
				symmetry_type = ARM_LEFT
			if(LEG_LEFT)
				symmetry_type = LEG_RIGHT
			if(LEG_RIGHT)
				symmetry_type = LEG_LEFT

		if(affecting.body_part == limb_type || affecting.body_part == symmetry_type)
			if(affecting.state == limb_state)
				limb_num++

	return limb_num


////////////////////////
// Change organ procs //
////////////////////////

//Easily change an organ to a different type

/mob/living/carbon/human/proc/change_all_organs(var/type)
	for(var/obj/item/organ/O in organs)
		O.change_organ(type)


/obj/item/organ/proc/change_organ(var/type)
	status = type
	state = ORGAN_FINE

	if(istype(src, /obj/item/organ/limb))
		var/obj/item/organ/limb/L = src
		L.burn_dam = 0
		L.brute_dam = 0
		L.brutestate = 0
		L.burnstate = 0
		if(L.owner)
			var/mob/living/carbon/human/H = L.owner
			H.updatehealth()
			H.regenerate_icons()



/////////////////
// Dummy limbs //
/////////////////

//Produces a dummy copy of the limb on the ground, for Asthetics
//Only handles limbs that visually remove

/obj/item/organ/limb/proc/drop_limb(var/location)
	var/obj/item/organ/limb/L
	var/obj/item/organ/limb/augment/A

	var/turf/T

	if(location)
		T = get_turf(location)
	else
		T = get_turf(src)

	if(status == ORGAN_ORGANIC)
		switch(body_part)
			if(ARM_RIGHT)
				L = new /obj/item/organ/limb/r_arm (T)
			if(ARM_LEFT)
				L = new /obj/item/organ/limb/l_arm (T)
			if(LEG_RIGHT)
				L = new /obj/item/organ/limb/r_leg (T)
			if(LEG_LEFT)
				L = new /obj/item/organ/limb/l_leg (T)

	else if(status == ORGAN_ROBOTIC)
		switch(body_part)
			if(ARM_RIGHT)
				A = new /obj/item/organ/limb/augment/r_arm (T)
			if(ARM_LEFT)
				A = new /obj/item/organ/limb/augment/l_arm (T)
			if(LEG_RIGHT)
				A = new /obj/item/organ/limb/augment/r_leg (T)
			if(LEG_LEFT)
				A = new /obj/item/organ/limb/augment/l_leg (T)

	var/direction = pick(cardinal)
	if(L)
		L.name = "[owner.name]'s [L.getDisplayName()]"
		step(L,direction)
	if(A)
		step(A,direction)

///////////////////////
// Has_active_hand() //
///////////////////////

//checks that the current active hand exists

/mob/proc/has_active_hand()
	return 1

/mob/living/carbon/human/has_active_hand()
	if(!ishuman(src))
		return
	var/obj/item/organ/limb/L
	if(hand)
		L = get_organ("l_arm")
	else
		L = get_organ("r_arm")
	if(L)
		if(L.state == ORGAN_REMOVED)
			return 0
		return 1


//////////////////////
//  head get_icon() //
//////////////////////

//Generates an icon for the head, using a human's Hair and Head layers, and the human generate_icon(limb) proc


/obj/item/organ/limb/head/proc/get_icon(var/mob/living/carbon/human/H)
	if(!istype(H) || !H)
		return

	icon_state = ""

	var/image/I = H.overlays_standing[HAIR_LAYER] //Grab the hair
	if(I)
		overlays += I


	I = H.overlays_standing[HEAD_LAYER] //Grab the Eyes/Face layer
	if(I)
		overlays += I


	I = H.generate_icon(H.getlimb(src)) //Get the Human head
	if(I)
		underlays += I
	else
		icon_state = "head"


/////AUGMENTATION SURGERIES//////


//SURGERY STEPS

/datum/surgery_step/replace
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32


/datum/surgery_step/replace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] begins to sever the muscles on [target]'s [parse_zone(user.zone_sel.selecting)]!</span>")


/datum/surgery_step/add_limb
	implements = list(/obj/item/robot_parts = 100)
	time = 32
	var/obj/item/organ/limb/L = null // L because "limb"
	allowed_organs = list("r_arm","l_arm","r_leg","l_leg","chest","head")



/datum/surgery_step/add_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = new_organ
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to augment [target]'s [parse_zone(user.zone_sel.selecting)].</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].</span>")



//ACTUAL SURGERIES

/datum/surgery/augmentation
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_limb)
	species = list(/mob/living/carbon/human)
	location = "anywhere" //Check attempt_initate_surgery() (in code/modules/surgery/helpers) to see what this does if you can't tell
	has_multi_loc = 1 //Multi location stuff, See multiple_location_example.dm


//SURGERY STEP SUCCESSES
/*
/datum/surgery_step/add_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully augments [target]'s [parse_zone(target_zone)]!</span>")
			L.loc = get_turf(target)
			H.organs -= L
			switch(target_zone)
				if("r_leg")
					H.organs += new /obj/item/organ/limb/augment/r_leg(src)
				if("l_leg")
					H.organs += new /obj/item/organ/limb/augment/l_leg(src)
				if("r_arm")
					H.organs += new /obj/item/organ/limb/augment/r_arm(src)
				if("l_arm")
					H.organs += new /obj/item/organ/limb/augment/l_arm(src)
				if("head")
					H.organs += new /obj/item/organ/limb/augment/head(src)
				if("chest")
					var/datum/surgery_step/xenomorph_removal/xeno_removal = new
					xeno_removal.remove_xeno(user, target) // remove an alien if there is one
					H.organs += new /obj/item/organ/limb/augment/chest(src)
					for(var/datum/disease/appendicitis/A in H.viruses) //If they already have Appendicitis, Remove it
						A.cure(1)
			user.drop_item()
			qdel(tool)
			H.update_damage_overlays(0)
			H.regenerate_icons()
			add_logs(user, target, "augmented", addition="by giving him new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
	else
		user.visible_message("<span class='notice'>[user] [target] has no organic [parse_zone(target_zone)] there!</span>")
	return 1 */