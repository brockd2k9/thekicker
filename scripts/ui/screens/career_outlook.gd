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

	var match_p := PanelContainer.new()
	col.add_child(match_p)
	var mv := VBoxContainer.new()
	mv.add_theme_constant_override("separation", 4)
	match_p.add_child(mv)
	mv.add_child(UiKit.label("WEEK %d  -  %s" % [c.week, "HOME" if e.get("home", true) else "AWAY"], 24,
		UiKit.MUTED))
	mv.add_child(UiKit.label("%s  %s" % [CareerScreen.team_name(c.team), "%d-%d" % [int(c.record["w"]),
		int(c.record["l"])]], 30))
	mv.add_child(UiKit.label("%s %s  (%s)" % ["vs" if e.get("home", true) else "at",
		CareerScreen.team_name(opp), CareerScreen.strength_word(float(opp.get("strength", 50)))], 30))
	mv.add_child(UiKit.label(_weather_text(e.get("weather", {})), 26, Color(0.75, 0.88, 1.0)))

	var list := UiKit.scroll_list(col)
	list.add_child(UiKit.section("HOW YOU'RE FEELING"))
	if p.outlook.is_empty():
		list.add_child(UiKit.label("Normal. Nothing helping, nothing hurting.", 28, UiKit.MUTED))
	for line in p.outlook:
		list.add_child(CareerUi.outlook_line(line, 30))
	list.add_child(UiKit.section("YOUR LEG TODAY"))
	list.add_child(UiKit.stat_row("Range", "about %d yd" % p.max_range_yards(kt)))
	var words: Dictionary = CareerContent.game_day().get("outlook", {})
	for key in [["aim", "Aim"], ["pressure", "Under pressure"], ["wind", "In the wind"]]:
		var w: Dictionary = words.get(key[0], {})
		list.add_child(UiKit.stat_row(key[1], _word(p.value(str(w.get("field", ""))),
			w.get("cuts", []), w.get("words", ["?"]))))
	list.add_child(UiKit.label(str(words.get("tip", "")), 22, UiKit.MUTED))

	var play := UiKit.button("Play Game", func() -> void:
		career.start_game()
		go_to_current(), UiKit.ACCENT.darkened(0.45))
	col.add_child(CareerUi.button_row([UiKit.button("Hub", go_back), play]))
	play.size_flags_stretch_ratio = 2.0
	if not OS.has_feature("mobile"):
		play.grab_focus.call_deferred()


static func _weather_text(w: Dictionary) -> String:
	var mph := absf(float(w.get("wind", 0.0)))
	if mph < 2.0:
		return "Weather: calm"
	return "Weather: %d mph crosswind%s" % [roundi(mph), ", gusty" if w.get("gusty", false) else ""]


## Buckets a value: below cuts[0] -> words[0], ... above the last cut -> last word.
static func _word(v: float, cuts: Array, words: Array) -> String:
	for i in cuts.size():
		if v < float(cuts[i]):
			return str(words[i])
	return str(words[words.size() - 1])
