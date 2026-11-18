class_name KickPad
extends Control
## Sideline swipe pad (placeholder art drawn in code): a strip of field with a
## ball on a tee, for kickoffs and onside kicks, or the warmup net.
## Swipes are measured like the kick scene's SwipeInput (screen heights, flick
## speed over the last FLICK_WINDOW seconds) and handed out as a Swipe, so
## the same KickController math reads them. The screen judges the kick
## (SidelineKick) and calls fly() to animate it.

signal swiped(swipe: Swipe)
signal flight_done

enum Kind { KICKOFF, ONSIDE, NET }

const FLICK_WINDOW := 0.12
const GRASS := Color(0.16, 0.45, 0.2)
const GRASS_DARK := Color(0.13, 0.39, 0.17)
const LINE := Color(1, 1, 1, 0.55)
const BALL := Color(0.55, 0.3, 0.12)
const NET := Color(0.85, 0.85, 0.9, 0.8)

var kind: Kind = Kind.KICKOFF
## Yards shown from the tee to the top edge (kickoff / onside).
var yards_shown := 70.0
## Kickoff: carry (yards) that reaches the goal line; the end zone is shaded past it.
var goal_line_yards := 0.0
## Onside: the target window (yards), shaded. 0/0 = none.
var target_min_yards := 0.0
var target_max_yards := 0.0
var accepting := true

var _points := PackedVector2Array()
var _times := PackedFloat64Array()
var _ball := Vector2.ZERO
var _ball_scale := 1.0
var _flying := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	resized.connect(_reset_ball)
	_reset_ball()


func _reset_ball() -> void:
	_ball = tee()
	_ball_scale = 1.0
	queue_redraw()


func tee() -> Vector2:
	return Vector2(size.x * 0.5, size.y - 70.0)


func reset() -> void:
	_flying = false
	accepting = true
	_points.clear()
	_reset_ball()


## Animate the ball: carry in yards (kickoff/onside) or 0..1 of the way to the
## net; aim in degrees (+ = right).
func fly(carry: float, aim_deg: float) -> void:
	_flying = true
	accepting = false
	var dist_px: float
	if kind == Kind.NET:
		dist_px = (tee().y - size.y * 0.22) * clampf(carry, 0.0, 1.0)
	else:
		dist_px = (tee().y - 20.0) * clampf(carry / yards_shown, 0.0, 1.05)
	var dir := Vector2(sin(deg_to_rad(aim_deg)), -cos(deg_to_rad(aim_deg)))
	var target := tee() + dir * dist_px
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_method(func(p: Vector2) -> void:
		_ball = p
		queue_redraw(), tee(), target, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(s: float) -> void:
		_ball_scale = s, 1.0, 0.55, 0.9)
	tw.chain().tween_callback(func() -> void:
		_flying = false
		flight_done.emit())


func _gui_input(event: InputEvent) -> void:
	if not accepting or _flying:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_points.clear()
			_times.clear()
			_record(event.position)
		elif not _points.is_empty():
			_record(event.position)
			var s := _make_swipe()
			_points.clear()
			queue_redraw()
			swiped.emit(s)
		accept_event()
	elif event is InputEventMouseMotion and not _points.is_empty():
		_record(event.position)
		queue_redraw()


func _record(p: Vector2) -> void:
	_points.append(p)
	_times.append(Time.get_ticks_usec() / 1_000_000.0)


## Same measurement as SwipeInput._finish().
func _make_swipe() -> Swipe:
	var n := _points.size()
	var t_end: float = _times[n - 1]
	var i := n - 1
	while i > 0 and t_end - _times[i - 1] <= FLICK_WINDOW:
		i -= 1
	if i == n - 1 and i > 0:
		i -= 1
	var dt := maxf(t_end - _times[i], 0.008)
	var s := Swipe.new()
	s.start = _points[0]
	s.end = _points[n - 1]
	s.duration = t_end - _times[0]
	s.flick_speed_px = _points[i].distance_to(_points[n - 1]) / dt
	s.screen_height = get_viewport().get_visible_rect().size.y
	return s


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), GRASS)
	var font := get_theme_default_font()
	if kind == Kind.NET:
		# Sideline: a few stripes and the practice net.
		for y in range(0, int(size.y), 80):
			draw_rect(Rect2(0, y, size.x, 40), GRASS_DARK)
		var net := Rect2(size.x * 0.25, size.y * 0.08, size.x * 0.5, size.y * 0.22)
		draw_rect(net, Color(0, 0, 0, 0.25))
		for x in range(int(net.position.x), int(net.end.x) + 1, 18):
			draw_line(Vector2(x, net.position.y), Vector2(x, net.end.y), NET, 1.0)
		for y in range(int(net.position.y), int(net.end.y) + 1, 18):
			draw_line(Vector2(net.position.x, y), Vector2(net.end.x, y), NET, 1.0)
		draw_rect(net, Color.WHITE, false, 4.0)
	else:
		var px_per_yd := (tee().y - 20.0) / yards_shown
		if goal_line_yards > 0.0:
			var gy := tee().y - goal_line_yards * px_per_yd
			draw_rect(Rect2(0, 0, size.x, gy), Color(0.1, 0.2, 0.55, 0.55))
			draw_line(Vector2(0, gy), Vector2(size.x, gy), Color.WHITE, 5.0)
			draw_string(font, Vector2(0, gy * 0.5 + 12), "END ZONE  (touchback)", HORIZONTAL_ALIGNMENT_CENTER,
				size.x, 30, Color.WHITE)
		if target_max_yards > target_min_yards:
			var y0 := tee().y - target_max_yards * px_per_yd
			var y1 := tee().y - target_min_yards * px_per_yd
			draw_rect(Rect2(0, y0, size.x, y1 - y0), Color(1.0, 0.8, 0.25, 0.3))
			draw_string(font, Vector2(0, (y0 + y1) * 0.5 + 10), "ONSIDE TARGET", HORIZONTAL_ALIGNMENT_CENTER,
				size.x, 28, Color.WHITE)
		# Yard lines every 10 yards up from the tee.
		for yd in range(10, int(yards_shown) + 1, 10):
			var y := tee().y - yd * px_per_yd
			draw_line(Vector2(0, y), Vector2(size.x, y), LINE, 2.0)
			draw_string(font, Vector2(10, y - 6), "%d" % yd, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, LINE)
		draw_line(Vector2(24, 0), Vector2(24, size.y), Color.WHITE, 3.0)
		draw_line(Vector2(size.x - 24, 0), Vector2(size.x - 24, size.y), Color.WHITE, 3.0)
	# Tee and ball.
	draw_rect(Rect2(tee() + Vector2(-10, 14), Vector2(20, 10)), Color(1.0, 0.55, 0.1))
	var r := 22.0 * _ball_scale
	draw_set_transform(_ball, 0.0, Vector2(0.75, 1.0))
	draw_circle(Vector2.ZERO, r, BALL)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_line(_ball + Vector2(0, -r * 0.6), _ball + Vector2(0, r * 0.6), Color.WHITE, 2.0)
	# Swipe trail.
	if _points.size() > 1:
		draw_polyline(_points, Color(1, 1, 1, 0.7), 6.0, true)
