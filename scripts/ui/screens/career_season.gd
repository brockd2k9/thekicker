extends CareerScreen
## End of a season: record and kicking line. Continue -> the offseason, or,
## after senior year, the "Senior year complete" screen (a placeholder until
## recruiting arrives in Stage 5) with the whole high school career.


func _build(col: VBoxContainer) -> void:
	var c := career.data
	if c.phase == CareerManager.PHASE_STAGE_END:
		_senior_year(col)
		return
	col.add_child(CareerUi.centered("SEASON %d COMPLETE" % c.season, 52, UiKit.ACCENT))
	col.add_child(CareerUi.centered("%s year at %s" % [career.class_year(), CareerScreen.team_name(c.team)],
		28, UiKit.MUTED))
	var list := UiKit.scroll_list(col)
	list.add_child(UiKit.stat_row("Record", "%d-%d%s" % [int(c.record["w"]), int(c.record["l"]),
		("-%d" % int(c.record["t"])) if int(c.record["t"]) > 0 else ""], UiKit.ACCENT))
	_stat_rows(list, c.season_stats)
	var last := c.season_in_stage >= career.tuning.high_school_seasons
	var b := UiKit.button("Finish High School" if last else "Start Offseason", func() -> void:
		career.end_season()
		go_to_current(), UiKit.ACCENT.darkened(0.45))
	col.add_child(b)
	if not OS.has_feature("mobile"):
		b.grab_focus.call_deferred()


func _senior_year(col: VBoxContainer) -> void:
	var c := career.data
	col.add_child(CareerUi.centered("SENIOR YEAR COMPLETE", 50, UiKit.ACCENT))
	col.add_child(CareerUi.centered("%s  -  %s" % [c.display_name(), CareerScreen.team_name(c.team)], 28))
	var list := UiKit.scroll_list(col)
	list.add_child(UiKit.label("College recruiting is coming in a future update. Your career is saved "
		+ "right here, ready for it.", 26, UiKit.MUTED))
	list.add_child(UiKit.section("HIGH SCHOOL CAREER"))
	for h in c.history:
		var r: Dictionary = h.get("record", {})
		var s: Dictionary = h.get("stats", {})
		list.add_child(UiKit.stat_row("%s (Season %d)" % [h.get("year", ""), int(h.get("season", 0))],
			"%d-%d   FG %d/%d" % [int(r.get("w", 0)), int(r.get("l", 0)), int(s.get("fg_made", 0)),
			int(s.get("fg_att", 0))]))
	list.add_child(UiKit.section("CAREER TOTALS"))
	_stat_rows(list, c.career_totals)
	col.add_child(UiKit.button("Career Menu", Screens.go.bind(Screens.CAREER)))


static func _stat_rows(list: VBoxContainer, s: Dictionary) -> void:
	list.add_child(UiKit.stat_row("Field goals", "%d / %d" % [int(s.get("fg_made", 0)), int(s.get("fg_att", 0))]))
	list.add_child(UiKit.stat_row("Extra points", "%d / %d" % [int(s.get("pat_made", 0)), int(s.get("pat_att", 0))]))
	list.add_child(UiKit.stat_row("Longest field goal",
		("%d yd" % int(s.get("long", 0))) if int(s.get("long", 0)) > 0 else "-"))
	list.add_child(UiKit.stat_row("Game winners", str(int(s.get("game_winners", 0)))))
	list.add_child(UiKit.stat_row("Points", str(int(s.get("points", 0)))))
