/obj/item/clothing/gloves/yellow
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	item_color="yellow"
	var/wired = 0
	var/obj/item/weapon/stock_parts/cell/cell = null

/obj/item/clothing/gloves/yellow/attackby(obj/item/weapon/W, mob/user)
	if(istype(src, /obj/item/clothing/gloves/boxing))	//quick fix for stunglove overlay not working nicely with boxing gloves.
		user << "<span class='notice'>That won't work.</span>"	//i'm not putting my lips on that!
		..()
		return
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(!wired)
			if(C.amount >= 2)
				C.use(2)
				wired = 1
				user << "<span class='notice'>You wrap some wires around [src].</span>"
				update_icon()
			else
				user << "<span class='notice'>There is not enough wire to cover [src].</span>"
		else
			user << "<span class='notice'>[src] are already wired.</span>"

	else if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(!wired)
			user << "<span class='notice'>[src] need to be wired first.</span>"
		else if(!cell)
			user.drop_item()
			W.loc = src
			cell = W
			user << "<span class='notice'>You attach a cell to [src].</span>"
			update_icon()
		else
			user << "<span class='notice'>[src] already have a cell.</span>"

	else if(istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/weapon/scalpel))
		wired = null

		if(cell)
			cell.updateicon()
			cell.loc = get_turf(src.loc)
			cell = null
			user << "<span class='notice'>You cut the cell away from [src].</span>"
			update_icon()
			return
		if(wired) //wires disappear into the void because fuck that shit
			wired = 0
			user << "<span class='notice'>You cut the wires away from [src].</span>"
			update_icon()
		..()
	return

/obj/item/clothing/gloves/yellow/Touch(A, proximity, var/mob/living/carbon/user)
	if(!user)		return 0
	if(!proximity)	return 0
	if(!cell)		return 0
	if(iscarbon(A) && user.a_intent == "harm")
		var/mob/living/carbon/M = A
		if(cell.use(1500))
			user.visible_message("\red <B>[A] has been touched with the stun gloves by [user]!</B>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Stungloved [M.name] ([M.ckey])</font>")
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stungloved by [user.name] ([user.ckey])</font>")
			message_admins("[user.name] ([user.ckey]) stungloved [M.name] ([M.ckey])  (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)", 1)
			M.apply_effects(5,5,0,0,5,0,0,M.run_armor_check(user.zone_sel.selecting, "energy"))
			return 1
		else
			user << "\red Not enough charge!"
	/*
	else if(istype(A, /obj/machinery/power/apc) && user.a_intent == "grab")
		Maybe place stungloves charging code here?
	*/
	return 0



/obj/item/clothing/gloves/yellow/update_icon()
	..()
	overlays.Cut()
	if(wired)
		overlays += "gloves_wire"
	if(cell)
		overlays += "gloves_cell"

/obj/item/clothing/gloves/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05

	item_color="yellow"

	New()
		siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	item_color = "brown"

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT


	hos
		item_color = "hosred"		//Exists for washing machines. Is not different from black gloves in any way.

	ce
		item_color = "chief"			//Exists for washing machines. Is not different from black gloves in any way.

/obj/item/clothing/gloves/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	item_state = "orangegloves"
	item_color = "orange"

/obj/item/clothing/gloves/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	item_state = "redgloves"
	item_color = "red"

/obj/item/clothing/gloves/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	item_state = "rainbowgloves"
	item_color = "rainbow"

	clown
		item_color = "clown"

/obj/item/clothing/gloves/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	item_state = "bluegloves"
	item_color = "blue"

/obj/item/clothing/gloves/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	item_state = "purplegloves"
	item_color = "purple"

/obj/item/clothing/gloves/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	item_state = "greengloves"
	item_color = "green"

/obj/item/clothing/gloves/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	item_state = "graygloves"
	item_color = "grey"

	rd
		item_color = "director"			//Exists for washing machines. Is not different from gray gloves in any way.

	hop
		item_color = "hop"				//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"
	item_color = "light brown"

/obj/item/clothing/gloves/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	item_state = "browngloves"
	item_color = "brown"

	cargo
		item_color = "cargo"				//Exists for washing machines. Is not different from brown gloves in any way.