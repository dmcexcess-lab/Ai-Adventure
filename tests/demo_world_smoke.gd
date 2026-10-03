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
const START_ROOM := "res://rooms/demo/lobby.tscn"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scenes: Dictionary = {}
	for path in ROOM_PATHS:
		var scene := load(path) as PackedScene
		if scene == null:
			failures.append("demo room failed to load: %s" % path)
		else:
			scenes[path] = scene

	if scenes.size() != ROOM_PATHS.size():
		_finish()
		return

	var adjacency: Dictionary = {}
	var room_ids: Dictionary = {}
	var perspective_profiles: Dictionary = {}

	for path in ROOM_PATHS:
		var scene: PackedScene = scenes[path]
		var room := scene.instantiate()
		root.add_child(room)
		await process_frame

		var room_id := String(room.get("room_id"))
		if room_id.is_empty():
			failures.append("room missing stable room_id: %s" % path)
		elif room_ids.has(room_id):
			failures.append("duplicate demo room_id: %s" % room_id)
		else:
			room_ids[room_id] = path

		var art := room.find_child("ArtBackground", true, false)
		if art == null or art.get("texture") == null:
			failures.append("room missing imported background texture: %s" % path)

		var player := room.find_child("PlayerActor", true, false)
		var sprite := room.find_child("Sprite", true, false)
		if player == null or sprite == null or sprite.get("texture") == null:
			failures.append("room missing shared player visual contract: %s" % path)
		else:
			var polygon: PackedVector2Array = room.get("walk_polygon")
			if polygon.size() < 4:
				failures.append("room lacks a background-specific walk polygon: %s" % path)
			else:
				var foot: Vector2 = room.call("get_player_foot")
				if not _point_in_or_on_polygon(foot, polygon):
					failures.append("default spawn clips outside the walkable floor: %s at %s" % [path, foot])
				var clamped: Vector2 = room.call("_clamp_to_walk_bounds", Vector2(-200, -200))
				if not _point_in_or_on_polygon(clamped, polygon):
					failures.append("off-floor movement was not clamped to room geometry: %s" % path)
			var profile := "%s/%s/%s/%s" % [
				player.get("perspective_far_scale"),
				player.get("perspective_near_scale"),
				player.get("perspective_top_y"),
				player.get("perspective_bottom_y"),
			]
			perspective_profiles[profile] = true

		var hotspots := room.find_child("Hotspots", true, false)
		if hotspots == null or hotspots.get_child_count() < 3:
			failures.append("room lacks representative hotspots: %s" % path)

		var targets: Array = room.call("get_transition_targets")
		if targets.is_empty():
			failures.append("orphan room has no outgoing transitions: %s" % path)
		adjacency[path] = []

		for target_value in targets:
			if not target_value is Dictionary:
				failures.append("invalid transition metadata in %s" % path)
				continue
			var target: Dictionary = target_value
			var target_path := String(target.get("room_path", ""))
			var spawn_marker := String(target.get("spawn_marker", ""))
			if not scenes.has(target_path):
				failures.append("transition target is outside demo room graph: %s -> %s" % [path, target_path])
				continue
			(adjacency[path] as Array).append(target_path)

			if spawn_marker.is_empty():
				failures.append("transition lacks target spawn marker: %s -> %s" % [path, target_path])
				continue
			var target_probe := (scenes[target_path] as PackedScene).instantiate()
			if target_probe.find_child(spawn_marker, true, false) == null:
				failures.append("target spawn missing: %s -> %s:%s" % [path, target_path, spawn_marker])
			target_probe.free()

		room.queue_free()
		await process_frame

	var visited: Dictionary = {}
	var queue: Array[String] = [START_ROOM]
	while not queue.is_empty():
		var current: String = queue.pop_front()
		if visited.has(current):
			continue
		visited[current] = true
		for target_path in adjacency.get(current, []):
			var next_path := String(target_path)
			if not visited.has(next_path):
				queue.append(next_path)

	if visited.size() != ROOM_PATHS.size():
		for path in ROOM_PATHS:
			if not visited.has(path):
				failures.append("demo room graph cannot reach %s from lobby" % path)

	if perspective_profiles.size() < 6:
		failures.append("room backgrounds still share too many generic perspective profiles")

	_finish()


func _point_in_or_on_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	if Geometry2D.is_point_in_polygon(point, polygon):
		return true
	for index in range(polygon.size()):
		var closest := Geometry2D.get_closest_point_to_segment(point, polygon[index], polygon[(index + 1) % polygon.size()])
		if point.distance_squared_to(closest) < 0.01:
			return true
	return false


func _finish() -> void:
	if failures.is_empty():
		print("DEMO_WORLD_OK: eight rooms load, art/player contracts hold, transition spawns resolve, and the full graph is traversable")
		quit(0)
		return

	for failure in failures:
		push_error("DEMO_WORLD_FAIL: %s" % failure)
	quit(1)
