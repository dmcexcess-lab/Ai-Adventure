extends Control

const MAIN_MENU := "res://ui/menus/main_menu.tscn"
const FIRST_ROOM := "res://rooms/demo/lobby.tscn"
const CASE_CATALOG := preload("res://content/demo/umbrella_case.gd")
const ALEX_PORTRAIT := preload("res://art/demo/alex_portrait_noir.svg")
const MINA_PORTRAIT := preload("res://art/demo/mina_portrait_noir.svg")

@onready var room_host: Control = %RoomHost
@onready var room_title_label: Label = %RoomTitle
@onready var room_subtitle_label: Label = %RoomSubtitle
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
@onready var character_profile: Label = %CharacterProfile
@onready var character_sentence: Label = %CharacterSentence
@onready var character_skills: Label = %CharacterSkills
@onready var character_descriptions: Label = %CharacterDescriptions
@onready var character_failures: Label = %CharacterFailures

@onready var background_overlay: Control = %BackgroundOverlay
@onready var background_choices: VBoxContainer = %BackgroundChoices

@onready var dialogue_panel: PanelContainer = %DialoguePanel
@onready var dialogue_close_button: Button = %DialogueCloseButton
@onready var dialogue_line: Label = %DialogueLine
@onready var dialogue_mode: Label = %DialogueMode
@onready var dialogue_trust: Label = %DialogueTrust
@onready var dialogue_choices: VBoxContainer = %DialogueChoices
@onready var present_button: Button = %PresentButton
@onready var dialogue_name: Label = %DialogueName
@onready var dialogue_role: Label = %DialogueRole
@onready var dialogue_portrait: TextureRect = %DialoguePortrait

@onready var resolution_panel: PanelContainer = %ResolutionPanel
@onready var resolution_text: Label = %ResolutionText
@onready var resolution_close_button: Button = %ResolutionCloseButton

var _current_room: Control
var _current_room_path := ""

var _clue_definitions: Dictionary = {}
var _deduction_definitions: Dictionary = {}
var _witness_definitions: Dictionary = {}
var _demo_clues: Dictionary = {}
var _demo_deductions: Dictionary = {}
var _selected_hypotheses: Array[String] = []
var _displayed_clue_ids: Array[String] = []
var _displayed_deduction_ids: Array[String] = []
var _dialogue_actions: Array[Dictionary] = []
var _dialogue_evidence_mode := false
var _active_witness_id := "alex"
var _demo_trust: Dictionary = {"alex": 0, "mina": 0}
var _case_resolved := false
var _demo_background_id := ""
var _demo_skill_values: Dictionary = {}
var _demo_failed_approaches: Dictionary = {}
var _demo_skill_checks: Dictionary = {}

var _has_demo_save := false
var _saved_room_path := ""
var _saved_foot := Vector2.ZERO
var _saved_clues: Dictionary = {}
var _saved_trust: Dictionary = {}
var _saved_deductions: Dictionary = {}
var _saved_hypotheses: Array[String] = []
var _saved_case_resolved := false
var _saved_background_id := ""
var _saved_skill_values: Dictionary = {}
var _saved_failed_approaches: Dictionary = {}
var _saved_skill_checks: Dictionary = {}


func _ready() -> void:
	_load_case_catalog()
	_reset_demo_case()

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
	resolution_close_button.pressed.connect(_close_all_modals)

	_build_demo_background_choices()
	_setup_filters()
	_refresh_notebook()
	_refresh_hypotheses()
	_refresh_character_panel()
	_load_demo_room(FIRST_ROOM)
	_open_demo_background_choice()
	_set_status("Choose how you approach problems. The profile is fixed for this Umbrella Quest run.")


func _build_demo_background_choices() -> void:
	for child in background_choices.get_children():
		child.queue_free()

	var skills := get_node_or_null("/root/SkillService")
	if skills == null:
		return

	for profile_value in skills.call("get_backgrounds"):
		if not profile_value is Dictionary:
			continue
		var profile: Dictionary = profile_value
		var button := Button.new()
		button.text = "“%s”\n%s" % [
			String(profile.get("sentence", "")),
			_profile_summary(profile.get("skills", {}))
		]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(0, 54)
		button.pressed.connect(_choose_demo_background.bind(String(profile.get("id", ""))))
		background_choices.add_child(button)


func _profile_summary(raw_skills: Variant) -> String:
	if not raw_skills is Dictionary:
		return ""
	var values: Dictionary = raw_skills
	return "OBS %d  REA %d  EMP %d  RES %d" % [
		int(values.get("observation", 0)),
		int(values.get("reasoning", 0)),
		int(values.get("empathy", 0)),
		int(values.get("resolve", 0))
	]


func _open_demo_background_choice() -> void:
	notebook_panel.visible = false
	character_panel.visible = false
	dialogue_panel.visible = false
	resolution_panel.visible = false
	background_overlay.visible = true
	context_label.text = "UMBRELLA QUEST // APPROACH"


