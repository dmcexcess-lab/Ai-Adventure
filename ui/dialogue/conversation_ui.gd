extends PanelContainer

signal closed

@onready var witness_label: Label = %WitnessLabel
@onready var role_label: Label = %RoleLabel
@onready var trust_label: Label = %TrustLabel
@onready var line_label: Label = %LineLabel
@onready var mode_label: Label = %ModeLabel
@onready var choice_list: VBoxContainer = %ChoiceList
@onready var present_button: Button = %PresentButton
@onready var close_button: Button = %CloseButton

var _dialogue_service: Node
var _witness_id := ""
var _node_id := ""
var _evidence_mode := false
var _actions: Array = []


func _ready() -> void:
	_dialogue_service = get_node_or_null("/root/DialogueService")
	present_button.pressed.connect(_toggle_evidence_mode)
	close_button.pressed.connect(close_conversation)
	visible = false


func open_conversation(witness_id: String) -> bool:
	if _dialogue_service == null:
		return false
	var view: Dictionary = _dialogue_service.call("start_conversation", witness_id)
	if view.is_empty():
		return false
	_witness_id = witness_id
	_evidence_mode = false
	visible = true
	_render_view(view)
	return true


func close_conversation() -> void:
	if not visible:
		return
	visible = false
	_witness_id = ""
	_node_id = ""
	_actions.clear()
	_evidence_mode = false
	closed.emit()


func is_open() -> bool:
	return visible


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			close_conversation()
			get_viewport().set_input_as_handled()
			return
		var index := _choice_index_for_key(key_event.keycode)
		if index >= 0 and index < _actions.size():
			_activate_action(index)
			get_viewport().set_input_as_handled()


func _render_view(view: Dictionary) -> void:
	_node_id = String(view.get("node_id", ""))
	witness_label.text = String(view.get("witness_name", _witness_id)).to_upper()
	role_label.text = String(view.get("witness_role", ""))
	trust_label.text = "TRUST %d" % int(view.get("trust", 0))
	line_label.text = String(view.get("line", ""))
	_evidence_mode = false
	mode_label.text = "TOPICS / RESPONSES"
	present_button.text = "PRESENT EVIDENCE"
	_render_choices(view.get("choices", []))


func _render_choices(raw_choices: Array) -> void:
	_clear_actions()
	for choice_value in raw_choices:
		if not choice_value is Dictionary:
			continue
		var choice: Dictionary = choice_value
		_add_action(
			String(choice.get("text", "Continue")),
			{"type": "choice", "id": String(choice.get("id", ""))}
		)
	if _actions.is_empty():
		_add_action("End conversation.", {"type": "close"})


func _toggle_evidence_mode() -> void:
	if _dialogue_service == null or _witness_id.is_empty():
		return
	if _evidence_mode:
		var view: Dictionary = _dialogue_service.call("get_node_view", _witness_id, _node_id)
		if not view.is_empty():
			_render_view(view)
		return

	_evidence_mode = true
	mode_label.text = "PRESENT RELEVANT EVIDENCE"
	present_button.text = "BACK TO TOPICS"
	_clear_actions()

	var evidence: Array = _dialogue_service.call("get_relevant_evidence", _witness_id)
	for clue_value in evidence:
		if not clue_value is Dictionary:
			continue
		var clue: Dictionary = clue_value
		_add_action(
			String(clue.get("title", "Evidence")),
			{"type": "evidence", "id": String(clue.get("id", ""))}
		)

	if _actions.is_empty():
		mode_label.text = "NO RELEVANT DISCOVERED EVIDENCE"


func _add_action(label: String, action: Dictionary) -> void:
	if _actions.size() >= 9:
		return
	var index := _actions.size()
	_actions.append(action)
	var button := Button.new()
	button.text = "%d. %s" % [index + 1, label]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(_activate_action.bind(index))
	choice_list.add_child(button)
	if index == 0:
		button.grab_focus()


func _clear_actions() -> void:
	_actions.clear()
	for child in choice_list.get_children():
		child.queue_free()


func _activate_action(index: int) -> void:
	if index < 0 or index >= _actions.size():
		return
	var action: Dictionary = _actions[index]
	match String(action.get("type", "")):
		"close":
			close_conversation()
		"choice":
			var result: Dictionary = _dialogue_service.call(
				"choose",
				_witness_id,
				_node_id,
				String(action.get("id", ""))
			)
			if bool(result.get("end", false)):
				close_conversation()
			elif bool(result.get("ok", false)):
				_render_view(result)
		"evidence":
			var result: Dictionary = _dialogue_service.call(
				"present_evidence",
				_witness_id,
				String(action.get("id", ""))
			)
			if bool(result.get("ok", false)):
				_render_view(result)


func _choice_index_for_key(keycode: Key) -> int:
	match keycode:
		KEY_1, KEY_KP_1:
			return 0
		KEY_2, KEY_KP_2:
			return 1
		KEY_3, KEY_KP_3:
			return 2
		KEY_4, KEY_KP_4:
			return 3
		KEY_5, KEY_KP_5:
			return 4
		KEY_6, KEY_KP_6:
			return 5
		KEY_7, KEY_KP_7:
			return 6
		KEY_8, KEY_KP_8:
			return 7
		KEY_9, KEY_KP_9:
			return 8
	return -1
