extends SceneTree

const VISUALS := preload("res://art/demo/visual_catalog.gd")
const PLAYER_SCRIPT := preload("res://core/interaction/player_actor.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_atlases()
	await _test_player_contract()
	_test_identity_correspondence()
	await _test_combat_input_lock()
	await _test_story_visual_visibility()
	await _test_modal_stops_room_motion()
	if failures.is_empty():
		print("GRAPHICS_COMPLETION_OK: recovered atlases, crops, perspective, walking, actions, identity correspondence, and combat feedback lock are valid")
		quit(0)
		return
	for failure in failures:
		push_error("GRAPHICS_COMPLETION_FAIL: %s" % failure)
	quit(1)


func _test_atlases() -> void:
	var expected := [
		Vector2i(1254, 1254), Vector2i(1254, 1254), Vector2i(1254, 1254),
		Vector2i(1254, 1254), Vector2i(1254, 1254), Vector2i(1536, 1024), Vector2i(1448, 1086),
	]
	var atlases := VISUALS.all_runtime_atlases()
	_expect(atlases.size() == 7, "seven runtime atlases were not loaded")
	for index in range(mini(atlases.size(), expected.size())):
		var atlas: Texture2D = atlases[index]
		_expect(Vector2i(atlas.get_width(), atlas.get_height()) == expected[index], "atlas %d has unexpected dimensions" % index)
		var image := atlas.get_image()
		_expect(image != null and image.detect_alpha() != Image.ALPHA_NONE, "atlas %d lost transparency" % index)
	_expect(VISUALS.EVIDENCE_INDEX.size() >= 19, "not every clue maps to an illustration")


func _test_player_contract() -> void:
	var actor := Control.new()
	actor.set_script(PLAYER_SCRIPT)
	actor.size = Vector2(42, 82)
	var sprite := TextureRect.new()
	sprite.name = "Sprite"
	actor.add_child(sprite)
	root.add_child(actor)
	await process_frame
	actor.call("place_at_foot", Vector2(300, 236))
	var far_foot: Vector2 = actor.call("get_foot_position")
	var far_scale := float(actor.call("get_visual_perspective_scale"))
	actor.call("place_at_foot", Vector2(300, 390))
	var near_scale := float(actor.call("get_visual_perspective_scale"))
	_expect(far_foot == Vector2(300, 236), "placing the visual changed the gameplay foot point")
	_expect(near_scale / far_scale > 1.75, "depth scaling is not visibly strong")
	_expect((actor.call("get_action_ids") as Array).size() == 9, "player does not expose nine named action clips")
	var action_foot: Vector2 = actor.call("get_foot_position")
	_expect(bool(actor.call("play_action", "inspect")), "inspect action was rejected")
	actor.call("_process", 0.40)
	_expect(Vector2(actor.call("get_foot_position")) == action_foot, "action animation moved the gameplay footprint")
	actor.call("move_to", Vector2(500, 340), Rect2(40, 230, 560, 160))
	var first_frame := int(actor.call("get_current_frame_index"))
	actor.call("_process", 0.10)
	_expect(int(actor.call("get_current_frame_index")) != first_frame, "directional walk frame did not advance")
	actor.queue_free()


func _test_identity_correspondence() -> void:
	for witness_id in ["alex", "mina"]:
		var sprite := VISUALS.witness_pose(witness_id, "idle") as AtlasTexture
		var portrait := VISUALS.witness_portrait(witness_id, "portrait_idle") as AtlasTexture
		_expect(sprite != null and portrait != null and sprite.atlas == portrait.atlas, "%s sprite and portrait do not share one atlas" % witness_id)


func _test_combat_input_lock() -> void:
	var demo: Control = load("res://ui/demo/ui_demo.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	demo.call("_choose_demo_background", "anchor")
	demo.call("_start_demo_combat")
	demo.call("_request_combat_action", "guard")
	var second_call: Variant = demo.call("_request_combat_action", "guard")
	_expect(second_call is Dictionary and String((second_call as Dictionary).get("error", "")) == "combat_feedback_locked", "combat accepted repeat input during feedback")
	demo.queue_free()


func _test_story_visual_visibility() -> void:
	var demo: Control = load("res://ui/demo/ui_demo.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	demo.call("_choose_demo_background", "anchor")
	demo.call("_load_demo_room", "res://rooms/demo/loading_bay.tscn")
	await process_frame
	var umbrella := demo.find_child("RecoveredUmbrellaVisual", true, false) as CanvasItem
	_expect(umbrella != null and not umbrella.visible, "recovered umbrella appears before the story reveals it")
	demo.set("_case_resolved", true)
	demo.call("_refresh_room_story_visuals")
	_expect(umbrella != null and umbrella.visible, "recovered umbrella stays hidden after the case resolves")
	demo.queue_free()


func _test_modal_stops_room_motion() -> void:
	var room: Control = load("res://rooms/demo/lobby.tscn").instantiate()
	root.add_child(room)
	await process_frame
	var player: Control = room.get("player")
	player.call("move_to", room.call("_clamp_to_walk_bounds", Vector2(500, 350)), room.get("walk_bounds"))
	_expect(bool(player.call("is_moving")), "room movement did not start for modal lock check")
	room.call("set_interaction_enabled", false)
	_expect(not bool(player.call("is_moving")), "player keeps moving behind an open modal")
	var hotspots: Control = room.get("hotspots")
	for child in hotspots.get_children():
		_expect(child.mouse_filter == Control.MOUSE_FILTER_IGNORE, "hidden modal left a hotspot clickable")
	room.queue_free()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
