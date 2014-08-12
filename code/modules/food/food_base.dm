
//Bases for customizable food

/obj/item/weapon/reagent_containers/food/snacks/base/pizza
	name = "pizza base"
	desc = "A base for somewhat pizza."
	icon_state = "personal_pizza"


/obj/item/weapon/reagent_containers/food/snacks/base/pie
	name = "pie base"
	desc = "Base for a pie."
	icon_state = "piecustom"


/obj/item/weapon/reagent_containers/food/snacks/base/pie/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/pie/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)
	..()

/obj/item/weapon/reagent_containers/food/snacks/base/cake
	name = "cake base"
	desc = "Base for a delicious (or not) cake."
	icon_state = "cakecustom"


/obj/item/weapon/reagent_containers/food/snacks/base/cake/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/cake/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)
	..()


/obj/item/weapon/reagent_containers/food/snacks/base/jelly
	name = "jelly base"
	desc = "Totally jelly."
	icon_state = "jellycustom"


/obj/item/weapon/reagent_containers/food/snacks/base/jelly/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/jelly/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)
	..()

/obj/item/weapon/reagent_containers/food/snacks/base/donkpocket
	name = "donk pocket base"
	desc = "You wanna put a bangin donk on it."
	icon_state = "donkcustom"


/obj/item/weapon/reagent_containers/food/snacks/base/donkpocket/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/donkpocket/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)
	..()

/obj/item/weapon/reagent_containers/food/snacks/base/bread
	name = "bread base"
	desc = "Base for a bread."
	icon_state = "breadcustom"


/obj/item/weapon/reagent_containers/food/snacks/base/bread/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/bread/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)
	..()
