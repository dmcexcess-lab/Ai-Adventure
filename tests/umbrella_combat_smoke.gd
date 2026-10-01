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
	state.set("background_id", "slice13_canon_sentinel")
	state.set("skill_values", {"observation": 9, "reasoning": 9, "empathy": 9, "resolve": 9})
	state.set("failed_approaches", {"canon_failure": {"attempts": 1}})
	state.set("clues", {"canon_sentinel": {"detail_level": 1}})
	state.set("deductions", {"canon_sentinel": {"state": "established"}})

	await _test_victory_path()
	await _test_skill_disengage_and_persistence()
	await _test_failure_consequence_and_case_completion()

	if String(state.get("background_id")) != "slice13_canon_sentinel":
		failures.append("Umbrella combat mutated canonical background")
	var canon_skills: Dictionary = state.get("skill_values")
	if int(canon_skills.get("resolve", 0)) != 9:
		failures.append("Umbrella combat mutated canonical skills")
	var canon_failed: Dictionary = state.get("failed_approaches")
	if not canon_failed.has("canon_failure") or canon_failed.size() != 1:
		failures.append("Umbrella combat mutated canonical failed approaches")
	var canon_clues: Dictionary = state.get("clues")
	if not canon_clues.has("canon_sentinel") or canon_clues.size() != 1:
		failures.append("Umbrella combat mutated canonical clues")
	var canon_deductions: Dictionary = state.get("deductions")
	if not canon_deductions.has("canon_sentinel") or canon_deductions.size() != 1:
		failures.append("Umbrella combat mutated canonical deductions")

	_finish()


func _test_victory_path() -> void:
	var demo := await _make_combat_ready_demo("anchor")
	if demo == null:
		return

	var action_ids: Array[String] = demo.call("_combat_action_ids")
	if action_ids != ["strike", "guard", "maneuver", "disengage"]:
		failures.append("combat action set is not the locked four-action grammar")

	var active_room: Node = demo.get("_current_room")
	var combat_player := active_room.find_child("PlayerActor", true, false) if active_room != null else null
	if combat_player == null or String(combat_player.call("get_current_pose_id")) != "combat":
		failures.append("loading-bay combat did not switch PC/#3 to the combat reference pose")

	var initial: Dictionary = demo.get("_combat_state")
	if not bool(initial.get("active", false)):
		failures.append("loading-bay encounter did not trigger")
	if int(initial.get("player_condition", -1)) != 8 or int(initial.get("opponent_condition", -1)) != 6:
		failures.append("combat did not start with authored condition values")

	var first: Dictionary = demo.call("_combat_action", "strike")
	var first_action: Dictionary = first.get("player_action", {})
	var first_opponent: Dictionary = first.get("opponent_action", {})
	if int(first_action.get("damage", -1)) != 3:
		failures.append("Anchor strike did not surface 2 base + 1 Resolve damage")
	if int(first_opponent.get("raw_damage", -1)) != 3 or int(first_opponent.get("damage", -1)) != 3:
		failures.append("round-one RUSH did not resolve deterministically")

	var second: Dictionary = demo.call("_combat_action", "strike")
	var final_state: Dictionary = second.get("state", {})
	if String(final_state.get("outcome", "")) != "victory":
		failures.append("two Anchor strikes did not produce the authored victory")
	if bool(demo.call("_combat_is_active")):
		failures.append("victory did not return control to investigation")
	if combat_player != null and String(combat_player.call("get_current_pose_id")) != String(combat_player.call("get_default_pose_id")):
		failures.append("combat completion did not restore the loading-bay default PC/#3 pose")
	var overlay := demo.find_child("CombatOverlay", true, false)
	if overlay == null or overlay.visible:
		failures.append("combat overlay remained visible after victory")

	demo.call("_load_demo_room", "res://rooms/demo/maintenance_corridor.tscn")
	await process_frame
	demo.call("_load_demo_room", "res://rooms/demo/loading_bay.tscn")
	await process_frame
	if bool(demo.call("_combat_is_active")):
		failures.append("completed encounter retriggered on loading-bay re-entry")

	demo.queue_free()
	await process_frame


