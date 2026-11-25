extends Node3D
## Kick scene controller (field goals, extra points, kickoffs, onside kicks).
## Field goals and extra points run one attempt at a time:
##   SETUP (situation shown, aim may wobble) -> SNAP (ball spirals to the holder,
##   who spots it; the defense is already rushing) -> KICK_WINDOW (swipe!)
##   -> FLIGHT -> RESULT (slow-mo beat, tap for next)
## The sideline warmup (WARMUP_NET, WarmupMode) is the same scene on the
## sideline: ball on a tee, kicked into a net, a few strikes in a row.
## Kickoffs and onside kicks (mode.kick_type()) use the same stadium, camera,
## swipe, wind, modifiers and HUD: ball on a tee, kickoff formation, no snap or
## block rush; judged where the ball lands (KickoffJudge). Their result is in
## tee_result; they are NOT reported to GameState (field-goal stats).
## It wires the independent pieces together and owns no tuning numbers:
## those live in KickTuning (res://tuning/kick_tuning.tres).

enum Phase { SETUP, SNAP, KICK_WINDOW, FLIGHT, RESULT }

## The result has been shown for result_min_display seconds.
signal attempt_finished(outcome: KickResult.Outcome)
## The ball has been kicked (field goal / extra point or tee kick), before its
## result: a tryout saves that the kick was taken, so quitting now is a miss.
signal kick_struck

@export var tuning: KickTuning
## Field goal / extra point difficulty (crooked swipes, distance, wind,
## contact vibration). null = res://tuning/kick_difficulty.tres.
@export var difficulty: KickDifficulty

var phase: Phase = Phase.SETUP
var situation: KickSituation
## Player-stat effects on the kick. Neutral unless a mode sets it before the
## scene enters the tree (Career: KickProfile.to_kick_modifiers()).
var modifiers: KickModifiers = KickModifiers.new()
## Game-mode rules (Challenge, Career later). Set before adding the scene to
## the tree. null = free practice: random kicks forever.
var mode: KickMode = null

var _rng := RandomNumberGenerator.new()
var _window_total := 1.0
var _window_left := 0.0
var _can_continue := false
var _attempt_id := 0
## Play progress for the two lines (0 at the snap, 1 = edge rushers at the ball).
var _play_t := 0.0
## Seconds from snap to block: snap travel + hold + kick window.
var _play_total := 1.0
## Ball position last physics frame, for sweeping it past defenders' hands.
var _ball_prev := Vector3.ZERO
## True while the finger that tapped "next kick" is still down.
var _swallow_release := false
## Live (gusting) wind at the moment of the kick, for the result report.
var _wind_at_kick := 0.0
## Tee kicks (kickoff / onside) -------------------------------------------------
## The last tee kick's result (KickoffJudge): read it after attempt_finished.
var tee_result: Dictionary = {}
var _tee := false
## Seconds since the tee kick (game time), -1 before it; and flight time for hang.
var _kick_t := -1.0
var _flight_t := 0.0
var _tee_aim := 0.0
## Warmup net: this strike's judged result, and whether it has reached the net.
var _net := false
var _net_res: Dictionary = {}
var _net_hit := false
var _first_net := true
var _default_rules := KickoffRules.new()
## Field goals: where the ball ended up relative to the posts (GoalMarker) and
## the margin line under the result banner ("Cleared the bar by 4 ft").
var _goal_marker: GoalMarker
var _margin := ""
## Field goals: the hook / slice from a crooked swipe (m/s^2, + = right) and
## seconds of flight so far (game time), for the wind's hang-time growth.
var _hook := 0.0
var _fg_flight_t := 0.0
## The last field goal's crooked-swipe penalty (0 = straight), for Career nerves.
var last_shot_penalty := 0.0
## Career: the nerves line for the debug overlay ("" = none).
var nerves_debug := ""

@onready var field: FieldBuilder = $Field
@onready var ball: Ball = $Ball
@onready var trail: BallTrail = $BallTrail
@onready var aim_marker: AimMarker = $AimMarker
@onready var cam: KickCamera = $KickCamera
@onready var wind: Wind = $Wind
@onready var pressure: PressureModel = $Pressure
@onready var kicker: KickController = $KickController
@onready var snap: SnapAnimator = $SnapAnimator
@onready var swipe_input: SwipeInput = $SwipeInput
@onready var hud: Hud = $Hud


