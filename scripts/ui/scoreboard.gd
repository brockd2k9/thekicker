class_name Scoreboard
extends Control
## The score bug (scenes/ui/scoreboard.tscn): an early-2000s TV score bug for
## the fictional "GRIDCAST" network, top-left of the game screens.
##
##            [ 1ST • 13:56 ]          <- header tab: quarter + game clock
##   [ GRID ][ ▶ RID      14 ]         <- body: network block, away row
##   [ CAST ][   BAY       7 ]         <-       home row (▶ = has the ball)
##   [ #7  FG 2/3 · XP 3/3 · LNG 44 · 9 PTS ]  <- your game line
##
## bind(state) connects it to a ScoreBugState; it redraws and flashes only
## when the state's signals fire (no polling). Brushed-chrome and black-glass
## panels are drawn in code (GlossPanel), once per resize. Display only:
## ignores the mouse, so swipes pass through to the kick.

## Fixed width (base viewport px): clear of the pause button in the top center.
const WIDTH := 272.0
const LOGO_W := 62.0
const ROW_H := 34.0
const NETWORK := ["GRID", "CAST"]
## Chrome / glass / accent colors (fixed: the bug looks the same at every stage).
const CHROME := Color("#c8ced8")
const CHROME_DARK := Color("#8c95a3")
const GLASS := Color("#0b0e14")
const GLASS_LIGHT := Color("#2a3140")
const STRIP := Color("#121a2c")
const LIVE_RED := Color("#e0261b")
const FLASH := Color("#ffd23f")
const INK := Color("#10141c")

var state: ScoreBugState

var _content: VBoxContainer
var _clock: Label
var _strip_label: Label
var _strip_flash: ColorRect
var _rows := {}  # side -> {abbr, score, poss, flash, chip}


## A panel with a glossy, beveled look: base color, a darker lower half, a
## soft highlight band on top and thin light/dark bevel lines. Drawn behind
## its children like a PanelContainer's stylebox.
class GlossPanel:
	extends PanelContainer
	var base := Color.GRAY
	var shade := Color.DIM_GRAY
	var radius := 6
	## Strength of the highlight band (chrome shines more than glass).
	var gloss := 1.0
	var corners := [true, true, true, true]  # tl, tr, br, bl
	var pad := Vector4(8, 4, 8, 4)  # left, top, right, bottom

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb := StyleBoxEmpty.new()
		sb.content_margin_left = pad.x
		sb.content_margin_top = pad.y
		sb.content_margin_right = pad.z
		sb.content_margin_bottom = pad.w
		add_theme_stylebox_override("panel", sb)
		resized.connect(queue_redraw)

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		_box(r, base)
		# Darker lower half (a two-tone "gradient"), then the gloss band.
		_box(Rect2(0, size.y * 0.52, size.x, size.y * 0.48), shade, false, true)
		_box(Rect2(1, 1, size.x - 2, size.y * 0.42), Color(1, 1, 1, 0.28 * gloss), true, false)
		_box(Rect2(2, 2, size.x - 4, size.y * 0.16), Color(1, 1, 1, 0.22 * gloss), true, false)
		# Bevel: light top line, dark bottom line, thin outline.
		draw_line(Vector2(radius, 1), Vector2(size.x - radius, 1), Color(1, 1, 1, 0.75), 1.5)
		draw_line(Vector2(radius, size.y - 1), Vector2(size.x - radius, size.y - 1), Color(0, 0, 0, 0.55), 2.0)
		var o := StyleBoxFlat.new()
		o.draw_center = false
		o.border_color = Color(0, 0, 0, 0.6)
		o.set_border_width_all(1)
		_round(o)
		o.anti_aliasing = true
		draw_style_box(o, r)

	func _box(r: Rect2, c: Color, top := true, bottom := true) -> void:
		var b := StyleBoxFlat.new()
		b.bg_color = c
		b.anti_aliasing = true
		_round(b)
		if not top:
			b.corner_radius_top_left = 0
			b.corner_radius_top_right = 0
		if not bottom:
			b.corner_radius_bottom_left = 0
			b.corner_radius_bottom_right = 0
		draw_style_box(b, r)

	func _round(b: StyleBoxFlat) -> void:
		b.corner_radius_top_left = radius if corners[0] else 0
		b.corner_radius_top_right = radius if corners[1] else 0
		b.corner_radius_bottom_right = radius if corners[2] else 0
		b.corner_radius_bottom_left = radius if corners[3] else 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_build()
	if state != null:
		_refresh_all()


