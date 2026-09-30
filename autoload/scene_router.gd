extends Node

signal room_changed(room_path: String, room: Node)

const MAIN_MENU := "res://ui/menus/main_menu.tscn"
const GAME_SHELL := "res://core/game_shell/game_shell.tscn"
const FIRST_TEST_ROOM := "res://rooms/ch01/test_room.tscn"

var _room_host: Control
var current_room: Node


func _ready() -> void:
	_install_input_actions()


func start_new_game() -> void:
	get_tree().change_scene_to_file(GAME_SHELL)


func return_to_menu() -> void:
	_room_host = null
	current_room = null
	get_tree().change_scene_to_file(MAIN_MENU)


func attach_room_host(host: Control) -> void:
	_room_host = host


func load_first_room() -> bool:
	return go_to_room(FIRST_TEST_ROOM)


func go_to_room(room_path: String, spawn_marker: String = "") -> bool:
	if not is_instance_valid(_room_host):
		push_error("SceneRouter: no room host is attached.")
		return false

	var packed := load(room_path) as PackedScene
	if packed == null:
		push_error("SceneRouter: unable to load room: %s" % room_path)
		return false

	for child in _room_host.get_children():
		_room_host.remove_child(child)
		child.queue_free()

	var room := packed.instantiate()
	_room_host.add_child(room)
	if room is Control:
		(room as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	current_room = room
	if room.has_method("enter_at"):
		room.call("enter_at", spawn_marker)

	room_changed.emit(room_path, room)
	return true


func _install_input_actions() -> void:
	_bind_key_action("notebook", KEY_N)
	_bind_key_action("evidence", KEY_E)
	_bind_key_action("character", KEY_C)
	_bind_key_action("reveal_hotspots", KEY_SPACE)
	_bind_key_action("menu_back", KEY_ESCAPE)
	_bind_mouse_action("primary_interact", MOUSE_BUTTON_LEFT)
	_bind_mouse_action("secondary_inspect", MOUSE_BUTTON_RIGHT)


func _bind_key_action(action_name: StringName, keycode: Key) -> void:
	if InputMap.has_action(action_name):
		return
	InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)


func _bind_mouse_action(action_name: StringName, button_index: MouseButton) -> void:
	if InputMap.has_action(action_name):
		return
	InputMap.add_action(action_name)
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action_name, event)
