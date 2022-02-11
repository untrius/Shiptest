/obj/overmap
	icon = 'whitesands/icons/effects/overmap.dmi'
	///~~If we need to render a map for cameras and helms for this object~~ basically can you look at and use this as a ship or station.
	var/render_map = FALSE
	/// The parent overmap datum for this overmap token that has all of the actual functionality.
	var/datum/overmap/parent
	// Stuff needed to render the map
	var/map_name
	var/atom/movable/screen/map_view/cam_screen
	var/atom/movable/screen/plane_master/lighting/cam_plane_master
	var/atom/movable/screen/background/cam_background

/obj/overmap/rendered
	render_map = TRUE

/obj/overmap/Initialize(mapload, new_parent)
	. = ..()
	parent = new_parent
	name = parent.name
	icon_state = parent.token_icon_state
	if(render_map)	// Initialize map objects
		map_name = "overmap_[REF(src)]_map"
		cam_screen = new
		cam_screen.name = "screen"
		cam_screen.assigned_map = map_name
		cam_screen.del_on_map_removal = FALSE
		cam_screen.screen_loc = "[map_name]:1,1"
		cam_plane_master = new
		cam_plane_master.name = "plane_master"
		cam_plane_master.assigned_map = map_name
		cam_plane_master.del_on_map_removal = FALSE
		cam_plane_master.screen_loc = "[map_name]:CENTER"
		cam_background = new
		cam_background.assigned_map = map_name
		cam_background.del_on_map_removal = FALSE
		update_screen()

/obj/overmap/Destroy(force)
	if(parent)
		return QDEL_HINT_LETMELIVE
	return ..()

/obj/overmap/attack_ghost(mob/user)
	. = ..()
	var/turf/jump_to_turf = parent.get_jump_to_turf()
	if(!jump_to_turf)
		return
	user.forceMove(jump_to_turf)

/**
  * Updates the screen object, which is displayed on all connected helms
  */
/obj/overmap/proc/update_screen()
	if(render_map)
		var/list/visible_turfs = list()
		for(var/turf/T in view(4, get_turf(src)))
			visible_turfs += T

		var/list/bbox = get_bbox_of_atoms(visible_turfs)
		var/size_x = bbox[3] - bbox[1] + 1
		var/size_y = bbox[4] - bbox[2] + 1

		cam_screen?.vis_contents = visible_turfs
		cam_background.icon_state = "clear"
		cam_background.fill_rect(1, 1, size_x, size_y)
		return TRUE
