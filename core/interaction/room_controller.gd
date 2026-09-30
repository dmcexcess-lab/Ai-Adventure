extends Control
class_name AdventureRoom

signal status_requested(text: String)
signal hover_label_changed(text: String)

@export var room_id := ""
@export var room_title := ""
@export var walk_bounds := Rect2(24.0, 240.0, 592.0, 150.0)
@export var default_spawn := Vector2(320.0, 365.0)

@onready var player: Control = %PlayerActor
@onready var hotspots: Control = %Hotspots

var _interaction_serial := 0
var _reveal_active := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_register_hotspots()
	if player.has_method("place_at_foot"):
		player.call("place_at_foot", default_spawn)


func enter_at(spawn_marker: String = "") -> void:
	var foot := default_spawn
	if not spawn_marker.is_empty():
		var marker := find_child(spawn_marker, true, false)
		if marker is Node2D:
			foot = (marker as Node2D).position
		elif marker is Control:
			foot = (marker as Control).position

	if player.has_method("place_at_foot"):
		player.call("place_at_foot", foot)


func walk_to(point: Vector2) -> void:
	_interaction_serial += 1
	if player.has_method("move_to"):
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
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
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
	var approach := hotspot.get("approach_point") as Vector2

	if approach.x >= 0.0 and approach.y >= 0.0 and player.has_method("move_to"):
		var moved := bool(player.call("move_to", approach, walk_bounds))
		if moved and player.has_signal("arrived"):
			await player.arrived
			if serial != _interaction_serial:
				return

	var transition_room := String(hotspot.get("transition_room"))
	if not transition_room.is_empty():
		var transition_spawn := String(hotspot.get("transition_spawn"))
		status_requested.emit("Moving to the next area.")
		SceneRouter.go_to_room(transition_room, transition_spawn)
		return

	var primary_text := String(hotspot.get("primary_text"))
	if primary_text.is_empty():
		primary_text = "There is nothing more to do here yet."
	status_requested.emit(primary_text)
