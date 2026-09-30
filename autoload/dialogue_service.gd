extends Node

signal trust_changed(witness_id: String, trust: int)
signal topic_opened(witness_id: String, topic_id: String)
signal reaction_recorded(witness_id: String, reaction_id: String)
signal dialogue_state_changed(witness_id: String)

const CATALOG_PATH := "res://content/ch01/dialogue/seed_witnesses.gd"

var _witnesses: Dictionary = {}


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
		var witness := (item as Dictionary).duplicate(true)
		var witness_id := String(witness.get("id", ""))
		var name := String(witness.get("name", ""))
		var start_node := String(witness.get("start_node", ""))
		var nodes = witness.get("nodes", {})
		if witness_id.is_empty() or name.is_empty() or start_node.is_empty():
			return false
		if next.has(witness_id) or not nodes is Dictionary or not nodes.has(start_node):
			return false
		for node_value in (nodes as Dictionary).values():
			if not node_value is Dictionary:
				return false
			if not node_value.get("choices", []) is Array:
				return false
		if not witness.get("evidence_reactions", []) is Array:
			return false
		next[witness_id] = witness
	_witnesses = next
	return true


func get_witness_count() -> int:
	return _witnesses.size()


func has_witness(witness_id: String) -> bool:
	return _witnesses.has(witness_id)


func get_witness(witness_id: String) -> Dictionary:
	if not _witnesses.has(witness_id):
		return {}
	return (_witnesses[witness_id] as Dictionary).duplicate(true)


func start_conversation(witness_id: String) -> Dictionary:
	if not _witnesses.has(witness_id):
		return {}
	var witness: Dictionary = _witnesses[witness_id]
	return get_node_view(witness_id, String(witness.get("start_node", "")))


func get_node_view(witness_id: String, node_id: String) -> Dictionary:
	if not _witnesses.has(witness_id):
		return {}
	var witness: Dictionary = _witnesses[witness_id]
	var nodes: Dictionary = witness.get("nodes", {})
	if not nodes.has(node_id):
		return {}

	var node: Dictionary = nodes[node_id]
	var visible_choices: Array = []
	for choice_value in node.get("choices", []):
		if not choice_value is Dictionary:
			continue
		var choice: Dictionary = choice_value
		if not evaluate_conditions(choice.get("conditions", {}), witness_id):
			continue
		var once_key := String(choice.get("once_key", ""))
		if not once_key.is_empty() and has_reaction(witness_id, once_key):
			continue
		visible_choices.append(choice.duplicate(true))

	return {
		"witness_id": witness_id,
		"witness_name": String(witness.get("name", witness_id)),
		"witness_role": String(witness.get("role", "")),
		"node_id": node_id,
		"line": String(node.get("line", "")),
		"choices": visible_choices,
		"trust": get_trust(witness_id),
	}


func choose(witness_id: String, node_id: String, choice_id: String) -> Dictionary:
	var raw_choice := _find_choice(witness_id, node_id, choice_id)
	if raw_choice.is_empty():
		return {"ok": false, "error": "choice_unavailable"}
	if not evaluate_conditions(raw_choice.get("conditions", {}), witness_id):
		return {"ok": false, "error": "conditions_not_met"}

	var once_key := String(raw_choice.get("once_key", ""))
	if not once_key.is_empty() and has_reaction(witness_id, once_key):
		return {"ok": false, "error": "choice_consumed"}

	var topic_id := String(raw_choice.get("topic_id", ""))
	if not topic_id.is_empty():
		open_topic(witness_id, topic_id)

	apply_effects(witness_id, raw_choice.get("effects", []))

	var next_node := String(raw_choice.get("next_node", node_id))
	var check_result: Dictionary = {}
	var skill_check = raw_choice.get("skill_check", {})
	if skill_check is Dictionary and not (skill_check as Dictionary).is_empty():
		var check: Dictionary = skill_check
		var skills := get_node_or_null("/root/SkillService")
		if skills == null:
			return {"ok": false, "error": "skill_service_unavailable"}
		check_result = skills.call(
			"perform_check",
			String(check.get("check_id", "")),
			String(check.get("skill", "")),
			int(check.get("threshold", 0)),
			int(check.get("modifier", 0)),
			true,
			String(check.get("context", choice_id))
		)
		if not bool(check_result.get("ok", false)):
			return {"ok": false, "error": "invalid_skill_check"}
		if bool(check_result.get("passed", false)):
			apply_effects(witness_id, raw_choice.get("success_effects", []))
			next_node = String(raw_choice.get("success_node", next_node))
		else:
			apply_effects(witness_id, raw_choice.get("failure_effects", []))
			next_node = String(raw_choice.get("failure_node", next_node))

	if not once_key.is_empty():
		record_reaction(witness_id, once_key)

	if bool(raw_choice.get("end", false)):
		return {"ok": true, "end": true, "witness_id": witness_id, "skill_check": check_result}

	var view := get_node_view(witness_id, next_node)
	view["ok"] = not view.is_empty()
	view["end"] = false
	if not check_result.is_empty():
		view["skill_check"] = check_result
	return view


