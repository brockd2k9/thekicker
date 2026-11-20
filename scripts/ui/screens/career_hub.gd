extends CareerScreen
## Career Hub: where every week starts and every quit comes back to.
## Week, record, next opponent, FG / kickoff range and skill points (tap: Skills),
## the four stat groups, traits, recent results,
## and one big button that does the next thing (Play Week / Continue Week /
## Game Day / Restart Game / Results / Season Summary ...).


func _build(col: VBoxContainer) -> void:
	var c := career.data
	col.add_theme_constant_override("separation", 14)
	col.add_child(_header())

	# Next up, and where the career is heading.
	col.add_child(_next_card())
	if c.notice != "":
		var n := UiKit.chip(c.notice, UiKit.WARN, false, "info", 24)
		n.get_child(0).get_child(1).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		n.get_child(0).get_child(1).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_child(n)
		c.notice = ""
		career.save()

	var list := UiKit.scroll_list(col)
	list.add_child(CareerUi.range_strip(c, career.tuning, Screens.go.bind(Screens.CAREER_SKILLS)))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	list.add_child(grid)
	var bars := {}
	for g in [CareerData.LIFE, CareerData.FOOTBALL, CareerData.PERSONALITY]:
		grid.add_child(CareerUi.group_panel(c, g, true, bars))
	grid.add_child(_traits_panel())
	_animate_bars(bars)
	list.add_child(CareerUi.button_row([
		UiKit.button("Stats", Screens.go.bind(Screens.CAREER_KICKING), UiKit.SECONDARY, "stats"),
		UiKit.button("Recruiting", Screens.go.bind(Screens.CAREER_RECRUITING_BOARD), UiKit.SECONDARY, "school")]))
	list.add_child(CareerUi.button_row([
		UiKit.button("Stats & Traits", Screens.go.bind(Screens.CAREER_STATS), UiKit.SECONDARY, "charisma"),
		UiKit.button("People", Screens.go.bind(Screens.CAREER_PEOPLE), UiKit.SECONDARY, "social")]))

	if c.is_injured():
		list.add_child(UiKit.stat_row("Injury", "%d week(s) left" % int(c.injury["weeks_left"]), UiKit.BAD, "health"))
	list.add_child(UiKit.section("Recent results"))
	if c.recent_results.is_empty():
		list.add_child(UiKit.label("No games yet.", 26, UiKit.MUTED))
	for i in range(c.recent_results.size() - 1, -1, -1):
		list.add_child(_result_row(c.recent_results[i]))

	var main := UiKit.primary(_main_text(), _main_action, "play")
	col.add_child(CareerUi.button_row([UiKit.button("Menu", go_back, UiKit.SECONDARY, "home"), main]))
	main.size_flags_stretch_ratio = 2.0
	if not OS.has_feature("mobile"):
		main.grab_focus.call_deferred()


## Broadcast lower-third in the team's colors: who (with this season's
## kicking line), the team (with its record), and when.
func _header() -> Control:
	var c := career.data
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tc := UiKit.team_color(0)
	var box := UiKit.panel_box(Color(0, 0, 0, 0), tc.darkened(0.35))
	box.border_color = UiKit.team_color(1)
	box.border_width_top = 0
	box.border_width_left = 0
	box.border_width_right = 0
	box.border_width_bottom = 6
	box.content_margin_top = 14
	box.content_margin_bottom = 12
	p.add_theme_stylebox_override("panel", box)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(h)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(left)
	var when := "Offseason" if c.week == 0 else "Week %d of %d" % [mini(c.week, career.weeks_in_season()),
		career.weeks_in_season()]
	var top := UiKit.label("#%d  ·  %s  ·  Season %d  ·  %s  ·  %s" % [int(c.player.get("number", 0)),
		career.stage_name(), c.season, career.class_year(), when],
		22, UiKit.team_color(1).lightened(0.2), UiTokens.FONT_CONDENSED)
	top.autowrap_mode = TextServer.AUTOWRAP_OFF
	top.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	top.text = top.text.to_upper()
	left.add_child(top)
	# Name, with this season's kicking line beside it.
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 12)
	name_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_child(name_row)
	var name_l := UiKit.label(c.display_name().to_upper(), 44, Color.WHITE, UiTokens.FONT_DISPLAY)
	name_l.autowrap_mode = TextServer.AUTOWRAP_OFF
	name_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_row.add_child(name_l)
	name_row.add_child(_season_line())
	# Team, with the team's record beside it.
	var team_row := HBoxContainer.new()
	team_row.add_theme_constant_override("separation", 12)
	team_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_child(team_row)
	var team_l := UiKit.label(CareerScreen.team_name(c.team).to_upper(), 26, Color(1, 1, 1, 0.88), UiTokens.FONT_DISPLAY)
	team_l.autowrap_mode = TextServer.AUTOWRAP_OFF
	team_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	team_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	team_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	team_row.add_child(team_l)
	var rec := UiKit.line(CareerRecords.record_text(c.record), 40, Color.WHITE, UiTokens.FONT_BANNER)
	rec.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rec.add_theme_color_override("font_shadow_color", Color(UiKit.ACCENT, 0.35))
	rec.add_theme_constant_override("shadow_outline_size", 10)
	rec.add_theme_constant_override("shadow_offset_x", 0)
	rec.add_theme_constant_override("shadow_offset_y", 0)
	team_row.add_child(rec)
	return p


