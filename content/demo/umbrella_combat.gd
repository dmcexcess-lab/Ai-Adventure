extends RefCounted


func get_loading_bay_encounter() -> Dictionary:
	return {
		"id": "loading_bay_scuffle",
		"room_path": "res://rooms/demo/loading_bay.tscn",
		"trigger_deduction": "mina_service_route",
		"opponent_name": "SOAKED TRESPASSER",
		"opening": "The rear service door slams inward. A soaked trespasser, startled to find you blocking the narrow bay, swings a heavy flashlight and tries to force past.",
		"player_condition": 8,
		"opponent_condition": 6,
		"strike_damage": 2,
		"guard_value": 2,
		"maneuver_leverage": 1,
		"max_leverage": 3,
		"disengage_threshold": 3,
		"failure_consequence": "bruised_ribs",
		"intents": [
			{"name": "RUSH", "damage": 3},
			{"name": "FLASHLIGHT SWING", "damage": 2},
			{"name": "SHOVE", "damage": 2},
		],
	}
