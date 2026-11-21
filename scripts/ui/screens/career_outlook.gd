extends CareerScreen
## Game Day Outlook: the matchup, the weather, and how you're feeling. The
## "feeling" lines come straight from KickProfile.build() (the same numbers the
## kick uses, e.g. "Rested: +2 yds"), and "Your leg today" turns the profile into
## plain words: today's field goal and kickoff range and the coach's longest call
## (shorter, with the reason, while he doubts you).

const KICK_TUNING := "res://tuning/kick_tuning.tres"


func _build(col: VBoxContainer) -> void:
	var c := career.data
	var e := career.entry()
	var opp: Dictionary = e.get("opponent", {})
	var p := career.profile()
	var kt: KickTuning = load(KICK_TUNING)
	var home: bool = e.get("home", true)

	col.add_child(UiKit.title_block("Game Day", "Week %d  ·  %s" % [c.week, "Home" if home else "Away"]))
	var board := CareerUi.scoreboard(c.team, opp, "%d-%d" % [int(c.record["w"]), int(c.record["l"])],
		CareerScreen.strength_word(float(opp.get("strength", 50))).to_upper(), "VS" if home else "AT",
		"KICKOFF", 52)
	col.add_child(board["root"])
	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", 8)
	chips.add_theme_constant_override("v_separation", 6)
	chips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chips.add_child(UiKit.chip(_weather_text(e.get("weather", {})), Color(0.6, 0.82, 1.0), false, "wind", 24))
	chips.add_child(UiKit.chip("%s %s" % ["vs" if home else "at", CareerScreen.team_name(opp)], UiKit.MUTED,
		false, "home" if home else "next", 24))
	col.add_child(chips)

	var bb := CareerUi.bench_banner(c, career.tuning, false)
	if bb != null:
		col.add_child(bb)
	var fb := CareerUi.fatigue_banner(c, career.tuning)
	if fb != null:
		col.add_child(fb)
	var list := UiKit.scroll_list(col)
	list.add_child(UiKit.section("How you're feeling"))
	if p.outlook.is_empty():
		list.add_child(UiKit.label("Normal. Nothing helping, nothing hurting.", 28, UiKit.MUTED))
	for line in p.outlook:
		list.add_child(CareerUi.outlook_line(line, 26))
	if not c.coach_doubt.is_empty():
		list.add_child(CareerUi.outlook_line({"label": "%s has lost faith" % Relationships.name_of(c, "coach"),
			"detail": "fewer, shorter field goals (%s)" % str(c.coach_doubt.get("reason", "")), "good": false}, 26))
	var fans := Followers.fan_pressure(c, career.tuning)
	if fans > 0.0:
		list.add_child(CareerUi.outlook_line({"label": "Fans are watching",
			"detail": "%s followers: +pressure in a close 4th quarter" % Followers.short(c.followers), "good": false}, 26))
	list.add_child(UiKit.section("Your leg today"))
	var fg := p.max_range_yards(kt)
	var base := floori(p.fg_range_base + 0.001)
	var fg_text := "%d yd" % fg if fg == base else "%d yd  (%+d today)" % [fg, fg - base]
	list.add_child(UiKit.stat_row("Field goal range", fg_text, UiKit.ACCENT, "range"))
	var params := Progression.game_params(c, career.tuning)
	list.add_child(UiKit.stat_row("Kickoff range", "%d yd%s" % [floori(p.kickoff_range + 0.001),
		"  (touchback)" if KickRange.touchback_possible(p.kickoff_range, params, career.tuning) else ""],
		Color(0, 0, 0, 0), "power"))
	if Bench.this_week(c):
		list.add_child(UiKit.stat_row("Field goals", "%s kicks them" % Bench.backup_name(c), UiKit.BAD, "whistle"))
	else:
		var lim := mini(KickTrust.coach_limit(c, p, career.tuning), int(params.get("fg_max", 60)))
		list.add_child(UiKit.stat_row("Coach calls field goals up to", "%d yd" % lim,
			UiKit.BAD if not c.coach_doubt.is_empty() else Color(0, 0, 0, 0), "whistle"))
	var words: Dictionary = CareerContent.game_day().get("outlook", {})
	for key in [["aim", "Aim", "accuracy"], ["pressure", "Under pressure", "resilience"], ["wind", "In the wind", "wind"]]:
		var w: Dictionary = words.get(key[0], {})
		list.add_child(UiKit.stat_row(key[1], _word(p.value(str(w.get("field", ""))),
			w.get("cuts", []), w.get("words", ["?"])), Color(0, 0, 0, 0), key[2]))
	list.add_child(UiKit.label(str(words.get("tip", "")), 22, UiKit.MUTED))
	# This stage's overtime rule (a tie after four quarters).
	list.add_child(UiKit.label(CareerManager.ot_rule_text(str(params.get("ot", "hs")), career.tuning), 22, UiKit.MUTED))
	UiKit.stagger(list, 0.04)

	var play := UiKit.primary("Play Game", func() -> void:
		career.start_game()
		go_to_current(), "play")
	col.add_child(CareerUi.button_row([UiKit.button("Hub", go_back, UiKit.SECONDARY, "home"), play]))
	play.size_flags_stretch_ratio = 2.0
	if not OS.has_feature("mobile"):
		play.grab_focus.call_deferred()


static func _weather_text(w: Dictionary) -> String:
	var mph := absf(float(w.get("wind", 0.0)))
	var temp: String = {"cold": "Cold, ", "snow": "Snow, "}.get(str(w.get("temp", "")), "")
	if mph < 2.0:
		return temp + ("calm" if temp != "" else "Calm")
	return "%s%d mph crosswind%s" % [temp, roundi(mph), ", gusty" if w.get("gusty", false) else ""]


## Buckets a value: below cuts[0] -> words[0], ... above the last cut -> last word.
static func _word(v: float, cuts: Array, words: Array) -> String:
	for i in cuts.size():
		if v < float(cuts[i]):
			return str(words[i])
	return str(words[words.size() - 1])
