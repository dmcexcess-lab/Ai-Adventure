extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_hotspot_dispatch()
	await _test_room_contract()

	if failures.is_empty():
		print("INTERACTION_OK: hotspot dispatch, reveal state, walk bounds, and linked rooms are valid")
		quit(0)
		return

	for failure in failures:
		push_error("INTERACTION_FAIL: %s" % failure)
	quit(1)


func _test_hotspot_dispatch() -> void:
	var hotspot_script := load("res://core/interaction/hotspot.gd") as Script
	var hotspot: Node = hotspot_script.new() as Node
	hotspot.set("hotspot_id", "smoke_hotspot")
	hotspot.set("display_name", "Smoke Hotspot")
	(hotspot as Control).size = Vector2(40, 40)
	root.add_child(hotspot)

	var actions: Array[StringName] = []
	hotspot.connect("action_requested", func(_source: Node, action: StringName) -> void:
		actions.append(action)
	)

	hotspot.call("trigger_primary")
	hotspot.call("trigger_inspect")
	if actions != [&"primary", &"inspect"]:
		failures.append("hotspot primary/inspect dispatch mismatch")

	hotspot.call("set_reveal", true)
	if not bool(hotspot.call("is_reveal_active")):
		failures.append("hotspot reveal state did not activate")

	hotspot.call("set_hotspot_enabled", false)
	hotspot.call("trigger_primary")
	if actions.size() != 2:
		failures.append("disabled hotspot still dispatched an action")

	hotspot.queue_free()


func _test_room_contract() -> void:
	var workstation_scene := load("res://rooms/ch01/test_room.tscn") as PackedScene
	var workstation: Node = workstation_scene.instantiate()
	root.add_child(workstation)
	await process_frame

	if String(workstation.get("room_id")) != "ch01_workstation":
		failures.append("workstation room_id missing")

	var player := workstation.find_child("PlayerActor", true, false)
	if player == null:
		failures.append("workstation player actor missing")
	else:
		workstation.call("walk_to", Vector2(-200, 900))
		var destination: Vector2 = player.call("get_destination_foot")
		if destination != Vector2(28, 392):
			failures.append("walk destination did not clamp to room bounds: %s" % destination)

	workstation.call("set_hotspot_reveal", true)
	var monitor := workstation.find_child("MonitorHotspot", true, false)
	var door := workstation.find_child("DoorHotspot", true, false)

	if monitor == null or not bool(monitor.call("is_reveal_active")):
		failures.append("room reveal did not propagate to hotspots")
	if door == null:
		failures.append("linked-room door hotspot missing")
	else:
		var target := String(door.get("transition_room"))
		if target != "res://rooms/ch01/corridor_room.tscn":
			failures.append("workstation transition target mismatch")
		elif load(target) == null:
			failures.append("corridor transition target does not load")

	var corridor_scene := load("res://rooms/ch01/corridor_room.tscn") as PackedScene
	var corridor: Node = corridor_scene.instantiate()
	root.add_child(corridor)
	await process_frame

	var back_door := corridor.find_child("BackDoorHotspot", true, false)
	if back_door == null:
		failures.append("corridor return hotspot missing")
	elif String(back_door.get("transition_room")) != "res://rooms/ch01/test_room.tscn":
		failures.append("corridor return transition mismatch")

	workstation.queue_free()
	corridor.queue_free()
