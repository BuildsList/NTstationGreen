/*Summon Keys:
"guns"
"magic"
"mechs"
"melee"
*/

/mob/proc/magic_summon(var/summon_type)
	var/list/summon_gunslist 			= list("taser","egun","laser","revolver","detective","smg","nuclear","deagle","gyrojet","pulse","silenced","cannon","doublebarrel","shotgun","combatshotgun","mateba","smg","uzi","crossbow","saw","tommy","retro","stunrevolver","glock","m1911", "m1911b")
	var/list/summon_magiclist 			= list("fireball","smoke","blind","mindswap","forcewall","knock","horsemask","charge","wandnothing", "wanddeath", "wandresurrection", "wandpolymorph", "wandteleport", "wanddoor", "wandfireball", "staffchange", "staffhealing", "armor", "scrying", "staffdoor", "special")
	var/list/summon_magicspeciallist	= list("staffchange","staffanimation", "wandbelt", "contract", "staffchaos")
	var/list/summon_mechslist			= list("durand","gygax","d-gygax","marauder","mauler","seraph","d-ripley","reticence","HONK")
	var/list/summon_meleelist			= list("katana","claymore","e-axe","e-sword","fireaxe","singu-ham","mjolnir","2-e-sword","spear")

	usr << "<B>You summoned [summon_type]!</B>"
	message_admins("[key_name_admin(usr, 1)] summoned [summon_type].")
	log_game("[key_name(usr)] summoned [summon_type].")
	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(H.mind)
			if(H.mind.special_role == "Wizard" || H.mind.special_role == "apprentice") continue
		if(prob(25) && !(H.mind in ticker.mode.traitors))
			ticker.mode.traitors += H.mind
			H.mind.special_role = "traitor"
			var/datum/objective/survive/survive = new
			survive.owner = H.mind
			H.mind.objectives += survive
			H.attack_log += "\[[time_stamp()]\] <font color='red'>Was made into a survivor, and trusts no one!</font>"
			H << "<B>You are the survivor! Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...</B>"
			var/obj_count = 1
			for(var/datum/objective/OBJ in H.mind.objectives)
				H << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
				obj_count++

		var/randomizeguns 			= pick(summon_gunslist)
		var/randomizemagic 			= pick(summon_magiclist)
		var/randomizemagicspecial 	= pick(summon_magicspeciallist)
		var/randomizemechs			= pick(summon_mechslist)
		var/randomizemelee			= pick(summon_meleelist)

		switch(summon_type)
			if("guns")
				switch (randomizeguns)
					if("taser")
						new /obj/item/weapon/gun/energy/taser(get_turf(H))
					if("egun")
						new /obj/item/weapon/gun/energy/gun(get_turf(H))
					if("laser")
						new /obj/item/weapon/gun/energy/laser(get_turf(H))
					if("revolver")
						new /obj/item/weapon/gun/projectile/revolver(get_turf(H))
					if("detective")
						new /obj/item/weapon/gun/projectile/revolver/detective(get_turf(H))
					if("smg")
						new /obj/item/weapon/gun/projectile/automatic/c20r(get_turf(H))
					if("nuclear")
						new /obj/item/weapon/gun/energy/gun/nuclear(get_turf(H))
					if("deagle")
						new /obj/item/weapon/gun/projectile/automatic/deagle/camo(get_turf(H))
					if("gyrojet")
						new /obj/item/weapon/gun/projectile/automatic/gyropistol(get_turf(H))
					if("pulse")
						new /obj/item/weapon/gun/energy/pulse_rifle(get_turf(H))
					if("silenced")
						new /obj/item/weapon/gun/projectile/automatic/pistol(get_turf(H))
						new /obj/item/weapon/silencer(get_turf(H))
					if("cannon")
						new /obj/item/weapon/gun/energy/lasercannon(get_turf(H))
					if("doublebarrel")
						new /obj/item/weapon/gun/projectile/revolver/doublebarrel(get_turf(H))
					if("shotgun")
						new /obj/item/weapon/gun/projectile/shotgun/(get_turf(H))
					if("combatshotgun")
						new /obj/item/weapon/gun/projectile/shotgun/combat(get_turf(H))
					if("mateba")
						new /obj/item/weapon/gun/projectile/revolver/mateba(get_turf(H))
					if("smg")
						new /obj/item/weapon/gun/projectile/automatic(get_turf(H))
					if("uzi")
						new /obj/item/weapon/gun/projectile/automatic/mini_uzi(get_turf(H))
					if("crossbow")
						new /obj/item/weapon/gun/energy/crossbow(get_turf(H))
					if("saw")
						new /obj/item/weapon/gun/projectile/automatic/l6_saw(get_turf(H))
					if("tommy")
						new /obj/item/weapon/gun/projectile/automatic/tommygun(get_turf(H))
					if("retro")
						new /obj/item/weapon/gun/energy/laser/retro(get_turf(H))
					if("stunrevolver")
						new /obj/item/weapon/gun/energy/stunrevolver(get_turf(H))
					if("glock")
						new /obj/item/weapon/gun/projectile/automatic/deagle/glock(get_turf(H))
					if("m1911")
						new /obj/item/weapon/gun/projectile/automatic/deagle/m1911(get_turf(H))
					if("m1911b")
						new /obj/item/weapon/gun/projectile/automatic/deagle/m1911/black(get_turf(H))

			if("magic")
				switch (randomizemagic)
					if("fireball")
						new /obj/item/weapon/spellbook/oneuse/fireball(get_turf(H))
					if("smoke")
						new /obj/item/weapon/spellbook/oneuse/smoke(get_turf(H))
					if("blind")
						new /obj/item/weapon/spellbook/oneuse/blind(get_turf(H))
					if("mindswap")
						new /obj/item/weapon/spellbook/oneuse/mindswap(get_turf(H))
					if("forcewall")
						new /obj/item/weapon/spellbook/oneuse/forcewall(get_turf(H))
					if("knock")
						new /obj/item/weapon/spellbook/oneuse/knock(get_turf(H))
					if("horsemask")
						new /obj/item/weapon/spellbook/oneuse/horsemask(get_turf(H))
					if("charge")
						new /obj/item/weapon/spellbook/oneuse/charge(get_turf(H))
					if("wandnothing")
						new /obj/item/weapon/gun/magic/wand(get_turf(H))
					if("wanddeath")
						new /obj/item/weapon/gun/magic/wand/death(get_turf(H))
					if("wandresurrection")
						new /obj/item/weapon/gun/magic/wand/resurrection(get_turf(H))
					if("wandpolymorph")
						new /obj/item/weapon/gun/magic/wand/polymorph(get_turf(H))
					if("wandteleport")
						new /obj/item/weapon/gun/magic/wand/teleport(get_turf(H))
					if("wanddoor")
						new /obj/item/weapon/gun/magic/wand/door(get_turf(H))
					if("staffhealing")
						new /obj/item/weapon/gun/magic/staff/healing(get_turf(H))
					if("staffdoor")
						new /obj/item/weapon/gun/magic/staff/door(get_turf(H))
					if("armor")
						new /obj/item/clothing/suit/space/rig/wizard(get_turf(H))
						new /obj/item/clothing/head/helmet/space/rig/wizard(get_turf(H))
					if("scrying")
						new /obj/item/weapon/scrying(get_turf(H))
						if (!H.has_organic_effect(/datum/organic_effect/xray))
							H.add_organic_effect(/datum/organic_effect/xray)
							H.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
							H.see_in_dark = 8
							H.see_invisible = SEE_INVISIBLE_LEVEL_TWO
							H << "<span class='notice'>The walls suddenly disappear.</span>"
					if("special")
						summon_magiclist -= "special" //only one super OP item per summoning max
						switch (randomizemagicspecial)
							if("staffchange")
								new /obj/item/weapon/gun/magic/staff/change(get_turf(H))
							if("staffanimation")
								new /obj/item/weapon/gun/magic/staff/animate(get_turf(H))
							if("wandbelt")
								new /obj/item/weapon/storage/belt/wands/full(get_turf(H))
							if("contract")
								new /obj/item/weapon/antag_spawner/contract(get_turf(H))
							if("staffchaos")
								new /obj/item/weapon/gun/magic/staff/chaos(get_turf(H))
						H << "<span class='notice'>You suddenly feel lucky.</span>"
			if("mechs")
				switch(randomizemechs)
					if("durand")
						var/obj/mecha/combat/durand/loaded/D = new /obj/mecha/combat/durand/loaded(get_turf(H))
						D.cell = new /obj/item/weapon/stock_parts/cell/infinite(D)
					if("gygax")
						var/obj/mecha/combat/gygax/loaded/G = new /obj/mecha/combat/gygax/loaded(get_turf(H))
						G.cell = new /obj/item/weapon/stock_parts/cell/infinite(G)
					if("d-gygax")
						var/obj/mecha/combat/gygax/dark/D = new /obj/mecha/combat/gygax/dark/loaded(get_turf(H))
						D.operation_req_access = list()
						D.cell = new /obj/item/weapon/stock_parts/cell/infinite(D)
					if("marauder")
						summon_mechslist -= "marauder"
						var/obj/mecha/combat/marauder/M = new /obj/mecha/combat/marauder/loaded(get_turf(H))
						M.operation_req_access = list()
						M.cell = new /obj/item/weapon/stock_parts/cell/infinite(M)
					if("mauler")
						summon_mechslist -= "mauler"
						var/obj/mecha/combat/marauder/mauler/MM = new /obj/mecha/combat/marauder/mauler/loaded(get_turf(H))
						MM.operation_req_access = list()
						MM.cell = new /obj/item/weapon/stock_parts/cell/infinite(MM)
					if("seraph")
						summon_mechslist -= "seraph"
						var/obj/mecha/combat/marauder/seraph/S = new /obj/mecha/combat/marauder/seraph(get_turf(H))
						S.operation_req_access = list()
						S.cell = new /obj/item/weapon/stock_parts/cell/infinite(S)
					if("d-ripley")
						var/obj/mecha/working/ripley/deathripley/DR = new /obj/mecha/working/ripley/deathripley(get_turf(H))
						DR.cell = new /obj/item/weapon/stock_parts/cell/infinite(DR)
					if("reticence")
						var/obj/mecha/combat/reticence/R = new /obj/mecha/combat/reticence/loaded(get_turf(H))
						R.operation_req_access = list()
						R.cell = new /obj/item/weapon/stock_parts/cell/infinite(R)
					if("HONK")
						var/obj/mecha/combat/honker/HONK = new /obj/mecha/combat/honker/loaded(get_turf(H))
						HONK.operation_req_access = list()
						HONK.cell = new /obj/item/weapon/stock_parts/cell/infinite(HONK)
			if("melee")
				switch(randomizemelee)
					if("katana")
						new /obj/item/weapon/katana(get_turf(H))
					if("claymore")
						new /obj/item/weapon/claymore(get_turf(H))
					if("e-axe")
						new /obj/item/weapon/melee/energy/axe(get_turf(H))
					if("e-sword")
						new /obj/item/weapon/melee/energy/sword(get_turf(H))
					if("fireaxe")
						new /obj/item/weapon/twohanded/fireaxe(get_turf(H))
					if("singu-ham")
						new /obj/item/weapon/twohanded/singularityhammer(get_turf(H))
					if("mjolnir")
						new /obj/item/weapon/twohanded/mjollnir(get_turf(H))
					if("2-e-sword")
						new /obj/item/weapon/twohanded/dualsaber(get_turf(H))
					if("spear")
						new /obj/item/weapon/twohanded/spear(get_turf(H))
