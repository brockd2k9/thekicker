class_name FieldBuilder
extends Node3D
## Builds the placeholder stadium from primitives + procedural shaders:
## textured field (lines/stripes are drawn by field.gdshader), stands full of
## fans behind the posts, light towers, and both lines in field-goal formation
## with a holder kneeling at the spot. No texture or model files.
##
## The ball is always held at the world origin and kicked toward -Z.
## $GoalEnd (posts + stands) slides to match the attempt distance.
##
## "Play progress" t runs 0 -> 1 over the kick window after the snap:
## both lines fire out, the middle of the defense leaps, and the two edge
## rushers reach the ball at t = 1 (= BLOCKED).

const FIELD_SHADER := preload("res://shaders/field.gdshader")
const CROWD_SHADER := preload("res://shaders/crowd.gdshader")

const YARD := 0.9144
## Line of scrimmage: the hold is 7 yards behind it.
const LOS_Z := -7.0 * YARD
## Distance from the end line to the front wall of the stands.
const STANDS_GAP := 12.0
const STAND_WIDTH := 200.0
const STAND_SLOPE_DEG := 34.0
const WALL_HEIGHT := 2.6

const WALL_COLOR := Color(0.07, 0.12, 0.3)
const OUR_JERSEY := Color(0.12, 0.28, 0.75)
const OUR_PANTS := Color(0.92, 0.9, 0.84)
const OUR_HELMET := Color(0.1, 0.18, 0.5)
const THEIR_JERSEY := Color(0.8, 0.12, 0.12)
const THEIR_PANTS := Color(0.95, 0.95, 0.95)
const THEIR_HELMET := Color(0.95, 0.95, 0.95)

## Field-goal unit (x, z offset from the line of scrimmage, + = our side).
## Long snapper at 0, guards, tackles, tight ends, then the two wings.
const OL_SPOTS := [
	Vector2(0.0, 0.45), Vector2(-0.95, 0.45), Vector2(0.95, 0.45),
	Vector2(-1.9, 0.45), Vector2(1.9, 0.45), Vector2(-2.85, 0.5), Vector2(2.85, 0.5),
	Vector2(-3.55, 1.3), Vector2(3.55, 1.3),
]
## Block unit across the line (negative z = their side).
const DL_SPOTS := [
	Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(-1.45, -0.5), Vector2(1.45, -0.5),
	Vector2(-2.4, -0.5), Vector2(2.4, -0.5), Vector2(-3.3, -0.55), Vector2(3.3, -0.55),
]
## Middle leaper who starts deep and jumps at the kick.
const LEAPER_SPOT := Vector2(0.0, -1.6)
## Edge rushers: start wide, finish at the ball.
const EDGE_FROM := [Vector3(-4.7, 0.0, -7.0), Vector3(4.7, 0.0, -7.0)]
const EDGE_TO := [Vector3(-0.8, 0.0, -0.9), Vector3(0.8, 0.0, -0.9)]
## Holder kneels on the kicker's left, facing the ball (legs sink into the turf).
const HOLDER_POS := Vector3(-0.78, -0.22, 0.4)

var _field_mat: ShaderMaterial
var _ol: Array[PlayerFigure] = []
var _ol_home: Array[Vector3] = []
var _dl: Array[PlayerFigure] = []
var _dl_home: Array[Vector3] = []
var _leaper: PlayerFigure
var _edges: Array[PlayerFigure] = []
var _holder: PlayerFigure

@onready var goal_end: Node3D = $GoalEnd
@onready var goal_posts: GoalPosts = $GoalEnd/GoalPosts


func _ready() -> void:
	_build_ground()
	_build_stands()
	_build_formation()


func set_distance(distance_m: float) -> void:
	goal_end.position = Vector3(0.0, 0.0, -distance_m)
	_field_mat.set_shader_parameter("goal_z", -distance_m)


func set_wind(mph: float, max_mph: float) -> void:
	goal_posts.set_wind(mph, max_mph)


## Where the holder puts the tip of the ball.
func hold_spot() -> Vector3:
	return Vector3.ZERO


## Everyone back in their pre-snap stance; holder holding the ball.
func reset_play() -> void:
	set_play_progress(0.0)
	set_holder_holding(true)


## Holder's finger on the ball (true) or pulled away after the kick (false).
func set_holder_holding(holding: bool) -> void:
	# The reaching arm is the far one (left), so the camera still sees the ball.
	_holder.set_pose(0.5, 66.0 if holding else 140.0, 20.0)


