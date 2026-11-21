extends CareerScreen
## Records Book (Hub → Records): all-time record lists (RecordBook).
##   Level:  High School | College | Pro
##   Scope:  League / Conference / Division / Team (a picker; the team scope
##           starts at your team), and Single Season | Career
##   Category: ◀ name ▶ (tap the name for the full list of categories)
## The list shows rank, name, team, years and value, with your entries
## highlighted; "Your best" (pinned above Back) says how far you are from the
## next rank and from #1. Rows are pooled RecordRow scenes; a scope's lists
## are built the first time they're shown (big ones on a worker thread).

const ROW := preload("res://scenes/ui/record_row.tscn")

## Remembered while the game runs, so coming back opens the same list.
static var level := ""
static var scope := {}  # level -> scope key
static var span := RecordBook.SEASON
static var cat := "fg_made"

var _head: VBoxContainer
var _list: VBoxContainer
var _rows: Array = []
var _note: Label
var _best: VBoxContainer
var _task := -1


func _build(col: VBoxContainer) -> void:
	col.add_child(UiKit.title_block("Records", "All-time record book"))
	if level == "":
		level = CareerRecords.level_of(CareerScreen.look_stage(career.data))
	_head = VBoxContainer.new()
	_head.add_theme_constant_override("separation", 10)
	col.add_child(_head)
	_list = UiKit.scroll_list(col)
	_list.add_theme_constant_override("separation", 8)
	_note = UiKit.label("", 26, UiKit.MUTED)
	_list.add_child(_note)
	var parts := UiKit.card(UiKit.ACCENT, 2)
	_best = parts[1]
	col.add_child(parts[0])
	col.add_child(UiKit.button("Back", go_back, UiKit.SECONDARY, "back"))
	_refresh()


func _exit_tree() -> void:
	if _task >= 0:
		WorkerThreadPool.wait_for_task_completion(_task)
		_task = -1


## The scope shown for a level: the one picked before, else your team there
## (the last you played for), else the level's widest scope.
func _scope_key() -> String:
	if scope.has(level):
		return str(scope[level])
	var key := ""
	var team := _my_team(level)
	if team != "":
		key = "team:" + team
	else:
		key = str(RecordBook.scopes(level, RecordBook.KINDS[level][0])[0]["key"])
	scope[level] = key
	return key


## Your team at a level: the one you play for now, else the last you played
## for there ("" if none has a record book).
func _my_team(lv: String) -> String:
	var team := str(career.data.team.get("id", "")) if CareerRecords.level_of(career.data.stage) == lv else ""
	if team == "":
		var mine := RecordBook.my_seasons(career.data, lv)
		if not mine.is_empty():
			team = str(mine[mine.size() - 1]["team"])
	return team if team != "" and not RecordBook.scopes_of_team(lv, team).is_empty() else ""


func _refresh() -> void:
	_build_head()
	_show_list()


# --- header: level, scope + span, category ---------------------------------------------------

func _build_head() -> void:
	for ch in _head.get_children():
		ch.queue_free()
	var levels := []
	for lv in RecordBook.LEVELS:
		levels.append([CareerRecords.LEVEL_SHORT[lv] if lv == CareerRecords.LEVEL_HS else CareerRecords.LEVEL_NAMES[lv], lv])
	_head.add_child(_segment(levels, level, func(v: String) -> void:
		level = v
		_refresh()))
	var key := _scope_key()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	# The scope as a tappable card: names can be long, so they wrap.
	var parts := CareerUi.card(_pick_scope)
	var sc: PanelContainer = parts[0]
	sc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box: VBoxContainer = parts[1]
	box.add_theme_constant_override("separation", 0)
	box.add_child(UiKit.line(RecordBook.kind_name(level, RecordBook.kind_of(key)).to_upper(), 20, UiKit.ACCENT,
		UiTokens.FONT_CONDENSED))
	box.add_child(UiKit.label(_short_scope(key), 26))
	row.add_child(sc)
	for it in [["Season", RecordBook.SEASON], ["Career", RecordBook.CAREER]]:
		var v := str(it[1])
		var b := UiKit.button(str(it[0]), func() -> void:
			span = v
			_refresh(), UiKit.PRIMARY if v == span else UiKit.SECONDARY)
		b.add_theme_font_size_override("font_size", 24)
		b.custom_minimum_size = Vector2(124, UiTokens.TAP_MIN)
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(b)
	_head.add_child(row)
	var cr := HBoxContainer.new()
	cr.add_theme_constant_override("separation", 10)
	cr.add_child(_arrow("back", -1))
	var cb := UiKit.button(RecordBook.CAT_NAMES[cat], _pick_cat, UiKit.PRIMARY)
	cb.add_theme_font_size_override("font_size", 28)
	cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cb.custom_minimum_size.y = UiTokens.TAP_MIN
	cr.add_child(cb)
	cr.add_child(_arrow("next", 1))
	_head.add_child(cr)


