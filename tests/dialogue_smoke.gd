extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var state := root.get_node_or_null("GameState")
	var evidence := root.get_node_or_null("EvidenceService")
	var deductions := root.get_node_or_null("DeductionService")
	var dialogue := root.get_node_or_null("DialogueService")
	if state == null or evidence == null or deductions == null or dialogue == null:
		failures.append("dialogue autoload services are unavailable")
		_finish()
		return

	state.call("reset_new_game")
	evidence.call("load_catalog")
	deductions.call("load_catalog")
	dialogue.call("load_catalog")

	if int(dialogue.call("get_witness_count")) < 1:
		failures.append("seed witness catalog is empty")

	var opening: Dictionary = dialogue.call("start_conversation", "mara_bell")
	if opening.is_empty():
		failures.append("seed witness conversation did not start")
	else:
		var opening_choices: Array = opening.get("choices", [])
		if not _has_choice(opening_choices, "ask_service"):
			failures.append("public service topic is not visible")
		if _has_choice(opening_choices, "ask_packet"):
			failures.append("evidence-unlocked packet topic leaked before discovery")

	var service_result: Dictionary = dialogue.call("choose", "mara_bell", "greeting", "ask_service")
	if not bool(service_result.get("ok", false)):
		failures.append("public service topic could not be selected")
	if int(dialogue.call("get_trust", "mara_bell")) != 1:
		failures.append("service topic did not change witness trust")
	if not bool(dialogue.call("is_topic_open", "mara_bell", "service_call")):
		failures.append("service topic was not persisted as opened")

	dialogue.call("choose", "mara_bell", "service_answer", "back")
	evidence.call("acquire_clue", "packet_impossible_timestamp", 1)

	var unlocked: Dictionary = dialogue.call("get_node_view", "mara_bell", "greeting")
	if not _has_choice(unlocked.get("choices", []), "ask_packet"):
		failures.append("packet topic did not unlock from discovered evidence")

	var packet_result: Dictionary = dialogue.call("choose", "mara_bell", "greeting", "ask_packet")
	if not bool(packet_result.get("ok", false)):
		failures.append("evidence-unlocked packet topic could not be selected")
	var flags: Dictionary = state.get("chapter_flags")
	if not bool(flags.get("mara_heard_packet_claim", false)):
		failures.append("dialogue set_flag effect was not applied")
	if not bool(dialogue.call("has_reaction", "mara_bell", "mara_packet_question")):
		failures.append("once-only topic reaction was not recorded")

	dialogue.call("choose", "mara_bell", "packet_answer", "back")
	var after_once: Dictionary = dialogue.call("get_node_view", "mara_bell", "greeting")
	var after_choices: Array = after_once.get("choices", [])
	if _has_choice(after_choices, "ask_packet"):
		failures.append("once-only packet topic remained visible after use")
	if not _has_choice(after_choices, "ask_copy"):
		failures.append("conditional service-record branch did not unlock")

	var record_result: Dictionary = dialogue.call("choose", "mara_bell", "greeting", "ask_copy")
	if not bool(record_result.get("ok", false)):
		failures.append("conditional service-record branch could not be selected")
	if (evidence.call("get_evidence", "corridor_service_sticker") as Dictionary).is_empty():
		failures.append("dialogue acquire_clue effect did not add evidence")
	if not bool(dialogue.call("is_topic_open", "mara_bell", "service_record")):
		failures.append("conditional topic opening did not persist")

	_test_condition_matrix(state, dialogue)
	_test_evidence_presentation(state, evidence, dialogue)
	_test_hotspot_hook()

	evidence.call("load_catalog")
	deductions.call("load_catalog")
	dialogue.call("load_catalog")
	_finish()


