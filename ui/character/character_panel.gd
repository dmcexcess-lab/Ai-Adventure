extends PanelContainer

signal closed

@onready var background_label: Label = %BackgroundLabel
@onready var background_sentence: Label = %BackgroundSentence
@onready var skills_label: Label = %SkillsLabel
@onready var descriptions_label: Label = %DescriptionsLabel
@onready var failures_label: Label = %FailuresLabel
@onready var close_button: Button = %CloseButton

var _skill_service: Node
var _state: Node


func _ready() -> void:
	_skill_service = get_node_or_null("/root/SkillService")
	_state = get_node_or_null("/root/GameState")
	close_button.pressed.connect(close_panel)
	visible = false


func open_panel() -> void:
	visible = true
	refresh()
	close_button.grab_focus()


func close_panel() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func is_open() -> bool:
	return visible


func refresh() -> void:
	if _skill_service == null or _state == null:
		background_label.text = "BACKGROUND UNAVAILABLE"
		background_sentence.text = ""
		skills_label.text = ""
		descriptions_label.text = ""
		failures_label.text = ""
		return

	var background_id := String(_state.get("background_id"))
	var profile: Dictionary = _skill_service.call("get_background", background_id)
	background_label.text = String(profile.get("title", "Unchosen Background")).to_upper()
	background_sentence.text = String(profile.get("sentence", "No background profile has been selected."))

	var skill_values: Dictionary = _state.get("skill_values")
	var definitions: Dictionary = _skill_service.call("get_skill_definitions")
	var rows := PackedStringArray()
	var desc := PackedStringArray()
	for skill_id in ["observation", "reasoning", "empathy", "resolve"]:
		var definition: Dictionary = definitions.get(skill_id, {})
		rows.append("%s  %d" % [
			String(definition.get("name", skill_id)).to_upper(),
			int(skill_values.get(skill_id, 0))
		])
		desc.append("%s — %s" % [
			String(definition.get("name", skill_id)),
			String(definition.get("description", ""))
		])
	skills_label.text = "\n".join(rows)
	descriptions_label.text = "\n".join(desc)

	var failed: Dictionary = _skill_service.call("get_failed_approaches")
	if failed.is_empty():
		failures_label.text = "FAILED APPROACHES\nNone recorded."
		return

	var failure_rows := PackedStringArray(["FAILED APPROACHES"])
	for check_id in failed.keys():
		var item: Dictionary = failed[check_id]
		var context := String(item.get("context", check_id))
		failure_rows.append("• %s // %s %d vs %d // attempts %d" % [
			context,
			String(item.get("skill", "")).to_upper(),
			int(item.get("last_total", 0)),
			int(item.get("threshold", 0)),
			int(item.get("attempts", 1))
		])
	failures_label.text = "\n".join(failure_rows)
