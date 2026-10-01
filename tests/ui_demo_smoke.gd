extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var state := root.get_node_or_null("GameState")
	if state == null:
		failures.append("GameState autoload unavailable")
		_finish()
		return

	state.call("pause_session")
	state.set("background_id", "sentinel_background")
	state.set("clues", {"sentinel": {"detail_level": 1}})
	state.set("chapter_flags", {"sentinel_flag": true})

	var menu_scene := load("res://ui/menus/main_menu.tscn") as PackedScene
	if menu_scene == null:
		failures.append("main menu failed to load")
	else:
		var menu := menu_scene.instantiate()
		root.add_child(menu)
		await process_frame
		if menu.find_child("DemoButton", true, false) == null:
			failures.append("main menu is missing the non-canon Umbrella visual slice button")
		menu.queue_free()

	var demo_scene := load("res://ui/demo/ui_demo.tscn") as PackedScene
	if demo_scene == null:
		failures.append("UI demo scene failed to load")
		_finish()
		return

	var demo := demo_scene.instantiate()
	root.add_child(demo)
	await process_frame

	var background_choices := demo.find_child("BackgroundChoices", true, false)
	if background_choices == null or background_choices.get_child_count() != 4:
		failures.append("Umbrella Quest does not expose four fixed background choices")
	if not bool(demo.call("_choose_demo_background", "watcher")):
		failures.append("Umbrella Quest could not apply a demo-local background")

	for node_name in [
		"RoomHost",
		"ArtBackground",
		"PlayerActor",
		"Hotspots",
		"NotebookPanel",
		"CharacterPanel",
		"BackgroundOverlay",
		"DialoguePanel",
		"CombatOverlay",
		"NoteButton",
		"EvidenceButton",
		"CharacterButton",
		"SaveButton",
		"LoadButton",
		"ExitButton"
	]:
		if demo.find_child(node_name, true, false) == null:
			failures.append("UI demo missing required control: %s" % node_name)

	var art_background := demo.find_child("ArtBackground", true, false)
	if art_background == null or art_background.get("texture") == null:
		failures.append("visual reference room background art is missing")
	var player_sprite := demo.find_child("Sprite", true, false)
	if player_sprite == null or player_sprite.get("texture") == null:
		failures.append("visual reference player sprite is missing")
	var portrait := demo.find_child("DialoguePortrait", true, false)
	if portrait == null or portrait.get("texture") == null:
		failures.append("dialogue portrait art is missing")
	var combat_visual := demo.find_child("CombatOpponentVisual", true, false)
	if combat_visual == null or combat_visual.get("texture") == null:
		failures.append("combat opponent art is missing")
	if demo.get("theme") == null:
		failures.append("comic-noir UI theme is not applied")

	var hotspots := demo.find_child("Hotspots", true, false)
	if hotspots == null or hotspots.get_child_count() < 5:
		failures.append("UI demo does not expose the expected hotspot set")
	else:
		demo.call("_set_reveal", true)
		for hotspot in hotspots.get_children():
			if hotspot.has_method("is_reveal_active") and not bool(hotspot.call("is_reveal_active")):
				failures.append("hotspot reveal did not propagate to %s" % hotspot.name)
		demo.call("_set_reveal", false)

	var notebook := demo.find_child("NotebookPanel", true, false)
	var character := demo.find_child("CharacterPanel", true, false)
	var dialogue := demo.find_child("DialoguePanel", true, false)

	demo.call("_open_notebook", "evidence")
	if notebook == null or not notebook.visible:
		failures.append("demo notebook did not open")
	demo.call("_open_character")
	if character == null or not character.visible or (notebook != null and notebook.visible):
		failures.append("demo character panel did not open exclusively")
	demo.call("_open_dialogue", "alex")
	if dialogue == null or not dialogue.visible or (character != null and character.visible):
		failures.append("demo dialogue panel did not open exclusively")
	demo.call("_close_all_modals")

	if hotspots != null:
		var rack := hotspots.find_child("UmbrellaRack", false, false)
		if rack == null:
			failures.append("umbrella rack hotspot missing")
		else:
			demo.call("_on_demo_hotspot_activated", rack)
			var demo_clues: Dictionary = demo.get("_demo_clues")
			if not demo_clues.has("dry_outline"):
				failures.append("demo hotspot did not add sandbox evidence")

	demo.call("_demo_save")
	var saved_foot: Vector2 = demo.get("_saved_foot")
	if saved_foot == Vector2.ZERO:
		failures.append("demo save did not capture player position")
	demo.call("_demo_load")

	if String(state.get("background_id")) != "sentinel_background":
		failures.append("UI demo mutated canonical background state")
	var story_clues: Dictionary = state.get("clues")
	if not story_clues.has("sentinel") or story_clues.size() != 1:
		failures.append("UI demo mutated canonical clue state")
	var story_flags: Dictionary = state.get("chapter_flags")
	if not bool(story_flags.get("sentinel_flag", false)):
		failures.append("UI demo mutated canonical chapter flags")

	demo.queue_free()
	_finish()


func _finish() -> void:
	if failures.is_empty():
		print("UMBRELLA_VISUAL_OK: multi-room launch, controls, modals, hotspots, reveal, local save/load, and canon isolation are valid")
		quit(0)
		return

	for failure in failures:
		push_error("UI_DEMO_FAIL: %s" % failure)
	quit(1)
