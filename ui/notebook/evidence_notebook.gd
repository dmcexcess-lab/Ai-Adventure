extends PanelContainer

signal closed

@onready var filter_option: OptionButton = %FilterOption
@onready var evidence_list: ItemList = %EvidenceList
@onready var title_label: Label = %TitleLabel
@onready var meta_label: Label = %MetaLabel
@onready var detail_label: Label = %DetailLabel
@onready var tags_label: Label = %TagsLabel
@onready var empty_label: Label = %EmptyLabel
@onready var close_button: Button = %CloseButton

var _displayed_ids: Array = []
var _evidence_service: Node


func _ready() -> void:
	_evidence_service = get_node_or_null("/root/EvidenceService")
	filter_option.item_selected.connect(_on_filter_selected)
	evidence_list.item_selected.connect(_on_evidence_selected)
	close_button.pressed.connect(close_notebook)
	visible = false


func open_notebook() -> void:
	visible = true
	refresh()
	if evidence_list.item_count > 0:
		evidence_list.grab_focus()
	else:
		close_button.grab_focus()


func close_notebook() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func is_open() -> bool:
	return visible


func refresh() -> void:
	if _evidence_service == null:
		_show_empty("Evidence service unavailable.")
		return

	var selected_tag := _selected_filter_tag()
	_rebuild_filters(selected_tag)
	selected_tag = _selected_filter_tag()
	_rebuild_list(selected_tag)


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


func _rebuild_list(filter_tag: String) -> void:
	evidence_list.clear()
	_displayed_ids.clear()

	var evidence: Array = _evidence_service.call("get_discovered_evidence", filter_tag)
	for clue_value in evidence:
		var clue: Dictionary = clue_value
		var clue_id := String(clue.get("id", ""))
		_displayed_ids.append(clue_id)
		evidence_list.add_item(String(clue.get("title", clue_id)))

	if evidence_list.item_count == 0:
		_show_empty("No evidence recorded for this filter.")
		return

	empty_label.visible = false
	evidence_list.select(0)
	_show_clue(String(_displayed_ids[0]))


func _show_clue(clue_id: String) -> void:
	var clue: Dictionary = _evidence_service.call("get_evidence", clue_id)
	if clue.is_empty():
		_show_empty("Evidence entry unavailable.")
		return

	empty_label.visible = false
	title_label.text = String(clue.get("title", clue_id))
	meta_label.text = "SOURCE: %s\nRELIABILITY: %s" % [
		String(clue.get("source", "Unknown")),
		String(clue.get("reliability", "Unknown")),
	]

	var temporal := String(clue.get("temporal_provenance", ""))
	var detail := String(clue.get("detail_text", ""))
	if not temporal.is_empty():
		detail += "\n\nTEMPORAL PROVENANCE\n" + temporal
	detail_label.text = detail

	var tags: Array = clue.get("tags", [])
	var contradictions: Array = clue.get("contradiction_tags", [])
	tags_label.text = "TAGS: %s" % _join_values(tags)
	if not contradictions.is_empty():
		tags_label.text += "\nCONTRADICTION TAGS: %s" % _join_values(contradictions)


func _show_empty(message: String) -> void:
	empty_label.visible = true
	empty_label.text = message
	title_label.text = "NO ENTRY SELECTED"
	meta_label.text = ""
	detail_label.text = ""
	tags_label.text = ""


func _selected_filter_tag() -> String:
	if filter_option.item_count == 0 or filter_option.selected < 0:
		return ""
	return String(filter_option.get_item_metadata(filter_option.selected))


func _on_filter_selected(_index: int) -> void:
	_rebuild_list(_selected_filter_tag())


func _on_evidence_selected(index: int) -> void:
	if index < 0 or index >= _displayed_ids.size():
		return
	_show_clue(String(_displayed_ids[index]))


func _join_values(values: Array) -> String:
	var parts := PackedStringArray()
	for value in values:
		parts.append(String(value))
	return ", ".join(parts)
