extends Node

signal room_changed(room_path: String, room: Node)

const MAIN_MENU := "res://ui/menus/main_menu.tscn"
const GAME_SHELL := "res://core/game_shell/game_shell.tscn"
const FIRST_TEST_ROOM := "res://rooms/ch01/test_room.tscn"

var _room_host: Control
var current_room: Node
var current_room_path := ""


func _ready() -> void:
	_install_input_actions()


func start_new_game() -> void:
	var state := get_node_or_null("/root/GameState")
	if state != null and state.has_method("reset_new_game"):
		state.call("reset_new_game")
	get_tree().change_scene_to_file(GAME_SHELL)


func return_to_menu() -> void:
	var state := get_node_or_null("/root/GameState")
	if state != null and state.has_method("pause_session"):
		state.call("pause_session")
	_room_host = null
	current_room = null
	current_room_path = ""
	get_tree().change_scene_to_file(MAIN_MENU)


func attach_room_host(host: Control) -> void:
	_room_host = host


func load_first_room() -> bool:
	return go_to_room(FIRST_TEST_ROOM)


func go_to_room(
	room_path: String,
	spawn_marker: String = "",
	restore_foot: Vector2 = Vector2(-1.0, -1.0),
	write_autosave: bool = true
) -> bool:
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
	current_room_path = room_path

	if room.has_method("enter_at"):
		room.call("enter_at", spawn_marker)
	if restore_foot.x >= 0.0 and restore_foot.y >= 0.0 and room.has_method("restore_player_foot"):
		room.call("restore_player_foot", restore_foot)

	sync_current_room_state()
	room_changed.emit(room_path, room)

	if write_autosave:
		var saves := get_node_or_null("/root/SaveService")
		if saves != null and saves.has_method("auto_save"):
			saves.call("auto_save")

	return true


func sync_current_room_state() -> void:
	if not is_instance_valid(current_room):
		return

	var state := get_node_or_null("/root/GameState")
	if state == null:
		return

	var room_id := String(current_room.get("room_id"))
	var player_foot := Vector2.ZERO
	if current_room.has_method("get_player_foot"):
		player_foot = current_room.call("get_player_foot")

	state.call("set_room", current_room_path, room_id, player_foot)


func restore_from_state() -> bool:
	var state := get_node_or_null("/root/GameState")
	if state == null:
		return false

	var room_path := String(state.get("current_room_path"))
	if room_path.is_empty():
		room_path = FIRST_TEST_ROOM

	var foot: Vector2 = state.get("current_player_foot")
	return go_to_room(room_path, "", foot, false)


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
