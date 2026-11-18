extends MenuScreen
## My Stats. Session = since the app was opened; the rest is all-time (saved).


func _build(col: VBoxContainer) -> void:
	var list := UiKit.scroll_list(col)
	var s := GameState.stats

	list.add_child(UiKit.section("THIS SESSION"))
	list.add_child(UiKit.stat_row("Session Accuracy",
		_accuracy(GameState.makes, GameState.attempts)))

	list.add_child(UiKit.section("ALL TIME"))
	list.add_child(UiKit.stat_row("All-Time Accuracy", _accuracy(s.makes, s.attempts)))
	list.add_child(UiKit.stat_row("Longest Kick Streak", str(s.longest_make_streak), UiKit.GOOD))
	list.add_child(UiKit.stat_row("Longest Miss Streak", str(s.longest_miss_streak), UiKit.BAD))
	list.add_child(UiKit.stat_row("Longest Field Goal",
		("%d yd" % s.longest_make_yards) if s.longest_make_yards > 0 else "-", UiKit.ACCENT))
	list.add_child(UiKit.stat_row("Current Streak", _current_streak(s)))

	list.add_child(UiKit.section("MISSES"))
	list.add_child(UiKit.stat_row("Wide Left", str(s.misses_by_type.get("wide_left", 0))))
	list.add_child(UiKit.stat_row("Wide Right", str(s.misses_by_type.get("wide_right", 0))))
	list.add_child(UiKit.stat_row("Short", str(s.misses_by_type.get("short", 0))))
	list.add_child(UiKit.stat_row("Blocked", str(s.misses_by_type.get("blocked", 0))))

	list.add_child(UiKit.section("CHALLENGE"))
	list.add_child(UiKit.stat_row("Best Run", "%d makes" % s.challenge_best_makes))
	list.add_child(UiKit.stat_row("Runs Played", str(s.challenge_runs)))

	list.add_child(UiKit.section("CAREER"))
	list.add_child(UiKit.stat_row("Careers Started", str(s.careers_started)))
	list.add_child(UiKit.stat_row("Careers Completed", str(s.careers_completed)))
	list.add_child(UiKit.stat_row("Best Career", s.best_career_text if s.best_career_text != "" else "-",
		UiKit.ACCENT))
	list.add_child(UiKit.stat_row("Longest Career",
		("%d season%s" % [s.longest_career_seasons, "" if s.longest_career_seasons == 1 else "s"])
		if s.longest_career_seasons > 0 else "-"))
	list.add_child(UiKit.stat_row("Career Kicks", _accuracy(s.career_makes, s.career_attempts)))

	add_back_button(col)


static func _accuracy(made: int, att: int) -> String:
	if att == 0:
		return "-"
	return "%d / %d  (%d%%)" % [made, att, roundi(100.0 * made / att)]


static func _current_streak(s: KickStats) -> String:
	if s.current_make_streak > 0:
		return "%d made" % s.current_make_streak
	if s.current_miss_streak > 0:
		return "%d missed" % s.current_miss_streak
	return "-"
