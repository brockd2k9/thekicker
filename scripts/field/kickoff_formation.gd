class_name KickoffFormation
extends Node3D
## Kickoff and onside-kick formations for the 3D kick scene, plus the tee and
## the painted yard numbers. Built by FieldBuilder instead of the field-goal
## formation when the kick is off a tee. Same jointed PlayerFigures and team
## kits as the field-goal units: 21 players, the same count as a field goal.
##
## The ball sits on the tee at the world origin and is kicked toward -Z.
## The kicker is the camera (as in field goals), so 10 coverage players show.
##
##   Kickoff: coverage team in a line one yard behind the ball, across the
##   field. Receiving team: a front line of 5 about 12 yards away, 4 more at
##   about 25 yards, and 2 deep returners at their own 5.
##   Onside: the coverage team bunched 5 and 5 beside the ball; the receiving
##   front line (5 "hands team" players) about 10 yards away, 4 behind them and
##   2 shallow returners.

const YARD := 0.9144
## Real football field: numbers are centered ~12 yards in from each sideline.
const NUMBER_X := 13.4
const NUMBER_SIZE := 0.0185
const STRIDE_LENGTH := 2.6
## Receiving front line backs up this far (m) after the kick, then turns to block.
const FRONT_RETREAT := 9.0
const RETURNER_SPEED := 6.5

## Kickoff: x (m) of the 10 coverage players; z is one yard behind the ball.
const KO_COVER_X := [-22.0, -17.5, -13.0, -8.5, -4.0, 4.0, 8.5, 13.0, 17.5, 22.0]
## Receiving team: [x m, yards downfield] (front line, second line).
const KO_FRONT := [[-15.0, 12.0], [-7.5, 12.0], [0.0, 12.5], [7.5, 12.0], [15.0, 12.0]]
const KO_SECOND := [[-12.0, 26.0], [-4.0, 27.0], [4.0, 27.0], [12.0, 26.0]]
## Deep returners: x (m); they stand at their own 5 (set_spot()).
const KO_DEEP_X := [-6.0, 6.0]

const ON_COVER_X := [-1.5, -3.2, -4.9, -6.6, -8.3, 1.5, 3.2, 4.9, 6.6, 8.3]
const ON_FRONT := [[-8.0, 10.5], [-4.0, 10.5], [0.0, 10.8], [4.0, 10.5], [8.0, 10.5]]
const ON_SECOND := [[-10.0, 16.0], [-3.5, 17.0], [3.5, 17.0], [10.0, 16.0]]
const ON_DEEP := [[-5.0, 25.0], [5.0, 25.0]]

var onside := false
## false when the field's own paint already has the yard numbers (full Field Paint).
var paint_numbers := true

var _cover: Array[PlayerFigure] = []
var _cover_home: Array[Vector3] = []
var _recv: Array[PlayerFigure] = []
var _recv_home: Array[Vector3] = []
## 0 = front line, 1 = second line, 2 = deep returner.
var _recv_role: Array[int] = []
var _numbers: Array[Label3D] = []
var _tee: MeshInstance3D
var _rng: RandomNumberGenerator
## Where the ball is heading (set at the kick), and the returner going for it.
var _target := Vector3.ZERO
var _returner := -1


## kick_type: KickSituation.KickType (KICKOFF or ONSIDE).
func build(kick_type: int, cover_kit: TeamKit, recv_kit: TeamKit,
		rng: RandomNumberGenerator, tee_height: float, ball_scale: float) -> void:
	_rng = rng
	onside = kick_type == KickSituation.KickType.ONSIDE
	var used: Array[int] = []
	for x in (ON_COVER_X if onside else KO_COVER_X):
		var p := _add_player(cover_kit, _number(used, 20, 49), 1.0)
		var home := Vector3(float(x), 0.0, 1.0 * YARD)
		_cover.append(p)
		_cover_home.append(home)
	used.clear()
	var lines := [ON_FRONT, ON_SECOND, ON_DEEP] if onside else [KO_FRONT, KO_SECOND, []]
	for role in 3:
		for spot in lines[role]:
			_add_receiver(recv_kit, used, role, Vector3(float(spot[0]), 0.0, -float(spot[1]) * YARD))
	if not onside:
		for x in KO_DEEP_X:
			_add_receiver(recv_kit, used, 2, Vector3(float(x), 0.0, -60.0 * YARD))  # placed by set_spot()
	_build_tee(tee_height, ball_scale)
	reset()