## Connects to a state (call before or after adding to the tree).
func bind(s: ScoreBugState) -> void:
	if state != null:
		for pair in [[state.score_changed, _on_score], [state.clock_changed, _on_clock],
				[state.possession_changed, _on_possession], [state.stats_changed, _on_stats]]:
			if (pair[0] as Signal).is_connected(pair[1]):
				(pair[0] as Signal).disconnect(pair[1])
	state = s
	state.score_changed.connect(_on_score)
	state.clock_changed.connect(_on_clock)
	state.possession_changed.connect(_on_possession)
	state.stats_changed.connect(_on_stats)
	if is_node_ready():
		_refresh_all()


# --- layout ------------------------------------------------------------------------------

## The bug's size is its content's (it's a plain Control so it can sit in any
## container or corner).
func _get_minimum_size() -> Vector2:
	return Vector2(WIDTH, _content.get_combined_minimum_size().y if _content != null else 0.0)


func _build() -> void:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(v)
	_content = v
	v.minimum_size_changed.connect(update_minimum_size)

	# Header tab (quarter • clock), sitting over the team rows like a TV tab.
	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 0)
	tab_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(tab_row)
	var gap := Control.new()
	gap.custom_minimum_size.x = LOGO_W + 18.0
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_row.add_child(gap)
	var tab := _gloss(CHROME, CHROME_DARK, [true, true, false, false], Vector4(12, 1, 12, 0))
	tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_row.add_child(tab)
	var th := HBoxContainer.new()
	th.alignment = BoxContainer.ALIGNMENT_CENTER
	th.add_theme_constant_override("separation", 8)
	th.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab.add_child(th)
	_clock = _text("1ST 15:00", 22, INK, UiTokens.FONT_DISPLAY)
	th.add_child(_live_dot())
	th.add_child(_clock)
	var tab_gap := Control.new()
	tab_gap.custom_minimum_size.x = 14
	tab_gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_row.add_child(tab_gap)

	# Body: network block + the two team rows + a chrome end cap.
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 0)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(body)
	var logo := _gloss(CHROME, CHROME_DARK, [true, false, false, true], Vector4(6, 4, 6, 4))
	logo.custom_minimum_size.x = LOGO_W
	body.add_child(logo)
	var lv := VBoxContainer.new()
	lv.alignment = BoxContainer.ALIGNMENT_CENTER
	lv.add_theme_constant_override("separation", -8)
	lv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.add_child(lv)
	for i in NETWORK.size():
		var w := _text(NETWORK[i], 22, INK if i == 0 else LIVE_RED, UiTokens.FONT_BANNER)
		w.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lv.add_child(w)
	var glass := _gloss(GLASS_LIGHT, GLASS, [false, false, false, false], Vector4(4, 3, 8, 3))
	glass.gloss = 0.35
	glass.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(glass)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 0)
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glass.add_child(rows)
	for side in ["away", "home"]:
		rows.add_child(_team_row(side))
	var cap := _gloss(CHROME, CHROME_DARK, [false, true, true, false], Vector4(0, 0, 0, 0))
	cap.custom_minimum_size.x = 14
	body.add_child(cap)

	# Your line this game.
	var strip := _gloss(STRIP.lightened(0.12), STRIP, [false, false, true, true], Vector4(6, 2, 10, 3))
	strip.gloss = 0.4
	v.add_child(strip)
	var sh := HBoxContainer.new()
	sh.add_theme_constant_override("separation", 8)
	sh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(sh)
	var tag := _text("#%d" % (state.number if state != null else 0), 18, INK, UiTokens.FONT_DISPLAY)
	var tag_bg := _gloss(FLASH, FLASH.darkened(0.25), [true, true, true, true], Vector4(5, 0, 5, 0))
	tag_bg.radius = 3
	tag_bg.add_child(tag)
	tag_bg.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sh.add_child(tag_bg)
	_strip_label = _text("FG 0/0 · XP 0/0 · LNG - · 0 PTS", 19, Color.WHITE, UiTokens.FONT_CONDENSED)
	_strip_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sh.add_child(_strip_label)
	_strip_flash = _flash_rect()
	strip.add_child(_strip_flash)
	set_meta("tag", tag)


