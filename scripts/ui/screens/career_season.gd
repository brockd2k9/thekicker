extends CareerScreen
## End of a season: record and kicking line, skill points, and (from age 30)
## what aging is about to take unless preserved. Continue -> the stage's next
## step (recruiting update, offseason, draft day or contract review).


func _build(col: VBoxContainer) -> void:
	var c := career.data
	col.add_child(UiKit.title_block("SEASON %d COMPLETE" % c.season))
	col.add_child(UiKit.label("%s  -  %s" % [career.class_year(), CareerScreen.team_name(c.team)],
		28, UiKit.MUTED))
	var list := UiKit.scroll_list(col)
	list.add_child(UiKit.stat_row("Record", "%d-%d%s" % [int(c.record["w"]), int(c.record["l"]),
		("-%d" % int(c.record["t"])) if int(c.record["t"]) > 0 else ""], UiKit.ACCENT))
	_stat_rows(list, c.season_stats)
	if Progression.is_poor_season(c, career.tuning):
		list.add_child(UiKit.label("A rough season: field goal percentage under %d%%. Another one or two like it "
			% roundi(career.tuning.poor_fg_pct * 100.0) + "and your options start to dry up.", 24, UiKit.BAD))
	_aging_rows(list)
	var b := UiKit.button(_next_text(), func() -> void:
		career.end_season()
		go_to_current(), UiKit.PRIMARY)
	col.add_child(b)
	if not OS.has_feature("mobile"):
		b.grab_focus.call_deferred()


func _next_text() -> String:
	match career.data.stage:
		CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO:
			return "Recruiting Update"
		CareerData.STAGE_COLLEGE:
			return "Draft Day" if career.data.season_in_stage >= career.tuning.college_seasons else "Start Offseason"
		CareerData.STAGE_PRO:
			return "Contract Review"
	return "Continue"


static func _stat_rows(list: VBoxContainer, s: Dictionary) -> void:
	list.add_child(UiKit.stat_row("Field goals", "%d / %d" % [int(s.get("fg_made", 0)), int(s.get("fg_att", 0))]))
	list.add_child(UiKit.stat_row("Extra points", "%d / %d" % [int(s.get("pat_made", 0)), int(s.get("pat_att", 0))]))
	list.add_child(UiKit.stat_row("Longest field goal",
		("%d yd" % int(s.get("long", 0))) if int(s.get("long", 0)) > 0 else "-"))
	list.add_child(UiKit.stat_row("Game winners", str(int(s.get("game_winners", 0)))))
	list.add_child(UiKit.stat_row("Points", str(int(s.get("points", 0)))))



## From age 30: each attribute's decline when you continue (or Preserved).
func _aging_rows(list: VBoxContainer) -> void:
	var c := career.data
	var t := career.tuning
	list.add_child(UiKit.stat_row("Skill points this season", "%d earned  ·  %d to spend" % [c.sp_season, c.skill_points],
		UiKit.ACCENT, "skill"))
	if not Aging.active(c, t):
		return
	list.add_child(UiKit.section("AGING (AGE %d)" % c.age, UiKit.WARN))
	var any := false
	for s in Aging.STATS:
		var name := str(CareerData.STAT_NAMES[s]).replace("Kicking ", "")
		if Aging.maintained(c, s):
			list.add_child(UiKit.stat_row(name, "Preserved", UiKit.GOOD, "check"))
		elif Aging.decline(c, s, t) > 0.0:
			any = true
			list.add_child(UiKit.stat_row(name, "-%.1f when you continue" % Aging.decline(c, s, t), UiKit.BAD, s))
	if any:
		list.add_child(UiKit.button("Preserve in Skills", Screens.go.bind(Screens.CAREER_SKILLS), UiKit.SECONDARY, "skill"))
