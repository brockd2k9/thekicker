class_name Ball
extends Node3D
## Simple ballistic football: gravity + constant wind, no drag.
## Custom integration (not RigidBody3D) so every kick is predictable and
## every number is tunable. The model (pointed football + laces) is generated
## in code and shaded procedurally, so there are no art files.

## Fired once, with the exact point where the ball crossed the uprights' plane.
signal reached_goal_plane(crossing: Vector3)
## Fired once, the first time the ball touches the ground.
signal landed(at: Vector3)

const BALL_SHADER := preload("res://shaders/ball.gdshader")
## Real football size (m), before visual scaling.
const LENGTH := 0.28
const BASE_RADIUS := 0.085
## Height of the ball's bottom tip above the turf (0 = held on the ground).
const HOLD_HEIGHT := 0.0
## How far the ball must travel before it shrinks to its far visual scale (m).
const SCALE_BLEND_DISTANCE := 15.0
## Tilt on the hold: nearly upright, laces facing the posts ("laces out").
## Use a positive angle to turn the laces toward the kicker instead.
const HOLD_TILT_DEG := -80.0

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
var _spot := Vector3.ZERO
var _near_scale := 1.0
var _far_scale := 1.0

@onready var _model: Node3D = $Model
@onready var _shadow: Node3D = $Shadow


func _ready() -> void:
	_build_model()


## Big near the camera for readability, smaller once it's downfield so it
## doesn't dwarf the posts.
func set_visual_scales(near: float, far: float) -> void:
	_near_scale = near
	_far_scale = far
	_apply_visual_scale()


func reset(spot: Vector3) -> void:
	_spot = spot
	in_flight = false
	velocity = Vector3.ZERO
	_crossed = false
	_has_landed = false
	set_pose(hold_position(), hold_rotation())


## Where the ball's center sits when held on the spot.
func hold_position() -> Vector3:
	var tilt := deg_to_rad(absf(HOLD_TILT_DEG))
	var stand_height := (LENGTH * 0.5 * sin(tilt) + BASE_RADIUS * cos(tilt)) * _near_scale * 0.92
	return _spot + Vector3(0.0, HOLD_HEIGHT + stand_height, 0.0)


## Model rotation when held on the spot.
func hold_rotation() -> Vector3:
	return Vector3(deg_to_rad(HOLD_TILT_DEG), 0.0, 0.0)


## Place the (not flying) ball anywhere, e.g. during the snap animation.
func set_pose(pos: Vector3, model_rotation: Vector3) -> void:
	global_position = pos
	_model.rotation = model_rotation
	_apply_visual_scale()
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


## Wind can change mid-flight (gusts). Ignored once the ball has landed.
func set_wind_accel(accel: Vector3) -> void:
	if in_flight and not _has_landed:
		_wind_accel = accel


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
	_apply_visual_scale()
	_update_shadow()

	# Emit after moving so listeners see the up-to-date ball.
	if crossed_now:
		reached_goal_plane.emit(crossing_point)
	if landed_now:
		landed.emit(next)


func _apply_visual_scale() -> void:
	var travel := Vector2(global_position.x - _spot.x, global_position.z - _spot.z).length()
	var s := lerpf(_near_scale, _far_scale, clampf(travel / SCALE_BLEND_DISTANCE, 0.0, 1.0))
	_model.scale = Vector3.ONE * s
	_ground_y = BASE_RADIUS * s


func _update_shadow() -> void:
	var h := global_position.y
	_shadow.global_position = Vector3(global_position.x, 0.015, global_position.z)
	var s := clampf(1.0 - h / 25.0, 0.35, 1.0) * _model.scale.x
	_shadow.scale = Vector3(s, 1.0, s * 1.4)


# --- model ----------------------------------------------------------------------

func _build_model() -> void:
	var body := MeshInstance3D.new()
	body.mesh = _make_ball_mesh(36, 28)
	var mat := ShaderMaterial.new()
	mat.shader = BALL_SHADER
	mat.set_shader_parameter("ball_length", LENGTH)
	mat.set_shader_parameter("ball_radius", BASE_RADIUS)
	body.material_override = mat
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_model.add_child(body)

	# Laces on the top panel (+Y): a center strip plus cross stitches.
	var lace_mat := StandardMaterial3D.new()
	lace_mat.albedo_color = Color(0.97, 0.96, 0.92)
	lace_mat.roughness = 0.8
	var stitch := BoxMesh.new()
	stitch.size = Vector3(0.026, 0.005, 0.0065)
	stitch.material = lace_mat
	var strip := BoxMesh.new()
	strip.size = Vector3(0.006, 0.0045, 0.0125)
	strip.material = lace_mat
	for k in 9:
		var z := -0.044 + k * 0.011
		var slope := (_profile(z + 0.0005) - _profile(z - 0.0005)) / 0.001
		var tilt := Vector3(-atan(slope), 0.0, 0.0)
		var pos := Vector3(0.0, _profile(z) + 0.0015, z)
		for m in [stitch, strip]:
			var mi := MeshInstance3D.new()
			mi.mesh = m
			mi.position = pos
			mi.rotation = tilt
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_model.add_child(mi)


## Radius of the football at position z along its long axis: pointed ends.
static func _profile(z: float) -> float:
	var s := 2.0 * z / LENGTH
	return BASE_RADIUS * pow(maxf(1.0 - s * s, 0.0), 0.75)


## Surface of revolution around Z. UV.x = around, UV.y = along.
static func _make_ball_mesh(segments: int, rings: int) -> ArrayMesh:
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for i in rings + 1:
		var t := float(i) / rings
		var z := (t - 0.5) * LENGTH
		var r := _profile(z)
		var dr := (_profile(z + 0.0005) - _profile(z - 0.0005)) / 0.001
		for j in segments + 1:
			var a := TAU * float(j) / segments
			var dir := Vector3(cos(a), sin(a), 0.0)
			verts.append(dir * r + Vector3(0.0, 0.0, z))
			normals.append((dir - Vector3(0.0, 0.0, dr)).normalized())
			uvs.append(Vector2(float(j) / segments, t))
	for i in rings:
		for j in segments:
			var a0 := i * (segments + 1) + j
			var b0 := a0 + segments + 1
			for idx in [a0, b0, a0 + 1, a0 + 1, b0, b0 + 1]:
				indices.append(idx)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
