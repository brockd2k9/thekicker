extends Control
## UI Gallery: every broadcast-system component in every state (normal, hover,
## focus, pressed, disabled), plus the palette (with contrast ratios), the type
## scale, the icons and the motion, at portrait phone size. A review page for
## the look; the layout checker (tools/ui_check.gd, shots gallery_1..N) pages
## through it. Opened from the main menu in debug builds.

const PRIMARY := preload("res://scenes/ui/brand/primary_button.tscn")
const SECONDARY := preload("res://scenes/ui/brand/secondary_button.tscn")
const TABS := preload("res://scenes/ui/brand/tab_bar.tscn")
const SEGMENTED := preload("res://scenes/ui/brand/segmented_toggle.tscn")
const ROW := preload("res://scenes/ui/brand/list_row.tscn")
const TILE := preload("res://scenes/ui/brand/stat_tile.tscn")
const BAR := preload("res://scenes/ui/brand/progress_bar.tscn")
const CARD := preload("res://scenes/ui/brand/card.tscn")
const HEADER := preload("res://scenes/ui/brand/header_bar.tscn")
const BANNER := preload("res://scenes/ui/brand/banner.tscn")
const POPUP := preload("res://scenes/ui/brand/popup.tscn")
const CHIP := preload("res://scenes/ui/brand/chip.tscn")
const STATES := ["normal", "hover", "focus", "pressed", "disabled"]
## A sample team color, to show how small team accents look.
const SAMPLE_TEAM := "#1f3a8a"

var scroll: ScrollContainer
var _list: VBoxContainer
var _demo_tile: BrandStatTile


func _ready() -> void:
	theme = BrandTheme.get_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Brand.INK_0
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var safe := MarginContainer.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(safe)
	UiKit.apply_safe_area(safe, Brand.MARGIN)
	var center := HBoxContainer.new()
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe.add_child(center)
	var col := VBoxContainer.new()
	col.custom_minimum_size.x = Brand.COLUMN
	col.add_theme_constant_override("separation", Brand.SPACE_3)
	center.add_child(col)
	col.add_child(_make(HEADER, {"eyebrow": "Broadcast design system", "title": "UI Gallery"}))
	scroll = TouchScroll.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var pad := MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_right", Brand.SPACE_3)
	scroll.add_child(pad)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", Brand.SPACE_4)
	pad.add_child(_list)
	var back: BrandButton = _make(SECONDARY, {"text": "Back", "icon_name": "back"})
	back.pressed.connect(func() -> void: Screens.go(Screens.MAIN_MENU))
	col.add_child(back)
	_build()


func _build() -> void:
	_palette()
	_type()
	_buttons()
	_tabs_and_toggles()
	_rows()
	_tiles()
	_bars()
	_cards()
	_banners()
	_popup()
	_chips()
	_game_pieces()
	_motion()
	_icons()


# --- sections ------------------------------------------------------------------------

func _section(title: String) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", Brand.SPACE_3)
	_list.add_child(v)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_2)
	v.add_child(h)
	var tick := ColorRect.new()
	tick.color = Brand.RED
	tick.custom_minimum_size = Vector2(Brand.RULE, 28)
	tick.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(tick)
	var l := BrandUi.text(title, "Subhead")
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(l)
	return v


func _palette() -> void:
	var v := _section("Palette")
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", Brand.SPACE_3)
	grid.add_theme_constant_override("v_separation", Brand.SPACE_2)
	v.add_child(grid)
	for name in Brand.PALETTE:
		var c: Color = Brand.PALETTE[name]
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", Brand.SPACE_2)
		h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sw := Panel.new()
		var box := ClippedBox.new()
		box.bg = c
		box.stroke = Brand.LINE
		box.cut_br = Brand.CUT_SMALL
		sw.add_theme_stylebox_override("panel", box)
		sw.custom_minimum_size = Vector2(64, 64)
		h.add_child(sw)
		var t := VBoxContainer.new()
		t.add_theme_constant_override("separation", 0)
		t.add_child(BrandTheme.label(name, "Eyebrow", Brand.WHITE))
		t.add_child(BrandTheme.label("#%s" % c.to_html(false), "Caption"))
		h.add_child(t)
		grid.add_child(h)
	v.add_child(BrandTheme.label("Text contrast (WCAG)", "Eyebrow"))
	var cg := GridContainer.new()
	cg.columns = 2
	cg.add_theme_constant_override("h_separation", Brand.SPACE_3)
	v.add_child(cg)
	for p in Brand.TEXT_PAIRS:
		var ratio := Brand.contrast(Brand.PALETTE[p[0]], Brand.PALETTE[p[1]])
		cg.add_child(BrandTheme.label("%s on %s" % [p[0], p[1]], "Caption"))
		cg.add_child(BrandTheme.label("%.1f : 1 (%s%s)" % [ratio, "ok" if ratio >= float(p[2]) else "FAIL",
			", large text" if float(p[2]) < 4.5 else ""], "Caption",
			Brand.WHITE if ratio >= float(p[2]) else Brand.RED_HOT))


