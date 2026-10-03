extends Control

signal status_requested(text: String)
signal hover_label_changed(text: String)
signal conversation_requested(witness_id: String)
signal transition_requested(room_path: String, spawn_marker: String)
signal hotspot_activated(hotspot: Node)

@export var room_id := ""
@export var room_title := ""
@export var room_subtitle := ""
@export var walk_bounds := Rect2(24.0, 238.0, 592.0, 150.0)
@export var default_spawn := Vector2(320.0, 360.0)

@onready var player: Control = %PlayerActor
@onready var hotspots: Control = %Hotspots

var _interaction_serial := 0
var _pending_hotspot: Node
var _pending_serial := -1
var _reveal_active := false
var _witness_visuals: Array[Control] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	for child in hotspots.get_children():
		if child.has_signal("hover_changed"):
			child.connect("hover_changed", Callable(self, "_on_hotspot_hover_changed"))
		if child.has_signal("action_requested"):
			child.connect("action_requested", Callable(self, "_on_hotspot_action_requested"))
	if player.has_signal("arrived"):
		player.connect("arrived", Callable(self, "_on_player_arrived"))
	for child in get_children():
		if child.has_method("show_pose"):
			_witness_visuals.append(child)
	player.call("place_at_foot", default_spawn)
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.18)
	set_process(true)


func _process(_delta: float) -> void:
	player.z_index = int(player.call("get_foot_position").y)
	for witness in _witness_visuals:
		witness.z_index = int(witness.position.y + witness.size.y)


func enter_at(spawn_marker: String = "") -> void:
	var foot := default_spawn
	if not spawn_marker.is_empty():
		var marker := find_child(spawn_marker, true, false)
		if marker is Control:
			foot = (marker as Control).position
		elif marker is Node2D:
			foot = (marker as Node2D).position
	restore_player_foot(foot)


func restore_player_foot(foot: Vector2) -> void:
	player.call("place_at_foot", _clamp_to_walk_bounds(foot))


func get_player_foot() -> Vector2:
	return player.call("get_foot_position")


func get_transition_targets() -> Array[Dictionary]:
	var targets: Array[Dictionary] = []
	for child in hotspots.get_children():
		var room_path := String(child.get("transition_room"))
		if room_path.is_empty():
			continue
		targets.append({
			"hotspot_id": String(child.get("hotspot_id")),
			"room_path": room_path,
			"spawn_marker": String(child.get("transition_spawn"))
		})
	return targets


func set_hotspot_reveal(value: bool) -> void:
	_reveal_active = value
	for child in hotspots.get_children():
		if child.has_method("set_reveal"):
			child.call("set_reveal", value)


func is_hotspot_reveal_active() -> bool:
	return _reveal_active


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_interaction_serial += 1
		_clear_pending_interaction()
		player.call("move_to", get_local_mouse_position(), walk_bounds)
		status_requested.emit("Walking.")
		accept_event()


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
		if bool(player.call("move_to", approach, walk_bounds)):
			_pending_hotspot = hotspot
			_pending_serial = serial
			status_requested.emit("Approaching %s." % String(hotspot.get("display_name")))
			return
	_complete_primary_action(hotspot, serial)


func _on_player_arrived() -> void:
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

	var transition_room := String(hotspot.get("transition_room"))
	if not transition_room.is_empty():
		transition_requested.emit(transition_room, String(hotspot.get("transition_spawn")))
		return

	var witness_id := String(hotspot.get("witness_id"))
	if not witness_id.is_empty():
		player.call("play_action", "dialogue")
		_set_witness_pose(witness_id, "talking")
		conversation_requested.emit(witness_id)
		return

	player.call("play_action", _action_for_hotspot(String(hotspot.get("hotspot_id"))))
	hotspot_activated.emit(hotspot)


func _clear_pending_interaction() -> void:
	_pending_hotspot = null
	_pending_serial = -1


func _clamp_to_walk_bounds(point: Vector2) -> Vector2:
	var max_point := walk_bounds.position + walk_bounds.size
	return Vector2(
		clampf(point.x, walk_bounds.position.x, max_point.x),
		clampf(point.y, walk_bounds.position.y, max_point.y)
	)


func set_witness_expression(witness_id: String, pose_id: String) -> void:
	_set_witness_pose(witness_id, pose_id)


func _set_witness_pose(witness_id: String, pose_id: String) -> void:
	for witness in _witness_visuals:
		if String(witness.get("witness_id")) == witness_id:
			witness.call("show_pose", pose_id)


func _action_for_hotspot(hotspot_id: String) -> String:
	var lowered := hotspot_id.to_lower()
	if "record" in lowered or "log" in lowered or "board" in lowered or "policy" in lowered or "handbook" in lowered:
		return "read"
	if "umbrella" in lowered or "ticket" in lowered or "tag" in lowered:
		return "pick_up"
	return "inspect"
