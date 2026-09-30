extends Control

const MAIN_MENU := "res://ui/menus/main_menu.tscn"
const WALK_BOUNDS := Rect2(26.0, 236.0, 588.0, 154.0)

@onready var player: Control = %DemoPlayer
@onready var hotspots: Control = %Hotspots
@onready var context_label: Label = %ContextLabel
@onready var status_label: Label = %StatusLabel

@onready var note_button: Button = %NoteButton
@onready var evidence_button: Button = %EvidenceButton
@onready var character_button: Button = %CharacterButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var exit_button: Button = %ExitButton

@onready var notebook_panel: PanelContainer = %NotebookPanel
@onready var evidence_tab_button: Button = %EvidenceTabButton
@onready var hypothesis_tab_button: Button = %HypothesisTabButton
@onready var notebook_close_button: Button = %NotebookCloseButton
@onready var filter_option: OptionButton = %FilterOption
@onready var evidence_panel: Control = %EvidencePanel
@onready var evidence_list: ItemList = %EvidenceList
@onready var evidence_title: Label = %EvidenceTitle
@onready var evidence_meta: Label = %EvidenceMeta
@onready var evidence_body: Label = %EvidenceBody
@onready var evidence_tags: Label = %EvidenceTags
@onready var hypothesis_panel: Control = %HypothesisPanel
@onready var hypothesis_list: ItemList = %HypothesisList
@onready var hypothesis_title: Label = %HypothesisTitle
@onready var hypothesis_status: Label = %HypothesisStatus
@onready var hypothesis_body: Label = %HypothesisBody
@onready var hypothesis_support: Label = %HypothesisSupport
@onready var hypothesis_test_button: Button = %HypothesisTestButton

@onready var character_panel: PanelContainer = %CharacterPanel
@onready var character_close_button: Button = %CharacterCloseButton

@onready var dialogue_panel: PanelContainer = %DialoguePanel
@onready var dialogue_close_button: Button = %DialogueCloseButton
@onready var dialogue_line: Label = %DialogueLine
@onready var dialogue_mode: Label = %DialogueMode
@onready var dialogue_trust: Label = %DialogueTrust
@onready var dialogue_choices: VBoxContainer = %DialogueChoices
@onready var present_button: Button = %PresentButton

var _pending_hotspot: Node
var _demo_clues: Dictionary = {
	"forecast_board": {
		"title": "Rain Forecast",
		"source": "Lobby notice board",
		"reliability": "Routine public notice",
		"tags": ["weather", "paper"],
		"detail": "The community center expected heavy rain at closing time. Plenty of umbrellas would have passed through the lobby."
	}
}
var _displayed_clue_ids: Array[String] = []
var _dialogue_actions: Array[Dictionary] = []
var _dialogue_evidence_mode := false
var _demo_trust := 0
var _hypothesis_recorded := false

var _has_demo_save := false
var _saved_foot := Vector2.ZERO
var _saved_clues: Dictionary = {}
var _saved_trust := 0


func _ready() -> void:
	player.call("place_at_foot", Vector2(318, 365))
	if player.has_signal("arrived"):
		player.connect("arrived", Callable(self, "_on_player_arrived"))

	_register_hotspots()

	note_button.pressed.connect(_open_notebook.bind("hypothesis"))
	evidence_button.pressed.connect(_open_notebook.bind("evidence"))
	character_button.pressed.connect(_open_character)
	save_button.pressed.connect(_demo_save)
	load_button.pressed.connect(_demo_load)
	exit_button.pressed.connect(_return_to_menu)

	evidence_tab_button.pressed.connect(_show_evidence_tab)
	hypothesis_tab_button.pressed.connect(_show_hypothesis_tab)
	notebook_close_button.pressed.connect(_close_all_modals)
	filter_option.item_selected.connect(_on_filter_changed)
	evidence_list.item_selected.connect(_on_evidence_selected)
	hypothesis_list.item_selected.connect(_on_hypothesis_selected)
	hypothesis_test_button.pressed.connect(_record_hypothesis)

	character_close_button.pressed.connect(_close_all_modals)
	dialogue_close_button.pressed.connect(_close_all_modals)
	present_button.pressed.connect(_toggle_dialogue_evidence)

	_setup_filters()
	_refresh_notebook()
	_refresh_hypotheses()
	_set_status("UI sandbox ready. Click to walk; hover objects; right-click to inspect.")


