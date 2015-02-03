/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "blindfold"
	flags = MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/muzzle/gag
	name = "gag"
	desc = "Stick this in their mouth to stop the noise."
	icon_state = "gag"
	w_class = 1

/obj/item/clothing/mask/muzzle/attack_paw(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.wear_mask)
			user << "<span class='notice'>You need help taking this off!</span>"
			return
	..()

/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = 1
	flags = MASKCOVERSMOUTH
	flags_inv = HIDEFACE
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 25, rad = 0)

/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	item_state = "pig"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = 2

/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = 2
	var/voicechange = 0

/obj/item/clothing/mask/horsehead/black
	name = "black horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a black horse."
	icon_state = "horsehead_b"
	item_state = "horsehead_b"

/obj/item/clothing/mask/unicornhead
	name = "unicorn head mask"
	desc = "A mask made of soft furr and latex, representing the head of a unicorn."
	icon_state = "unicorn"
	item_state = "unicorn"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = 2

/obj/item/clothing/mask/horsehead/speechModification(message)
	if(voicechange)
		if(!(copytext(message, 1, 2) == "*" || (usr.mind && usr.mind.changeling && (copytext(message, 1, 3) == ":g" || copytext(message, 1, 3) == ":G" || copytext(message, 1, 3) == ":ï"))))
			message = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")
	return message

/obj/item/clothing/mask/fawkes
	name = "Guy Fawkes mask"
	desc = "A mask designed to help you remember a specific date."
	icon_state = "fawkes"
	item_state = "fawkes"
	flags_inv = HIDEFACE
	w_class = 2

/obj/item/clothing/mask/bandana
	name = "bandana"
	desc = "A colorful bandana."
	action_button_name = "Toggle Bandana"
	flags_inv = HIDEFACE
	w_class = 1
	can_flip = 1

obj/item/clothing/mask/bandana/red
	name = "red bandana"
	icon_state = "bandred"

obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	icon_state = "bandblue"

obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	icon_state = "bandgold"

obj/item/clothing/mask/bandana/green
	name = "green bandana"
	icon_state = "bandgreen"

/obj/item/clothing/mask/bandana/botany
	name = "botany bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "bandbotany"

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "It's a black bandana with a skull pattern."
	icon_state = "bandskull"

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	desc = "It's a black bandana."
	icon_state = "bandblack"

/obj/item/clothing/mask/heist/smiley
	name = "white smiley mask"
	desc = "It's a white plastic smiley mask.\nCheck your corners..."
	icon_state = "w_smiley"
	item_state = "w_smiley"
	flags_inv = HIDEFACE
	w_class = 1

/obj/item/clothing/mask/heist/smiley/yellow
	name = "yellow smiley mask"
	desc = "It's a yellow plastic smiley mask.\nTime to find some thermal drill..."
	icon_state = "y_smiley"
	item_state = "y_smiley"

/obj/item/clothing/mask/heist/smiley/red
	name = "red smiley mask"
	desc = "It's a red plastic smiley mask.\nPayday time!"
	icon_state = "r_smiley"
	item_state = "r_smiley"