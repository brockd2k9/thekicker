extends CareerScreen
## The league (League): three views with tabs between them, one scene each
## (career_standings / career_schedule / career_divisions .tscn set `view`).
##   Standings  each division of a conference in order (W-L-T, division
##              record, points for / against, streak), the playoff line, your
##              team highlighted; then the live playoff picture (from
##              LeagueConfig.playoff_picture_from_week), the conference title
##              games and the bracket once the postseason starts.
##   Schedule   your schedule with results (postseason included), or any
##              team's (tap a team anywhere, or "Pick a team").
##   Divisions  how the league is built and who gets in, then every
##              conference and division with each team's strength and record.
## Built for the 640-wide phone column: numbers in condensed type, long team
## names wrap instead of being cut off. Reachable from the Hub and the weekly
## Results; Back returns to wherever the career is.

const VIEWS := ["standings", "schedule", "divisions"]
const TITLES := {"standings": "Standings", "schedule": "Schedule", "divisions": "Divisions"}
## Standings columns: header, width (the team column takes the rest).
const COLS := [["W-L-T", 84], ["DIV", 60], ["PF", 52], ["PA", 52], ["STRK", 56]]

@export var view := "standings"

## While the game runs: the conference shown in Standings (-1 = yours) and
## the team shown in Schedule (-1 = yours).
static var conf_shown := -1
static var team_shown := -1

var _body: VBoxContainer
var _lg: Dictionary
var _st: Array
var _p := -1


func _uses_brand() -> bool:
	return true


func _build(col: VBoxContainer) -> void:
	_lg = career.data.league
	var ok := League.valid(_lg, career.data.stage) and int(_lg.get("season", 0)) == career.data.season
	var tabs: BrandTabs = load("res://scenes/ui/brand/tab_bar.tscn").instantiate()
	tabs.tabs = PackedStringArray(VIEWS.map(func(v: String) -> String: return TITLES[v]))
	tabs.selected = maxi(VIEWS.find(view), 0)
	tabs.tab_selected.connect(func(i: int) -> void:
		view = VIEWS[i]
		_show())
	col.add_child(tabs)
	# Three tabs share the phone column: each gets room in proportion to its
	# word, so none is cut off.
	for b in tabs._buttons:
		var f := b.get_theme_font("font")
		b.size_flags_stretch_ratio = f.get_string_size(b.text, HORIZONTAL_ALIGNMENT_LEFT, -1,
			b.get_theme_font_size("font_size")).x + Brand.SPACE_4 * 2
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", Brand.SPACE_3)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_body)
	col.add_child(BrandUi.button("Back", go_back, "secondary", "back"))
	if not ok:
		_body.add_child(BrandUi.banner("info", "No league right now",
			"Leagues run during high school, junior college, college and pro seasons."))
		return
	_st = League.standings(_lg)
	_p = League.player_index(career.data)
	_show()


## Back goes to the step the career is on (the Hub, or this week's Results).
func go_back() -> void:
	go_to_current()


func _show() -> void:
	for ch in _body.get_children():
		ch.queue_free()
	match view:
		"schedule":
			_schedule()
		"divisions":
			_divisions()
		_:
			_standings()


# --- standings -------------------------------------------------------------------------