func _test_condition_matrix(state: Node, dialogue: Node) -> void:
	var deductions_state: Dictionary = (state.get("deductions") as Dictionary).duplicate(true)
	deductions_state["packet_not_random_damage"] = {"state": "established"}
	state.set("deductions", deductions_state)

	var hypotheses: Array = (state.get("hypotheses") as Array).duplicate(true)
	if not hypotheses.has("packet_not_random_damage"):
		hypotheses.append("packet_not_random_damage")
	state.set("hypotheses", hypotheses)

	var skills: Dictionary = (state.get("skill_values") as Dictionary).duplicate(true)
	skills["empathy"] = 2
	state.set("skill_values", skills)

	var conditions := {
		"clues_all": ["packet_impossible_timestamp"],
		"deductions_all": ["packet_not_random_damage"],
		"hypotheses_all": ["packet_not_random_damage"],
		"min_trust": 1,
		"flags": {"mara_heard_packet_claim": true},
		"skills_min": {"empathy": 2},
		"topics_open_all": ["service_call"],
	}
	if not bool(dialogue.call("evaluate_conditions", conditions, "mara_bell")):
		failures.append("combined dialogue condition evaluation failed")


func _test_evidence_presentation(state: Node, evidence: Node, dialogue: Node) -> void:
	state.call("reset_new_game")
	evidence.call("load_catalog")
	dialogue.call("load_catalog")
	evidence.call("acquire_clue", "packet_impossible_timestamp", 1)

	var relevant: Array = dialogue.call("get_relevant_evidence", "mara_bell")
	if relevant.size() != 1 or String((relevant[0] as Dictionary).get("id", "")) != "packet_impossible_timestamp":
		failures.append("relevant evidence filtering did not return only the timestamp clue")

	var reaction: Dictionary = dialogue.call("present_evidence", "mara_bell", "packet_impossible_timestamp")
	if not bool(reaction.get("ok", false)) or String(reaction.get("status", "")) != "reacted":
		failures.append("evidence presentation did not trigger authored witness reaction")
	if int(dialogue.call("get_trust", "mara_bell")) != 1:
		failures.append("evidence reaction trust effect was not applied")
	if not bool(dialogue.call("has_reaction", "mara_bell", "mara_saw_impossible_timestamp")):
		failures.append("evidence once-only reaction was not recorded")
	if (evidence.call("get_evidence", "corridor_service_sticker") as Dictionary).is_empty():
		failures.append("evidence reaction did not acquire its authored clue")

	var relevant_after: Array = dialogue.call("get_relevant_evidence", "mara_bell")
	if not relevant_after.is_empty():
		failures.append("consumed once-only evidence reaction remained presentable")

	var serialized: Dictionary = state.call("to_serializable_state")
	state.call("reset_new_game")
	if not bool(state.call("apply_serializable_state", serialized)):
		failures.append("GameState rejected dialogue-bearing serialized state")
		return
	if int(dialogue.call("get_trust", "mara_bell")) != 1:
		failures.append("witness trust did not survive serialization")
	if not bool(dialogue.call("has_reaction", "mara_bell", "mara_saw_impossible_timestamp")):
		failures.append("once-only reaction did not survive serialization")
	var restored_flags: Dictionary = state.get("chapter_flags")
	if not bool(restored_flags.get("mara_timestamp_shown", false)):
		failures.append("dialogue chapter flag did not survive serialization")
	if (evidence.call("get_evidence", "corridor_service_sticker") as Dictionary).is_empty():
		failures.append("dialogue-acquired evidence did not survive serialization")


func _test_hotspot_hook() -> void:
	var scene := load("res://rooms/ch01/corridor_room.tscn") as PackedScene
	if scene == null:
		failures.append("corridor scene failed to load for witness hook test")
		return
	var room := scene.instantiate()
	root.add_child(room)
	await process_frame
	var hotspot := room.find_child("OfficeDoorHotspot", true, false)
	if hotspot == null:
		failures.append("seed witness hotspot is missing")
	elif String(hotspot.get("witness_id")) != "mara_bell":
		failures.append("seed witness hotspot is not wired to DialogueService ID")
	room.queue_free()


func _has_choice(choices: Array, choice_id: String) -> bool:
	for value in choices:
		if value is Dictionary and String(value.get("id", "")) == choice_id:
			return true
	return false


func _finish() -> void:
	if failures.is_empty():
		print("DIALOGUE_OK: conditions, effects, evidence presentation, trust, once-only state, persistence, and hotspot hook are valid")
		quit(0)
		return

	for failure in failures:
		push_error("DIALOGUE_FAIL: %s" % failure)
	quit(1)
