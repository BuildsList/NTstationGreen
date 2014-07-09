
// see code/datums/recipe.dm

/datum/recipe/microwave/boiledegg
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledegg

/datum/recipe/microwave/donkpocket/warm
	reagents = list() //This is necessary since this is a child object of the above recipe and we don't want donk pockets to need flour
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donkpocket //SPECIAL
	proc/warm_up(var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/being_cooked)
		being_cooked.warm = 1
		being_cooked.reagents.add_reagent("tricordrazine", 5)
		being_cooked.bitesize = 6
		being_cooked.name = "Warm " + being_cooked.name
		being_cooked.cooltime()
	make_food(var/obj/container as obj)
		var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/being_cooked = locate() in container
		if(being_cooked && !being_cooked.warm)
			warm_up(being_cooked)
		return being_cooked

/datum/recipe/microwave/popcorn
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/popcorn



/datum/recipe/microwave/spacylibertyduff
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff

/datum/recipe/microwave/amanitajelly
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	make_food(var/obj/container as obj)
		var/obj/item/weapon/reagent_containers/food/snacks/amanitajelly/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("amatoxin")
		return being_cooked

/datum/recipe/microwave/meatballsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot ,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballsoup

/datum/recipe/microwave/vegetablesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/vegetablesoup

/datum/recipe/microwave/nettlesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/grown/nettle,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/nettlesoup

/datum/recipe/microwave/wishsoup
	reagents = list("water" = 20)
	result= /obj/item/weapon/reagent_containers/food/snacks/wishsoup

/datum/recipe/microwave/hotchili
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotchili

/datum/recipe/microwave/coldchili
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/coldchili

/datum/recipe/microwave/enchiladas
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/enchiladas

/datum/recipe/microwave/monkeysdelight
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeysdelight

/datum/recipe/microwave/tomatosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/tomatosoup

/datum/recipe/microwave/stew
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/stew

/datum/recipe/microwave/milosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/milosoup

/datum/recipe/microwave/stewedsoymeat
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat

/datum/recipe/microwave/boiledspagetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspagetti

/datum/recipe/microwave/pastatomato
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pastatomato

/datum/recipe/microwave/meatballspagetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
		/obj/item/weapon/reagent_containers/food/snacks/rawmeatball,
		/obj/item/weapon/reagent_containers/food/snacks/rawmeatball,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballspagetti

/datum/recipe/microwave/smeatballspagetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
		/obj/item/weapon/reagent_containers/food/snacks/rawmeatball,
		/obj/item/weapon/reagent_containers/food/snacks/rawmeatball,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballspagetti/sauced

/datum/recipe/microwave/spesslaw
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spesslaw

/datum/recipe/microwave/sspesslaw
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spesslaw/sauced

/datum/recipe/microwave/twobread
	reagents = list("wine" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/twobread

/datum/recipe/microwave/bloodsoup
	reagents = list("blood" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/bloodsoup

/datum/recipe/microwave/slimesoup
	reagents = list("water" = 10, "slimejelly" = 5)
	items = list(
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/slimesoup

/datum/recipe/microwave/clownstears
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/weapon/ore/clown,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/clownstears

/datum/recipe/microwave/chocolateegg
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chocolateegg

/datum/recipe/microwave/sausage
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
		/obj/item/weapon/reagent_containers/food/snacks/cutlet,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sausage

/datum/recipe/microwave/mysterysoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/badrecipe,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/mysterysoup


/datum/recipe/microwave/mushroomsoup
	reagents = list("water" = 5, "milk" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/mushroomsoup

/datum/recipe/microwave/beetsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/beetsoup

/datum/recipe/microwave/aesirsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/aesirsalad

/datum/recipe/microwave/validsalad
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/validsalad
	make_food(var/obj/container as obj)
		var/obj/item/weapon/reagent_containers/food/snacks/validsalad/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("toxin")
		return being_cooked

/datum/recipe/microwave/taco
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/tacobase,
		/obj/item/weapon/reagent_containers/food/snacks/cutlet,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/taco

/datum/recipe/microwave/cornedbeef
	reagents = list("sodiumchloride" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cornedbeef

/datum/recipe/microwave/copypasta
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato,
		/obj/item/weapon/reagent_containers/food/snacks/pastatomato,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/copypasta

////////////////////////////FOOD ADDITTIONS///////////////////////////////

/datum/recipe/microwave/wrap
	reagents = list("soysauce" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/wrap

/datum/recipe/microwave/boiledspiderleg
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spiderleg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg

/datum/recipe/microwave/spidereggsham
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs,
		/obj/item/weapon/reagent_containers/food/snacks/spidermeat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spidereggsham

/datum/recipe/microwave/sashimi
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sashimi

