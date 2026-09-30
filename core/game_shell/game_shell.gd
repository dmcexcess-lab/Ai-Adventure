extends Control

@onready var context_label: Label = %ContextLabel
@onready var status_label: Label = %StatusLabel

var _current_room: Node
var _last_status := "CASE ACTIVE // Click to walk. Hover objects for context."
var _scene_router: Node


func _ready() -> void:
	_scene_router = get_node_or_null("/root/SceneRouter")
	if _scene_router == null:
		push_error("GameShell: SceneRouter autoload is missing.")
		return

	var callback := Callable(self, "_on_room_changed")
	if not _scene_router.is_connected("room_changed", callback):
		_scene_router.connect("room_changed", callback)

	_scene_router.call("attach_room_host", %RoomHost)
	_scene_router.call("load_first_room")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu_back"):
		if _scene_router != null:
			_scene_router.call("return_to_menu")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("reveal_hotspots"):
		_set_reveal(true)
		get_viewport().set_input_as_handled()
	elif event.is_action_released("reveal_hotspots"):
		_set_reveal(false)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("notebook"):
		_set_status("NOTEBOOK — evidence system arrives in Slice 5")
	elif event.is_action_pressed("evidence"):
		_set_status("EVIDENCE — case file scaffold online")
	elif event.is_action_pressed("character"):
		_set_status("CHARACTER — RPG layer arrives in Slice 8")


func _on_room_changed(_room_path: String, room: Node) -> void:
	_current_room = room

	if room.has_signal("status_requested"):
		room.connect("status_requested", Callable(self, "_on_status_requested"))
	if room.has_signal("hover_label_changed"):
		room.connect("hover_label_changed", Callable(self, "_on_hover_label_changed"))

	var title := String(room.get("room_title"))
	context_label.text = title.to_upper() if not title.is_empty() else "LOCATION"
	_set_status("Entered %s." % (title if not title.is_empty() else "the area"))


func _on_status_requested(text: String) -> void:
	_set_status(text)


func _on_hover_label_changed(text: String) -> void:
	if text.is_empty():
		var title := ""
		if is_instance_valid(_current_room):
			title = String(_current_room.get("room_title"))
		context_label.text = title.to_upper() if not title.is_empty() else "WALK"
	else:
		context_label.text = text.to_upper()


func _set_reveal(value: bool) -> void:
	if is_instance_valid(_current_room) and _current_room.has_method("set_hotspot_reveal"):
		_current_room.call("set_hotspot_reveal", value)
		var title := String(_current_room.get("room_title"))
		context_label.text = "INTERACTABLES" if value else title.to_upper()


func _set_status(message: String) -> void:
	_last_status = message
	status_label.text = _last_status
