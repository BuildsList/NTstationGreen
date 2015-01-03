//Contains the target item datums for Steal objectives.

datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/weapon/bikehorn		//typepath of the objective item
	var/difficulty = 9001							//vaguely how hard it is to do this objective
	var/list/excludefromjob = list()				//If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)
	var/list/altitems = list()				//Items which can serve as an alternative to the objective (darn you blueprints)

datum/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1


datum/objective_item/steal/caplaser
	name = "капитанский антикварный лазер"
	targetitem = /obj/item/weapon/gun/energy/laser/captain
	difficulty = 5
	excludefromjob = list("Captain")

datum/objective_item/steal/handtele
	name = "ручной телепортер"
	targetitem = /obj/item/weapon/hand_tele
	difficulty = 5
	excludefromjob = list("Captain")

datum/objective_item/steal/rcd
	name = "устройство моментального строительства"
	targetitem = /obj/item/weapon/rcd
	difficulty = 3

datum/objective_item/steal/jetpack
	name = "реактивный ранец"
	targetitem = /obj/item/weapon/tank/jetpack
	difficulty = 3

datum/objective_item/steal/magboots
	name = "магнитные ботинки главы инженеров"
	targetitem =  /obj/item/clothing/shoes/magboots/advance
	difficulty = 5
	excludefromjob = list("Chief Engineer")

datum/objective_item/steal/corgimeat
	name = "ломтик мяса корги"
	targetitem = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	difficulty = 5
	excludefromjob = list("Head of Personnel") //>hurting your little buddy ever

datum/objective_item/steal/capmedal
	name = "медаль \"Лучшему Капитану\""
	targetitem = /obj/item/clothing/tie/medal/gold/captain
	difficulty = 5
	excludefromjob = list("Captain")

datum/objective_item/steal/hypo
	name = "гипоспрей"
	targetitem = /obj/item/weapon/reagent_containers/hypospray
	difficulty = 5
	excludefromjob = list("Chief Medical Officer")

datum/objective_item/steal/nukedisc
	name = "диск ядерной аутентификации"
	targetitem = /obj/item/weapon/disk/nuclear
	difficulty = 5
	excludefromjob = list("Captain")

datum/objective_item/steal/ablative
	name = "комплект отражающей брони"
	targetitem = /obj/item/clothing/suit/armor/laserproof
	difficulty = 3
	excludefromjob = list("Head of Security", "Warden")

datum/objective_item/steal/reactive
	name = "комплект реактивной брони"
	targetitem = /obj/item/clothing/suit/armor/reactive
	difficulty = 5
	excludefromjob = list("Research Director")

datum/objective_item/steal/documents
	name = "пачку секретных документов"
	targetitem = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's
	difficulty = 5

//Items with special checks!
datum/objective_item/steal/plasma
	name = "28 молей газообразной плазмы (полный бак)"
	targetitem = /obj/item/weapon/tank
	difficulty = 3
	excludefromjob = list("Chief Engineer","Research Director","Station Engineer","Scientist","Atmospheric Technician")

datum/objective_item/plasma/check_special_completion(var/obj/item/weapon/tank/T)
	var/target_amount = text2num(name)
	var/found_amount = 0
	found_amount += T.air_contents.toxins
	return found_amount>=target_amount


datum/objective_item/steal/functionalai
	name = "функционирующий ИИ"
	targetitem = /obj/item/device/aicard
	difficulty = 20 //beyond the impossible

datum/objective_item/functionalai/check_special_completion(var/obj/item/device/aicard/C)
	for(var/mob/living/silicon/ai/A in C)
		if(istype(A, /mob/living/silicon/ai) && A.stat != 2) //See if any AI's are alive inside that card.
			return 1
	return 0

datum/objective_item/steal/blueprints
	name = "чертежи станции"
	targetitem = /obj/item/blueprints
	difficulty = 10
	excludefromjob = list("Chief Engineer")
	altitems = list(/obj/item/weapon/photo)

datum/objective_item/blueprints/check_special_completion(var/obj/item/I)
	if(istype(I, /obj/item/blueprints))
		return 1
	if(istype(I, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/P = I
		if(P.blueprints)	//if the blueprints are in frame
			return 1
	return 0

datum/objective_item/steal/slime
	name = "не использованный экстракт слизня"
	targetitem = /obj/item/slime_extract
	difficulty = 3
	excludefromjob = list("Research Director","Scientist")

datum/objective_item/slime/check_special_completion(var/obj/item/slime_extract/E)
	if(E.Uses > 0)
		return 1
	return 0

//Unique Objectives
datum/objective_item/unique/docs_red
	name = "\"Красные\" секретные документы"
	targetitem = /obj/item/documents/syndicate/red
	difficulty = 10

datum/objective_item/unique/docs_blue
	name = "\"Синие\" секретные докуметны"
	targetitem = /obj/item/documents/syndicate/blue
	difficulty = 10

//Old ninja objectives.
datum/objective_item/special/pinpointer
	name = "капитанский указатель"
	targetitem = /obj/item/weapon/pinpointer
	difficulty = 10

datum/objective_item/special/aegun
	name = "улучшенное энергетическое оружие"
	targetitem = /obj/item/weapon/gun/energy/gun/nuclear
	difficulty = 10

datum/objective_item/special/ddrill
	name = "алмазную дрелль"
	targetitem = /obj/item/weapon/pickaxe/diamonddrill
	difficulty = 10

datum/objective_item/special/boh
	name = "бездонную сумку"
	targetitem = /obj/item/weapon/storage/backpack/holding
	difficulty = 10

datum/objective_item/special/hypercell
	name = "батарейку с гипер зарядом"
	targetitem = /obj/item/weapon/stock_parts/cell/hyper
	difficulty = 5

datum/objective_item/special/laserpointer
	name = "лазерную указку"
	targetitem = /obj/item/device/laser_pointer
	difficulty = 5

//Stack objectives get their own subtype
datum/objective_item/stack
	name = "пять картонок"
	targetitem = /obj/item/stack/sheet/cardboard
	difficulty = 9001

datum/objective_item/stack/check_special_completion(var/obj/item/stack/S)
	var/target_amount = text2num(name)
	var/found_amount = 0

	if(istype(S, targetitem))
		found_amount = S.amount
	return found_amount>=target_amount

datum/objective_item/stack/diamond
	name = "десять алмазов"
	targetitem = /obj/item/stack/sheet/mineral/diamond
	difficulty = 10

datum/objective_item/stack/gold
	name = "пятьдесят слитков золота"
	targetitem = /obj/item/stack/sheet/mineral/gold
	difficulty = 15

datum/objective_item/stack/uranium
	name = "двадцать пять обработанных стержней урана"
	targetitem = /obj/item/stack/sheet/mineral/uranium
	difficulty = 10
