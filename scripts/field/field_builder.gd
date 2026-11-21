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
## "Play progress" t runs 0 -> 1 from the snap to the end of the kick window.
## What the defense does is decided per attempt by a RushPlan (who rushes,
## who leaps, dives or gets hands up); its one designated blocker reaches the
## ball at t = 1 (= BLOCKED).

enum HolderPose { READY, HOLDING, RELEASED }

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
const BLEACHER_RAIL := Color(0.62, 0.64, 0.68)
## Sideline stands (wings): distance from the middle of the field.
const WING_X := 38.0

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
const EDGE_FROM := [Vector3(-5.6, 0.0, -7.6), Vector3(5.6, 0.0, -7.6)]
const EDGE_TO := [Vector3(-0.8, 0.0, -0.9), Vector3(0.8, 0.0, -0.9)]
## Holder kneels on the kicker's left, facing the ball.
const HOLDER_POS := Vector3(-0.8, 0.0, 0.3)
## Meters per full running cycle (two steps). Legs cycle in step with speed.
const STRIDE_LENGTH := 2.6

var _field_mat: ShaderMaterial
var _ol: Array[PlayerFigure] = []
var _ol_home: Array[Vector3] = []
var _dl: Array[PlayerFigure] = []
var _dl_home: Array[Vector3] = []
var _leaper: PlayerFigure
var _edges: Array[PlayerFigure] = []
var _holder: PlayerFigure
var _home_kit := TeamKit.home()
var _away_kit := TeamKit.away()
## Optional uniforms (Career Mode team colors). Set before the scene enters the
## tree (field_goal_game.gd set_look()); null = the default kits.
var home_kit_override: TeamKit
var away_kit_override: TeamKit
## The stadium (StadiumSpec). Set before the scene enters the tree
## (field_goal_game.gd set_look()); null = the original stadium.
var stadium: StadiumSpec
var _stadium: StadiumSpec
var _rng := RandomNumberGenerator.new()
var _plan: RushPlan
## KickSituation.KickType. Set before the scene enters the tree
## (field_goal_game.gd does it from the mode). Tee kicks build a
## KickoffFormation instead of the field-goal units; the rest of the stadium
## is the same.
var kick_type: int = KickSituation.KickType.FIELD_GOAL
## The kickoff / onside formation (null for field goals and extra points).
var kickoff: KickoffFormation
## The sideline with the warmup net (WARMUP_NET only; null otherwise).
var sideline: SidelineSet
## Where the sideline set (its tee) stands: x from the middle of the field.
var sideline_x := 29.0
## Visual tee size (set with kick_type, from KickTuning).
var tee_height := 0.05
var tee_ball_scale := 2.5

@onready var goal_end: Node3D = $GoalEnd
@onready var goal_posts: GoalPosts = $GoalEnd/GoalPosts


func _ready() -> void:
	if home_kit_override != null:
		_home_kit = home_kit_override
	if away_kit_override != null:
		_away_kit = away_kit_override
	_stadium = stadium if stadium != null else StadiumSpec.new()
	_build_ground()
	_build_stands()
	if kick_type == KickSituation.KickType.WARMUP_NET:
		# Empty field (the game goes on without you); you're on the sideline.
		_rng.randomize()
		sideline = SidelineSet.new()
		sideline.stadium = _stadium
		sideline.position = Vector3(sideline_x, 0.0, 0.0)
		add_child(sideline)
		sideline.build(_home_kit, _rng, tee_height, tee_ball_scale)
	elif KickSituation.is_tee_type(kick_type):
		_rng.randomize()
		kickoff = KickoffFormation.new()
		add_child(kickoff)
		kickoff.build(kick_type, _home_kit, _away_kit, _rng, tee_height, tee_ball_scale)
	else:
		_build_formation()


func set_distance(distance_m: float) -> void:
	goal_end.position = Vector3(0.0, 0.0, -distance_m)
	_field_mat.set_shader_parameter("goal_z", -distance_m)


## How loud this stadium's crowd is (0-1): a hook for crowd sound later.
func crowd_level() -> float:
	return _stadium.crowd_level if _stadium != null else 0.8


func set_wind(mph: float, max_mph: float, along: float = 0.0) -> void:
	goal_posts.set_wind(mph, max_mph, along)


