extends CareerScreen
## Career Hub: where every week starts and every quit comes back to.
## Week, record, next opponent, FG / kickoff range and skill points (tap: Skills),
## the four stat groups, traits, recent results,
## and one big button that does the next thing (Play Week / Continue Week /
## Game Day / Restart Game / Results / Season Summary ...).


func _uses_brand() -> bool:
	return true


func _build(col: VBoxContainer) -> void:
	GameState.daily_refresh()  # a waiting Daily Challenge reward lands before the tiles show
	var c := career.data
	var t := career.tuning
	# Everything scrolls; only the action row stays put (thumb reach).
	var list := BrandUi.scroll_list(col)
	list.add_child(_header())

	# Benched / thin ice / suspended: the first thing you see (never a surprise).
	var bb := CareerUi.bench_banner_text(c, t, c.phase == CareerManager.PHASE_WEEK_START)
	if not bb.is_empty():
		list.add_child(BrandUi.banner("warning", bb["title"], bb["body"]))
	# Running on empty (Fatigue): rest this week, or lose attribute points.
	if Fatigue.warned(c):
		list.add_child(BrandUi.banner("warning", "Running on empty", CareerUi.fatigue_text(t)))
	# Next up, and where the career is heading.
	list.add_child(_next_card())
	if c.notice != "":
		list.add_child(BrandUi.banner("info", "Update", c.notice))
		c.notice = ""
		career.save()

	list.add_child(_range_tiles())
	# Weekly practice intensity (Fatigue), before you play the week.
	if c.phase == CareerManager.PHASE_WEEK_START and career.in_season_loop():
		list.add_child(BrandUi.section("Practice this week"))
		var seg: BrandSegmented = load("res://scenes/ui/brand/segmented_toggle.tscn").instantiate()
		seg.options = PackedStringArray(Fatigue.INTENSITIES.map(func(x: String) -> String: return x.capitalize()))
		seg.selected = Fatigue.INTENSITIES.find(Fatigue.practice(c))
		seg.option_selected.connect(func(i: int) -> void: _set_practice(str(Fatigue.INTENSITIES[i])))
		list.add_child(seg)
		list.add_child(BrandUi.text(CareerUi.practice_text(c, t), "Caption"))
	if c.is_injured():
		list.add_child(BrandUi.banner("warning", "Injured", "%d week(s) left." % int(c.injury["weeks_left"])))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", Brand.SPACE_3)
	grid.add_theme_constant_override("v_separation", Brand.SPACE_3)
	list.add_child(grid)
	var bars := {}
	for g in [CareerData.LIFE, CareerData.FOOTBALL, CareerData.PERSONALITY]:
		grid.add_child(_group_card(g, bars))
	grid.add_child(_traits_panel())
	_animate_bars(bars)

	list.add_child(BrandUi.section("Career"))
	var nav := VBoxContainer.new()
	nav.add_theme_constant_override("separation", 0)
	list.add_child(nav)
	var st := CareerRecords.this_season(c)
	nav.add_child(_daily_row())
	for r in [["Skills", "%d skill points to spend" % c.skill_points, "", "trend", Screens.CAREER_SKILLS],
			["Kicking stats", "This season, career and records", "FG %d/%d" % [int(st["fg_made"]), int(st["fg_att"])],
				"football", Screens.CAREER_KICKING],
			["Recruiting", "Who's watching, offers", "", "school", Screens.CAREER_RECRUITING_BOARD],
			["Stats & traits", "Every attribute and trait", "", "star", Screens.CAREER_STATS],
			["People", "Coach, team, family and friends", "", "team", Screens.CAREER_PEOPLE]]:
		nav.add_child(_nav_row(r[0], r[1], r[2], r[3], r[4]))

	list.add_child(BrandUi.section("Recent results"))
	if c.recent_results.is_empty():
		list.add_child(BrandUi.text("No games yet.", "Caption"))
	for i in range(c.recent_results.size() - 1, -1, -1):
		list.add_child(_result_row(c.recent_results[i]))

	var main := BrandUi.button(_main_text(), _main_action, "primary", "play")
	var menu := BrandUi.button("Menu", go_back, "secondary", "home")
	col.add_child(BrandUi.button_row([menu, main]))
	main.size_flags_stretch_ratio = 2.0
	if not OS.has_feature("mobile"):
		main.grab_focus.call_deferred()


