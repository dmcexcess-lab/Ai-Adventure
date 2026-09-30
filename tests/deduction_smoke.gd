extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var state := root.get_node_or_null("GameState")
	var evidence := root.get_node_or_null("EvidenceService")
	var deductions := root.get_node_or_null("DeductionService")
	if state == null or evidence == null or deductions == null:
		failures.append("deduction autoload services are unavailable")
		_finish()
		return

	state.call("reset_new_game")
	evidence.call("load_catalog")
	deductions.call("load_catalog")

	if int(deductions.call("get_definition_count")) < 3:
		failures.append("seed deduction catalog is incomplete")

	var initial: Dictionary = deductions.call("evaluate", "packet_not_random_damage")
	if String(initial.get("status", "")) != "unsupported":
		failures.append("empty case did not evaluate as unsupported")

	evidence.call("acquire_clue", "packet_impossible_timestamp", 1)
	var partial: Dictionary = deductions.call("evaluate", "packet_not_random_damage")
	if int(partial.get("support_count", -1)) != 1:
		failures.append("support count did not reflect one discovered clue")
	if String(partial.get("status", "")) != "unsupported":
		failures.append("insufficient evidence did not remain unsupported")

	var wrong_try: Dictionary = deductions.call("select_hypothesis", "packet_not_random_damage")
	if String(wrong_try.get("status", "")) != "unsupported":
		failures.append("unsupported hypothesis selection changed status incorrectly")
	if not (state.get("hypotheses") as Array).has("packet_not_random_damage"):
		failures.append("unsupported hypothesis was not persisted")

	evidence.call("acquire_clue", "packet_survival_phrase", 1)
	var supported: Dictionary = deductions.call("evaluate", "packet_not_random_damage")
	if String(supported.get("status", "")) != "supported":
		failures.append("minimum support rule did not produce supported state")

	var established: Dictionary = deductions.call("select_hypothesis", "packet_not_random_damage")
	if String(established.get("status", "")) != "established":
		failures.append("supported hypothesis did not become established")
	if not bool(deductions.call("is_established", "packet_not_random_damage")):
		failures.append("established deduction was not persisted")

	var deduction_count := (state.get("deductions") as Dictionary).size()
	var established_again: Dictionary = deductions.call("select_hypothesis", "packet_not_random_damage")
	if String(established_again.get("status", "")) != "established":
		failures.append("established deduction was not idempotent")
	if (state.get("deductions") as Dictionary).size() != deduction_count:
		failures.append("reselecting established deduction duplicated state")

	var dependent: Dictionary = deductions.call("evaluate", "packet_contains_temporal_claim")
	if String(dependent.get("status", "")) != "supported":
		failures.append("met prerequisite plus temporal evidence did not support dependent deduction")

	var serialized: Dictionary = state.call("to_serializable_state")
	state.call("reset_new_game")
	if not bool(state.call("apply_serializable_state", serialized)):
		failures.append("GameState rejected deduction-bearing serialized state")
	else:
		if not (state.get("hypotheses") as Array).has("packet_not_random_damage"):
			failures.append("hypothesis selection did not survive serialization")
		if not bool(deductions.call("is_established", "packet_not_random_damage")):
			failures.append("established deduction did not survive serialization")

	_test_prerequisite_gate(state, evidence, deductions)
	_test_refutation(state, evidence, deductions)

	evidence.call("load_catalog")
	deductions.call("load_catalog")
	_finish()


func _test_prerequisite_gate(state: Node, evidence: Node, deductions: Node) -> void:
	state.call("reset_new_game")
	evidence.call("load_catalog")
	deductions.call("load_catalog")
	evidence.call("acquire_clue", "packet_impossible_timestamp", 1)

	var dependent: Dictionary = deductions.call("evaluate", "packet_contains_temporal_claim")
	if bool(dependent.get("prerequisites_met", true)):
		failures.append("missing prerequisite was reported as met")
	if String(dependent.get("status", "")) != "unsupported":
		failures.append("missing prerequisite did not block supported state")


func _test_refutation(state: Node, evidence: Node, deductions: Node) -> void:
	state.call("reset_new_game")
	var clue_ok: bool = evidence.call("load_definitions", [
		{
			"id": "support_a",
			"title": "Support A",
			"source": "test",
			"reliability": "test",
			"tags": ["support"],
			"contradiction_tags": [],
			"detail_levels": [{"level": 1, "text": "support"}],
		},
		{
			"id": "refuter",
			"title": "Refuter",
			"source": "test",
			"reliability": "test",
			"tags": ["refute_tag"],
			"contradiction_tags": [],
			"detail_levels": [{"level": 1, "text": "refute"}],
		},
	])
	var deduction_ok: bool = deductions.call("load_definitions", [
		{
			"id": "refutable",
			"title": "Refutable",
			"description": "test",
			"required_clue_ids": ["support_a"],
			"required_tags": [],
			"minimum_support": 1,
			"prerequisite_deductions": [],
			"refute_evidence_tags": ["refute_tag"],
			"refute_contradiction_tags": [],
		},
	])
	if not clue_ok or not deduction_ok:
		failures.append("custom refutation fixture failed to load")
		return

	evidence.call("acquire_clue", "support_a", 1)
	var before: Dictionary = deductions.call("evaluate", "refutable")
	if String(before.get("status", "")) != "supported":
		failures.append("refutation fixture was not initially supported")

	evidence.call("acquire_clue", "refuter", 1)
	var after: Dictionary = deductions.call("evaluate", "refutable")
	if String(after.get("status", "")) != "refuted":
		failures.append("discovered refuting evidence did not produce refuted state")
	var visible: Array = deductions.call("get_visible_contradictions", "refutable")
	if visible.size() != 1 or String((visible[0] as Dictionary).get("id", "")) != "refuter":
		failures.append("refutation did not expose only the discovered contradicting clue")


func _finish() -> void:
	if failures.is_empty():
		print("DEDUCTION_OK: support, prerequisites, refutation, persistence, hypotheses, and idempotence are valid")
		quit(0)
		return

	for failure in failures:
		push_error("DEDUCTION_FAIL: %s" % failure)
	quit(1)
