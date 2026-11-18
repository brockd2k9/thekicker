class_name Ball
extends Node3D
## Simple ballistic football: gravity + constant wind, no drag.
## Custom integration (not RigidBody3D) so every kick is predictable and
## every number is tunable.

## Fired once, with the exact point where the ball crossed the uprights' plane.
signal reached_goal_plane(crossing: Vector3)
## Fired once, the first time the ball touches the ground.
signal landed(at: Vector3)

## Physical ball half-thickness (m), before visual scaling.
const BASE_RADIUS := 0.085
const TEE_HEIGHT := 0.05

var velocity := Vector3.ZERO
var in_flight := false

var _gravity := 9.8
var _wind_accel := Vector3.ZERO
var _sim_scale := 1.0
var _goal_z := -INF
var _spin := 0.0
var _crossed := false
var _has_landed := false
var _ground_y := BASE_RADIUS

@onready var _model: Node3D = $Model
@onready var _shadow: Node3D = $Shadow


func set_visual_scale(s: float) -> void:
	_model.scale = Vector3.ONE * s
	_ground_y = BASE_RADIUS * s


func reset(spot: Vector3) -> void:
	in_flight = false
	velocity = Vector3.ZERO
	_crossed = false
	_has_landed = false
	global_position = spot + Vector3(0.0, _ground_y + TEE_HEIGHT, 0.0)
	_model.rotation = Vector3(deg_to_rad(15.0), 0.0, 0.0)  # tilted back on the tee
	_update_shadow()


## goal_z: world Z of the uprights' plane (negative, in front of the kicker).
func launch(v: Vector3, gravity: float, wind_accel: Vector3, sim_scale: float,
		goal_z: float, spin: float) -> void:
	velocity = v
	_gravity = gravity
	_wind_accel = wind_accel
	_sim_scale = sim_scale
	_goal_z = goal_z
	_spin = spin
	_crossed = false
	_has_landed = false
	in_flight = true


func _physics_process(delta: float) -> void:
	if not in_flight:
		return
	var dt := delta * _sim_scale
	var prev := global_position
	velocity += (Vector3.DOWN * _gravity + _wind_accel) * dt
	var next := prev + velocity * dt

	var crossing_point := Vector3.ZERO
	var crossed_now := false
	if not _crossed and prev.z > _goal_z and next.z <= _goal_z:
		var t := (prev.z - _goal_z) / (prev.z - next.z)
		crossing_point = prev.lerp(next, t)
		crossed_now = crossing_point.y > _ground_y
		_crossed = true

	var landed_now := false
	if next.y <= _ground_y:
		next.y = _ground_y
		if not _has_landed:
			_has_landed = true
			landed_now = true
			_wind_accel = Vector3.ZERO
		# Cheap bounce + roll-out.
		velocity.y = -velocity.y * 0.35
		velocity.x *= 0.6
		velocity.z *= 0.6
		_spin *= 0.5
		if velocity.length() < 0.6:
			in_flight = false

	global_position = next
	_model.rotate_object_local(Vector3.RIGHT, -_spin * dt)
	_update_shadow()

	# Emit after moving so listeners see the up-to-date ball.
	if crossed_now:
		reached_goal_plane.emit(crossing_point)
	if landed_now:
		landed.emit(next)


func _update_shadow() -> void:
	var h := global_position.y
	_shadow.global_position = Vector3(global_position.x, 0.015, global_position.z)
	var s := clampf(1.0 - h / 25.0, 0.35, 1.0) * _model.scale.x
	_shadow.scale = Vector3(s, 1.0, s * 1.4)
