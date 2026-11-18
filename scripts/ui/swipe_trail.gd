class_name SwipeTrail
extends Control
## Draws the finger/mouse path while swiping, then fades it out.

@export var color: Color = Color(1.0, 1.0, 1.0, 0.8)
@export var width: float = 10.0
@export var fade_per_second: float = 2.5

var _points := PackedVector2Array()
var _alpha := 0.0
var _fading := false


func begin(pos: Vector2) -> void:
	_points = PackedVector2Array([pos])
	_alpha = 1.0
	_fading = false
	queue_redraw()


func add(pos: Vector2) -> void:
	if _fading:
		return
	_points.append(pos)
	queue_redraw()


func finish() -> void:
	_fading = true


func _process(delta: float) -> void:
	if _fading and _alpha > 0.0:
		_alpha = maxf(_alpha - delta * fade_per_second, 0.0)
		queue_redraw()


func _draw() -> void:
	if _points.size() < 2 or _alpha <= 0.0:
		return
	var c := color
	c.a *= _alpha
	draw_polyline(_points, c, width, true)