func _choose_demo_background(background_id: String) -> bool:
	var skills := get_node_or_null("/root/SkillService")
	if skills == null:
		return false
	var profile: Dictionary = skills.call("get_background", background_id)
	if profile.is_empty():
		return false

	_demo_background_id = background_id
	_demo_skill_values = (profile.get("skills", {}) as Dictionary).duplicate(true)
	_demo_failed_approaches.clear()
	_demo_skill_checks.clear()
	background_overlay.visible = false
	_refresh_character_panel()
	_set_status("%s selected // %s" % [
		String(profile.get("title", background_id)),
		_case_objective()
	])
	context_label.text = _room_context()
	return true


func _perform_demo_check(
	check_id: String,
	skill_id: String,
	threshold: int,
	modifier: int = 0,
	context: String = "",
	fallback_hint: String = ""
) -> Dictionary:
	var skills := get_node_or_null("/root/SkillService")
	if skills == null or _demo_background_id.is_empty():
		return {"ok": false, "passed": false, "error": "demo_profile_unavailable"}

	var result: Dictionary = skills.call("evaluate_values", _demo_skill_values, skill_id, threshold, modifier)
	result["check_id"] = check_id
	result["context"] = context
	result["fallback_hint"] = fallback_hint
	_demo_skill_checks[check_id] = result.duplicate(true)
	if not bool(result.get("passed", false)):
		_record_demo_failed_approach(check_id, result)
	_refresh_character_panel()
	return result


func _record_demo_failed_approach(check_id: String, result: Dictionary) -> void:
	var prior: Dictionary = {}
	if _demo_failed_approaches.get(check_id, {}) is Dictionary:
		prior = (_demo_failed_approaches.get(check_id, {}) as Dictionary).duplicate(true)
	_demo_failed_approaches[check_id] = {
		"check_id": check_id,
		"skill": String(result.get("skill", "")),
		"threshold": int(result.get("threshold", 0)),
		"last_total": int(result.get("total", 0)),
		"last_modifier": int(result.get("modifier", 0)),
		"context": String(result.get("context", "")),
		"fallback_hint": String(result.get("fallback_hint", "")),
		"attempts": int(prior.get("attempts", 0)) + 1
	}


func _demo_check_was_attempted(check_id: String) -> bool:
	return _demo_skill_checks.has(check_id)


func _demo_check_passed(check_id: String) -> bool:
	if not _demo_skill_checks.has(check_id):
		return false
	var result: Dictionary = _demo_skill_checks[check_id]
	return bool(result.get("passed", false))


func _format_demo_check(result: Dictionary) -> String:
	var skill_id := String(result.get("skill", "skill"))
	var label := skill_id.to_upper()
	var base := int(result.get("base", 0))
	var modifier := int(result.get("modifier", 0))
	var total := int(result.get("total", base + modifier))
	var threshold := int(result.get("threshold", 0))
	var modifier_text := "+%d" % modifier if modifier >= 0 else str(modifier)
	return "%s %d %s = %d / %d // %s" % [
		label,
		base,
		modifier_text,
		total,
		threshold,
		"PASS" if bool(result.get("passed", false)) else "FAIL"
	]


func _refresh_character_panel() -> void:
	var skills := get_node_or_null("/root/SkillService")
	if skills == null or _demo_background_id.is_empty():
		character_profile.text = "NO PROFILE SELECTED"
		character_sentence.text = "Choose one approach before beginning the case."
		character_skills.text = "OBSERVATION  -\nREASONING    -\nEMPATHY      -\nRESOLVE      -"
		character_descriptions.text = "The four skills expose alternate investigative routes. Checks are deterministic; there are no hidden dice."
		character_failures.text = "FAILED APPROACHES\nNone yet."
		return

	var profile: Dictionary = skills.call("get_background", _demo_background_id)
	character_profile.text = String(profile.get("title", _demo_background_id)).to_upper()
	character_sentence.text = "“%s”" % String(profile.get("sentence", ""))
	character_skills.text = "OBSERVATION  %d\nREASONING    %d\nEMPATHY      %d\nRESOLVE      %d" % [
		int(_demo_skill_values.get("observation", 0)),
		int(_demo_skill_values.get("reasoning", 0)),
		int(_demo_skill_values.get("empathy", 0)),
		int(_demo_skill_values.get("resolve", 0))
	]

	var definitions: Dictionary = skills.call("get_skill_definitions")
	var description_lines := PackedStringArray()
	for skill_id in ["observation", "reasoning", "empathy", "resolve"]:
		var definition: Dictionary = definitions.get(skill_id, {})
		description_lines.append("%s — %s" % [
			String(definition.get("name", skill_id.capitalize())),
			String(definition.get("description", ""))
		])
	character_descriptions.text = "\n\n".join(description_lines)

	var failure_lines := PackedStringArray(["FAILED APPROACHES"])
	var failed_ids: Array = _demo_failed_approaches.keys()
	failed_ids.sort()
	if failed_ids.is_empty():
		failure_lines.append("None yet.")
	else:
		for check_id_value in failed_ids:
			var failed: Dictionary = _demo_failed_approaches[String(check_id_value)]
			var skill_label := String(failed.get("skill", "skill")).to_upper()
			var modifier := int(failed.get("last_modifier", 0))
			var modifier_text := "+%d" % modifier if modifier >= 0 else str(modifier)
			var math := "%s %d %s / %d" % [
				skill_label,
				int(failed.get("last_total", 0)) - modifier,
				modifier_text,
				int(failed.get("threshold", 0))
			]
			failure_lines.append("• %s — %s" % [math, String(failed.get("context", "Approach failed"))])
			var fallback := String(failed.get("fallback_hint", ""))
			if not fallback.is_empty():
				failure_lines.append("  FALLBACK: %s" % fallback)
	character_failures.text = "\n".join(failure_lines)