## Career Mode: goalpost style/width/colors and team uniforms. Call after
## instantiate() and before adding the scene to the tree. look keys (all
## optional): posts ("high_school"/"college"/"pro"), width (m), accent, accent2
## (Color), home / away ([primary, secondary] Colors), stadium (StadiumSpec:
## the stands, lights, scoreboard, night). Without it the scene looks exactly
## as before.
func set_look(look: Dictionary) -> void:
	var posts := get_node("Field/GoalEnd/GoalPosts") as GoalPosts
	posts.style = StringName(str(look.get("posts", "")))
	posts.inner_width = float(look.get("width", GoalPosts.INNER_WIDTH))
	posts.accent = look.get("accent", posts.accent)
	posts.accent2 = look.get("accent2", posts.accent2)
	var f := get_node("Field") as FieldBuilder
	var home: Array = look.get("home", [])
	if home.size() == 2:
		f.home_kit_override = TeamKit.from_colors(home[0], home[1])
	var away: Array = look.get("away", [])
	if away.size() == 2:
		f.away_kit_override = TeamKit.from_colors(away[0], away[1], true)
	var st: Variant = look.get("stadium")
	if st is StadiumSpec:
		f.stadium = st
		if st.night:
			_set_night()


## Night games: StageLook lights the scene (a dark sky with stars, the stadium
## lights as the key light). No real-time lights are added.
func _set_night() -> void:
	(get_node("StageLook") as StageLook).night = true


## Tee kicks need their formation built before the field's _ready().
func _enter_tree() -> void:
	if mode == null or not KickSituation.is_off_tee(mode.kick_type()):
		return
	var f := get_node("Field") as FieldBuilder
	f.kick_type = mode.kick_type()
	var t := tuning if tuning != null else KickTuning.new()
	f.sideline_x = t.warmup_sideline_x
	f.tee_height = t.tee_height
	f.tee_ball_scale = t.ball_visual_scale


func _ready() -> void:
	if tuning == null:
		tuning = KickTuning.new()
	if difficulty == null:
		var d: Variant = load("res://tuning/kick_difficulty.tres")
		difficulty = d if d is KickDifficulty else KickDifficulty.new()
	_rng.randomize()
	ball.set_visual_scales(tuning.ball_visual_scale, tuning.ball_visual_scale_far)
	cam.fov = tuning.camera_fov
	swipe_input.pressed.connect(_on_pressed)
	swipe_input.dragged.connect(hud.trail_add)
	swipe_input.released.connect(_on_swipe_released)
	ball.reached_goal_plane.connect(_on_ball_reached_goal_plane)
	ball.landed.connect(_on_ball_landed)
	_goal_marker = GoalMarker.new()
	add_child(_goal_marker)
	# Debug overlay (with the other debug numbers): Career nerves breakdown.
	if nerves_debug != "" and tuning.show_debug_readout:
		hud.set_debug_line(nerves_debug)
	_start_attempt()


func _process(delta: float) -> void:
	# Live (gusting) wind on the flags and the HUD arrow.
	field.set_wind(wind.mph, tuning.max_wind_mph + tuning.max_gust_mph, wind.along_mph)
	hud.set_live_wind(wind.mph, tuning.max_wind_mph + tuning.max_gust_mph, wind.along_mph)

	if phase != Phase.FLIGHT and phase != Phase.RESULT:
		aim_marker.set_aim(pressure.wobble_deg(), situation.distance_m())
	if _tee:
		if _kick_t >= 0.0 and field.kickoff != null:
			_kick_t += delta
			field.kickoff.update_play(_kick_t, tuning.coverage_speed)
		return
	if phase != Phase.SETUP:
		# The rush runs on one clock from the snap, and carries on after the kick.
		# No clamp at 1: runners keep moving through the end of the play.
		_play_t = minf(_play_t + delta / _play_total, 2.5)
		field.set_play_progress(_play_t)
	if phase == Phase.KICK_WINDOW:
		_window_left -= delta
		hud.set_window(clampf(_window_left / _window_total, 0.0, 1.0), true)
		if _window_left <= 0.0:
			_kick_blocked()