## Where the holder puts the tip of the ball.
func hold_spot() -> Vector3:
	return Vector3.ZERO


## Where the ball sits in the long snapper's hands before the snap.
func snap_spot() -> Vector3:
	return Vector3(0.0, 0.2, LOS_Z)


## Where the holder catches the snap.
func catch_spot() -> Vector3:
	return Vector3(0.0, 1.05, 0.3)


## Everyone back in their pre-snap stance; holder showing a target.
## plan: this attempt's block call (see RushPlan). Null = a default plan.
func reset_play(plan: RushPlan = null) -> void:
	_plan = plan if plan != null else RushPlan.new()
	if _plan.dl_action.is_empty():
		for i in _dl.size():
			_plan.dl_action.append(RushPlan.Action.PUSH)
			_plan.dl_timing.append(0.8)
			_plan.dl_shift.append(Vector2.ZERO)
	set_play_progress(0.0)
	set_holder_pose(HolderPose.READY)


## Glove positions of every defender, for checking whether a kick gets tipped.
func defender_hands() -> Array[Vector3]:
	var out: Array[Vector3] = []
	for p in _dl:
		out.append_array(p.hand_positions())
	for p in _edges:
		out.append_array(p.hand_positions())
	out.append_array(_leaper.hand_positions())
	return out


## x of each block-unit lineman, for RushPlan.roll().
func dl_x_positions() -> PackedFloat32Array:
	var xs := PackedFloat32Array()
	for s in DL_SPOTS:
		var spot: Vector2 = s
		xs.append(spot.x)
	return xs


func set_holder_pose(pose: HolderPose) -> void:
	# The reaching arm is the far one (left), so the camera still sees the ball.
	match pose:
		HolderPose.READY:
			_holder.set_elbows(35.0, 35.0)
			_holder.set_pose(0.5, 100.0, 100.0)  # both hands up, a target for the snap
		HolderPose.HOLDING:
			_holder.set_elbows(0.0, 20.0)
			_holder.set_pose(0.5, 79.0, 20.0)  # fingertip on top of the ball
		HolderPose.RELEASED:
			_holder.set_elbows(20.0, 20.0)
			_holder.set_pose(0.5, 150.0, 20.0)  # pulled away after the kick


## t: 0 = at the snap, 1 = kick window expired (the plan's blocker reaches the ball).
## t keeps going past 1 after the kick so runners carry on through the play.
func set_play_progress(t: float) -> void:
	t = maxf(t, 0.0)
	var plan := _plan
	var fire := smoothstep(0.0, 0.25, t)  # how far out of their stance
	var push := pow(minf(t, 1.0), 1.3)
	var stance_arms := lerpf(35.0, 85.0, fire)

	for i in _ol.size():
		# Stand up, absorb the rush, give a little ground.
		_ol[i].position = _ol_home[i] + Vector3(0.0, 0.0, plan.ol_give * push)
		# Stay fairly low so the kicker can see the crossbar over them.
		_ol[i].set_elbows(lerpf(10.0, 45.0, fire), lerpf(10.0, 45.0, fire))
		_ol[i].set_pose(1.0 - 0.45 * fire, stance_arms, stance_arms)

	for i in _dl.size():
		var shift: Vector2 = plan.dl_shift[i]
		var home := _dl_home[i] + Vector3(shift.x, 0.0, shift.y)
		if i == plan.penetrator:
			_animate_penetrator(_dl[i], home, t, fire)
		else:
			_animate_lineman(_dl[i], home, plan.dl_action[i], plan.dl_timing[i], minf(t, 1.0),
				fire, push)

	_animate_leaper(t, fire)
	for e in _edges.size():
		_animate_edge(e, t, fire)


