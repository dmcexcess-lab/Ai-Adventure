extends RefCounted
class_name UmbrellaVisualCatalog

const REGIONS := preload("res://art/demo/atlas_regions.gd")
const PC3_WALK: Texture2D = preload("res://art/characters/pc3/pc3_walk.png")
const PC3_MOTION: Texture2D = preload("res://art/characters/pc3/pc3_motion.png")
const PC3_COMBAT: Texture2D = preload("res://art/characters/pc3/pc3_combat.png")
const ALEX: Texture2D = preload("res://art/demo/cast/alex_atlas.png")
const MINA: Texture2D = preload("res://art/demo/cast/mina_atlas.png")
const INTRUDER: Texture2D = preload("res://art/demo/cast/intruder_atlas.png")
const EVIDENCE: Texture2D = preload("res://art/demo/objects/evidence_atlas.png")

const EVIDENCE_INDEX := {
	"case_request": 0,
	"forecast_board": 4,
	"dry_outline": 10,
	"ticket_47b": 1,
	"alex_statement": 3,
	"closing_log": 3,
	"cabinet_trace": 8,
	"shift_board": 4,
	"wet_property_policy": 3,
	"transfer_tag": 5,
	"fan_timer": 6,
	"mina_statement": 3,
	"mina_reason": 3,
	"rear_drying_rail": 11,
	"watcher_transfer_residue": 9,
	"analyst_service_timing": 6,
	"reader_protective_tell": 3,
	"anchor_exact_route": 5,
	"umbrella_recovered": 0,
}


static func walk_cycle(direction: String) -> Array[Texture2D]:
	return REGIONS.crops(PC3_WALK, REGIONS.WALK_ROWS.get(direction, REGIONS.WALK_ROWS["side"]))


static func player_motion(pose_id: String) -> Texture2D:
	return REGIONS.crop(PC3_MOTION, REGIONS.MOTION_CELLS.get(pose_id, REGIONS.MOTION_CELLS["idle"]))


static func player_combat(pose_id: String) -> Texture2D:
	return REGIONS.crop(PC3_COMBAT, REGIONS.COMBAT_CELLS.get(pose_id, REGIONS.COMBAT_CELLS["combat_ready"]))


static func witness_pose(witness_id: String, pose_id: String) -> Texture2D:
	var atlas := MINA if witness_id == "mina" else ALEX
	return REGIONS.crop(atlas, REGIONS.WITNESS_CELLS.get(pose_id, REGIONS.WITNESS_CELLS["idle"]))


static func witness_portrait(witness_id: String, expression: String = "portrait_idle") -> Texture2D:
	return witness_pose(witness_id, expression)


static func intruder_pose(pose_id: String) -> Texture2D:
	return REGIONS.crop(INTRUDER, REGIONS.INTRUDER_CELLS.get(pose_id, REGIONS.INTRUDER_CELLS["ready"]))


static func evidence_art(clue_id: String) -> Texture2D:
	var index := int(EVIDENCE_INDEX.get(clue_id, 3))
	return REGIONS.crop(EVIDENCE, REGIONS.EVIDENCE_CELLS[index])


static func recovered_umbrella() -> Texture2D:
	return REGIONS.crop(EVIDENCE, REGIONS.EVIDENCE_CELLS[0])


static func all_runtime_atlases() -> Array[Texture2D]:
	return [PC3_WALK, PC3_MOTION, PC3_COMBAT, ALEX, MINA, INTRUDER, EVIDENCE]
