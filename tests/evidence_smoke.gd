extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var state := root.get_node_or_null("GameState")
	var evidence := root.get_node_or_null("EvidenceService")
	if state == null or evidence == null:
		failures.append("evidence autoload services are unavailable")
		_finish()
		return

	state.call("reset_new_game")

	if not bool(evidence.call("load_catalog")):
		failures.append("clue catalog failed to load")
	if int(evidence.call("get_definition_count")) < 3:
		failures.append("seed clue catalog is incomplete")

	var unknown: Dictionary = evidence.call("acquire_clue", "missing_clue", 1)
	if bool(unknown.get("ok", false)):
		failures.append("unknown clue was accepted")

	var first: Dictionary = evidence.call("acquire_clue", "packet_impossible_timestamp", 1)
	if not bool(first.get("ok", false)) or String(first.get("status", "")) != "added":
		failures.append("first clue acquisition did not add evidence")

	var clues: Dictionary = state.get("clues")
	if clues.size() != 1:
		failures.append("first acquisition did not create exactly one clue state")

	var duplicate: Dictionary = evidence.call("acquire_clue", "packet_impossible_timestamp", 1)
	if String(duplicate.get("status", "")) != "unchanged":
		failures.append("idempotent acquisition did not remain unchanged")
	if (state.get("clues") as Dictionary).size() != 1:
		failures.append("duplicate acquisition created a duplicate clue")

	var upgrade: Dictionary = evidence.call("acquire_clue", "packet_impossible_timestamp", 2)
	if String(upgrade.get("status", "")) != "upgraded":
		failures.append("detail upgrade was not reported")
	var upgraded_clue: Dictionary = evidence.call("get_evidence", "packet_impossible_timestamp")
	if int(upgraded_clue.get("detail_level", 0)) != 2:
		failures.append("detail level did not upgrade to 2")
	if not String(upgraded_clue.get("detail_text", "")).contains("same impossible time"):
		failures.append("upgraded detail text was not exposed")

	var temporal: Array = evidence.call("get_discovered_evidence", "temporal")
	if temporal.size() != 1:
		failures.append("temporal filter did not return the timestamp clue")
	var physical_before: Array = evidence.call("get_discovered_evidence", "physical")
	if not physical_before.is_empty():
		failures.append("undiscovered physical clue leaked through filtering")

	evidence.call("acquire_clue", "corridor_service_sticker", 1)
	var physical_after: Array = evidence.call("get_discovered_evidence", "physical")
	if physical_after.size() != 1:
		failures.append("physical filter did not return discovered physical evidence")

	var tags: Array = evidence.call("get_discovered_tags")
	if not tags.has("temporal") or not tags.has("physical"):
		failures.append("discovered tag list is incomplete")

	var serialized: Dictionary = state.call("to_serializable_state")
	state.call("reset_new_game")
	if not bool(state.call("apply_serializable_state", serialized)):
		failures.append("GameState rejected evidence-bearing serialized state")
	else:
		var restored: Dictionary = evidence.call("get_evidence", "packet_impossible_timestamp")
		if int(restored.get("detail_level", 0)) != 2:
			failures.append("evidence detail did not survive GameState serialization")
		var restored_all: Array = evidence.call("get_discovered_evidence")
		if restored_all.size() != 2:
			failures.append("discovered evidence count did not survive serialization")

	var workstation_scene := load("res://rooms/ch01/test_room.tscn") as PackedScene
	var workstation: Node = workstation_scene.instantiate()
	root.add_child(workstation)
	await process_frame
	var monitor := workstation.find_child("MonitorHotspot", true, false)
	if monitor == null:
		failures.append("workstation monitor hotspot missing")
	elif String(monitor.get("evidence_id")) != "packet_impossible_timestamp":
		failures.append("workstation monitor is not wired to the seed evidence hook")
	workstation.queue_free()

	_finish()


func _finish() -> void:
	if failures.is_empty():
		print("EVIDENCE_OK: acquisition, upgrades, persistence, filtering, rejection, and hotspot hook are valid")
		quit(0)
		return

	for failure in failures:
		push_error("EVIDENCE_FAIL: %s" % failure)
	quit(1)