func _unhandled_input(event: InputEvent) -> void:
	if background_overlay.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			var background_key := event as InputEventKey
			var background_index := _number_key_index(background_key.keycode)
			if background_index >= 0 and background_index < background_choices.get_child_count():
				var button := background_choices.get_child(background_index) as Button
				if button != null:
					button.pressed.emit()
		get_viewport().set_input_as_handled()
		return

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

func _load_demo_room(room_path: String, spawn_marker: String = "", restore_foot := Vector2(-10000.0, -10000.0)) -> void:
	var packed := load(room_path) as PackedScene
	if packed == null:
		_set_status("DEMO WORLD ERROR // room failed to load.")
		return

	if is_instance_valid(_current_room):
		room_host.remove_child(_current_room)
		_current_room.queue_free()

	_current_room = packed.instantiate() as Control
	if _current_room == null:
		_set_status("DEMO WORLD ERROR // room failed to instantiate.")
		return

	room_host.add_child(_current_room)
	_current_room_path = room_path

	if _current_room.has_signal("status_requested"):
		_current_room.connect("status_requested", Callable(self, "_on_demo_room_status"))
	if _current_room.has_signal("hover_label_changed"):
		_current_room.connect("hover_label_changed", Callable(self, "_on_demo_room_hover"))
	if _current_room.has_signal("conversation_requested"):
		_current_room.connect("conversation_requested", Callable(self, "_on_demo_conversation"))
	if _current_room.has_signal("transition_requested"):
		_current_room.connect("transition_requested", Callable(self, "_on_demo_room_transition"))
	if _current_room.has_signal("hotspot_activated"):
		_current_room.connect("hotspot_activated", Callable(self, "_on_demo_hotspot_activated"))

	room_title_label.text = "UMBRELLA QUEST // %s" % String(_current_room.get("room_title"))
	room_subtitle_label.text = String(_current_room.get("room_subtitle"))
	if restore_foot.x > -9000.0:
		_current_room.call("restore_player_foot", restore_foot)
	else:
		_current_room.call("enter_at", spawn_marker)
	context_label.text = _room_context()
	_set_status("Entered %s. Click to walk; hover objects; right-click to inspect." % String(_current_room.get("room_title")).to_lower())


func _on_demo_room_status(message: String) -> void:
	_set_status(message)


func _on_demo_room_hover(label: String) -> void:
	context_label.text = _room_context() if label.is_empty() else label.to_upper()


func _on_demo_room_transition(room_path: String, spawn_marker: String) -> void:
	_load_demo_room(room_path, spawn_marker)


func _on_demo_conversation(witness_id: String) -> void:
	if _witness_definitions.has(witness_id):
		_open_dialogue(witness_id)
	else:
		_set_status("That witness is not part of this case.")

func _on_demo_hotspot_activated(hotspot: Node) -> void:
	if _demo_background_id.is_empty():
		_open_demo_background_choice()
		return

	var hotspot_id := String(hotspot.get("hotspot_id"))

	if hotspot_id == "umbrella_rack":
		_acquire_demo_clue("dry_outline", false)
		var observation := _perform_demo_check(
			"rack_residue_read",
			"observation",
			3,
			0,
			"Read the transfer residue on the wet umbrella rack",
			"Use the paper record or ask Alex to establish the first transfer."
		)
		if bool(observation.get("passed", false)):
			_acquire_demo_clue("watcher_transfer_residue", false)
			_set_status("[%s] Transfer residue recorded as evidence." % _format_demo_check(observation))
		else:
			_set_status("[%s] The residue is too ambiguous to trust. FALLBACK: paper record or Alex." % _format_demo_check(observation))
		_refresh_notebook()
		_refresh_hypotheses()
		return

	if hotspot_id == "fuse_panel":
		_acquire_demo_clue("fan_timer", false)
		var modifier := 1 if _demo_clues.has("closing_log") else 0
		var reasoning := _perform_demo_check(
			"service_timing_reconstruction",
			"reasoning",
			4,
			modifier,
			"Reconstruct the closing route from the rear fan timer",
			"Get the front-desk closing log for a timing anchor, or use Mina's transfer tag / statement."
		)
		if bool(reasoning.get("passed", false)):
			_acquire_demo_clue("analyst_service_timing", false)
			_set_status("[%s] Service timing reconstruction recorded." % _format_demo_check(reasoning))
		else:
			_set_status("[%s] The timer alone is underdetermined. FALLBACK: closing log, transfer tag, or Mina." % _format_demo_check(reasoning))
		_refresh_notebook()
		_refresh_hypotheses()
		return

	var clue_map := {
		"claim_board": "ticket_47b",
		"desk_log": "closing_log",
		"claim_cabinets": "cabinet_trace",
		"office_corkboard": "shift_board",
		"wet_property_handbook": "wet_property_policy",
		"storage_shelves": "transfer_tag",
	}
	if clue_map.has(hotspot_id):
		_acquire_demo_clue(String(clue_map[hotspot_id]))
		return

	if hotspot_id == "drying_rail":
		_acquire_demo_clue("rear_drying_rail")
		if _is_demo_deduction_established("drying_not_theft"):
			_resolve_demo_case()
		else:
			_set_status("The rear rail matters, but the case does not yet explain why 47B came here.")
		return

	_set_status(String(hotspot.get("primary_text")))

