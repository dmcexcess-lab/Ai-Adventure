extends SceneTree

const REQUIRED_SCRIPTS := [
	"res://autoload/game_state.gd",
	"res://autoload/evidence_service.gd",
	"res://autoload/deduction_service.gd",
	"res://autoload/dialogue_service.gd",
	"res://autoload/skill_service.gd",
	"res://autoload/save_service.gd",
	"res://autoload/scene_router.gd",
	"res://ui/menus/main_menu.gd",
	"res://ui/demo/ui_demo.gd",
	"res://content/demo/umbrella_case.gd",
	"res://content/demo/umbrella_combat.gd",
	"res://core/combat/bounded_combat.gd",
	"res://rooms/demo/demo_room.gd",
	"res://rooms/demo/ambient_fx.gd",
	"res://core/game_shell/game_shell.gd",
	"res://core/interaction/room_controller.gd",
	"res://core/interaction/player_actor.gd",
	"res://core/interaction/hotspot.gd",
]

const REQUIRED_VISUALS := [
	"res://ui/theme/comic_noir_theme.tres",
	"res://art/demo/production/community_center_lobby_production.png",
	"res://art/demo/production/exterior_entry_production.png",
	"res://art/demo/production/front_desk_production.png",
	"res://art/demo/production/lost_found_hall_production.png",
	"res://art/demo/production/staff_office_production.png",
	"res://art/demo/production/storage_room_production.png",
	"res://art/demo/production/maintenance_corridor_production.png",
	"res://art/demo/production/loading_bay_production.png",
	"res://art/characters/pc3/pc3_reference_atlas.webp",
	"res://art/demo/alex_sprite_noir.svg",
	"res://art/demo/alex_portrait_noir.svg",
	"res://art/demo/mina_portrait_noir.svg",
	"res://art/demo/mina_sprite_noir.svg",
	"res://art/demo/combat_intruder_noir.svg",
]

const REQUIRED_ART_FILES := [
	"res://art/demo/community_center_lobby_noir.svg",
	"res://art/demo/exterior_entry_noir.svg",
	"res://art/demo/front_desk_noir.svg",
	"res://art/demo/lost_found_hall_noir.svg",
	"res://art/demo/staff_office_noir.svg",
	"res://art/demo/storage_room_noir.svg",
	"res://art/demo/maintenance_corridor_noir.svg",
	"res://art/demo/loading_bay_noir.svg",
	"res://art/demo/demo_player_noir.svg",
	"res://art/demo/alex_portrait_noir.svg",
	"res://art/demo/mina_portrait_noir.svg",
	"res://art/demo/mina_sprite_noir.svg",
	"res://art/demo/combat_intruder_noir.svg",
]

const REQUIRED_SCENES := [
	"res://ui/menus/main_menu.tscn",
	"res://ui/demo/ui_demo.tscn",
	"res://rooms/demo/exterior_entry.tscn",
	"res://rooms/demo/lobby.tscn",
	"res://rooms/demo/front_desk.tscn",
	"res://rooms/demo/lost_found_hall.tscn",
	"res://rooms/demo/staff_office.tscn",
	"res://rooms/demo/storage_room.tscn",
	"res://rooms/demo/maintenance_corridor.tscn",
	"res://rooms/demo/loading_bay.tscn",
	"res://core/game_shell/game_shell.tscn",
	"res://ui/notebook/evidence_notebook.tscn",
	"res://ui/dialogue/conversation_ui.tscn",
	"res://ui/character/character_panel.tscn",
	"res://rooms/ch01/test_room.tscn",
	"res://rooms/ch01/corridor_room.tscn",
]


func _init() -> void:
	var failures: Array[String] = []

	if ProjectSettings.get_setting("display/window/size/viewport_width") != 640:
		failures.append("viewport width is not 640")
	if ProjectSettings.get_setting("display/window/size/viewport_height") != 480:
		failures.append("viewport height is not 480")
	if ProjectSettings.get_setting("rendering/renderer/rendering_method") != "gl_compatibility":
		failures.append("renderer is not gl_compatibility")
	for autoload_name in ["GameState", "EvidenceService", "DeductionService", "DialogueService", "SkillService", "SaveService", "SceneRouter"]:
		if not ProjectSettings.has_setting("autoload/%s" % autoload_name):
			failures.append("%s autoload missing" % autoload_name)

	for path in REQUIRED_SCRIPTS:
		var script := load(path) as Script
		if script == null:
			failures.append("failed to load script %s" % path)
		elif not script.can_instantiate():
			failures.append("script cannot instantiate: %s" % path)

	for path in REQUIRED_VISUALS:
		if load(path) == null:
			failures.append("failed to load visual resource %s" % path)

	for path in REQUIRED_ART_FILES:
		if not FileAccess.file_exists(path):
			failures.append("missing visual art file %s" % path)
		elif FileAccess.get_file_as_string(path).is_empty():
			failures.append("visual art file is empty %s" % path)

	for path in REQUIRED_SCENES:
		var scene := load(path) as PackedScene
		if scene == null:
			failures.append("failed to load scene %s" % path)

	if failures.is_empty():
		print("SMOKE_OK: project settings, visual assets/theme, services, scripts, and room resources are valid")
		quit(0)
		return

	for failure in failures:
		push_error("SMOKE_FAIL: %s" % failure)
	quit(1)