## The player card: a team-color stripe, who and when, the team and its
## record, and this season's kicking line as a stat strip.
func _header() -> Control:
	var c := career.data
	var team_col := Color.from_string(str((c.team.get("colors", []) as Array).front() if not
		(c.team.get("colors", []) as Array).is_empty() else ""), Brand.GREY)
	var card := BrandUi.card("raised", team_col)
	var when := "Offseason" if c.week == 0 else "Week %d of %d" % [mini(c.week, career.weeks_in_season()),
		career.weeks_in_season()]
	card.content.add_child(BrandUi.text("#%d  ·  %s  ·  Season %d  ·  %s  ·  %s" % [int(c.player.get("number", 0)),
		career.stage_name(), c.season, career.class_year(), when], "Eyebrow"))
	card.content.add_child(BrandUi.text(c.display_name(), "Title"))
	var team_row := HBoxContainer.new()
	team_row.add_theme_constant_override("separation", Brand.SPACE_3)
	team_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.content.add_child(team_row)
	var team_l := BrandUi.text(CareerScreen.team_name(c.team), "Subhead", Brand.GREY)
	team_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	team_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	team_row.add_child(team_l)
	var rec := BrandTheme.label(CareerRecords.record_text(c.record), "Heading")
	rec.add_theme_font_override("font", BrandTheme.font(Brand.FONT_NUMBER))
	team_row.add_child(rec)
	var st := CareerRecords.this_season(c)
	var strip: BrandStatStrip = load("res://scenes/ui/brand/stat_strip.tscn").instantiate()
	card.content.add_child(strip)
	strip.set_cells([["FG", "%d/%d" % [int(st["fg_made"]), int(st["fg_att"])]], ["FG%", CareerRecords.pct_text(st)],
		["XP", "%d/%d" % [int(st["pat_made"]), int(st["pat_att"])]],
		["Long", str(int(st["long"])) if int(st["long"]) > 0 else "-"], ["Pts", str(int(st["points"]))]])
	return card


## FG range (the key number), kickoff range and skill points.
func _range_tiles() -> HBoxContainer:
	var c := career.data
	var t := career.tuning
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_3)
	var params := Progression.game_params(c, t)
	var ko := KickRange.kickoff_range(c, t)
	row.add_child(_tile("FG range", floorf(KickRange.fg_range(c, t) + 0.001), "yd", "", true))
	row.add_child(_tile("Kickoff", floorf(ko + 0.001), "yd",
		"Touchback range" if KickRange.touchback_possible(ko, params, t) else ""))
	row.add_child(_tile("Skill pts", float(c.skill_points), "", ""))
	return row


func _tile(caption: String, value: float, unit: String, note: String, highlight := false) -> BrandStatTile:
	var tile: BrandStatTile = load("res://scenes/ui/brand/stat_tile.tscn").instantiate()
	tile.caption = caption
	tile.value = value
	tile.unit = unit
	tile.delta = note
	tile.highlight = highlight
	return tile


## A stat group: its name, then each stat as a bar.
func _group_card(group: String, bars: Dictionary) -> BrandCard:
	var card := BrandUi.card()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.content.add_theme_constant_override("separation", Brand.SPACE_3)
	card.content.add_child(BrandTheme.label(str(CareerData.GROUP_NAMES[group]), "Eyebrow", Brand.WHITE))
	for k in CareerData.GROUP_KEYS[group]:
		var b: BrandBar = load("res://scenes/ui/brand/progress_bar.tscn").instantiate()
		b.title = str(CareerData.STAT_NAMES[k]).replace("Kicking ", "")
		b.value = career.data.stat(k)
		bars[k] = b
		card.content.add_child(b)
	return card


## Bars glide from what the Hub showed last time (UI memory only).
func _animate_bars(bars: Dictionary) -> void:
	var seen: Dictionary = CareerUi.last_seen.get(_seen_key(), {})
	for k in bars:
		var b: BrandBar = bars[k]
		if seen.has(k) and not is_equal_approx(float(seen[k]), career.data.stat(k)):
			b.value = float(seen[k])
			b.animate_to.call_deferred(career.data.stat(k))
	var now := {}
	for k in bars:
		now[k] = career.data.stat(k)
	CareerUi.last_seen = {_seen_key(): now}


func _seen_key() -> String:
	return "%d|%d" % [career.data.slot, career.data.created]