func evaluate_conditions(raw_conditions: Variant, witness_id: String = "") -> bool:
	if not raw_conditions is Dictionary:
		return true
	var conditions: Dictionary = raw_conditions
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return false

	var clues: Dictionary = state.get("clues")
	for clue_id in conditions.get("clues_all", []):
		if not clues.has(String(clue_id)):
			return false
	var clue_any: Array = conditions.get("clues_any", [])
	if not clue_any.is_empty():
		var any_clue := false
		for clue_id in clue_any:
			if clues.has(String(clue_id)):
				any_clue = true
				break
		if not any_clue:
			return false

	var deduction_service := get_node_or_null("/root/DeductionService")
	for deduction_id in conditions.get("deductions_all", []):
		if deduction_service == null or not bool(deduction_service.call("is_established", String(deduction_id))):
			return false

	var hypotheses: Array = state.get("hypotheses")
	for hypothesis_id in conditions.get("hypotheses_all", []):
		if not hypotheses.has(String(hypothesis_id)):
			return false
	var hypothesis_any: Array = conditions.get("hypotheses_any", [])
	if not hypothesis_any.is_empty():
		var any_hypothesis := false
		for hypothesis_id in hypothesis_any:
			if hypotheses.has(String(hypothesis_id)):
				any_hypothesis = true
				break
		if not any_hypothesis:
			return false

	if conditions.has("min_trust") and get_trust(witness_id) < int(conditions["min_trust"]):
		return false
	if conditions.has("max_trust") and get_trust(witness_id) > int(conditions["max_trust"]):
		return false

	var flags: Dictionary = state.get("chapter_flags")
	var required_flags = conditions.get("flags", {})
	if required_flags is Dictionary:
		for flag_name in (required_flags as Dictionary).keys():
			if flags.get(flag_name, null) != required_flags[flag_name]:
				return false

	var skills: Dictionary = state.get("skill_values")
	var skill_min = conditions.get("skills_min", {})
	if skill_min is Dictionary:
		for skill_name in (skill_min as Dictionary).keys():
			if int(skills.get(skill_name, 0)) < int(skill_min[skill_name]):
				return false

	for topic_id in conditions.get("topics_open_all", []):
		if not is_topic_open(witness_id, String(topic_id)):
			return false
	for reaction_id in conditions.get("reactions_unseen", []):
		if has_reaction(witness_id, String(reaction_id)):
			return false

	var skills_service := get_node_or_null("/root/SkillService")
	for check_id in conditions.get("failed_approaches_all", []):
		if skills_service == null or not bool(skills_service.call("has_failed_approach", String(check_id))):
			return false

	return true


func apply_effects(witness_id: String, raw_effects: Variant) -> void:
	if not raw_effects is Array:
		return
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return

	for effect_value in raw_effects:
		if not effect_value is Dictionary:
			continue
		var effect: Dictionary = effect_value
		match String(effect.get("type", "")):
			"acquire_clue":
				var evidence := get_node_or_null("/root/EvidenceService")
				if evidence != null:
					evidence.call(
						"acquire_clue",
						String(effect.get("clue_id", "")),
						int(effect.get("detail_level", 1))
					)
			"trust_delta":
				set_trust(witness_id, get_trust(witness_id) + int(effect.get("amount", 0)))
			"set_trust":
				set_trust(witness_id, int(effect.get("value", 0)))
			"set_flag":
				var flags: Dictionary = (state.get("chapter_flags") as Dictionary).duplicate(true)
				flags[String(effect.get("flag", ""))] = effect.get("value", true)
				state.set("chapter_flags", flags)
			"open_topic":
				open_topic(witness_id, String(effect.get("topic_id", "")))
			"record_reaction":
				record_reaction(witness_id, String(effect.get("reaction_id", "")))

	dialogue_state_changed.emit(witness_id)


func get_relevant_evidence(witness_id: String) -> Array:
	if not _witnesses.has(witness_id):
		return []
	var evidence := get_node_or_null("/root/EvidenceService")
	if evidence == null:
		return []

	var witness: Dictionary = _witnesses[witness_id]
	var reactions: Array = witness.get("evidence_reactions", [])
	var results: Array = []
	var included: Array = []

	for clue_value in evidence.call("get_discovered_evidence"):
		var clue: Dictionary = clue_value
		var clue_id := String(clue.get("id", ""))
		for reaction_value in reactions:
			if not reaction_value is Dictionary:
				continue
			var reaction: Dictionary = reaction_value
			var once_key := String(reaction.get("once_key", ""))
			if not once_key.is_empty() and has_reaction(witness_id, once_key):
				continue
			if not evaluate_conditions(reaction.get("conditions", {}), witness_id):
				continue
			if _reaction_matches_clue(reaction, clue) and not included.has(clue_id):
				included.append(clue_id)
				results.append(clue.duplicate(true))
	return results