func _standings() -> void:
	var n := League.conference_count(_lg)
	var conf := conf_shown if conf_shown >= 0 and conf_shown < n else League.conf_of(_lg, maxi(_p, 0))
	if n > 1:
		_body.add_child(_stepper(League.conference_name(_lg, conf), func(step: int) -> void:
			conf_shown = posmod(conf + step, n)
			_show()))
	var list := BrandUi.scroll_list(_body, Brand.SPACE_2)
	var s := League.rules(_lg)
	var q := int(s.get("qualifiers_per_division", 0))
	var pic := League.picture(career.data)
	var seeds := _seeds(pic)
	var regular := (_lg["weeks"] as Array).size()
	var played := int(pic.get("played", 0))
	list.add_child(BrandUi.text("%s  ·  after week %d of %d" % [_season_word(), played, regular] if played > 0
		else "%s  ·  no games yet" % _season_word(), "Caption", Brand.GREY))
	var flat := League.flat(_lg)
	for div in League.conference_divisions(_lg, conf):
		# High school and college: the conference is the division (one table).
		list.add_child(BrandUi.section(League.conference_name(_lg, conf) if flat and n == 1
			else League.division_name(_lg, div)) if not (flat and n > 1) else Control.new())
		list.add_child(_table_head())
		var order := League.division_order(_lg, _st, div)
		for k in order.size():
			list.add_child(_team_row(order[k], seeds.get(order[k], 0)))
			if q > 0 and k == q - 1 and k < order.size() - 1:
				list.add_child(_line("Playoff line"))
	var group := "conference" if flat else "division"
	var legend := ("Red line: the top %d in the %s get in." if flat and n == 1 else "Red line: the top %d in each %s get in.") \
		% [q, group] if q > 0 else "Playoff spots go by the national ranking (see the playoff picture)."
	if int(s.get("wildcards", 0)) > 0:
		legend += " Then %d wild cards per conference." % int(s["wildcards"])
	list.add_child(BrandUi.text(legend + " The number before a team is its seed in the playoff picture.", "Caption",
		Brand.GREY))
	_picture(list, pic)
	_title_games(list)
	_bracket(list)


func _season_word() -> String:
	return "Season %d" % career.data.season


## The live playoff picture: each bracket's seeds, the line, the first teams out.
func _picture(list: VBoxContainer, pic: Dictionary) -> void:
	list.add_child(BrandUi.section("Playoff picture" if not bool(pic.get("final", false)) else "Playoff field"))
	if not bool(pic.get("show", false)):
		list.add_child(BrandUi.text("Shows from week %d. Until then, every team is still alive."
			% League.config().playoff_picture_from_week, "Caption", Brand.GREY))
		return
	var line := League.picture_line(career.data)
	if line != "":
		list.add_child(BrandUi.text(line, "BodyStrong"))
	for side in pic["sides"]:
		if (pic["sides"] as Array).size() > 1:
			list.add_child(BrandUi.text(str(side["name"]), "Eyebrow", Brand.GREY))
		var inside: Array = side["in"]
		for k in inside.size():
			list.add_child(_picture_row(int(inside[k]), k + 1))
		if not (side["out"] as Array).is_empty():
			list.add_child(_line("Playoff line"))
			for i in side["out"]:
				list.add_child(_picture_row(int(i), 0))
	var bowls: Array = pic.get("bowls", [])
	if not bowls.is_empty():
		var mine := bowls.has(_p)
		list.add_child(BrandUi.text("Bowl games: the next %d teams with a .500 record or better%s." % [bowls.size(),
			" (you're one of them)" if mine else ""], "Caption", Brand.GREY))


## College conference title games this season (once set).
func _title_games(list: VBoxContainer) -> void:
	var post: Dictionary = _lg.get("post", {})
	var games: Array = post.get("ccg", []) if int(post.get("season", -1)) == int(_lg["season"]) else []
	if games.is_empty():
		return
	list.add_child(BrandUi.section("Conference title games"))
	for g in games:
		var a := int(g[1])
		var b := int(g[2])
		var txt := "%s: %s vs %s" % [League.conference_name(_lg, int(g[0]), true), _short(a), _short(b)]
		if (g as Array).size() >= 5:
			txt = "%s: %s %d, %s %d" % [League.conference_name(_lg, int(g[0]), true), _short(a), int(g[3]),
				_short(b), int(g[4])]
		list.add_child(BrandUi.text(txt, "BodyStrong" if a == _p or b == _p else "Body"))


