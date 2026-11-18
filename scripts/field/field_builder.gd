class_name FieldBuilder
extends Node3D
## Builds the placeholder field from primitives: grass, 5-yard stripes, lines,
## end zone, holder, our line, and the rushers who block late kicks.
##
## The ball is always kicked from the world origin toward -Z.
## $GoalEnd (posts, end zone, yard lines) slides to match the attempt distance.

const YARD := 0.9144
const FIELD_WIDTH := 48.77  # 53 1/3 yards
## Line of scrimmage is 7 yards in front of the hold.
const LOS_Z := -7.0 * YARD

const GRASS_A := Color(0.20, 0.52, 0.22)
const GRASS_B := Color(0.17, 0.46, 0.19)
const LINE_COLOR := Color(0.95, 0.95, 0.95)
const ENDZONE_COLOR := Color(0.12, 0.22, 0.55)
const OUR_COLOR := Color(0.15, 0.3, 0.85)
const THEIR_COLOR := Color(0.85, 0.15, 0.15)

## Rusher start positions and where they end up when the window runs out.
const RUSH_FROM := [Vector3(-4.6, 0.0, -7.2), Vector3(0.6, 0.0, -7.4), Vector3(4.6, 0.0, -7.2)]
const RUSH_TO := [Vector3(-0.9, 0.0, -1.0), Vector3(0.25, 0.0, -1.4), Vector3(0.9, 0.0, -1.0)]

var _rushers: Array[MeshInstance3D] = []

@onready var goal_end: Node3D = $GoalEnd
@onready var goal_posts: GoalPosts = $GoalEnd/GoalPosts


func _ready() -> void:
	_build_ground()
	_build_goal_end()
	_build_players()


func set_distance(distance_m: float) -> void:
	goal_end.position = Vector3(0.0, 0.0, -distance_m)


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
		var p := from.lerp(RUSH_TO[i], eased)
		var arms_up := 1.0 + 0.3 * smoothstep(0.75, 1.0, t)
		r.scale = Vector3(1.0, arms_up, 1.0)
		r.position = p + Vector3(0.0, 0.9 * arms_up, 0.0)


# --- building -----------------------------------------------------------------

func _build_ground() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(200.0, 320.0)
	plane.material = _mat(GRASS_B, false)
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.position = Vector3(0.0, 0.0, -90.0)
	add_child(mi)


func _build_goal_end() -> void:
	# GoalEnd local frame: posts/end line at z=0, field extends toward +Z.
	var goal_line_z := 10.0 * YARD
	_add_box(goal_end, Vector3(FIELD_WIDTH, 0.01, goal_line_z),
		Vector3(0.0, 0.01, goal_line_z * 0.5), ENDZONE_COLOR, false)
	# 5-yard stripes and lines out to the 70-yard line (beyond the longest kick).
	for i in 14:
		var z0 := goal_line_z + i * 5.0 * YARD
		if i % 2 == 0:
			_add_box(goal_end, Vector3(FIELD_WIDTH, 0.01, 5.0 * YARD),
				Vector3(0.0, 0.01, z0 + 2.5 * YARD), GRASS_A, false)
		_add_box(goal_end, Vector3(FIELD_WIDTH, 0.02, 0.15 if i > 0 else 0.25),
			Vector3(0.0, 0.02, z0), LINE_COLOR, true)
	_add_box(goal_end, Vector3(FIELD_WIDTH, 0.02, 0.15), Vector3(0.0, 0.02, 0.0), LINE_COLOR, true)
	var side_len := goal_line_z + 70.0 * YARD
	for side in [-1.0, 1.0]:
		_add_box(goal_end, Vector3(0.2, 0.02, side_len),
			Vector3(side * FIELD_WIDTH * 0.5, 0.02, side_len * 0.5), LINE_COLOR, true)


func _build_players() -> void:
	# Tee + holder.
	_add_box(self, Vector3(0.08, 0.05, 0.08), Vector3(0.0, 0.025, 0.0), Color(1.0, 0.5, 0.1), false)
	_add_box(self, Vector3(0.5, 0.9, 0.5), Vector3(-0.6, 0.45, 0.1), OUR_COLOR, false)
	# Our line.
	for i in 7:
		var x := -3.6 + i * 1.2
		_add_box(self, Vector3(0.9, 1.7, 0.6), Vector3(x, 0.85, LOS_Z + 0.5), OUR_COLOR, false)
	# Their rushers.
	for i in RUSH_FROM.size():
		var start: Vector3 = RUSH_FROM[i]
		_rushers.append(_add_box(self, Vector3(0.9, 1.8, 0.6), start, THEIR_COLOR, false))
	reset_rush()


func _add_box(parent: Node, size: Vector3, pos: Vector3, color: Color,
		unshaded: bool) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	box.material = _mat(color, unshaded)
	var mi := MeshInstance3D.new()
	mi.mesh = box
	mi.position = pos
	parent.add_child(mi)
	return mi


static func _mat(c: Color, unshaded: bool) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 1.0
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m
