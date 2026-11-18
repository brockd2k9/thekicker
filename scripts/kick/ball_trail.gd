class_name BallTrail
extends MultiMeshInstance3D
## Dotted trail of the ball's arc so the trajectory is easy to read.
## Keep this node at the world origin (instances are placed in world space).

@export var max_dots: int = 90
## Seconds (game time) between dots.
@export var interval: float = 0.035
## Dot diameter near the kicker; grows with distance so far dots stay visible.
@export var dot_size: float = 0.12
@export var color: Color = Color(1.0, 1.0, 1.0, 0.75)

var _ball: Ball
var _timer := 0.0
var _count := 0


func _ready() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.radial_segments = 8
	sphere.rings = 4
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = color
	sphere.material = mat

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = sphere
	mm.instance_count = max_dots
	mm.visible_instance_count = 0
	multimesh = mm


func clear() -> void:
	_ball = null
	_count = 0
	multimesh.visible_instance_count = 0


func start(ball: Ball) -> void:
	clear()
	_ball = ball
	_timer = 0.0


func _physics_process(delta: float) -> void:
	if _ball == null or not _ball.in_flight or _count >= max_dots:
		return
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = interval
	var p := _ball.global_position
	var s := dot_size * (1.0 + absf(p.z) / 20.0)
	multimesh.set_instance_transform(_count, Transform3D(Basis.from_scale(Vector3.ONE * s), p))
	_count += 1
	multimesh.visible_instance_count = _count