func _type() -> void:
	var v := _section("Type scale")
	for name in BrandTheme.LABELS:
		var ty := BrandTheme.type_of(name)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", Brand.SPACE_3)
		var sample := "52" if name in ["Hero", "Display"] else "Field goal 52 yd"
		var l := BrandTheme.label(sample, name)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.clip_text = true
		h.add_child(l)
		var tag := BrandTheme.label("%s %d" % [name, int(ty["size"])], "Caption")
		tag.size_flags_vertical = Control.SIZE_SHRINK_END
		h.add_child(tag)
		v.add_child(h)


func _buttons() -> void:
	var v := _section("Buttons")
	var grid := _grid(v)
	for kind in [[PRIMARY, "Primary"], [SECONDARY, "Secondary"]]:
		for st in STATES:
			var b: BrandButton = _make(kind[0], {"text": "Play Week" if kind[1] == "Primary" else "Menu",
				"icon_name": "play" if kind[1] == "Primary" else "home"})
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(_state(kind[1] + "  ·  " + st, b))
			b.preview_state.call_deferred(st)


func _tabs_and_toggles() -> void:
	var v := _section("Tab bar")
	var tabs: BrandTabs = _make(TABS, {"tabs": PackedStringArray(["Season", "Career", "Records"]), "selected": 0})
	v.add_child(_state("selected Season  ·  Career hover  ·  Records disabled", tabs))
	(func() -> void:
		tabs.preview_state(1, "hover")
		tabs.preview_state(2, "disabled")).call_deferred()
	var t2: BrandTabs = _make(TABS, {"tabs": PackedStringArray(["Attributes", "Perks"]), "selected": 1})
	v.add_child(_state("selected Perks  ·  Attributes focus", t2))
	t2.preview_state.call_deferred(0, "focus")
	var s := _section("Segmented toggle")
	var seg: BrandSegmented = _make(SEGMENTED, {"options": PackedStringArray(["Light", "Normal", "Hard"]), "selected": 1})
	s.add_child(_state("selected Normal", seg))
	var seg2: BrandSegmented = _make(SEGMENTED, {"options": PackedStringArray(["Light", "Normal", "Hard"]),
		"selected": 0, "disabled_options": PackedInt32Array([2])})
	s.add_child(_state("selected Light  ·  Normal hover  ·  Hard disabled", seg2))
	seg2.preview_state.call_deferred(1, "hover")


func _rows() -> void:
	var v := _section("List rows")
	var data := [["normal", "Kicking Power", "Range +0.4 yd per point", "38", "football"],
		["hover", "Followers", "", "28.4K", "team"],
		["focus", "Savings", "After taxes and agent", "$1.20M", "money"],
		["pressed", "Season 5", "", "8-3", "calendar"],
		["disabled", "Perks (locked)", "Unlock at 25 skill points", "0/15", "lock"],
		["normal", "Cape Girardeau Coastal University Thunderbirds", "Long names wrap, never cut off", "1,234,567", "trophy"]]
	for d in data:
		var r: BrandListRow = _make(ROW, {"title": d[1], "subtitle": d[2], "value": d[3], "icon_name": d[4]})
		v.add_child(_state(str(d[0]), r))
		r.preview_state.call_deferred(str(d[0]))


