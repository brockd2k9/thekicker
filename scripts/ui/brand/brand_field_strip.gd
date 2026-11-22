class_name BrandFieldStrip
extends VBoxContainer
## The field strip for the game screen, in the broadcast system: a top-down
## field drawn as a black-on-black graphic, an info bar and the last play.
## Same data as the old FieldTracker (bind(FieldState); redraws on its
## signals only), restyled: no turf green and no other hues.
##
##   field     10-yard bands in two blacks, white yard lines and numbers, end
##             zones in black with a small team-color stripe and the
##             abbreviation; the drive as a white bar with an arrow; first-down
##             line white, line of scrimmage red; field goal range as a white
##             hatch; your kick: a red frame and a red "FG 42 YDS" tag
##   info bar  each side's abbreviation and timeouts (pips), down & distance
##   last play a tag (red for scoring plays) and the play-by-play line
## Scene: scenes/ui/brand/field_strip.tscn.

## Field height as a share of its width, and the cap as a share of the screen.
const ASPECT := 0.3
const MAX_SCREEN_SHARE := 0.17
## Play types that score (their tag is red).
const SCORING := ["TD", "FG", "XP"]

var state: FieldState

var _field: _Field
var _info: Label
var _sides := {}  # side -> {abbr: Label, pips: _Pips}
var _tag: PanelContainer
var _tag_label: Label
var _play: Label
var _last_kick: Dictionary = {}


class _Field:
	extends Control
	var state: FieldState
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
		var font := BrandTheme.font(Brand.FONT_HEAD)
		var fs := int(Brand.TYPE["Eyebrow"][1])
		draw_rect(Rect2(0, 0, w, h), Brand.INK_1)
		for i in 10:
			if i % 2 == 1:
				draw_rect(Rect2(x(i * 10.0), 0, x((i + 1) * 10.0) - x(i * 10.0), h), Brand.INK_2)
		for yd in range(5, 100, 5):
			draw_line(Vector2(x(float(yd)), 0), Vector2(x(float(yd)), h),
				Color(Brand.WHITE, 0.16 if yd % 10 == 0 else 0.06), 1.0)
		for yd in range(10, 100, 10):
			var n := str(yd if yd <= 50 else 100 - yd)
			var tw := font.get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			draw_string(font, Vector2(x(float(yd)) - tw * 0.5, h - 8), n, HORIZONTAL_ALIGNMENT_LEFT, -1, fs,
				Color(Brand.WHITE, 0.35))
		for gx in [x(0), x(100)]:
			draw_line(Vector2(gx, 0), Vector2(gx, h), Color(Brand.WHITE, 0.7), 2.0)
		_end_zone("away", Rect2(0, 0, x(0), h), -PI * 0.5, true)
		_end_zone("home", Rect2(x(100), 0, w - x(100), h), PI * 0.5, false)
		var s := state
		var side := s.possession
		if side != "":
			var dir := FieldState.attack_dir(side)
			if s.in_fg_range():
				var rl := x(s.fg_range_line(side))
				var gl := x(FieldState.goal_of(side))
				_hatch(Rect2(minf(rl, gl), 0, absf(gl - rl), h))
				_dashed(rl, h)
			if s.drive_start >= 0.0:
				var a := x(s.drive_start)
				var b := x(ball_shown)
				var bh := maxf(h * 0.08, 6.0)
				var cy := h * 0.58
				draw_rect(Rect2(minf(a, b), cy - bh * 0.5, absf(b - a), bh), Color(Brand.WHITE, 0.85))
				draw_colored_polygon(PackedVector2Array([Vector2(b + dir * bh * 1.3, cy),
					Vector2(b - dir * bh * 0.2, cy - bh * 1.1), Vector2(b - dir * bh * 0.2, cy + bh * 1.1)]),
					Brand.WHITE)
			if s.first_down >= 0.0 and s.down > 0:
				draw_line(Vector2(x(s.first_down), 0), Vector2(x(s.first_down), h), Brand.WHITE, 3.0)
			draw_line(Vector2(x(ball_shown), 0), Vector2(x(ball_shown), h), Brand.RED, 4.0)
			# The ball: a white football, a black lace, an arrow the way they're going.
			var bx := x(ball_shown)
			var by := h * 0.32
			var r := maxf(h * 0.07, 7.0)
			draw_set_transform(Vector2(bx, by), 0.0, Vector2(1.5, 1.0))
			draw_circle(Vector2.ZERO, r, Brand.WHITE)
			draw_set_transform(Vector2.ZERO)
			draw_line(Vector2(bx - r * 0.6, by), Vector2(bx + r * 0.6, by), Brand.INK_0, 2.0)
			var tx := bx + dir * r * 2.4
			draw_colored_polygon(PackedVector2Array([Vector2(tx + dir * r, by), Vector2(tx, by - r * 0.8),
				Vector2(tx, by + r * 0.8)]), Brand.WHITE)
		if not s.kick.is_empty():
			var fw := 3.0 + glow * 3.0
			draw_rect(Rect2(fw * 0.5, fw * 0.5, w - fw, h - fw), Brand.RED, false, fw)
			var kind := str(s.kick.get("kind", ""))
			var label: String = {"fg": "FG  %d YDS" % int(s.kick.get("yards", 0)), "pat": "EXTRA POINT",
				"kickoff": "KICKOFF", "onside": "ONSIDE KICK"}.get(kind, "")
			if label != "":
				var lw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
				var tag := Rect2(w * 0.5 - lw * 0.5 - Brand.SPACE_3, fw, lw + Brand.SPACE_3 * 2, fs + 10)
				draw_rect(tag, Brand.RED)
				draw_string(font, Vector2(tag.position.x + Brand.SPACE_3, tag.position.y + fs), label,
					HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Brand.WHITE)

	func _end_zone(side: String, r: Rect2, angle: float, stripe_left: bool) -> void:
		draw_rect(r, Brand.INK_3)
		var t: Dictionary = state.team(side)
		var accent := Brand.team_accent(t.get("color", Brand.GREY))
		var sw := float(Brand.STRIPE)
		draw_rect(Rect2(r.position.x if stripe_left else r.end.x - sw, 0, sw, r.size.y), accent)
		var font := BrandTheme.font(Brand.FONT_HEAD, true)
		var fs := int(Brand.TYPE["Eyebrow"][1])
		var name := str(t.get("abbr", "")).to_upper()
		var tw := font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_set_transform(r.get_center(), angle)
		draw_string(font, Vector2(-tw * 0.5, fs * 0.35), name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Brand.WHITE)
		draw_set_transform(Vector2.ZERO)

	func _hatch(r: Rect2) -> void:
		draw_rect(r, Color(Brand.WHITE, 0.05))
		var xx := r.position.x - r.size.y
		while xx < r.end.x:
			var a := Vector2(maxf(xx, r.position.x), r.end.y - maxf(r.position.x - xx, 0.0))
			var b := Vector2(minf(xx + r.size.y, r.end.x), r.position.y + maxf(xx + r.size.y - r.end.x, 0.0))
			draw_line(a, b, Color(Brand.WHITE, 0.1), 1.0)
			xx += 10.0

	func _dashed(lx: float, h: float) -> void:
		var y := 0.0
		while y < h:
			draw_line(Vector2(lx, y), Vector2(lx, minf(y + 6.0, h)), Color(Brand.WHITE, 0.6), 2.0)
			y += 11.0


