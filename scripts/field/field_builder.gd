class_name FieldBuilder
extends Node3D
## Builds the placeholder stadium from primitives + procedural shaders:
## textured field (lines/stripes are drawn by field.gdshader), kicking tee,
## stands full of fans behind the posts, light towers, and the two edge
## rushers who block late kicks. No texture or model files.
##
## The ball is always kicked from the world origin toward -Z.
## $GoalEnd (posts + stands) slides to match the attempt distance.

const FIELD_SHADER := preload("res://shaders/field.gdshader")
const CROWD_SHADER := preload("res://shaders/crowd.gdshader")

const YARD := 0.9144
## Distance from the end line to the front wall of the stands.
const STANDS_GAP := 12.0
const STAND_WIDTH := 200.0
const STAND_SLOPE_DEG := 34.0
const WALL_HEIGHT := 2.6

const TEE_COLOR := Color(1.0, 0.72, 0.1)
const WALL_COLOR := Color(0.07, 0.12, 0.3)
const THEIR_JERSEY := Color(0.8, 0.12, 0.12)
const THEIR_HELMET := Color(0.95, 0.95, 0.95)

## Rushers come in from off-screen on both edges and meet at the ball.
const RUSH_FROM := [Vector3(-5.2, 0.0, -4.6), Vector3(5.2, 0.0, -4.6)]
const RUSH_TO := [Vector3(-0.75, 0.0, -1.0), Vector3(0.75, 0.0, -1.0)]

var _field_mat: ShaderMaterial
var _rushers: Array[Node3D] = []

@onready var goal_end: Node3D = $GoalEnd
@onready var goal_posts: GoalPosts = $GoalEnd/GoalPosts


func _ready() -> void:
	_build_ground()
	_build_tee()
	_build_stands()
	_build_rushers()


func set_distance(distance_m: float) -> void:
	goal_end.position = Vector3(0.0, 0.0, -distance_m)
	_field_mat.set_shader_parameter("goal_z", -distance_m)


func set_wind(mph: float, max_mph: float) -> void:
	goal_posts.set_wind(mph, max_mph)


func tee_position() -> Vector3:
	return Vector3.ZERO


func reset_rush() -> void:
	set_rush_progress(0.0)


## t: 0 = at the snap, 1 = window expired (they reach the ball).
func set_rush_progress(t: float) -> void:
	var eased := pow(clampf(t, 0.0, 1.0), 1.6)
	for i in _rushers.size():
		var r := _rushers[i]
		var from: Vector3 = RUSH_FROM[i]
		var to: Vector3 = RUSH_TO[i]
		r.position = from.lerp(to, eased)
		# Lean in and leap with arms up at the end.
		var leap := smoothstep(0.75, 1.0, t)
		r.position.y = 0.35 * leap
		r.rotation = Vector3(deg_to_rad(12.0 * eased), (from - to).x * 0.05, 0.0)
		r.scale = Vector3(1.0, 1.0 + 0.15 * leap, 1.0)


# --- building -------------------------------------------------------------------

func _build_ground() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(240.0, 360.0)
	plane.subdivide_width = 8
	plane.subdivide_depth = 8
	_field_mat = ShaderMaterial.new()
	_field_mat.shader = FIELD_SHADER
	plane.material = _field_mat
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.position = Vector3(0.0, 0.0, -120.0)
	add_child(mi)


func _build_tee() -> void:
	var cone := CylinderMesh.new()
	cone.top_radius = 0.035
	cone.bottom_radius = 0.09
	cone.height = Ball.TEE_HEIGHT
	cone.radial_segments = 16
	cone.rings = 1
	var m := _mat(TEE_COLOR)
	m.roughness = 0.4
	cone.material = m
	var mi := MeshInstance3D.new()
	mi.mesh = cone
	mi.position = Vector3(0.0, Ball.TEE_HEIGHT * 0.5, 0.0)
	add_child(mi)


