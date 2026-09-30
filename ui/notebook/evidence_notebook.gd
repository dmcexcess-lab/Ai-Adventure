extends PanelContainer

signal closed

@onready var evidence_mode_button: Button = %EvidenceModeButton
@onready var hypothesis_mode_button: Button = %HypothesisModeButton
@onready var evidence_panel: Control = %EvidencePanel
@onready var hypothesis_panel: Control = %HypothesisPanel

@onready var filter_option: OptionButton = %FilterOption
@onready var evidence_list: ItemList = %EvidenceList
@onready var evidence_title: Label = %EvidenceTitle
@onready var evidence_meta: Label = %EvidenceMeta
@onready var evidence_detail: Label = %EvidenceDetail
@onready var evidence_tags: Label = %EvidenceTags
@onready var evidence_empty: Label = %EvidenceEmpty

@onready var deduction_list: ItemList = %DeductionList
@onready var deduction_title: Label = %DeductionTitle
@onready var deduction_status: Label = %DeductionStatus
@onready var deduction_detail: Label = %DeductionDetail
@onready var deduction_support: Label = %DeductionSupport
@onready var hypothesis_button: Button = %HypothesisButton

@onready var close_button: Button = %CloseButton

var _displayed_clue_ids: Array = []
var _displayed_deduction_ids: Array = []
var _evidence_service: Node
var _deduction_service: Node
var _mode := "evidence"


func _ready() -> void:
	_evidence_service = get_node_or_null("/root/EvidenceService")
	_deduction_service = get_node_or_null("/root/DeductionService")

	evidence_mode_button.pressed.connect(func() -> void: set_mode("evidence"))
	hypothesis_mode_button.pressed.connect(func() -> void: set_mode("hypotheses"))
	filter_option.item_selected.connect(_on_filter_selected)
	evidence_list.item_selected.connect(_on_evidence_selected)
	deduction_list.item_selected.connect(_on_deduction_selected)
	hypothesis_button.pressed.connect(_on_hypothesis_pressed)
	close_button.pressed.connect(close_notebook)
	visible = false


func open_notebook(mode: String = "") -> void:
	if mode == "evidence" or mode == "hypotheses":
		_mode = mode
	visible = true
	refresh()
	_focus_current_mode()


func close_notebook() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func is_open() -> bool:
	return visible


func set_mode(mode: String) -> void:
	if mode != "evidence" and mode != "hypotheses":
		return
	_mode = mode
	refresh()
	_focus_current_mode()


func refresh() -> void:
	var show_evidence := _mode == "evidence"
	evidence_panel.visible = show_evidence
	hypothesis_panel.visible = not show_evidence
	evidence_mode_button.disabled = show_evidence
	hypothesis_mode_button.disabled = not show_evidence

	if show_evidence:
		_refresh_evidence()
	else:
		_refresh_deductions()


func _refresh_evidence() -> void:
	if _evidence_service == null:
		_show_evidence_empty("Evidence service unavailable.")
		return

	var selected_tag := _selected_filter_tag()
	_rebuild_filters(selected_tag)
	_rebuild_evidence_list(_selected_filter_tag())


func _rebuild_filters(preferred_tag: String) -> void:
	filter_option.clear()
	filter_option.add_item("ALL")
	filter_option.set_item_metadata(0, "")
	var selected_index := 0

	var tags: Array = _evidence_service.call("get_discovered_tags")
	for tag_value in tags:
		var tag := String(tag_value)
		var index := filter_option.item_count
		filter_option.add_item(tag.to_upper())
		filter_option.set_item_metadata(index, tag)
		if tag == preferred_tag:
			selected_index = index
	filter_option.select(selected_index)


func _rebuild_evidence_list(filter_tag: String) -> void:
	evidence_list.clear()
	_displayed_clue_ids.clear()

	var evidence: Array = _evidence_service.call("get_discovered_evidence", filter_tag)
	for clue_value in evidence:
		var clue: Dictionary = clue_value
		var clue_id := String(clue.get("id", ""))
		_displayed_clue_ids.append(clue_id)
		evidence_list.add_item(String(clue.get("title", clue_id)))

	if evidence_list.item_count == 0:
		_show_evidence_empty("No evidence recorded for this filter.")
		return

	evidence_empty.visible = false
	evidence_list.select(0)
	_show_clue(String(_displayed_clue_ids[0]))


func _show_clue(clue_id: String) -> void:
	var clue: Dictionary = _evidence_service.call("get_evidence", clue_id)
	if clue.is_empty():
		_show_evidence_empty("Evidence entry unavailable.")
		return

	evidence_empty.visible = false
	evidence_title.text = String(clue.get("title", clue_id))
	evidence_meta.text = "SOURCE: %s\nRELIABILITY: %s" % [
		String(clue.get("source", "Unknown")),
		String(clue.get("reliability", "Unknown")),
	]

	var temporal := String(clue.get("temporal_provenance", ""))
	var detail := String(clue.get("detail_text", ""))
	if not temporal.is_empty():
		detail += "\n\nTEMPORAL PROVENANCE\n" + temporal
	evidence_detail.text = detail

	var tags: Array = clue.get("tags", [])
	var contradictions: Array = clue.get("contradiction_tags", [])
	evidence_tags.text = "TAGS: %s" % _join_values(tags)
	if not contradictions.is_empty():
		evidence_tags.text += "\nCONTRADICTION TAGS: %s" % _join_values(contradictions)


