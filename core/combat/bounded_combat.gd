extends RefCounted

const ACTION_ORDER := ["strike", "guard", "maneuver", "disengage"]


var _encounter: Dictionary = {}
var _skills: Dictionary = {}
var _state: Dictionary = {}


func start(encounter: Dictionary, skill_values: Dictionary) -> Dictionary:
	_encounter = encounter.duplicate(true)
	_skills = skill_values.duplicate(true)

	var player_max := int(_encounter.get("player_condition", 8))
	var opponent_max := int(_encounter.get("opponent_condition", 6))
	_state = {
		"active": true,
		"completed": false,
		"outcome": "",
		"consequence": "",
		"round": 1,
		"player_condition": player_max,
		"player_max_condition": player_max,
		"opponent_condition": opponent_max,
		"opponent_max_condition": opponent_max,
		"guard": 0,
		"leverage": 0,
		"opponent_name": String(_encounter.get("opponent_name", "Opponent")),
		"last_resolution": {},
		"log": [
			String(_encounter.get("opening", "The encounter begins."))
		],
	}
	return get_state()


func get_action_ids() -> Array[String]:
	var result: Array[String] = []
	if not bool(_state.get("active", false)):
		return result
	for action_id in ACTION_ORDER:
		result.append(action_id)
	return result


func get_state() -> Dictionary:
	return _state.duplicate(true)


func perform_action(action_id: String) -> Dictionary:
	if not bool(_state.get("active", false)):
		return {"ok": false, "error": "combat_not_active", "state": get_state()}
	if not ACTION_ORDER.has(action_id):
		return {"ok": false, "error": "unknown_action", "state": get_state()}

	var resolution: Dictionary = {
		"ok": true,
		"action": action_id,
		"round": int(_state.get("round", 1)),
		"lines": [],
		"player_action": {},
		"opponent_action": {},
	}

	match action_id:
		"strike":
			_resolve_strike(resolution)
		"guard":
			_resolve_guard(resolution)
		"maneuver":
			_resolve_maneuver(resolution)
		"disengage":
			_resolve_disengage(resolution)

	if bool(_state.get("active", false)) and int(_state.get("opponent_condition", 0)) <= 0:
		_finish("victory", "")
		(resolution["lines"] as Array).append("OPPONENT CONDITION 0 // VICTORY")

	if bool(_state.get("active", false)):
		_resolve_opponent_turn(resolution)

	if bool(_state.get("active", false)):
		_state["round"] = int(_state.get("round", 1)) + 1

	_state["last_resolution"] = resolution.duplicate(true)
	var log: Array = _state.get("log", [])
	for line_value in resolution.get("lines", []):
		log.append(String(line_value))
	while log.size() > 8:
		log.pop_front()
	_state["log"] = log

	resolution["state"] = get_state()
	return resolution


func _resolve_strike(resolution: Dictionary) -> void:
	var resolve_value := int(_skills.get("resolve", 0))
	var resolve_bonus := 1 if resolve_value >= 3 else 0
	var leverage_used := mini(int(_state.get("leverage", 0)), 1)
	var base_damage := int(_encounter.get("strike_damage", 2))
	var damage := base_damage + resolve_bonus + leverage_used
	_state["leverage"] = maxi(0, int(_state.get("leverage", 0)) - leverage_used)
	_state["opponent_condition"] = maxi(0, int(_state.get("opponent_condition", 0)) - damage)
	resolution["player_action"] = {
		"base": base_damage,
		"resolve_bonus": resolve_bonus,
		"leverage_used": leverage_used,
		"damage": damage,
	}
	(resolution["lines"] as Array).append(
		"STRIKE %d + RESOLVE %d + LEVERAGE %d = %d DAMAGE" % [
			base_damage, resolve_bonus, leverage_used, damage
		]
	)


func _resolve_guard(resolution: Dictionary) -> void:
	var resolve_value := int(_skills.get("resolve", 0))
	var resolve_bonus := 1 if resolve_value >= 3 else 0
	var base_guard := int(_encounter.get("guard_value", 2))
	var guard_value := base_guard + resolve_bonus
	_state["guard"] = guard_value
	resolution["player_action"] = {
		"base": base_guard,
		"resolve_bonus": resolve_bonus,
		"guard": guard_value,
	}
	(resolution["lines"] as Array).append(
		"GUARD %d + RESOLVE %d = %d BLOCK" % [base_guard, resolve_bonus, guard_value]
	)