func _tiles() -> void:
	var v := _section("Stat tiles")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_3)
	v.add_child(row)
	row.add_child(_make(TILE, {"caption": "FG range", "value": 52.0, "unit": "yd", "highlight": true}))
	row.add_child(_make(TILE, {"caption": "Skill pts", "value": 24.0, "delta": "+6 this week"}))
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", Brand.SPACE_3)
	v.add_child(row2)
	row2.add_child(_make(TILE, {"caption": "Followers", "value": 1234567.0, "number_format": "%s"}))
	row2.add_child(_make(TILE, {"caption": "Standing", "value": 41.0, "delta": "-8 after the fine"}))


func _bars() -> void:
	var v := _section("Progress bars")
	v.add_child(_make(BAR, {"title": "Accuracy", "value": 62.0}))
	v.add_child(_make(BAR, {"title": "Power  ·  gain preview", "value": 54.0, "delta": 8.0}))
	v.add_child(_make(BAR, {"title": "Energy  ·  loss preview", "value": 48.0, "delta": -12.0}))
	v.add_child(_make(BAR, {"title": "Kick trust  ·  highlight", "value": 85.0, "highlight": true}))
	v.add_child(_make(BAR, {"title": "Locked", "value": 30.0, "disabled": true}))


func _cards() -> void:
	var v := _section("Cards and header bar")
	for spec in [["card", "Card", "The base panel: black, a clipped corner, a hairline stroke."],
			["raised", "Raised card", "One step up, for content inside a screen's main card."],
			["accent", "Accent card", "A red rule on top: the one card that matters most."]]:
		var c: BrandCard = _make(CARD, {"variant": spec[0]})
		v.add_child(c)
		c.content.add_child(BrandTheme.label(spec[1], "Subhead"))
		var b := BrandTheme.label(spec[2], "Body")
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		c.content.add_child(b)
	var team: BrandCard = _make(CARD, {"team_color": Color(SAMPLE_TEAM)})
	v.add_child(team)
	team.content.add_child(BrandTheme.label("Ridgeline Falcons", "Subhead"))
	team.content.add_child(BrandTheme.label("Team color: only a small stripe", "Caption"))
	var hdr: BrandHeader = _make(HEADER, {"eyebrow": "Week 4  ·  Off the field", "title": "Locker Room Beef"})
	v.add_child(hdr)
	hdr.side.add_child(_make(CHIP, {"text": "Team", "kind": "red", "icon_name": "team"}))


func _banners() -> void:
	var v := _section("Banners")
	v.add_child(_make(BANNER, {"kind": "info", "title": "Offseason training",
		"body": "+6 skill points. You have 24 to spend in Skills."}))
	v.add_child(_make(BANNER, {"kind": "warning", "title": "On thin ice",
		"body": "Coach Rourke is losing patience: 6 of your last 10 field goals missed. Two more misses this week and Tyler Brooks takes over."}))
	v.add_child(_make(BANNER, {"kind": "warning", "title": "Suspended",
		"body": "You sit out your next 2 games. Practice still counts."}))


func _popup() -> void:
	var v := _section("Popup")
	v.add_child(_make(POPUP, {"inline": true, "title": "Retire?", "body": "Your career ends here and you'll see your career summary.",
		"primary_text": "Retire", "secondary_text": "Not yet"}))
	var open: BrandButton = _make(SECONDARY, {"text": "Open the popup"})
	open.pressed.connect(func() -> void:
		BrandPopup.open(self, "Retire?", "Your career ends here.", "Retire", Callable(), "Not yet"))
	v.add_child(open)


func _chips() -> void:
	var v := _section("Chips and tags")
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", Brand.SPACE_2)
	flow.add_theme_constant_override("v_separation", Brand.SPACE_2)
	v.add_child(flow)
	for spec in [["28.4K followers", "neutral", "team"], ["$1.20M saved", "neutral", "money"], ["Home", "outline", ""],
			["Contender", "outline", "trophy"], ["Game winner", "red", "star"], ["Ridgeline", "team", ""],
			["Locked", "neutral", "lock"]]:
		flow.add_child(_make(CHIP, {"text": spec[0], "kind": spec[1], "icon_name": spec[2],
			"team_color": Color(SAMPLE_TEAM), "disabled": spec[0] == "Locked"}))


