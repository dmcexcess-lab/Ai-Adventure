extends Control
class_name AdventurePlayerActor

signal arrived

const PC3_ATLAS: Texture2D = preload("res://art/characters/pc3/pc3_reference_atlas.webp")
const POSE_REGIONS := {
	"front": Rect2(3, 1, 28, 70),
	"walk_left_3q": Rect2(38, 3, 30, 68),
	"idle_right_3q": Rect2(76, 2, 25, 69),
	"side_right": Rect2(107, 4, 39, 67),
	"rear_right_3q": Rect2(147, 3, 28, 68),
	"combat": Rect2(176, 9, 40, 62),
}

@export var move_speed := 210.0
@export_enum("front", "walk_left_3q", "idle_right_3q", "side_right", "rear_right_3q", "combat") var default_pose_id := "idle_right_3q"
@export var default_flip_h := false
@export var perspective_far_scale := 0.80
@export var perspective_near_scale := 1.04
@export var perspective_top_y := 236.0
@export var perspective_bottom_y := 390.0
@export var visual_display_size := Vector2(84.0, 164.0)

var _destination_position := Vector2.ZERO
var _destination_foot := Vector2.ZERO
var _moving := false
var _visual: TextureRect
var _visual_base_position := Vector2.ZERO
var _walk_phase := 0.0
var _idle_phase := 0.0
var _pose_cache: Dictionary = {}
var _current_pose_id := ""
var _current_flip_h := false
var _context_pose_id := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_destination_position = position
	_destination_foot = get_foot_position()
	_visual = get_node_or_null("Sprite") as TextureRect
	_build_pose_cache()
	_configure_visual_rect()
	_apply_default_pose()
	_update_visual_scale()
	set_process(true)


func place_at_foot(foot_position: Vector2) -> void:
	position = foot_position - _foot_offset()
	_destination_position = position
	_destination_foot = foot_position
	_moving = false
	_apply_default_pose()
	_reset_visual_motion()
	_update_visual_scale()


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
		_apply_default_pose()
		_reset_visual_motion()
		_update_visual_scale()
		return false

	_select_movement_pose(_destination_foot - get_foot_position())
	_moving = true
	return true


func stop() -> void:
	_destination_position = position
	_destination_foot = get_foot_position()
	_moving = false
	_apply_default_pose()
	_reset_visual_motion()
	_update_visual_scale()


func is_moving() -> bool:
	return _moving


func get_destination_foot() -> Vector2:
	return _destination_foot


func get_foot_position() -> Vector2:
	return position + _foot_offset()


func get_current_pose_id() -> String:
	return _current_pose_id


func get_default_pose_id() -> String:
	return default_pose_id


func get_visual_perspective_scale() -> float:
	return _perspective_scale()


func get_visual_display_size() -> Vector2:
	return visual_display_size


func get_visual_rendered_height() -> float:
	return visual_display_size.y * _perspective_scale()


func set_combat_pose(active: bool) -> void:
	if active:
		_context_pose_id = "combat"
		_apply_pose("combat", false)
	else:
		_context_pose_id = ""
		if _moving:
			_select_movement_pose(_destination_foot - get_foot_position())
		else:
			_apply_default_pose()
	_update_visual_scale()


func _process(delta: float) -> void:
	if _moving:
		position = position.move_toward(_destination_position, move_speed * delta)
		_walk_phase += delta * 11.5
		_apply_walk_motion()
		_update_visual_scale()

		if position.distance_to(_destination_position) <= 0.5:
			position = _destination_position
			_moving = false
			_apply_default_pose()
			_reset_visual_motion()
			_update_visual_scale()
			arrived.emit()
		return

	_idle_phase += delta * 1.8
	_apply_idle_motion()
	_update_visual_scale()


func _configure_visual_rect() -> void:
	if _visual == null:
		return
	_visual.set_anchors_preset(Control.PRESET_TOP_LEFT, false)
	_visual.size = visual_display_size
	_visual.position = Vector2(
		(size.x - visual_display_size.x) * 0.5,
		size.y - visual_display_size.y
	)
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_visual_base_position = _visual.position
	_visual.pivot_offset = Vector2(visual_display_size.x * 0.5, visual_display_size.y)


func _build_pose_cache() -> void:
	_pose_cache.clear()
	for pose_id_value in POSE_REGIONS.keys():
		var pose_id := String(pose_id_value)
		var texture := AtlasTexture.new()
		texture.atlas = PC3_ATLAS
		texture.region = POSE_REGIONS[pose_id]
		_pose_cache[pose_id] = texture


func _select_movement_pose(direction: Vector2) -> void:
	if not _context_pose_id.is_empty():
		_apply_pose(_context_pose_id, false)
		return

	var abs_x := absf(direction.x)
	var abs_y := absf(direction.y)
	if abs_x >= abs_y * 0.80:
		_apply_pose("side_right", direction.x < 0.0)
	elif direction.y < 0.0:
		_apply_pose("rear_right_3q", direction.x < 0.0)
	else:
		_apply_pose("walk_left_3q", direction.x >= 0.0)


func _apply_default_pose() -> void:
	if not _context_pose_id.is_empty():
		_apply_pose(_context_pose_id, false)
		return
	_apply_pose(default_pose_id, default_flip_h)


func _apply_pose(pose_id: String, flip_h: bool) -> void:
	if _visual == null:
		return
	var resolved_id := pose_id if _pose_cache.has(pose_id) else "idle_right_3q"
	_visual.texture = _pose_cache[resolved_id]
	_current_pose_id = resolved_id
	_current_flip_h = flip_h


func _apply_walk_motion() -> void:
	if _visual == null:
		return
	_visual.position = _visual_base_position + Vector2(0.0, sin(_walk_phase * 2.0) * 1.35)
	_visual.rotation = sin(_walk_phase) * 0.018


func _apply_idle_motion() -> void:
	if _visual == null:
		return
	_visual.position = _visual_base_position + Vector2(0.0, sin(_idle_phase) * 0.22)
	_visual.rotation = 0.0


func _reset_visual_motion() -> void:
	if _visual == null:
		return
	_visual.position = _visual_base_position
	_visual.rotation = 0.0


func _update_visual_scale() -> void:
	if _visual == null:
		return
	var scale_value := _perspective_scale()
	_visual.scale = Vector2(-scale_value if _current_flip_h else scale_value, scale_value)


func _perspective_scale() -> float:
	var span := maxf(1.0, perspective_bottom_y - perspective_top_y)
	var t := clampf((get_foot_position().y - perspective_top_y) / span, 0.0, 1.0)
	return lerpf(perspective_far_scale, perspective_near_scale, t)


func _foot_offset() -> Vector2:
	return Vector2(size.x * 0.5, size.y)
