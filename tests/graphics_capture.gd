extends SceneTree
## Optional rendered QA harness. Output is ignored under build/graphics-qa/.

var demo: Control


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(640, 480)
	demo = load("res://ui/demo/ui_demo.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	demo.call("_choose_demo_background", "anchor")
	DirAccess.make_dir_recursive_absolute("res://build/graphics-qa")
	for room_name in ["lobby", "front_desk", "staff_office", "storage_room", "lost_found_hall", "maintenance_corridor", "exterior_entry", "loading_bay"]:
		demo.call("_load_demo_room", "res://rooms/demo/%s.tscn" % room_name)
		await create_timer(0.12).timeout
		await _capture(room_name)
	var room: Control = demo.get("_current_room")
	var player: Control = room.get("player")
	player.call("place_at_foot", room.call("_clamp_to_walk_bounds", Vector2(270, 246)))
	await _capture("depth_far")
	player.call("place_at_foot", room.call("_clamp_to_walk_bounds", Vector2(270, 378)))
	await _capture("depth_near")
	player.call("move_to", room.call("_clamp_to_walk_bounds", Vector2(500, 300)), room.get("walk_bounds"))
	await create_timer(0.18).timeout
	await _capture("walk")
	player.call("stop")
	demo.call("_open_dialogue", "mina")
	await _capture("dialogue_mina")
	demo.call("_close_all_modals")
	demo.call("_open_dialogue", "alex")
	await _capture("dialogue_alex")
	demo.call("_close_all_modals")
	demo.call("_open_notebook", "evidence")
	await _capture("notebook")
	demo.call("_close_all_modals")
	demo.call("_open_character")
	await _capture("character")
	demo.call("_close_all_modals")
	demo.call("_start_demo_combat")
	await _capture("combat")
	demo.call("_request_combat_action", "strike")
	await create_timer(0.15).timeout
	await _capture("combat_strike")
	await create_timer(0.6).timeout
	demo.get_node("CombatOverlay").visible = false
	demo.call("_set_demo_player_combat_pose", false)
	demo.call("_resolve_demo_case")
	await _capture("ending")
	quit()


func _capture(label: String) -> void:
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://build/graphics-qa/%s.png" % label)
	print("CAPTURE: ", label)