## t: 0 = at the snap, 1 = kick window expired (edge rushers reach the ball).
func set_play_progress(t: float) -> void:
	t = clampf(t, 0.0, 1.0)
	var fire := smoothstep(0.0, 0.25, t)  # how far out of their stance
	var push := pow(t, 1.3)
	var stance_arms := lerpf(35.0, 85.0, fire)

	for i in _ol.size():
		# Stand up, absorb the rush, give a little ground.
		_ol[i].position = _ol_home[i] + Vector3(0.0, 0.0, 0.4 * push)
		# Stay fairly low so the kicker can see the crossbar over them.
		_ol[i].set_pose(1.0 - 0.45 * fire, stance_arms, stance_arms)

	var reach := smoothstep(0.55, 1.0, t)
	for i in _dl.size():
		var home := _dl_home[i]
		_dl[i].position = home + Vector3(0.0, 0.0, 0.5 * push)
		var arms := stance_arms
		if absf(home.x) < 2.0:
			arms = lerpf(stance_arms, 165.0, reach)  # interior hands up to block
		_dl[i].set_pose(1.0 - 0.7 * fire, arms, arms)

	# Middle leaper: run up to the line, then jump with arms high.
	_leaper.position = Vector3(LEAPER_SPOT.x, 0.0,
		LOS_Z + LEAPER_SPOT.y + 1.0 * smoothstep(0.1, 0.7, t))
	var leap_arms := lerpf(40.0, 170.0, reach)
	_leaper.set_pose(0.6 - 0.6 * fire, leap_arms, leap_arms, 0.55 * smoothstep(0.65, 0.9, t))

	# Edge rushers race around the end to the ball and dive at it.
	var eased := pow(t, 1.6)
	var dive := smoothstep(0.8, 1.0, t)
	var dive_arms := lerpf(40.0, 120.0, dive)
	for i in _edges.size():
		var from: Vector3 = EDGE_FROM[i]
		var to: Vector3 = EDGE_TO[i]
		var dir := (to - from).normalized()
		_edges[i].position = from.lerp(to, eased)
		_edges[i].rotation.y = atan2(-dir.x, -dir.z)  # forward (-Z) along the path
		_edges[i].set_pose(0.9 - 0.6 * fire + 0.4 * dive, dive_arms, dive_arms, 0.25 * dive)


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


func _build_formation() -> void:
	for s in OL_SPOTS:
		var spot: Vector2 = s
		var p := _add_player(OUR_JERSEY, OUR_PANTS, OUR_HELMET)
		var home := Vector3(spot.x, 0.0, LOS_Z + spot.y)
		p.position = home
		if absf(spot.x) > 3.0:
			p.rotation.y = -signf(spot.x) * deg_to_rad(25.0)  # wings angle out
		_ol.append(p)
		_ol_home.append(home)
	for s in DL_SPOTS:
		var spot: Vector2 = s
		var p := _add_player(THEIR_JERSEY, THEIR_PANTS, THEIR_HELMET)
		var home := Vector3(spot.x, 0.0, LOS_Z + spot.y)
		p.position = home
		p.rotation.y = PI  # facing us
		_dl.append(p)
		_dl_home.append(home)
	_leaper = _add_player(THEIR_JERSEY, THEIR_PANTS, THEIR_HELMET)
	_leaper.rotation.y = PI
	for i in EDGE_FROM.size():
		_edges.append(_add_player(THEIR_JERSEY, THEIR_PANTS, THEIR_HELMET))

	_holder = _add_player(OUR_JERSEY, OUR_PANTS, OUR_HELMET)
	_holder.position = HOLDER_POS
	_holder.rotation.y = deg_to_rad(-90.0)  # facing +X, toward the ball
	reset_play()


func _add_player(jersey: Color, pants: Color, helmet: Color) -> PlayerFigure:
	var p := PlayerFigure.new()
	add_child(p)
	p.build(jersey, pants, helmet)
	return p


func _build_stands() -> void:
	# All parented to GoalEnd (local z=0 is the end line, the field is +Z).
	var front_z := -STANDS_GAP
	_add_box(goal_end, Vector3(STAND_WIDTH, WALL_HEIGHT, 0.5),
		Vector3(0.0, WALL_HEIGHT * 0.5, front_z), WALL_COLOR)
	# Trim band along the top of the wall.
	_add_box(goal_end, Vector3(STAND_WIDTH, 0.35, 0.55),
		Vector3(0.0, WALL_HEIGHT - 0.4, front_z + 0.02), Color(0.9, 0.9, 0.92))

	var lower_top := _add_stand(Vector3(0.0, WALL_HEIGHT, front_z - 0.3), 46.0)
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


func _add_box(parent: Node, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	box.material = m
	var mi := MeshInstance3D.new()
	mi.mesh = box
	mi.position = pos
	parent.add_child(mi)
	return mi
