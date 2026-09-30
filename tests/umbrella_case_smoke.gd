extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var state := root.get_node_or_null("GameState")
	if state == null:
		failures.append("GameState unavailable")
		_finish()
		return

	state.call("pause_session")
	state.set("background_id", "slice11_sentinel")
	state.set("clues", {"canon_sentinel": {"detail_level": 1}})
	state.set("deductions", {"canon_sentinel": {"state": "established"}})
	state.set("chapter_flags", {"canon_sentinel": true})

	var scene := load("res://ui/demo/ui_demo.tscn") as PackedScene
	if scene == null:
		failures.append("Umbrella shell failed to load")
		_finish()
		return

	var demo := scene.instantiate()
	root.add_child(demo)
	await process_frame
	if not bool(demo.call("_choose_demo_background", "watcher")):
		failures.append("case smoke could not choose a demo background")

	var clues: Dictionary = demo.get("_demo_clues")
	if not clues.has("case_request"):
		failures.append("fresh case does not begin with the owner description")
	if bool(demo.get("_case_resolved")):
		failures.append("fresh case starts resolved")

	# Golden path: witness-assisted.
	demo.call("_acquire_demo_clue", "ticket_47b", false)
	_expect_established(demo, "identity_47b")

	demo.call("_acquire_demo_clue", "dry_outline", false)
	demo.call("_apply_demo_topic", "alex_transfer")
	_expect_established(demo, "lobby_to_lost_found")

	demo.call("_acquire_demo_clue", "cabinet_trace", false)
	_expect_established(demo, "cabinet_was_intermediate")

	demo.call("_acquire_demo_clue", "shift_board", false)
	demo.call("_open_dialogue", "mina")
	demo.call("_present_demo_evidence", "cabinet_trace")
	clues = demo.get("_demo_clues")
	if not clues.has("mina_statement"):
		failures.append("presenting Cabinet B evidence to Mina did not produce her transfer statement")
	_expect_established(demo, "mina_service_route")

	demo.call("_apply_demo_topic", "mina_policy")
	demo.call("_acquire_demo_clue", "rear_drying_rail", false)
	_expect_established(demo, "drying_not_theft")
	demo.call("_resolve_demo_case")
	if not bool(demo.get("_case_resolved")):
		failures.append("golden path did not resolve the case")
	clues = demo.get("_demo_clues")
	if not clues.has("umbrella_recovered"):
		failures.append("case resolution did not record umbrella recovery")

	# Alternate route: solve without Mina's admission.
	demo.call("_reset_demo_case")
	demo.call("_acquire_demo_clue", "ticket_47b", false)
	_expect_established(demo, "identity_47b")
	demo.call("_acquire_demo_clue", "dry_outline", false)
	demo.call("_acquire_demo_clue", "closing_log", false)
	_expect_established(demo, "lobby_to_lost_found")
	demo.call("_acquire_demo_clue", "cabinet_trace", false)
	_expect_established(demo, "cabinet_was_intermediate")
	demo.call("_acquire_demo_clue", "shift_board", false)
	demo.call("_acquire_demo_clue", "transfer_tag", false)
	_expect_established(demo, "mina_service_route")

	clues = demo.get("_demo_clues")
	if clues.has("mina_statement"):
		failures.append("alternate route accidentally depended on Mina's admission")

	demo.call("_acquire_demo_clue", "wet_property_policy", false)
	demo.call("_acquire_demo_clue", "rear_drying_rail", false)
	_expect_established(demo, "drying_not_theft")
	demo.call("_resolve_demo_case")
	if not bool(demo.get("_case_resolved")):
		failures.append("alternate documentary/physical route did not resolve the case")

	# Refutation behavior.
	demo.call("_reset_demo_case")
	var early_alex: Dictionary = demo.call("_select_demo_hypothesis", "alex_took_it")
	if String(early_alex.get("status", "")) != "established":
		failures.append("early bad hypothesis was not selectable when superficially supported")
	demo.call("_acquire_demo_clue", "closing_log", false)
	var refuted_alex: Dictionary = demo.call("_evaluate_demo_deduction", "alex_took_it")
	if String(refuted_alex.get("status", "")) != "refuted":
		failures.append("later evidence did not refute the Alex accusation")

	# Canon isolation.
	if String(state.get("background_id")) != "slice11_sentinel":
		failures.append("Umbrella investigation mutated canonical background")
	var canon_clues: Dictionary = state.get("clues")
	if not canon_clues.has("canon_sentinel") or canon_clues.size() != 1:
		failures.append("Umbrella investigation mutated canonical clues")
	var canon_deductions: Dictionary = state.get("deductions")
	if not canon_deductions.has("canon_sentinel") or canon_deductions.size() != 1:
		failures.append("Umbrella investigation mutated canonical deductions")
	var canon_flags: Dictionary = state.get("chapter_flags")
	if not bool(canon_flags.get("canon_sentinel", false)):
		failures.append("Umbrella investigation mutated canonical flags")

	demo.queue_free()
	_finish()


func _expect_established(demo: Node, deduction_id: String) -> void:
	var result: Dictionary = demo.call("_select_demo_hypothesis", deduction_id)
	if String(result.get("status", "")) != "established":
		failures.append("deduction did not establish: %s (%s)" % [
			deduction_id,
			String(result.get("status", "missing"))
		])


func _finish() -> void:
	if failures.is_empty():
		print("UMBRELLA_CASE_OK: fresh start, witness evidence, deductions, alternate route, refutation, resolution, and canon isolation are valid")
		quit(0)
		return
	for failure in failures:
		push_error("UMBRELLA_CASE_FAIL: %s" % failure)
	quit(1)
