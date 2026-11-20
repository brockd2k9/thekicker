class_name FieldTracker
extends VBoxContainer
## The field tracker (scenes/ui/field_tracker.tscn): a compact top-down strip
## of the field for the sim screen, with an info bar and the last play under
## it. Portrait-first: it fills the width it's given and keeps its height to
## about 30% of the width (and at most 16% of the screen).
##
##   [ AWAY |10 20 30 40 50 40 30 20 10| HOME ]   end zones: team colors,
##   [ end  |  ===drive===>▲  :   :     | end  ]   names written vertically
##   [ TIMEOUTS 3 | 1st & 10 ball on OAK 37 | TIMEOUTS 2 ]
##   [ PASS ] Quick pass to Mendez for 12.
##
## Markers: ball (football + direction triangle, tweened between plays), line
## of scrimmage (red), first-down line (yellow), drive bar in the offense's
## color with an arrow, field goal range (soft gold) when the offense is in it,
## and a gold frame + "FG 42 YDS" when it's your kick.
## bind(state) connects to a FieldState; redraws on its `changed` signal only.

const TURF_A := Color("#3e6b34")
const TURF_B := Color("#447539")
const LINE := Color(1, 1, 1, 0.22)
const NUMBER := Color(1, 1, 1, 0.26)
const LOS := Color("#e2412f")
const FIRST_DOWN := Color("#ffd400")
const RANGE := Color("#ffd23f")
const BAR := Color("#24402a")
const BAR_DARK := Color("#152a1a")
## Field height as a share of its width, and the cap as a share of the screen.
const ASPECT := 0.3
const MAX_SCREEN_SHARE := 0.16

var state: FieldState

var _field: _Field
var _info: Label
var _to_labels := {}  # side -> Label
var _to_names := {}  # side -> Label
var _tag: PanelContainer
var _tag_label: Label
var _play: Label
var _last_kick: Dictionary = {}