## Timeouts left as three pips (white = left, outline = used).
class _Pips:
	extends Control
	var left := 3

	func _ready() -> void:
		custom_minimum_size = Vector2(3 * 14 + 2 * 6, 14)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		for i in 3:
			var r := Rect2(i * 20.0, 0, 14, 14)
			if i < left:
				draw_rect(r, Brand.WHITE)
			else:
				draw_rect(r.grow(-1), Brand.LINE_STRONG, false, 2.0)


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
	_field.custom_minimum_size.y = 140
	add_child(_field)
	var bar := PanelContainer.new()
	bar.theme_type_variation = "CardRaised"
	bar.add_theme_stylebox_override("panel", (BrandTheme.get_theme().get_stylebox("panel", "CardRaised") as ClippedBox).with(
		{"cut_tr": 0, "content_margin_top": Brand.SPACE_2, "content_margin_bottom": Brand.SPACE_2}))
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_3)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(h)
	h.add_child(_side("away"))
	_info = BrandTheme.label("", "Eyebrow", Brand.WHITE)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	h.add_child(_info)
	h.add_child(_side("home"))
	var line := PanelContainer.new()
	line.add_theme_stylebox_override("panel", (BrandTheme.get_theme().get_stylebox("panel", "Card") as ClippedBox).with(
		{"cut_tr": 0, "cut_br": Brand.CUT, "content_margin_top": Brand.SPACE_2, "content_margin_bottom": Brand.SPACE_2}))
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)
	var ph := HBoxContainer.new()
	ph.add_theme_constant_override("separation", Brand.SPACE_3)
	ph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(ph)
	_tag = PanelContainer.new()
	_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tag.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_tag_label = BrandTheme.label("", "Eyebrow", Brand.WHITE)
	_tag.add_child(_tag_label)
	ph.add_child(_tag)
	_play = BrandTheme.label("", "Body")
	_play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_play.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ph.add_child(_play)


func _side(side: String) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", Brand.SPACE_1)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var abbr := BrandTheme.label("", "Eyebrow", Brand.WHITE)
	abbr.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if side == "away" else HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(abbr)
	var pips := _Pips.new()
	pips.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if side == "away" else Control.SIZE_SHRINK_END
	v.add_child(pips)
	_sides[side] = {"abbr": abbr, "pips": pips}
	return v


func _fit_height() -> void:
	var vh := get_viewport_rect().size.y if is_inside_tree() else 1280.0
	var want := clampf(size.x * ASPECT, 110.0, vh * MAX_SCREEN_SHARE)
	if not is_equal_approx(_field.custom_minimum_size.y, want):
		_field.custom_minimum_size.y = want


func _refresh() -> void:
	if _field == null or state == null:
		return
	_info.text = state.info_text()
	for side in ["away", "home"]:
		(_sides[side]["abbr"] as Label).text = str(state.team(side).get("abbr", ""))
		var p: _Pips = _sides[side]["pips"]
		p.left = int(state.timeouts.get(side, 3))
		p.queue_redraw()
	_play.text = state.play_text
	var type := state.play_type
	_tag.visible = type != ""
	if type != "":
		var key := "ChipRed" if type in SCORING else "ChipNeutral"
		_tag.add_theme_stylebox_override("panel", BrandTheme.get_theme().get_stylebox("panel", key))
		_tag_label.text = type
	if not state.kick.is_empty() and state.kick != _last_kick:
		var tw := create_tween()
		tw.tween_method(func(g: float) -> void:
			_field.glow = g
			_field.queue_redraw(), 1.0, 0.0, Brand.T_BASE * 4.0)
	_last_kick = state.kick.duplicate()
	_field.queue_redraw()


func _on_ball_moved(from: float) -> void:
	if _field == null:
		return
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void:
		_field.ball_shown = v
		_field.queue_redraw(), from, state.ball, Brand.T_BASE * 3.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
