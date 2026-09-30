extends SceneTree

const TEST_PATH := "user://slice4_persistence_test.json"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_serialization_and_migration()
	await _test_canonical_room_restore()
	_cleanup_test_file()

	if failures.is_empty():
		print("PERSISTENCE_OK: schema, file round-trip, migration, canonical room state, and restore are valid")
		quit(0)
		return

	for failure in failures:
		push_error("PERSISTENCE_FAIL: %s" % failure)
	quit(1)


func _test_serialization_and_migration() -> void:
	var state_script := load("res://autoload/game_state.gd") as Script
	var save_script := load("res://autoload/save_service.gd") as Script
	var state: Node = state_script.new()
	var saves: Node = save_script.new()
	root.add_child(state)
	root.add_child(saves)

	state.call("reset_new_game")
	state.call("set_room", "res://rooms/ch01/corridor_room.tscn", "ch01_corridor", Vector2(222, 333))
	state.set("clues", {"packet": {"detail": 1}})
	state.set("chapter_flags", {"door_checked": true})
	state.set("inventory", ["removable_media"])
	state.set("playtime_seconds", 42.5)

	var source: Dictionary = state.call("to_serializable_state")
	var document: Dictionary = saves.call("build_document", source)
	var encoded: String = saves.call("encode_document", document)
	var decoded: Dictionary = saves.call("decode_document", encoded)

	if not bool(decoded.get("ok", false)):
		failures.append("valid save document did not decode")
	else:
		var decoded_document: Dictionary = decoded["document"]
		var decoded_state: Dictionary = decoded_document["state"]
		if String(decoded_state.get("current_room_id", "")) != "ch01_corridor":
			failures.append("room id was not preserved in serialization")
		if not bool((decoded_state.get("chapter_flags", {}) as Dictionary).get("door_checked", false)):
			failures.append("chapter flag was not preserved in serialization")

	var second_state: Node = state_script.new()
	root.add_child(second_state)
	if not bool(second_state.call("apply_serializable_state", source)):
		failures.append("serialized state could not be applied")
	elif second_state.get("current_player_foot") != Vector2(222, 333):
		failures.append("player foot did not survive state round-trip")

	if bool((saves.call("decode_document", "not-json") as Dictionary).get("ok", false)):
		failures.append("invalid JSON was accepted")

	var future_result: Dictionary = saves.call("validate_and_migrate", {
		"schema_version": 999,
		"state": {},
	})
	if bool(future_result.get("ok", false)):
		failures.append("future schema was accepted")

	var migrated: Dictionary = saves.call("validate_and_migrate", {
		"schema_version": 0,
		"content_version": "legacy-test",
		"state": {
			"room": "res://rooms/ch01/test_room.tscn",
			"room_id": "ch01_workstation",
			"player_foot": {"x": 145, "y": 366},
			"flags": {"legacy_flag": true},
		},
	})
	if not bool(migrated.get("ok", false)):
		failures.append("schema 0 migration failed")
	else:
		var migrated_state: Dictionary = (migrated["document"] as Dictionary)["state"]
		if String(migrated_state.get("current_room_id", "")) != "ch01_workstation":
			failures.append("legacy room id migration failed")
		if not bool((migrated_state.get("chapter_flags", {}) as Dictionary).get("legacy_flag", false)):
			failures.append("legacy flag migration failed")

	if not bool(saves.call("write_document_to_path", TEST_PATH, document)):
		failures.append("save document file write failed")
	else:
		var disk_result: Dictionary = saves.call("read_document_from_path", TEST_PATH)
		if not bool(disk_result.get("ok", false)):
			failures.append("save document file read failed")
		else:
			var disk_state: Dictionary = (disk_result["document"] as Dictionary)["state"]
			if String(disk_state.get("current_room_id", "")) != "ch01_corridor":
				failures.append("file round-trip changed canonical state")

	state.queue_free()
	second_state.queue_free()
	saves.queue_free()


func _test_canonical_room_restore() -> void:
	var router := root.get_node_or_null("SceneRouter")
	var game_state := root.get_node_or_null("GameState")
	if router == null or game_state == null:
		failures.append("autoload services were not available to persistence test")
		return

	var host := Control.new()
	root.add_child(host)
	router.call("attach_room_host", host)

	game_state.call("reset_new_game")
	if not bool(router.call("go_to_room", "res://rooms/ch01/corridor_room.tscn", "FromWorkstation", Vector2(-1, -1), false)):
		failures.append("canonical transition failed")
		host.queue_free()
		return

	await process_frame
	if String(game_state.get("current_room_path")) != "res://rooms/ch01/corridor_room.tscn":
		failures.append("room transition did not update canonical room path")
	if String(game_state.get("current_room_id")) != "ch01_corridor":
		failures.append("room transition did not update canonical room id")

	var saved: Dictionary = game_state.call("to_serializable_state")
	saved["current_room_path"] = "res://rooms/ch01/test_room.tscn"
	saved["current_room_id"] = "ch01_workstation"
	saved["current_player_foot"] = {"x": 200, "y": 350}
	game_state.call("apply_serializable_state", saved)

	if not bool(router.call("restore_from_state")):
		failures.append("router could not restore canonical room state")
	else:
		await process_frame
		if String(game_state.get("current_room_id")) != "ch01_workstation":
			failures.append("restored room id is incorrect")
		var room: Node = router.get("current_room")
		if room == null:
			failures.append("router current room missing after restore")
		else:
			var foot: Vector2 = room.call("get_player_foot")
			if foot != Vector2(200, 350):
				failures.append("saved player foot was not restored: %s" % foot)

	if bool(router.call("go_to_room", "res://rooms/ch01/test_room.tscn", "", Vector2(-500, 900), false)):
		await process_frame
		var clamped_room: Node = router.get("current_room")
		var clamped_foot: Vector2 = clamped_room.call("get_player_foot")
		if clamped_foot != Vector2(28, 392):
			failures.append("unsafe restored foot was not clamped: %s" % clamped_foot)
	else:
		failures.append("room load for clamp test failed")

	host.queue_free()


func _cleanup_test_file() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