func _physics_process(_delta: float) -> void:
	if not _tee and phase == Phase.FLIGHT:
		_fg_flight_t += _delta * tuning.flight_speed_scale
	ball.set_wind_accel(_ball_wind_accel())
	if _net:
		_net_physics(_delta)
		return
	if _tee:
		_tee_physics(_delta)
		return
	if phase == Phase.FLIGHT:
		_check_hands()


## Did the ball pass through a defender's glove since last frame? Swept test,
## because a fast kick moves ~0.5 m per frame.
func _check_hands() -> void:
	var now := ball.global_position
	var from := _ball_prev
	_ball_prev = now
	if now.z < FieldBuilder.LOS_Z - 3.0:
		return  # already past everyone
	var r := tuning.hand_block_radius
	for hand in field.defender_hands():
		var closest := Geometry3D.get_closest_point_to_segment(hand, from, now)
		if closest.distance_to(hand) <= r:
			_tipped(closest, hand)
			return


func _tipped(at: Vector3, hand: Vector3) -> void:
	# Knock it up and back off the hand, keeping a little of its speed.
	var away := (at - hand).normalized()
	var v := ball.velocity * 0.15 + Vector3(away.x * 3.0, _rng.randf_range(2.0, 5.0),
		_rng.randf_range(2.0, 5.0))
	ball.global_position = at
	ball.launch(v, tuning.gravity, Vector3.ZERO, 1.0, -INF, tuning.ball_spin_speed * 1.5)
	cam.shake(tuning.kick_shake * 2.0)
	Haptics.pulse(tuning.block_vibration_ms)
	_resolve(KickResult.Outcome.BLOCKED, "Tipped at the line!")


# --- attempt flow ---------------------------------------------------------------

func _start_attempt() -> void:
	_attempt_id += 1
	var my_id := _attempt_id
	phase = Phase.SETUP
	_can_continue = false
	Engine.time_scale = 1.0
	_goal_marker.clear()
	_margin = ""

	situation = mode.next_situation(_rng, tuning, wind) if mode != null else null
	if situation == null:
		var wind_mph := wind.roll(_rng, tuning)
		situation = KickSituation.roll(_rng, tuning, wind_mph)
	situation.wind_gust_mph = wind.gust_mph
	_hook = 0.0
	_fg_flight_t = 0.0
	last_shot_penalty = 0.0
	# Field goals on windy days also get a headwind or tailwind.
	if situation.along_preset:
		wind.set_along(situation.wind_along_mph)
	elif difficulty.enabled and not KickSituation.is_off_tee(situation.kick_type) \
			and absf(situation.wind_mph) >= 0.5 and difficulty.max_head_tail_mph > 0.0:
		situation.wind_along_mph = roundf(_rng.randf_range(-1.0, 1.0) * difficulty.max_head_tail_mph)
		wind.set_along(situation.wind_along_mph)
	_net = situation.kick_type == KickSituation.KickType.WARMUP_NET and field.sideline != null
	_tee = (situation.is_tee_kick() and field.kickoff != null) or _net
	if _net:
		_start_net_attempt(my_id)
		return
	if _tee:
		_start_tee_attempt(my_id)
		return
	field.set_distance(situation.distance_m())
	_play_t = 0.0
	field.reset_play(RushPlan.roll(_rng, field.dl_x_positions()))
	ball.reset(field.hold_spot())
	snap.set_ready(ball, field.snap_spot())
	trail.clear()
	cam.reset_to(field.hold_spot(), situation.distance_m())
	pressure.setup(situation.pressure, tuning, modifiers)
	aim_marker.visible = GameState.settings.aim_assist

	hud.show_situation(situation, tuning)
	hud.hide_result()
	hud.set_window(1.0, false)
	hud.set_hint("Get set...")

	await get_tree().create_timer(tuning.snap_delay).timeout
	if my_id != _attempt_id:
		return
	phase = Phase.SNAP
	_window_total = pressure.kick_window_sec()
	_window_left = _window_total
	_play_total = tuning.snap_travel_time + tuning.hold_place_time + _window_total
	hud.set_hint("")
	Sfx.play(&"snap")
	snap.play(ball, field.snap_spot(), field.catch_spot(),
		tuning.snap_travel_time, tuning.hold_place_time, tuning.snap_spins)

	await snap.caught
	if my_id != _attempt_id:
		return
	field.set_holder_pose(FieldBuilder.HolderPose.HOLDING)
	Sfx.play(&"catch")

	await snap.placed
	if my_id != _attempt_id:
		return
	phase = Phase.KICK_WINDOW
	hud.set_window(1.0, true)
	hud.set_hint("SWIPE UP TO KICK!")


