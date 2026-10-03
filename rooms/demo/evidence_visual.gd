extends TextureRect
class_name UmbrellaEvidenceVisual

const VISUALS := preload("res://art/demo/visual_catalog.gd")

@export var clue_id := "umbrella_recovered"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	texture = VISUALS.evidence_art(clue_id)
