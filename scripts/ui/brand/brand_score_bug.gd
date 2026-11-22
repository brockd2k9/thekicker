class_name BrandScoreBug
extends Control
## The score bug in the broadcast system (replaces the glossy "GRIDCAST" bug
## on the game screen and over the kick):
##
##   [■ 2ND 13:56            ]   clock tab (red square = live)
##   [▌RID  ▶            14  ]   team rows: a small team-color stripe, the
##   [▌BAY                7  ]   abbreviation, the ball (red) and the score
##   [ #7  FG 2/3 · XP 3/3 · LNG 44 · 9 PTS ]   your line, white on red
##
## bind(state) connects it to a ScoreBugState (the same state as before); a
## score flashes its row red and counts up. Display only: ignores the mouse,
## so swipes pass through to the kick. Scene: scenes/ui/brand/score_bug.tscn.

## Fixed width (base viewport px): clear of the pause button in the top center.
const WIDTH := 296.0
## Compact: no "your line" strip (over the kick, where the HUD keeps only
## SCORE_BUG_ROOM clear).
@export var compact := false

var state: ScoreBugState

var _content: VBoxContainer
var _clock: Label
var _live: ColorRect
var _line: Label
var _line_panel: PanelContainer
var _rows := {}  # side -> {panel, abbr, score, poss}


func _ready() -> void:
	theme = BrandTheme.get_theme()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	if state != null:
		_refresh_all()


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


func _get_minimum_size() -> Vector2:
	return Vector2(WIDTH, _content.get_combined_minimum_size().y if _content != null else 0.0)


func _build() -> void:
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 0)
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_content)
	_content.minimum_size_changed.connect(update_minimum_size)
	# Clock tab.
	var tab := _panel(Brand.INK_0, {"cut_tr": Brand.CUT_SMALL}, Brand.SPACE_1)
	_content.add_child(tab)
	var th := HBoxContainer.new()
	th.add_theme_constant_override("separation", Brand.SPACE_2)
	th.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab.add_child(th)
	_live = ColorRect.new()
	_live.color = Brand.RED
	_live.custom_minimum_size = Vector2(12, 12)
	_live.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_live.mouse_filter = Control.MOUSE_FILTER_IGNORE
	th.add_child(_live)
	_clock = BrandTheme.label("1ST 15:00", "Eyebrow", Brand.WHITE)
	th.add_child(_clock)
	for side in ["away", "home"]:
		_content.add_child(_row(side))
	# Your line: white on red.
	_line_panel = _panel(Brand.RED, {"cut_br": Brand.CUT_SMALL}, Brand.SPACE_1)
	_line_panel.visible = not compact
	_content.add_child(_line_panel)
	_line = BrandTheme.label("", "Eyebrow", Brand.WHITE)
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line_panel.add_child(_line)


func _row(side: String) -> PanelContainer:
	var p := _panel(Brand.INK_1, {"stroke": Brand.LINE, "stroke_width": 1}, 0)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_2)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(h)
	var stripe := ColorRect.new()
	stripe.custom_minimum_size = Vector2(Brand.STRIPE, 0)
	stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(stripe)
	var abbr := BrandTheme.label("", "Subhead", Brand.WHITE)
	h.add_child(abbr)
	var poss := BrandIcons.rect("play", Brand.RED, 30)
	poss.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(poss)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(gap)
	var score := BrandTheme.label("0", "Subhead", Brand.WHITE)
	score.add_theme_font_override("font", BrandTheme.font(Brand.FONT_NUMBER))
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(score)
	var pad := Control.new()
	pad.custom_minimum_size.x = Brand.SPACE_2
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(pad)
	_rows[side] = {"panel": p, "abbr": abbr, "score": score, "poss": poss, "stripe": stripe}
	return p


func _panel(bg: Color, fields: Dictionary, pad_y: int) -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var b := ClippedBox.new()
	b.bg = bg
	for k in fields:
		b.set(k, fields[k])
	b.content_margin_left = Brand.SPACE_2
	b.content_margin_right = Brand.SPACE_2
	b.content_margin_top = pad_y
	b.content_margin_bottom = pad_y
	p.add_theme_stylebox_override("panel", b)
	return p


func _refresh_all() -> void:
	for side in ["away", "home"]:
		var t: Dictionary = state.away if side == "away" else state.home
		var r: Dictionary = _rows[side]
		(r["abbr"] as Label).text = str(t.get("abbr", ""))
		(r["stripe"] as ColorRect).color = Brand.team_accent(t.get("color", Brand.GREY))
		(r["score"] as Label).text = str(state.away_score if side == "away" else state.home_score)
	_on_clock()
	_on_possession()
	_line.text = "#%d  %s" % [state.number, state.stats_text()]


func _on_score(side: String) -> void:
	var r: Dictionary = _rows[side]
	var l: Label = r["score"]
	var old := int(l.text) if l.text.is_valid_int() else 0
	BrandMotion.count_up(l, old, state.away_score if side == "away" else state.home_score, "%d", Brand.T_BASE * 2.0)
	BrandMotion.flash(r["panel"])


func _on_clock() -> void:
	_clock.text = state.header_text()
	_live.visible = not state.final


func _on_possession() -> void:
	for side in ["away", "home"]:
		(_rows[side]["poss"] as TextureRect).modulate.a = 1.0 if state.possession == side else 0.0


func _on_stats() -> void:
	_line.text = "#%d  %s" % [state.number, state.stats_text()]
	BrandMotion.flash(_line_panel)