## The bracket so far: every round's games (byes skipped).
func _bracket(list: VBoxContainer) -> void:
	var post: Dictionary = _lg.get("post", {})
	if int(post.get("season", -1)) != int(_lg["season"]) or not post.has("bracket"):
		return
	var br: Dictionary = post["bracket"]
	var rounds: Array = br.get("w", [])
	if rounds.is_empty():
		return
	var names := League.round_names(career.data)
	var offset := maxi(names.size() - League.bracket_rounds(br), 0)
	list.add_child(BrandUi.section("Bracket"))
	for r in rounds.size():
		var slots: Array = br["slots"] if r == 0 else br["w"][r - 1]
		var sc: Array = br["sc"][r]
		var lines := PackedStringArray()
		var mine := false
		for k in range(0, slots.size(), 2):
			var a := int(slots[k])
			var b := int(slots[k + 1])
			if a < 0 or b < 0:
				continue
			mine = mine or a == _p or b == _p
			lines.append("#%d %s %d, #%d %s %d" % [League.seed_of(_lg, a), _short(a), int(sc[k]),
				League.seed_of(_lg, b), _short(b), int(sc[k + 1])])
		if lines.is_empty():
			continue
		list.add_child(BrandUi.text(names[offset + r] if offset + r < names.size() else "Round %d" % (r + 1),
			"Eyebrow", Brand.RED_HOT if mine else Brand.GREY))
		for l in lines:
			list.add_child(BrandUi.text(l, "Caption"))
	var last: Array = rounds.back()
	if last.size() == 1 and int(last[0]) >= 0:
		list.add_child(BrandUi.text("Champions: %s" % CareerScreen.team_name(League.team(_lg, int(last[0]))),
			"BodyStrong", Brand.WHITE))


func _seeds(pic: Dictionary) -> Dictionary:
	var out := {}
	if not bool(pic.get("show", false)):
		return out
	for side in pic["sides"]:
		var inside: Array = side["in"]
		for k in inside.size():
			out[int(inside[k])] = k + 1
	return out


func _table_head() -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_1)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := _margins(h)
	h.add_child(_cell("#", 32, "Eyebrow", Brand.GREY_DIM))
	var team := _cell("Team", 0, "Eyebrow", Brand.GREY_DIM)
	h.add_child(team)
	for c in COLS:
		h.add_child(_cell(str(c[0]), int(c[1]), "Eyebrow", Brand.GREY_DIM, HORIZONTAL_ALIGNMENT_RIGHT))
	return m


## One standings row: seed, team (wraps), W-L-T, division, PF, PA, streak.
## Tap: that team's schedule.
func _team_row(i: int, seed: int) -> Control:
	var r: Dictionary = _st[i]
	var b := _row_button(i)
	var h: HBoxContainer = b.get_meta("box")
	var mine := i == _p
	h.add_child(_cell(str(seed) if seed > 0 else "", 32, "Eyebrow", Brand.RED_HOT if mine else Brand.GREY, 0, true))
	var name := _cell(_short(i), 0, "BodyStrong" if mine else "Caption", Brand.WHITE)
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	h.add_child(name)
	var vals := [League.record_text(r), League.record_text(r, "d"), str(int(r["pf"])), str(int(r["pa"])),
		str(r["streak"]) if str(r["streak"]) != "" else "-"]
	for k in COLS.size():
		var col := Brand.WHITE if k == 0 else Brand.GREY
		if k == 4 and str(vals[k]).begins_with("L"):
			col = Brand.RED_HOT
		h.add_child(_cell(str(vals[k]), int(COLS[k][1]), "Caption", col, HORIZONTAL_ALIGNMENT_RIGHT, true))
	return b


## A playoff picture row: seed, team, record, division.
func _picture_row(i: int, seed: int) -> Control:
	var b := _row_button(i)
	var h: HBoxContainer = b.get_meta("box")
	var mine := i == _p
	h.add_child(_cell(str(seed) if seed > 0 else "-", 32, "Eyebrow", Brand.RED_HOT if mine else Brand.GREY, 0, true))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(v)
	var name := BrandUi.text(_short(i), "BodyStrong" if mine else "Caption", Brand.WHITE)
	v.add_child(name)
	var div_order := League.division_order(_lg, _st, League.div_of(_lg, i))
	var sub := "%s in the %s" % [League.ordinal(div_order.find(i) + 1), League.division_name(_lg, League.div_of(_lg, i))]
	v.add_child(BrandUi.text(sub, "Caption", Brand.GREY))
	h.add_child(_cell(League.record_text(_st[i]), 84, "Caption", Brand.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, true))
	return b


