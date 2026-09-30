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
	"res://core/game_shell/game_shell.gd",
	"res://core/interaction/room_controller.gd",
	"res://core/interaction/player_actor.gd",
	"res://core/interaction/hotspot.gd",
]

const REQUIRED_SCENES := [
	"res://ui/menus/main_menu.tscn",
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

	for path in REQUIRED_SCENES:
		var scene := load(path) as PackedScene
		if scene == null:
			failures.append("failed to load scene %s" % path)

	if failures.is_empty():
		print("SMOKE_OK: project settings, evidence/deduction/dialogue/RPG/persistence services, scripts, and room resources are valid")
		quit(0)
		return

	for failure in failures:
		push_error("SMOKE_FAIL: %s" % failure)
	quit(1)
