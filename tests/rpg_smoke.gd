extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var state := root.get_node_or_null("GameState")
	var skills := root.get_node_or_null("SkillService")
	var evidence := root.get_node_or_null("EvidenceService")
	var dialogue := root.get_node_or_null("DialogueService")
	if state == null or skills == null or evidence == null or dialogue == null:
		failures.append("RPG autoload services are unavailable")
		_finish()
		return

	_test_background_profiles(state, skills)
	_test_deterministic_checks(state, skills)
	await _test_observation_route(state, skills, evidence)
	_test_dialogue_success_route(state, skills, evidence, dialogue)
	_test_dialogue_failure_route(state, skills, evidence, dialogue)
	_test_persistence(state, skills)
	await _test_background_choice_ui()

	evidence.call("load_catalog")
	dialogue.call("load_catalog")
	_finish()


func _test_background_profiles(state: Node, skills: Node) -> void:
	var expected := {
		"watcher": {"observation": 3, "reasoning": 2, "empathy": 1, "resolve": 1},
		"analyst": {"observation": 2, "reasoning": 3, "empathy": 1, "resolve": 1},
		"reader": {"observation": 2, "reasoning": 1, "empathy": 3, "resolve": 1},
		"anchor": {"observation": 1, "reasoning": 2, "empathy": 1, "resolve": 3},
	}
	var profiles: Array = skills.call("get_backgrounds")
	if profiles.size() != 4:
		failures.append("background choice catalog does not contain exactly four profiles")

	for background_id in expected.keys():
		state.call("reset_new_game")
		if not bool(skills.call("apply_background", background_id)):
			failures.append("background failed to apply: %s" % background_id)
			continue
		if String(state.get("background_id")) != background_id:
			failures.append("background id not stored: %s" % background_id)
		var actual: Dictionary = state.get("skill_values")
		for skill_id in (expected[background_id] as Dictionary).keys():
			if int(actual.get(skill_id, -1)) != int((expected[background_id] as Dictionary)[skill_id]):
				failures.append("wrong %s value for %s" % [skill_id, background_id])


func _test_deterministic_checks(state: Node, skills: Node) -> void:
	state.call("reset_new_game")
	skills.call("apply_background", "analyst")

	var exact: Dictionary = skills.call("evaluate_check", "reasoning", 3, 0)
	if not bool(exact.get("passed", false)) or int(exact.get("total", -1)) != 3:
		failures.append("exact deterministic threshold did not pass")

	var fail: Dictionary = skills.call("evaluate_check", "observation", 3, 0)
	if bool(fail.get("passed", true)) or int(fail.get("total", -1)) != 2:
		failures.append("deterministic failure did not reflect base skill")

	var modified: Dictionary = skills.call("evaluate_check", "observation", 3, 1)
	if not bool(modified.get("passed", false)) or int(modified.get("total", -1)) != 3:
		failures.append("contextual modifier did not affect deterministic result")

	var sandbox_values := {"observation": 1, "reasoning": 3, "empathy": 2, "resolve": 1}
	var sandbox_check: Dictionary = skills.call("evaluate_values", sandbox_values, "reasoning", 4, 1)
	if not bool(sandbox_check.get("passed", false)) or int(sandbox_check.get("total", -1)) != 4:
		failures.append("pure local skill-value evaluation did not use the canonical deterministic rule")

	skills.call("perform_check", "test_failed_approach", "empathy", 2, 0, true, "Test failed approach")
	if not bool(skills.call("has_failed_approach", "test_failed_approach")):
		failures.append("failed approach was not recorded")
	var failed: Dictionary = skills.call("get_failed_approaches")
	var saved: Dictionary = failed.get("test_failed_approach", {})
	if int(saved.get("attempts", 0)) != 1:
		failures.append("failed approach attempt count is incorrect")


func _test_observation_route(state: Node, skills: Node, evidence: Node) -> void:
	state.call("reset_new_game")
	skills.call("apply_background", "watcher")
	evidence.call("load_catalog")

	var scene := load("res://rooms/ch01/test_room.tscn") as PackedScene
	var room: Node = scene.instantiate()
	root.add_child(room)
	await process_frame
	var monitor := room.find_child("MonitorHotspot", true, false)
	if monitor == null:
		failures.append("workstation skill-check hotspot is missing")
	else:
		room.call("_grant_hotspot_evidence", monitor)
		var feedback := String(room.call("_run_hotspot_skill_check", monitor))
		var clue: Dictionary = evidence.call("get_evidence", "packet_impossible_timestamp")
		if int(clue.get("detail_level", 0)) != 2:
			failures.append("Observation success did not upgrade packet evidence detail")
		if feedback.is_empty():
			failures.append("Observation success produced no player feedback")
		if bool(skills.call("has_failed_approach", "workstation_packet_second_field")):
			failures.append("successful Observation check was recorded as a failure")
	room.queue_free()

	state.call("reset_new_game")
	skills.call("apply_background", "analyst")
	evidence.call("load_catalog")
	var room_fail: Node = scene.instantiate()
	root.add_child(room_fail)
	await process_frame
	var monitor_fail := room_fail.find_child("MonitorHotspot", true, false)
	room_fail.call("_grant_hotspot_evidence", monitor_fail)
	room_fail.call("_run_hotspot_skill_check", monitor_fail)
	var fail_clue: Dictionary = evidence.call("get_evidence", "packet_impossible_timestamp")
	if int(fail_clue.get("detail_level", 0)) != 1:
		failures.append("failed Observation route incorrectly upgraded evidence")
	if not bool(skills.call("has_failed_approach", "workstation_packet_second_field")):
		failures.append("failed Observation route was not recorded")
	room_fail.queue_free()


