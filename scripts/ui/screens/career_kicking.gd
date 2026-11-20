extends CareerScreen
## Stats (Hub → Stats): your kicking record.
##   Season: this season's line (FG, FG%, XP, long, points, game winners) and
##           every game so far.
##   Career: tabs HS | College | Pro | Career Total. Each level lists its
##           seasons (junior college counts as College) with a total row; Career
##           Total sums the levels. Built from the season history (CareerRecords),
##           so older saves show their whole record too.

## Remembered while the game runs, so coming back opens the same view.
static var view := "season"
## "" until first opened: then the level you're playing.
static var level := ""

const TOTAL := "total"
## Table columns: header, width (the season column takes the rest).
const COLS := [["FG", 104], ["PCT", 76], ["XP", 92], ["LNG", 66], ["PTS", 72]]

var _body: VBoxContainer


func _build(col: VBoxContainer) -> void:
	col.add_child(UiKit.title_block("Stats", "Kicking record"))
	if level == "":
		level = CareerRecords.level_of(CareerScreen.look_stage(career.data))
	col.add_child(_segment([["Season", "season"], ["Career", "career"]], view, func(v: String) -> void:
		view = v
		_show()))
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 14)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_body)
	col.add_child(UiKit.button("Back", go_back, UiKit.SECONDARY, "back"))
	_show()


func _show() -> void:
	for ch in _body.get_children():
		ch.queue_free()
	if view == "season":
		_season()
	else:
		_career()


# --- season --------------------------------------------------------------------------

func _season() -> void:
	var c := career.data
	var st := CareerRecords.this_season(c)
	var open := CareerRecords.current_season_open(c)
	var parts := UiKit.card(UiKit.team_color(0), 4)
	var head: VBoxContainer = parts[1]
	head.add_child(UiKit.label(("%s  ·  Season %d  ·  %s" % [career.stage_name(), c.season, career.class_year()]).to_upper(),
		22, UiKit.MUTED, UiTokens.FONT_CONDENSED))
	var row := HBoxContainer.new()
	head.add_child(row)
	var team := UiKit.label(CareerScreen.team_name(c.team).to_upper(), 32, UiKit.TEXT, UiTokens.FONT_DISPLAY)
	team.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(team)
	row.add_child(UiKit.line(CareerRecords.record_text(c.record), 40, UiKit.TEXT, UiTokens.FONT_BANNER))
	if not open:
		head.add_child(UiKit.label("Season finished. The next one starts at zero.", 22, UiKit.MUTED))
	_body.add_child(parts[0])

	var tiles := GridContainer.new()
	tiles.columns = 3
	tiles.add_theme_constant_override("h_separation", 10)
	tiles.add_theme_constant_override("v_separation", 10)
	tiles.add_child(UiKit.stat_tile("%d/%d" % [int(st["fg_made"]), int(st["fg_att"])], "Field goals"))
	tiles.add_child(UiKit.stat_tile(CareerRecords.pct_text(st), "FG pct"))
	tiles.add_child(UiKit.stat_tile("%d/%d" % [int(st["pat_made"]), int(st["pat_att"])], "Extra points"))
	tiles.add_child(UiKit.stat_tile(str(int(st["long"])) if int(st["long"]) > 0 else "-", "Long (yd)"))
	tiles.add_child(UiKit.stat_tile(str(int(st["points"])), "Points"))
	tiles.add_child(UiKit.stat_tile(str(int(st["game_winners"])), "Game winners", UiKit.GOOD))
	_body.add_child(tiles)

	var list := UiKit.scroll_list(_body)
	list.add_child(UiKit.section("Games"))
	var any := false
	for e in c.schedule:
		var r: Variant = e.get("result")
		if not (r is Dictionary):
			continue
		any = true
		list.add_child(_game_row(e, r))
	if not any:
		list.add_child(UiKit.label("No games played yet this season.", 26, UiKit.MUTED))


func _game_row(e: Dictionary, r: Dictionary) -> Control:
	var o := str(r.get("outcome", "T"))
	var col: Color = UiKit.GOOD if o == "W" else (UiKit.BAD if o == "L" else UiKit.MUTED)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	var badge := UiKit.chip(o, col, true, "", 26)
	badge.custom_minimum_size = Vector2(46, 40)
	h.add_child(badge)
	var opp: Dictionary = e.get("opponent", {})
	var name := UiKit.label("Wk %d  %s %s" % [int(e.get("week", 0)), "vs" if e.get("home", true) else "at",
		CareerScreen.team_name(opp)], 26)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(name)
	h.add_child(UiKit.line("%d-%d" % [int(r.get("us", 0)), int(r.get("them", 0))], 30, col.lightened(0.1),
		UiTokens.FONT_DISPLAY))
	var parts := UiKit.card(Color(0, 0, 0, 0), 0)
	(parts[1] as VBoxContainer).add_child(h)
	return parts[0]


# --- career --------------------------------------------------------------------------

