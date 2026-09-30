extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var state := root.get_node_or_null("GameState")
	var skills := root.get_node_or_null("SkillService")
	if state == null or skills == null:
		failures.append("canonical state/RPG services unavailable")
		_finish()
		return

	state.call("pause_session")
	state.set("background_id", "slice12_canon_sentinel")
	state.set("skill_values", {"observation": 9, "reasoning": 9, "empathy": 9, "resolve": 9})
	state.set("failed_approaches", {"canon_failure": {"attempts": 1}})
	state.set("clues", {"canon_sentinel": {"detail_level": 1}})

	var expected := {
		"watcher": {"observation": 3, "reasoning": 2, "empathy": 1, "resolve": 1},
		"analyst": {"observation": 2, "reasoning": 3, "empathy": 1, "resolve": 1},
		"reader": {"observation": 2, "reasoning": 1, "empathy": 3, "resolve": 1},
		"anchor": {"observation": 1, "reasoning": 2, "empathy": 1, "resolve": 3},
	}

	# Every fixed profile applies locally and can still solve through the non-skill route.
	for background_id in expected.keys():
		var demo := await _make_demo(background_id)
		if demo == null:
			continue
		if String(demo.get("_demo_background_id")) != background_id:
			failures.append("demo background id did not apply: %s" % background_id)
		var actual: Dictionary = demo.get("_demo_skill_values")
		for skill_id in (expected[background_id] as Dictionary).keys():
			if int(actual.get(skill_id, -1)) != int((expected[background_id] as Dictionary)[skill_id]):
				failures.append("wrong %s value for Umbrella %s" % [skill_id, background_id])
		_solve_universal_route(demo)
		if not bool(demo.get("_case_resolved")):
			failures.append("background could not resolve the ordinary case path: %s" % background_id)
		demo.queue_free()
		await process_frame

	# Watcher: direct physical transfer reading at the lobby rack.
	var watcher := await _make_demo("watcher")
	if watcher != null:
		var room: Node = watcher.get("_current_room")
		var rack := room.find_child("UmbrellaRack", true, false)
		watcher.call("_on_demo_hotspot_activated", rack)
		var watcher_clues: Dictionary = watcher.get("_demo_clues")
		if not watcher_clues.has("watcher_transfer_residue"):
			failures.append("Watcher route did not add transfer-residue evidence")
		var watcher_checks: Dictionary = watcher.get("_demo_skill_checks")
		var watcher_result: Dictionary = watcher_checks.get("rack_residue_read", {})
		if not bool(watcher_result.get("passed", false)) or int(watcher_result.get("total", -1)) != 3:
			failures.append("Watcher Observation route did not pass exact threshold")
		watcher.queue_free()
		await process_frame

	# Analyst: timer alone fails at 3/4, then closing-log context grants +1 and the same check passes.
	var analyst := await _make_demo("analyst")
	if analyst != null:
		analyst.call("_load_demo_room", "res://rooms/demo/maintenance_corridor.tscn")
		await process_frame
		var analyst_room: Node = analyst.get("_current_room")
		var panel := analyst_room.find_child("FusePanel", true, false)
		analyst.call("_on_demo_hotspot_activated", panel)
		var analyst_checks: Dictionary = analyst.get("_demo_skill_checks")
		var first: Dictionary = analyst_checks.get("service_timing_reconstruction", {})
		if bool(first.get("passed", true)) or int(first.get("total", -1)) != 3 or int(first.get("threshold", -1)) != 4:
			failures.append("Analyst timing route did not fail transparently without context")
		var failed: Dictionary = analyst.get("_demo_failed_approaches")
		var first_failure: Dictionary = failed.get("service_timing_reconstruction", {})
		if String(first_failure.get("fallback_hint", "")).is_empty():
			failures.append("failed Reasoning route did not preserve a fallback")
		analyst.call("_acquire_demo_clue", "closing_log", false)
		analyst.call("_on_demo_hotspot_activated", panel)
		analyst_checks = analyst.get("_demo_skill_checks")
		var second: Dictionary = analyst_checks.get("service_timing_reconstruction", {})
		if not bool(second.get("passed", false)) or int(second.get("modifier", 0)) != 1 or int(second.get("total", -1)) != 4:
			failures.append("Analyst contextual +1 did not convert the deterministic check to a pass")
		var analyst_clues: Dictionary = analyst.get("_demo_clues")
		if not analyst_clues.has("analyst_service_timing"):
			failures.append("Analyst success did not add timing-reconstruction evidence")
		analyst.queue_free()
		await process_frame

	# Reader: emotional read creates motive evidence.
	var reader := await _make_demo("reader")
	if reader != null:
		var empathy: Dictionary = reader.call("_run_demo_dialogue_skill", "mina_protective_read")
		if not bool(empathy.get("passed", false)):
			failures.append("Reader Empathy route did not pass")
		var reader_clues: Dictionary = reader.get("_demo_clues")
		if not reader_clues.has("reader_protective_tell"):
			failures.append("Reader route did not add protective-tell evidence")
		reader.queue_free()
		await process_frame

	# Anchor: direct challenge yields the exact route plus Mina's ordinary transfer statement.
	var anchor := await _make_demo("anchor")
	if anchor != null:
		var resolve: Dictionary = anchor.call("_run_demo_dialogue_skill", "mina_exact_route_challenge")
		if not bool(resolve.get("passed", false)):
			failures.append("Anchor Resolve route did not pass")
		var anchor_clues: Dictionary = anchor.get("_demo_clues")
		if not anchor_clues.has("anchor_exact_route") or not anchor_clues.has("mina_statement"):
			failures.append("Anchor route did not produce exact-route evidence")
		anchor.queue_free()
		await process_frame

	# A failed social check records the exact math and a usable fallback, then survives local save/load.
	var persistence := await _make_demo("analyst")
	if persistence != null:
		var empathy_fail: Dictionary = persistence.call("_run_demo_dialogue_skill", "mina_protective_read")
		if bool(empathy_fail.get("passed", true)):
			failures.append("low-Empathy Analyst unexpectedly passed Reader route")
		var failures_state: Dictionary = persistence.get("_demo_failed_approaches")
		var saved_failure: Dictionary = failures_state.get("mina_protective_read", {})
		if int(saved_failure.get("last_total", -1)) != 1 or String(saved_failure.get("fallback_hint", "")).is_empty():
			failures.append("failed Empathy route did not record math + fallback")
		persistence.call("_demo_save")
		persistence.set("_demo_background_id", "corrupted")
		persistence.set("_demo_skill_values", {})
		persistence.set("_demo_failed_approaches", {})
		persistence.call("_demo_load")
		if String(persistence.get("_demo_background_id")) != "analyst":
			failures.append("demo background did not survive local save/load")
		var restored_values: Dictionary = persistence.get("_demo_skill_values")
		if int(restored_values.get("reasoning", 0)) != 3:
			failures.append("demo skill values did not survive local save/load")
		var restored_failures: Dictionary = persistence.get("_demo_failed_approaches")
		if not restored_failures.has("mina_protective_read"):
			failures.append("demo failed-approach state did not survive local save/load")
		persistence.queue_free()
		await process_frame

	# Canon isolation after all demo-local RPG work.
	if String(state.get("background_id")) != "slice12_canon_sentinel":
		failures.append("Umbrella RPG mutated canonical background")
	var canon_skills: Dictionary = state.get("skill_values")
	if int(canon_skills.get("observation", 0)) != 9:
		failures.append("Umbrella RPG mutated canonical skill values")
	var canon_failures: Dictionary = state.get("failed_approaches")
	if not canon_failures.has("canon_failure") or canon_failures.size() != 1:
		failures.append("Umbrella RPG mutated canonical failed approaches")
	var canon_clues: Dictionary = state.get("clues")
	if not canon_clues.has("canon_sentinel") or canon_clues.size() != 1:
		failures.append("Umbrella RPG mutated canonical clues")

	_finish()


