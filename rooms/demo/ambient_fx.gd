extends Control
class_name DemoAmbientFX

@export var rain_rect := Rect2()
@export var glow_rect := Rect2()
@export var rain_density := 18
@export var rain_speed := 150.0
@export var glow_strength := 0.035

var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func _process(delta: float) -> void:
	_time = fmod(_time + delta, 1000.0)
	queue_redraw()


func _draw() -> void:
	_draw_rain()
	_draw_practical_glow()


func _draw_rain() -> void:
	if rain_rect.size.x <= 0.0 or rain_rect.size.y <= 0.0 or rain_density <= 0:
		return
	var tint := Color(0.60, 0.78, 0.84, 0.22)
	for index in range(rain_density):
		var x := fmod(float(index * 41) + _time * rain_speed, rain_rect.size.x + 34.0) - 17.0
		var y := fmod(float(index * 67) + _time * rain_speed * 1.31, rain_rect.size.y + 46.0) - 23.0
		var start := rain_rect.position + Vector2(x, y)
		var finish := start + Vector2(-7.0, 24.0)
		draw_line(start, finish, tint, 1.25, true)


func _draw_practical_glow() -> void:
	if glow_rect.size.x <= 0.0 or glow_rect.size.y <= 0.0 or glow_strength <= 0.0:
		return
	var pulse := clampf(0.72 + sin(_time * 2.6) * 0.18 + sin(_time * 10.7) * 0.07, 0.45, 1.0)
	draw_rect(glow_rect, Color(0.88, 0.62, 0.33, glow_strength * pulse), true)