func _row_button(i: int) -> Button:
	var b := Button.new()
	b.theme_type_variation = "ListRow"
	b.custom_minimum_size.y = Brand.TAP
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_1)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := _margins(h)
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	b.add_child(m)
	b.set_meta("box", h)
	if i == _p:
		var hi := ColorRect.new()
		hi.color = Color(Brand.RED, 0.16)
		hi.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		b.add_child(hi)
		b.move_child(hi, 0)
		var stripe := ColorRect.new()
		stripe.color = Brand.RED
		stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stripe.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
		stripe.offset_right = Brand.STRIPE
		b.add_child(stripe)
	b.pressed.connect(func() -> void:
		team_shown = i
		view = "schedule"
		_reselect_tab()
		_show())
	# A Button doesn't size to its children: grow with wrapped names.
	m.minimum_size_changed.connect(func() -> void:
		b.custom_minimum_size.y = maxf(Brand.TAP, m.get_combined_minimum_size().y))
	return b


func _margins(h: Control) -> MarginContainer:
	var m := MarginContainer.new()
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.add_theme_constant_override("margin_left", Brand.SPACE_3)
	m.add_theme_constant_override("margin_right", Brand.SPACE_2)
	m.add_theme_constant_override("margin_top", Brand.SPACE_1)
	m.add_theme_constant_override("margin_bottom", Brand.SPACE_1)
	m.add_child(h)
	return m


## A table cell: width 0 = takes the rest; numbers in condensed type.
func _cell(text: String, width: int, variation: String, color: Color, align := 0, condensed := false) -> Label:
	var l := BrandTheme.label(text, variation, color)
	if width > 0:
		l.custom_minimum_size.x = width
	else:
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if condensed:
		l.add_theme_font_override("font", BrandTheme.font(Brand.FONT_HEAD))
	return l


## The red playoff line with its label.
func _line(text: String) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_2)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var r := ColorRect.new()
	r.color = Brand.RED
	r.custom_minimum_size = Vector2(0, Brand.RULE)
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(r)
	h.add_child(BrandTheme.label(text, "Eyebrow", Brand.RED_HOT))
	return h


## "< Name >": steps through conferences (or teams).
func _stepper(text: String, on_step: Callable) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_2)
	var prev := BrandUi.button("", on_step.bind(-1), "secondary", "back")
	prev.custom_minimum_size = Vector2(Brand.TAP, Brand.TAP)
	h.add_child(prev)
	var l := BrandUi.text(text, "Subhead")
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(l)
	var next := BrandUi.button("", on_step.bind(1), "secondary", "next")
	next.custom_minimum_size = Vector2(Brand.TAP, Brand.TAP)
	h.add_child(next)
	return h


# --- schedule --------------------------------------------------------------------------

func _schedule() -> void:
	var i := team_shown if team_shown >= 0 and team_shown < League.size(_lg) else _p
	_body.add_child(_team_card(i))
	var buttons: Array = []
	if i != _p:
		buttons.append(BrandUi.button("My team", func() -> void:
			team_shown = -1
			_show(), "secondary", "home"))
	buttons.append(BrandUi.button("Pick a team", _pick_team, "secondary", "team"))
	_body.add_child(BrandUi.button_row(buttons))
	var list := BrandUi.scroll_list(_body, Brand.SPACE_1)
	if i == _p:
		for e in career.data.schedule:
			list.add_child(_my_week(e))
	else:
		for g in League.team_schedule(_lg, i):
			list.add_child(_their_week(g))
		_their_postseason(list, i)