func _build_stands() -> void:
	# All parented to GoalEnd (local z=0 is the end line, the field is +Z).
	var front_z := -STANDS_GAP
	_add_box(goal_end, Vector3(STAND_WIDTH, WALL_HEIGHT, 0.5),
		Vector3(0.0, WALL_HEIGHT * 0.5, front_z), WALL_COLOR)
	# Trim band along the top of the wall.
	_add_box(goal_end, Vector3(STAND_WIDTH, 0.35, 0.55),
		Vector3(0.0, WALL_HEIGHT - 0.4, front_z + 0.02), Color(0.9, 0.9, 0.92))

	var lower_len := 46.0
	var lower_top := _add_stand(Vector3(0.0, WALL_HEIGHT, front_z - 0.3), lower_len)
	# Suite level: a dark glass band between the decks.
	_add_box(goal_end, Vector3(STAND_WIDTH, 4.0, 1.0),
		lower_top + Vector3(0.0, 2.0, -0.5), Color(0.05, 0.07, 0.12))
	var upper_top := _add_stand(lower_top + Vector3(0.0, 4.0, -1.0), 30.0)
	# Roof rim.
	_add_box(goal_end, Vector3(STAND_WIDTH, 1.2, 6.0),
		upper_top + Vector3(0.0, 0.6, 1.5), Color(0.75, 0.77, 0.8))

	# Light towers above the stands.
	for side_v in [-1.0, 1.0]:
		var side: float = side_v
		var base := Vector3(side * 34.0, 0.0, upper_top.z - 4.0)
		var height := upper_top.y + 14.0
		_add_box(goal_end, Vector3(0.8, height, 0.8), base + Vector3(0.0, height * 0.5, 0.0),
			Color(0.55, 0.57, 0.6))
		var panel := _add_box(goal_end, Vector3(10.0, 5.0, 0.6),
			base + Vector3(0.0, height + 2.0, 0.6), Color(1.0, 1.0, 0.95))
		var lm := (panel.mesh as BoxMesh).material as StandardMaterial3D
		lm.emission_enabled = true
		lm.emission = Color(1.0, 0.97, 0.85)
		lm.emission_energy_multiplier = 1.5


## Adds one sloped seating deck whose bottom-front edge is at `bottom`.
## Returns the top-back edge position so the next deck can stack on it.
func _add_stand(bottom: Vector3, length: float) -> Vector3:
	var slope := deg_to_rad(STAND_SLOPE_DEG)
	var up_dir := Vector3(0.0, sin(slope), -cos(slope))
	var plane := PlaneMesh.new()
	plane.size = Vector2(STAND_WIDTH, length)
	var mat := ShaderMaterial.new()
	mat.shader = CROWD_SHADER
	mat.set_shader_parameter("plane_size", plane.size)
	plane.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.rotation = Vector3(slope, 0.0, 0.0)  # tilt to face the field
	mi.position = bottom + up_dir * length * 0.5
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	goal_end.add_child(mi)
	return bottom + up_dir * length


func _build_rushers() -> void:
	var jersey := _mat(THEIR_JERSEY)
	var helmet := _mat(THEIR_HELMET)
	helmet.roughness = 0.25
	helmet.metallic = 0.3
	var pants := _mat(Color(0.92, 0.9, 0.85))
	for i in RUSH_FROM.size():
		var root := Node3D.new()
		add_child(root)
		var legs := CapsuleMesh.new()
		legs.radius = 0.24
		legs.height = 0.95
		legs.material = pants
		_add_mesh(root, legs, Vector3(0.0, 0.48, 0.0))
		var body := CapsuleMesh.new()
		body.radius = 0.36
		body.height = 1.0
		body.material = jersey
		_add_mesh(root, body, Vector3(0.0, 1.2, 0.0))
		var head := SphereMesh.new()
		head.radius = 0.17
		head.height = 0.34
		head.material = helmet
		_add_mesh(root, head, Vector3(0.0, 1.85, 0.0))
		# Arms reaching up to block.
		for side_v in [-1.0, 1.0]:
			var side: float = side_v
			var arm := CapsuleMesh.new()
			arm.radius = 0.09
			arm.height = 0.85
			arm.material = jersey
			var a := _add_mesh(root, arm, Vector3(side * 0.42, 1.9, -0.1))
			a.rotation = Vector3(deg_to_rad(-15.0), 0.0, side * deg_to_rad(-15.0))
		_rushers.append(root)
	reset_rush()


func _add_mesh(parent: Node, mesh: Mesh, pos: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	parent.add_child(mi)
	return mi


func _add_box(parent: Node, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	box.material = _mat(color)
	return _add_mesh(parent, box, pos)


static func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.9
	return m
