//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 250
	var/obj/item/weapon/charging = null

/obj/machinery/recharger/attackby(obj/item/weapon/G as obj, mob/user as mob)
	if(istype(user,/mob/living/silicon))
		return
	if(istype(G, /obj/item/weapon/gun/energy) || istype(G, /obj/item/weapon/melee/baton) || istype(G, /obj/item/weapon/cell/crap))
		if(charging)
			return

		// Checks to make sure he's not in space doing it, and that the area got proper power.
		var/area/a = get_area(src)
		if(!isarea(a))
			user << "\red The [name] blinks red as you try to insert the item!"
			return
		if(a.power_equip == 0)
			user << "\red The [name] blinks red as you try to insert the item!"
			return


		if (istype(G, /obj/item/weapon/gun/energy/taser/leet))
			var/obj/item/weapon/gun/energy/taser/leet/T = G
			if(!T.power_supply)
				to_chat(usr, "<span class='notice'>How are you going to charge a gun without a battery?</span>")
				return

		user.drop_item()
		G.loc = src
		charging = G
		use_power = 2
		update_icon()
	else if(istype(G, /obj/item/weapon/wrench))
		if(charging)
			user << "\red Remove the weapon first!"
			return
		anchored = !anchored
		user << "You [anchored ? "attached" : "detached"] the recharger."
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)

/obj/machinery/recharger/attack_hand(mob/user as mob)
	add_fingerprint(user)

	if(charging)
		charging.update_icon()
		charging.loc = loc
		if(istype(charging, /obj/item/weapon/cell/crap))
			var/obj/item/weapon/cell/crap/C = charging
			C.updateicon()
		charging = null
		use_power = 1
		update_icon()

/obj/machinery/recharger/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/recharger/attack_tk(mob/user)
	if(charging)
		charging.update_icon()
		charging.loc = loc
		charging = null
		use_power = 1
		update_icon()

/obj/machinery/recharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = charging
			if(E.power_supply.charge < E.power_supply.maxcharge)
				E.power_supply.give(100)
				icon_state = "recharger1"
				use_power(250)
			else
				icon_state = "recharger2"
			return
		if(istype(charging, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = charging
			if(B.charges < initial(B.charges))
				B.charges++
				icon_state = "recharger1"
				use_power(150)
			else
				icon_state = "recharger2"

		if(istype(charging, /obj/item/weapon/cell/crap))
			var/obj/item/weapon/cell/crap/C = charging
			if(C.charge < C.maxcharge)
				icon_state = "recharger1"
				use_power(C.give(100))
			else
				icon_state = "recharger2"

/obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging,  /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/E = charging
		if(E.power_supply)
			E.power_supply.emp_act(severity)

	else if(istype(charging, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = charging
		B.charges = 0
	..(severity)

/obj/machinery/recharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		icon_state = "recharger1"
	else
		icon_state = "recharger0"

/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"

/obj/machinery/recharger/wallcharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = charging
			if(E.power_supply.charge < E.power_supply.maxcharge)
				E.power_supply.give(100)
				icon_state = "wrecharger1"
				use_power(250)
			else
				icon_state = "wrecharger2"
			return
		if(istype(charging, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = charging
			if(B.charges < initial(B.charges))
				B.charges++
				icon_state = "wrecharger1"
				use_power(150)
			else
				icon_state = "wrecharger2"

/obj/machinery/recharger/wallcharger/update_icon()
	if(charging)
		icon_state = "wrecharger1"
	else
		icon_state = "wrecharger0"