func _animate_lineman(p: PlayerFigure, home: Vector3, action: int, timing: float,
		t: float, fire: float, push: float) -> void:
	p.rotation.y = PI  # facing us
	p.set_stride(0.0, 0.0)
	p.set_elbows(lerpf(10.0, 40.0, fire), lerpf(10.0, 40.0, fire))
	var crouch := 1.0 - 0.7 * fire
	var arms := lerpf(35.0, 85.0, fire)
	var pos := home + Vector3(0.0, 0.0, 0.5 * push)
	var rise := smoothstep(timing - 0.25, timing, t)
	match action:
		RushPlan.Action.HANDS_UP:
			arms = lerpf(arms, 170.0, rise)
			crouch = lerpf(crouch, 0.0, rise)
			p.set_elbows(lerpf(40.0, 5.0, rise), lerpf(40.0, 5.0, rise))
			p.set_pose(crouch, arms, arms)
		RushPlan.Action.LEAP:
			# Jump, then come back down.
			var hop := rise * (1.0 - smoothstep(timing + 0.1, timing + 0.3, t))
			arms = lerpf(arms, 170.0, rise)
			p.set_pose(lerpf(crouch, 0.0, rise), arms, arms, 0.5 * hop)
		RushPlan.Action.DIVE:
			# Lunge forward over the protection and end up laid out on the turf.
			pos.z += 1.1 * rise
			var air := sin(rise * PI) * 0.35
			p.set_pose(crouch * (1.0 - rise), lerpf(arms, 160.0, rise),
				lerpf(arms, 160.0, rise), air, rise)
		_:
			p.set_pose(crouch, arms, arms)
	p.position = pos


## Breaks through the middle at full speed and dives at the ball at the end.
func _animate_penetrator(p: PlayerFigure, home: Vector3, t: float, fire: float) -> void:
	var target := Vector3(signf(home.x) * 0.35, 0.0, -0.9)
	var length := home.distance_to(target)
	var dist := minf(run_fraction(t, _plan.penetrator_accel) * length, length)
	var dir := (target - home).normalized()
	p.position = home + dir * dist
	p.rotation.y = atan2(-dir.x, -dir.z)
	var dive := smoothstep(0.85, 1.0, t)
	p.set_stride(dist / STRIDE_LENGTH, fire * (1.0 - dive))
	p.set_elbows(lerpf(60.0, 5.0, dive), lerpf(60.0, 5.0, dive))
	var arms := lerpf(lerpf(35.0, 70.0, fire), 160.0, dive)
	p.set_pose(lerpf(1.0, 0.4, fire), arms, arms, 0.3 * sin(dive * PI), dive * 0.8)


func _animate_leaper(t: float, fire: float) -> void:
	var plan := _plan
	var timing := plan.leaper_timing
	var rise := smoothstep(timing - 0.2, timing, t)
	_leaper.rotation.y = PI
	# Steady walk-up to the line, arriving just as he jumps.
	var walk := clampf(run_fraction(t, 0.15) / run_fraction(timing - 0.1, 0.15), 0.0, 1.0)
	_leaper.position = Vector3(LEAPER_SPOT.x, 0.0, LOS_Z + LEAPER_SPOT.y + 1.0 * walk)
	_leaper.set_stride(walk * 1.2, 0.5 * fire * (1.0 - walk))
	var arms := lerpf(40.0, 85.0, fire)
	match plan.leaper_action:
		RushPlan.Action.LEAP:
			var hop := rise * (1.0 - smoothstep(timing + 0.1, timing + 0.3, t))
			arms = lerpf(arms, 170.0, rise)
			_leaper.set_pose(0.6 - 0.6 * fire, arms, arms, 0.6 * hop)
		RushPlan.Action.HANDS_UP:
			arms = lerpf(arms, 170.0, rise)
			_leaper.set_pose(0.6 - 0.6 * fire, arms, arms)
		_:
			_leaper.set_pose(0.6 - 0.3 * fire, arms, arms)