func _gui_input(event: InputEvent) -> void:
	if _modal_open():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_pending_hotspot = null
		player.call("move_to", get_local_mouse_position(), WALK_BOUNDS)
		_set_status("Walking.")
		accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if dialogue_panel.visible:
			if key_event.keycode == KEY_ESCAPE:
				_close_all_modals()
				get_viewport().set_input_as_handled()
				return
			var choice_index := _number_key_index(key_event.keycode)
			if choice_index >= 0 and choice_index < _dialogue_actions.size():
				_activate_dialogue_action(choice_index)
				get_viewport().set_input_as_handled()
				return

	if event.is_action_pressed("menu_back"):
		if _modal_open():
			_close_all_modals()
		else:
			_return_to_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("notebook"):
		_open_notebook("hypothesis")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("evidence"):
		_open_notebook("evidence")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("character"):
		_open_character()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("reveal_hotspots"):
		_set_reveal(true)
		get_viewport().set_input_as_handled()
	elif event.is_action_released("reveal_hotspots"):
		_set_reveal(false)
		get_viewport().set_input_as_handled()


func _register_hotspots() -> void:
	for hotspot in hotspots.get_children():
		if hotspot.has_signal("hover_changed"):
			hotspot.connect("hover_changed", Callable(self, "_on_hotspot_hover"))
		if hotspot.has_signal("action_requested"):
			hotspot.connect("action_requested", Callable(self, "_on_hotspot_action"))


func _on_hotspot_hover(label: String) -> void:
	context_label.text = "UI DEMO // COMMUNITY CENTER" if label.is_empty() else label.to_upper()


func _on_hotspot_action(hotspot: Node, action: StringName) -> void:
	if action == &"inspect":
		_set_status(String(hotspot.get("inspect_text")))
		return

	var approach: Vector2 = hotspot.get("approach_point")
	if approach.x >= 0.0 and approach.y >= 0.0:
		_pending_hotspot = hotspot
		if bool(player.call("move_to", approach, WALK_BOUNDS)):
			_set_status("Approaching %s." % String(hotspot.get("display_name")))
			return
	_pending_hotspot = null
	_activate_hotspot(hotspot)


func _on_player_arrived() -> void:
	if is_instance_valid(_pending_hotspot):
		var hotspot := _pending_hotspot
		_pending_hotspot = null
		_activate_hotspot(hotspot)


func _activate_hotspot(hotspot: Node) -> void:
	match String(hotspot.get("hotspot_id")):
		"umbrella_rack":
			_add_clue("dry_outline", {
				"title": "Dry Outline on the Rack",
				"source": "Umbrella rack",
				"reliability": "Direct observation",
				"tags": ["physical", "lobby"],
				"detail": "One hook is dry while the rack around it is wet. Something hung there until recently."
			})
			_set_status("Evidence recorded: Dry Outline on the Rack.")
		"claim_board":
			_add_clue("ticket_47b", {
				"title": "Claim Ticket 47B",
				"source": "Lost-and-found board",
				"reliability": "Paper record",
				"tags": ["paper", "lost_and_found"],
				"detail": "Ticket 47B lists a blue umbrella, logged twenty minutes before closing."
			})
			_set_status("Evidence recorded: Claim Ticket 47B.")
		"front_desk":
			_open_dialogue()
		"vending_machine":
			_set_status("The vending machine offers six kinds of soda and no investigative insight.")
		"exit_door":
			_set_status("This is only a UI sandbox. Use EXIT in the bottom bar to return to the title screen.")
		_:
			_set_status(String(hotspot.get("primary_text")))


func _add_clue(clue_id: String, clue: Dictionary) -> void:
	if not _demo_clues.has(clue_id):
		_demo_clues[clue_id] = clue.duplicate(true)
	_refresh_notebook()
	_refresh_hypotheses()


func _setup_filters() -> void:
	filter_option.clear()
	for label in ["ALL", "PHYSICAL", "PAPER", "WEATHER", "LOST & FOUND"]:
		filter_option.add_item(label)
	filter_option.select(0)


func _open_notebook(mode: String) -> void:
	_close_all_modals()
	notebook_panel.visible = true
	if mode == "hypothesis":
		_show_hypothesis_tab()
	else:
		_show_evidence_tab()
	context_label.text = "UI DEMO // NOTEBOOK"


func _show_evidence_tab() -> void:
	evidence_panel.visible = true
	hypothesis_panel.visible = false
	evidence_tab_button.disabled = true
	hypothesis_tab_button.disabled = false
	_refresh_notebook()


func _show_hypothesis_tab() -> void:
	evidence_panel.visible = false
	hypothesis_panel.visible = true
	evidence_tab_button.disabled = false
	hypothesis_tab_button.disabled = true
	_refresh_hypotheses()


