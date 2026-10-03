extends Control
class_name AdventurePlayerActor

signal arrived
signal action_finished(action_id: String)

const PC3_IDLE_ATLAS: Texture2D = preload("res://art/characters/pc3/pc3_reference_atlas_hd.webp")
const VISUALS := preload("res://art/demo/visual_catalog.gd")
const IDLE_REGIONS := {
	"front": Rect2(12, 4, 112, 280),
	"walk_left_3q": Rect2(152, 12, 120, 272),
	"idle_right_3q": Rect2(304, 8, 100, 276),
	"side_right": Rect2(428, 16, 156, 268),
	"rear_right_3q": Rect2(588, 12, 112, 272),
	"combat": Rect2(704, 36, 160, 248),
}
const ACTION_CLIPS := {
	"dialogue": ["motion:dialogue", "motion:idle", "motion:dialogue"],
	"read": ["motion:read", "motion:read", "motion:idle"],
	"inspect": ["motion:inspect", "motion:inspect", "motion:idle"],
	"pick_up": ["motion:inspect", "motion:pick_up", "motion:show_clue"],
	"strike": ["combat:strike_windup", "combat:strike", "combat:recover"],
	"guard": ["combat:combat_ready", "combat:guard", "combat:combat_ready"],
	"maneuver": ["combat:combat_ready", "combat:maneuver", "combat:recover"],
	"hurt": ["combat:combat_ready", "combat:hurt", "combat:recover"],
	"disengage": ["combat:combat_ready", "combat:disengage", "combat:recover"],
}

@export var move_speed := 210.0
@export_enum("front", "walk_left_3q", "idle_right_3q", "side_right", "rear_right_3q", "combat") var default_pose_id := "idle_right_3q"
@export var default_flip_h := false
@export var perspective_far_scale := 0.64
@export var perspective_near_scale := 1.16
@export var perspective_top_y := 236.0
@export var perspective_bottom_y := 390.0
@export var visual_display_size := Vector2(118.0, 184.0)

var _destination_position := Vector2.ZERO
var _destination_foot := Vector2.ZERO
var _moving := false
var _visual: TextureRect
var _visual_base_position := Vector2.ZERO
var _idle_phase := 0.0
var _idle_cache: Dictionary = {}
var _current_pose_id := ""
var _current_flip_h := false
var _context_pose_id := ""
var _walk_direction := "side"
var _walk_frames: Array[Texture2D] = []
var _walk_frame_index := 0
var _walk_clock := 0.0
var _action_id := ""
var _action_frames: Array[Texture2D] = []
var _action_frame_index := 0
var _action_clock := 0.0
var _action_frame_time := 0.12


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_destination_position = position
	_destination_foot = get_foot_position()
	_visual = get_node_or_null("Sprite") as TextureRect
	_build_idle_cache()
	_configure_visual_rect()
	_apply_default_pose()
	_update_visual_scale()
	set_process(true)


func place_at_foot(foot_position: Vector2) -> void:
	position = foot_position - _foot_offset()
	_destination_position = position
	_destination_foot = foot_position
	_moving = false
	_cancel_action()
	_apply_default_pose()
	_reset_visual_motion()
	_update_visual_scale()


func move_to(foot_target: Vector2, walk_bounds: Rect2) -> bool:
	var max_point := walk_bounds.position + walk_bounds.size
	_destination_foot = Vector2(clampf(foot_target.x, walk_bounds.position.x, max_point.x), clampf(foot_target.y, walk_bounds.position.y, max_point.y))
	_destination_position = _destination_foot - _foot_offset()
	if position.distance_to(_destination_position) <= 0.5:
		position = _destination_position
		_moving = false
		_apply_default_pose()
		_update_visual_scale()
		return false
	_cancel_action()
	_select_walk_cycle(_destination_foot - get_foot_position())
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


func is_action_playing() -> bool:
	return not _action_id.is_empty()


func get_destination_foot() -> Vector2:
	return _destination_foot


func get_foot_position() -> Vector2:
	return position + _foot_offset()


func get_current_pose_id() -> String:
	return _current_pose_id


func get_current_animation_id() -> String:
	if not _action_id.is_empty():
		return _action_id
	return "walk_%s" % _walk_direction if _moving else _current_pose_id


func get_current_frame_index() -> int:
	return _action_frame_index if not _action_id.is_empty() else _walk_frame_index


func get_default_pose_id() -> String:
	return default_pose_id


func get_visual_perspective_scale() -> float:
	return _perspective_scale()


func get_visual_display_size() -> Vector2:
	return visual_display_size


func get_source_atlas_size() -> Vector2i:
	return Vector2i(VISUALS.PC3_WALK.get_width(), VISUALS.PC3_WALK.get_height())


func get_current_pose_region() -> Rect2:
	return IDLE_REGIONS.get(_current_pose_id, Rect2())


