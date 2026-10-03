extends Control
class_name AdventureHotspot

signal hover_changed(label: String)
signal action_requested(hotspot: Node, action: StringName)

@export var hotspot_id := ""
@export var display_name := "Hotspot"
@export_multiline var inspect_text := ""
@export_multiline var primary_text := ""
@export var transition_room := ""
@export var transition_spawn := ""
@export var approach_point := Vector2(-1.0, -1.0)
@export var evidence_id := ""
@export var evidence_detail_level := 1
@export var witness_id := ""
@export var skill_check_id := ""
@export var skill_name := ""
@export var skill_threshold := 0
@export var skill_modifier := 0
@export var skill_success_evidence_id := ""
@export var skill_success_evidence_detail_level := 1
@export_multiline var skill_success_text := ""
@export_multiline var skill_failure_text := ""
@export var enabled := true

var _hovered := false
var _reveal_active := false
var _input_enabled := true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP if enabled and _input_enabled else Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	queue_redraw()


func set_hotspot_enabled(value: bool) -> void:
	enabled = value
	if not enabled and _hovered:
		_hovered = false
		hover_changed.emit("")
	mouse_filter = Control.MOUSE_FILTER_STOP if enabled and _input_enabled else Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func set_input_enabled(value: bool) -> void:
	_input_enabled = value
	if not _input_enabled and _hovered:
		_hovered = false
		hover_changed.emit("")
	mouse_filter = Control.MOUSE_FILTER_STOP if enabled and _input_enabled else Control.MOUSE_FILTER_IGNORE


func set_reveal(value: bool) -> void:
	_reveal_active = value
	queue_redraw()


func is_reveal_active() -> bool:
	return _reveal_active


func trigger_primary() -> void:
	if enabled and _input_enabled:
		action_requested.emit(self, &"primary")


func trigger_inspect() -> void:
	if enabled and _input_enabled:
		action_requested.emit(self, &"inspect")


func _gui_input(event: InputEvent) -> void:
	if not enabled or not _input_enabled:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			trigger_primary()
			accept_event()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			trigger_inspect()
			accept_event()


func _on_mouse_entered() -> void:
	if not enabled or not _input_enabled:
		return
	_hovered = true
	hover_changed.emit(display_name)
	queue_redraw()


func _on_mouse_exited() -> void:
	if not _hovered:
		return
	_hovered = false
	hover_changed.emit("")
	queue_redraw()


func _draw() -> void:
	if not enabled:
		return

	var rect := Rect2(Vector2.ZERO, size)
	if _hovered:
		draw_rect(rect, Color(0.56, 0.82, 0.74, 0.12), true)
		draw_rect(rect, Color(0.63, 0.92, 0.79, 0.72), false, 1.0)
	elif _reveal_active:
		draw_rect(rect, Color(0.40, 0.67, 0.65, 0.06), true)
		draw_rect(rect, Color(0.48, 0.78, 0.73, 0.62), false, 1.0)
