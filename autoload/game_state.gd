extends Node

signal state_reset
signal state_loaded

const DEFAULT_SKILLS := {
	"observation": 0,
	"reasoning": 0,
	"empathy": 0,
	"resolve": 0,
}

var current_room_path := ""
var current_room_id := ""
var current_player_foot := Vector2.ZERO
var clues: Dictionary = {}
var deductions: Dictionary = {}
var hypotheses: Array = []
var witness_trust: Dictionary = {}
var dialogue_topics: Dictionary = {}
var dialogue_reactions: Dictionary = {}
var chapter_flags: Dictionary = {}
var background_id := ""
var skill_values: Dictionary = DEFAULT_SKILLS.duplicate(true)
var failed_approaches: Dictionary = {}
var inventory: Array = []
var visited_locations: Array = []
var playtime_seconds := 0.0
var session_active := false


func _process(delta: float) -> void:
	if session_active:
		playtime_seconds += delta


func reset_new_game() -> void:
	current_room_path = ""
	current_room_id = ""
	current_player_foot = Vector2.ZERO
	clues = {}
	deductions = {}
	hypotheses = []
	witness_trust = {}
	dialogue_topics = {}
	dialogue_reactions = {}
	chapter_flags = {}
	background_id = ""
	skill_values = DEFAULT_SKILLS.duplicate(true)
	failed_approaches = {}
	inventory = []
	visited_locations = []
	playtime_seconds = 0.0
	session_active = true
	state_reset.emit()


func pause_session() -> void:
	session_active = false


func resume_session() -> void:
	session_active = true


func set_room(room_path: String, room_id: String, player_foot: Vector2) -> void:
	current_room_path = room_path
	current_room_id = room_id
	current_player_foot = player_foot
	if not room_id.is_empty() and not visited_locations.has(room_id):
		visited_locations.append(room_id)


func set_player_foot(player_foot: Vector2) -> void:
	current_player_foot = player_foot


func to_serializable_state() -> Dictionary:
	return {
		"current_room_path": current_room_path,
		"current_room_id": current_room_id,
		"current_player_foot": {"x": current_player_foot.x, "y": current_player_foot.y},
		"clues": clues.duplicate(true),
		"deductions": deductions.duplicate(true),
		"hypotheses": hypotheses.duplicate(true),
		"witness_trust": witness_trust.duplicate(true),
		"dialogue_topics": dialogue_topics.duplicate(true),
		"dialogue_reactions": dialogue_reactions.duplicate(true),
		"chapter_flags": chapter_flags.duplicate(true),
		"background_id": background_id,
		"skill_values": skill_values.duplicate(true),
		"failed_approaches": failed_approaches.duplicate(true),
		"inventory": inventory.duplicate(true),
		"visited_locations": visited_locations.duplicate(true),
		"playtime_seconds": playtime_seconds,
	}


func apply_serializable_state(raw_state: Dictionary) -> bool:
	var normalized := normalize_serializable_state(raw_state)
	if normalized.is_empty():
		return false
	current_room_path = String(normalized["current_room_path"])
	current_room_id = String(normalized["current_room_id"])
	var foot: Dictionary = normalized["current_player_foot"]
	current_player_foot = Vector2(float(foot["x"]), float(foot["y"]))
	clues = (normalized["clues"] as Dictionary).duplicate(true)
	deductions = (normalized["deductions"] as Dictionary).duplicate(true)
	hypotheses = (normalized["hypotheses"] as Array).duplicate(true)
	witness_trust = (normalized["witness_trust"] as Dictionary).duplicate(true)
	dialogue_topics = (normalized["dialogue_topics"] as Dictionary).duplicate(true)
	dialogue_reactions = (normalized["dialogue_reactions"] as Dictionary).duplicate(true)
	chapter_flags = (normalized["chapter_flags"] as Dictionary).duplicate(true)
	background_id = String(normalized["background_id"])
	skill_values = (normalized["skill_values"] as Dictionary).duplicate(true)
	failed_approaches = (normalized["failed_approaches"] as Dictionary).duplicate(true)
	inventory = (normalized["inventory"] as Array).duplicate(true)
	visited_locations = (normalized["visited_locations"] as Array).duplicate(true)
	playtime_seconds = float(normalized["playtime_seconds"])
	session_active = true
	state_loaded.emit()
	return true


func normalize_serializable_state(raw_state: Dictionary) -> Dictionary:
	if raw_state.is_empty():
		return {}

	var foot_value = raw_state.get("current_player_foot", {"x": 0.0, "y": 0.0})
	var foot := {"x": 0.0, "y": 0.0}
	if foot_value is Dictionary:
		foot["x"] = float(foot_value.get("x", 0.0))
		foot["y"] = float(foot_value.get("y", 0.0))
	elif foot_value is Array and foot_value.size() >= 2:
		foot["x"] = float(foot_value[0])
		foot["y"] = float(foot_value[1])

	var normalized_skills := DEFAULT_SKILLS.duplicate(true)
	var incoming_skills = raw_state.get("skill_values", {})
	if incoming_skills is Dictionary:
		for key in normalized_skills.keys():
			normalized_skills[key] = int(incoming_skills.get(key, normalized_skills[key]))

	return {
		"current_room_path": String(raw_state.get("current_room_path", "")),
		"current_room_id": String(raw_state.get("current_room_id", "")),
		"current_player_foot": foot,
		"clues": _dict_or_empty(raw_state.get("clues", {})),
		"deductions": _dict_or_empty(raw_state.get("deductions", {})),
		"hypotheses": _array_or_empty(raw_state.get("hypotheses", [])),
		"witness_trust": _dict_or_empty(raw_state.get("witness_trust", {})),
		"dialogue_topics": _dict_or_empty(raw_state.get("dialogue_topics", {})),
		"dialogue_reactions": _dict_or_empty(raw_state.get("dialogue_reactions", {})),
		"chapter_flags": _dict_or_empty(raw_state.get("chapter_flags", {})),
		"background_id": String(raw_state.get("background_id", "")),
		"skill_values": normalized_skills,
		"failed_approaches": _dict_or_empty(raw_state.get("failed_approaches", {})),
		"inventory": _array_or_empty(raw_state.get("inventory", [])),
		"visited_locations": _array_or_empty(raw_state.get("visited_locations", [])),
		"playtime_seconds": maxf(0.0, float(raw_state.get("playtime_seconds", 0.0))),
	}


func _dict_or_empty(value: Variant) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {}


func _array_or_empty(value: Variant) -> Array:
	if value is Array:
		return (value as Array).duplicate(true)
	return []
