class_name SwipeInput
extends Node
## Turns pointer input into swipes.
##
## Touch and mouse share ONE code path: project setting
## input_devices/pointing/emulate_mouse_from_touch = true makes Godot convert
## the first finger into mouse events, so this works on phones and on Steam
## (mouse) without branching. Uses _unhandled_input so future menu buttons
## (Phase 2) swallow their own clicks and never trigger a kick.

signal pressed(pos: Vector2)
signal dragged(pos: Vector2)
signal released(swipe: Swipe)

## Trailing window (real seconds) used to measure flick speed.
@export var flick_sample_window: float = 0.12
@export var enabled: bool = true

var _active := false
var _points := PackedVector2Array()
var _times := PackedFloat64Array()


func _unhandled_input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed:
			_begin(mb.position)
		elif _active:
			_finish(mb.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _active:
		var mm := event as InputEventMouseMotion
		_record(mm.position)
		dragged.emit(mm.position)


func _begin(pos: Vector2) -> void:
	_active = true
	_points.clear()
	_times.clear()
	_record(pos)
	pressed.emit(pos)


func _finish(pos: Vector2) -> void:
	_active = false
	_record(pos)
	var t_end: float = _times[_times.size() - 1]

	# Find the first sample inside the trailing flick window.
	var i := _times.size() - 1
	while i > 0 and t_end - _times[i - 1] <= flick_sample_window:
		i -= 1
	if i == _times.size() - 1 and i > 0:
		i -= 1  # always measure across at least one segment
	var dt := maxf(t_end - _times[i], 0.008)

	var s := Swipe.new()
	s.start = _points[0]
	s.end = pos
	s.duration = t_end - _times[0]
	s.flick_speed_px = _points[i].distance_to(pos) / dt
	s.screen_height = get_viewport().get_visible_rect().size.y
	released.emit(s)


func _record(pos: Vector2) -> void:
	_points.append(pos)
	_times.append(Time.get_ticks_usec() / 1_000_000.0)