## Who: name, division and place, the full line, strength.
func _team_card(i: int) -> BrandCard:
	var t := League.team(_lg, i)
	var colors: Array = t.get("colors", [])
	var card := BrandUi.card("raised", Color.from_string(str(colors[0]) if not colors.is_empty() else "", Brand.GREY))
	var div := League.div_of(_lg, i)
	var place := League.division_order(_lg, _st, div).find(i) + 1
	card.content.add_child(BrandUi.text("%s  ·  %s in the %s" % [League.conference_name(_lg, League.conf_of(_lg, i), true),
		League.ordinal(place), League.division_name(_lg, div)], "Eyebrow", Brand.GREY))
	card.content.add_child(BrandUi.text(CareerScreen.team_name(t), "Heading"))
	var r: Dictionary = _st[i]
	card.content.add_child(BrandUi.text("%s  ·  Div %s  ·  Conf %s" % [League.record_text(r), League.record_text(r, "d"),
		League.record_text(r, "c")], "BodyStrong"))
	card.content.add_child(BrandUi.text("Points %d-%d  ·  Streak %s  ·  %s" % [int(r["pf"]), int(r["pa"]),
		str(r["streak"]) if str(r["streak"]) != "" else "-", CareerScreen.strength_word(float(_lg["str"][i]))],
		"Caption", Brand.GREY))
	return card


## Your week: the schedule entry with its result (or what's next).
func _my_week(e: Dictionary) -> Control:
	var res: Variant = e.get("result")
	var post := Postseason.is_postseason(e)
	var label := "Wk %d" % int(e.get("week", 0))
	if str(e.get("type", "")) == "bye":
		return _week_row(label, "Bye week", "", "", false)
	var opp: Dictionary = e.get("opponent", {})
	var who := "%s %s" % ["vs" if e.get("home", true) else "at", CareerScreen.team_name(opp)]
	var sub := str(e.get("round_name", "")) if post else ""
	var oi := League.index_of(_lg, str(opp.get("id", "")))
	if not post and oi >= 0:
		sub = "%s  ·  %s" % [League.record_text(_st[oi]), League.division_name(_lg, League.div_of(_lg, oi))] \
			if League.div_of(_lg, oi) != League.div_of(_lg, _p) else "%s  ·  division game" % League.record_text(_st[oi])
	if res is Dictionary:
		var o := str(res.get("outcome", "T"))
		return _week_row(label, who, sub, "%s %d-%d" % [o, int(res.get("us", 0)), int(res.get("them", 0))],
			o == "L", int(e.get("week", 0)) == career.data.week)
	return _week_row(label, who, sub, "-", false, int(e.get("week", 0)) == career.data.week)


func _their_week(g: Dictionary) -> Control:
	var label := "Wk %d" % int(g["week"])
	if int(g["opp"]) < 0:
		return _week_row(label, "Bye week", "", "", false)
	var opp := int(g["opp"])
	var who := "%s %s" % ["vs" if g["home"] else "at", _short(opp)]
	var sub := League.record_text(_st[opp])
	if int(g["us"]) < 0:
		return _week_row(label, who, sub, "-", false)
	var o := "W" if int(g["us"]) > int(g["them"]) else ("L" if int(g["us"]) < int(g["them"]) else "T")
	return _week_row(label, who, sub, "%s %d-%d" % [o, int(g["us"]), int(g["them"])], o == "L")


## Another team's postseason games so far (bracket and conference title games).
func _their_postseason(list: VBoxContainer, i: int) -> void:
	var post: Dictionary = _lg.get("post", {})
	if int(post.get("season", -1)) != int(_lg["season"]):
		return
	for g in post.get("ccg", []):
		if (g as Array).size() >= 5 and (int(g[1]) == i or int(g[2]) == i):
			var home := int(g[1]) == i
			var us := int(g[3]) if home else int(g[4])
			var them := int(g[4]) if home else int(g[3])
			list.add_child(_week_row("Post", "vs " + _short(int(g[2]) if home else int(g[1])),
				"%s Championship" % League.conference_name(_lg, int(g[0])), "%s %d-%d" % ["W" if us > them else "L", us, them],
				us < them))
	var br: Dictionary = post.get("bracket", {})
	if br.is_empty():
		return
	var names := League.round_names(career.data)
	var offset := maxi(names.size() - League.bracket_rounds(br), 0)
	for r in (br["w"] as Array).size():
		var slots: Array = br["slots"] if r == 0 else br["w"][r - 1]
		var k := slots.find(i)
		if k < 0 or int(slots[k ^ 1]) < 0:
			continue
		var us := int(br["sc"][r][k])
		var them := int(br["sc"][r][k ^ 1])
		list.add_child(_week_row("Post", "vs " + _short(int(slots[k ^ 1])), names[offset + r] if offset + r < names.size()
			else "Playoffs", "%s %d-%d" % ["W" if us > them else "L", us, them], us < them))


