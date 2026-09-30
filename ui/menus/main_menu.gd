extends Control

@onready var start_button: Button = %StartButton
@onready var about_button: Button = %AboutButton
@onready var about_panel: PanelContainer = %AboutPanel


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	about_button.pressed.connect(_on_about_pressed)
	start_button.grab_focus()


func _on_start_pressed() -> void:
	SceneRouter.start_new_game()


func _on_about_pressed() -> void:
	about_panel.visible = not about_panel.visible