func _try_kick(swipe: Swipe) -> void:
	if _net:
		_kick_into_net(swipe)
		return
	if _tee:
		_kick_off_tee(swipe)
		return
	var problem := kicker.validate(swipe, tuning)
	if problem != "":
		hud.flash_hint(problem)
		return
	var shot: KickController.Shot = kicker.build_shot(
		swipe, tuning, modifiers, pressure.wobble_deg(), _rng, _play_t, difficulty, situation.distance_yards)
	_hook = shot.hook_accel
	_fg_flight_t = 0.0
	last_shot_penalty = shot.penalty
	phase = Phase.FLIGHT
	kick_struck.emit()
	_wind_at_kick = wind.mph
	aim_marker.visible = false
	hud.set_window(0.0, false)
	hud.set_hint("")
	if tuning.show_debug_readout:
		hud.show_shot_info("Power %d%%  Aim %+.1f°  Wobble %+.1f°  Crooked %d%% (-%d%%)" % [
			roundi(shot.power * 100.0), shot.final_aim_deg, shot.wobble_deg,
			roundi(shot.crooked * 100.0), roundi(shot.penalty * 100.0)])

	_ball_prev = ball.global_position
	ball.launch(shot.velocity, tuning.gravity, _ball_wind_accel(),
		tuning.flight_speed_scale, -situation.distance_m(), tuning.ball_spin_speed)
	trail.start(ball)
	field.set_holder_pose(FieldBuilder.HolderPose.RELEASED)
	cam.follow(ball, tuning.camera_follow_strength, tuning.camera_follow_speed)
	cam.shake(tuning.kick_shake * (0.5 + shot.power))
	Sfx.play(&"kick", 0.0, lerpf(0.9, 1.15, shot.power))
	_contact_vibration(shot)


## The pulse at the moment the foot meets the ball (phones only; Haptics is a
## no-op on desktop / Steam and when Vibration is off in Settings).
## Clean strike: short and sharp. Mishit (crooked swipe): longer, weaker, rough.
func _contact_vibration(shot: KickController.Shot) -> void:
	if not difficulty.enabled:
		Haptics.pulse(roundi(tuning.kick_vibration_ms * lerpf(0.75, 1.5, shot.power)))
		return
	var bad := clampf(shot.penalty * 2.0, 0.0, 1.0)  # even a modest penalty feels off
	var ms := roundi(lerpf(difficulty.clean_vibration_ms, difficulty.mishit_vibration_ms, bad))
	Haptics.pulse(ms, lerpf(difficulty.clean_vibration_amp, difficulty.mishit_vibration_amp, bad))
	if bad > 0.5:
		Haptics.pulse_after(ms / 1000.0 + 0.04, roundi(ms * 0.4), difficulty.mishit_vibration_amp)


## Wind on the ball right now. Field goals (KickDifficulty): stronger, more of a
## push the longer the ball has been up, plus a crooked swipe's hook / slice.
## Career's wind_mult (Toughness) still applies first.
func _ball_wind_accel() -> Vector3:
	var a := wind.acceleration(tuning) * modifiers.wind_mult
	if _tee or not difficulty.enabled:
		return a
	var grow := difficulty.wind_strength_multiplier * (1.0 + difficulty.hang_time_wind_growth * _fg_flight_t)
	return Vector3(a.x * grow + _hook, 0.0, a.z * grow * difficulty.head_tail_effect)


