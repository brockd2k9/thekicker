class_name SidelineSet
extends Node3D
## The team's sideline beside the field: bench, a water cooler on a table,
## a few teammates in the team's colors, a low wall and a strip of crowd
## behind it, and a kicking net (KickingNet) in front of a tee. Reusable: the
## warmup uses it; anything else on the sideline can place one too.
## Placeholder low-poly art (boxes, cylinders, PlayerFigures, the crowd shader).
##
## Local frame: origin = the tee (where the kicker kicks from), facing -Z
## (down the sideline). The field is toward -X, the stands toward +X.

const CROWD_SHADER := preload("res://shaders/crowd.gdshader")
## Net distance in front of the tee (m).
const NET_DISTANCE := 6.5
const BENCH_X := 4.2
const STANDS_X := 12.0
const STAND_LENGTH := 220.0
const STAND_SLOPE_DEG := 34.0
## Teammates by the bench: [x, z, kneeling].
const TEAMMATES := [[3.4, -3.0, false], [3.0, -5.2, false], [3.6, -8.6, true], [3.1, -11.0, false],
	[3.5, -13.5, false]]

var net: KickingNet
## The stadium's crowd settings (empty seats, colors, bleachers). Set before build().
var stadium: StadiumSpec
var _tee: MeshInstance3D


func build(kit: TeamKit, rng: RandomNumberGenerator, tee_height: float, ball_scale: float) -> void:
	net = KickingNet.new()
	net.position = Vector3(0.0, 0.0, -NET_DISTANCE)
	add_child(net)
	_tee = KickoffFormation.make_tee(tee_height, ball_scale)
	add_child(_tee)
	_build_bench()
	var used: Array[int] = []
	for t in TEAMMATES:
		var p := PlayerFigure.new()
		add_child(p)
		var num := rng.randi_range(10, 89)
		while used.has(num):
			num = rng.randi_range(10, 89)
		used.append(num)
		p.build(kit, num, rng, 1.0 + rng.randf() * 0.2)
		p.kneeling = bool(t[2])
		p.position = Vector3(float(t[0]), 0.0, float(t[1]))
		p.rotation.y = PI * 0.5 + rng.randf_range(-0.3, 0.3)  # watching the field
		p.set_elbows(rng.randf_range(10.0, 60.0), rng.randf_range(10.0, 60.0))
		p.set_pose(0.5 if t[2] else rng.randf_range(0.0, 0.15), rng.randf_range(5.0, 30.0),
			rng.randf_range(5.0, 30.0))
	_build_stands()


func _build_bench() -> void:
	var metal := _mat(Color(0.55, 0.57, 0.6), 0.4, 0.5)
	var seat := _mat(Color(0.18, 0.2, 0.24), 0.8)
	for i in 2:
		var z := -2.5 - i * 7.0
		_box(seat, Vector3(0.45, 0.08, 6.0), Vector3(BENCH_X + 0.5, 0.45, z - 3.0))
		_box(seat, Vector3(0.08, 0.4, 6.0), Vector3(BENCH_X + 0.75, 0.75, z - 3.0))
		for end in [0.0, -6.0]:
			_box(metal, Vector3(0.45, 0.45, 0.08), Vector3(BENCH_X + 0.5, 0.22, z + float(end)))
	# A table with a generic water cooler and a stack of cups.
	var table := _mat(Color(0.85, 0.85, 0.82), 0.7)
	_box(table, Vector3(0.7, 0.05, 1.4), Vector3(BENCH_X + 0.4, 0.8, -17.0))
	_box(metal, Vector3(0.6, 0.78, 1.2), Vector3(BENCH_X + 0.4, 0.39, -17.0))
	var cooler := CylinderMesh.new()
	cooler.top_radius = 0.22
	cooler.bottom_radius = 0.22
	cooler.height = 0.5
	cooler.radial_segments = 12
	cooler.material = _mat(Color(0.95, 0.5, 0.1), 0.5)
	var mi := MeshInstance3D.new()
	mi.mesh = cooler
	mi.position = Vector3(BENCH_X + 0.4, 1.08, -16.7)
	add_child(mi)
	_box(_mat(Color.WHITE, 0.6), Vector3(0.12, 0.25, 0.12), Vector3(BENCH_X + 0.4, 0.95, -17.4))


## A low wall and one sloped deck of crowd along the sideline, facing the field.
func _build_stands() -> void:
	var pivot := Node3D.new()
	pivot.position = Vector3(STANDS_X, 0.0, -STAND_LENGTH * 0.35)
	pivot.rotation.y = -PI * 0.5  # local +Z = toward the field
	add_child(pivot)
	var wall := _mat(Color(0.07, 0.12, 0.3), 0.9)
	var wall_mi := _box(wall, Vector3(STAND_LENGTH, 1.6, 0.4), Vector3(0.0, 0.8, 0.0))
	remove_child(wall_mi)
	pivot.add_child(wall_mi)
	var slope := deg_to_rad(STAND_SLOPE_DEG)
	var length := 18.0
	var up_dir := Vector3(0.0, sin(slope), -cos(slope))
	var plane := PlaneMesh.new()
	plane.size = Vector2(STAND_LENGTH, length)
	var mat := ShaderMaterial.new()
	mat.shader = CROWD_SHADER
	mat.set_shader_parameter("plane_size", plane.size)
	FieldBuilder.stadium_crowd(mat, stadium)
	plane.material = mat
	var crowd := MeshInstance3D.new()
	crowd.mesh = plane
	crowd.rotation = Vector3(slope, 0.0, 0.0)
	crowd.position = Vector3(0.0, 1.6, -0.3) + up_dir * length * 0.5
	crowd.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pivot.add_child(crowd)


func _box(mat: Material, size: Vector3, pos: Vector3) -> MeshInstance3D:
	var b := BoxMesh.new()
	b.size = size
	b.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = b
	mi.position = pos
	add_child(mi)
	return mi


static func _mat(c: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = roughness
	m.metallic = metallic
	return m
