//Zlevel where overmap objects should be
#define OVERMAP_ZLEVEL 12
//How far from the edge of overmap zlevel could randomly placed objects spawn
#define OVERMAP_EDGE 7

//list used to track which zlevels are being 'moved' by the proc below
var/list/moving_levels = list()
//Proc to 'move' stars in spess
//yes it looks ugly, but it should only fire when state actually change.
//null direction stops movement
/proc/toggle_move_stars(var/obj/effect/map/ship/ship, direction)
	if(!ship)
		return

	var/gen_dir = null
	if(direction & (NORTH|SOUTH))
		gen_dir += "ns"
	else if(direction & (EAST|WEST))
		gen_dir += "ew"
	if(!direction)
		gen_dir = null

	for(var/zlevel in ship.ship_levels)
		if (ship.move_dir != gen_dir)
			ship.move_dir = gen_dir
			for(var/turf/space/S in ship.ship_turfs)
				var/turf/T = S
				if(!gen_dir)
					T.icon_state = "[((T.x + T.y) ^ ~(T.x * T.y) + T.z) % 25]"
				else
					T.icon_state = "speedspace_[gen_dir]_[rand(1,15)]"
					for(var/atom/movable/AM in T)
						if (!AM.anchored)
							AM.throw_at(get_step(T,reverse_direction(direction)), 5, 1)


//list used to cache empty zlevels to avoid nedless map bloat
var/list/cached_space = list()

/proc/overmap_spacetravel(var/turf/space/T, var/atom/movable/A)
	var/obj/effect/map/M = map_sectors["[T.z]"]
	if (!M)
		return
	var/mapx = M.x
	var/mapy = M.y
	var/nx = 1
	var/ny = 1
	var/nz = M.map_z

	if(T.x <= TRANSITIONEDGE)
		nx = world.maxx - TRANSITIONEDGE - 2
		ny = T.y
		mapx = max(1, mapx-1)

	else if (A.x >= (world.maxx - TRANSITIONEDGE - 1))
		nx = TRANSITIONEDGE + 2
		ny = T.y
		mapx = min(world.maxx, mapx+1)

	else if (T.y <= TRANSITIONEDGE)
		ny = world.maxy - TRANSITIONEDGE -2
		nx = T.x
		mapy = max(1, mapy-1)

	else if (A.y >= (world.maxy - TRANSITIONEDGE - 1))
		ny = TRANSITIONEDGE + 2
		nx = T.x
		mapy = min(world.maxy, mapy+1)

//	testing("[A] moving from [M] ([M.x], [M.y]) to ([mapx],[mapy]).")

	var/turf/map = locate(mapx,mapy,OVERMAP_ZLEVEL)
	var/obj/effect/map/TM = locate() in map
	if(TM)
		if(istype(TM, /obj/effect/map/ship))
			nz = pick(TM:ship_levels)
		else
			nz = TM.map_z
//		testing("Destination: [TM]")
	else
		if(cached_space.len)
			var/obj/effect/map/sector/temporary/cache = cached_space[cached_space.len]
			cached_space -= cache
			nz = cache.map_z
			cache.x = mapx
			cache.y = mapy
//			testing("Destination: *cached* [TM]")
		else
			world.maxz++
			nz = world.maxz
			TM = new /obj/effect/map/sector/temporary(mapx, mapy, nz)
//			testing("Destination: *new* [TM]")

	var/turf/dest = locate(nx,ny,nz)
	if(dest)
		A.loc = dest

	if(istype(M, /obj/effect/map/sector/temporary))
		var/obj/effect/map/sector/temporary/source = M
		if (source.can_die())
//			testing("Catching [M] for future use")
			source.loc = null
			cached_space += source

	if ((A && A.loc))
		A.loc.Entered(A)
		//now we're on the new z_level, proceed the space drifting
		A.newtonian_move(A.inertia_dir)