## The game screen's pieces: the score bug, the kicker stats strip and the
## field strip, on a made-up game.
func _game_pieces() -> void:
	var v := _section("Game screen: score bug, stats strip, field strip")
	var us := {"name": "Ridgeline", "town": "Ridgeline", "mascot": "Falcons", "short": "RID", "colors": [SAMPLE_TEAM, "#f2b632"]}
	var them := {"name": "Oak Valley", "town": "Oak Valley", "mascot": "Oaks", "short": "OAK", "colors": ["#a4161a", "#111111"]}
	var bug := ScoreBugState.new()
	bug.setup(us, them, true, 7)
	bug.set_score(10, 7)
	bug.set_time(1500.0, 720.0)
	bug.set_possession("us")
	bug.set_stats({"fg_made": 2, "fg_att": 3, "pat_made": 1, "pat_att": 1, "long": 44, "points": 7})
	var b: BrandScoreBug = load("res://scenes/ui/brand/score_bug.tscn").instantiate()
	b.bind(bug)
	v.add_child(_state("score bug (the kick screen uses the compact one, without the line)", b))
	var strip: BrandStatStrip = load("res://scenes/ui/brand/stat_strip.tscn").instantiate()
	strip.set_cells([["FG", "2/3"], ["XP", "1/1"], ["Long", "44"], ["Pts", "7"]])
	v.add_child(_state("kicker stats strip", strip))
	var fm := FieldModel.new()
	fm.setup(us, them, true, 720.0, 45.0, 45.0)
	fm.state.possession = "home"
	fm.state.ball = 72.0
	fm.state.drive_start = 40.0
	fm.state.first_down = 80.0
	fm.state.down = 2
	fm.state.to_go = 8
	fm.state.play_text = "Quick pass to Mendez for 12."
	fm.state.play_type = "PASS"
	fm.state.kick = {"kind": "fg", "yards": 45}
	var f: BrandFieldStrip = load("res://scenes/ui/brand/field_strip.tscn").instantiate()
	f.bind(fm.state)
	v.add_child(_state("field strip (your field goal coming up)", f))


func _motion() -> void:
	var v := _section("Motion")
	_demo_tile = _make(TILE, {"caption": "Career points", "value": 338.0, "highlight": true})
	v.add_child(_demo_tile)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_3)
	v.add_child(row)
	var up: BrandButton = _make(SECONDARY, {"text": "Count up"})
	up.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	up.pressed.connect(func() -> void: _demo_tile.set_value(_demo_tile.value + 41.0))
	row.add_child(up)
	var fl: BrandButton = _make(PRIMARY, {"text": "Record!"})
	fl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fl.pressed.connect(func() -> void:
		_demo_tile.set_value(_demo_tile.value + 3.0)
		BrandMotion.flash(_demo_tile))
	row.add_child(fl)


func _icons() -> void:
	var v := _section("Icons (Material Symbols Sharp, filled)")
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", Brand.SPACE_3)
	grid.add_theme_constant_override("v_separation", Brand.SPACE_3)
	v.add_child(grid)
	for n in BrandIcons.names():
		var cell := VBoxContainer.new()
		cell.custom_minimum_size.x = 112
		var ic := BrandIcons.rect(n, Brand.WHITE, 48)
		ic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cell.add_child(ic)
		var l := BrandTheme.label(n, "Caption")
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.clip_text = true
		cell.add_child(l)
		grid.add_child(cell)


# --- helpers -------------------------------------------------------------------------

## A component scene with its properties set before it builds itself.
func _make(scene: PackedScene, props: Dictionary) -> Node:
	var n := scene.instantiate()
	for k in props:
		n.set(k, props[k])
	return n


func _grid(parent: Control) -> GridContainer:
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", Brand.SPACE_3)
	g.add_theme_constant_override("v_separation", Brand.SPACE_3)
	parent.add_child(g)
	return g


## A component under a small state caption.
func _state(caption: String, c: Control) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", Brand.SPACE_1)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(BrandUi.text(caption, "Caption"))
	v.add_child(c)
	return v
