extends SceneTree

const ROOM_PATHS := [
	"res://rooms/demo/exterior_entry.tscn",
	"res://rooms/demo/lobby.tscn",
	"res://rooms/demo/front_desk.tscn",
	"res://rooms/demo/lost_found_hall.tscn",
	"res://rooms/demo/staff_office.tscn",
	"res://rooms/demo/storage_room.tscn",
	"res://rooms/demo/maintenance_corridor.tscn",
	"res://rooms/demo/loading_bay.tscn",
]

const POSE_PATHS := {
	"front": "res://art/characters/pc3/poses/front.webp",
	"walk_left_3q": "res://art/characters/pc3/poses/walk_3q.webp",
	"idle_right_3q": "res://art/characters/pc3/poses/idle_3q.webp",
	"side_right": "res://art/characters/pc3/poses/side.webp",
	"rear_right_3q": "res://art/characters/pc3/poses/rear_3q.webp",
	"combat": "res://art/characters/pc3/poses/combat.webp",
}

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for pose_id in POSE_PATHS.keys():
		var path := String(POSE_PATHS[pose_id])
		var texture := load(path) as Texture2D
		if texture == null:
			failures.append("production PC pose failed to load: %s" % path)
			continue
		if texture.get_height() < 220:
			failures.append("production PC pose is too low-resolution: %s = %dx%d" % [
				pose_id, texture.get_width(), texture.get_height()
			])
		if texture.get_width() < 90:
			failures.append("production PC pose crop is implausibly narrow: %s = %dx%d" % [
				pose_id, texture.get_width(), texture.get_height()
			])

	var seen_defaults: Dictionary = {}
	for path in ROOM_PATHS:
		var packed := load(path) as PackedScene
		if packed == null:
			failures.append("room failed to load for PC production test: %s" % path)
			continue
		var room := packed.instantiate()
		root.add_child(room)
		await process_frame

		var player := room.find_child("PlayerActor", true, false)
		if player == null:
			failures.append("room missing production PC actor: %s" % path)
			room.queue_free()
			await process_frame
			continue

		var pose_ids: Array = player.call("get_pose_ids")
		if pose_ids.size() != 6:
			failures.append("PC actor does not expose all six production poses: %s" % path)

		for pose_id in POSE_PATHS.keys():
			var resource_path := String(player.call("get_pose_resource_path", String(pose_id)))
			if resource_path != String(POSE_PATHS[pose_id]):
				failures.append("PC pose resource path mismatch: %s -> %s" % [pose_id, resource_path])
			var source_size: Vector2i = player.call("get_pose_source_size", String(pose_id))
			if source_size.y < 220:
				failures.append("PC runtime source is below production resolution: %s -> %s" % [pose_id, source_size])

		var default_pose := String(player.call("get_default_pose_id"))
		seen_defaults[default_pose] = true
		if not POSE_PATHS.has(default_pose):
			failures.append("room uses invalid default PC pose: %s -> %s" % [path, default_pose])

		var top_y := float(player.get("perspective_top_y"))
		var bottom_y := float(player.get("perspective_bottom_y"))
		var x := 320.0

		var far_foot := Vector2(x, top_y)
		player.call("place_at_foot", far_foot)
		var far_scale := float(player.call("get_visual_perspective_scale"))
		if (player.call("get_foot_position") as Vector2).distance_to(far_foot) > 0.01:
			failures.append("PC far-plane visual scaling moved gameplay foot coordinate: %s" % path)

		var near_foot := Vector2(x, bottom_y)
		player.call("place_at_foot", near_foot)
		var near_scale := float(player.call("get_visual_perspective_scale"))
		if near_scale <= far_scale:
			failures.append("PC perspective does not grow toward camera: %s" % path)
		if (player.call("get_foot_position") as Vector2).distance_to(near_foot) > 0.01:
			failures.append("PC near-plane visual scaling moved gameplay foot coordinate: %s" % path)

		var visual_size: Vector2 = player.call("get_visual_size")
		var pivot: Vector2 = player.call("get_visual_pivot_offset")
		var expected_pivot := Vector2(visual_size.x * 0.5, visual_size.y)
		if pivot.distance_to(expected_pivot) > 0.01:
			failures.append("PC scale pivot is not bottom-center: %s -> %s expected %s" % [path, pivot, expected_pivot])

		var bounds: Rect2 = room.get("walk_bounds")
		var center := bounds.position + bounds.size * 0.5
		player.call("place_at_foot", center)
		player.call("move_to", center + Vector2(48.0, 0.0), bounds)
		if String(player.call("get_current_pose_id")) != "side_right":
			failures.append("horizontal travel did not select side pose: %s" % path)
		player.call("stop")

		player.call("place_at_foot", center)
		player.call("move_to", center + Vector2(0.0, -36.0), bounds)
		if String(player.call("get_current_pose_id")) != "rear_right_3q":
			failures.append("deeper travel did not select rear three-quarter pose: %s" % path)
		player.call("stop")

		player.call("place_at_foot", center)
		player.call("move_to", center + Vector2(0.0, 36.0), bounds)
		if String(player.call("get_current_pose_id")) != "walk_left_3q":
			failures.append("toward-camera travel did not select walking three-quarter pose: %s" % path)
		player.call("stop")

		player.call("set_combat_pose", true)
		if String(player.call("get_current_pose_id")) != "combat":
			failures.append("combat did not select combat PC pose: %s" % path)
		player.call("set_combat_pose", false)
		if String(player.call("get_current_pose_id")) != default_pose:
			failures.append("combat exit did not restore room-authored PC pose: %s" % path)

		room.queue_free()
		await process_frame

	if seen_defaults.size() < 3:
		failures.append("PC staging uses fewer than three distinct room-authored resting angles")

	_finish()


func _finish() -> void:
	if failures.is_empty():
		print("PC3_PRODUCTION_OK: six high-resolution source poses, room angles, directional movement, bottom-center perspective, foot invariance, and combat restoration are valid")
		quit(0)
		return
	for failure in failures:
		push_error("PC3_PRODUCTION_FAIL: %s" % failure)
	quit(1)
