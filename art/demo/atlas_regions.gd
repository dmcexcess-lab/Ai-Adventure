extends RefCounted
class_name UmbrellaAtlasRegions

const WALK_ROWS := {
	"side": [Rect2(0, 0, 314, 418), Rect2(314, 0, 313, 418), Rect2(627, 0, 314, 418), Rect2(941, 0, 313, 418)],
	"front": [Rect2(0, 418, 314, 418), Rect2(314, 418, 313, 418), Rect2(627, 418, 314, 418), Rect2(941, 418, 313, 418)],
	"rear": [Rect2(0, 836, 314, 418), Rect2(314, 836, 313, 418), Rect2(627, 836, 314, 418), Rect2(941, 836, 313, 418)],
}

const MOTION_CELLS := {
	"idle": Rect2(0, 941, 209, 313),
	"dialogue": Rect2(209, 941, 209, 313),
	"read": Rect2(418, 941, 209, 313),
	"inspect": Rect2(627, 941, 209, 313),
	"pick_up": Rect2(836, 941, 209, 313),
	"show_clue": Rect2(1045, 941, 209, 313),
}

const COMBAT_CELLS := {
	"combat_ready": Rect2(0, 0, 418, 418),
	"strike_windup": Rect2(418, 0, 418, 418),
	"strike": Rect2(836, 0, 418, 418),
	"recover": Rect2(0, 418, 418, 418),
	"guard": Rect2(418, 418, 418, 418),
	"maneuver": Rect2(836, 418, 418, 418),
	"hurt": Rect2(0, 836, 418, 418),
	"disengage": Rect2(418, 836, 418, 418),
	"portrait": Rect2(836, 836, 418, 418),
}

const WITNESS_CELLS := {
	"idle": Rect2(0, 0, 418, 627),
	"talking": Rect2(418, 0, 418, 627),
	"thoughtful": Rect2(836, 0, 418, 627),
	"portrait_idle": Rect2(0, 627, 418, 627),
	"portrait_talking": Rect2(418, 627, 418, 627),
	"portrait_thoughtful": Rect2(836, 627, 418, 627),
}

const INTRUDER_CELLS := {
	"ready": Rect2(0, 0, 384, 512),
	"advance": Rect2(384, 0, 384, 512),
	"strike": Rect2(768, 0, 384, 512),
	"guard": Rect2(1152, 0, 384, 512),
	"recoil": Rect2(0, 512, 384, 512),
	"hurt": Rect2(384, 512, 384, 512),
	"defeated": Rect2(768, 512, 384, 512),
	"portrait": Rect2(1152, 512, 384, 512),
}

const EVIDENCE_CELLS := [
	Rect2(0, 0, 362, 362), Rect2(362, 0, 362, 362), Rect2(724, 0, 362, 362), Rect2(1086, 0, 362, 362),
	Rect2(0, 362, 362, 362), Rect2(362, 362, 362, 362), Rect2(724, 362, 362, 362), Rect2(1086, 362, 362, 362),
	Rect2(0, 724, 362, 362), Rect2(362, 724, 362, 362), Rect2(724, 724, 362, 362), Rect2(1086, 724, 362, 362),
]


static func crop(atlas: Texture2D, region: Rect2) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = region
	texture.filter_clip = true
	return texture


static func crops(atlas: Texture2D, regions: Array) -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	for region_value in regions:
		textures.append(crop(atlas, region_value))
	return textures