## A scope's name for the button: team abbreviations stay readable on phones.
func _short_scope(key: String) -> String:
	if RecordBook.kind_of(key) == "team":
		var t := TeamDatabase.team(key.substr(5))
		return str(t.get("name", ""))
	return RecordBook.scope_name(level, key)


func _arrow(icon: String, step: int) -> Button:
	var b := UiKit.button("", func() -> void:
		cat = RecordBook.CATS[posmod(RecordBook.CATS.find(cat) + step, RecordBook.CATS.size())]
		_refresh(), UiKit.SECONDARY, icon)
	b.custom_minimum_size = Vector2(UiTokens.TAP_MIN, UiTokens.TAP_MIN)
	return b


func _segment(items: Array, selected: String, on_pick: Callable, font_size := 28) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	for it in items:
		var v := str(it[1])
		var b := UiKit.button(str(it[0]), on_pick.bind(v), UiKit.PRIMARY if v == selected else UiKit.SECONDARY)
		b.add_theme_font_size_override("font_size", font_size)
		b.custom_minimum_size.y = UiTokens.TAP_MIN
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	return row


# --- the list -----------------------------------------------------------------------------------

func _show_list() -> void:
	var key := _scope_key()
	if not RecordBook.is_cached(level, key):
		_set_rows([])
		_note.text = "Opening the record book..."
		_note.visible = true
		_fill_best({})
		_load(level, key)
		return
	var list := RecordBook.ranked(level, key, span, cat, career.data)
	_set_rows(list)
	_note.visible = list.is_empty()
	_note.text = _empty_text()
	_fill_best(RecordBook.standing(level, key, span, cat, career.data))


## Builds a scope's lists on a worker thread; the screen shows them when done.
func _load(lv: String, key: String) -> void:
	if _task >= 0:
		return  # _process starts the newest request when this one finishes
	_task = WorkerThreadPool.add_task(RecordBook.baseline.bind(lv, key), false, "record book")
	set_process(true)


func _process(_delta: float) -> void:
	if _task < 0:
		set_process(false)
		return
	if not WorkerThreadPool.is_task_completed(_task):
		return
	WorkerThreadPool.wait_for_task_completion(_task)
	_task = -1
	# Show the list picked now (it may have changed while loading).
	if RecordBook.is_cached(level, _scope_key()):
		_show_list()
	else:
		_load(level, _scope_key())


func _set_rows(list: Array) -> void:
	while _rows.size() < list.size():
		var r: RecordRow = ROW.instantiate()
		_list.add_child(r)
		_rows.append(r)
	for i in _rows.size():
		var r: RecordRow = _rows[i]
		r.visible = i < list.size()
		if r.visible:
			var e: Dictionary = list[i]
			var tied := (i > 0 and int(list[i - 1]["rank"]) == int(e["rank"])) \
				or (i + 1 < list.size() and int(list[i + 1]["rank"]) == int(e["rank"]))
			r.show_entry(e, cat, tied)
	_list.move_child(_note, 0)


func _empty_text() -> String:
	if cat == "made_60":
		return "Nobody has made a 60-yard field goal here yet."
	if cat == "fg_pct":
		return "No one has the %d attempts needed to qualify yet." % RecordBook.min_att(level, span)
	return "No entries yet."


# --- your best ----------------------------------------------------------------------------------

func _fill_best(st: Dictionary) -> void:
	for ch in _best.get_children():
		ch.queue_free()
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	_best.add_child(top)
	var cap := UiKit.line("YOUR BEST", 22, UiKit.ACCENT, UiTokens.FONT_CONDENSED)
	cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(cap)
	if st.is_empty():
		_best.add_child(UiKit.label("...", 24, UiKit.MUTED))
		return
	if not st.get("have", false):
		top.add_child(UiKit.line("-", 32, UiKit.MUTED, UiTokens.FONT_DISPLAY))
		_best.add_child(UiKit.label(str(st.get("text", "")), 24, UiKit.MUTED))
		return
	var rank := int(st["rank"])
	if rank > 0:
		top.add_child(UiKit.chip("#%d" % rank, UiKit.GOOD if rank == 1 else UiKit.ACCENT, rank == 1, "", 22))
	var e: Dictionary = st["entry"]
	var when := str(e.get("years", ""))
	if bool(e.get("current", false)):
		when += " (in progress)" if span == RecordBook.SEASON else " (active)"
	top.add_child(UiKit.line(when, 22, UiKit.MUTED, UiTokens.FONT_CONDENSED))
	top.add_child(UiKit.line(RecordBook.value_text(float(st["value"]), cat), 34, UiKit.TEXT, UiTokens.FONT_DISPLAY))
	_best.add_child(UiKit.label(str(st["text"]), 24, UiKit.MUTED))


