extends Node

signal background_applied(background_id: String)
signal failed_approach_recorded(check_id: String)

const SKILLS := {
	"observation": {
		"name": "Observation",
		"description": "Notice physical and visual irregularities others overlook."
	},
	"reasoning": {
		"name": "Reasoning",
		"description": "Extract stronger conclusions from technical and documentary evidence."
	},
	"empathy": {
		"name": "Empathy",
		"description": "Read emotional mismatch and open human routes through the case."
	},
	"resolve": {
		"name": "Resolve",
		"description": "Push through pressure, evasions, and disturbing implications."
	}
}

const BACKGROUNDS := {
	"watcher": {
		"title": "The Watcher",
		"sentence": "I notice what everyone else edits out.",
		"skills": {"observation": 3, "reasoning": 2, "empathy": 1, "resolve": 1}
	},
	"analyst": {
		"title": "The Analyst",
		"sentence": "I trust the structure before the story.",
		"skills": {"observation": 2, "reasoning": 3, "empathy": 1, "resolve": 1}
	},
	"reader": {
		"title": "The Reader",
		"sentence": "People tell me more than they mean to.",
		"skills": {"observation": 2, "reasoning": 1, "empathy": 3, "resolve": 1}
	},
	"anchor": {
		"title": "The Anchor",
		"sentence": "When something pushes back, I keep going.",
		"skills": {"observation": 1, "reasoning": 2, "empathy": 1, "resolve": 3}
	}
}

const BACKGROUND_ORDER := ["watcher", "analyst", "reader", "anchor"]


func get_skill_definitions() -> Dictionary:
	return SKILLS.duplicate(true)


func get_backgrounds() -> Array:
	var result: Array = []
	for background_id in BACKGROUND_ORDER:
		var entry: Dictionary = (BACKGROUNDS[background_id] as Dictionary).duplicate(true)
		entry["id"] = background_id
		result.append(entry)
	return result


func get_background(background_id: String) -> Dictionary:
	if not BACKGROUNDS.has(background_id):
		return {}
	var result: Dictionary = (BACKGROUNDS[background_id] as Dictionary).duplicate(true)
	result["id"] = background_id
	return result


func apply_background(background_id: String) -> bool:
	if not BACKGROUNDS.has(background_id):
		return false
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return false
	var profile: Dictionary = BACKGROUNDS[background_id]
	state.set("background_id", background_id)
	state.set("skill_values", (profile["skills"] as Dictionary).duplicate(true))
	background_applied.emit(background_id)
	return true


func evaluate_values(skill_values: Dictionary, skill_id: String, threshold: int, modifier: int = 0) -> Dictionary:
	if not SKILLS.has(skill_id):
		return {"ok": false, "passed": false, "error": "invalid_skill"}
	var base := int(skill_values.get(skill_id, 0))
	var total := base + modifier
	return {
		"ok": true,
		"skill": skill_id,
		"base": base,
		"modifier": modifier,
		"total": total,
		"threshold": threshold,
		"passed": total >= threshold,
		"margin": total - threshold
	}


func evaluate_check(skill_id: String, threshold: int, modifier: int = 0) -> Dictionary:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return {"ok": false, "passed": false, "error": "invalid_skill_or_state"}
	var skills: Dictionary = state.get("skill_values")
	return evaluate_values(skills, skill_id, threshold, modifier)


func perform_check(
	check_id: String,
	skill_id: String,
	threshold: int,
	modifier: int = 0,
	record_failure: bool = true,
	context: String = ""
) -> Dictionary:
	var result := evaluate_check(skill_id, threshold, modifier)
	result["check_id"] = check_id
	result["context"] = context
	if not bool(result.get("ok", false)):
		return result
	if not bool(result.get("passed", false)) and record_failure and not check_id.is_empty():
		_record_failed_approach(check_id, result)
	return result


func get_failed_approaches() -> Dictionary:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return {}
	return (state.get("failed_approaches") as Dictionary).duplicate(true)


func has_failed_approach(check_id: String) -> bool:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return false
	return (state.get("failed_approaches") as Dictionary).has(check_id)


func _record_failed_approach(check_id: String, result: Dictionary) -> void:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return

	var failed: Dictionary = (state.get("failed_approaches") as Dictionary).duplicate(true)
	var prior: Dictionary = {}
	if failed.get(check_id, {}) is Dictionary:
		prior = (failed.get(check_id, {}) as Dictionary).duplicate(true)

	var attempts := int(prior.get("attempts", 0)) + 1
	failed[check_id] = {
		"check_id": check_id,
		"skill": String(result.get("skill", "")),
		"threshold": int(result.get("threshold", 0)),
		"last_total": int(result.get("total", 0)),
		"last_modifier": int(result.get("modifier", 0)),
		"context": String(result.get("context", "")),
		"attempts": attempts
	}
	state.set("failed_approaches", failed)
	failed_approach_recorded.emit(check_id)