func _test_dialogue_success_route(state: Node, skills: Node, evidence: Node, dialogue: Node) -> void:
	state.call("reset_new_game")
	skills.call("apply_background", "reader")
	evidence.call("load_catalog")
	dialogue.call("load_catalog")
	evidence.call("acquire_clue", "packet_impossible_timestamp", 1)

	var result: Dictionary = dialogue.call("choose", "mara_bell", "greeting", "read_mara")
	var check: Dictionary = result.get("skill_check", {})
	if not bool(result.get("ok", false)) or not bool(check.get("passed", false)):
		failures.append("Empathy seed route did not pass for Reader background")
	if String(result.get("node_id", "")) != "empathy_read_success":
		failures.append("successful Empathy route did not enter success node")
	var clue: Dictionary = evidence.call("get_evidence", "packet_impossible_timestamp")
	if int(clue.get("detail_level", 0)) != 2:
		failures.append("successful Empathy route did not upgrade evidence detail")
	if bool(skills.call("has_failed_approach", "mara_read_evasion")):
		failures.append("successful Empathy route recorded a failure")


func _test_dialogue_failure_route(state: Node, skills: Node, evidence: Node, dialogue: Node) -> void:
	state.call("reset_new_game")
	skills.call("apply_background", "watcher")
	evidence.call("load_catalog")
	dialogue.call("load_catalog")
	evidence.call("acquire_clue", "packet_impossible_timestamp", 1)

	dialogue.call("choose", "mara_bell", "greeting", "ask_service")
	dialogue.call("choose", "mara_bell", "service_answer", "back")

	var result: Dictionary = dialogue.call("choose", "mara_bell", "greeting", "read_mara")
	var check: Dictionary = result.get("skill_check", {})
	if not bool(result.get("ok", false)) or bool(check.get("passed", true)):
		failures.append("Empathy seed route did not fail for Watcher background")
	if String(result.get("node_id", "")) != "empathy_read_failure":
		failures.append("failed Empathy route did not enter failure node")
	if not bool(skills.call("has_failed_approach", "mara_read_evasion")):
		failures.append("failed Empathy route was not recorded")

	dialogue.call("choose", "mara_bell", "empathy_read_failure", "back")
	var greeting: Dictionary = dialogue.call("get_node_view", "mara_bell", "greeting")
	if not _has_choice(greeting.get("choices", []), "ask_failed_route"):
		failures.append("failed skill approach did not expose authored fallback route")

	var fallback: Dictionary = dialogue.call("choose", "mara_bell", "greeting", "ask_failed_route")
	if not bool(fallback.get("ok", false)):
		failures.append("authored fallback route could not be selected")
	if (evidence.call("get_evidence", "corridor_service_sticker") as Dictionary).is_empty():
		failures.append("fallback route did not acquire alternate-route evidence")


func _test_persistence(state: Node, skills: Node) -> void:
	state.call("reset_new_game")
	skills.call("apply_background", "anchor")
	skills.call("perform_check", "persisted_failure", "observation", 3, 0, true, "Persistent test")

	var serialized: Dictionary = state.call("to_serializable_state")
	state.call("reset_new_game")
	if not bool(state.call("apply_serializable_state", serialized)):
		failures.append("GameState rejected RPG-bearing serialized state")
		return

	if String(state.get("background_id")) != "anchor":
		failures.append("background did not survive serialization")
	var values: Dictionary = state.get("skill_values")
	if int(values.get("resolve", 0)) != 3:
		failures.append("skill values did not survive serialization")
	if not bool(skills.call("has_failed_approach", "persisted_failure")):
		failures.append("failed approach state did not survive serialization")


func _test_background_choice_ui() -> void:
	var scene := load("res://ui/menus/main_menu.tscn") as PackedScene
	if scene == null:
		failures.append("main menu failed to load for background-choice test")
		return
	var menu := scene.instantiate()
	root.add_child(menu)
	await process_frame
	var choices := menu.find_child("BackgroundChoices", true, false)
	if choices == null or choices.get_child_count() != 4:
		failures.append("opening background UI did not build four fixed choices")
	menu.queue_free()


func _has_choice(choices: Array, choice_id: String) -> bool:
	for value in choices:
		if value is Dictionary and String(value.get("id", "")) == choice_id:
			return true
	return false


func _finish() -> void:
	if failures.is_empty():
		print("RPG_OK: backgrounds, deterministic checks, modifiers, failures, skill routes, fallback routes, UI, and persistence are valid")
		quit(0)
		return

	for failure in failures:
		push_error("RPG_FAIL: %s" % failure)
	quit(1)
