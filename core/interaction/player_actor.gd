extends Control
class_name AdventurePlayerActor

signal arrived

@export var move_speed := 210.0

var _destination_position := Vector2.ZERO
var _destination_foot := Vector2.ZERO
var _moving := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_destination_position = position
	_destination_foot = get_foot_position()
	set_process(false)


func place_at_foot(foot_position: Vector2) -> void:
	position = foot_position - _foot_offset()
	_destination_position = position
	_destination_foot = foot_position
	_moving = false
	set_process(false)


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
		set_process(false)
		return false

	_moving = true
	set_process(true)
	return true


func stop() -> void:
	_destination_position = position
	_destination_foot = get_foot_position()
	_moving = false
	set_process(false)


func is_moving() -> bool:
	return _moving


func get_destination_foot() -> Vector2:
	return _destination_foot


func get_foot_position() -> Vector2:
	return position + _foot_offset()


func _process(delta: float) -> void:
	position = position.move_toward(_destination_position, move_speed * delta)

	if position.distance_to(_destination_position) <= 0.5:
		position = _destination_position
		_moving = false
		set_process(false)
		arrived.emit()


func _foot_offset() -> Vector2:
	return Vector2(size.x * 0.5, size.y)
