extends SceneTree

const REQUIRED_RESOURCES := [
	"res://autoload/scene_router.gd",
	"res://ui/menus/main_menu.tscn",
	"res://core/game_shell/game_shell.tscn",
	"res://rooms/ch01/test_room.tscn",
]


func _init() -> void:
	var failures: Array[String] = []

	if ProjectSettings.get_setting("display/window/size/viewport_width") != 640:
		failures.append("viewport width is not 640")
	if ProjectSettings.get_setting("display/window/size/viewport_height") != 480:
		failures.append("viewport height is not 480")
	if ProjectSettings.get_setting("rendering/renderer/rendering_method") != "gl_compatibility":
		failures.append("renderer is not gl_compatibility")
	if not ProjectSettings.has_setting("autoload/SceneRouter"):
		failures.append("SceneRouter autoload missing")

	for path in REQUIRED_RESOURCES:
		var resource := load(path)
		if resource == null:
			failures.append("failed to load %s" % path)

	if failures.is_empty():
		print("SMOKE_OK: bootstrap resources load and project settings are valid")
		quit(0)
		return

	for failure in failures:
		push_error("SMOKE_FAIL: %s" % failure)
	quit(1)
