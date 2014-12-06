////////////////
//BARBER TOOLS//
////////////////

///obj/item/weapon/scissors
//	name = "scissors"
//	icon = 'surgery.dmi'
//	icon_state = "scissors"
//	w_class = 1.0
//	origin_tech = "materials=1"
//
///obj/item/weapon/dye
//	name = "hairdye"
//	icon = 'surgery.dmi'
//	icon_state = "dye"
//	w_class = 1.0
//	origin_tech = "materials=1"

///obj/item/weapon/bearddye
//	name = "bearddye"
//	icon = 'surgery.dmi'
//	icon_state = "dye"
//	w_class = 1.0
//	origin_tech = "materials=1"
//
///obj/item/weapon/comb
//	name = "straight razor"
//	icon = 'surgery.dmi'
//	icon_state = "razor"
//	w_class = 1.0
//	origin_tech = "materials=1"


//////////
//HAIRDYE//
///////////
//
// /obj/item/weapon/dye/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
//	if(!istype(M, /mob))
//		return
//
//	//hairstyle pick
//	var/new_hair = input(user, "Please select hair color.", "Hairdye") as color
//	if(new_hair)
//		M:r_hair = hex2num(copytext(new_hair, 2, 4))
//		M:g_hair = hex2num(copytext(new_hair, 4, 6))
//		M:b_hair = hex2num(copytext(new_hair, 6, 8))
//
//		M:update_body()
//		M:update_face()
//
//	return
//
////////////
//BEARDDYE//
////////////
//
///obj/item/weapon/bearddye/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
//	if(!istype(M, /mob))
//		return
//
//	//hairstyle pick
//	var/new_facial = input(user, "Please select facial hair color.", "Bearddye") as color
//	if(new_facial)
//		M:r_facial = hex2num(copytext(new_facial, 2, 4))
//		M:g_facial = hex2num(copytext(new_facial, 4, 6))
//		M:b_facial = hex2num(copytext(new_facial, 6, 8))
//
//		M:update_body()
//		M:update_face()
//
//	return


//////////
//BEARDCOMB//
////////////

///obj/item/weapon/comb/attack(mob/living/carbon/H as mob, mob/living/carbon/user as mob)
//	if(!istype(H, /mob))
//		return
//
	//hairstyle pick
//		if(H.gender == MALE)
//			var/new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in facial_hair_styles_list
//			if(userloc != H.loc) return	//no tele-grooming
//			if(new_style)
//				H.facial_hair_style = new_style
//		else
//			H.facial_hair_style = "Shaved"
//		H.update_hair()
//
//	return
//
/////////////
//SCISSORS//
////////////

///obj/item/weapon/scissors/attack(mob/living/carbon/H as mob, mob/living/carbon/user as mob)
//	if(!istype(H, /mob))
//		return
//
//
//		var/new_style = input(user, "Select a hair style", "Grooming")  as null|anything in hair_styles_list
//		if(userloc != H.loc) return	//no tele-grooming
//		if(new_style)
//			H.hair_style = new_style
//		H.update_hair()

//
//	return

//end barber tools