func _kick_blocked() -> void:
	_wind_at_kick = wind.mph
	aim_marker.visible = false
	hud.set_window(0.0, false)
	_play_t = 1.0
	field.set_play_progress(1.0)
	field.set_holder_pose(FieldBuilder.HolderPose.RELEASED)
	Haptics.pulse(tuning.block_vibration_ms)
	# Pop the ball up and back off the rusher's hands.
	var deflect := Vector3(_rng.randf_range(-2.5, 2.5), 5.0, 2.5)
	ball.launch(deflect, tuning.gravity, Vector3.ZERO, 1.0, -INF, tuning.ball_spin_speed)
	cam.shake(tuning.kick_shake * 2.0)
	_resolve(KickResult.Outcome.BLOCKED)


func _resolve(outcome: KickResult.Outcome, note: String = "") -> void:
	phase = Phase.RESULT
	var my_id := _attempt_id
	# THE kick-result event: stats, achievements and modes all hear it from here.
	GameState.report_kick(KickReport.create(outcome, situation, _wind_at_kick,
		mode.id() if mode != null else &"practice", note))

	if KickResult.is_good(outcome):
		Sfx.play(&"good")
	elif outcome == KickResult.Outcome.BLOCKED:
		Sfx.play(&"block")
	else:
		Sfx.play(&"miss")

	var detail := "%d yards" % situation.distance_yards
	if GameState.streak > 1:
		detail += "  -  %d in a row" % GameState.streak
	if _margin != "":
		detail = _margin + "\n" + detail
	if note != "":
		detail = note + "\n" + detail
	hud.set_hint("")
	_play_slow_mo(my_id)
	hud.show_result(outcome, detail)

	await get_tree().create_timer(tuning.result_min_display, true, false, true).timeout
	if my_id != _attempt_id:
		return
	attempt_finished.emit(outcome)
	if mode != null and not mode.wants_next_kick():
		return  # the mode shows its own end screen
	_can_continue = true
	hud.set_hint("Tap for next kick")


func _play_slow_mo(my_id: int) -> void:
	Engine.time_scale = tuning.slowmo_scale
	await get_tree().create_timer(tuning.slowmo_duration, true, false, true).timeout
	if my_id == _attempt_id:
		Engine.time_scale = 1.0


# --- signals --------------------------------------------------------------------

func _on_pressed(pos: Vector2) -> void:
	if phase == Phase.RESULT and _can_continue:
		_swallow_release = true
		_start_attempt()
		return
	hud.trail_begin(pos)


func _on_swipe_released(swipe: Swipe) -> void:
	hud.trail_finish()
	if _swallow_release:
		_swallow_release = false
		return
	match phase:
		Phase.SETUP:
			hud.flash_hint("Get set..." if _tee else "Wait for the snap!")
		Phase.SNAP:
			hud.flash_hint("Wait for the hold!")
		Phase.KICK_WINDOW:
			_try_kick(swipe)


func _on_ball_reached_goal_plane(crossing: Vector3) -> void:
	if phase == Phase.FLIGHT:
		var half := field.goal_posts.inner_width * 0.5
		var outcome := KickResult.judge_at_goal_plane(crossing, half)
		_goal_marker.show_crossing(crossing, KickResult.is_good(outcome), -situation.distance_m(), half,
			GoalPosts.CROSSBAR_HEIGHT)
		_margin = _crossing_margin(outcome, crossing, half)
		_resolve(outcome)


func _on_ball_landed(at: Vector3) -> void:
	if _tee:
		if phase == Phase.FLIGHT and situation.kick_type == KickSituation.KickType.KICKOFF:
			_resolve_tee(KickoffJudge.kickoff(at, _flight_t, _rules(), _rng))
		return
	if phase == Phase.FLIGHT:
		var goal_z := -situation.distance_m()
		_goal_marker.show_short(at, goal_z, field.goal_posts.inner_width * 0.5, GoalPosts.CROSSBAR_HEIGHT)
		var yd := (at.z - goal_z) / KickSituation.YARD_TO_M
		_margin = "Less than a yard short" if yd < 1.0 else "%d yard%s short" % [roundi(yd), "" if roundi(yd) == 1 else "s"]
		_resolve(KickResult.Outcome.SHORT)