func present_evidence(witness_id: String, clue_id: String) -> Dictionary:
	if not _witnesses.has(witness_id):
		return {"ok": false, "status": "unknown_witness"}
	var evidence := get_node_or_null("/root/EvidenceService")
	if evidence == null:
		return {"ok": false, "status": "no_evidence_service"}

	var clue: Dictionary = evidence.call("get_evidence", clue_id)
	if clue.is_empty():
		return {"ok": false, "status": "undiscovered"}

	var witness: Dictionary = _witnesses[witness_id]
	for reaction_value in witness.get("evidence_reactions", []):
		if not reaction_value is Dictionary:
			continue
		var reaction: Dictionary = reaction_value
		var once_key := String(reaction.get("once_key", ""))
		if not once_key.is_empty() and has_reaction(witness_id, once_key):
			continue
		if not evaluate_conditions(reaction.get("conditions", {}), witness_id):
			continue
		if not _reaction_matches_clue(reaction, clue):
			continue

		apply_effects(witness_id, reaction.get("effects", []))
		if not once_key.is_empty():
			record_reaction(witness_id, once_key)
		var next_node := String(reaction.get("next_node", witness.get("start_node", "")))
		var view := get_node_view(witness_id, next_node)
		view["ok"] = not view.is_empty()
		view["status"] = "reacted"
		view["presented_clue_id"] = clue_id
		return view

	return {"ok": false, "status": "not_relevant"}


func get_trust(witness_id: String) -> int:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return 0
	var trust: Dictionary = state.get("witness_trust")
	return int(trust.get(witness_id, 0))


func set_trust(witness_id: String, value: int) -> void:
	if witness_id.is_empty():
		return
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return
	var trust: Dictionary = (state.get("witness_trust") as Dictionary).duplicate(true)
	trust[witness_id] = value
	state.set("witness_trust", trust)
	trust_changed.emit(witness_id, value)


func open_topic(witness_id: String, topic_id: String) -> void:
	if witness_id.is_empty() or topic_id.is_empty():
		return
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return
	var all_topics: Dictionary = (state.get("dialogue_topics") as Dictionary).duplicate(true)
	var witness_topics: Array = []
	if all_topics.get(witness_id, []) is Array:
		witness_topics = (all_topics.get(witness_id, []) as Array).duplicate(true)
	if not witness_topics.has(topic_id):
		witness_topics.append(topic_id)
		all_topics[witness_id] = witness_topics
		state.set("dialogue_topics", all_topics)
		topic_opened.emit(witness_id, topic_id)


func is_topic_open(witness_id: String, topic_id: String) -> bool:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return false
	var all_topics: Dictionary = state.get("dialogue_topics")
	var witness_topics = all_topics.get(witness_id, [])
	return witness_topics is Array and (witness_topics as Array).has(topic_id)


func record_reaction(witness_id: String, reaction_id: String) -> void:
	if witness_id.is_empty() or reaction_id.is_empty():
		return
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return
	var all_reactions: Dictionary = (state.get("dialogue_reactions") as Dictionary).duplicate(true)
	var witness_reactions: Array = []
	if all_reactions.get(witness_id, []) is Array:
		witness_reactions = (all_reactions.get(witness_id, []) as Array).duplicate(true)
	if not witness_reactions.has(reaction_id):
		witness_reactions.append(reaction_id)
		all_reactions[witness_id] = witness_reactions
		state.set("dialogue_reactions", all_reactions)
		reaction_recorded.emit(witness_id, reaction_id)


func has_reaction(witness_id: String, reaction_id: String) -> bool:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return false
	var all_reactions: Dictionary = state.get("dialogue_reactions")
	var witness_reactions = all_reactions.get(witness_id, [])
	return witness_reactions is Array and (witness_reactions as Array).has(reaction_id)


func _find_choice(witness_id: String, node_id: String, choice_id: String) -> Dictionary:
	if not _witnesses.has(witness_id):
		return {}
	var witness: Dictionary = _witnesses[witness_id]
	var nodes: Dictionary = witness.get("nodes", {})
	if not nodes.has(node_id):
		return {}
	var node: Dictionary = nodes[node_id]
	for choice_value in node.get("choices", []):
		if choice_value is Dictionary and String(choice_value.get("id", "")) == choice_id:
			return (choice_value as Dictionary).duplicate(true)
	return {}


func _reaction_matches_clue(reaction: Dictionary, clue: Dictionary) -> bool:
	var clue_id := String(clue.get("id", ""))
	var evidence_ids: Array = reaction.get("evidence_ids", [])
	if evidence_ids.has(clue_id):
		return true
	var clue_tags: Array = clue.get("tags", [])
	for tag in reaction.get("evidence_tags", []):
		if clue_tags.has(tag):
			return true
	return false