## The kicking spot (own yard line): places the deep returners at their 5 and
## paints the yard numbers.
func set_spot(spot_yards: int) -> void:
	if not onside:
		var deep_z := -float(100 - spot_yards - 5) * YARD
		for i in _recv.size():
			if _recv_role[i] == 2:
				_recv_home[i].z = deep_z
	for n in _numbers:
		n.queue_free()
	_numbers.clear()
	for yl in range(10, 100, 10):
		if not paint_numbers:
			break
		var z := -float(yl - spot_yards) * YARD
		var shown := yl if yl <= 50 else 100 - yl
		for side in [-1.0, 1.0]:
			var l := Label3D.new()
			l.text = str(shown)
			l.font_size = 96
			l.pixel_size = NUMBER_SIZE
			l.outline_size = 0
			l.modulate = Color(0.97, 0.97, 0.94, 0.92)
			l.shaded = false
			l.double_sided = false
			l.position = Vector3(float(side) * NUMBER_X, 0.02, z)
			l.rotation_degrees = Vector3(-90.0, 0.0, 0.0)  # flat, read from the kicker's end
			add_child(l)
			_numbers.append(l)
	reset()


## Everyone in their pre-kick stance.
func reset() -> void:
	_returner = -1
	for i in _cover.size():
		var p := _cover[i]
		p.position = _cover_home[i]
		p.rotation.y = 0.0  # facing downfield
		p.set_stride(0.0, 0.0)
		p.set_elbows(30.0, 30.0)
		p.set_pose(0.45, 25.0, 25.0)
	for i in _recv.size():
		var p := _recv[i]
		p.position = _recv_home[i]
		p.rotation.y = PI  # facing the kicker
		p.set_stride(0.0, 0.0)
		p.set_elbows(25.0, 25.0)
		var role := _recv_role[i]
		p.set_pose(0.1 if role == 2 else 0.3, 20.0, 20.0)
	if _tee != null:
		_tee.visible = true


## Called at the kick with where the ball will come down (world position).
func kicked(target: Vector3) -> void:
	_target = target
	_tee.visible = true
	# The deep returner closest to the ball goes for it (onside: the nearest receiver).
	var best := INF
	for i in _recv.size():
		if not onside and _recv_role[i] != 2:
			continue
		var d := Vector2(_recv_home[i].x - target.x, _recv_home[i].z - target.z).length()
		if d < best:
			best = d
			_returner = i