func _week_row(label: String, who: String, sub: String, result: String, lost: bool, now := false) -> Control:
	var card := BrandUi.card("accent" if now else "card")
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_2)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.content.add_child(h)
	h.add_child(_cell(label, 76, "Eyebrow", Brand.GREY, 0, true))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(v)
	v.add_child(BrandUi.text(who, "BodyStrong"))
	if sub != "":
		v.add_child(BrandUi.text(sub, "Caption", Brand.GREY))
	if result != "":
		h.add_child(_cell(result, 0 if result.length() > 1 else 40, "Subhead", Brand.RED_HOT if lost else Brand.WHITE,
			HORIZONTAL_ALIGNMENT_RIGHT, true))
		(h.get_child(h.get_child_count() - 1) as Label).size_flags_horizontal = Control.SIZE_SHRINK_END
	return card


## A list of every team, by division: tap one to see its schedule.
func _pick_team() -> void:
	var box := BrandUi.modal(self, "Pick a team")
	var sc := TouchScroll.new()
	sc.custom_minimum_size = Vector2(0, 760)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(sc)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 0)
	sc.add_child(list)
	for div in League.division_count(_lg):
		list.add_child(BrandUi.section(League.division_name(_lg, div)))
		for i in League.division_order(_lg, _st, div):
			var r: BrandListRow = load("res://scenes/ui/brand/list_row.tscn").instantiate()
			r.title = _short(i)
			r.value = League.record_text(_st[i])
			r.pressed.connect(func() -> void:
				team_shown = i
				UiKit.modal_root(box).queue_free()
				_show())
			list.add_child(r)
	box.add_child(BrandUi.button("Close", func() -> void: UiKit.modal_root(box).queue_free(), "secondary", "close"))


# --- divisions -------------------------------------------------------------------------

func _divisions() -> void:
	var list := BrandUi.scroll_list(_body)
	var card := BrandUi.card("accent")
	card.content.add_child(BrandUi.text("How it works", "Subhead"))
	card.content.add_child(BrandUi.text(_format_text(), "Body"))
	list.add_child(card)
	var flat := League.flat(_lg)
	for c in League.conference_count(_lg):
		list.add_child(BrandUi.section(League.conference_name(_lg, c)))
		for div in League.conference_divisions(_lg, c):
			var dc := BrandUi.card("raised" if div == League.div_of(_lg, maxi(_p, 0)) else "card")
			if not flat:
				dc.content.add_child(BrandUi.text(League.division_name(_lg, div), "Eyebrow", Brand.GREY))
			for i in League.division_teams(_lg, div):
				var r: BrandListRow = load("res://scenes/ui/brand/list_row.tscn").instantiate()
				r.title = CareerScreen.team_name(League.team(_lg, i)) + ("  (you)" if i == _p else "")
				r.subtitle = CareerScreen.strength_word(float(_lg["str"][i]))
				r.value = League.record_text(_st[i])
				r.pressed.connect(func() -> void:
					team_shown = i
					view = "schedule"
					_reselect_tab()
					_show())
				dc.content.add_child(r)
			list.add_child(dc)


