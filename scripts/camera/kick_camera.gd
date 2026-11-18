class_name KickCamera
extends Camera3D
## Behind-the-ball camera with a partial follow during flight and a little shake.
## Uses KEEP_WIDTH so the posts frame the same on tall phones and wide monitors.

## Camera position relative to the ball spot.
@export var home_offset: Vector3 = Vector3(0.0, 2.2, 5.5)
## Point the camera looks at, relative to the ball spot.
@export var home_look: Vector3 = Vector3(0.0, 3.5, -30.0)

var _spot := Vector3.ZERO
var _target: Node3D
var _strength := 0.0
var _speed := 3.0
var _pos := Vector3.ZERO
var _look := Vector3.ZERO
var _shake := 0.0


func _ready() -> void:
	keep_aspect = Camera3D.KEEP_WIDTH


## Snap back to the home framing instantly.
func reset_to(spot: Vector3) -> void:
	_spot = spot
	_target = null
	_strength = 0.0
	_shake = 0.0
	_pos = spot + home_offset
	_look = spot + home_look
	_apply()


func follow(target: Node3D, strength: float, speed: float) -> void:
	_target = target
	_strength = strength
	_speed = speed


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func _process(delta: float) -> void:
	var want_pos := _spot + home_offset
	var want_look := _spot + home_look
	if _target != null and _strength > 0.0:
		var tp := _target.global_position
		var travel := tp - _spot
		want_pos += Vector3(travel.x * 0.5, travel.y * 0.3, travel.z) * _strength
		want_look = want_look.lerp(tp, _strength)
	var k := 1.0 - exp(-_speed * delta)
	_pos = _pos.lerp(want_pos, k)
	_look = _look.lerp(want_look, k)
	_shake = move_toward(_shake, 0.0, delta * 0.6)
	_apply()


func _apply() -> void:
	var jitter := Vector3.ZERO
	if _shake > 0.0:
		jitter = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * _shake
	global_position = _pos + jitter
	look_at(_look, Vector3.UP)