func _test_skill_disengage_and_persistence() -> void:
	var demo := await _make_combat_ready_demo("reader")
	if demo == null:
		return

	demo.call("_demo_save")
	if bool(demo.get("_has_demo_save")):
		failures.append("active combat incorrectly allowed a local save snapshot")

	var maneuver: Dictionary = demo.call("_combat_action", "maneuver")
	var action: Dictionary = maneuver.get("player_action", {})
	if String(action.get("skill", "")) != "empathy":
		failures.append("Reader maneuver did not use Empathy as strongest authored skill")
	if int(action.get("expertise_bonus", -1)) != 1 or int(action.get("leverage_gain", -1)) != 2:
		failures.append("Reader maneuver did not surface the skill expertise leverage bonus")
	var maneuver_state: Dictionary = maneuver.get("state", {})
	if int(maneuver_state.get("player_condition", -1)) != 6:
		failures.append("maneuver guard did not reduce the surfaced RUSH damage from 3 to 2")

	var disengage: Dictionary = demo.call("_combat_action", "disengage")
	var disengage_action: Dictionary = disengage.get("player_action", {})
	if int(disengage_action.get("total", -1)) != 3 or not bool(disengage_action.get("passed", false)):
		failures.append("Reader did not disengage with Resolve 1 + Leverage 2 = 3/3")
	if String((disengage.get("state", {}) as Dictionary).get("outcome", "")) != "disengaged":
		failures.append("successful disengage did not end the encounter")

	demo.call("_demo_save")
	if not bool(demo.get("_has_demo_save")):
		failures.append("resolved combat did not allow a safe local save")
	demo.set("_combat_completed", false)
	demo.set("_combat_outcome", "")
	demo.set("_combat_consequence", "")
	demo.call("_demo_load")
	if not bool(demo.get("_combat_completed")) or String(demo.get("_combat_outcome")) != "disengaged":
		failures.append("safe save/load did not preserve combat outcome")
	if bool(demo.call("_combat_is_active")):
		failures.append("safe combat-outcome load restored an active half-encounter")

	demo.queue_free()
	await process_frame


func _test_failure_consequence_and_case_completion() -> void:
	var demo := await _make_combat_ready_demo("analyst")
	if demo == null:
		return

	var attempts := 0
	while bool(demo.call("_combat_is_active")) and attempts < 6:
		demo.call("_combat_action", "disengage")
		attempts += 1

	if bool(demo.call("_combat_is_active")):
		failures.append("repeated failed disengage did not terminate through consequence")
	if String(demo.get("_combat_outcome")) != "forced_disengage":
		failures.append("condition failure did not use forced disengagement outcome")
	if String(demo.get("_combat_consequence")) != "bruised_ribs":
		failures.append("failure consequence was not recorded")
	if attempts != 4:
		failures.append("deterministic failed-disengage path took %d actions instead of 4" % attempts)

	demo.call("_acquire_demo_clue", "wet_property_policy", false)
	demo.call("_acquire_demo_clue", "rear_drying_rail", false)
	_expect_established(demo, "drying_not_theft")
	demo.call("_resolve_demo_case")
	if not bool(demo.get("_case_resolved")):
		failures.append("combat consequence prevented umbrella-case completion")

	demo.queue_free()
	await process_frame


func _make_combat_ready_demo(background_id: String) -> Node:
	var scene := load("res://ui/demo/ui_demo.tscn") as PackedScene
	if scene == null:
		failures.append("Umbrella demo scene failed to load")
		return null
	var demo := scene.instantiate()
	root.add_child(demo)
	await process_frame
	if not bool(demo.call("_choose_demo_background", background_id)):
		failures.append("could not choose combat-test background: %s" % background_id)
		return demo

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

	demo.call("_load_demo_room", "res://rooms/demo/loading_bay.tscn")
	await process_frame
	if not bool(demo.call("_combat_is_active")):
		failures.append("combat did not trigger for %s after service-route deduction" % background_id)
	return demo


func _expect_established(demo: Node, deduction_id: String) -> void:
	var result: Dictionary = demo.call("_select_demo_hypothesis", deduction_id)
	if String(result.get("status", "")) != "established":
		failures.append("combat progression did not establish %s (%s)" % [
			deduction_id,
			String(result.get("status", "missing"))
		])


func _finish() -> void:
	if failures.is_empty():
		print("UMBRELLA_COMBAT_OK: trigger, four actions, deterministic math, RPG leverage, victory, disengage, forced consequence, safe persistence, case completion, and canon isolation are valid")
		quit(0)
		return
	for failure in failures:
		push_error("UMBRELLA_COMBAT_FAIL: %s" % failure)
	quit(1)
