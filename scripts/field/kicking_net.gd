class_name KickingNet
extends Node3D
## A sideline kicking net: a tall frame on poles with a mesh net that ripples
## where the ball hits it. Reusable anywhere (SidelineSet places one for the
## warmup). Placeholder low-poly art: cylinders + one shaded plane.
##
## Local frame: the net hangs in the plane z = 0, centered on x = 0, from
## BOTTOM to BOTTOM + HEIGHT; the kicker is toward +Z.

const NET_SHADER := preload("res://shaders/net.gdshader")
const WIDTH := 3.6
const HEIGHT := 4.0
const BOTTOM := 0.25
const POLE_RADIUS := 0.05
const RIPPLE_TIME := 0.9

var _mat: ShaderMaterial
var _ripple := -1.0


func _ready() -> void:
	var frame := StandardMaterial3D.new()
	frame.albedo_color = Color(0.12, 0.13, 0.15)
	frame.roughness = 0.5
	frame.metallic = 0.4
	var top := BOTTOM + HEIGHT
	for side in [-1.0, 1.0]:
		var x: float = side * (WIDTH * 0.5 + POLE_RADIUS)
		_cyl(frame, top + 0.15, POLE_RADIUS, Vector3(x, (top + 0.15) * 0.5, 0.0), Vector3.ZERO)
		# Base feet so it stands on its own.
		_cyl(frame, 1.2, POLE_RADIUS * 0.8, Vector3(x, 0.04, -0.3), Vector3(90.0, 0.0, 0.0))
	_cyl(frame, WIDTH + POLE_RADIUS * 4.0, POLE_RADIUS, Vector3(0.0, top, 0.0), Vector3(0.0, 0.0, 90.0))
	_cyl(frame, WIDTH + POLE_RADIUS * 4.0, POLE_RADIUS * 0.7, Vector3(0.0, BOTTOM, 0.0), Vector3(0.0, 0.0, 90.0))

	var plane := PlaneMesh.new()
	plane.size = Vector2(WIDTH, HEIGHT)
	plane.orientation = PlaneMesh.FACE_Z
	plane.subdivide_width = 14
	plane.subdivide_depth = 16
	_mat = ShaderMaterial.new()
	_mat.shader = NET_SHADER
	_mat.set_shader_parameter("plane_size", Vector2(WIDTH, HEIGHT))
	plane.material = _mat
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.position = Vector3(0.0, BOTTOM + HEIGHT * 0.5, 0.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	set_process(false)


## True if a world point (where the ball crosses the net's plane) is inside the net.
func contains(world_point: Vector3) -> bool:
	var p := to_local(world_point)
	return absf(p.x) <= WIDTH * 0.5 and p.y >= BOTTOM and p.y <= BOTTOM + HEIGHT


## World z of the net's plane.
func plane_z() -> float:
	return global_position.z


## Start a ripple at a world point on the net.
func hit(world_point: Vector3) -> void:
	var p := to_local(world_point)
	# PlaneMesh FACE_Z: UV x runs left to right, UV y top to bottom.
	var uv := Vector2(p.x / WIDTH + 0.5, 1.0 - (p.y - BOTTOM) / HEIGHT)
	_mat.set_shader_parameter("hit_uv", uv)
	_ripple = 0.0
	_mat.set_shader_parameter("ripple_t", 0.0)
	set_process(true)


func _process(delta: float) -> void:
	_ripple += delta
	if _ripple >= RIPPLE_TIME:
		_ripple = -1.0
		set_process(false)
	_mat.set_shader_parameter("ripple_t", _ripple)


func _cyl(mat: Material, length: float, radius: float, pos: Vector3, rot_deg: Vector3) -> void:
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = length
	cyl.radial_segments = 8
	cyl.rings = 1
	cyl.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = cyl
	mi.position = pos
	mi.rotation_degrees = rot_deg
	add_child(mi)