## "Cleared the bar by 4 ft" / "Under the bar by 1 ft" / "Wide by 2 ft".
static func _crossing_margin(outcome: KickResult.Outcome, crossing: Vector3, half_width: float) -> String:
	const FOOT := 0.3048
	match outcome:
		KickResult.Outcome.GOOD:
			return "Cleared the bar by %d ft" % maxi(roundi((crossing.y - GoalPosts.CROSSBAR_HEIGHT) / FOOT), 1)
		KickResult.Outcome.SHORT:
			return "Under the bar by %d ft" % maxi(roundi((GoalPosts.CROSSBAR_HEIGHT - crossing.y) / FOOT), 1)
		KickResult.Outcome.WIDE_LEFT, KickResult.Outcome.WIDE_RIGHT:
			return "Wide by %d ft" % maxi(roundi((absf(crossing.x) - half_width) / FOOT), 1)
	return ""


# --- sideline warmup net -----------------------------------------------------------

func _start_net_attempt(my_id: int) -> void:
	var spot := field.sideline.global_position
	# The far end zone (stands and posts) down the sideline.
	field.set_distance(50.0 * KickSituation.YARD_TO_M)
	_net_res = {}
	_net_hit = false
	_flight_t = 0.0
	tee_result = {}
	trail.clear()
	ball.reset(spot)
	ball.set_pose(ball.hold_position() + Vector3(0.0, tuning.tee_height * tuning.ball_visual_scale, 0.0),
		ball.hold_rotation())
	cam.reset_to(spot, tuning.warmup_look_distance)
	pressure.setup(situation.pressure, tuning, modifiers)
	aim_marker.visible = false
	hud.show_situation(situation, tuning)
	hud.set_headline("SIDELINE NET", situation.label)
	hud.hide_result()
	hud.set_window(1.0, false)
	hud.set_hint("Get set..." if _first_net else "")
	await get_tree().create_timer(tuning.kickoff_setup_time if _first_net else 0.2).timeout
	_first_net = false
	if my_id != _attempt_id:
		return
	phase = Phase.KICK_WINDOW
	hud.set_hint("SWIPE INTO THE NET")


## Same swipe reading as the old sideline pad: power from the swipe (no
## power_mult), aim from the tilt plus the profile's random aim error. Judged at
## the strike (WarmupJudge); the 3D flight shows it.
func _kick_into_net(swipe: Swipe) -> void:
	var problem := kicker.validate(swipe, tuning)
	if problem != "":
		hud.flash_hint(problem)
		return
	var power := kicker.power_from_swipe(swipe, tuning)
	var aim := clampf(swipe.tilt_deg() * tuning.aim_sensitivity, -tuning.max_aim_deg, tuning.max_aim_deg)
	aim += pressure.wobble_deg()
	if modifiers.accuracy_spread_deg > 0.0:
		aim += _rng.randfn(0.0, modifiers.accuracy_spread_deg)
	var wm := mode as WarmupMode
	_net_res = wm.judge(power, aim) if wm != null else WarmupJudge.strike(power, aim, 0.5, 0.92, 6.0)
	var speed := lerpf(tuning.min_launch_speed, tuning.max_launch_speed * modifiers.power_mult, power)
	phase = Phase.FLIGHT
	_flight_t = 0.0
	_ball_prev = ball.global_position
	hud.set_hint("")
	if tuning.show_debug_readout:
		hud.show_shot_info("Power %d%%  Aim %+.1f°" % [roundi(power * 100.0), aim])
	ball.launch(KickLaunch.direction(aim, tuning.warmup_elevation_deg) * speed, tuning.gravity,
		Vector3.ZERO, tuning.flight_speed_scale, -INF, tuning.ball_spin_speed)
	trail.start(ball)
	cam.follow(ball, tuning.camera_follow_strength, tuning.camera_follow_speed)
	cam.shake(tuning.kick_shake * (0.5 + power))
	Sfx.play(&"kick", 0.0, lerpf(0.9, 1.15, power))
	Haptics.pulse(roundi(tuning.kick_vibration_ms * lerpf(0.75, 1.5, power)))


