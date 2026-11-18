class_name GoalPosts
extends Node3D
## Placeholder goalposts built from primitives, plus wind ribbons on top.
## Local frame: crossbar centered at x=0, z=0; the kicker is toward +Z.

const CROSSBAR_HEIGHT := 3.048  # 10 ft
const INNER_WIDTH := 5.639      # 18 ft 6 in
const UPRIGHT_HEIGHT := 10.67   # above the crossbar
const POST_RADIUS := 0.08
const GOOSENECK_OFFSET := 1.8
const POST_COLOR := Color(1.0, 0.85, 0.1)
const FLAG_COLOR := Color(1.0, 0.25, 0.15)
const FLAG_LENGTH := 1.6

var _flag_pivots: Array[Node3D] = []


func _ready() -> void:
	var mat := _mat(POST_COLOR)
	# Base pole (behind the end line) + gooseneck arm forward to the crossbar.
	_add_cyl(mat, CROSSBAR_HEIGHT, POST_RADIUS * 1.6,
		Vector3(0.0, CROSSBAR_HEIGHT * 0.5, -GOOSENECK_OFFSET), Vector3.ZERO)
	_add_cyl(mat, GOOSENECK_OFFSET, POST_RADIUS,
		Vector3(0.0, CROSSBAR_HEIGHT, -GOOSENECK_OFFSET * 0.5), Vector3(90.0, 0.0, 0.0))
	# Crossbar.
	_add_cyl(mat, INNER_WIDTH + POST_RADIUS * 2.0, POST_RADIUS,
		Vector3(0.0, CROSSBAR_HEIGHT, 0.0), Vector3(0.0, 0.0, 90.0))
	# Uprights + wind ribbons.
	var flag_mat := _mat(FLAG_COLOR)
	for side in [-1.0, 1.0]:
		var x: float = side * INNER_WIDTH * 0.5
		_add_cyl(mat, UPRIGHT_HEIGHT, POST_RADIUS,
			Vector3(x, CROSSBAR_HEIGHT + UPRIGHT_HEIGHT * 0.5, 0.0), Vector3.ZERO)
		var pivot := Node3D.new()
		pivot.position = Vector3(x, CROSSBAR_HEIGHT + UPRIGHT_HEIGHT, 0.0)
		add_child(pivot)
		var ribbon := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(FLAG_LENGTH, 0.35, 0.03)
		box.material = flag_mat
		ribbon.mesh = box
		ribbon.position = Vector3(FLAG_LENGTH * 0.5, 0.0, 0.0)
		pivot.add_child(ribbon)
		_flag_pivots.append(pivot)


## Ribbons point downwind and stretch with strength; they droop when calm.
func set_wind(mph: float, max_mph: float) -> void:
	var strength := clampf(absf(mph) / maxf(max_mph, 0.01), 0.0, 1.0)
	for pivot in _flag_pivots:
		if absf(mph) < 0.5:
			pivot.rotation = Vector3(0.0, 0.0, deg_to_rad(-80.0))
			pivot.scale = Vector3(0.5, 1.0, 1.0)
		else:
			pivot.rotation = Vector3(0.0, 0.0 if mph > 0.0 else PI, deg_to_rad(-60.0 * (1.0 - strength)))
			pivot.scale = Vector3(lerpf(0.5, 1.4, strength), 1.0, 1.0)


func _add_cyl(mat: Material, length: float, radius: float, pos: Vector3, rot_deg: Vector3) -> void:
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = length
	cyl.radial_segments = 10
	cyl.rings = 1
	cyl.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = cyl
	mi.position = pos
	mi.rotation_degrees = rot_deg
	add_child(mi)


static func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	return m
