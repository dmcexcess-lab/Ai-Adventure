extends Control

@onready var start_button: Button = %StartButton
@onready var about_button: Button = %AboutButton
@onready var about_panel: PanelContainer = %AboutPanel
@onready var background_panel: PanelContainer = %BackgroundPanel
@onready var background_choices: VBoxContainer = %BackgroundChoices
@onready var background_back_button: Button = %BackgroundBackButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	about_button.pressed.connect(_on_about_pressed)
	background_back_button.pressed.connect(_close_backgrounds)
	_build_background_choices()
	start_button.grab_focus()


func _on_start_pressed() -> void:
	about_panel.visible = false
	background_panel.visible = true
	start_button.disabled = true
	about_button.disabled = true
	if background_choices.get_child_count() > 0:
		(background_choices.get_child(0) as Control).grab_focus()


func _on_about_pressed() -> void:
	about_panel.visible = not about_panel.visible


func _build_background_choices() -> void:
	for child in background_choices.get_children():
		child.queue_free()

	var skills := get_node_or_null("/root/SkillService")
	if skills == null:
		return

	for profile_value in skills.call("get_backgrounds"):
		if not profile_value is Dictionary:
			continue
		var profile: Dictionary = profile_value
		var button := Button.new()
		button.text = "“%s”\n%s" % [
			String(profile.get("sentence", "")),
			_profile_summary(profile.get("skills", {}))
		]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(0, 52)
		button.pressed.connect(_choose_background.bind(String(profile.get("id", ""))))
		background_choices.add_child(button)


func _profile_summary(raw_skills: Variant) -> String:
	if not raw_skills is Dictionary:
		return ""
	var values: Dictionary = raw_skills
	return "OBS %d  REA %d  EMP %d  RES %d" % [
		int(values.get("observation", 0)),
		int(values.get("reasoning", 0)),
		int(values.get("empathy", 0)),
		int(values.get("resolve", 0))
	]


func _choose_background(background_id: String) -> void:
	var router := get_node_or_null("/root/SceneRouter")
	if router != null:
		router.call("start_new_game", background_id)


func _close_backgrounds() -> void:
	background_panel.visible = false
	start_button.disabled = false
	about_button.disabled = false
	start_button.grab_focus()