func _refresh_notebook() -> void:
	if evidence_list == null:
		return
	evidence_list.clear()
	_displayed_clue_ids.clear()
	var filter := _selected_filter()

	for clue_id in _demo_clues.keys():
		var clue: Dictionary = _demo_clues[clue_id]
		if not filter.is_empty() and not (clue.get("tags", []) as Array).has(filter):
			continue
		_displayed_clue_ids.append(String(clue_id))
		evidence_list.add_item(String(clue.get("title", clue_id)))

	if evidence_list.item_count > 0:
		evidence_list.select(0)
		_show_clue(_displayed_clue_ids[0])
	else:
		evidence_title.text = "NO MATCHING EVIDENCE"
		evidence_meta.text = ""
		evidence_body.text = "Try another filter or interact with the demo room."
		evidence_tags.text = ""


func _show_clue(clue_id: String) -> void:
	if not _demo_clues.has(clue_id):
		return
	var clue: Dictionary = _demo_clues[clue_id]
	evidence_title.text = String(clue.get("title", clue_id))
	evidence_meta.text = "SOURCE: %s\nRELIABILITY: %s" % [
		String(clue.get("source", "Unknown")),
		String(clue.get("reliability", "Unknown"))
	]
	evidence_body.text = String(clue.get("detail", ""))
	evidence_tags.text = "TAGS: %s" % _join_values(clue.get("tags", []))


func _selected_filter() -> String:
	match filter_option.selected:
		1:
			return "physical"
		2:
			return "paper"
		3:
			return "weather"
		4:
			return "lost_and_found"
	return ""


func _on_filter_changed(_index: int) -> void:
	_refresh_notebook()


func _on_evidence_selected(index: int) -> void:
	if index >= 0 and index < _displayed_clue_ids.size():
		_show_clue(_displayed_clue_ids[index])


func _refresh_hypotheses() -> void:
	hypothesis_list.clear()
	var support := 0
	if _demo_clues.has("dry_outline"):
		support += 1
	if _demo_clues.has("ticket_47b"):
		support += 1
	var status := "SUPPORTED" if support >= 2 else "UNSUPPORTED"
	var prefix := "* " if _hypothesis_recorded else ""
	hypothesis_list.add_item("%sThe umbrella reached lost & found [%s]" % [prefix, status])
	hypothesis_list.add_item("The vending machine stole it [REFUTED]")
	hypothesis_list.select(0)
	_show_hypothesis(0)


func _show_hypothesis(index: int) -> void:
	if index == 0:
		var support := 0
		var support_lines := PackedStringArray()
		if _demo_clues.has("dry_outline"):
			support += 1
			support_lines.append("+ Dry Outline on the Rack")
		if _demo_clues.has("ticket_47b"):
			support += 1
			support_lines.append("+ Claim Ticket 47B")
		var supported := support >= 2
		hypothesis_title.text = "The umbrella reached lost & found."
		hypothesis_status.text = "STATUS: %s%s" % [
			"SUPPORTED" if supported else "UNSUPPORTED",
			" // RECORDED" if _hypothesis_recorded else ""
		]
		hypothesis_body.text = "A deliberately ordinary demo hypothesis used to test notebook hierarchy, selection, and button states."
		hypothesis_support.text = "VISIBLE SUPPORT: %d/2\n%s" % [
			support,
			"\n".join(support_lines) if not support_lines.is_empty() else "No supporting evidence collected yet."
		]
		hypothesis_test_button.disabled = false
		hypothesis_test_button.text = "RECORD HYPOTHESIS" if not _hypothesis_recorded else "RECORDED"
	else:
		hypothesis_title.text = "The vending machine stole it."
		hypothesis_status.text = "STATUS: REFUTED"
		hypothesis_body.text = "Included only to test how an obviously refuted conclusion reads in the UI."
		hypothesis_support.text = "- The machine has no arms.\n- It has remained bolted to the floor."
		hypothesis_test_button.disabled = false
		hypothesis_test_button.text = "RECORD BAD HYPOTHESIS"


func _on_hypothesis_selected(index: int) -> void:
	_show_hypothesis(index)


func _record_hypothesis() -> void:
	if hypothesis_list.get_selected_items().is_empty():
		return
	var index := int(hypothesis_list.get_selected_items()[0])
	if index == 0:
		_hypothesis_recorded = true
		_set_status("Demo hypothesis recorded.")
	else:
		_set_status("Bad hypotheses can remain visible without blocking progress.")
	_refresh_hypotheses()


func _open_character() -> void:
	_close_all_modals()
	character_panel.visible = true
	context_label.text = "UI DEMO // CHARACTER"


func _open_dialogue() -> void:
	_close_all_modals()
	dialogue_panel.visible = true
	_dialogue_evidence_mode = false
	dialogue_line.text = "Alex looks up from the front desk. “Lost something?”"
	dialogue_mode.text = "TOPICS / RESPONSES"
	present_button.text = "PRESENT EVIDENCE"
	_refresh_dialogue_choices()
	context_label.text = "UI DEMO // CONVERSATION"