func _net_physics(delta: float) -> void:
	if phase != Phase.FLIGHT:
		return
	_flight_t += delta * tuning.flight_speed_scale
	var net := field.sideline.net
	var now := ball.global_position
	if not _net_hit and now.z <= net.plane_z() and _ball_prev.z > net.plane_z():
		_net_hit = true
		var t := (_ball_prev.z - net.plane_z()) / maxf(_ball_prev.z - now.z, 0.0001)
		var at := _ball_prev.lerp(now, t)
		if net.contains(at):
			# Into the net: it gives, and the ball drops down its face.
			net.hit(at)
			Sfx.play(&"net")
			ball.global_position = Vector3(at.x, at.y, net.plane_z() + 0.3)
			ball.launch(Vector3(0.0, -0.5, 1.4), tuning.gravity, Vector3.ZERO, 1.0, -INF,
				tuning.ball_spin_speed * 0.3)
			_resolve_net(_net_res)
			return
	_ball_prev = ball.global_position
	# Missed the net (or came up short): judged once the ball settles.
	if not ball.in_flight or _flight_t > 3.0:
		_resolve_net(_net_res)


## One strike's banner, then the next ball on the tee; after the last strike,
## the session banner (WARMED UP / LOOSE) and attempt_finished.
func _resolve_net(res: Dictionary) -> void:
	phase = Phase.RESULT
	var my_id := _attempt_id
	tee_result = res
	var good := bool(res.get("good", false))
	Sfx.play(&"good" if good else &"miss")
	hud.set_hint("")
	hud.show_banner(str(res.get("banner", "")), good, str(res.get("detail", "")))
	await get_tree().create_timer(tuning.result_min_display + tuning.warmup_next_delay, true, false, true).timeout
	if my_id != _attempt_id:
		return
	if mode != null and mode.wants_next_kick():
		attempt_finished.emit(KickResult.Outcome.GOOD if good else KickResult.Outcome.SHORT)
		_start_attempt()
		return
	var wm := mode as WarmupMode
	if wm != null:
		var sum := wm.summary()
		tee_result = {"result": wm.result(), "pure": wm.pure, "taken": wm.taken}
		hud.show_banner(str(sum["banner"]), bool(sum["good"]), str(sum["detail"]))
		await get_tree().create_timer(1.4, true, false, true).timeout
		if my_id != _attempt_id:
			return
	attempt_finished.emit(KickResult.Outcome.GOOD if good else KickResult.Outcome.SHORT)
	if mode == null:
		_can_continue = true
		hud.set_hint("Tap for next kick")


# --- tee kicks: kickoff / onside ---------------------------------------------------

func _rules() -> KickoffRules:
	return situation.kickoff_rules if situation.kickoff_rules != null else _default_rules


func _start_tee_attempt(my_id: int) -> void:
	var r := _rules()
	var onside := situation.kick_type == KickSituation.KickType.ONSIDE
	situation.distance_yards = r.to_goal_yards()
	# Posts on the receiving team's end line, 10 yards past their goal line.
	field.set_distance((r.to_goal_yards() + 10) * KickSituation.YARD_TO_M)
	field.kickoff.set_spot(r.spot_yards)
	_kick_t = -1.0
	_flight_t = 0.0
	tee_result = {}
	trail.clear()
	ball.reset(field.hold_spot())
	ball.set_pose(ball.hold_position() + Vector3(0.0, tuning.tee_height * tuning.ball_visual_scale, 0.0),
		ball.hold_rotation())
	cam.home_offset = tuning.kickoff_camera_offset
	cam.look_down_deg = tuning.kickoff_look_down_deg
	cam.fov = tuning.kickoff_camera_fov
	cam.reset_to(field.hold_spot(), situation.distance_m())
	pressure.setup(situation.pressure, tuning, modifiers)
	aim_marker.visible = false
	hud.show_situation(situation, tuning)
	hud.set_headline("ONSIDE KICK" if onside else "KICKOFF", "From your own %d%s" % [r.spot_yards,
		"" if situation.label == "" else "  -  " + situation.label])
	hud.hide_result()
	hud.set_window(1.0, false)
	hud.set_hint("Get set...")
	await get_tree().create_timer(tuning.kickoff_setup_time).timeout
	if my_id != _attempt_id:
		return
	phase = Phase.KICK_WINDOW
	hud.set_hint("SWIPE SOFTLY: ONSIDE!" if onside else "SWIPE UP TO KICK OFF!")