func _room_context() -> String:
	if is_instance_valid(_current_room):
		return "UMBRELLA QUEST // %s" % String(_current_room.get("room_title"))
	return "UMBRELLA QUEST // COMMUNITY CENTER"


func _load_case_catalog() -> void:
	var provider: Object = CASE_CATALOG.new()
	for clue_value in provider.call("get_clues"):
		if clue_value is Dictionary:
			var clue: Dictionary = (clue_value as Dictionary).duplicate(true)
			_clue_definitions[String(clue.get("id", ""))] = clue
	for deduction_value in provider.call("get_deductions"):
		if deduction_value is Dictionary:
			var deduction: Dictionary = (deduction_value as Dictionary).duplicate(true)
			_deduction_definitions[String(deduction.get("id", ""))] = deduction
	var witnesses_value: Variant = provider.call("get_witnesses")
	if witnesses_value is Dictionary:
		_witness_definitions = (witnesses_value as Dictionary).duplicate(true)


func _reset_demo_case() -> void:
	_demo_clues.clear()
	_demo_deductions.clear()
	_selected_hypotheses.clear()
	_demo_trust = {"alex": 0, "mina": 0}
	_demo_failed_approaches.clear()
	_demo_skill_checks.clear()
	_case_resolved = false
	_acquire_demo_clue("case_request", false)
	_acquire_demo_clue("forecast_board", false)
	_refresh_character_panel()

func _acquire_demo_clue(clue_id: String, announce: bool = true) -> bool:
	if not _clue_definitions.has(clue_id):
		if announce:
			_set_status("CASE ERROR // unknown evidence.")
		return false
	if _demo_clues.has(clue_id):
		if announce:
			var existing: Dictionary = _demo_clues[clue_id]
			_set_status("Already recorded: %s." % String(existing.get("title", clue_id)))
		return false

	var clue: Dictionary = (_clue_definitions[clue_id] as Dictionary).duplicate(true)
	_demo_clues[clue_id] = clue
	_refresh_notebook()
	_refresh_hypotheses()
	if announce:
		_set_status("Evidence recorded: %s." % String(clue.get("title", clue_id)))
	return true


func _evaluate_demo_deduction(deduction_id: String) -> Dictionary:
	if not _deduction_definitions.has(deduction_id):
		return {}

	var result: Dictionary = (_deduction_definitions[deduction_id] as Dictionary).duplicate(true)
	var support_ids: Array[String] = []
	for clue_id_value in result.get("required_clue_ids", []):
		var clue_id := String(clue_id_value)
		if _demo_clues.has(clue_id):
			support_ids.append(clue_id)

	var contradicting_ids: Array[String] = []
	var refute_tags: Array = result.get("refute_evidence_tags", [])
	var refute_contradictions: Array = result.get("refute_contradiction_tags", [])
	for clue_id_value in _demo_clues.keys():
		var clue_id := String(clue_id_value)
		var clue: Dictionary = _demo_clues[clue_id]
		if _arrays_intersect(clue.get("tags", []), refute_tags) or _arrays_intersect(clue.get("contradiction_tags", []), refute_contradictions):
			contradicting_ids.append(clue_id)

	var prerequisites_met := true
	for prerequisite_value in result.get("prerequisite_deductions", []):
		if not _is_demo_deduction_established(String(prerequisite_value)):
			prerequisites_met = false
			break

	var status := "unsupported"
	if not contradicting_ids.is_empty():
		status = "refuted"
	elif _is_demo_deduction_established(deduction_id):
		status = "established"
	elif prerequisites_met and support_ids.size() >= int(result.get("minimum_support", 1)):
		status = "supported"

	result["status"] = status
	result["supporting_evidence_ids"] = support_ids
	result["contradicting_evidence_ids"] = contradicting_ids
	result["support_count"] = support_ids.size()
	result["selected"] = _selected_hypotheses.has(deduction_id)
	result["established"] = _is_demo_deduction_established(deduction_id)
	result["prerequisites_met"] = prerequisites_met
	return result


