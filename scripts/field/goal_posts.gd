class_name GoalPosts
extends Node3D
## Placeholder goalposts built from primitives, plus wind ribbons on top.
## Local frame: crossbar centered at x=0, z=0; the kicker is toward +Z.

const CROSSBAR_HEIGHT := 3.048  # 10 ft
const INNER_WIDTH := 5.639      # 18 ft 6 in
const UPRIGHT_HEIGHT := 10.67   # above the crossbar
## Drawn a bit thicker than real (0.05 m) so the posts read from 60 yards.
const POST_RADIUS := 0.11
const GOOSENECK_OFFSET := 1.8
const POST_COLOR := Color(1.0, 0.85, 0.1)
const FLAG_COLOR := Color(1.0, 0.25, 0.15)
const FLAG_LENGTH := 1.6

## Career Mode look, set before the scene enters the tree (field_goal_game.gd
## set_look()). style "" = the original posts below, unchanged.
##   high_school: plain H-frame posts from the ground, matte, wider.
##   college: gooseneck posts with school-colored padding, bands and flags.
##   pro: polished gold gooseneck posts, taller uprights, team padding, narrower.
var style: StringName = &""
## Gap between the uprights (m). KickResult judges against this too.
var inner_width: float = INNER_WIDTH
var accent := Color(0.1, 0.18, 0.45)
var accent2 := Color(1.0, 0.85, 0.1)

var _flag_pivots: Array[Node3D] = []


func _ready() -> void:
	match style:
		&"high_school":
			_build_high_school()
		&"college":
			_build_gooseneck(POST_COLOR, 0.15, 0.25, accent, UPRIGHT_HEIGHT, accent2, accent2)
		&"pro":
			_build_gooseneck(Color(1.0, 0.82, 0.12), 0.5, 0.12, accent, UPRIGHT_HEIGHT * 1.2, accent2,
				FLAG_COLOR)
		_:
			_build_gooseneck(POST_COLOR, 0.25, 0.3, Color(0.1, 0.18, 0.45), UPRIGHT_HEIGHT, Color.TRANSPARENT,
				FLAG_COLOR)


## The original posts (style ""), and the college / pro variants of them.
## bands: colored rings near the top of the uprights (transparent = none).
func _build_gooseneck(post_color: Color, emission: float, roughness: float, pad_color: Color,
		upright_h: float, bands: Color, flag_color: Color) -> void:
	var mat := _mat(post_color)
	mat.roughness = roughness
	mat.metallic = 0.25 if emission < 0.4 else 0.55
	mat.emission_enabled = true
	mat.emission = post_color
	mat.emission_energy_multiplier = emission
	# Padding around the base of the pole.
	var pad := _mat(pad_color)
	pad.roughness = 0.9
	_add_cyl(pad, 2.0, POST_RADIUS * 3.2, Vector3(0.0, 1.0, -GOOSENECK_OFFSET), Vector3.ZERO)
	# Base pole (behind the end line) + gooseneck arm forward to the crossbar.
	_add_cyl(mat, CROSSBAR_HEIGHT, POST_RADIUS * 1.6,
		Vector3(0.0, CROSSBAR_HEIGHT * 0.5, -GOOSENECK_OFFSET), Vector3.ZERO)
	_add_cyl(mat, GOOSENECK_OFFSET, POST_RADIUS,
		Vector3(0.0, CROSSBAR_HEIGHT, -GOOSENECK_OFFSET * 0.5), Vector3(90.0, 0.0, 0.0))
	# Crossbar.
	_add_cyl(mat, inner_width + POST_RADIUS * 2.0, POST_RADIUS,
		Vector3(0.0, CROSSBAR_HEIGHT, 0.0), Vector3(0.0, 0.0, 90.0))
	# Uprights + wind ribbons.
	for side in [-1.0, 1.0]:
		var x: float = side * inner_width * 0.5
		_add_cyl(mat, upright_h, POST_RADIUS,
			Vector3(x, CROSSBAR_HEIGHT + upright_h * 0.5, 0.0), Vector3.ZERO)
		if bands.a > 0.0:
			var band := _mat(bands)
			for k in 2:
				_add_cyl(band, 0.35, POST_RADIUS * 1.25,
					Vector3(x, CROSSBAR_HEIGHT + upright_h - 1.2 - k * 0.6, 0.0), Vector3.ZERO)
		_add_flag(x, CROSSBAR_HEIGHT + upright_h, flag_color)


## Plain H-frame: two posts straight up from the ground, matte paint, wide.
func _build_high_school() -> void:
	var paint := _mat(Color(0.96, 0.92, 0.62))
	paint.roughness = 0.85
	var pad := _mat(Color(0.35, 0.36, 0.38))
	pad.roughness = 0.95
	var r := POST_RADIUS * 0.85
	var upright_h := UPRIGHT_HEIGHT * 0.75
	_add_cyl(paint, inner_width + r * 2.0, r, Vector3(0.0, CROSSBAR_HEIGHT, 0.0), Vector3(0.0, 0.0, 90.0))
	for side in [-1.0, 1.0]:
		var x: float = side * inner_width * 0.5
		var h := CROSSBAR_HEIGHT + upright_h
		_add_cyl(paint, h, r, Vector3(x, h * 0.5, 0.0), Vector3.ZERO)
		_add_cyl(pad, 1.6, r * 2.6, Vector3(x, 0.8, 0.0), Vector3.ZERO)
		_add_flag(x, h, Color(0.95, 0.95, 0.95))


func _add_flag(x: float, top: float, color: Color) -> void:
	var pivot := Node3D.new()
	pivot.position = Vector3(x, top, 0.0)
	add_child(pivot)
	var ribbon := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(FLAG_LENGTH, 0.35, 0.03)
	box.material = _mat(color)
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
