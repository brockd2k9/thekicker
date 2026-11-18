class_name Hud
extends CanvasLayer
## HUD: score, distance, situation, wind, pressure, kick clock, result banner.
## Display only: it never changes game state. Every Control has
## mouse_filter = IGNORE so swipes pass through to SwipeInput.

const GOOD_COLOR := Color(0.45, 1.0, 0.45)
const MISS_COLOR := Color(1.0, 0.4, 0.3)

var _pressure_fill: StyleBoxFlat
var _window_fill: StyleBoxFlat

@onready var _attempts: Label = %AttemptsLabel
@onready var _makes: Label = %MakesLabel
@onready var _distance: Label = %DistanceLabel
@onready var _situation: Label = %SituationLabel
@onready var _wind_arrow: WindIndicator = %WindIndicator
@onready var _wind_label: Label = %WindLabel
@onready var _pressure_bar: ProgressBar = %PressureBar
@onready var _pressure_label: Label = %PressureLabel
@onready var _result: Label = %ResultLabel
@onready var _result_sub: Label = %ResultSubLabel
@onready var _shot_info: Label = %ShotInfoLabel
@onready var _window_bar: ProgressBar = %KickWindowBar
@onready var _hint: Label = %HintLabel
@onready var _trail: SwipeTrail = %SwipeTrail
@onready var _safe_area: MarginContainer = %SafeArea


func _ready() -> void:
	_pressure_fill = _style_bar(_pressure_bar)
	_window_fill = _style_bar(_window_bar)
	_apply_safe_area()
	GameState.session_changed.connect(update_score)
	update_score()
	hide_result()


func update_score() -> void:
	_attempts.text = "KICKS %d" % GameState.attempts
	_makes.text = "MADE %d  (%d%%)" % [GameState.makes, GameState.make_percent()]


func show_situation(s: KickSituation, tuning: KickTuning) -> void:
	_distance.text = "%d YD" % s.distance_yards
	_situation.text = s.label
	_wind_arrow.set_wind(s.wind_mph, tuning.max_wind_mph + tuning.max_gust_mph)
	var arrow := "->" if s.wind_mph > 0.0 else "<-"
	var base := roundi(absf(s.wind_mph))
	if absf(s.wind_mph) < 0.5:
		_wind_label.text = "CALM"
	elif s.wind_gust_mph > 0.0:
		_wind_label.text = "%d-%d MPH %s GUSTY" % [base, base + roundi(s.wind_gust_mph), arrow]
	else:
		_wind_label.text = "%d MPH %s" % [base, arrow]
	_pressure_bar.value = s.pressure * 100.0
	_pressure_fill.bg_color = GOOD_COLOR.lerp(MISS_COLOR, s.pressure)
	_pressure_label.text = _pressure_word(s.pressure)
	_shot_info.text = ""


## Arrow follows the current (gusting) wind every frame; the label shows the range.
func set_live_wind(mph: float, max_mph: float) -> void:
	_wind_arrow.set_wind(mph, max_mph)


func set_hint(text: String) -> void:
	_hint.text = text


func flash_hint(text: String) -> void:
	_hint.text = text
	var tw := create_tween()
	_hint.modulate = Color(1.0, 0.6, 0.3)
	tw.tween_property(_hint, "modulate", Color.WHITE, 0.5)


## frac: 1 = full time left, 0 = blocked. shown=false hides it without moving layout.
func set_window(frac: float, shown: bool) -> void:
	_window_bar.modulate.a = 1.0 if shown else 0.0
	_window_bar.value = frac * 100.0
	_window_fill.bg_color = MISS_COLOR.lerp(GOOD_COLOR, frac)


func show_shot_info(text: String) -> void:
	_shot_info.text = text


func show_result(outcome: KickResult.Outcome, detail: String) -> void:
	_result.text = KickResult.text(outcome)
	_result.modulate = GOOD_COLOR if KickResult.is_good(outcome) else MISS_COLOR
	_result_sub.text = detail
	_result.visible = true
	_result_sub.visible = true
	# Pop-in. Speed-compensated so it still pops during slow motion.
	_result.pivot_offset = _result.size * 0.5
	_result.scale = Vector2.ONE * 0.4
	var tw := create_tween()
	tw.set_speed_scale(1.0 / maxf(Engine.time_scale, 0.01))
	tw.tween_property(_result, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hide_result() -> void:
	_result.visible = false
	_result_sub.visible = false


# Swipe trail passthroughs (wired by the game scene).
func trail_begin(pos: Vector2) -> void:
	_trail.begin(pos)


func trail_add(pos: Vector2) -> void:
	_trail.add(pos)


func trail_finish() -> void:
	_trail.finish()


func _pressure_word(p: float) -> String:
	if p >= 0.9:
		return "CLUTCH"
	if p >= 0.6:
		return "HIGH"
	if p >= 0.3:
		return "MEDIUM"
	if p > 0.0:
		return "LOW"
	return "NONE"


func _style_bar(bar: ProgressBar) -> StyleBoxFlat:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.0, 0.0, 0.0, 0.45)
	bg.set_corner_radius_all(6)
	var fill := StyleBoxFlat.new()
	fill.bg_color = GOOD_COLOR
	fill.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)
	return fill


## Keep text out from under notches / rounded corners on phones.
func _apply_safe_area() -> void:
	if not OS.has_feature("mobile"):
		return
	var safe := DisplayServer.get_display_safe_area()
	var screen := DisplayServer.screen_get_size()
	if screen.x <= 0 or screen.y <= 0:
		return
	var vp := _safe_area.get_viewport_rect().size
	var sx := vp.x / screen.x
	var sy := vp.y / screen.y
	_safe_area.add_theme_constant_override("margin_left", 24 + int(safe.position.x * sx))
	_safe_area.add_theme_constant_override("margin_top", 24 + int(safe.position.y * sy))
	_safe_area.add_theme_constant_override("margin_right", 24 + int((screen.x - safe.end.x) * sx))
	_safe_area.add_theme_constant_override("margin_bottom", 32 + int((screen.y - safe.end.y) * sy))