func _refresh_dialogue_choices() -> void:
	_clear_dialogue_actions()
	_add_dialogue_action("Ask about the blue umbrella.", {"type": "topic", "id": "umbrella"})
	_add_dialogue_action("Ask who worked the closing shift.", {"type": "topic", "id": "shift"})
	_add_dialogue_action("End conversation.", {"type": "close"})


func _toggle_dialogue_evidence() -> void:
	_dialogue_evidence_mode = not _dialogue_evidence_mode
	_clear_dialogue_actions()
	if _dialogue_evidence_mode:
		dialogue_mode.text = "PRESENT EVIDENCE"
		present_button.text = "BACK TO TOPICS"
		for clue_id in _demo_clues.keys():
			var clue: Dictionary = _demo_clues[clue_id]
			_add_dialogue_action(String(clue.get("title", clue_id)), {"type": "evidence", "id": String(clue_id)})
		if _dialogue_actions.is_empty():
			dialogue_mode.text = "NO EVIDENCE AVAILABLE"
	else:
		dialogue_mode.text = "TOPICS / RESPONSES"
		present_button.text = "PRESENT EVIDENCE"
		_refresh_dialogue_choices()


func _add_dialogue_action(label: String, action: Dictionary) -> void:
	if _dialogue_actions.size() >= 9:
		return
	var index := _dialogue_actions.size()
	_dialogue_actions.append(action)
	var button := Button.new()
	button.text = "%d. %s" % [index + 1, label]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(_activate_dialogue_action.bind(index))
	dialogue_choices.add_child(button)
	if index == 0:
		button.grab_focus()


func _clear_dialogue_actions() -> void:
	_dialogue_actions.clear()
	for child in dialogue_choices.get_children():
		child.queue_free()


func _activate_dialogue_action(index: int) -> void:
	if index < 0 or index >= _dialogue_actions.size():
		return
	var action := _dialogue_actions[index]
	match String(action.get("type", "")):
		"close":
			_close_all_modals()
		"topic":
			if String(action.get("id", "")) == "umbrella":
				_demo_trust = mini(_demo_trust + 1, 3)
				dialogue_line.text = "“Blue umbrella? I saw one near the rack before the floor crew came through.”"
			else:
				dialogue_line.text = "“Mina closed. She logs anything left behind on the paper board.”"
			dialogue_trust.text = "TRUST %d" % _demo_trust
		"evidence":
			var clue_id := String(action.get("id", ""))
			if clue_id == "ticket_47b":
				dialogue_line.text = "Alex taps the ticket. “There it is. Cabinet B. That is exactly what the board is for.”"
				_demo_trust = mini(_demo_trust + 1, 3)
			elif clue_id == "dry_outline":
				dialogue_line.text = "“That dry hook means it was moved after the rain started. Check the claim board.”"
			else:
				dialogue_line.text = "“Rainy day. Useful context, but it does not tell us whose umbrella it was.”"
			dialogue_trust.text = "TRUST %d" % _demo_trust


func _demo_save() -> void:
	_saved_foot = player.call("get_foot_position")
	_saved_clues = _demo_clues.duplicate(true)
	_saved_trust = _demo_trust
	_has_demo_save = true
	_set_status("DEMO SAVE // position, evidence, and trust snapshot stored in memory.")


func _demo_load() -> void:
	if not _has_demo_save:
		_set_status("DEMO LOAD // no snapshot yet. Press SAVE first.")
		return
	_demo_clues = _saved_clues.duplicate(true)
	_demo_trust = _saved_trust
	player.call("place_at_foot", _saved_foot)
	dialogue_trust.text = "TRUST %d" % _demo_trust
	_refresh_notebook()
	_refresh_hypotheses()
	_set_status("DEMO LOAD // snapshot restored.")


func _set_reveal(value: bool) -> void:
	for hotspot in hotspots.get_children():
		if hotspot.has_method("set_reveal"):
			hotspot.call("set_reveal", value)
	context_label.text = "INTERACTABLES" if value else "UI DEMO // COMMUNITY CENTER"


func _close_all_modals() -> void:
	notebook_panel.visible = false
	character_panel.visible = false
	dialogue_panel.visible = false
	context_label.text = "UI DEMO // COMMUNITY CENTER"


func _modal_open() -> bool:
	return notebook_panel.visible or character_panel.visible or dialogue_panel.visible


func _return_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)


func _set_status(message: String) -> void:
	status_label.text = message


func _join_values(values: Array) -> String:
	var parts := PackedStringArray()
	for value in values:
		parts.append(String(value))
	return ", ".join(parts)


func _number_key_index(keycode: Key) -> int:
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
