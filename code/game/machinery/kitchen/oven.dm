/obj/machinery/cooking
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	var/orig = "oven"
	var/production_meth = "cooking"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	var/grown_only = 0
	idle_power_usage = 5
	var/on = FALSE	//Is it making food already?
	var/list/food_choices = list()
/obj/machinery/cooking/New()
	..()
	updatefood()

/obj/machinery/cooking/attackby(obj/item/I, mob/user)
	if(on)
		user << "The machine is already running."
		return
	if(istype(I,/obj/item/weapon/wrench))
		if(!anchored && !isinspace())
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 1
			user << "You wrench [src] in place."
		else if(anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 0
			user << "You unwrench [src]."
	if(!istype(I,/obj/item/weapon/reagent_containers/food/snacks/))
		user << "That isn't food."
		return
	if(!istype(I,/obj/item/weapon/reagent_containers/food/snacks/grown/) && grown_only)
		user << "You can only still grown items."
		return
	else
		var/obj/item/weapon/reagent_containers/food/snacks/F = I
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/C
		user.drop_item()
		F.loc = src
		C = input("Select food to make.", "Cooking", C) in food_choices
		if(!C)
			F.loc = user.loc
			return
		else
			user << "You put [F] into [src] for [production_meth]."
			user.drop_item()
			F.loc = src
			on = TRUE
			icon_state = "[orig]_on"
			sleep(100)
			on = FALSE
			icon_state = "[orig]_off"
			C.loc = get_turf(src)
			C.attackby(F,user)
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			updatefood()
			return

/obj/machinery/cooking/proc/updatefood()
	return

/obj/machinery/cooking/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	flags = OPENCONTAINER | NOREACT
	icon_state = "oven_off"
	var/global/list/datum/recipe/oven/available_recipes // List of the recipes you can use //Coderbus will kill me
	var/global/list/acceptable_reagents // List of the reagents you can put in
	var/global/max_n_of_items = 0
	var/efficiency = 0

/obj/machinery/cooking/oven/New()
	create_reagents(100)
	if(!available_recipes)
		available_recipes = new
		for(var/type in (typesof(/datum/recipe/oven) - /datum/recipe/oven))
			available_recipes += new type
		acceptable_reagents = new
		for(var/datum/recipe/recipe in available_recipes)
			for(var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
			if(recipe.items)
				max_n_of_items = max(max_n_of_items, recipe.items.len)

/obj/machinery/cooking/oven/attackby(obj/item/I, mob/user)
	if(on)
		user << "The machine is already running."
		return
	if(istype(I,/obj/item/weapon/wrench))
		if(!anchored && !isinspace())
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 1
			user << "You wrench [src] in place."
		else if(anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 0
			user << "You unwrench [src]."
	if(!istype(I,/obj/item/weapon/reagent_containers/food/snacks/))
		user << "That isn't food."
		return
//		if(!istype(I,/obj/item/weapon/reagent_containers/food/snacks/grown/) && grown_only)
//			user << "You can only still grown items."
//			return
	else if(istype(I,/obj/item/weapon/reagent_containers/glass) || \
	        istype(I,/obj/item/weapon/reagent_containers/food/drinks) || \
	        istype(I,/obj/item/weapon/reagent_containers/food/condiment) \
		)
		if (!I.reagents)
			return 1
		for (var/datum/reagent/R in I.reagents.reagent_list)
			if (!(R.id in acceptable_reagents))
				user << "\red Your [I] contains components unsuitable for cookery."
				return 1
	else
		if(!user.unEquip(I))
			user << "<span class='warning'>You cannot bake [I].</span>"
			return
		if (contents.len>=max_n_of_items)
			user << "\red This [src] is full of ingredients, you cannot put more."
			return 1
		if(stat & (NOPOWER))
			return
		if (istype(I,/obj/item/stack) && I:amount>1)
			new I.type (src)
			I:use(1)
			user.visible_message( \
				"\blue [user] has added one of [I] to \the [src].", \
				"\blue You add one of [I] to \the [src].")
		else
			I.loc = src
			user.visible_message( \
				"\blue [user] has added \the [I] to \the [src].", \
				"\blue You add \the [I] to \the [src].")

	src.updateUsrDialog()

/obj/machinery/cooking/oven/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)


/obj/machinery/cooking/oven/interact(mob/user as mob) // The oven Menu
	var/dat = "<div class='statusDisplay'>"
	if(src.on)
		dat += "Cooking in progress!<BR>Please wait...!</div>"
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for (var/obj/O in contents)
			var/display_name = O.name
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
				display_name = "Donk Pockets"
				items_measures[display_name] = "donk pocket"
				items_measures_p[display_name] = "donk pockets"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/carpmeat))
				items_measures[display_name] = "fillet of meat"
				items_measures_p[display_name] = "fillets of meat"
			items_counts[display_name]++
		for (var/O in items_counts)
			var/N = items_counts[O]
			if (!(O in items_measures))
				dat += "[capitalize(O)]: [N] [lowertext(O)]\s<BR>"
			else
				if (N==1)
					dat += "[capitalize(O)]: [N] [items_measures[O]]<BR>"
				else
					dat += "[capitalize(O)]: [N] [items_measures_p[O]]<BR>"

		for (var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if (R.id == "capsaicin")
				display_name = "hot sauce"
			if (R.id == "frostoil")
				display_name = "cold sauce"
			dat += "[display_name]: [R.volume] unit\s<BR>"

		if (items_counts.len==0 && reagents.reagent_list.len==0)
			dat += "The oven is empty.</div>"
		else
			dat = "<h3>Ingredients:</h3>[dat]</div>"
		dat += "<A href='?src=\ref[src];action=cook'>Turn on</A>"
		dat += "<A href='?src=\ref[src];action=dispose'>Eject ingredients</A>"

	var/datum/browser/popup = new(user, "oven", name, 300, 300)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/cooking/oven/proc/cook()
	if(stat & (NOPOWER))
		return
	var/datum/recipe/oven/recipe = select_recipe(available_recipes,src)
	var/obj/cooked

	on = TRUE
	icon_state = "oven_on"
	sleep(200)
	if(!recipe)
		cooked = fail()
		stop()
	else
		cooked = recipe.make_food(src)
		cooked.loc = src.loc
		for(var/i=1,i<efficiency,i++)
			cooked = new cooked.type(loc)
		stop()

/obj/machinery/cooking/oven/proc/stop()
	on = FALSE
	icon_state = "oven_off"
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	return

/obj/machinery/cooking/oven/proc/fail()
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for (var/obj/O in contents-ffuu)
		amount++
		if (O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if (id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	src.reagents.clear_reagents()
	ffuu.reagents.add_reagent("carbon", amount)
	ffuu.reagents.add_reagent("toxin", amount/10)
	return ffuu

/obj/machinery/cooking/oven/proc/dispose()
	for (var/obj/O in contents)
		O.loc = src.loc
	src.reagents.clear_reagents()
	usr << "\blue You dispose of the oven contents."
	src.updateUsrDialog()

/obj/machinery/cooking/oven/Topic(href, href_list)
	usr.set_machine(src)
	if(src.on)
		updateUsrDialog()
		return

	switch(href_list["action"])
		if ("cook")
			cook()

		if ("dispose")
			dispose()
	updateUsrDialog()
	return

/obj/machinery/cooking/candy
	name = "candy machine"
	desc = "Get yer box of deep fried deep fried deep fried deep fried cotton candy cereal sandwich cookies here!"
	icon_state = "mixer_off"
	orig = "mixer"
	production_meth = "candizing"

/obj/machinery/cooking/candy/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable/candy)-(/obj/item/weapon/reagent_containers/food/snacks/customizable/candy))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/V = new U
		src.food_choices += V
	return


/obj/machinery/cooking/still
	name = "still"
	desc = "Alright, so, t'make some moonshine, fust yo' gotta combine some of this hyar egg wif th' deep fried sausage."
	icon_state = "still_off"
	orig = "still"
	grown_only = 1
	production_meth = "brewing"

/obj/machinery/cooking/still/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in typesof(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/)-(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/))
		var/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/V = new U
		src.food_choices += V
	return
