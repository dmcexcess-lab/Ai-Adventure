extends Control
class_name AdventurePlayerActor

signal arrived

@export var move_speed := 210.0

var _destination_position := Vector2.ZERO
var _destination_foot := Vector2.ZERO
var _moving := false
var _visual: Control
var _visual_base_position := Vector2.ZERO
var _walk_phase := 0.0
var _idle_phase := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_destination_position = position
	_destination_foot = get_foot_position()
	_visual = get_node_or_null("Sprite") as Control
	if _visual != null:
		_visual_base_position = _visual.position
		_visual.pivot_offset = _visual.size * 0.5
	set_process(true)


func place_at_foot(foot_position: Vector2) -> void:
	position = foot_position - _foot_offset()
	_destination_position = position
	_destination_foot = foot_position
	_moving = false
	_reset_visual_pose()


func move_to(foot_target: Vector2, walk_bounds: Rect2) -> bool:
	var max_point := walk_bounds.position + walk_bounds.size
	_destination_foot = Vector2(
		clampf(foot_target.x, walk_bounds.position.x, max_point.x),
		clampf(foot_target.y, walk_bounds.position.y, max_point.y)
	)
	_destination_position = _destination_foot - _foot_offset()

	if position.distance_to(_destination_position) <= 0.5:
		position = _destination_position
		_moving = false
		_reset_visual_pose()
		return false

	_moving = true
	return true


func stop() -> void:
	_destination_position = position
	_destination_foot = get_foot_position()
	_moving = false
	_reset_visual_pose()


func is_moving() -> bool:
	return _moving


func get_destination_foot() -> Vector2:
	return _destination_foot


func get_foot_position() -> Vector2:
	return position + _foot_offset()


func _process(delta: float) -> void:
	if _moving:
		position = position.move_toward(_destination_position, move_speed * delta)
		_walk_phase += delta * 11.5
		_apply_walk_pose()

		if position.distance_to(_destination_position) <= 0.5:
			position = _destination_position
			_moving = false
			_reset_visual_pose()
			arrived.emit()
		return

	_idle_phase += delta * 1.8
	_apply_idle_pose()


func _apply_walk_pose() -> void:
	if _visual == null:
		return
	_visual.position = _visual_base_position + Vector2(0.0, sin(_walk_phase * 2.0) * 1.35)
	_visual.rotation = sin(_walk_phase) * 0.018


func _apply_idle_pose() -> void:
	if _visual == null:
		return
	_visual.position = _visual_base_position + Vector2(0.0, sin(_idle_phase) * 0.22)
	_visual.rotation = 0.0


func _reset_visual_pose() -> void:
	if _visual == null:
		return
	_visual.position = _visual_base_position
	_visual.rotation = 0.0


func _foot_offset() -> Vector2:
	return Vector2(size.x * 0.5, size.y)
