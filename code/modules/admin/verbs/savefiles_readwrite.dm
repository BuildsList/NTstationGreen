// In this file:
// * A lot of hacks to make stuff save/load correctly
// * A lot of hacks to keep save files small
// * A lot of hacks to stop server crashes on save


// Reduces save file size
/atom/movable/Write(var/savefile/F)
	..()
	F.dir.Remove("tag", "suit_fibers", "blood_DNA",
	"fingerprints", "fingerprintshidden", "fingerprintslast")

	if(F["attack_verb"])
		var/list/verbs = F["attack_verb"]
		if(!verbs.len)
			F.dir.Remove("attack_verb")

/mob/Write(var/savefile/F)
	..()
	F.dir.Remove("attack_log", "lastattacker", "lastattacked")


/obj/item/Write(var/savefile/F)
	..()
	if(!armor["melee"] && !armor["bullet"] && !armor["laser"] && !armor["energy"] && !armor["bomb"] && !armor["bio"] && !armor["rad"])
		F.dir.Remove("armor")

/obj/item/Read(var/savefile/F)
	..()
	if(!F["armor"])
		armor = list("melee" = 0,"bullet" = 0,"laser" = 0,"energy" = 0,"bomb" = 0,"bio" = 0,"rad" = 0)

/obj/item/weapon/Write(var/savefile/F)
	..()
	if((damtype == "fire" && hitsound == 'sound/items/welder.ogg') || (damtype == "brute" && hitsound == "swing_hit"))
		F.dir.Remove("hitsound")

/obj/item/weapon/stock_parts/cell/Write(var/savefile/F)
	..()
	F.dir.Remove("overlays")



// Reduces save file size and updates icons correctly
/mob/living/carbon/human/Write(var/savefile/F)
	..()
	F.dir.Remove("overlays")

/mob/Read()
	..()
	regenerate_icons()


// Removing block so badminspawned injectors will get updated block at New()
/obj/item/weapon/dnainjector/Write(var/savefile/F)
	..()
	if(type != /obj/item/weapon/dnainjector) // Not a base type injector
		F.dir.Remove("fields")


// Resetting type to base type so contents will not be respawned twice
/obj/item/weapon/storage/Write(var/savefile/F)
	..()
	var/list/base_simple = list(
		/obj/item/weapon/storage/belt/utility,
		/obj/item/weapon/storage/secure/safe,
		/obj/item/weapon/storage/bible,
		/obj/item/weapon/storage/belt/soulstone,
		/obj/item/weapon/storage/belt/wands,
		/obj/item/weapon/storage/wallet,
		/obj/item/weapon/storage/backpack/satchel)

	for(var/b_type in base_simple)
		if(istype(src, b_type))
			F["type"] << b_type

/obj/item/weapon/storage/box/Write(var/savefile/F)
	..()
	if(type != /obj/item/weapon/storage/box) // Not a base type box
		var/list/ignored_types = list(
			/obj/item/weapon/storage/box/monkeycubes,
			/obj/item/weapon/storage/box/matches,
			/obj/item/weapon/storage/box/snappops)

		if(!(type in ignored_types))
			F["type"] << /obj/item/weapon/storage/box
			F["name"] << name
			F["desc"] << desc
			F["icon_state"] << icon_state
			F["storage_slots"] << storage_slots
			F["max_combined_w_class"] << max_combined_w_class
			F["use_to_pickup"] << use_to_pickup
			F["w_class"] << w_class
		else
			F.dir.Remove("contents")


/obj/item/weapon/storage/toolbox/Write(var/savefile/F)
	..()
	if(type != /obj/item/weapon/storage/toolbox) // Not a base type toolbox
		var/list/ignored_types = list()

		if(!(type in ignored_types))
			F["type"] << /obj/item/weapon/storage/toolbox
			F["name"] << name
			F["desc"] << desc
			F["icon_state"] << icon_state
		else
			F.dir.Remove("contents")


// Removes mobs from blood's donor. We do not want to S/L the whole mob from blood syringe
/datum/reagent/blood/Write(var/savefile/F)
	var/donor = data["donor"]
	data["donor"] = null
	..()
	data["donor"] = donor



// Special roles save/load
/datum/mind/Write(var/savefile/F)
	..()
	var/list/roles = list()

	if(src in ticker.mode.changelings)
		roles.Add("changeling")
	if(src in ticker.mode.wizards)
		roles.Add("wizard")
	if(src in ticker.mode.cult)
		roles.Add("cult")
	if(src in ticker.mode.syndicates)
		roles.Add("operative")
	if(src in ticker.mode.head_revolutionaries)
		roles.Add("head_rev")
	if(src in ticker.mode.revolutionaries)
		roles.Add("rev")
	if(src in ticker.mode.traitors)
		roles.Add("traitor")

	if(roles.len)
		F["roles"] << roles

/datum/mind/Read(var/savefile/F)
	..()
	var/list/roles
	F["roles"] >> roles

	if(!roles || !roles.len )
		return

	for(var/role in roles)
		switch(role)
			if("changeling")
				ticker.mode.changelings.Add(src)
			if("wizard")
				ticker.mode.wizards.Add(src)
			if("cult")
				ticker.mode.add_cultist(src)
			if("operative")
				ticker.mode.syndicates.Add(src)
			if("rev")
				ticker.mode.add_revolutionary(src)
			if("head_rev")
				ticker.mode.head_revolutionaries.Add(src)
				ticker.mode.update_rev_icons_added(src)
				ticker.mode.forge_revolutionary_objectives(src)
			if("traitor")
				ticker.mode.traitors.Add(src)



// Not save any vars for this items:

// Because grabs are totally /tmp/ objects
/obj/item/weapon/grab/Write(var/savefile/F)
	return

/obj/item/tk_grab/Write(var/savefile/F)
	return

// Because saving 50 boolets can trigger infinite loop check.
// Boolets are respawned on New when magazine is loaded.
/obj/item/ammo_box/magazine/m762/Write(var/savefile/F)
	return