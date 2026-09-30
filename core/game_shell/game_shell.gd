extends Control

@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	SceneRouter.attach_room_host(%RoomHost)
	SceneRouter.go_to_room(SceneRouter.FIRST_TEST_ROOM)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu_back"):
		SceneRouter.return_to_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("notebook"):
		_show_placeholder("NOTEBOOK — evidence system arrives in Slice 5")
	elif event.is_action_pressed("evidence"):
		_show_placeholder("EVIDENCE — case file scaffold online")
	elif event.is_action_pressed("character"):
		_show_placeholder("CHARACTER — RPG layer arrives in Slice 8")
	elif event.is_action_pressed("reveal_hotspots"):
		_show_placeholder("HOTSPOTS — reveal action registered")


func _show_placeholder(message: String) -> void:
	status_label.text = message
