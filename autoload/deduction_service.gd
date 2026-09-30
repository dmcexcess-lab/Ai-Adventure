extends Node

signal hypothesis_selected(deduction_id: String, status: String)
signal deduction_established(deduction_id: String)
signal deduction_changed(deduction_id: String, status: String)

const CATALOG_PATH := "res://content/ch01/deductions/seed_deductions.gd"

var _definitions: Dictionary = {}


func _ready() -> void:
	load_catalog()


func load_catalog() -> bool:
	var script := load(CATALOG_PATH) as Script
	if script == null or not script.can_instantiate():
		return false
	var provider: Object = script.new()
	if provider == null:
		return false
	return load_definitions(provider.call("get_definitions"))


func load_definitions(items: Array) -> bool:
	var next: Dictionary = {}
	for item in items:
		if not item is Dictionary:
			return false
		var definition := (item as Dictionary).duplicate(true)
		var deduction_id := String(definition.get("id", ""))
		if deduction_id.is_empty() or next.has(deduction_id):
			return false
		if String(definition.get("title", "")).is_empty():
			return false
		if not definition.get("required_clue_ids", []) is Array:
			return false
		if not definition.get("required_tags", []) is Array:
			return false
		if not definition.get("prerequisite_deductions", []) is Array:
			return false
		if int(definition.get("minimum_support", 1)) < 1:
			return false
		next[deduction_id] = definition
	_definitions = next
	return true


func get_definition_count() -> int:
	return _definitions.size()


func has_definition(deduction_id: String) -> bool:
	return _definitions.has(deduction_id)


func get_definition(deduction_id: String) -> Dictionary:
	if not _definitions.has(deduction_id):
		return {}
	return (_definitions[deduction_id] as Dictionary).duplicate(true)


func get_all_deductions() -> Array:
	var results: Array = []
	for deduction_id in _definitions.keys():
		results.append(evaluate(String(deduction_id)))
	results.sort_custom(_sort_by_title)
	return results


func evaluate(deduction_id: String) -> Dictionary:
	if not _definitions.has(deduction_id):
		return {}

	var definition: Dictionary = (_definitions[deduction_id] as Dictionary).duplicate(true)
	var state := get_node_or_null("/root/GameState")
	var evidence := get_node_or_null("/root/EvidenceService")
	if state == null or evidence == null:
		return {}

	var discovered: Array = evidence.call("get_discovered_evidence")
	var discovered_by_id: Dictionary = {}
	for clue_value in discovered:
		var clue: Dictionary = clue_value
		discovered_by_id[String(clue.get("id", ""))] = clue

	var support_ids: Array = []
	for clue_id_value in definition.get("required_clue_ids", []):
		var clue_id := String(clue_id_value)
		if discovered_by_id.has(clue_id) and not support_ids.has(clue_id):
			support_ids.append(clue_id)

	for required_tag_value in definition.get("required_tags", []):
		var required_tag := String(required_tag_value)
		for clue_value in discovered:
			var clue: Dictionary = clue_value
			var clue_id := String(clue.get("id", ""))
			var tags: Array = clue.get("tags", [])
			if tags.has(required_tag) and not support_ids.has(clue_id):
				support_ids.append(clue_id)

	var contradicting_ids: Array = []
	var refute_tags: Array = definition.get("refute_evidence_tags", [])
	var refute_contradictions: Array = definition.get("refute_contradiction_tags", [])
	for clue_value in discovered:
		var clue: Dictionary = clue_value
		var clue_id := String(clue.get("id", ""))
		var clue_tags: Array = clue.get("tags", [])
		var contradiction_tags: Array = clue.get("contradiction_tags", [])
		if _intersects(clue_tags, refute_tags) or _intersects(contradiction_tags, refute_contradictions):
			contradicting_ids.append(clue_id)

	var prerequisite_ids: Array = definition.get("prerequisite_deductions", [])
	var prerequisites_met := true
	for prerequisite_value in prerequisite_ids:
		if not is_established(String(prerequisite_value)):
			prerequisites_met = false
			break

	var minimum_support := int(definition.get("minimum_support", 1))
	var selected := (state.get("hypotheses") as Array).has(deduction_id)
	var established := is_established(deduction_id)
	var status := "unsupported"

	if not contradicting_ids.is_empty():
		status = "refuted"
	elif established:
		status = "established"
	elif prerequisites_met and support_ids.size() >= minimum_support:
		status = "supported"

	definition["status"] = status
	definition["selected"] = selected
	definition["support_count"] = support_ids.size()
	definition["minimum_support"] = minimum_support
	definition["supporting_evidence_ids"] = support_ids
	definition["contradicting_evidence_ids"] = contradicting_ids
	definition["prerequisites_met"] = prerequisites_met
	definition["established"] = established
	return definition


func select_hypothesis(deduction_id: String) -> Dictionary:
	if not _definitions.has(deduction_id):
		return {"ok": false, "status": "unknown"}

	var state := get_node_or_null("/root/GameState")
	if state == null:
		return {"ok": false, "status": "no_state"}

	var hypotheses: Array = (state.get("hypotheses") as Array).duplicate(true)
	if not hypotheses.has(deduction_id):
		hypotheses.append(deduction_id)
		state.set("hypotheses", hypotheses)

	var evaluation := evaluate(deduction_id)
	var status := String(evaluation.get("status", "unsupported"))

	if status == "supported":
		var deductions: Dictionary = (state.get("deductions") as Dictionary).duplicate(true)
		if not deductions.has(deduction_id):
			deductions[deduction_id] = {
				"state": "established",
				"established_at_playtime": float(state.get("playtime_seconds")),
			}
			state.set("deductions", deductions)
			deduction_established.emit(deduction_id)
			status = "established"
		elif String((deductions[deduction_id] as Dictionary).get("state", "")) == "established":
			status = "established"

	hypothesis_selected.emit(deduction_id, status)
	deduction_changed.emit(deduction_id, status)
	var result := evaluate(deduction_id)
	result["ok"] = true
	return result


func is_established(deduction_id: String) -> bool:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return false
	var deductions: Dictionary = state.get("deductions")
	if not deductions.has(deduction_id):
		return false
	var saved: Dictionary = deductions[deduction_id]
	return String(saved.get("state", "")) == "established"


func get_selected_hypotheses() -> Array:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return []
	return (state.get("hypotheses") as Array).duplicate(true)


func get_visible_support(deduction_id: String) -> Array:
	var evaluation := evaluate(deduction_id)
	var evidence := get_node_or_null("/root/EvidenceService")
	if evaluation.is_empty() or evidence == null:
		return []
	var results: Array = []
	for clue_id in evaluation.get("supporting_evidence_ids", []):
		var clue: Dictionary = evidence.call("get_evidence", String(clue_id))
		if not clue.is_empty():
			results.append(clue)
	return results


func get_visible_contradictions(deduction_id: String) -> Array:
	var evaluation := evaluate(deduction_id)
	var evidence := get_node_or_null("/root/EvidenceService")
	if evaluation.is_empty() or evidence == null:
		return []
	var results: Array = []
	for clue_id in evaluation.get("contradicting_evidence_ids", []):
		var clue: Dictionary = evidence.call("get_evidence", String(clue_id))
		if not clue.is_empty():
			results.append(clue)
	return results


func _intersects(left: Array, right: Array) -> bool:
	for value in left:
		if right.has(value):
			return true
	return false


func _sort_by_title(a: Dictionary, b: Dictionary) -> bool:
	return String(a.get("title", "")).to_lower() < String(b.get("title", "")).to_lower()
