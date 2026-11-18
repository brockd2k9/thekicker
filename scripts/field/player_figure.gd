class_name PlayerFigure
extends Node3D
## A football player built from simple meshes, with a skeleton of joints
## (hips, knees, waist, shoulders, elbows) so it can get into a stance, run,
## block, jump, dive and kneel.
##
## Uniform: jersey with numbers and side panels (jersey.gdshader), shoulder
## pads, sleeves with trim, gloves, belted pants with a stripe, socks, cleats,
## and a helmet with a center stripe, side decals, face opening and facemask.
## Local forward is -Z (rotate the node to face another way).

const THIGH := 0.46
const SHIN := 0.46
const FOOT := 0.07
const UPPER_ARM := 0.3
const SKIN_TONES := [
	Color(0.96, 0.8, 0.66), Color(0.87, 0.67, 0.5), Color(0.66, 0.46, 0.32),
	Color(0.47, 0.31, 0.2), Color(0.33, 0.21, 0.14),
]

## Kneel on the right knee (the holder). Overrides the leg pose.
var kneeling := false

var _root: Node3D
var _pelvis: Node3D
var _hip_l: Node3D
var _hip_r: Node3D
var _knee_l: Node3D
var _knee_r: Node3D
var _torso: Node3D
var _shoulder_l: Node3D
var _shoulder_r: Node3D
var _elbow_l: Node3D
var _elbow_r: Node3D
var _bulk := 1.0
var _stride_phase := 0.0
var _stride_amount := 0.0
var _elbow_deg := Vector2(20.0, 20.0)


## Call once after creating. bulk: 1 = skill player, ~1.2 = lineman.
func build(kit: TeamKit, number: int, rng: RandomNumberGenerator,
		bulk: float = 1.0) -> PlayerFigure:
	_bulk = bulk
	var skin_c: Color = SKIN_TONES[rng.randi_range(0, SKIN_TONES.size() - 1)]
	var skin := StandardMaterial3D.new()
	skin.albedo_color = skin_c
	skin.roughness = 0.6
	var pants := kit.mat("pants", kit.pants, 0.7)
	var stripe := kit.mat("pants_stripe", kit.pants_stripe, 0.7)
	var socks := kit.mat("socks", kit.socks, 0.9)
	var cleats := kit.mat("cleats", Color(0.06, 0.06, 0.07), 0.4)
	var jersey_flat := kit.mat("jersey", kit.jersey, 0.75)
	var trim := kit.mat("trim", kit.trim, 0.75)
	var gloves := kit.mat("gloves", kit.gloves, 0.6)
	# Some players wear compression sleeves on the forearms.
	var forearm := skin
	if rng.randf() < 0.35:
		var use_trim := rng.randf() < 0.5
		forearm = kit.mat("sleeve_trim" if use_trim else "sleeve_jersey",
			kit.trim if use_trim else kit.jersey, 0.6)

	_root = _node(self, Vector3.ZERO)
	_pelvis = _node(_root, Vector3(0.0, THIGH + SHIN + FOOT, 0.0))

	# Hips + belt.
	_mesh(_pelvis, _sphere(0.2), pants, Vector3(0.0, 0.02, 0.0), Vector3(1.0 * bulk, 0.75, 0.75))
	_mesh(_pelvis, _cyl(0.19 * bulk, 0.05), kit.mat("belt", Color(0.08, 0.08, 0.08), 0.5),
		Vector3(0.0, 0.11, 0.0), Vector3(1.0, 1.0, 0.75))

	# Legs.
	var legs: Array[Node3D] = []
	for side in [-1.0, 1.0]:
		var s: float = side
		var hip := _node(_pelvis, Vector3(s * 0.11 * bulk, 0.0, 0.0))
		_mesh(hip, _capsule(0.09 * bulk, THIGH + 0.08), pants, Vector3(0.0, -THIGH * 0.5, 0.0))
		_mesh(hip, _box(Vector3(0.02, THIGH * 0.8, 0.05)), stripe,
			Vector3(s * 0.088 * bulk, -THIGH * 0.5, 0.0))
		var knee := _node(hip, Vector3(0.0, -THIGH, 0.0))
		_mesh(knee, _cyl(0.078 * bulk, 0.14), pants, Vector3(0.0, -0.04, 0.0))
		_mesh(knee, _capsule(0.062 * bulk, SHIN), socks, Vector3(0.0, -SHIN * 0.55, 0.0))
		_mesh(knee, _box(Vector3(0.11, FOOT, 0.28)), cleats, Vector3(0.0, -SHIN - FOOT * 0.5, -0.06))
		legs.append(hip)
		legs.append(knee)
	_hip_l = legs[0]
	_knee_l = legs[1]
	_hip_r = legs[2]
	_knee_r = legs[3]

	# Torso (waist pivot), jersey with numbers.
	_torso = _node(_pelvis, Vector3(0.0, 0.08, 0.0))
	var torso_mesh := MeshInstance3D.new()
	torso_mesh.mesh = _torso_mesh(bulk)
	torso_mesh.material_override = kit.jersey_material(number)
	_torso.add_child(torso_mesh)
	# Shoulder pads under the jersey: the classic silhouette.
	_mesh(_torso, _sphere(0.2), jersey_flat, Vector3(0.0, 0.55, 0.0),
		Vector3(1.75 * bulk, 0.62, 1.2 * bulk))
	_mesh(_torso, _cyl(0.065, 0.16), skin, Vector3(0.0, 0.66, 0.0))
	_build_helmet(_node(_torso, Vector3(0.0, 0.82, 0.0)), kit, skin)

	# Arms.
	var arms: Array[Node3D] = []
	for side in [-1.0, 1.0]:
		var s: float = side
		var sh := _node(_torso, Vector3(s * 0.31 * bulk, 0.52, 0.0))
		_mesh(sh, _capsule(0.066 * bulk, UPPER_ARM + 0.06), skin, Vector3(0.0, -UPPER_ARM * 0.5, 0.0))
		_mesh(sh, _cyl(0.088 * bulk, 0.16), jersey_flat, Vector3(0.0, -0.06, 0.0))
		_mesh(sh, _cyl(0.09 * bulk, 0.025), trim, Vector3(0.0, -0.135, 0.0))
		var el := _node(sh, Vector3(0.0, -UPPER_ARM, 0.0))
		_mesh(el, _capsule(0.056 * bulk, 0.3), forearm, Vector3(0.0, -0.14, 0.0))
		_mesh(el, _cyl(0.06 * bulk, 0.04), kit.mat("wristband", Color(0.95, 0.95, 0.95), 0.8),
			Vector3(0.0, -0.25, 0.0))
		_mesh(el, _sphere(0.05), gloves, Vector3(0.0, -0.33, 0.0), Vector3(0.95, 1.5, 0.6))
		arms.append(sh)
		arms.append(el)
	_shoulder_l = arms[0]
	_elbow_l = arms[1]
	_shoulder_r = arms[2]
	_elbow_r = arms[3]

	set_pose(0.0, 15.0, 15.0)
	return self


## crouch: 0 = standing tall, 1 = deep three-point stance.
## Arm angles in degrees: 0 = hanging down, 90 = straight forward, 170 = up.
## lift: meters off the ground (jumping).
## dive: 0 = upright, 1 = fully laid out forward (diving at the kick).
func set_pose(crouch: float, arm_l_deg: float, arm_r_deg: float, lift: float = 0.0,
		dive: float = 0.0) -> void:
	var c := clampf(crouch, 0.0, 1.0)
	var swing := sin(_stride_phase * TAU) * _stride_amount

	if kneeling:
		# Left foot planted, right knee on the turf.
		_hip_l.rotation.x = deg_to_rad(90.0)
		_knee_l.rotation.x = deg_to_rad(-90.0)
		_hip_r.rotation.x = deg_to_rad(-5.0)
		_knee_r.rotation.x = deg_to_rad(-90.0)
		_pelvis.position.y = SHIN + FOOT
	else:
		# Bent knees with the feet under the hips; strides swing the thighs.
		var a := deg_to_rad(lerpf(6.0, 50.0, c))
		var sw := deg_to_rad(38.0) * swing
		_hip_l.rotation.x = a + sw
		_hip_r.rotation.x = a - sw
		_knee_l.rotation.x = -2.0 * a - deg_to_rad(70.0) * maxf(-swing, 0.0)
		_knee_r.rotation.x = -2.0 * a - deg_to_rad(70.0) * maxf(swing, 0.0)
		_pelvis.position.y = (THIGH + SHIN) * cos(a) + FOOT - 0.04 * absf(swing)

	_torso.rotation.x = deg_to_rad(-lerpf(4.0, 48.0, c) - 12.0 * _stride_amount)
	# Arms pump opposite the legs when running.
	var pump := 45.0 * swing
	_shoulder_l.rotation.x = deg_to_rad(arm_l_deg - pump)
	_shoulder_r.rotation.x = deg_to_rad(arm_r_deg + pump)
	_elbow_l.rotation.x = deg_to_rad(_elbow_deg.x + 50.0 * _stride_amount)
	_elbow_r.rotation.x = deg_to_rad(_elbow_deg.y + 50.0 * _stride_amount)
	_root.position.y = lift
	_root.rotation.x = deg_to_rad(-80.0) * clampf(dive, 0.0, 1.0)


## Elbow bend in degrees (0 = straight). Applied on the next set_pose().
func set_elbows(left_deg: float, right_deg: float) -> void:
	_elbow_deg = Vector2(left_deg, right_deg)


## Running: phase in strides (keep increasing it), amount 0..1. Applied on the
## next set_pose().
func set_stride(phase: float, amount: float) -> void:
	_stride_phase = phase
	_stride_amount = clampf(amount, 0.0, 1.0)


# --- building -------------------------------------------------------------------

func _build_helmet(h: Node3D, kit: TeamKit, skin: Material) -> void:
	var shell := kit.mat("helmet", kit.helmet, 0.22, 0.25)
	var mask := kit.mat("facemask", kit.facemask, 0.35, 0.6)
	# Face inside the opening, then the shell with an opening cut by a dark band.
	_mesh(h, _sphere(0.1), skin, Vector3(0.0, -0.03, -0.06), Vector3(0.95, 1.05, 1.0))
	_mesh(h, _sphere(0.15), shell, Vector3(0.0, 0.0, 0.015), Vector3(1.0, 1.0, 1.12))
	_mesh(h, _sphere(0.1), kit.mat("face_shadow", Color(0.05, 0.05, 0.06), 0.9),
		Vector3(0.0, -0.035, -0.13), Vector3(1.05, 0.8, 0.45))
	_mesh(h, _sphere(0.152), kit.mat("helmet_stripe", kit.helmet_stripe, 0.3),
		Vector3(0.0, 0.0, 0.015), Vector3(0.14, 1.0, 1.12))
	# Side decals and ear holes.
	for side in [-1.0, 1.0]:
		var s: float = side
		var decal := _mesh(h, _cyl(0.05, 0.012), kit.mat("decal", kit.helmet_stripe, 0.3),
			Vector3(s * 0.145, 0.02, 0.02))
		decal.rotation_degrees = Vector3(0.0, 0.0, 90.0)
		var ear := _mesh(h, _cyl(0.015, 0.012), kit.mat("ear", Color(0.05, 0.05, 0.05), 0.9),
			Vector3(s * 0.15, -0.035, -0.03))
		ear.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	# Facemask cage: three horizontal bars, two vertical, chin cup.
	for i in 3:
		var bar := _mesh(h, _cyl(0.009, 0.2 - i * 0.02), mask,
			Vector3(0.0, -0.005 - i * 0.045, -0.172 + i * 0.006))
		bar.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	for side in [-1.0, 1.0]:
		var s: float = side
		_mesh(h, _cyl(0.008, 0.11), mask, Vector3(s * 0.045, -0.05, -0.17))
		var cheek := _mesh(h, _cyl(0.008, 0.08), mask, Vector3(s * 0.1, -0.04, -0.14))
		cheek.rotation_degrees = Vector3(0.0, s * 35.0, 0.0)
	_mesh(h, _box(Vector3(0.08, 0.035, 0.05)), kit.mat("chin", Color(0.95, 0.95, 0.95), 0.6),
		Vector3(0.0, -0.13, -0.13))


## Tapered torso with UVs for the jersey shader (u = around from the chest,
## v = 0 at the waist up to 1 at the collar). Flattened front-to-back.
static func _torso_mesh(bulk: float) -> ArrayMesh:
	var profile := [Vector2(0.19, 0.0), Vector2(0.21, 0.15), Vector2(0.24, 0.35),
		Vector2(0.26, 0.5), Vector2(0.22, 0.62)]
	var segments := 24
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for i in profile.size():
		var p: Vector2 = profile[i]
		var prev: Vector2 = profile[maxi(i - 1, 0)]
		var next: Vector2 = profile[mini(i + 1, profile.size() - 1)]
		var slope := (next.x - prev.x) / maxf(next.y - prev.y, 0.001)
		for j in segments + 1:
			var ang := TAU * float(j) / segments
			var dir := Vector3(sin(ang), 0.0, -cos(ang))
			var r := p.x * bulk
			verts.append(Vector3(dir.x * r, p.y, dir.z * r * 0.72))
			normals.append((dir - Vector3(0.0, slope, 0.0)).normalized())
			uvs.append(Vector2(float(j) / segments, p.y / 0.62))
	for i in profile.size() - 1:
		for j in segments:
			var a0 := i * (segments + 1) + j
			var b0 := a0 + segments + 1
			for idx in [a0, a0 + 1, b0, a0 + 1, b0 + 1, b0]:
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


static func _node(parent: Node, pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	parent.add_child(n)
	return n


static func _mesh(parent: Node, mesh: Mesh, mat: Material, pos: Vector3,
		scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.scale = scl
	parent.add_child(mi)
	return mi


static func _sphere(r: float) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = 16
	m.rings = 8
	return m


static func _capsule(r: float, h: float) -> CapsuleMesh:
	var m := CapsuleMesh.new()
	m.radius = r
	m.height = maxf(h, r * 2.0)
	m.radial_segments = 12
	m.rings = 4
	return m


static func _cyl(r: float, h: float) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = r
	m.bottom_radius = r
	m.height = h
	m.radial_segments = 12
	m.rings = 1
	return m


static func _box(size: Vector3) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = size
	return m
