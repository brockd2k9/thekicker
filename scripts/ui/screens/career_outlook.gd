extends CareerScreen
## Game Day Outlook: the matchup, the weather, and how you're feeling. The
## "feeling" lines come straight from KickProfile.build() (the same numbers the
## kick uses), and "Your leg today" turns the profile into plain words.

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

	var list := UiKit.scroll_list(col)
	list.add_child(UiKit.section("How you're feeling"))
	if p.outlook.is_empty():
		list.add_child(UiKit.label("Normal. Nothing helping, nothing hurting.", 28, UiKit.MUTED))
	for line in p.outlook:
		list.add_child(CareerUi.outlook_line(line, 26))
	list.add_child(UiKit.section("Your leg today"))
	list.add_child(UiKit.stat_row("Range", "about %d yd" % p.max_range_yards(kt), UiKit.ACCENT, "power"))
	var words: Dictionary = CareerContent.game_day().get("outlook", {})
	for key in [["aim", "Aim", "accuracy"], ["pressure", "Under pressure", "resilience"], ["wind", "In the wind", "wind"]]:
		var w: Dictionary = words.get(key[0], {})
		list.add_child(UiKit.stat_row(key[1], _word(p.value(str(w.get("field", ""))),
			w.get("cuts", []), w.get("words", ["?"])), Color(0, 0, 0, 0), key[2]))
	list.add_child(UiKit.label(str(words.get("tip", "")), 22, UiKit.MUTED))
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
	if mph < 2.0:
		return "Calm"
	return "%d mph crosswind%s" % [roundi(mph), ", gusty" if w.get("gusty", false) else ""]


## Buckets a value: below cuts[0] -> words[0], ... above the last cut -> last word.
static func _word(v: float, cuts: Array, words: Array) -> String:
	for i in cuts.size():
		if v < float(cuts[i]):
			return str(words[i])
	return str(words[words.size() - 1])
