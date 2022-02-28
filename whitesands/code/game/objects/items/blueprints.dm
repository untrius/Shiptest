/obj/item/areaeditor/shuttle
	name = "shuttle expansion permit"
	desc = "A set of paperwork which is used to expand flyable shuttles."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "blueprints"
	color = COLOR_ASSEMBLY_WHITE
	fluffnotice = "Not to be used for non-sanctioned shuttle construction and maintenance."
	var/obj/docking_port/mobile/target_shuttle

/obj/item/areaeditor/shuttle/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/machinery/computer/helm))
		var/obj/machinery/computer/helm/H = target
		target_shuttle = H.current_ship.shuttle_port

/obj/item/areaeditor/shuttle/attack_self(mob/user)
	. = ..()
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(user, "blueprints")

/obj/item/areaeditor/shuttle/Topic(href, href_list)
	if(!usr.canUseTopic(src) || usr != loc)
		usr << browse(null, "window=blueprints")
		return TRUE
	if(href_list["create_area"])
		if(in_use)
			return
		if(!target_shuttle)
			to_chat(usr, "<span class='warning'>You need to designate a shuttle to expand by linking the helm console to these plans.</span>")
			return
		var/area/A = get_area(usr)
		if(A.area_flags & NOTELEPORT)
			to_chat(usr, "<span class='warning'>You cannot edit restricted areas.</span>")
			return
		in_use = TRUE
		create_shuttle_area(usr)
		in_use = FALSE
	updateUsrDialog()

// Virtually a copy of create_area() with specialized behaviour
/obj/item/areaeditor/shuttle/proc/create_shuttle_area(mob/creator)
	// Passed into the above proc as list/break_if_found
	var/static/area_or_turf_fail_types = typecacheof(list(
		/turf/open/space,
		))
	// Ignore these areas and dont let people expand them. They can expand into them though
	var/static/blacklisted_areas = typecacheof(list(
		/area/space,
		))

	if(creator)
		if(creator.create_area_cooldown >= world.time)
			to_chat(creator, "<span class='warning'>You're trying to create a new area a little too fast.</span>")
			return
		creator.create_area_cooldown = world.time + 10

	var/list/turfs = detect_room(get_turf(creator), area_or_turf_fail_types, BP_MAX_ROOM_SIZE*2)
	if(!turfs)
		to_chat(creator, "<span class='warning'>The new area must be completely airtight.</span>")
		return
	if(turfs.len > BP_MAX_ROOM_SIZE)
		to_chat(creator, "<span class='warning'>The room you're in is too big. It is [turfs.len >= BP_MAX_ROOM_SIZE *2 ? "more than 100" : ((turfs.len / BP_MAX_ROOM_SIZE)-1)*100]% larger than allowed.</span>")
		return
	var/list/areas = list("New Area" = /area/ship)
	var/list/shuttle_coords = target_shuttle.return_coords()
	var/near_shuttle = FALSE
	for(var/i in 1 to turfs.len)
		var/area/place = get_area(turfs[i])
		if(blacklisted_areas[place.type])
			continue
		if(!place.requires_power || (place.area_flags & NOTELEPORT) || (place.area_flags & HIDDEN_AREA))
			continue // No expanding powerless rooms etc
		areas[place.name] = place

		// The following code checks to see if the tile is within one tile of the target shuttle
		if(near_shuttle)
			continue
		var/turf/T = turfs[i]
		if(T.z == target_shuttle.z)
			if(T.x >= (min(shuttle_coords[1], shuttle_coords[3]) - 1) && T.x <= (max(shuttle_coords[1], shuttle_coords[3]) + 1))
				if(T.y >= (min(shuttle_coords[2], shuttle_coords[4]) - 1) && T.y <= (max(shuttle_coords[2], shuttle_coords[4]) + 1))
					near_shuttle = TRUE
	if(!near_shuttle)
		to_chat(creator, "<span class='warning'>The new area must be next to the shuttle.</span>")
		return
	var/area_choice = input(creator, "Choose an area to expand or make a new area.", "Area Expansion") as null|anything in areas
	area_choice = areas[area_choice]

	if(!area_choice)
		to_chat(creator, "<span class='warning'>No choice selected. The area remains undefined.</span>")
		return
	var/area/newA
	var/area/oldA = get_area(get_turf(creator))
	if(!isarea(area_choice))
		var/str = stripped_input(creator,"New area name:", "Blueprint Editing", "", MAX_NAME_LEN)
		if(!str || !length(str)) //cancel
			return
		if(length(str) > 50)
			to_chat(creator, "<span class='warning'>The given name is too long. The area remains undefined.</span>")
			return
		newA = new area_choice
		newA.setup(str)
		newA.set_dynamic_lighting()
		newA.has_gravity = oldA.has_gravity
	else
		newA = area_choice

	for(var/i in 1 to turfs.len)
		var/turf/thing = turfs[i]
		var/area/old_area = thing.loc
		newA.contents += thing
		thing.change_area(old_area, newA)

		if(istype(thing, /turf/open/space))
			continue
		if(length(thing.baseturfs) < 2)
			continue
		//Add the shuttle base shit to the shuttle
		if(!(/turf/baseturf_skipover/shuttle in thing.baseturfs))
			thing.baseturfs.Insert(3, /turf/baseturf_skipover/shuttle)

	var/list/firedoors = oldA.firedoors
	for(var/door in firedoors)
		var/obj/machinery/door/firedoor/FD = door
		FD.CalculateAffectingAreas()

	target_shuttle.shuttle_areas[newA] = TRUE

	newA.connect_to_shuttle(target_shuttle, target_shuttle.get_docked())
	for(var/atom/thing in newA)
		thing.connect_to_shuttle(target_shuttle, target_shuttle.get_docked())

	target_shuttle.recalculate_bounds()

	to_chat(creator, "<span class='notice'>You have created a new area, named [newA.name]. It is now weather proof, and constructing an APC will allow it to be powered.</span>")
	return TRUE

// VERY EXPENSIVE (I think)
/obj/docking_port/mobile/proc/recalculate_bounds()
	if(!istype(src, /obj/docking_port/mobile))
		return FALSE
	//Heights is the distance away from the port
	//width is the distance perpendicular to the port
	var/minX = INFINITY
	var/maxX = 0
	var/minY = INFINITY
	var/maxY = 0
	for(var/area/A in shuttle_areas)
		for(var/turf/T in A)
			minX = min(T.x, minX)
			maxX = max(T.x, maxX)
			minY = min(T.y, minY)
			maxY = max(T.y, maxY)
	//Make sure shuttle was actually found.
	if(maxX == INFINITY || maxY == INFINITY)
		return FALSE
	minX--
	minY--
	var/new_width = maxX - minX
	var/new_height = maxY - minY
	var/offset_x = x - minX
	var/offset_y = y - minY
	switch(dir) //Source: code/datums/shuttles.dm line 77 (14/03/2020) :)
		if(NORTH)
			width = new_width
			height = new_height
			dwidth = offset_x - 1
			dheight = offset_y - 1
		if(EAST)
			width = new_height
			height = new_width
			dwidth = new_height - offset_y
			dheight = offset_x - 1
		if(SOUTH)
			width = new_width
			height = new_height
			dwidth = new_width - offset_x
			dheight = new_height - offset_y
		if(WEST)
			width = new_height
			height = new_width
			dwidth = offset_y - 1
			dheight = new_width - offset_x
	qdel(assigned_transit, TRUE)
	assigned_transit = null