func _career() -> void:
	var tabs := [[CareerRecords.LEVEL_SHORT[CareerRecords.LEVEL_HS], CareerRecords.LEVEL_HS],
		[CareerRecords.LEVEL_SHORT[CareerRecords.LEVEL_COLLEGE], CareerRecords.LEVEL_COLLEGE],
		[CareerRecords.LEVEL_SHORT[CareerRecords.LEVEL_PRO], CareerRecords.LEVEL_PRO], ["Total", TOTAL]]
	_body.add_child(_segment(tabs, level, func(v: String) -> void:
		level = v
		_show(), 26))
	var list := UiKit.scroll_list(_body)
	list.add_theme_constant_override("separation", 8)
	list.add_child(_table_head("Career" if level == TOTAL else "Season"))
	if level == TOTAL:
		_total_rows(list)
		return
	var rows := CareerRecords.seasons(career.data, level)
	if rows.is_empty():
		list.add_child(UiKit.label("No %s seasons yet." % str(CareerRecords.LEVEL_NAMES[level]).to_lower(), 26,
			UiKit.MUTED))
		return
	for r in rows:
		var label := "S%d  %s" % [int(r["season"]), _year(r)]
		var sub := str(r["team"]) + ("  ·  " + CareerRecords.record_text(r["record"]))
		if r["current"]:
			sub += "  ·  NOW"
		list.add_child(_table_row(label, sub, r["stats"], false))
	list.add_child(_table_row("%s total" % CareerRecords.LEVEL_NAMES[level],
		"%d season%s  ·  %s" % [rows.size(), "" if rows.size() == 1 else "s",
		CareerRecords.record_text(CareerRecords.total_record(rows))], CareerRecords.total(rows), true))


## Career Total: one row per level, then the whole career.
func _total_rows(list: VBoxContainer) -> void:
	var c := career.data
	var all_rows: Array = []
	for lv in CareerRecords.LEVELS:
		var rows := CareerRecords.seasons(c, lv)
		all_rows.append_array(rows)
		if rows.is_empty():
			continue
		list.add_child(_table_row(str(CareerRecords.LEVEL_NAMES[lv]), "%d season%s  ·  %s" % [rows.size(),
			"" if rows.size() == 1 else "s", CareerRecords.record_text(CareerRecords.total_record(rows))],
			CareerRecords.total(rows), false))
	if all_rows.is_empty():
		list.add_child(UiKit.label("No games yet.", 26, UiKit.MUTED))
		return
	list.add_child(_table_row("Career total", "%d games  ·  %s" % [int(CareerRecords.total(all_rows)["games"]),
		CareerRecords.record_text(CareerRecords.total_record(all_rows))], CareerRecords.total(all_rows), true))


func _year(r: Dictionary) -> String:
	var y := str(r.get("year", ""))
	if y == "" and r["current"]:
		y = career.class_year()
	if str(r.get("stage", "")) == CareerData.STAGE_JUCO:
		y = "JC " + y if not y.begins_with("Junior") else "JC"
	return y


func _table_head(first: String) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	var f := UiKit.line(first.to_upper(), 22, UiKit.MUTED, UiTokens.FONT_CONDENSED)
	f.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(f)
	for col in COLS:
		var l := UiKit.line(str(col[0]), 22, UiKit.MUTED, UiTokens.FONT_CONDENSED)
		l.custom_minimum_size.x = int(col[1])
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		h.add_child(l)
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", UiTokens.PAD)
	m.add_theme_constant_override("margin_right", UiTokens.PAD)
	m.add_child(h)
	return m


func _table_row(title: String, sub: String, st: Dictionary, is_total: bool) -> Control:
	var parts := UiKit.card(UiKit.ACCENT if is_total else Color(0, 0, 0, 0), 0)
	var p: PanelContainer = parts[0]
	if is_total:
		p.add_theme_stylebox_override("panel", UiKit.panel_box(UiKit.ACCENT, Color(UiKit.ACCENT.darkened(0.72), 0.95)))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	(parts[1] as VBoxContainer).add_child(h)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", -2)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(left)
	var t := UiKit.label(title, 26, UiKit.TEXT, UiTokens.FONT_DISPLAY)
	left.add_child(t)
	if sub != "":
		left.add_child(UiKit.label(sub, 20, UiKit.MUTED, UiTokens.FONT_CONDENSED))
	var vals := ["%d/%d" % [int(st["fg_made"]), int(st["fg_att"])], CareerRecords.pct_text(st),
		"%d/%d" % [int(st["pat_made"]), int(st["pat_att"])], str(int(st["long"])) if int(st["long"]) > 0 else "-",
		str(int(st["points"]))]
	for i in COLS.size():
		var l := UiKit.line(vals[i], 26, UiKit.TEXT, UiTokens.FONT_DISPLAY)
		l.custom_minimum_size.x = int(COLS[i][1])
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(l)
	return p


# --- tabs ----------------------------------------------------------------------------

## A row of tab buttons; the selected one is the primary (gold) button.
## items: [[text, value], ...]. on_pick(value).
func _segment(items: Array, selected: String, on_pick: Callable, font_size := 30) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	for it in items:
		var v := str(it[1])
		var b := UiKit.button(str(it[0]), on_pick.bind(v), UiKit.PRIMARY if v == selected else UiKit.SECONDARY)
		b.add_theme_font_size_override("font_size", font_size)
		b.custom_minimum_size.y = UiTokens.TAP_MIN
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	return row
