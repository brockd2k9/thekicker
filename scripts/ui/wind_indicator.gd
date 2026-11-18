class_name WindIndicator
extends Control
## Draws a left/right arrow whose length and color follow wind strength.

@export var calm_color: Color = Color(1.0, 1.0, 1.0, 0.5)
@export var light_color: Color = Color(1.0, 1.0, 1.0)
@export var strong_color: Color = Color(1.0, 0.55, 0.1)

var mph: float = 0.0
var max_mph: float = 20.0


func set_wind(new_mph: float, new_max: float) -> void:
	mph = new_mph
	max_mph = maxf(new_max, 0.01)
	queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	if absf(mph) < 0.5:
		draw_circle(c, minf(size.y * 0.18, 10.0), calm_color)
		return
	var strength := clampf(absf(mph) / max_mph, 0.0, 1.0)
	var col := light_color.lerp(strong_color, strength)
	var dir := 1.0 if mph > 0.0 else -1.0
	var half_len := lerpf(0.2, 0.48, strength) * size.x
	var head := minf(size.y * 0.45, 22.0)
	var tail := Vector2(c.x - dir * half_len, c.y)
	var tip := Vector2(c.x + dir * half_len, c.y)
	var neck := Vector2(tip.x - dir * head, c.y)
	draw_line(tail, neck, col, lerpf(4.0, 9.0, strength), true)
	draw_colored_polygon(PackedVector2Array([
		tip,
		Vector2(neck.x, c.y - head * 0.7),
		Vector2(neck.x, c.y + head * 0.7),
	]), col)