## Edge rushers run nonstop from the snap. The designated blocker arrives at
## the ball as the window closes; the other is pushed wide by the wing and keeps
## running past the play.
func _animate_edge(e: int, t: float, fire: float) -> void:
	var plan := _plan
	var p := _edges[e]
	var from: Vector3 = EDGE_FROM[e]
	var to: Vector3 = EDGE_TO[e]
	var accel := plan.edge_accel[e]
	p.set_elbows(30.0, 30.0)

	if not plan.edge_is_blocker[e]:
		var side := signf(from.x)
		var path := [from, Vector3(side * 2.7, 0.0, -1.8), Vector3(side * 2.5, 0.0, 3.5)]
		var first_leg := from.distance_to(path[1])
		var dist := run_fraction(t, accel) * first_leg / run_fraction(plan.edge_wide_time[e], accel)
		p.position = _along(path, dist)
		var ahead := _along(path, dist + 0.1) - p.position
		p.rotation.y = atan2(-ahead.x, -ahead.z)
		p.set_stride(dist / STRIDE_LENGTH, fire)
		p.set_pose(0.9 - 0.6 * fire, 50.0, 50.0)
		return

	var length := from.distance_to(to)
	var dist := minf(run_fraction(t, accel) * length, length)
	var dir := (to - from).normalized()
	p.position = from + dir * dist
	p.rotation.y = atan2(-dir.x, -dir.z)
	var finish := smoothstep(0.85, 1.0, t)
	p.set_stride(dist / STRIDE_LENGTH, fire * (1.0 - finish))
	p.set_elbows(lerpf(70.0, 5.0, finish), lerpf(70.0, 5.0, finish))
	if plan.edge_dives[e]:
		var arms := lerpf(40.0, 160.0, finish)
		p.set_pose(0.9 - 0.6 * fire, arms, arms, 0.3 * sin(finish * PI), finish * 0.85)
	else:
		var arms := lerpf(40.0, 170.0, finish)
		p.set_pose(lerpf(0.9 - 0.6 * fire, 0.0, finish), arms, arms, 0.45 * finish)


## Fraction of a run covered at play time t: a short burst of acceleration off the
## snap (accel = fraction of the play spent speeding up), then constant speed.
## Reaches 1 at t = 1 and keeps growing after, so runners never slow or stop.
static func run_fraction(t: float, accel: float) -> float:
	if t <= 0.0:
		return 0.0
	var a := clampf(accel, 0.01, 0.9)
	var norm := 1.0 - a * 0.5
	if t < a:
		return t * t / (2.0 * a) / norm
	return (t - a * 0.5) / norm


## Point at distance d along a polyline; carries on straight past the last point.
static func _along(points: Array, d: float) -> Vector3:
	for i in points.size() - 1:
		var a: Vector3 = points[i]
		var b: Vector3 = points[i + 1]
		var seg := a.distance_to(b)
		if d <= seg or i == points.size() - 2:
			return a + (b - a).normalized() * d
		d -= seg
	return points[0]


# --- building -------------------------------------------------------------------

func _build_ground() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(240.0, 360.0)
	plane.subdivide_width = 8
	plane.subdivide_depth = 8
	_field_mat = ShaderMaterial.new()
	_field_mat.shader = FIELD_SHADER
	plane.material = _field_mat
	_field_mat.set_shader_parameter("hash_x", _stadium.hash_x)
	if _stadium.endzone.a > 0.0:
		_field_mat.set_shader_parameter("endzone_color", _stadium.endzone)
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.position = Vector3(0.0, 0.0, -120.0)
	add_child(mi)


func _build_formation() -> void:
	_rng.randomize()
	var used: Array[int] = []
	for s in OL_SPOTS:
		var spot: Vector2 = s
		var wing := absf(spot.x) > 3.0
		var num := _number(used, 80, 89) if wing else _number(used, 50, 79)
		var p := _add_player(_home_kit, num, 1.05 if wing else 1.2)
		var home := Vector3(spot.x, 0.0, LOS_Z + spot.y)
		p.position = home
		if wing:
			p.rotation.y = -signf(spot.x) * deg_to_rad(25.0)  # wings angle out
		_ol.append(p)
		_ol_home.append(home)
	used.clear()
	for s in DL_SPOTS:
		var spot: Vector2 = s
		var big := absf(spot.x) < 2.0
		var num := _number(used, 90, 99) if big else _number(used, 40, 59)
		var p := _add_player(_away_kit, num, 1.2 if big else 1.08)
		var home := Vector3(spot.x, 0.0, LOS_Z + spot.y)
		p.position = home
		p.rotation.y = PI  # facing us
		_dl.append(p)
		_dl_home.append(home)
	_leaper = _add_player(_away_kit, _number(used, 20, 39), 1.0)
	_leaper.rotation.y = PI
	for i in EDGE_FROM.size():
		_edges.append(_add_player(_away_kit, _number(used, 40, 59), 1.0))

	_holder = _add_player(_home_kit, _rng.randi_range(1, 19), 0.95)
	_holder.kneeling = true
	_holder.position = HOLDER_POS
	_holder.rotation.y = deg_to_rad(-90.0)  # facing +X, toward the ball
	reset_play()


func _add_player(kit: TeamKit, number: int, bulk: float) -> PlayerFigure:
	var p := PlayerFigure.new()
	add_child(p)
	p.build(kit, number, _rng, bulk)
	return p