func _resolve_maneuver(resolution: Dictionary) -> void:
	var base_gain := int(_encounter.get("maneuver_leverage", 1))
	var expertise := _best_maneuver_skill()
	var expertise_bonus := 1 if int(expertise.get("value", 0)) >= 3 else 0
	var gain := base_gain + expertise_bonus
	_state["leverage"] = mini(
		int(_encounter.get("max_leverage", 3)),
		int(_state.get("leverage", 0)) + gain
	)
	_state["guard"] = maxi(int(_state.get("guard", 0)), 1)
	resolution["player_action"] = {
		"base": base_gain,
		"skill": String(expertise.get("skill", "")),
		"skill_value": int(expertise.get("value", 0)),
		"expertise_bonus": expertise_bonus,
		"leverage_gain": gain,
		"leverage_total": int(_state.get("leverage", 0)),
		"guard": int(_state.get("guard", 0)),
	}
	var skill_label := String(expertise.get("skill", "none")).to_upper()
	(resolution["lines"] as Array).append(
		"MANEUVER LEVERAGE %d + %s EXPERTISE %d = +%d // TOTAL %d" % [
			base_gain, skill_label, expertise_bonus, gain, int(_state.get("leverage", 0))
		]
	)


func _resolve_disengage(resolution: Dictionary) -> void:
	var resolve_value := int(_skills.get("resolve", 0))
	var leverage := int(_state.get("leverage", 0))
	var total := resolve_value + leverage
	var threshold := int(_encounter.get("disengage_threshold", 3))
	var passed := total >= threshold
	resolution["player_action"] = {
		"resolve": resolve_value,
		"leverage": leverage,
		"total": total,
		"threshold": threshold,
		"passed": passed,
	}
	(resolution["lines"] as Array).append(
		"DISENGAGE RESOLVE %d + LEVERAGE %d = %d / %d // %s" % [
			resolve_value, leverage, total, threshold, "PASS" if passed else "FAIL"
		]
	)
	if passed:
		_finish("disengaged", "")
		(resolution["lines"] as Array).append("You break contact and the trespasser bolts into the rain.")


func _resolve_opponent_turn(resolution: Dictionary) -> void:
	var intents_value: Variant = _encounter.get("intents", [])
	if not intents_value is Array or (intents_value as Array).is_empty():
		return
	var intents: Array = intents_value
	var round_index := maxi(0, int(_state.get("round", 1)) - 1)
	var intent_value: Variant = intents[round_index % intents.size()]
	if not intent_value is Dictionary:
		return
	var intent: Dictionary = intent_value
	var raw_damage := int(intent.get("damage", 0))
	var guard := int(_state.get("guard", 0))
	var applied := maxi(0, raw_damage - guard)
	_state["guard"] = 0
	_state["player_condition"] = maxi(0, int(_state.get("player_condition", 0)) - applied)
	resolution["opponent_action"] = {
		"name": String(intent.get("name", "ATTACK")),
		"raw_damage": raw_damage,
		"guard": guard,
		"damage": applied,
	}
	(resolution["lines"] as Array).append(
		"%s %d - GUARD %d = %d DAMAGE" % [
			String(intent.get("name", "ATTACK")).to_upper(),
			raw_damage,
			guard,
			applied
		]
	)

	if int(_state.get("player_condition", 0)) <= 0:
		_finish("forced_disengage", String(_encounter.get("failure_consequence", "bruised_ribs")))
		(resolution["lines"] as Array).append("CONDITION 0 // FORCED DISENGAGEMENT")


func _best_maneuver_skill() -> Dictionary:
	var best_skill := "observation"
	var best_value := int(_skills.get(best_skill, 0))
	for skill_id in ["reasoning", "empathy"]:
		var value := int(_skills.get(skill_id, 0))
		if value > best_value:
			best_skill = skill_id
			best_value = value
	return {"skill": best_skill, "value": best_value}


func _finish(outcome: String, consequence: String) -> void:
	_state["active"] = false
	_state["completed"] = true
	_state["outcome"] = outcome
	_state["consequence"] = consequence
