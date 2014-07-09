
// see code/datums/recipe.dm

/datum/recipe/fryer/cheesyfries
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawsticks,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesyfries

/datum/recipe/fryer/fries
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawsticks,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/fries

/datum/recipe/fryer/fishandchips
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawsticks,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishandchips

/datum/recipe/fryer/fishfingers
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat,
		/obj/item/weapon/reagent_containers/food/snacks/doughslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishfingers

/datum/recipe/fryer/meatbun
	reagents = list("soysauce" = 5, "flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatbun
