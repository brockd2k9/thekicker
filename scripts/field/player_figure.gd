class_name PlayerFigure
extends Node3D
## Placeholder football player built from capsules: legs, torso, helmet with
## facemask, and two arms on shoulder pivots so it can crouch, lean, block
## and jump. Local forward is -Z (rotate the node to face another way).

const HEIGHT := 1.85

var _root: Node3D
var _legs: MeshInstance3D
var _hips: Node3D
var _arm_l: Node3D
var _arm_r: Node3D


## Call once after creating. Returns self so it can be chained.
func build(jersey: Color, pants: Color, helmet: Color) -> PlayerFigure:
	_root = Node3D.new()
	add_child(_root)
	var jersey_mat := _mat(jersey, 0.85)
	var helmet_mat := _mat(helmet, 0.25)
	helmet_mat.metallic = 0.3

	var legs := CapsuleMesh.new()
	legs.radius = 0.22
	legs.height = 0.95
	legs.material = _mat(pants, 0.9)
	_legs = _add(_root, legs, Vector3(0.0, 0.475, 0.0))

	_hips = Node3D.new()
	_root.add_child(_hips)
	var torso := CapsuleMesh.new()
	torso.radius = 0.34
	torso.height = 0.95
	torso.material = jersey_mat
	var t := _add(_hips, torso, Vector3(0.0, 0.42, 0.0))
	t.scale = Vector3(1.15, 1.0, 0.85)  # shoulder pads
	var head := SphereMesh.new()
	head.radius = 0.17
	head.height = 0.34
	head.material = helmet_mat
	_add(_hips, head, Vector3(0.0, 1.0, 0.0))
	var mask := BoxMesh.new()
	mask.size = Vector3(0.2, 0.09, 0.05)
	mask.material = _mat(Color(0.25, 0.25, 0.27), 0.5)
	_add(_hips, mask, Vector3(0.0, 0.95, -0.17))

	_arm_l = _make_arm(-1.0, jersey_mat)
	_arm_r = _make_arm(1.0, jersey_mat)
	set_pose(0.0, 15.0, 15.0)
	return self


## crouch: 0 = standing tall, 1 = deep three-point stance.
## Arm angles in degrees: 0 = hanging down, 90 = straight forward, 170 = up.
## lift: meters off the ground (jumping).
func set_pose(crouch: float, arm_l_deg: float, arm_r_deg: float, lift: float = 0.0) -> void:
	var c := clampf(crouch, 0.0, 1.0)
	_legs.scale.y = lerpf(1.0, 0.62, c)
	_legs.position.y = 0.475 * _legs.scale.y
	_hips.position.y = lerpf(0.9, 0.58, c)
	_hips.rotation.x = deg_to_rad(-lerpf(6.0, 55.0, c))
	_arm_l.rotation.x = deg_to_rad(arm_l_deg)
	_arm_r.rotation.x = deg_to_rad(arm_r_deg)
	_root.position.y = lift


func _make_arm(side: float, mat: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = Vector3(side * 0.44, 0.72, 0.0)
	_hips.add_child(pivot)
	var arm := CapsuleMesh.new()
	arm.radius = 0.085
	arm.height = 0.8
	arm.material = mat
	_add(pivot, arm, Vector3(0.0, -0.36, 0.0))
	return pivot


static func _add(parent: Node, mesh: Mesh, pos: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	parent.add_child(mi)
	return mi


static func _mat(c: Color, roughness: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = roughness
	return m