func _team_row(side: String) -> Control:
	var row := Control.new()
	row.custom_minimum_size.y = ROW_H
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var flash := _flash_rect()
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_child(flash)
	var h := HBoxContainer.new()
	h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	h.add_theme_constant_override("separation", 6)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(h)
	var chip := ColorRect.new()  # team color
	chip.custom_minimum_size = Vector2(5, ROW_H - 10)
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(chip)
	var poss := TextureRect.new()  # ▶ = has the ball
	poss.texture = UiIcons.texture("play", FLASH, 14)
	poss.custom_minimum_size = Vector2(14, 14)
	poss.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	poss.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	poss.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	poss.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(poss)
	var abbr := _text("TM", 27, Color.WHITE, UiTokens.FONT_DISPLAY)
	abbr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(abbr)
	var score := _text("0", 29, Color.WHITE, UiTokens.FONT_BANNER)
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score.custom_minimum_size.x = 40
	h.add_child(score)
	_rows[side] = {"abbr": abbr, "score": score, "poss": poss, "flash": flash, "chip": chip}
	return row


func _gloss(base: Color, shade: Color, corners: Array, pad: Vector4) -> GlossPanel:
	var g := GlossPanel.new()
	g.base = base
	g.shade = shade
	g.corners = corners
	g.pad = pad
	return g


func _text(t: String, size: int, color: Color, font: StringName) -> Label:
	var l := UiKit.line(t, size, color, font)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_constant_override("outline_size", 0)
	return l


## The red "live" dot between the quarter and the clock.
func _live_dot() -> Control:
	var d := Panel.new()
	var b := StyleBoxFlat.new()
	b.bg_color = LIVE_RED
	b.set_corner_radius_all(5)
	b.border_color = Color(1, 1, 1, 0.5)
	b.border_width_top = 1
	d.add_theme_stylebox_override("panel", b)
	d.custom_minimum_size = Vector2(10, 10)
	d.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	d.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_meta("dot", d)
	return d


func _flash_rect() -> ColorRect:
	var f := ColorRect.new()
	f.color = FLASH
	f.modulate.a = 0.0
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	f.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return f


# --- updates (signals) ---------------------------------------------------------------------

func _refresh_all() -> void:
	for side in ["away", "home"]:
		var t: Dictionary = state.away if side == "away" else state.home
		var r: Dictionary = _rows[side]
		(r["abbr"] as Label).text = str(t.get("abbr", ""))
		(r["chip"] as ColorRect).color = (t.get("color", Color.GRAY) as Color).lightened(0.15)
		(r["score"] as Label).text = str(state.away_score if side == "away" else state.home_score)
	(get_meta("tag") as Label).text = "#%d" % state.number
	_on_clock()
	_on_possession()
	_strip_label.text = state.stats_text()


func _on_score(side: String) -> void:
	var r: Dictionary = _rows[side]
	var l: Label = r["score"]
	l.text = str(state.away_score if side == "away" else state.home_score)
	_flash(r["flash"], 0.55)
	l.pivot_offset = l.size * 0.5
	var tw := l.create_tween().set_ignore_time_scale(true)
	tw.tween_property(l, "scale", Vector2.ONE * 1.35, 0.1)
	tw.tween_property(l, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_clock() -> void:
	_clock.text = state.header_text()
	(get_meta("dot") as Control).visible = not state.final


func _on_possession() -> void:
	for side in ["away", "home"]:
		(_rows[side]["poss"] as TextureRect).modulate.a = 1.0 if state.possession == side else 0.0


func _on_stats() -> void:
	_strip_label.text = state.stats_text()
	_flash(_strip_flash, 0.5)


func _flash(f: ColorRect, peak: float) -> void:
	var tw := f.create_tween().set_ignore_time_scale(true)
	tw.tween_property(f, "modulate:a", peak, 0.08)
	tw.tween_property(f, "modulate:a", 0.0, 0.6)
