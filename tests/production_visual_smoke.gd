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

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
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
			if not player.is_processing():
				failures.append("player idle/walk animation process is not active: %s" % path)

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
		print("PRODUCTION_VISUAL_OK: eight production PNG rooms, ambient layers, animated player staging, NPC art, portraits, and combat visual resources are valid")
		quit(0)
		return
	for failure in failures:
		push_error("PRODUCTION_VISUAL_FAIL: %s" % failure)
	quit(1)