## Daily Challenge: 7 days in a row pay this career the week's skill points
## ("NEW" until today's kick is tried, otherwise the day of the week).
func _daily_row() -> BrandListRow:
	var d := GameState.daily
	var w := d.tuning.week_days
	var sub := "Day %d of %d  ·  %d skill points on day %d" % [d.week_day_today(), w, d.next_payout(), w]
	if d.week_paid_today():
		sub = "Week complete: +%d skill points" % int(d.today.get("reward", 0))
	elif d.status() == "done":
		sub = "Done today  ·  day %d of %d" % [d.week_day_today(), w]
	var r := _nav_row("Daily Challenge", sub, "NEW" if d.is_new() else "Day %d/%d" % [d.week_day_today(), w],
		"calendar", Screens.DAILY)
	r.pressed.connect(func() -> void: DailyScreen.return_to = Screens.CAREER_HUB, CONNECT_ONE_SHOT)
	return r


func _nav_row(title: String, sub: String, value: String, icon: String, path: String) -> BrandListRow:
	var r: BrandListRow = load("res://scenes/ui/brand/list_row.tscn").instantiate()
	r.title = title
	r.subtitle = sub
	r.value = value
	r.icon_name = icon
	r.pressed.connect(Screens.go.bind(path))
	return r


## A result: W / L / T, the week and opponent (with the game line), the score.
func _result_row(r: Dictionary) -> BrandCard:
	var o := str(r.get("outcome", "T"))
	var card := BrandUi.card("card")
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_3)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.content.add_child(h)
	var badge := BrandUi.chip(o, {"W": "outline", "L": "red"}.get(o, "neutral"))
	badge.custom_minimum_size.x = 52
	h.add_child(badge)
	var mid := VBoxContainer.new()
	mid.add_theme_constant_override("separation", 0)
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(mid)
	var ot := CareerManager.ot_tag(r)
	mid.add_child(BrandUi.text("Wk %d  %s%s" % [int(r.get("week", 0)), r.get("opponent", ""),
		("  " + ot) if ot != "" else ""], "BodyStrong"))
	if str(r.get("line", "")) != "":
		mid.add_child(BrandUi.text(str(r.get("line", "")), "Caption"))
	var score := BrandTheme.label("%d-%d" % [int(r.get("us", 0)), int(r.get("them", 0))], "Subhead",
		Brand.RED_HOT if o == "L" else Brand.WHITE)
	score.add_theme_font_override("font", BrandTheme.font(Brand.FONT_NUMBER))
	score.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(score)
	return card


func go_back() -> void:
	career.save()
	Screens.go(Screens.CAREER)


## This week: home / away, the opponent (with a small stripe of their color)
## and how strong they are; or what's next outside the season. Then the
## career status chips.
func _next_card() -> BrandCard:
	var card := BrandUi.card("accent")
	var c := career.data
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", Brand.SPACE_2)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.content.add_child(head)
	var kicker := BrandTheme.label("", "Eyebrow")
	head.add_child(kicker)
	var big := BrandUi.text("", "Heading")
	if not career.in_season_loop():
		kicker.text = career.stage_name()
		big.text = "Decision time: see what's next."
	elif c.phase == CareerManager.PHASE_SEASON_END:
		kicker.text = "Season over"
		big.text = "Final record %d-%d" % [int(c.record["w"]), int(c.record["l"])]
	elif c.phase == CareerManager.PHASE_OFFSEASON:
		kicker.text = "Offseason"
		big.text = "Get ready for next season."
	elif career.is_bye():
		kicker.text = "This week"
		big.text = "Bye week: no game"
	else:
		var e := career.entry()
		var opp: Dictionary = e.get("opponent", {})
		var home: bool = e.get("home", true)
		kicker.text = "This week"
		head.add_child(BrandUi.chip("Home" if home else "Away", "outline"))
		var sp := Control.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		head.add_child(sp)
		head.add_child(BrandUi.chip(CareerScreen.strength_word(float(opp.get("strength", 50))), "neutral"))
		var vs := HBoxContainer.new()
		vs.add_theme_constant_override("separation", Brand.SPACE_3)
		vs.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var block := ColorRect.new()
		var oc: Array = opp.get("colors", [])
		block.color = Brand.team_accent(Color.from_string(str(oc[0]) if not oc.is_empty() else "", Brand.GREY))
		block.custom_minimum_size = Vector2(Brand.STRIPE * 2, 44)
		block.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		block.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vs.add_child(block)
		var at := BrandTheme.label("vs" if home else "at", "Subhead", Brand.GREY)
		at.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		vs.add_child(at)
		big.text = CareerScreen.team_name(opp)
		big.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vs.add_child(big)
		card.content.add_child(vs)
		card.content.add_child(_status_line())
		return card
	card.content.add_child(big)
	card.content.add_child(_status_line())
	return card