## t: seconds since the kick (game time). Cheap: positions and one pose per player.
func update_play(t: float, coverage_speed: float) -> void:
	if t <= 0.0:
		return
	for i in _cover.size():
		var p := _cover[i]
		var home := _cover_home[i]
		var d := _run(t, coverage_speed, 0.5)
		var aim := _target if onside else Vector3(lerpf(home.x, _target.x, 0.35), 0.0, _target.z)
		var dir := Vector3(aim.x - home.x, 0.0, aim.z - home.z)
		var reach := dir.length()
		dir = dir.normalized() if reach > 0.01 else Vector3.FORWARD
		var moved := minf(d, maxf(reach - (1.0 if onside else 4.0), 0.0))
		p.position = home + dir * moved
		p.rotation.y = atan2(-dir.x, -dir.z)
		var still := moved < d - 0.05  # arrived: stop running
		p.set_stride(moved / STRIDE_LENGTH, 0.0 if still else 1.0)
		p.set_pose(0.25, 50.0, 50.0)
	for i in _recv.size():
		var p := _recv[i]
		var home := _recv_home[i]
		if i == _returner:
			_move_to(p, home, Vector3(_target.x, 0.0, maxf(_target.z, home.z - 4.0)), t, RETURNER_SPEED, true)
		elif onside:
			_move_to(p, home, _target, t, 5.0, false)
		elif _recv_role[i] == 0:
			# Turn and run back to set up the return wall, then face the coverage.
			var back := minf(_run(t, 6.0, 0.4), FRONT_RETREAT)
			p.position = home + Vector3(0.0, 0.0, -back)
			var turned := back >= FRONT_RETREAT - 0.05
			p.rotation.y = PI if turned else 0.0
			p.set_stride(back / STRIDE_LENGTH, 0.0 if turned else 1.0)
			p.set_pose(0.35 if turned else 0.2, 70.0 if turned else 40.0, 70.0 if turned else 40.0)
		elif _recv_role[i] == 1:
			_move_to(p, home, Vector3(lerpf(home.x, _target.x, 0.3), 0.0, home.z - 6.0), t, 4.0, false)


func _move_to(p: PlayerFigure, home: Vector3, to: Vector3, t: float, speed: float, catch: bool) -> void:
	var dir := Vector3(to.x - home.x, 0.0, to.z - home.z)
	var reach := dir.length()
	var d := minf(_run(t, speed, 0.4), reach)
	var moved_dir := dir.normalized() if reach > 0.01 else Vector3.BACK
	p.position = home + moved_dir * d
	var arrived := d >= reach - 0.05
	# Run facing where they're going; once there, face the ball coming in.
	p.rotation.y = PI if arrived else atan2(-moved_dir.x, -moved_dir.z)
	p.set_stride(d / STRIDE_LENGTH, 0.0 if arrived else 1.0)
	var arms := 95.0 if (catch and arrived) else 35.0
	p.set_pose(0.15 if arrived else 0.25, arms, arms)


## Distance run after t seconds: accelerate for `accel` s, then constant speed.
static func _run(t: float, speed: float, accel: float) -> float:
	if t < accel:
		return 0.5 * speed / accel * t * t
	return speed * (t - accel * 0.5)


func _add_receiver(kit: TeamKit, used: Array[int], role: int, home: Vector3) -> void:
	var num := _number(used, 20, 49) if role == 2 else _number(used, 30, 99)
	var p := _add_player(kit, num, 1.0 if role == 2 else 1.1)
	_recv.append(p)
	_recv_home.append(home)
	_recv_role.append(role)


func _add_player(kit: TeamKit, number: int, bulk: float) -> PlayerFigure:
	var p := PlayerFigure.new()
	add_child(p)
	p.build(kit, number, _rng, bulk)
	return p


func _number(used: Array[int], lo: int, hi: int) -> int:
	for attempt in 20:
		var n := _rng.randi_range(lo, hi)
		if not used.has(n):
			used.append(n)
			return n
	return _rng.randi_range(lo, hi)


## A small orange kicking tee, drawn at the ball's visual scale.
func _build_tee(height: float, ball_scale: float) -> void:
	_tee = make_tee(height, ball_scale)
	add_child(_tee)


## The kicking tee mesh (shared with SidelineSet), standing at the local origin.
static func make_tee(height: float, ball_scale: float) -> MeshInstance3D:
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.025 * ball_scale
	cyl.bottom_radius = 0.055 * ball_scale
	cyl.height = height * ball_scale
	cyl.radial_segments = 12
	cyl.rings = 1
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(1.0, 0.45, 0.05)
	m.roughness = 0.5
	cyl.material = m
	var tee := MeshInstance3D.new()
	tee.mesh = cyl
	tee.position = Vector3(0.0, cyl.height * 0.5, 0.0)
	return tee