# --- pickers ------------------------------------------------------------------------------------

func _pick_cat() -> void:
	var v := UiKit.modal(self, "Category")
	var root := UiKit.modal_root(v)
	var sc := _modal_scroll(v)
	for ct in RecordBook.CATS:
		var b := UiKit.button(RecordBook.CAT_NAMES[ct], func() -> void:
			cat = ct
			root.queue_free()
			_refresh(), UiKit.PRIMARY if ct == cat else UiKit.SECONDARY)
		b.add_theme_font_size_override("font_size", 28)
		sc.add_child(b)
	v.add_child(UiKit.button("Cancel", root.queue_free, UiKit.SECONDARY, "back"))


## League / Conference / Division / Team, then the scope; teams of big
## levels are picked through their conference (or pro division).
func _pick_scope() -> void:
	var v := UiKit.modal(self, "Record book")
	var root := UiKit.modal_root(v)
	var kinds := []
	for k in RecordBook.KINDS[level]:
		kinds.append([RecordBook.kind_name(level, k), k])
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	var state := {"kind": RecordBook.kind_of(_scope_key())}
	var fill: Callable
	fill = func(conf: String) -> void:
		for ch in body.get_children():
			ch.queue_free()
		# Kinds: one row, or two rows of two (pro has four).
		var grid := GridContainer.new()
		grid.columns = 2 if kinds.size() > 3 else kinds.size()
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		for k in kinds:
			var kb := UiKit.button(str(k[0]), func() -> void:
				state["kind"] = str(k[1])
				fill.call(""), UiKit.PRIMARY if str(k[1]) == state["kind"] else UiKit.SECONDARY)
			kb.add_theme_font_size_override("font_size", 24)
			kb.custom_minimum_size.y = UiTokens.TAP_MIN
			kb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(kb)
		body.add_child(grid)
		var sc := _modal_scroll(body)
		var pick := func(key: String) -> void:
			scope[level] = key
			root.queue_free()
			_refresh()
		var kind: String = state["kind"]
		if kind == "team":
			var confs := RecordBook.scopes(level, "conference")
			var my_team := _my_team(level)
			if conf == "" and confs.size() > 1:
				if my_team != "":
					sc.add_child(_pick_button("Your team: " + str(TeamDatabase.team(my_team)["name"]),
						pick.bind("team:" + my_team), true))
				for cs in confs:
					sc.add_child(_pick_button(_conf_text(cs) + "  ›", fill.bind(str(cs["key"]))))
				return
			if conf != "":
				sc.add_child(_pick_button("‹  All", fill.bind("")))
			for t in RecordBook.scopes(level, "team"):
				var tm := TeamDatabase.team(str(t["key"]).substr(5))
				if conf != "" and not RecordBook.team_in(tm, conf):
					continue
				sc.add_child(_pick_button(str(t["name"]), pick.bind(str(t["key"])), str(t["key"]) == _scope_key()))
		else:
			for s in RecordBook.scopes(level, kind):
				var text := _conf_text(s) if kind == "conference" else str(s["name"])
				sc.add_child(_pick_button(text, pick.bind(str(s["key"])), str(s["key"]) == _scope_key()))
	v.add_child(body)
	fill.call("")
	v.add_child(UiKit.button("Cancel", root.queue_free, UiKit.SECONDARY, "back"))


## College conference names can repeat across divisions: "FBS · Mountain
## States Conference" (the division's short id keeps it on one line). Pro divisions already say AFC / NFC.
func _conf_text(sc: Dictionary) -> String:
	var div := str(sc.get("division", ""))
	if level != RecordBook.LEVEL_COLLEGE or div == "":
		return str(sc["name"])
	return "%s · %s" % [div, sc["name"]]


func _pick_button(text: String, on: Callable, selected := false) -> Button:
	var b := UiKit.button(text, on, UiKit.PRIMARY if selected else UiKit.SECONDARY)
	b.add_theme_font_size_override("font_size", 25)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.clip_text = true
	b.custom_minimum_size.y = UiTokens.TAP_MIN
	return b


## A scroll list inside a modal, at most most of the screen tall.
func _modal_scroll(parent: Control) -> VBoxContainer:
	var sc := TouchScroll.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.custom_minimum_size.y = minf(get_viewport_rect().size.y * 0.55, 820.0)
	parent.add_child(sc)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	sc.add_child(list)
	return list