## The turf, end zones and markers, drawn in code.
class _Field:
	extends Control
	var state: FieldState
	## Where the ball is drawn (abs), tweened toward state.ball.
	var ball_shown := 50.0
	var glow := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip_contents = true
		resized.connect(queue_redraw)

	func x(abs_yd: float) -> float:
		return FieldState.x_of(abs_yd, size.x)

	func _draw() -> void:
		if state == null or size.x <= 0.0:
			return
		var w := size.x
		var h := size.y
		var font := get_theme_default_font()
		# Turf stripes, every 10 yards.
		for i in 10:
			draw_rect(Rect2(x(i * 10.0), 0, x((i + 1) * 10.0) - x(i * 10.0), h), TURF_A if i % 2 == 0 else TURF_B)
		# Yard lines every 5, numbers every 10 (top row upside down, like TV).
		for yd in range(5, 100, 5):
			var lx := x(float(yd))
			draw_line(Vector2(lx, 0), Vector2(lx, h), LINE if yd % 10 == 0 else Color(LINE, 0.12), 1.0)
		var fs := clampi(int(h * 0.13), 10, 22)
		for yd in range(10, 100, 10):
			var n := str(yd if yd <= 50 else 100 - yd)
			var tw := font.get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			draw_string(font, Vector2(x(float(yd)) - tw * 0.5, h - fs * 0.45), n, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, NUMBER)
			draw_set_transform(Vector2(x(float(yd)) + tw * 0.5, fs * 0.45), PI)
			draw_string(font, Vector2.ZERO, n, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, NUMBER)
			draw_set_transform(Vector2.ZERO)
		draw_line(Vector2(x(0), 0), Vector2(x(0), h), Color(1, 1, 1, 0.6), 2.0)
		draw_line(Vector2(x(100), 0), Vector2(x(100), h), Color(1, 1, 1, 0.6), 2.0)
		_end_zone("away", Rect2(0, 0, x(0), h), -PI * 0.5)
		_end_zone("home", Rect2(x(100), 0, w - x(100), h), PI * 0.5)

		var s := state
		var side := s.possession
		if side != "":
			var dir := FieldState.attack_dir(side)
			# Field goal range, softly, when the offense is in it.
			if s.in_fg_range():
				var rl := x(s.fg_range_line(side))
				var gl := x(FieldState.goal_of(side))
				draw_rect(Rect2(minf(rl, gl), 0, absf(gl - rl), h), Color(RANGE, 0.1))
				_dashed(rl, h, Color(RANGE, 0.55))
			# Drive bar from the drive start to the ball, with an arrow.
			var team_col: Color = s.team(side).get("color", Color.WHITE)
			var bar_col := team_col.lightened(0.25) if team_col.get_luminance() < 0.25 else team_col
			if s.drive_start >= 0.0:
				var a := x(s.drive_start)
				var b := x(ball_shown)
				var bh := maxf(h * 0.09, 6.0)
				var cy := h * 0.62
				draw_rect(Rect2(minf(a, b), cy - bh * 0.5, absf(b - a), bh), Color(bar_col, 0.85))
				draw_colored_polygon(PackedVector2Array([Vector2(b + dir * bh * 1.2, cy),
					Vector2(b - dir * bh * 0.2, cy - bh * 1.1), Vector2(b - dir * bh * 0.2, cy + bh * 1.1)]),
					Color(bar_col, 0.95))
			# First-down line (yellow) and line of scrimmage (red).
			if s.first_down >= 0.0 and s.down > 0:
				draw_line(Vector2(x(s.first_down), 0), Vector2(x(s.first_down), h), FIRST_DOWN, 3.0)
			draw_line(Vector2(x(ball_shown), 0), Vector2(x(ball_shown), h), LOS, 3.0)
			# The ball: a football with a direction triangle.
			var bx := x(ball_shown)
			var by := h * 0.36
			var r := maxf(h * 0.07, 6.0)
			draw_set_transform(Vector2(bx, by), 0.0, Vector2(1.5, 1.0))
			draw_circle(Vector2.ZERO, r, Color("#7a4a24"))
			draw_arc(Vector2.ZERO, r, 0, TAU, 20, Color(1, 1, 1, 0.9), 1.2, true)
			draw_set_transform(Vector2.ZERO)
			draw_line(Vector2(bx - r * 0.6, by), Vector2(bx + r * 0.6, by), Color.WHITE, 1.5)
			var tx := bx + dir * r * 2.4
			draw_colored_polygon(PackedVector2Array([Vector2(tx + dir * r, by), Vector2(tx, by - r * 0.8),
				Vector2(tx, by + r * 0.8)]), Color.WHITE)
		# Your kick: a gold frame and the distance.
		if not s.kick.is_empty():
			var fw := 3.0 + glow * 3.0
			draw_rect(Rect2(fw * 0.5, fw * 0.5, w - fw, h - fw), Color(RANGE, 0.75 + glow * 0.25), false, fw)
			var kind := str(s.kick.get("kind", ""))
			var label: String = {"fg": "FG  %d YDS" % int(s.kick.get("yards", 0)), "pat": "EXTRA POINT",
				"kickoff": "KICKOFF", "onside": "ONSIDE KICK"}.get(kind, "")
			if label != "":
				var lf := clampi(int(h * 0.15), 12, 26)
				var lw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, lf).x
				var pill := Rect2(w * 0.5 - lw * 0.5 - 10, 6, lw + 20, lf + 8)
				var pb := StyleBoxFlat.new()
				pb.bg_color = Color(0.05, 0.06, 0.1, 0.85)
				pb.border_color = RANGE
				pb.set_border_width_all(2)
				pb.set_corner_radius_all(6)
				draw_style_box(pb, pill)
				draw_string(font, Vector2(pill.position.x + 10, pill.position.y + lf), label,
					HORIZONTAL_ALIGNMENT_LEFT, -1, lf, RANGE)

	func _end_zone(side: String, r: Rect2, angle: float) -> void:
		var t: Dictionary = state.team(side)
		var c: Color = t.get("color", Color.DIM_GRAY)
		draw_rect(r, c)
		draw_rect(r, Color(0, 0, 0, 0.12), false, 2.0)
		var c2: Color = t.get("color2", Color.WHITE)
		var txt_col := c2 if absf(c2.get_luminance() - c.get_luminance()) > 0.3 else UiKit.readable_on(c)
		var name := str(t.get("name", t.get("abbr", ""))).to_upper()
		var font: Font = get_theme_font("font", UiTokens.FONT_DISPLAY) if has_theme_font("font", UiTokens.FONT_DISPLAY) \
			else get_theme_default_font()
		var fs := int(minf(r.size.x * 0.62, 30.0))
		var tw := font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		while tw > r.size.y * 0.92 and fs > 8:
			fs -= 1
			tw = font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var center := r.get_center()
		draw_set_transform(center, angle)
		draw_string(font, Vector2(-tw * 0.5, fs * 0.35), name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, txt_col)
		draw_set_transform(Vector2.ZERO)

	func _dashed(lx: float, h: float, c: Color) -> void:
		var y := 0.0
		while y < h:
			draw_line(Vector2(lx, y), Vector2(lx, minf(y + 6.0, h)), c, 2.0)
			y += 11.0