## This season's kicking line, two compact rows (FG and FG%; XP, long, points).
func _season_line() -> VBoxContainer:
	var st := CareerRecords.this_season(career.data)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", -4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var gold := UiKit.team_color(1).lightened(0.25)
	var l1 := UiKit.line("FG %d/%d  ·  %s" % [int(st["fg_made"]), int(st["fg_att"]), CareerRecords.pct_text(st)],
		24, Color.WHITE, UiTokens.FONT_DISPLAY)
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(l1)
	var l2 := UiKit.line("XP %d/%d  ·  LNG %s  ·  %d PTS" % [int(st["pat_made"]), int(st["pat_att"]),
		str(int(st["long"])) if int(st["long"]) > 0 else "-", int(st["points"])], 20, gold, UiTokens.FONT_CONDENSED)
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(l2)
	return v


## Bars glide from what the Hub showed last time (UI memory only).
func _animate_bars(bars: Dictionary) -> void:
	var seen: Dictionary = CareerUi.last_seen.get(_seen_key(), {})
	var i := 0
	for k in bars:
		var b: StatBar = bars[k]
		if seen.has(k):
			b.animate_from(float(seen[k]), 0.25 + i * 0.03)
		i += 1
	var now := {}
	for k in bars:
		now[k] = career.data.stat(k)
	CareerUi.last_seen = {_seen_key(): now}


func _seen_key() -> String:
	return "%d|%d" % [career.data.slot, career.data.created]


func _result_row(r: Dictionary) -> PanelContainer:
	var o := str(r.get("outcome", "T"))
	var col: Color = UiKit.GOOD if o == "W" else (UiKit.BAD if o == "L" else UiKit.MUTED)
	var parts := UiKit.card(Color(0, 0, 0, 0), 0)
	var p: PanelContainer = parts[0]
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parts[1] as VBoxContainer).add_child(h)
	var badge := UiKit.chip(o, col, true, "", 30)
	badge.custom_minimum_size = Vector2(52, 48)
	h.add_child(badge)
	var mid := VBoxContainer.new()
	mid.add_theme_constant_override("separation", 0)
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(mid)
	mid.add_child(UiKit.line("Wk %d  %s" % [int(r.get("week", 0)), r.get("opponent", "")], 28, UiKit.TEXT,
		UiTokens.FONT_DISPLAY))
	if str(r.get("line", "")) != "":
		mid.add_child(UiKit.label(str(r.get("line", "")), 22, UiKit.MUTED))
	var score := UiKit.label("%d-%d" % [int(r.get("us", 0)), int(r.get("them", 0))], 38, col.lightened(0.1),
		UiTokens.FONT_BANNER)
	score.autowrap_mode = TextServer.AUTOWRAP_OFF
	h.add_child(score)
	return p


func go_back() -> void:
	career.save()
	Screens.go(Screens.CAREER)