func _make_demo(background_id: String) -> Node:
	var scene := load("res://ui/demo/ui_demo.tscn") as PackedScene
	if scene == null:
		failures.append("Umbrella demo scene failed to load")
		return null
	var demo := scene.instantiate()
	root.add_child(demo)
	await process_frame
	if not bool(demo.call("_choose_demo_background", background_id)):
		failures.append("could not choose Umbrella background: %s" % background_id)
	return demo


func _solve_universal_route(demo: Node) -> void:
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
	demo.call("_acquire_demo_clue", "wet_property_policy", false)
	demo.call("_acquire_demo_clue", "rear_drying_rail", false)
	_expect_established(demo, "drying_not_theft")
	demo.call("_resolve_demo_case")


func _expect_established(demo: Node, deduction_id: String) -> void:
	var result: Dictionary = demo.call("_select_demo_hypothesis", deduction_id)
	if String(result.get("status", "")) != "established":
		failures.append("RPG regression route did not establish %s (%s)" % [
			deduction_id,
			String(result.get("status", "missing"))
		])


func _finish() -> void:
	if failures.is_empty():
		print("UMBRELLA_RPG_OK: four profiles, deterministic checks, contextual modifier, skill routes, failures/fallbacks, persistence, universal solvability, and canon isolation are valid")
		quit(0)
		return
	for failure in failures:
		push_error("UMBRELLA_RPG_FAIL: %s" % failure)
	quit(1)