## The league's shape and who gets in, from the team database and league.tres.
func _format_text() -> String:
	var s := League.rules(_lg)
	var t := career.tuning
	var n := League.conference_count(_lg)
	var flat := League.flat(_lg)
	var games := t.games_for(career.data.stage)
	var lines := PackedStringArray()
	var who := "%d teams" % League.size(_lg)
	if career.data.stage == CareerData.STAGE_COLLEGE and str(_lg.get("scope", "")) != "":
		who += " (%s)" % str(TeamDatabase.division_info("college", str(_lg["scope"])).get("name", _lg["scope"]))
	if flat:
		who += " in %d conference%s." % [n, "" if n == 1 else "s"] if n > 1 else \
			" in the %s." % League.conference_name(_lg, 0)
	else:
		who += ": %d conferences of %d divisions." % [n, League.division_count(_lg) / maxi(n, 1)]
	lines.append(who)
	var div_g := int(s.get("division_games", 0))
	var conf_g := int(s.get("conference_games", 0))
	if flat:
		lines.append("%d games: up to %d in the conference, the rest outside it; %d bye week%s (more for some teams when the numbers are odd)." % [
			games, div_g, t.byes_per_season, "" if t.byes_per_season == 1 else "s"])
	else:
		lines.append("%d games: %d in the division, %d against the rest of the conference, %d outside it; %d bye week%s." % [
			games, div_g, conf_g, maxi(games - div_g - conf_g, 0), t.byes_per_season, "" if t.byes_per_season == 1 else "s"])
	var per := 0
	if career.data.stage == CareerData.STAGE_COLLEGE:
		if bool(s.get("title_game", false)):
			lines.append("The top two in each conference (%d+ teams) play for its title." % int(s.get("title_min", 6)))
		lines.append("Playoff: %d teams by ranking (record, schedule strength, conference champions first); the best %d conference champions are in for sure." % [
			int(s.get("field", 12)), int(s.get("auto_bids", 0))])
		lines.append("Bowl games: the next %d teams with a record of .500 or better." % int(s.get("bowl_slots", 0)))
		per = int(s.get("field", 12))
	else:
		var q := int(s.get("qualifiers_per_division", 0))
		var wc := int(s.get("wildcards", 0))
		var by_conf := bool(s.get("by_conference", false)) and n > 1
		var divs_per_side := League.division_count(_lg) / maxi(n, 1) if by_conf else League.division_count(_lg)
		per = q * divs_per_side + wc
		var txt := ""
		if flat and n == 1:
			txt = "Playoffs: the top %d." % q
		else:
			txt = "Playoffs: the top %d in each %s" % [q, "conference" if flat else "division"] if q > 1 \
				else "Playoffs: every %s winner" % ("conference" if flat else "division")
			if wc > 0:
				txt += " plus %d wild card%s" % [wc, "s" if wc != 1 else ""]
			txt += " per conference (%d each, a bracket per conference; the champions meet in the final)." % per \
				if by_conf else " (%d teams)." % per
		lines.append(txt)
	if per > 0 and League._pow2(per) != per:
		lines.append("The top seeds get first-round byes.")
	lines.append("Ties in the standings: head-to-head, then division record, then conference record, then point differential.")
	return "\n".join(lines)


# --- shared ----------------------------------------------------------------------------

## A team name for tables: pro "Boston Rebels", high school "Ashford Ridge",
## college the school's name (cities repeat across schools).
func _short(i: int) -> String:
	var t := League.team(_lg, i)
	match career.data.stage:
		CareerData.STAGE_PRO:
			return CareerScreen.team_name(t)
		CareerData.STAGE_HIGH_SCHOOL:
			return str(t.get("name", "")).trim_suffix(" High School").trim_suffix(" High")
	return str(t.get("name", ""))


func _reselect_tab() -> void:
	for ch in get_children():
		var tabs := _find_tabs(ch)
		if tabs != null:
			tabs.select(VIEWS.find(view))
			return


func _find_tabs(n: Node) -> BrandTabs:
	if n is BrandTabs:
		return n
	for ch in n.get_children():
		var f := _find_tabs(ch)
		if f != null:
			return f
	return null