func _ready() -> void:
	add_theme_constant_override("separation", 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_build()
	resized.connect(_fit_height)
	if state != null:
		_refresh()


func bind(s: FieldState) -> void:
	if state != null:
		if state.changed.is_connected(_refresh):
			state.changed.disconnect(_refresh)
		if state.ball_moved.is_connected(_on_ball_moved):
			state.ball_moved.disconnect(_on_ball_moved)
	state = s
	state.changed.connect(_refresh)
	state.ball_moved.connect(_on_ball_moved)
	if _field != null:
		_field.state = s
		_field.ball_shown = s.ball
		_refresh()


func _build() -> void:
	_field = _Field.new()
	_field.state = state
	if state != null:
		_field.ball_shown = state.ball
	_field.custom_minimum_size.y = 120
	add_child(_field)

	# Info bar: timeouts at the edges, down & distance and the spot centered.
	var bar := Scoreboard.GlossPanel.new()
	bar.base = BAR
	bar.shade = BAR_DARK
	bar.gloss = 0.5
	bar.radius = 0
	bar.pad = Vector4(10, 4, 10, 4)
	add_child(bar)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(h)
	h.add_child(_timeouts("away", HORIZONTAL_ALIGNMENT_LEFT))
	_info = UiKit.line("", 26, Color.WHITE, UiTokens.FONT_DISPLAY)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_info.clip_text = true
	_info.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	h.add_child(_info)
	h.add_child(_timeouts("home", HORIZONTAL_ALIGNMENT_RIGHT))

	# The last play: a colored type tag and the play-by-play line.
	var line := PanelContainer.new()
	var lb := StyleBoxFlat.new()
	lb.bg_color = Color(0.04, 0.06, 0.1, 0.9)
	lb.content_margin_left = 10
	lb.content_margin_right = 10
	lb.content_margin_top = 5
	lb.content_margin_bottom = 6
	lb.corner_radius_bottom_left = 8
	lb.corner_radius_bottom_right = 8
	line.add_theme_stylebox_override("panel", lb)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)
	var ph := HBoxContainer.new()
	ph.add_theme_constant_override("separation", 10)
	ph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(ph)
	_tag = PanelContainer.new()
	_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_tag_label = UiKit.line("", 18, Color.WHITE, UiTokens.FONT_DISPLAY)
	_tag.add_child(_tag_label)
	ph.add_child(_tag)
	_play = UiKit.line("", 22, Color(1, 1, 1, 0.9))
	_play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_play.clip_text = true
	_play.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	ph.add_child(_play)


func _timeouts(side: String, align: HorizontalAlignment) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", -4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var small := UiKit.line("TIMEOUTS", 13, Color(1, 1, 1, 0.6), UiTokens.FONT_CONDENSED)
	small.horizontal_alignment = align
	v.add_child(small)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN if align == HORIZONTAL_ALIGNMENT_LEFT else BoxContainer.ALIGNMENT_END
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var name := UiKit.line("", 15, Color(1, 1, 1, 0.75), UiTokens.FONT_CONDENSED)
	var n := UiKit.line("3", 26, Color.WHITE, UiTokens.FONT_BANNER)
	if align == HORIZONTAL_ALIGNMENT_LEFT:
		row.add_child(n)
		row.add_child(name)
	else:
		row.add_child(name)
		row.add_child(n)
	name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	v.add_child(row)
	_to_labels[side] = n
	_to_names[side] = name
	return v


## Height follows the width (portrait phones), capped to a share of the screen.
func _fit_height() -> void:
	var vh := get_viewport_rect().size.y if is_inside_tree() else 1280.0
	var want := clampf(size.x * ASPECT, 90.0, vh * MAX_SCREEN_SHARE)
	if not is_equal_approx(_field.custom_minimum_size.y, want):
		_field.custom_minimum_size.y = want


func _refresh() -> void:
	if _field == null or state == null:
		return
	_info.text = state.info_text()
	for side in ["away", "home"]:
		(_to_labels[side] as Label).text = str(int(state.timeouts.get(side, 3)))
		(_to_names[side] as Label).text = str(state.team(side).get("abbr", ""))
	_play.text = state.play_text
	var type := state.play_type
	_tag.visible = type != ""
	if type != "":
		var tb := StyleBoxFlat.new()
		tb.bg_color = FieldState.PLAY_COLORS.get(type, Color.DIM_GRAY)
		tb.skew = Vector2(UiTokens.SKEW, 0)
		tb.set_corner_radius_all(4)
		tb.content_margin_left = 8
		tb.content_margin_right = 8
		_tag.add_theme_stylebox_override("panel", tb)
		_tag_label.text = type
	# Flash the frame once when your kick comes up.
	if not state.kick.is_empty() and state.kick != _last_kick:
		var tw := create_tween()
		tw.tween_method(func(g: float) -> void:
			_field.glow = g
			_field.queue_redraw(), 1.0, 0.0, 0.8)
	_last_kick = state.kick.duplicate()
	_field.queue_redraw()


## Slide the ball (and the drive bar's end) to the new spot.
func _on_ball_moved(from: float) -> void:
	if _field == null:
		return
	var to := state.ball
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void:
		_field.ball_shown = v
		_field.queue_redraw(), from, to, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