## Same swipe reading as the field goal (KickController + KickModifiers):
## swipe tilt = aim (+ pressure wobble + the profile's aim error), swipe
## strength = distance (KickoffRules.max_carry_yards * power * power_mult).
func _kick_off_tee(swipe: Swipe) -> void:
	var problem := kicker.validate(swipe, tuning)
	if problem != "":
		hud.flash_hint(problem)
		return
	var r := _rules()
	var onside := situation.kick_type == KickSituation.KickType.ONSIDE
	var power := kicker.power_from_swipe(swipe, tuning)
	var aim := clampf(swipe.tilt_deg() * tuning.aim_sensitivity, -tuning.max_aim_deg, tuning.max_aim_deg)
	var wobble := pressure.wobble_deg()
	aim += wobble
	if modifiers.accuracy_spread_deg > 0.0:
		aim += _rng.randfn(0.0, modifiers.accuracy_spread_deg)
	_tee_aim = aim
	var carry_yd := maxf(r.max_carry_yards * power * modifiers.power_mult, 5.0)
	var carry_m := carry_yd * KickSituation.YARD_TO_M / maxf(cos(deg_to_rad(aim)), 0.5)
	var elev := tuning.onside_elevation_deg if onside else tuning.kickoff_elevation_deg
	var v := KickLaunch.velocity(carry_m, aim, elev, tuning.gravity, tuning.flight_speed_scale,
		ball.global_position, tuning.ball_visual_scale, tuning.ball_visual_scale_far, onside)

	phase = Phase.FLIGHT
	_wind_at_kick = wind.mph
	_flight_t = 0.0
	kick_struck.emit()
	hud.set_window(0.0, false)
	hud.set_hint("")
	if tuning.show_debug_readout:
		hud.show_shot_info("Power %d%%  Aim %+.1f°  Wobble %+.1f°  Carry %d yd" % [
			roundi(power * 100.0), aim, wobble, roundi(carry_yd)])
	ball.launch(v, tuning.gravity, wind.acceleration(tuning) * modifiers.wind_mult,
		tuning.flight_speed_scale, -INF, tuning.ball_spin_speed)
	trail.start(ball)
	var dir := KickLaunch.direction(aim, 0.0)
	field.kickoff.kicked(dir * carry_m)
	_kick_t = 0.0
	cam.follow(ball, tuning.kickoff_camera_follow, tuning.camera_follow_speed)
	cam.shake(tuning.kick_shake * (0.5 + power))
	Sfx.play(&"kick", 0.0, lerpf(0.9, 1.15, power))
	Haptics.pulse(roundi(tuning.kick_vibration_ms * lerpf(0.75, 1.5, power)))


func _tee_physics(delta: float) -> void:
	if phase != Phase.FLIGHT:
		return
	_flight_t += delta * tuning.flight_speed_scale
	# Onside kicks are judged where the ball stops (or after 8 s, just in case).
	if situation.kick_type == KickSituation.KickType.ONSIDE and (not ball.in_flight or _flight_t > 8.0):
		_resolve_tee(KickoffJudge.onside(ball.global_position, _tee_aim, _rules(), _rng))


## Same result beat as a field goal: slow motion, banner, then the mode decides.
func _resolve_tee(res: Dictionary) -> void:
	phase = Phase.RESULT
	var my_id := _attempt_id
	tee_result = res
	var good := bool(res.get("good", false))
	Sfx.play(&"good" if good else &"miss")
	hud.set_hint("")
	_play_slow_mo(my_id)
	hud.show_banner(str(res.get("banner", "")), good, str(res.get("detail", res.get("text", ""))))
	await get_tree().create_timer(tuning.result_min_display, true, false, true).timeout
	if my_id != _attempt_id:
		return
	attempt_finished.emit(KickResult.Outcome.GOOD if good else KickResult.Outcome.SHORT)
	if mode != null and not mode.wants_next_kick():
		return
	_can_continue = true
	hud.set_hint("Tap for next kick")