func _next_card() -> PanelContainer:
	var parts := UiKit.card(UiKit.ACCENT, 4)
	var p: PanelContainer = parts[0]
	var v: VBoxContainer = parts[1]
	var c := career.data
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(head)
	var kicker := UiKit.line("", 24, UiKit.MUTED, UiTokens.FONT_DISPLAY)
	head.add_child(kicker)
	var big := UiKit.label("", 34, UiKit.TEXT, UiTokens.FONT_DISPLAY)
	if not career.in_season_loop():
		kicker.text = career.stage_name().to_upper()
		big.text = "Decision time: see what's next."
	elif c.phase == CareerManager.PHASE_SEASON_END:
		kicker.text = "SEASON OVER"
		big.text = "Final record %d-%d" % [int(c.record["w"]), int(c.record["l"])]
	elif c.phase == CareerManager.PHASE_OFFSEASON:
		kicker.text = "OFFSEASON"
		big.text = "Get ready for next season."
	elif career.is_bye():
		kicker.text = "THIS WEEK"
		big.text = "BYE WEEK: no game"
	else:
		var e := career.entry()
		var opp: Dictionary = e.get("opponent", {})
		var home: bool = e.get("home", true)
		kicker.text = "THIS WEEK"
		head.add_child(UiKit.chip("HOME" if home else "AWAY", UiKit.GOOD if home else UiKit.ALT, false, "", 22))
		var vs := HBoxContainer.new()
		vs.add_theme_constant_override("separation", 12)
		vs.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var stripe := CareerUi.team_stripe(opp, 10, 34)
		stripe.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		vs.add_child(stripe)
		vs.add_child(UiKit.line("vs" if home else "at", 28, UiKit.MUTED, UiTokens.FONT_DISPLAY))
		big.text = CareerScreen.team_name(opp).to_upper()
		big.autowrap_mode = TextServer.AUTOWRAP_OFF
		big.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		big.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vs.add_child(big)
		v.add_child(vs)
		var sp := Control.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(sp)
		head.add_child(UiKit.chip(CareerScreen.strength_word(float(opp.get("strength", 50))), UiKit.WARN, false, "", 22))
		v.add_child(_status_line())
		return p
	v.add_child(big)
	v.add_child(_status_line())
	return p


## Recruiting / draft stock / contract, depending on the stage, as chips.
func _status_line() -> HFlowContainer:
	var c := career.data
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", 8)
	f.add_theme_constant_override("v_separation", 6)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var t := career.tuning
	match c.stage:
		CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO:
			f.add_child(UiKit.chip("Recruiting %d  ·  %s" % [roundi(c.recruiting_score), CareerScreen.recruit_word(c)],
				UiKit.ACCENT, false, "school", 22))
			f.add_child(UiKit.chip("GPA %.2f" % c.gpa, UiKit.MUTED, false, "book", 22))
			if c.offers.size() > 0:
				f.add_child(UiKit.chip("%d offer%s" % [c.offers.size(), "" if c.offers.size() == 1 else "s"],
					UiKit.GOOD, true, "", 22))
		CareerData.STAGE_COLLEGE:
			f.add_child(UiKit.chip("Draft stock %d  ·  %s" % [roundi(c.draft_score), CareerScreen.draft_word(c)],
				UiKit.ACCENT, false, "career", 22))
			var bad_gpa := c.gpa < t.college_min_gpa
			f.add_child(UiKit.chip("GPA %.2f%s" % [c.gpa, "  INELIGIBLE" if bad_gpa else ""],
				UiKit.BAD if bad_gpa else UiKit.MUTED, bad_gpa, "book", 22))
		CareerData.STAGE_PRO:
			f.add_child(UiKit.chip("%s  ·  %d yr left" % [Progression.money(int(c.contract.get("salary", 0))),
				int(c.contract.get("years_left", 0))], UiKit.ACCENT, false, "money", 22))
			f.add_child(UiKit.chip("Standing: %s" % CareerScreen.standing_word(
				c.retention_score if c.season_in_stage > 1 else 50.0, t), UiKit.MUTED, false, "", 22))
		_:
			f.add_child(UiKit.chip(career.stage_name(), UiKit.MUTED, false, "", 22))
	return f


