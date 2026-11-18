extends CareerScreen
## Retirement / career summary: why it ended, the path you took, career kicking
## totals, every season, and your traits. Final: the slot stays as a record.


func _build(col: VBoxContainer) -> void:
	var c := career.data
	col.add_child(CareerUi.centered("CAREER OVER", 56, UiKit.ACCENT))
	col.add_child(CareerUi.centered("%s  #%d" % [c.display_name(), int(c.player.get("number", 0))], 34))
	col.add_child(CareerUi.centered(str(c.retirement.get("text", "")), 26, UiKit.MUTED))
	var list := UiKit.scroll_list(col)
	var tot := c.career_totals
	list.add_child(UiKit.section("CAREER TOTALS"))
	list.add_child(UiKit.stat_row("Field goals", "%d / %d  (%d%%)" % [int(tot["fg_made"]), int(tot["fg_att"]),
		roundi(Progression.fg_pct(tot) * 100.0)], UiKit.ACCENT))
	list.add_child(UiKit.stat_row("Extra points", "%d / %d" % [int(tot["pat_made"]), int(tot["pat_att"])]))
	list.add_child(UiKit.stat_row("Longest field goal", ("%d yd" % int(tot["long"])) if int(tot["long"]) > 0 else "-"))
	list.add_child(UiKit.stat_row("Game winners", str(int(tot["game_winners"]))))
	list.add_child(UiKit.stat_row("Points", str(int(tot["points"]))))
	list.add_child(UiKit.stat_row("Games", str(int(tot["games"]))))
	var earned := 0
	for h in c.history:
		if h.get("stage", "") == CareerData.STAGE_PRO:
			earned += 1
	if earned > 0:
		list.add_child(UiKit.stat_row("Pro seasons", str(earned)))
	list.add_child(UiKit.section("THE ROAD"))
	for r in c.route:
		list.add_child(UiKit.label("Age %d:  %s" % [int(r.get("age", 0)), r.get("text", "")], 24))
	list.add_child(UiKit.section("SEASON BY SEASON"))
	for h in c.history:
		var s: Dictionary = h.get("stats", {})
		var r: Dictionary = h.get("record", {})
		list.add_child(UiKit.stat_row("%s  %s" % [_stage_short(str(h.get("stage", ""))), h.get("team", "")],
			"%d-%d  FG %d/%d" % [int(r.get("w", 0)), int(r.get("l", 0)), int(s.get("fg_made", 0)),
			int(s.get("fg_att", 0))]))
	list.add_child(UiKit.section("TRAITS"))
	if c.traits.is_empty():
		list.add_child(UiKit.label("None", 24, UiKit.MUTED))
	for id in c.traits:
		list.add_child(UiKit.label(str(CareerContent.trait_def(str(id)).get("name", id)), 26, UiKit.ACCENT))
	col.add_child(UiKit.button("Career Menu", Screens.go.bind(Screens.CAREER)))


func go_back() -> void:
	Screens.go(Screens.CAREER)


static func _stage_short(stage: String) -> String:
	return {"high_school": "HS", "juco": "JC", "college": "COL", "pro": "PRO"}.get(stage, stage)