func _select_demo_hypothesis(deduction_id: String) -> Dictionary:
	if not _deduction_definitions.has(deduction_id):
		return {}
	if not _selected_hypotheses.has(deduction_id):
		_selected_hypotheses.append(deduction_id)

	var evaluation := _evaluate_demo_deduction(deduction_id)
	if String(evaluation.get("status", "")) == "supported":
		_demo_deductions[deduction_id] = {"state": "established"}
		evaluation = _evaluate_demo_deduction(deduction_id)
		_set_status("Deduction established: %s" % String(evaluation.get("title", deduction_id)))
	else:
		_set_status("Hypothesis recorded: %s" % String(evaluation.get("status", "unsupported")).to_upper())
	_refresh_hypotheses()
	return evaluation


func _is_demo_deduction_established(deduction_id: String) -> bool:
	if not _demo_deductions.has(deduction_id):
		return false
	var saved: Dictionary = _demo_deductions[deduction_id]
	return String(saved.get("state", "")) == "established"


func _visible_demo_deduction_ids() -> Array[String]:
	var ids: Array[String] = []
	for deduction_id_value in _deduction_definitions.keys():
		var deduction_id := String(deduction_id_value)
		var definition: Dictionary = _deduction_definitions[deduction_id]
		var prerequisites: Array = definition.get("prerequisite_deductions", [])
		if prerequisites.is_empty():
			ids.append(deduction_id)
			continue
		var show := true
		for prerequisite_value in prerequisites:
			if not _is_demo_deduction_established(String(prerequisite_value)):
				show = false
				break
		if show:
			ids.append(deduction_id)
	return ids


func _case_objective() -> String:
	if _case_resolved:
		return "CASE CLOSED // Nora's umbrella recovered from the rear drying rail."
	if _is_demo_deduction_established("drying_not_theft"):
		return "Final step: return to the loading bay and inspect the rear drying rail."
	if _is_demo_deduction_established("mina_service_route"):
		return "Determine why Mina moved 47B and where the service route ended."
	if _is_demo_deduction_established("cabinet_was_intermediate"):
		return "Identify who made the second transfer out of Cabinet B."
	if _is_demo_deduction_established("lobby_to_lost_found"):
		return "Cabinet B should contain 47B. Find out why it does not."
	if _is_demo_deduction_established("identity_47b"):
		return "Trace Nora's umbrella after it left the lobby rack."
	return "Find the paper record that matches Nora's navy umbrella with the yellow-taped handle."


func _resolve_demo_case() -> void:
	if _case_resolved:
		_set_status(_case_objective())
		return
	_acquire_demo_clue("umbrella_recovered", false)
	_case_resolved = true
	_refresh_notebook()
	resolution_text.text = "CASE CLOSED\n\nBehind the folded safety curtain hangs Nora Vale's navy umbrella: yellow-taped handle, brass duck-head cap, still damp but intact.\n\nAlex made the routine first transfer to Lost & Found. Mina made the undocumented second transfer to the rear drying rail so the soaking umbrella would not damage claim files and donation cartons.\n\nNothing supernatural. Nothing stolen. Just a broken handoff reconstructed from evidence."
	_close_all_modals()
	resolution_panel.visible = true
	context_label.text = "UMBRELLA QUEST // CASE CLOSED"
	_set_status("Case resolved: 47B recovered from the rear drying rail.")


func _arrays_intersect(left_value: Variant, right_value: Variant) -> bool:
	if not left_value is Array or not right_value is Array:
		return false
	var left: Array = left_value
	var right: Array = right_value
	for value in left:
		if right.has(value):
			return true
	return false

func _setup_filters() -> void:
	filter_option.clear()
	for label in ["ALL", "PHYSICAL", "PAPER", "WITNESS", "LOST & FOUND", "DRYING"]:
		filter_option.add_item(label)
	filter_option.select(0)

func _open_notebook(mode: String) -> void:
	if _demo_background_id.is_empty():
		_open_demo_background_choice()
		return
	_close_all_modals()
	notebook_panel.visible = true
	if mode == "hypothesis":
		_show_hypothesis_tab()
	else:
		_show_evidence_tab()
	context_label.text = "UMBRELLA QUEST // CASE FILE"

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
			return "witness"
		4:
			return "lost_and_found"
		5:
			return "drying"
	return ""

func _on_filter_changed(_index: int) -> void:
	_refresh_notebook()


func _on_evidence_selected(index: int) -> void:
	if index >= 0 and index < _displayed_clue_ids.size():
		_show_clue(_displayed_clue_ids[index])


func _refresh_hypotheses() -> void:
	if hypothesis_list == null:
		return
	hypothesis_list.clear()
	_displayed_deduction_ids.clear()
	for deduction_id in _visible_demo_deduction_ids():
		var evaluation := _evaluate_demo_deduction(deduction_id)
		_displayed_deduction_ids.append(deduction_id)
		var marker := "* " if bool(evaluation.get("selected", false)) else ""
		hypothesis_list.add_item("%s%s [%s]" % [
			marker,
			String(evaluation.get("title", deduction_id)),
			String(evaluation.get("status", "unsupported")).to_upper()
		])
	if hypothesis_list.item_count > 0:
		hypothesis_list.select(0)
		_show_hypothesis(0)

