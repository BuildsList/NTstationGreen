/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 90
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"


/obj/item/projectile/bullet/weakbullet
	damage = 1
	stun = 5
	weaken = 5


/obj/item/projectile/bullet/weakbullet2
	damage = 15
	stun = 5
	weaken = 5

/obj/item/projectile/bullet/weakbullet3
	damage = 30

/obj/item/projectile/bullet/pellet
	name = "pellet"
	damage = 20


/obj/item/projectile/bullet/midbullet
	damage = 30
	stun = 5
	weaken = 5


/obj/item/projectile/bullet/midbullet2
	damage = 35


/obj/item/projectile/bullet/midbullet3 //Only used with the Stechkin Pistol - RobRichards
	damage = 45

/obj/item/projectile/bullet/midbullet4 // c38 expansive
	damage = 60
	stun = 15
	weaken = 15

/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "co bullet"
	damage = 30
	damage_type = OXY


/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 60
	damage_type = TOX


/obj/item/projectile/bullet/burstbullet//I think this one needs something for the on hit
	name = "exploding bullet"
	damage = 35


/obj/item/projectile/bullet/stunslug
	name = "stunslug"
	damage = 2
	stun = 15
	weaken = 15
	stutter = 15


/obj/item/projectile/bullet/a762
	damage = 35


/obj/item/projectile/bullet/incendiary

/obj/item/projectile/bullet/incendiary/on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon))
				var/mob/living/carbon/M = target
				M.adjust_fire_stacks(1)
				M.IgniteMob()

/obj/item/projectile/bullet/incendiary/shell
	damage = 30

/obj/item/projectile/bullet/incendiary/mech
	damage = 7

/obj/item/projectile/bullet/incendiary/mid
	damage = 15

/obj/item/projectile/bullet/mime
	damage = 30
	trace_residue = null

/obj/item/projectile/bullet/mime/on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon))
				var/mob/living/carbon/M = target
				M.silent = max(M.silent, 15)


/obj/item/projectile/bullet/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6
	trace_residue = "Deep pinpricking."

	New()
		..()
		flags |= NOREACT
		create_reagents(75)

	on_hit(var/atom/target, var/blocked = 0, var/hit_zone)
		if(istype(target, /mob/living/carbon))
			var/mob/living/carbon/M = target
			if(M.can_inject(null,0,hit_zone)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				reagents.trans_to(M, reagents.total_volume)
				return 1
			else
				target.visible_message("<span class='danger'>The [name] was deflected!</span>", \
									   "<span class='userdanger'>You were protected against the [name]!</span>")
		flags &= ~NOREACT
		reagents.handle_reactions()
		return 1

/obj/item/projectile/bullet/dart/metalfoam
	New()
		..()
		reagents.add_reagent("aluminium", 15)
		reagents.add_reagent("foaming_agent", 5)
		reagents.add_reagent("pacid", 5)

//This one is for future syringe guns update
/obj/item/projectile/bullet/dart/syringe
	name = "syringe"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringeproj"

/obj/item/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 10
	damage_type = TOX
	weaken = 10
	trace_residue = "Sludge residue."

/obj/item/projectile/bullet/neurotoxin/on_hit(var/atom/target, var/blocked = 0)
	if(isalien(target))
		return 0
	..() // Execute the rest of the code.
