/obj/machinery/foodgrill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "grill_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	flags = OPENCONTAINER | NOREACT
	var/on = FALSE	//Is it grilling food already?
	var/global/list/datum/recipe/grill/available_recipes // List of the recipes you can use //Coderbus will kill me
	var/global/list/acceptable_reagents // List of the reagents you can put in
	var/global/max_n_of_items = 0
	var/efficiency = 0

/obj/machinery/foodgrill/New()
	create_reagents(100)
	if(!available_recipes)
		available_recipes = new
		for(var/type in (typesof(/datum/recipe/grill) - /datum/recipe/grill))
			available_recipes += new type
		acceptable_reagents = new
		for(var/datum/recipe/grill/recipe in available_recipes)
			for(var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
			if(recipe.items)
				max_n_of_items = max(max_n_of_items, recipe.items.len)

/obj/machinery/foodgrill/attackby(obj/item/I, mob/user)
	if(on)
		user << "<span class='notice'>[src] is already processing, please wait.</span>"
		return
	else if(istype(I, /obj/item/weapon/grab)||istype(I, /obj/item/tk_grab))
		user << "<span class='warning'>That isn't going to fit.</span>"
		return

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
			user << "<span class='warning'>You cannot grill [I].</span>"
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

/obj/machinery/foodgrill/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/foodgrill/interact(mob/user as mob) // The foodgrill Menu
	var/dat = "<div class='statusDisplay'>"
	if(src.on)
		dat += "Grilling in progress!<BR>Please wait...!</div>"
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
			dat += "The grill is empty.</div>"
		else
			dat = "<h3>Ingredients:</h3>[dat]</div>"
		dat += "<A href='?src=\ref[src];action=cook'>Turn on</A>"
		dat += "<A href='?src=\ref[src];action=dispose'>Eject ingredients</A>"

	var/datum/browser/popup = new(user, "grill", name, 300, 300)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/foodgrill/proc/cook()
	if(stat & (NOPOWER))
		return
	var/datum/recipe/grill/recipe = select_recipe(available_recipes,src)
	var/obj/cooked

	on = TRUE
	icon_state = "grill_on_closed"
	sleep(200)
	if(!recipe)
		cooked = grill()
		on = FALSE
		icon_state = "grill_off"
		return
	else
		cooked = recipe.make_food(src)
		cooked.loc = src.loc
		for(var/i=1,i<efficiency,i++)
			cooked = new cooked.type(loc)
		on = FALSE
		icon_state = "grill_off"
		return
/obj/machinery/foodgrill/proc/grill()
	for (var/obj/O in contents)
		if(istype(O, /obj/item/weapon/reagent_containers/))
			var/obj/item/weapon/reagent_containers/food = O
			food.reagents.add_reagent("nutriment", 10)
			food.reagents.trans_to(O, food.reagents.total_volume)
		O.loc = src.loc
		O.color = "#A34719"
		var/tempname = O.name
		O.name = "grilled [tempname]"



/obj/machinery/foodgrill/proc/dispose()
	for (var/obj/O in contents)
		O.loc = src.loc
	src.reagents.clear_reagents()
	usr << "\blue You dispose of the grill contents."
	src.updateUsrDialog()

/obj/machinery/foodgrill/Topic(href, href_list)
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