func _show_hypothesis(index: int) -> void:
	if index < 0 or index >= _displayed_deduction_ids.size():
		return
	var deduction_id := _displayed_deduction_ids[index]
	var evaluation := _evaluate_demo_deduction(deduction_id)
	hypothesis_title.text = String(evaluation.get("title", deduction_id))
	hypothesis_status.text = "STATUS: %s" % String(evaluation.get("status", "unsupported")).to_upper()
	hypothesis_body.text = String(evaluation.get("description", ""))

	var support_lines := PackedStringArray()
	for clue_id_value in evaluation.get("supporting_evidence_ids", []):
		var clue_id := String(clue_id_value)
		if _demo_clues.has(clue_id):
			var clue: Dictionary = _demo_clues[clue_id]
			support_lines.append("+ %s" % String(clue.get("title", clue_id)))
	for clue_id_value in evaluation.get("contradicting_evidence_ids", []):
		var clue_id := String(clue_id_value)
		if _demo_clues.has(clue_id):
			var clue: Dictionary = _demo_clues[clue_id]
			support_lines.append("- CONTRADICTED BY: %s" % String(clue.get("title", clue_id)))

	hypothesis_support.text = "VISIBLE SUPPORT: %d/%d\n%s" % [
		int(evaluation.get("support_count", 0)),
		int(evaluation.get("minimum_support", 1)),
		"\n".join(support_lines) if not support_lines.is_empty() else "No discovered evidence supports this yet."
	]
	hypothesis_test_button.disabled = String(evaluation.get("status", "")) == "established"
	hypothesis_test_button.text = "ESTABLISHED" if hypothesis_test_button.disabled else "RECORD / TEST"

func _on_hypothesis_selected(index: int) -> void:
	_show_hypothesis(index)

func _record_hypothesis() -> void:
	var selected: PackedInt32Array = hypothesis_list.get_selected_items()
	if selected.is_empty():
		return
	var index := int(selected[0])
	if index < 0 or index >= _displayed_deduction_ids.size():
		return
	_select_demo_hypothesis(_displayed_deduction_ids[index])

func _open_character() -> void:
	if _demo_background_id.is_empty():
		_open_demo_background_choice()
		return
	_close_all_modals()
	_refresh_character_panel()
	character_panel.visible = true
	context_label.text = "UMBRELLA QUEST // CHARACTER"

func _open_dialogue(witness_id: String = "alex") -> void:
	if _demo_background_id.is_empty():
		_open_demo_background_choice()
		return
	if not _witness_definitions.has(witness_id):
		return
	_close_all_modals()
	_active_witness_id = witness_id
	var witness: Dictionary = _witness_definitions[witness_id]
	dialogue_panel.visible = true
	_dialogue_evidence_mode = false
	dialogue_name.text = String(witness.get("name", witness_id)).to_upper()
	dialogue_role.text = String(witness.get("role", ""))
	dialogue_portrait.texture = MINA_PORTRAIT if witness_id == "mina" else ALEX_PORTRAIT
	dialogue_line.text = String(witness.get("opening", ""))
	dialogue_trust.text = "TRUST %d" % _get_demo_trust(witness_id)
	dialogue_mode.text = "TOPICS / RESPONSES"
	present_button.text = "PRESENT EVIDENCE"
	_refresh_dialogue_choices()
	context_label.text = "UMBRELLA QUEST // CONVERSATION"

func _refresh_dialogue_choices() -> void:
	_clear_dialogue_actions()
	if _active_witness_id == "alex":
		_add_dialogue_action("What did you do with the umbrella from the rack?", {"type": "topic", "id": "alex_transfer"})
		_add_dialogue_action("Who handled lost property after you?", {"type": "topic", "id": "alex_shift"})
		if _demo_clues.has("cabinet_trace"):
			_add_dialogue_action("Cabinet B is empty. Who could move something from there?", {"type": "topic", "id": "alex_cabinet"})
	else:
		_add_dialogue_action("Tell me about your closing sweep.", {"type": "topic", "id": "mina_sweep"})
		_add_dialogue_action("What happens to soaking lost property?", {"type": "topic", "id": "mina_policy"})
		if _is_demo_deduction_established("cabinet_was_intermediate") or _demo_clues.has("cabinet_trace"):
			if not _demo_check_was_attempted("mina_protective_read"):
				_add_dialogue_action("[EMPATHY 3] You're worried about the paperwork, not the accusation.", {"type": "skill_topic", "id": "mina_protective_read"})
			if not _demo_check_was_attempted("mina_exact_route_challenge"):
				_add_dialogue_action("[RESOLVE 3] No procedure. Give me the exact route.", {"type": "skill_topic", "id": "mina_exact_route_challenge"})
			_add_dialogue_action("Did you move Ticket 47B out of Cabinet B?", {"type": "topic", "id": "mina_47b"})
	_add_dialogue_action("End conversation.", {"type": "close"})

