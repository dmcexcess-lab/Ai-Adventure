extends Control
class_name AdventureRoom

signal status_requested(text: String)
signal hover_label_changed(text: String)
signal conversation_requested(witness_id: String)

@export var room_id := ""
@export var room_title := ""
@export var walk_bounds := Rect2(24.0, 240.0, 592.0, 150.0)
@export var default_spawn := Vector2(320.0, 365.0)

@onready var player: Control = %PlayerActor
@onready var hotspots: Control = %Hotspots

var _interaction_serial := 0
var _reveal_active := false
var _pending_hotspot: Node
var _pending_serial := -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_register_hotspots()
	if player.has_signal("arrived"):
		player.connect("arrived", Callable(self, "_on_player_arrived"))
	player.call("place_at_foot", default_spawn)


func enter_at(spawn_marker: String = "") -> void:
	var foot := default_spawn
	if not spawn_marker.is_empty():
		var marker := find_child(spawn_marker, true, false)
		if marker is Node2D:
			foot = (marker as Node2D).position
		elif marker is Control:
			foot = (marker as Control).position
	restore_player_foot(foot)


func restore_player_foot(foot: Vector2) -> void:
	player.call("place_at_foot", _clamp_to_walk_bounds(foot))


func get_player_foot() -> Vector2:
	return player.call("get_foot_position")


func walk_to(point: Vector2) -> void:
	_interaction_serial += 1
	_clear_pending_interaction()
	player.call("move_to", point, walk_bounds)
	status_requested.emit("Walking.")


func set_hotspot_reveal(value: bool) -> void:
	_reveal_active = value
	for child in hotspots.get_children():
		if child.has_method("set_reveal"):
			child.call("set_reveal", value)


func is_hotspot_reveal_active() -> bool:
	return _reveal_active


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		walk_to(get_local_mouse_position())
		accept_event()


func _register_hotspots() -> void:
	for child in hotspots.get_children():
		if child.has_signal("hover_changed"):
			child.connect("hover_changed", Callable(self, "_on_hotspot_hover_changed"))
		if child.has_signal("action_requested"):
			child.connect("action_requested", Callable(self, "_on_hotspot_action_requested"))


func _on_hotspot_hover_changed(label: String) -> void:
	hover_label_changed.emit(label)


func _on_hotspot_action_requested(hotspot: Node, action: StringName) -> void:
	if action == &"inspect":
		var inspect_text := String(hotspot.get("inspect_text"))
		if inspect_text.is_empty():
			inspect_text = "Nothing else stands out."
		status_requested.emit(inspect_text)
		return

	_interaction_serial += 1
	var serial := _interaction_serial
	var approach: Vector2 = hotspot.get("approach_point")
	if approach.x >= 0.0 and approach.y >= 0.0:
		var moved: bool = bool(player.call("move_to", approach, walk_bounds))
		if moved:
			_pending_hotspot = hotspot
			_pending_serial = serial
			status_requested.emit("Approaching %s." % String(hotspot.get("display_name")))
			return

	_complete_primary_action(hotspot, serial)


func _on_player_arrived() -> void:
	var router := get_node_or_null("/root/SceneRouter")
	if router != null and router.has_method("sync_current_room_state"):
		router.call("sync_current_room_state")

	if not is_instance_valid(_pending_hotspot):
		_clear_pending_interaction()
		return

	var hotspot := _pending_hotspot
	var serial := _pending_serial
	_clear_pending_interaction()
	if serial == _interaction_serial:
		_complete_primary_action(hotspot, serial)


func _complete_primary_action(hotspot: Node, serial: int) -> void:
	if serial != _interaction_serial or not is_instance_valid(hotspot):
		return

	var witness_id := String(hotspot.get("witness_id"))
	if not witness_id.is_empty():
		conversation_requested.emit(witness_id)
		return

	var evidence_feedback := _grant_hotspot_evidence(hotspot)
	var skill_feedback := _run_hotspot_skill_check(hotspot)
	var transition_room := String(hotspot.get("transition_room"))
	if not transition_room.is_empty():
		var transition_spawn := String(hotspot.get("transition_spawn"))
		var router := get_node_or_null("/root/SceneRouter")
		if router == null:
			status_requested.emit("Transition unavailable: scene router is missing.")
			return
		status_requested.emit("Moving to the next area.")
		router.call("go_to_room", transition_room, transition_spawn)
		return

	var primary_text := String(hotspot.get("primary_text"))
	if primary_text.is_empty():
		primary_text = "There is nothing more to do here yet."
	if not evidence_feedback.is_empty():
		primary_text += "  " + evidence_feedback
	if not skill_feedback.is_empty():
		primary_text += "  " + skill_feedback
	status_requested.emit(primary_text)


func _grant_hotspot_evidence(hotspot: Node) -> String:
	var clue_id := String(hotspot.get("evidence_id"))
	if clue_id.is_empty():
		return ""

	var service := get_node_or_null("/root/EvidenceService")
	if service == null:
		return ""

	var detail_level := int(hotspot.get("evidence_detail_level"))
	var result: Dictionary = service.call("acquire_clue", clue_id, detail_level)
	if not bool(result.get("ok", false)):
		return ""

	var clue: Dictionary = result.get("clue", {})
	var title := String(clue.get("title", clue_id))
	match String(result.get("status", "")):
		"added":
			return "Evidence recorded: %s." % title
		"upgraded":
			return "Evidence updated: %s." % title
		_:
			return ""


func _run_hotspot_skill_check(hotspot: Node) -> String:
	var check_id := String(hotspot.get("skill_check_id"))
	var skill_id := String(hotspot.get("skill_name"))
	if check_id.is_empty() or skill_id.is_empty():
		return ""

	var skills := get_node_or_null("/root/SkillService")
	if skills == null:
		return ""

	var result: Dictionary = skills.call(
		"perform_check",
		check_id,
		skill_id,
		int(hotspot.get("skill_threshold")),
		int(hotspot.get("skill_modifier")),
		true,
		String(hotspot.get("display_name"))
	)

	if not bool(result.get("ok", false)):
		return ""

	if bool(result.get("passed", false)):
		var success_clue := String(hotspot.get("skill_success_evidence_id"))
		if not success_clue.is_empty():
			var evidence := get_node_or_null("/root/EvidenceService")
			if evidence != null:
				evidence.call(
					"acquire_clue",
					success_clue,
					int(hotspot.get("skill_success_evidence_detail_level"))
				)
		var success_text := String(hotspot.get("skill_success_text"))
		if success_text.is_empty():
			success_text = "%s check passed." % skill_id.capitalize()
		return success_text

	var failure_text := String(hotspot.get("skill_failure_text"))
	if failure_text.is_empty():
		failure_text = "That approach does not reveal anything more."
	return failure_text


func _clear_pending_interaction() -> void:
	_pending_hotspot = null
	_pending_serial = -1


func _clamp_to_walk_bounds(point: Vector2) -> Vector2:
	var max_point := walk_bounds.position + walk_bounds.size
	return Vector2(
		clampf(point.x, walk_bounds.position.x, max_point.x),
		clampf(point.y, walk_bounds.position.y, max_point.y)
	)