## Recruiting / draft stock / contract, depending on the stage, as chips.
func _status_line() -> HFlowContainer:
	var c := career.data
	var f := BrandUi.chip_flow()
	var t := career.tuning
	match c.stage:
		CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO:
			f.add_child(BrandUi.chip("Recruiting %d  ·  %s" % [roundi(c.recruiting_score), CareerScreen.recruit_word(c)],
				"neutral", "school"))
			f.add_child(BrandUi.chip("GPA %.2f" % c.gpa, "neutral"))
			if c.offers.size() > 0:
				f.add_child(BrandUi.chip("%d offer%s" % [c.offers.size(), "" if c.offers.size() == 1 else "s"], "red"))
		CareerData.STAGE_COLLEGE:
			f.add_child(BrandUi.chip("Draft stock %d  ·  %s" % [roundi(c.draft_score), CareerScreen.draft_word(c)],
				"neutral", "trend"))
			var bad_gpa := c.gpa < t.college_min_gpa
			f.add_child(BrandUi.chip("GPA %.2f%s" % [c.gpa, "  ineligible" if bad_gpa else ""], "red" if bad_gpa else "neutral"))
		CareerData.STAGE_PRO:
			f.add_child(BrandUi.chip("%s  ·  %d yr left" % [Progression.money(int(c.contract.get("salary", 0))),
				int(c.contract.get("years_left", 0))], "neutral", "money"))
			f.add_child(BrandUi.chip("Standing: %s" % CareerScreen.standing_word(
				c.retention_score if c.season_in_stage > 1 else 50.0, t), "outline"))
		_:
			f.add_child(BrandUi.chip(career.stage_name(), "outline"))
	f.add_child(BrandUi.chip("%s followers  ·  %s" % [Followers.short(c.followers),
		Followers.tier_name(Followers.tier(c, t))], "neutral", "team"))
	if c.savings > 0 or c.stage == CareerData.STAGE_PRO:
		f.add_child(BrandUi.chip("%s saved" % Savings.text(c.savings), "neutral", "money"))
	if Reputation.is_dismissed(c):
		f.add_child(BrandUi.chip("Dismissed at season end", "red", "warning"))
	else:
		match Reputation.state(c):
			"concerns":
				f.add_child(BrandUi.chip("Character concerns", "red", "warning"))
			"rebuilt":
				f.add_child(BrandUi.chip("Rebuilt reputation", "outline", "check"))
	return f


func _traits_panel() -> BrandCard:
	var card := BrandUi.card()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.content.add_theme_constant_override("separation", Brand.SPACE_3)
	card.content.add_child(BrandTheme.label("Traits", "Eyebrow", Brand.WHITE))
	for id in career.data.traits:
		var td := CareerContent.trait_def(str(id))
		card.content.add_child(_trait_line("star", str(td.get("name", id)), true))
	# The closest locked trait, dimmed, so there's always something to chase.
	var next := _next_trait()
	if not next.is_empty():
		card.content.add_child(_trait_line("lock", str(next["text"]), false))
	elif career.data.traits.is_empty():
		card.content.add_child(BrandUi.text("None yet. Personality stats unlock them.", "Caption"))
	return card


static func _trait_line(icon: String, text: String, unlocked: bool) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_2)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ic := BrandIcons.rect(icon, Brand.WHITE if unlocked else Brand.GREY, 32)
	ic.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	h.add_child(ic)
	var l := BrandUi.text(text, "BodyStrong" if unlocked else "Caption")
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
			if Bench.audition_due(career.data):
				return "Audition"
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
			return "Audition" if str(career.data.tryout.get("purpose", "")) == "job" else "Tryout"
		CareerManager.PHASE_DRAFT:
			return "Draft Day" if career.data.stage == CareerData.STAGE_COLLEGE else "Free Agency"
		CareerManager.PHASE_CONTRACT:
			return "Contract Review"
		CareerManager.PHASE_EPILOGUE:
			return "After the Game"
		CareerManager.PHASE_HALL:
			return "Hall of Fame Vote"
		CareerManager.PHASE_RETIRED:
			return "Career Summary"
	return "Continue"


func _set_practice(intensity: String) -> void:
	Fatigue.set_practice(career.data, intensity)
	career.save()
	UiKit.feedback(&"ui_tap")
	Screens.go(Screens.CAREER_HUB)


func _main_action() -> void:
	if career.data.phase == CareerManager.PHASE_WEEK_START:
		career.begin_week()
	go_to_current()