func _toggle_dialogue_evidence() -> void:
	_dialogue_evidence_mode = not _dialogue_evidence_mode
	_clear_dialogue_actions()
	if _dialogue_evidence_mode:
		dialogue_mode.text = "PRESENT EVIDENCE"
		present_button.text = "BACK TO TOPICS"
		for clue_id_value in _demo_clues.keys():
			var clue_id := String(clue_id_value)
			var clue: Dictionary = _demo_clues[clue_id]
			_add_dialogue_action(String(clue.get("title", clue_id)), {"type": "evidence", "id": clue_id})
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
	var action: Dictionary = _dialogue_actions[index]
	match String(action.get("type", "")):
		"close":
			_close_all_modals()
		"topic":
			_apply_demo_topic(String(action.get("id", "")))
		"skill_topic":
			_run_demo_dialogue_skill(String(action.get("id", "")))
		"evidence":
			_present_demo_evidence(String(action.get("id", "")))


func _run_demo_dialogue_skill(check_id: String) -> Dictionary:
	if check_id == "mina_protective_read":
		var empathy := _perform_demo_check(
			check_id,
			"empathy",
			3,
			0,
			"Read what Mina is actually defending",
			"Ask about wet-property policy or present the Cabinet B / fan evidence."
		)
		if bool(empathy.get("passed", false)):
			_acquire_demo_clue("reader_protective_tell", false)
			_change_demo_trust("mina", 1)
			dialogue_line.text = "[%s]\nMina keeps looking at the paper files, not the missing umbrella. “I was trying to keep the whole cabinet from getting soaked.”" % _format_demo_check(empathy)
		else:
			dialogue_line.text = "[%s]\nMina reads the question as an accusation and closes off. FALLBACK: ask about policy or show physical evidence." % _format_demo_check(empathy)
		dialogue_trust.text = "TRUST %d" % _get_demo_trust("mina")
		_refresh_dialogue_choices()
		_refresh_notebook()
		_refresh_hypotheses()
		return empathy

	if check_id == "mina_exact_route_challenge":
		var resolve := _perform_demo_check(
			check_id,
			"resolve",
			3,
			0,
			"Press Mina for the exact physical route",
			"Corroborate the route with the shift board, transfer tag, fan timer, or evidence presentation."
		)
		if bool(resolve.get("passed", false)):
			_acquire_demo_clue("mina_statement", false)
			_acquire_demo_clue("anchor_exact_route", false)
			_change_demo_trust("mina", -1)
			dialogue_line.text = "[%s]\nMina stops hedging. “Cabinet B. Storage cart. Maintenance corridor. Rear drying rail. That's the exact route.”" % _format_demo_check(resolve)
		else:
			_change_demo_trust("mina", -1)
			dialogue_line.text = "[%s]\n“I'm not being interrogated over an umbrella.” Mina digs in. FALLBACK: prove the route from records and physical traces." % _format_demo_check(resolve)
		dialogue_trust.text = "TRUST %d" % _get_demo_trust("mina")
		_refresh_dialogue_choices()
		_refresh_notebook()
		_refresh_hypotheses()
		return resolve

	return {"ok": false, "passed": false, "error": "unknown_demo_check"}

func _apply_demo_topic(topic_id: String) -> void:
	match topic_id:
		"alex_transfer":
			_acquire_demo_clue("alex_statement", false)
			_change_demo_trust("alex", 1)
			dialogue_line.text = "“At 8:55 I cleared the rack. The navy one with yellow tape went straight to Lost & Found. I was back behind this desk before nine.”"
		"alex_shift":
			dialogue_line.text = "“Mina had the east-hall sweep and rear close. Check the shift board if you want it in writing.”"
		"alex_cabinet":
			dialogue_line.text = "“Once I logged it, I never touched Cabinet B again. Mina's sweep is the only staff route that continues through there after nine.”"
		"mina_sweep":
			dialogue_line.text = "“East hall, storage, service corridor, rear close. Same loop every wet night.”"
		"mina_policy":
			_acquire_demo_clue("wet_property_policy", false)
			_change_demo_trust("mina", 1)
			dialogue_line.text = "“Anything soaking gets moved to the rear rail. Paper claims and donation boxes don't mix with dripping fabric.”"
		"mina_47b":
			_acquire_demo_clue("mina_statement", false)
			_change_demo_trust("mina", 1)
			dialogue_line.text = "Mina studies the ticket number. “Forty-seven B... yes. Navy, yellow tape. I moved that one during the sweep.”"
	dialogue_trust.text = "TRUST %d" % _get_demo_trust(_active_witness_id)
	_refresh_dialogue_choices()
	_refresh_notebook()
	_refresh_hypotheses()