## A jersey number in [lo, hi] not used yet by this side.
func _number(used: Array[int], lo: int, hi: int) -> int:
	for attempt in 20:
		var n := _rng.randi_range(lo, hi)
		if not used.has(n):
			used.append(n)
			return n
	return _rng.randi_range(lo, hi)


func _build_stands() -> void:
	# All parented to GoalEnd (local z=0 is the end line, the field is +Z).
	var st := _stadium
	var front_z := -STANDS_GAP
	var width := st.stand_width
	_add_box(goal_end, Vector3(width, st.wall_height, 0.5),
		Vector3(0.0, st.wall_height * 0.5, front_z), BLEACHER_RAIL if st.bleachers else WALL_COLOR)
	# Trim band along the top of the wall.
	_add_box(goal_end, Vector3(width, 0.35, 0.55),
		Vector3(0.0, st.wall_height - 0.4, front_z + 0.02), Color(0.9, 0.9, 0.92))

	var top := Vector3(0.0, st.wall_height, front_z - 0.3)
	for i in st.decks.size():
		if i > 0:
			# Suite level (dark glass) or a concrete fascia between the decks.
			var band := 4.0 if st.suite_band else 2.5
			_add_box(goal_end, Vector3(width, band, 1.0), top + Vector3(0.0, band * 0.5, -0.5),
				Color(0.05, 0.07, 0.12) if st.suite_band else Color(0.4, 0.41, 0.44))
			top += Vector3(0.0, band, -1.0)
		top = _add_stand(goal_end, top, st.decks[i], width)
	if st.roof_rim:
		_add_box(goal_end, Vector3(width, 1.2, 6.0), top + Vector3(0.0, 0.6, 1.5),
			Color(0.75, 0.77, 0.8))
	if st.press_box:
		# Off to one side, so it never sits behind the uprights.
		var px := Vector3(-width * 0.3, 0.0, 0.0)
		_add_box(goal_end, Vector3(18.0, 4.0, 5.0), top + px + Vector3(0.0, 2.0, -2.0),
			Color(0.82, 0.83, 0.85))
		var glass := _add_box(goal_end, Vector3(16.0, 1.4, 0.2), top + px + Vector3(0.0, 2.4, 0.55),
			Color(0.1, 0.13, 0.2))
		_glow(glass, Color(1.0, 0.92, 0.7), 0.8 if st.night else 0.0)
	_build_lights(top)
	_build_scoreboard(top)
	if st.wings:
		for side_v in [-1.0, 1.0]:
			var side: float = side_v
			# The warmup's own sideline set stands on +X.
			if side > 0.0 and kick_type == KickSituation.KickType.WARMUP_NET:
				continue
			_build_wing(side)


## Light towers (2), poles (4, high school and bleachers) or a lit roof ring.
func _build_lights(top: Vector3) -> void:
	var st := _stadium
	var energy := 4.0 if st.night else 1.5
	if st.lights == "ring":
		var ring := _add_box(goal_end, Vector3(st.stand_width * 0.9, 0.6, 1.2),
			top + Vector3(0.0, 1.6, 4.0), Color(1.0, 1.0, 0.95))
		_glow(ring, Color(1.0, 0.97, 0.85), energy)
		return
	var spots: Array[Vector3] = []
	var height := 0.0
	if st.lights == "poles":
		# Along both sidelines: two by the stands, two out toward midfield.
		height = maxf(top.y + 12.0, 22.0)
		for z in [-STANDS_GAP - 2.0, 45.0]:
			for side in [-1.0, 1.0]:
				spots.append(Vector3(float(side) * 33.0, 0.0, float(z)))
	else:
		height = top.y + 14.0
		for side in [-1.0, 1.0]:
			spots.append(Vector3(float(side) * st.stand_width * 0.17, 0.0, top.z - 4.0))
	var panel_size := Vector3(6.0, 3.5, 0.5) if st.lights == "poles" else Vector3(10.0, 5.0, 0.6)
	for base in spots:
		_add_box(goal_end, Vector3(0.8, height, 0.8), base + Vector3(0.0, height * 0.5, 0.0),
			Color(0.55, 0.57, 0.6))
		var panel := _add_box(goal_end, panel_size, base + Vector3(0.0, height + 2.0, 0.6),
			Color(1.0, 1.0, 0.95))
		_glow(panel, Color(1.0, 0.97, 0.85), energy)


