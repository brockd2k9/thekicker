class_name Hud
extends CanvasLayer
## HUD: score, distance, situation, wind, pressure, kick clock, result banner.
## Display only: it never changes game state. Every Control has
## mouse_filter = IGNORE so swipes pass through to SwipeInput.

const GOOD_COLOR := Color(0.45, 1.0, 0.45)
const MISS_COLOR := Color(1.0, 0.4, 0.3)
## Result banner colors (broadcast style): gold for good, red for a miss.
const BANNER_GOOD := Color("#ffb81c")
const BANNER_MISS := Color("#d7261e")

var _pressure_fill: StyleBoxFlat
var _window_fill: StyleBoxFlat
## True once a mode has taken over the top row (set_scoreboard).
var _scoreboard_override := false
var _winner: Label
var _result_box: StyleBoxFlat

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
	_restyle()
	_apply_safe_area()
	GameState.session_changed.connect(update_score)
	update_score()
	hide_result()


func update_score() -> void:
	if _scoreboard_override:
		return
	_attempts.text = "KICKS %d" % GameState.attempts
	_makes.text = "MADE %d  (%d%%)" % [GameState.makes, GameState.make_percent()]


## Modes replace the session score in the top row, e.g. Challenge: kick / misses.
func set_scoreboard(left: String, right: String) -> void:
	_scoreboard_override = true
	_attempts.text = left
	_makes.text = right


## A score bug (Scoreboard) sits in the top-left corner: hide the top row and
## keep `height` px clear at the top so the distance, situation and wind /
## pressure lines start below it.
func make_room_for_score_bug(height: float) -> void:
	_scoreboard_override = true
	var top := get_node("Root/SafeArea/Column/TopRow") as Control
	top.visible = false
	var col := top.get_parent()
	if col.get_node_or_null("ScoreBugRoom") == null:
		var room := Control.new()
		room.name = "ScoreBugRoom"
		room.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(room)
		col.move_child(room, 0)
	(col.get_node("ScoreBugRoom") as Control).custom_minimum_size.y = height


## Replace the big distance line and the situation line (kickoffs:
## "KICKOFF" / "From the 35").
func set_headline(big: String, small: String) -> void:
	_distance.text = big
	_situation.text = small


func show_situation(s: KickSituation, tuning: KickTuning) -> void:
	_distance.text = "%d YD" % s.distance_yards
	_situation.text = s.label
	_wind_arrow.set_wind(s.wind_mph, tuning.max_wind_mph + tuning.max_gust_mph, s.wind_along_mph)
	var arrow := "->" if s.wind_mph > 0.0 else "<-"
	var base := roundi(absf(s.wind_mph))
	if absf(s.wind_mph) < 0.5:
		_wind_label.text = "CALM"
	elif s.wind_gust_mph > 0.0:
		_wind_label.text = "%d-%d MPH %s GUSTY" % [base, base + roundi(s.wind_gust_mph), arrow]
	else:
		_wind_label.text = "%d MPH %s" % [base, arrow]
	# Second line: head / tailwind (field goals), e.g. "+ 7 TAILWIND".
	if absf(s.wind_along_mph) >= 0.5:
		_wind_label.text += "\n%d MPH %s" % [roundi(absf(s.wind_along_mph)),
			"TAILWIND" if s.wind_along_mph > 0.0 else "HEADWIND"]
	_pressure_bar.value = s.pressure * 100.0
	_pressure_fill.bg_color = GOOD_COLOR.lerp(MISS_COLOR, s.pressure)
	_pressure_label.text = _pressure_word(s.pressure)
	_shot_info.text = ""


## Arrow follows the current (gusting) wind every frame; the label shows the range.
func set_live_wind(mph: float, max_mph: float, along: float = 0.0) -> void:
	_wind_arrow.set_wind(mph, max_mph, along)


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
	show_banner(KickResult.text(outcome), KickResult.is_good(outcome), detail)


