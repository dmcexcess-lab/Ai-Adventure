extends Control

const MANUAL_SLOT := "manual_1"

@onready var context_label: Label = %ContextLabel
@onready var status_label: Label = %StatusLabel
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton

var _current_room: Node
var _last_status := "CASE ACTIVE // Click to walk. Hover objects for context."
var _scene_router: Node
var _save_service: Node


func _ready() -> void:
	_scene_router = get_node_or_null("/root/SceneRouter")
	_save_service = get_node_or_null("/root/SaveService")

	if _scene_router == null:
		push_error("GameShell: SceneRouter autoload is missing.")
		return

	var callback := Callable(self, "_on_room_changed")
	if not _scene_router.is_connected("room_changed", callback):
		_scene_router.connect("room_changed", callback)

	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)

	_scene_router.call("attach_room_host", %RoomHost)
	_scene_router.call("load_first_room")
	_refresh_save_buttons()


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


func _on_status_requested(message: String) -> void:
	_set_status(message)


func _on_hover_label_changed(message: String) -> void:
	if message.is_empty():
		var title := ""
		if is_instance_valid(_current_room):
			title = String(_current_room.get("room_title"))
		context_label.text = title.to_upper() if not title.is_empty() else "WALK"
	else:
		context_label.text = message.to_upper()


func _on_save_pressed() -> void:
	if _save_service == null:
		_set_status("SAVE unavailable.")
		return
	if bool(_save_service.call("save_slot", MANUAL_SLOT)):
		_set_status("CASE SAVED // Slot 1")
	_refresh_save_buttons()


func _on_load_pressed() -> void:
	if _save_service == null:
		_set_status("LOAD unavailable.")
		return
	if bool(_save_service.call("load_slot", MANUAL_SLOT)):
		_set_status("CASE RESTORED // Slot 1")
	else:
		_set_status("No valid save in Slot 1.")
	_refresh_save_buttons()


func _refresh_save_buttons() -> void:
	save_button.disabled = _save_service == null
	load_button.disabled = _save_service == null or not bool(_save_service.call("has_slot", MANUAL_SLOT))


func _set_reveal(value: bool) -> void:
	if is_instance_valid(_current_room) and _current_room.has_method("set_hotspot_reveal"):
		_current_room.call("set_hotspot_reveal", value)
		var title := String(_current_room.get("room_title"))
		context_label.text = "INTERACTABLES" if value else title.to_upper()


func _set_status(message: String) -> void:
	_last_status = message
	status_label.text = _last_status
