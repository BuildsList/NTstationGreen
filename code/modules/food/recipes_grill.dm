
// see code/datums/recipe.dm

/datum/recipe/grill/friedegg
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/friedegg


/datum/recipe/grill/omelette
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/omelette

/datum/recipe/grill/wingfangchu
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/xenomeat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/wingfangchu

/datum/recipe/grill/cubancarp
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat,
		/obj/item/weapon/reagent_containers/food/snacks/doughslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cubancarp

/datum/recipe/grill/meatsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatsteak

/datum/recipe/grill/syntisteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/weapon/syntiflesh
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatsteak

/datum/recipe/grill/sandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sandwich

/datum/recipe/grill/toastedsandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/sandwich
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/toastedsandwich

/datum/recipe/grill/grilledcheese
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/grilledcheese

/datum/recipe/grill/cutlet
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawcutlet,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cutlet

/datum/recipe/grill/meatball
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawmeatball,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/faggot

/datum/recipe/grill/slimetoast
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime

/datum/recipe/grill/jelliedtoast
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry

/datum/recipe/grill/slimesandwich
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime

/datum/recipe/grill/cherrysandwich
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry

/datum/recipe/grill/human
	make_food(var/obj/container as obj)
		var/human_name
		var/human_job
		for (var/obj/item/weapon/reagent_containers/food/snacks/meat/human/HM in container)
			if (!HM.subjectname)
				continue
			human_name = HM.subjectname
			human_job = HM.subjectjob
			break
		var/lastname_index = findtext(human_name, " ")
		if (lastname_index)
			human_name = copytext(human_name,lastname_index+1)

		var/obj/item/weapon/reagent_containers/food/snacks/burger/human/HB = ..(container)
		HB.name = human_name+HB.name
		HB.job = human_job
		return HB

/datum/recipe/grill/human/burger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,

	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/human

/datum/recipe/grill/human/kebab
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/human/kebab

/datum/recipe/grill/monkeykebab
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/meat/monkey,
		/obj/item/weapon/reagent_containers/food/snacks/meat/monkey,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeykebab

/datum/recipe/grill/tofukebab
	items = list(
		/obj/item/stack/rods,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/tofukebab


/datum/recipe/grill/carpmeat
	reagents = list("carpotoxin" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/carpmeat/imitation

/datum/recipe/grill/benedict
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/benedict

/datum/recipe/grill/icecreamsandwich
	reagents = list("ice" = 5, "cream" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/icecream,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich

/datum/recipe/grill/notasandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/clothing/mask/fakemoustache,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/notasandwich