func _traits_panel() -> PanelContainer:
	var parts := UiKit.card(UiKit.ALT if UiKit.palette.get("mood") == "broadcast" else UiKit.ACCENT, 10)
	var p: PanelContainer = parts[0]
	var v: VBoxContainer = parts[1]
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(UiKit.label("TRAITS", 24, UiKit.ACCENT, UiTokens.FONT_DISPLAY))
	for id in career.data.traits:
		var t := CareerContent.trait_def(str(id))
		v.add_child(_trait_tile(UiIcons.for_trait(str(id)), str(t.get("name", id)), true))
	# The closest locked trait, greyed, so there's always something to chase.
	var next := _next_trait()
	if not next.is_empty():
		v.add_child(_trait_tile(UiIcons.for_trait(str(next["id"])), str(next["text"]), false))
	elif career.data.traits.is_empty():
		v.add_child(UiKit.label("None yet. Personality stats unlock them.", 22, UiKit.MUTED))
	return p


static func _trait_tile(icon: String, text: String, unlocked: bool) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tile := PanelContainer.new()
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var b := UiKit._skewed(UiKit._box(Color(UiKit.ACCENT, 0.2) if unlocked else Color(1, 1, 1, 0.05),
		UiTokens.RADIUS_CHIP, Color(0, 0, 0, 0) if unlocked else Color(1, 1, 1, 0.18)))
	b.set_content_margin_all(6)
	if not unlocked:
		b.set_border_width_all(2)
	tile.add_theme_stylebox_override("panel", b)
	tile.add_child(UiIcons.rect(icon if unlocked else "lock", UiKit.ACCENT if unlocked else Color(1, 1, 1, 0.35), 26))
	h.add_child(tile)
	var l := UiKit.label(text, 24 if unlocked else 20, UiKit.TEXT if unlocked else Color(UiKit.TEXT, 0.45),
		UiTokens.FONT_DISPLAY if unlocked else UiTokens.FONT_CONDENSED)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(l)
	return h


## The locked trait you're closest to: {"id", "text": "Captain: Leadership 35/60"}.
func _next_trait() -> Dictionary:
	var c := career.data
	var best := {}
	var best_p := -1.0
	for t in CareerContent.traits():
		if c.has_trait(str(t["id"])):
			continue
		var worst := 1.0
		var label := ""
		for cond in t.get("unlock", []):
			var k := str(cond.get("stat", ""))
			var need := float(cond.get("min", 0))
			var frac := c.stat(k) / maxf(need, 1.0)
			if frac < worst:
				worst = frac
				label = "%s %d/%d" % [str(CareerData.STAT_NAMES.get(k, k)).replace("Kicking ", ""),
					roundi(c.stat(k)), roundi(need)]
		if worst > best_p:
			best_p = worst
			best = {"id": t["id"], "text": "%s: %s" % [t.get("name", ""), label]}
	return best


func _main_text() -> String:
	match career.data.phase:
		CareerManager.PHASE_WEEK_START:
			return "Play Bye Week" if career.is_bye() else "Play Week"
		CareerManager.PHASE_SCENARIO:
			return "Continue Week"
		CareerManager.PHASE_OFFSEASON:
			return "Offseason"
		CareerManager.PHASE_OUTLOOK:
			return "Game Day"
		CareerManager.PHASE_GAME:
			return "Restart Game"
		CareerManager.PHASE_RESULTS:
			return "Week Results"
		CareerManager.PHASE_SEASON_END:
			return "Season Summary"
		CareerManager.PHASE_RECRUITING:
			return "Recruiting Update"
		CareerManager.PHASE_COLLEGE_CHOICE:
			return "Choose a College"
		CareerManager.PHASE_TRYOUT:
			return "Tryout"
		CareerManager.PHASE_DRAFT:
			return "Draft Day" if career.data.stage == CareerData.STAGE_COLLEGE else "Free Agency"
		CareerManager.PHASE_CONTRACT:
			return "Contract Review"
		CareerManager.PHASE_RETIRED:
			return "Career Summary"
	return "Continue"


func _main_action() -> void:
	if career.data.phase == CareerManager.PHASE_WEEK_START:
		career.begin_week()
	go_to_current()