## A scoreboard: small on two posts beside the end zone, or a board / video
## board on top of the stands.
func _build_scoreboard(top: Vector3) -> void:
	var st := _stadium
	match st.scoreboard:
		"small":
			var base := Vector3(-22.0, 0.0, -STANDS_GAP + 2.0)
			for dx in [-3.0, 3.0]:
				_add_box(goal_end, Vector3(0.4, 5.0, 0.4), base + Vector3(float(dx), 2.5, 0.0),
					Color(0.55, 0.57, 0.6))
			var board := _add_box(goal_end, Vector3(8.0, 3.2, 0.4), base + Vector3(0.0, 6.2, 0.0),
				Color(0.08, 0.1, 0.16))
			_glow(board, Color(0.95, 0.55, 0.2), 0.5 if st.night else 0.15)
		"board", "video":
			var big := st.scoreboard == "video"
			var size := Vector3(36.0, 12.0, 1.0) if big else Vector3(22.0, 8.0, 1.0)
			var at := top + Vector3(0.0, size.y * 0.5 + 3.0, -3.0)
			_add_box(goal_end, size, at, Color(0.12, 0.13, 0.16))
			var face := _add_box(goal_end, Vector3(size.x - 1.6, size.y - 1.6, 0.2),
				at + Vector3(0.0, 0.0, 0.55), Color(0.05, 0.08, 0.16))
			var color := Color(0.35, 0.55, 1.0) if big else Color(0.95, 0.6, 0.2)
			_glow(face, color, (1.2 if st.night else 0.35) * (1.0 if big else 0.7))


## A sideline stand (the bowl): a wall and one deck along the whole field,
## facing the middle. Parented to the field, not the moving goal end.
func _build_wing(side: float) -> void:
	var st := _stadium
	var pivot := Node3D.new()
	pivot.position = Vector3(side * WING_X, 0.0, -70.0)
	pivot.rotation.y = side * PI * 0.5  # local +Z = toward the field
	add_child(pivot)
	var length := 220.0
	_add_box(pivot, Vector3(length, st.wall_height, 0.5), Vector3(0.0, st.wall_height * 0.5, 0.0),
		WALL_COLOR)
	_add_stand(pivot, Vector3(0.0, st.wall_height, -0.3), st.decks[0] * 0.7, length)


## Adds one sloped seating deck whose bottom-front edge is at `bottom`.
## Returns the top-back edge position so the next deck can stack on it.
func _add_stand(parent: Node3D, bottom: Vector3, length: float, width: float) -> Vector3:
	var slope := deg_to_rad(STAND_SLOPE_DEG)
	var up_dir := Vector3(0.0, sin(slope), -cos(slope))
	var plane := PlaneMesh.new()
	plane.size = Vector2(width, length)
	var mat := ShaderMaterial.new()
	mat.shader = CROWD_SHADER
	mat.set_shader_parameter("plane_size", plane.size)
	stadium_crowd(mat, _stadium)
	plane.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.rotation = Vector3(slope, 0.0, 0.0)  # tilt to face the field
	mi.position = bottom + up_dir * length * 0.5
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return bottom + up_dir * length


## The crowd shader's stadium settings: empty seats, the home crowd's colors,
## pale aluminum seats for bleachers. Shared with the sideline warmup.
static func stadium_crowd(mat: ShaderMaterial, st: StadiumSpec) -> void:
	if st == null or st.tier == "default":
		return
	mat.set_shader_parameter("empty_seats", st.empty_seats)
	if st.crowd_colors.size() == 2:
		mat.set_shader_parameter("home_color", st.crowd_colors[0])
		mat.set_shader_parameter("alt_color", st.crowd_colors[1])
	if st.bleachers:
		mat.set_shader_parameter("seat_color", Color(0.6, 0.62, 0.66))
		mat.set_shader_parameter("concrete", Color(0.68, 0.7, 0.73))


## Makes a box glow (light panels, scoreboards). energy 0: no glow.
func _glow(mi: MeshInstance3D, color: Color, energy: float) -> void:
	if energy <= 0.0:
		return
	var m := (mi.mesh as BoxMesh).material as StandardMaterial3D
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy


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
