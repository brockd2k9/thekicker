extends Node3D
## Field-goal scene controller. Runs one attempt at a time:
##   SETUP (situation shown, aim may wobble) -> snap -> KICK_WINDOW (swipe!)
##   -> FLIGHT -> RESULT (slow-mo beat, tap for next)
## It wires the independent pieces together and owns no tuning numbers:
## those live in KickTuning (res://tuning/kick_tuning.tres).

enum Phase { SETUP, KICK_WINDOW, FLIGHT, RESULT }

@export var tuning: KickTuning

var phase: Phase = Phase.SETUP
var situation: KickSituation
## Phase 2: replace with modifiers built from the player's current stats.
var modifiers: KickModifiers = KickModifiers.new()

var _rng := RandomNumberGenerator.new()
var _window_total := 1.0
var _window_left := 0.0
var _can_continue := false
var _attempt_id := 0
## True while the finger that tapped "next kick" is still down.
var _swallow_release := false

@onready var field: FieldBuilder = $Field
@onready var ball: Ball = $Ball
@onready var trail: BallTrail = $BallTrail
@onready var aim_marker: AimMarker = $AimMarker
@onready var cam: KickCamera = $KickCamera
@onready var wind: Wind = $Wind
@onready var pressure: PressureModel = $Pressure
@onready var kicker: KickController = $KickController
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
	if phase == Phase.SETUP or phase == Phase.KICK_WINDOW:
		aim_marker.set_aim(pressure.wobble_deg(), situation.distance_m())
	if phase == Phase.KICK_WINDOW:
		_window_left -= delta
		var frac := clampf(_window_left / _window_total, 0.0, 1.0)
		hud.set_window(frac, true)
		field.set_rush_progress(1.0 - frac)
		if _window_left <= 0.0:
			_kick_blocked()


# --- attempt flow ---------------------------------------------------------------

func _start_attempt() -> void:
	_attempt_id += 1
	var my_id := _attempt_id
	phase = Phase.SETUP
	_can_continue = false
	Engine.time_scale = 1.0

	var wind_mph := wind.roll(_rng, tuning)
	situation = KickSituation.roll(_rng, tuning, wind_mph)
	field.set_distance(situation.distance_m())
	field.set_wind(wind_mph, tuning.max_wind_mph)
	field.reset_rush()
	ball.reset(field.tee_position())
	trail.clear()
	cam.reset_to(field.tee_position(), situation.distance_m())
	pressure.setup(situation.pressure, tuning, modifiers)
	aim_marker.visible = true

	hud.show_situation(situation, tuning)
	hud.hide_result()
	hud.set_window(1.0, false)
	hud.set_hint("Get set...")

	await get_tree().create_timer(tuning.snap_delay).timeout
	if my_id != _attempt_id:
		return
	phase = Phase.KICK_WINDOW
	_window_total = pressure.kick_window_sec()
	_window_left = _window_total
	hud.set_window(1.0, true)
	hud.set_hint("SWIPE UP TO KICK!")
	Sfx.play(&"snap")


func _try_kick(swipe: Swipe) -> void:
	var problem := kicker.validate(swipe, tuning)
	if problem != "":
		hud.flash_hint(problem)
		return
	var shot: KickController.Shot = kicker.build_shot(
		swipe, tuning, modifiers, pressure.wobble_deg(), _rng)
	phase = Phase.FLIGHT
	aim_marker.visible = false
	hud.set_window(0.0, false)
	hud.set_hint("")
	if tuning.show_debug_readout:
		hud.show_shot_info("Power %d%%  Aim %+.1f°  Wobble %+.1f°" % [
			roundi(shot.power * 100.0), shot.swipe_aim_deg, shot.wobble_deg])

	ball.launch(shot.velocity, tuning.gravity, wind.acceleration(tuning),
		tuning.flight_speed_scale, -situation.distance_m(), tuning.ball_spin_speed)
	trail.start(ball)
	cam.follow(ball, tuning.camera_follow_strength, tuning.camera_follow_speed)
	cam.shake(tuning.kick_shake * (0.5 + shot.power))
	Sfx.play(&"kick", 0.0, lerpf(0.9, 1.15, shot.power))


func _kick_blocked() -> void:
	aim_marker.visible = false
	hud.set_window(0.0, false)
	field.set_rush_progress(1.0)
	# Pop the ball up and back off the rusher's hands.
	var deflect := Vector3(_rng.randf_range(-2.5, 2.5), 5.0, 2.5)
	ball.launch(deflect, tuning.gravity, Vector3.ZERO, 1.0, -INF, tuning.ball_spin_speed)
	cam.shake(tuning.kick_shake * 2.0)
	_resolve(KickResult.Outcome.BLOCKED)


func _resolve(outcome: KickResult.Outcome) -> void:
	phase = Phase.RESULT
	var my_id := _attempt_id
	GameState.record_attempt(situation.distance_yards, situation.pressure, outcome)

	if KickResult.is_good(outcome):
		Sfx.play(&"good")
	elif outcome == KickResult.Outcome.BLOCKED:
		Sfx.play(&"block")
	else:
		Sfx.play(&"miss")

	var detail := "%d yards" % situation.distance_yards
	if GameState.streak > 1:
		detail += "  -  %d in a row" % GameState.streak
	hud.set_hint("")
	_play_slow_mo(my_id)
	hud.show_result(outcome, detail)

	await get_tree().create_timer(tuning.result_min_display, true, false, true).timeout
	if my_id != _attempt_id:
		return
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
		Phase.KICK_WINDOW:
			_try_kick(swipe)


func _on_ball_reached_goal_plane(crossing: Vector3) -> void:
	if phase == Phase.FLIGHT:
		_resolve(KickResult.judge_at_goal_plane(crossing))


func _on_ball_landed(_at: Vector3) -> void:
	if phase == Phase.FLIGHT:
		_resolve(KickResult.Outcome.SHORT)