## The result banner with any text (field goals use show_result; kickoffs show
## TOUCHBACK, DEEP KICK, RECOVERED! ...). good = gold banner, else red.
func show_banner(text: String, good: bool, detail: String) -> void:
	_result.text = text
	_result_box.bg_color = BANNER_GOOD if good else BANNER_MISS
	_result.add_theme_color_override("font_color", Color(0.08, 0.05, 0.0) if good else Color.WHITE)
	_result.modulate = Color.WHITE
	_result_sub.text = detail
	_result.visible = true
	_result_sub.visible = true
	var winner := good and "GAME WINNER" in _situation.text
	_winner.visible = winner
	# Punch in from the side, overshoot, settle. Ignores slow motion so it
	# still lands crisply while the ball floats.
	_result.pivot_offset = _result.size * 0.5
	_result.scale = Vector2(1.5, 0.3)
	_result.rotation = -0.06
	var tw := create_tween().set_ignore_time_scale(true)
	tw.set_parallel(true)
	tw.tween_property(_result, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_result, "rotation", 0.0, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_result_sub.modulate.a = 0.0
	tw.tween_property(_result_sub, "modulate:a", 1.0, 0.2).set_delay(0.18)
	if not good:
		# A short shake for misses.
		var sh := create_tween().set_ignore_time_scale(true)
		sh.tween_interval(0.3)
		for dx in [10.0, -8.0, 5.0, 0.0]:
			sh.tween_property(_result, "position:x", _result.position.x + dx, 0.04)
	if winner:
		_winner.pivot_offset = _winner.size * 0.5
		_winner.scale = Vector2.ZERO
		var wt := create_tween().set_ignore_time_scale(true)
		wt.tween_interval(0.35)
		wt.tween_property(_winner, "scale", Vector2.ONE * 1.15, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		wt.tween_property(_winner, "scale", Vector2.ONE, 0.15)
		UiKit.feedback(&"game_winner")
	else:
		UiKit.feedback(&"result_good" if good else &"result_miss")


func hide_result() -> void:
	_result.visible = false
	_result_sub.visible = false
	if _winner != null:
		_winner.visible = false


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


## Broadcast look (fonts and panels from UiTokens / the project theme).
## Layout stays in hud.tscn; this only styles it.
func _restyle() -> void:
	var dark := Color(0.03, 0.05, 0.1, 0.72)
	for l in [_attempts, _makes]:
		l.theme_type_variation = UiTokens.FONT_DISPLAY
		l.add_theme_font_size_override("font_size", 28)
		l.add_theme_stylebox_override("normal", _chip_box(dark))
		l.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if l == _attempts else Control.SIZE_SHRINK_END
		l.size_flags_stretch_ratio = 1.0
	_attempts.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_BEGIN
	_makes.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	_distance.theme_type_variation = UiTokens.FONT_BANNER
	_distance.add_theme_font_size_override("font_size", 92)
	_distance.add_theme_constant_override("outline_size", 12)
	_situation.theme_type_variation = UiTokens.FONT_DISPLAY
	_situation.add_theme_font_size_override("font_size", 30)
	for path in ["Root/SafeArea/Column/InfoRow/WindBox/WindTitle",
			"Root/SafeArea/Column/InfoRow/PressureBox/PressureTitle"]:
		var t := get_node_or_null(path) as Label
		if t != null:
			t.theme_type_variation = UiTokens.FONT_CONDENSED
			t.add_theme_font_size_override("font_size", 24)
			t.add_theme_color_override("font_color", Color("#ffb81c"))
	for l in [_wind_label, _pressure_label]:
		l.theme_type_variation = UiTokens.FONT_DISPLAY
	_hint.theme_type_variation = UiTokens.FONT_DISPLAY
	# Result banner: a slanted color block behind the text.
	_result.theme_type_variation = UiTokens.FONT_BANNER
	_result.add_theme_font_size_override("font_size", 104)
	_result.add_theme_constant_override("outline_size", 0)
	_result_box = StyleBoxFlat.new()
	_result_box.bg_color = BANNER_GOOD
	_result_box.skew = Vector2(UiTokens.SKEW, 0)
	_result_box.content_margin_left = 40
	_result_box.content_margin_right = 40
	_result_box.content_margin_top = 0
	_result_box.content_margin_bottom = 4
	_result_box.shadow_color = Color(0, 0, 0, 0.5)
	_result_box.shadow_size = 14
	_result_box.shadow_offset = Vector2(6, 8)
	_result.add_theme_stylebox_override("normal", _result_box)
	_result.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_result_sub.theme_type_variation = UiTokens.FONT_DISPLAY
	_result_sub.add_theme_font_size_override("font_size", 34)
	# "GAME WINNER" stinger under the banner (made game winners only).
	_winner = Label.new()
	_winner.text = "GAME WINNER!"
	_winner.theme_type_variation = UiTokens.FONT_BANNER
	_winner.add_theme_font_size_override("font_size", 48)
	_winner.add_theme_color_override("font_color", Color.WHITE)
	_winner.add_theme_constant_override("outline_size", 0)
	var wb := _chip_box(Color("#d7261e"))
	wb.content_margin_left = 26
	wb.content_margin_right = 26
	_winner.add_theme_stylebox_override("normal", wb)
	_winner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_winner.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_winner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_winner.visible = false
	_result_sub.add_sibling(_winner)


func _chip_box(c: Color) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = c
	b.skew = Vector2(UiTokens.SKEW, 0)
	b.set_corner_radius_all(UiTokens.RADIUS_CHIP)
	b.content_margin_left = 16
	b.content_margin_right = 16
	b.content_margin_top = 2
	b.content_margin_bottom = 2
	return b


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