func _show_evidence_empty(message: String) -> void:
	evidence_empty.visible = true
	evidence_empty.text = message
	evidence_title.text = "NO ENTRY SELECTED"
	evidence_meta.text = ""
	evidence_detail.text = ""
	evidence_tags.text = ""


func _refresh_deductions() -> void:
	if _deduction_service == null:
		_show_deduction_empty("Deduction service unavailable.")
		return

	deduction_list.clear()
	_displayed_deduction_ids.clear()
	var deductions: Array = _deduction_service.call("get_all_deductions")

	for value in deductions:
		var deduction: Dictionary = value
		var deduction_id := String(deduction.get("id", ""))
		var status := String(deduction.get("status", "unsupported"))
		var selected := bool(deduction.get("selected", false))
		var prefix := "* " if selected else ""
		_displayed_deduction_ids.append(deduction_id)
		deduction_list.add_item("%s%s [%s]" % [
			prefix,
			String(deduction.get("title", deduction_id)),
			status.to_upper(),
		])

	if deduction_list.item_count == 0:
		_show_deduction_empty("No hypotheses are available.")
		return

	deduction_list.select(0)
	_show_deduction(String(_displayed_deduction_ids[0]))


func _show_deduction(deduction_id: String) -> void:
	var deduction: Dictionary = _deduction_service.call("evaluate", deduction_id)
	if deduction.is_empty():
		_show_deduction_empty("Hypothesis unavailable.")
		return

	deduction_title.text = String(deduction.get("title", deduction_id))
	var status := String(deduction.get("status", "unsupported"))
	deduction_status.text = "STATUS: %s%s" % [
		status.to_upper(),
		" // RECORDED" if bool(deduction.get("selected", false)) else "",
	]
	deduction_detail.text = String(deduction.get("description", ""))

	var support_lines := PackedStringArray()
	var support: Array = _deduction_service.call("get_visible_support", deduction_id)
	for clue_value in support:
		var clue: Dictionary = clue_value
		support_lines.append("+ " + String(clue.get("title", "Evidence")))

	var contradictions: Array = _deduction_service.call("get_visible_contradictions", deduction_id)
	for clue_value in contradictions:
		var clue: Dictionary = clue_value
		support_lines.append("- CONTRADICTS: " + String(clue.get("title", "Evidence")))

	var count := int(deduction.get("support_count", 0))
	var required := int(deduction.get("minimum_support", 1))
	var prereq_text := "MET" if bool(deduction.get("prerequisites_met", true)) else "NOT MET"
	var summary := "VISIBLE SUPPORT: %d/%d // PREREQUISITES: %s" % [count, required, prereq_text]
	if support_lines.is_empty():
		summary += "\nNo discovered evidence currently supports or contradicts this hypothesis."
	else:
		summary += "\n" + "\n".join(support_lines)
	deduction_support.text = summary

	hypothesis_button.disabled = status == "established"
	hypothesis_button.text = "ESTABLISHED" if status == "established" else "TEST / RECORD HYPOTHESIS"


func _show_deduction_empty(message: String) -> void:
	deduction_title.text = "NO HYPOTHESIS SELECTED"
	deduction_status.text = ""
	deduction_detail.text = message
	deduction_support.text = ""
	hypothesis_button.disabled = true


func _on_hypothesis_pressed() -> void:
	if deduction_list.get_selected_items().is_empty():
		return
	var index := int(deduction_list.get_selected_items()[0])
	if index < 0 or index >= _displayed_deduction_ids.size():
		return
	var deduction_id := String(_displayed_deduction_ids[index])
	_deduction_service.call("select_hypothesis", deduction_id)
	_refresh_deductions()

	for i in range(_displayed_deduction_ids.size()):
		if String(_displayed_deduction_ids[i]) == deduction_id:
			deduction_list.select(i)
			_show_deduction(deduction_id)
			break


func _selected_filter_tag() -> String:
	if filter_option.item_count == 0 or filter_option.selected < 0:
		return ""
	return String(filter_option.get_item_metadata(filter_option.selected))


func _on_filter_selected(_index: int) -> void:
	_rebuild_evidence_list(_selected_filter_tag())


func _on_evidence_selected(index: int) -> void:
	if index >= 0 and index < _displayed_clue_ids.size():
		_show_clue(String(_displayed_clue_ids[index]))


func _on_deduction_selected(index: int) -> void:
	if index >= 0 and index < _displayed_deduction_ids.size():
		_show_deduction(String(_displayed_deduction_ids[index]))


func _focus_current_mode() -> void:
	if _mode == "evidence" and evidence_list.item_count > 0:
		evidence_list.grab_focus()
	elif _mode == "hypotheses" and deduction_list.item_count > 0:
		deduction_list.grab_focus()
	else:
		close_button.grab_focus()


func _join_values(values: Array) -> String:
	var parts := PackedStringArray()
	for value in values:
		parts.append(String(value))
	return ", ".join(parts)
