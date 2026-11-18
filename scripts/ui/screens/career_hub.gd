extends CareerScreen
## Career Hub: where every week starts and every quit comes back to.
## Week, record, next opponent, the four stat groups, traits, recent results,
## and one big button that does the next thing (Play Week / Continue Week /
## Game Day / Restart Game / Results / Season Summary ...).


func _build(col: VBoxContainer) -> void:
	var c := career.data

	# Header: who and when.
	var head := PanelContainer.new()
	col.add_child(head)
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 4)
	head.add_child(hv)
	var when := "OFFSEASON" if c.week == 0 else "WEEK %d of %d" % [mini(c.week, career.weeks_in_season()),
		career.weeks_in_season()]
	hv.add_child(UiKit.label("SEASON %d  -  %s  -  %s" % [c.season, career.class_year().to_upper(), when],
		24, UiKit.MUTED))
	var team_l := UiKit.label("%s  #%d" % [c.display_name(), int(c.player.get("number", 0))], 40, UiKit.ACCENT)
	hv.add_child(team_l)
	hv.add_child(UiKit.label("%s   %d-%d%s" % [CareerScreen.team_name(c.team), int(c.record["w"]),
		int(c.record["l"]), ("-%d" % int(c.record["t"])) if int(c.record["t"]) > 0 else ""], 30))

	# Next up.
	col.add_child(_next_card())
	if c.notice != "":
		col.add_child(UiKit.label(c.notice, 26, Color(1.0, 0.85, 0.5)))
		c.notice = ""
		career.save()

	var list := UiKit.scroll_list(col)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	list.add_child(grid)
	for g in [CareerData.LIFE, CareerData.FOOTBALL, CareerData.PERSONALITY]:
		grid.add_child(CareerUi.group_panel(c, g, true))
	grid.add_child(_traits_panel())
	list.add_child(UiKit.button("Stats & Traits", Screens.go.bind(Screens.CAREER_STATS)))

	if c.is_injured():
		list.add_child(UiKit.stat_row("Injury", "%d week(s) left" % int(c.injury["weeks_left"]), UiKit.BAD))
	list.add_child(UiKit.section("RECENT RESULTS"))
	if c.recent_results.is_empty():
		list.add_child(UiKit.label("No games yet.", 26, UiKit.MUTED))
	for i in range(c.recent_results.size() - 1, -1, -1):
		var r: Dictionary = c.recent_results[i]
		var o := str(r.get("outcome", "T"))
		list.add_child(UiKit.stat_row("Wk %d  %s  %s" % [int(r.get("week", 0)), o, r.get("opponent", "")],
			"%d-%d" % [int(r.get("us", 0)), int(r.get("them", 0))],
			UiKit.GOOD if o == "W" else (UiKit.BAD if o == "L" else Color.WHITE)))
		var kl := UiKit.label("     " + str(r.get("line", "")), 22, UiKit.MUTED)
		list.add_child(kl)

	var main := UiKit.button(_main_text(), _main_action, UiKit.ACCENT.darkened(0.45))
	col.add_child(CareerUi.button_row([UiKit.button("Menu", go_back), main]))
	main.size_flags_stretch_ratio = 2.0
	if not OS.has_feature("mobile"):
		main.grab_focus.call_deferred()


func go_back() -> void:
	career.save()
	Screens.go(Screens.CAREER)


func _next_card() -> PanelContainer:
	var p := PanelContainer.new()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	p.add_child(v)
	var c := career.data
	if c.phase in [CareerManager.PHASE_SEASON_END, CareerManager.PHASE_STAGE_END]:
		v.add_child(UiKit.label("SEASON OVER", 24, UiKit.MUTED))
		v.add_child(UiKit.label("Final record %d-%d" % [int(c.record["w"]), int(c.record["l"])], 32))
		return p
	if c.phase == CareerManager.PHASE_OFFSEASON:
		v.add_child(UiKit.label("OFFSEASON", 24, UiKit.MUTED))
		v.add_child(UiKit.label("Get ready for next season.", 30))
		return p
	if career.is_bye():
		v.add_child(UiKit.label("THIS WEEK", 24, UiKit.MUTED))
		v.add_child(UiKit.label("BYE WEEK: no game", 32))
		return p
	var e := career.entry()
	var opp: Dictionary = e.get("opponent", {})
	v.add_child(UiKit.label("THIS WEEK  -  %s" % ("HOME" if e.get("home", true) else "AWAY"), 24, UiKit.MUTED))
	v.add_child(UiKit.label("%s %s  %s" % ["vs" if e.get("home", true) else "at",
		CareerScreen.team_name(opp), "(%s)" % CareerScreen.strength_word(float(opp.get("strength", 50)))], 30))
	return p


func _traits_panel() -> PanelContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	p.add_child(v)
	v.add_child(UiKit.label("TRAITS", 22, UiKit.MUTED))
	if career.data.traits.is_empty():
		v.add_child(UiKit.label("None yet. Personality stats unlock them.", 22, UiKit.MUTED))
	for id in career.data.traits:
		var t := CareerContent.trait_def(str(id))
		v.add_child(UiKit.label(str(t.get("name", id)), 24, UiKit.ACCENT))
	return p


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
		CareerManager.PHASE_STAGE_END:
			return "Senior Year"
	return "Continue"


func _main_action() -> void:
	if career.data.phase == CareerManager.PHASE_WEEK_START:
		career.begin_week()
	go_to_current()
