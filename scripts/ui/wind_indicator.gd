class_name WindIndicator
extends Control
## Draws an arrow pointing where the wind blows the ball: left / right for the
## crosswind, up the screen for a tailwind (downfield), down for a headwind.
## Length and color follow the wind's total strength.

@export var calm_color: Color = Color(1.0, 1.0, 1.0, 0.5)
@export var light_color: Color = Color(1.0, 1.0, 1.0)
@export var strong_color: Color = Color(1.0, 0.55, 0.1)

var mph: float = 0.0
## Tailwind (+) / headwind (-), mph.
var along: float = 0.0
var max_mph: float = 20.0


func set_wind(new_mph: float, new_max: float, new_along: float = 0.0) -> void:
	mph = new_mph
	along = new_along
	max_mph = maxf(new_max, 0.01)
	queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var v := Vector2(mph, -along)  # screen: tailwind points up (downfield)
	if v.length() < 0.5:
		draw_circle(c, minf(size.y * 0.18, 10.0), calm_color)
		return
	var strength := clampf(v.length() / max_mph, 0.0, 1.0)
	var col := light_color.lerp(strong_color, strength)
	var dir := v.normalized()
	# Room along the arrow: the box is wide and short, so an up/down arrow is shorter.
	var room := Vector2(size.x * 0.48, size.y * 0.48)
	var reach := 1.0 / maxf(absf(dir.x) / room.x, absf(dir.y) / room.y)
	var half_len := lerpf(0.42, 1.0, strength) * reach
	var head := minf(minf(size.y * 0.45, 22.0), half_len * 0.9)
	var tail := c - dir * half_len
	var tip := c + dir * half_len
	var neck := tip - dir * head
	var side := Vector2(-dir.y, dir.x) * head * 0.7
	draw_line(tail, neck, col, lerpf(4.0, 9.0, strength), true)
	draw_colored_polygon(PackedVector2Array([tip, neck + side, neck - side]), col)
