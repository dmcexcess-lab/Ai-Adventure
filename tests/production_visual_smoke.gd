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

const EXPECTED_DEFAULT_POSES := {
	"res://rooms/demo/exterior_entry.tscn": "side_right",
	"res://rooms/demo/lobby.tscn": "idle_right_3q",
	"res://rooms/demo/front_desk.tscn": "idle_right_3q",
	"res://rooms/demo/lost_found_hall.tscn": "side_right",
	"res://rooms/demo/staff_office.tscn": "idle_right_3q",
	"res://rooms/demo/storage_room.tscn": "rear_right_3q",
	"res://rooms/demo/maintenance_corridor.tscn": "side_right",
	"res://rooms/demo/loading_bay.tscn": "idle_right_3q",
}

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var seen_default_poses: Dictionary = {}
	for path in ROOM_PATHS:
		var packed := load(path) as PackedScene
		if packed == null:
			failures.append("production room failed to load: %s" % path)
			continue

		var room := packed.instantiate()
		root.add_child(room)
		await process_frame

		var art := room.find_child("ArtBackground", true, false)
		if art == null or art.get("texture") == null:
			failures.append("production background missing: %s" % path)
		else:
			var resource_path := String((art.get("texture") as Resource).resource_path)
			if not resource_path.begins_with("res://art/demo/production/") or not resource_path.ends_with("_production.png"):
				failures.append("room is not using production PNG art: %s -> %s" % [path, resource_path])

		var ambient := room.find_child("AmbientFX", true, false)
		if ambient == null:
			failures.append("room missing ambient visual layer: %s" % path)

		var player := room.find_child("PlayerActor", true, false)
		if player == null:
			failures.append("room missing player actor: %s" % path)
		else:
			var sprite := player.find_child("Sprite", true, false)
			if sprite == null or sprite.get("texture") == null:
				failures.append("production player sprite missing: %s" % path)
			else:
				var pose_texture := sprite.get("texture") as AtlasTexture
				if pose_texture == null:
					failures.append("PC/#3 sprite is not sourced from the master pose atlas: %s" % path)
				elif pose_texture.atlas == null or String(pose_texture.atlas.resource_path) != "res://art/characters/pc3/pc3_reference_atlas.webp":
					failures.append("PC/#3 pose atlas path is wrong: %s" % path)
			if not player.is_processing():
				failures.append("player idle/walk animation process is not active: %s" % path)
			var display_size: Vector2 = player.call("get_visual_display_size")
			if display_size.y < 150.0 or display_size.x < 70.0:
				failures.append("PC/#3 visual is still prototype-small: %s -> %s" % [path, display_size])
			if sprite != null:
				if sprite.size.y < 150.0:
					failures.append("PC/#3 sprite rectangle was not expanded to production staging size: %s -> %s" % [path, sprite.size])
				if int(sprite.texture_filter) != int(CanvasItem.TEXTURE_FILTER_LINEAR):
					failures.append("PC/#3 scaled atlas is not using linear filtering: %s" % path)
			if player.size.y > 90.0:
				failures.append("PC/#3 gameplay footprint changed while enlarging only the visual: %s" % path)

			var default_pose := String(player.call("get_default_pose_id"))
			seen_default_poses[default_pose] = true
			if default_pose != String(EXPECTED_DEFAULT_POSES.get(path, "")):
				failures.append("room PC default pose mismatch: %s -> %s" % [path, default_pose])

			var far_scale := float(player.get("perspective_far_scale"))
			var near_scale := float(player.get("perspective_near_scale"))
			if near_scale <= far_scale:
				failures.append("room PC perspective does not grow toward camera: %s" % path)

			var top_y := float(player.get("perspective_top_y"))
			var bottom_y := float(player.get("perspective_bottom_y"))
			player.call("place_at_foot", Vector2(320.0, top_y))
			var measured_far := float(player.call("get_visual_perspective_scale"))
			player.call("place_at_foot", Vector2(320.0, bottom_y))
			var measured_near := float(player.call("get_visual_perspective_scale"))
			if measured_near <= measured_far:
				failures.append("runtime PC perspective interpolation failed: %s" % path)
			var near_rendered_height := float(player.call("get_visual_rendered_height"))
			if near_rendered_height < 150.0:
				failures.append("near-plane PC/#3 remains undersized against room/NPC scale: %s -> %.1f" % [path, near_rendered_height])

		if path.ends_with("front_desk.tscn"):
			var alex := room.find_child("AlexVisual", true, false)
			if alex == null or alex.get("texture") == null:
				failures.append("front desk is missing production Alex staging")
		if path.ends_with("staff_office.tscn"):
			var mina := room.find_child("MinaVisual", true, false)
			if mina == null or mina.get("texture") == null:
				failures.append("staff office is missing production Mina staging")

		room.queue_free()
		await process_frame

	if seen_default_poses.size() < 3:
		failures.append("PC/#3 scene staging does not use enough distinct authored default angles")

	var demo_scene := load("res://ui/demo/ui_demo.tscn") as PackedScene
	if demo_scene == null:
		failures.append("Umbrella shell failed to load for production visual check")
	else:
		var demo := demo_scene.instantiate()
		root.add_child(demo)
		await process_frame
		var portrait := demo.find_child("DialoguePortrait", true, false)
		if portrait == null or portrait.get("texture") == null:
			failures.append("production dialogue portrait resource missing")
		var opponent := demo.find_child("CombatOpponentVisual", true, false)
		if opponent == null or opponent.get("texture") == null:
			failures.append("production combat silhouette missing")
		var combat_panel := demo.find_child("CombatPanel", true, false)
		if combat_panel == null:
			failures.append("combat presentation panel missing")
		demo.queue_free()

	_finish()


func _finish() -> void:
	if failures.is_empty():
		print("PRODUCTION_VISUAL_OK: eight accepted production PNG rooms plus PC/#3 staging scale, pose, perspective, and structural presentation resources are valid")
		quit(0)
		return
	for failure in failures:
		push_error("PRODUCTION_VISUAL_FAIL: %s" % failure)
	quit(1)