func get_visual_rendered_height() -> float:
	return visual_display_size.y * _perspective_scale()


func get_action_ids() -> Array[String]:
	var ids: Array[String] = []
	for action_value in ACTION_CLIPS.keys():
		ids.append(String(action_value))
	ids.sort()
	return ids


func play_action(action_id: String) -> bool:
	if not ACTION_CLIPS.has(action_id):
		return false
	_moving = false
	_destination_position = position
	_destination_foot = get_foot_position()
	_action_id = action_id
	_action_frames.clear()
	for frame_value in ACTION_CLIPS[action_id]:
		_action_frames.append(_action_texture(String(frame_value)))
	_action_frame_index = 0
	_action_clock = 0.0
	_apply_action_frame()
	return true


func set_combat_pose(active: bool) -> void:
	_cancel_action()
	if active:
		_context_pose_id = "combat"
		if _visual != null:
			_visual.texture = VISUALS.player_combat("combat_ready")
		_current_pose_id = "combat"
	else:
		_context_pose_id = ""
		_apply_default_pose()
	_update_visual_scale()


func _process(delta: float) -> void:
	if not _action_id.is_empty():
		_update_action(delta)
		_update_visual_scale()
		return
	if _moving:
		position = position.move_toward(_destination_position, move_speed * delta)
		_walk_clock += delta
		if _walk_clock >= (1.0 / 12.0):
			_walk_clock = fmod(_walk_clock, 1.0 / 12.0)
			_walk_frame_index = (_walk_frame_index + 1) % _walk_frames.size()
			if _visual != null:
				_visual.texture = _walk_frames[_walk_frame_index]
			_current_pose_id = "walk_%s_%d" % [_walk_direction, _walk_frame_index]
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
	_visual.position = Vector2((size.x - visual_display_size.x) * 0.5, size.y - visual_display_size.y)
	_visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_visual.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_visual_base_position = _visual.position
	_visual.pivot_offset = Vector2(visual_display_size.x * 0.5, visual_display_size.y)


func _build_idle_cache() -> void:
	_idle_cache.clear()
	for pose_id_value in IDLE_REGIONS.keys():
		var pose_id := String(pose_id_value)
		var texture := AtlasTexture.new()
		texture.atlas = PC3_IDLE_ATLAS
		texture.region = IDLE_REGIONS[pose_id]
		texture.filter_clip = true
		_idle_cache[pose_id] = texture


func _select_walk_cycle(direction: Vector2) -> void:
	var abs_x := absf(direction.x)
	var abs_y := absf(direction.y)
	if abs_x >= abs_y * 0.80:
		_walk_direction = "side"
		_current_flip_h = direction.x < 0.0
	elif direction.y < 0.0:
		_walk_direction = "rear"
		_current_flip_h = direction.x < 0.0
	else:
		_walk_direction = "front"
		_current_flip_h = direction.x > 0.0
	_walk_frames = VISUALS.walk_cycle(_walk_direction)
	_walk_frame_index = 0
	_walk_clock = 0.0
	if _visual != null:
		_visual.texture = _walk_frames[0]
	_current_pose_id = "walk_%s_0" % _walk_direction


func _apply_default_pose() -> void:
	if not _context_pose_id.is_empty():
		if _visual != null:
			_visual.texture = VISUALS.player_combat("combat_ready")
		_current_pose_id = _context_pose_id
		return
	_apply_idle_pose(default_pose_id, default_flip_h)


func _apply_idle_pose(pose_id: String, flip_h: bool) -> void:
	if _visual == null:
		return
	var resolved_id := pose_id if _idle_cache.has(pose_id) else "idle_right_3q"
	_visual.texture = _idle_cache[resolved_id]
	_current_pose_id = resolved_id
	_current_flip_h = flip_h


func _action_texture(frame_id: String) -> Texture2D:
	var parts := frame_id.split(":", false, 1)
	if parts.size() == 2 and parts[0] == "combat":
		return VISUALS.player_combat(parts[1])
	return VISUALS.player_motion(parts[1] if parts.size() == 2 else frame_id)


func _update_action(delta: float) -> void:
	_action_clock += delta
	if _action_clock < _action_frame_time:
		return
	_action_clock = fmod(_action_clock, _action_frame_time)
	_action_frame_index += 1
	if _action_frame_index >= _action_frames.size():
		var finished_id := _action_id
		_cancel_action()
		_apply_default_pose()
		action_finished.emit(finished_id)
		return
	_apply_action_frame()


func _apply_action_frame() -> void:
	if _visual == null or _action_frames.is_empty():
		return
	_visual.texture = _action_frames[_action_frame_index]
	_current_pose_id = "%s_%d" % [_action_id, _action_frame_index]


func _cancel_action() -> void:
	_action_id = ""
	_action_frames.clear()
	_action_frame_index = 0
	_action_clock = 0.0


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
