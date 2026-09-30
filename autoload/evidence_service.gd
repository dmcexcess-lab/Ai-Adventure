extends Node

signal evidence_added(clue_id: String)
signal evidence_upgraded(clue_id: String, old_level: int, new_level: int)
signal evidence_changed

const CATALOG_PATH := "res://content/ch01/clues/seed_clues.gd"

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
		var clue_id := String(definition.get("id", ""))
		var details = definition.get("detail_levels", [])
		if clue_id.is_empty() or next.has(clue_id):
			return false
		if String(definition.get("title", "")).is_empty() or not details is Array or details.is_empty():
			return false
		next[clue_id] = definition
	_definitions = next
	return true


func has_definition(clue_id: String) -> bool:
	return _definitions.has(clue_id)


func get_definition_count() -> int:
	return _definitions.size()


func acquire_clue(clue_id: String, requested_level: int = 1) -> Dictionary:
	if not _definitions.has(clue_id):
		return {"ok": false, "status": "unknown", "clue_id": clue_id}

	var state := get_node_or_null("/root/GameState")
	if state == null:
		return {"ok": false, "status": "no_state", "clue_id": clue_id}

	var definition: Dictionary = _definitions[clue_id]
	var target_level := clampi(requested_level, 1, _max_level(definition))
	var clues: Dictionary = (state.get("clues") as Dictionary).duplicate(true)

	if not clues.has(clue_id):
		clues[clue_id] = {
			"detail_level": target_level,
			"acquired_at_playtime": float(state.get("playtime_seconds")),
		}
		state.set("clues", clues)
		evidence_added.emit(clue_id)
		evidence_changed.emit()
		return {"ok": true, "status": "added", "clue": get_evidence(clue_id)}

	var saved: Dictionary = (clues[clue_id] as Dictionary).duplicate(true)
	var old_level := clampi(int(saved.get("detail_level", 1)), 1, _max_level(definition))
	if target_level <= old_level:
		return {"ok": true, "status": "unchanged", "clue": get_evidence(clue_id)}

	saved["detail_level"] = target_level
	clues[clue_id] = saved
	state.set("clues", clues)
	evidence_upgraded.emit(clue_id, old_level, target_level)
	evidence_changed.emit()
	return {"ok": true, "status": "upgraded", "clue": get_evidence(clue_id)}


func get_evidence(clue_id: String) -> Dictionary:
	if not _definitions.has(clue_id):
		return {}
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return {}
	var clues: Dictionary = state.get("clues")
	if not clues.has(clue_id):
		return {}

	var result: Dictionary = (_definitions[clue_id] as Dictionary).duplicate(true)
	var saved: Dictionary = clues[clue_id]
	var level := clampi(int(saved.get("detail_level", 1)), 1, _max_level(result))
	result["detail_level"] = level
	result["detail_text"] = _detail_text(result, level)
	result["acquired_at_playtime"] = float(saved.get("acquired_at_playtime", 0.0))
	return result


func get_discovered_evidence(filter_tag: String = "") -> Array:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return []
	var results: Array = []
	var clues: Dictionary = state.get("clues")
	for clue_id in clues.keys():
		var clue := get_evidence(String(clue_id))
		if clue.is_empty():
			continue
		var tags: Array = clue.get("tags", [])
		if filter_tag.is_empty() or tags.has(filter_tag):
			results.append(clue)
	results.sort_custom(_sort_by_title)
	return results


func get_discovered_tags() -> Array:
	var tags: Array = []
	for clue in get_discovered_evidence():
		for tag in clue.get("tags", []):
			var text := String(tag)
			if not tags.has(text):
				tags.append(text)
	tags.sort()
	return tags


func _sort_by_title(a: Dictionary, b: Dictionary) -> bool:
	return String(a.get("title", "")).to_lower() < String(b.get("title", "")).to_lower()


func _max_level(definition: Dictionary) -> int:
	var value := 1
	for detail in definition.get("detail_levels", []):
		value = maxi(value, int(detail.get("level", 1)))
	return value


func _detail_text(definition: Dictionary, level: int) -> String:
	var result := ""
	for detail in definition.get("detail_levels", []):
		if int(detail.get("level", 0)) <= level:
			result = String(detail.get("text", ""))
	return result
