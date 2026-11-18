extends Node3D
## Field-goal scene controller. Runs one attempt at a time:
##   SETUP (situation shown, aim may wobble) -> SNAP (ball spirals to the holder,
##   who spots it; the defense is already rushing) -> KICK_WINDOW (swipe!)
##   -> FLIGHT -> RESULT (slow-mo beat, tap for next)
## It wires the independent pieces together and owns no tuning numbers:
## those live in KickTuning (res://tuning/kick_tuning.tres).

enum Phase { SETUP, SNAP, KICK_WINDOW, FLIGHT, RESULT }

## The result has been shown for result_min_display seconds.
signal attempt_finished(outcome: KickResult.Outcome)

@export var tuning: KickTuning

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


func _ready() -> void:
	if tuning == null:
		tuning = KickTuning.new()
	_rng.randomize()
	ball.set_visual_scales(tuning.ball_visual_scale, tuning.ball_visual_scale_far)
	cam.fov = tuning.camera_fov
	swipe_input.pressed.connect(_on_pressed)
	swipe_input.dragged.connect(hud.trail_add)
	swipe_input.released.connect(_on_swipe_released)
	ball.reached_goal_plane.connect(_on_ball_reached_goal_plane)
	ball.landed.connect(_on_ball_landed)
	_start_attempt()


func _process(delta: float) -> void:
	# Live (gusting) wind on the flags and the HUD arrow.
	field.set_wind(wind.mph, tuning.max_wind_mph + tuning.max_gust_mph)
	hud.set_live_wind(wind.mph, tuning.max_wind_mph + tuning.max_gust_mph)

	if phase != Phase.FLIGHT and phase != Phase.RESULT:
		aim_marker.set_aim(pressure.wobble_deg(), situation.distance_m())
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
	ball.set_wind_accel(wind.acceleration(tuning) * modifiers.wind_mult)
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

	situation = mode.next_situation(_rng, tuning, wind) if mode != null else null
	if situation == null:
		var wind_mph := wind.roll(_rng, tuning)
		situation = KickSituation.roll(_rng, tuning, wind_mph)
	situation.wind_gust_mph = wind.gust_mph
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
	var problem := kicker.validate(swipe, tuning)
	if problem != "":
		hud.flash_hint(problem)
		return
	var shot: KickController.Shot = kicker.build_shot(
		swipe, tuning, modifiers, pressure.wobble_deg(), _rng, _play_t)
	phase = Phase.FLIGHT
	_wind_at_kick = wind.mph
	aim_marker.visible = false
	hud.set_window(0.0, false)
	hud.set_hint("")
	if tuning.show_debug_readout:
		hud.show_shot_info("Power %d%%  Aim %+.1f°  Wobble %+.1f°  Loft %.0f°" % [
			roundi(shot.power * 100.0), shot.swipe_aim_deg, shot.wobble_deg, shot.elevation_deg])

	_ball_prev = ball.global_position
	ball.launch(shot.velocity, tuning.gravity, wind.acceleration(tuning) * modifiers.wind_mult,
		tuning.flight_speed_scale, -situation.distance_m(), tuning.ball_spin_speed)
	trail.start(ball)
	field.set_holder_pose(FieldBuilder.HolderPose.RELEASED)
	cam.follow(ball, tuning.camera_follow_strength, tuning.camera_follow_speed)
	cam.shake(tuning.kick_shake * (0.5 + shot.power))
	Sfx.play(&"kick", 0.0, lerpf(0.9, 1.15, shot.power))
	Haptics.pulse(roundi(tuning.kick_vibration_ms * lerpf(0.75, 1.5, shot.power)))


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
			hud.flash_hint("Wait for the snap!")
		Phase.SNAP:
			hud.flash_hint("Wait for the hold!")
		Phase.KICK_WINDOW:
			_try_kick(swipe)


func _on_ball_reached_goal_plane(crossing: Vector3) -> void:
	if phase == Phase.FLIGHT:
		_resolve(KickResult.judge_at_goal_plane(crossing))


func _on_ball_landed(_at: Vector3) -> void:
	if phase == Phase.FLIGHT:
		_resolve(KickResult.Outcome.SHORT)
