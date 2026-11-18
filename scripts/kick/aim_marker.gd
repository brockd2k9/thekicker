class_name AimMarker
extends Node3D
## Ring floating above the crossbar showing where a perfectly straight swipe
## would go right now. Under pressure it drifts (the wobble), so the player can
## see it and time/compensate their swipe. Wind is NOT shown here.

@export var color: Color = Color(1.0, 1.0, 1.0, 0.85)
@export var height_above_bar: float = 2.5

var _ring: MeshInstance3D


func _ready() -> void:
	var torus := TorusMesh.new()
	torus.inner_radius = 0.38
	torus.outer_radius = 0.5
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	mat.albedo_color = color
	torus.material = mat
	_ring = MeshInstance3D.new()
	_ring.mesh = torus
	_ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)  # face the camera
	add_child(_ring)


func set_aim(yaw_deg: float, distance_m: float) -> void:
	position = Vector3(
		tan(deg_to_rad(yaw_deg)) * distance_m,
		GoalPosts.CROSSBAR_HEIGHT + height_above_bar,
		-distance_m)
	scale = Vector3.ONE * clampf(distance_m / 18.0, 1.0, 3.5)
