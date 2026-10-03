extends TextureRect
class_name UmbrellaWitnessVisual

const VISUALS := preload("res://art/demo/visual_catalog.gd")

@export_enum("alex", "mina") var witness_id := "alex"
@export_enum("idle", "talking", "thoughtful") var pose_id := "idle"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	show_pose(pose_id)


func show_pose(next_pose_id: String) -> void:
	pose_id = next_pose_id if ["idle", "talking", "thoughtful"].has(next_pose_id) else "idle"
	texture = VISUALS.witness_pose(witness_id, pose_id)


func show_talking(active: bool) -> void:
	show_pose("talking" if active else "idle")
