class_name KickCamera
extends Camera3D
## Low behind-the-ball camera with a long lens: the ball sits big in the lower
## third, the posts sit big in the middle. Partial follow during flight + shake.
## Uses KEEP_WIDTH so the framing is the same on tall phones and wide monitors.

## Camera position relative to the ball spot.
@export var home_offset: Vector3 = Vector3(0.0, 1.0, 2.2)
## How far below level the camera looks (degrees). Raises/lowers the posts on screen.
@export var look_down_deg: float = 2.0

var _spot := Vector3.ZERO
var _home_look := Vector3.ZERO
var _target: Node3D
var _strength := 0.0
var _speed := 3.0
var _pos := Vector3.ZERO
var _look := Vector3.ZERO
var _shake := 0.0


func _ready() -> void:
	keep_aspect = Camera3D.KEEP_WIDTH


## Snap back to the home framing for a kick of `distance_m`.
func reset_to(spot: Vector3, distance_m: float) -> void:
	_spot = spot
	_target = null
	_strength = 0.0
	_shake = 0.0
	var drop := tan(deg_to_rad(look_down_deg)) * (distance_m + home_offset.z)
	_home_look = spot + Vector3(0.0, home_offset.y - drop, -distance_m)
	_pos = spot + home_offset
	_look = _home_look
	_apply()


func follow(target: Node3D, strength: float, speed: float) -> void:
	_target = target
	_strength = strength
	_speed = speed


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func _process(delta: float) -> void:
	var want_pos := _spot + home_offset
	var want_look := _home_look
	if _target != null and _strength > 0.0:
		var tp := _target.global_position
		var travel := tp - _spot
		# Ease in so the view doesn't dip toward the ball at the moment of contact.
		var f := _strength * clampf(travel.length() / 6.0, 0.0, 1.0)
		want_pos += Vector3(travel.x * 0.5, travel.y * 0.3, travel.z) * f
		want_look = want_look.lerp(tp, f)
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