func _present_demo_evidence(clue_id: String) -> void:
	if not _demo_clues.has(clue_id):
		return
	if _active_witness_id == "alex":
		match clue_id:
			"ticket_47b":
				_acquire_demo_clue("alex_statement", false)
				_change_demo_trust("alex", 1)
				dialogue_line.text = "Alex points at the description. “That's the one. Yellow tape, weird brass bird. I carried it east myself.”"
			"closing_log":
				dialogue_line.text = "“That's my handwriting. Rack clear at 8:56, then I was back on desk duty.”"
			"cabinet_trace":
				dialogue_line.text = "“Then somebody moved it after me. Mina's sweep is the only staff route through that cabinet after nine.”"
			_:
				dialogue_line.text = "Alex considers it. “Useful, maybe. It doesn't change what I did with the rack.”"
	else:
		match clue_id:
			"cabinet_trace", "transfer_tag":
				_acquire_demo_clue("mina_statement", false)
				_change_demo_trust("mina", 1)
				dialogue_line.text = "Mina exhales. “Okay. I moved 47B. It was soaking through the cabinet shelf, so I put it on my service cart.”"
			"fan_timer":
				_acquire_demo_clue("mina_reason", false)
				_change_demo_trust("mina", 1)
				dialogue_line.text = "“I switched that fan on for the drying rail. The umbrella was dripping onto paperwork and donation boxes.”"
			"wet_property_policy":
				_acquire_demo_clue("mina_reason", false)
				dialogue_line.text = "“Exactly. I followed that rule. I should have updated the claim ticket before I kept moving.”"
			"ticket_47b":
				_acquire_demo_clue("mina_statement", false)
				dialogue_line.text = "Mina recognizes the number. “Yes. That's the wet umbrella I moved on the east-hall sweep.”"
			_:
				dialogue_line.text = "Mina scans the evidence. “That doesn't tell you more about my closing route.”"
	dialogue_trust.text = "TRUST %d" % _get_demo_trust(_active_witness_id)
	_refresh_notebook()
	_refresh_hypotheses()


func _get_demo_trust(witness_id: String) -> int:
	return int(_demo_trust.get(witness_id, 0))


func _change_demo_trust(witness_id: String, amount: int) -> void:
	_demo_trust[witness_id] = clampi(_get_demo_trust(witness_id) + amount, -3, 3)

func _demo_save() -> void:
	if _demo_background_id.is_empty():
		_open_demo_background_choice()
		_set_status("Choose an approach before saving the Umbrella Quest.")
		return
	if not is_instance_valid(_current_room):
		_set_status("DEMO SAVE // no active room.")
		return
	_saved_room_path = _current_room_path
	_saved_foot = _current_room.call("get_player_foot")
	_saved_clues = _demo_clues.duplicate(true)
	_saved_trust = _demo_trust.duplicate(true)
	_saved_deductions = _demo_deductions.duplicate(true)
	_saved_hypotheses = _selected_hypotheses.duplicate()
	_saved_case_resolved = _case_resolved
	_saved_background_id = _demo_background_id
	_saved_skill_values = _demo_skill_values.duplicate(true)
	_saved_failed_approaches = _demo_failed_approaches.duplicate(true)
	_saved_skill_checks = _demo_skill_checks.duplicate(true)
	_has_demo_save = true
	_set_status("DEMO SAVE // room, case, profile, skills, failed approaches, and position stored in memory.")

func _demo_load() -> void:
	if not _has_demo_save:
		_set_status("DEMO LOAD // no snapshot yet. Press SAVE first.")
		return
	_demo_clues = _saved_clues.duplicate(true)
	_demo_trust = _saved_trust.duplicate(true)
	_demo_deductions = _saved_deductions.duplicate(true)
	_selected_hypotheses = _saved_hypotheses.duplicate()
	_case_resolved = _saved_case_resolved
	_demo_background_id = _saved_background_id
	_demo_skill_values = _saved_skill_values.duplicate(true)
	_demo_failed_approaches = _saved_failed_approaches.duplicate(true)
	_demo_skill_checks = _saved_skill_checks.duplicate(true)
	background_overlay.visible = false
	_load_demo_room(_saved_room_path, "", _saved_foot)
	_refresh_notebook()
	_refresh_hypotheses()
	_refresh_character_panel()
	_set_status("DEMO LOAD // investigation + RPG snapshot restored. %s" % _case_objective())

func _set_reveal(value: bool) -> void:
	if is_instance_valid(_current_room):
		_current_room.call("set_hotspot_reveal", value)
	context_label.text = "INTERACTABLES" if value else _room_context()


func _close_all_modals() -> void:
	notebook_panel.visible = false
	character_panel.visible = false
	dialogue_panel.visible = false
	resolution_panel.visible = false
	background_overlay.visible = _demo_background_id.is_empty()
	context_label.text = "UMBRELLA QUEST // APPROACH" if background_overlay.visible else _room_context()

func _modal_open() -> bool:
	return background_overlay.visible or notebook_panel.visible or character_panel.visible or dialogue_panel.visible or resolution_panel.visible

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
