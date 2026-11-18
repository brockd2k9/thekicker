extends CareerScreen
## Retirement / career summary: why it ended, the path you took, career kicking
## totals, every season, and your traits. Final: the slot stays as a record.


func _build(col: VBoxContainer) -> void:
	var c := career.data
	col.add_child(UiKit.title_block("Career Over", "Final whistle"))
	var hero := UiKit.card(UiKit.team_color(1), 2)
	var hv: VBoxContainer = hero[1]
	(hero[0] as PanelContainer).add_theme_stylebox_override("panel",
		UiKit.panel_box(UiKit.team_color(1), UiKit.team_color(0).darkened(0.4)))
	var name_l := UiKit.label("%s  #%d" % [c.display_name().to_upper(), int(c.player.get("number", 0))], 44,
		Color.WHITE, UiTokens.FONT_DISPLAY)
	hv.add_child(name_l)
	hv.add_child(UiKit.label(str(c.retirement.get("text", "")), 26, Color(1, 1, 1, 0.8)))
	col.add_child(hero[0])
	var tot := c.career_totals
	var tiles := HBoxContainer.new()
	tiles.add_theme_constant_override("separation", 10)
	tiles.add_child(UiKit.stat_tile("%d%%" % roundi(Progression.fg_pct(tot) * 100.0), "FG pct"))
	tiles.add_child(UiKit.stat_tile(("%d" % int(tot["long"])) if int(tot["long"]) > 0 else "-", "Long (yd)"))
	tiles.add_child(UiKit.stat_tile(str(int(tot["points"])), "Points"))
	tiles.add_child(UiKit.stat_tile(str(int(tot["game_winners"])), "Winners", UiKit.GOOD))
	col.add_child(tiles)
	UiKit.stagger(tiles, 0.08)
	var list := UiKit.scroll_list(col)
	list.add_child(UiKit.section("Career totals"))
	list.add_child(UiKit.stat_row("Field goals", "%d / %d  (%d%%)" % [int(tot["fg_made"]), int(tot["fg_att"]),
		roundi(Progression.fg_pct(tot) * 100.0)], UiKit.ACCENT, "accuracy"))
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
	list.add_child(UiKit.section("The road"))
	for r in c.route:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 12)
		var age := UiKit.chip("AGE %d" % int(r.get("age", 0)), UiKit.ACCENT, true, "", 22)
		age.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		h.add_child(age)
		var t := UiKit.label(str(r.get("text", "")), 24)
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(t)
		list.add_child(h)
	list.add_child(UiKit.section("Season by season"))
	for h in c.history:
		var s: Dictionary = h.get("stats", {})
		var r: Dictionary = h.get("record", {})
		list.add_child(UiKit.stat_row("%s  %s" % [_stage_short(str(h.get("stage", ""))), h.get("team", "")],
			"%d-%d  FG %d/%d" % [int(r.get("w", 0)), int(r.get("l", 0)), int(s.get("fg_made", 0)),
			int(s.get("fg_att", 0))]))
	list.add_child(UiKit.section("Traits"))
	if c.traits.is_empty():
		list.add_child(UiKit.label("None", 24, UiKit.MUTED))
	var tf := HFlowContainer.new()
	tf.add_theme_constant_override("h_separation", 8)
	tf.add_theme_constant_override("v_separation", 8)
	for id in c.traits:
		tf.add_child(UiKit.chip(str(CareerContent.trait_def(str(id)).get("name", id)), UiKit.ACCENT, false,
			UiIcons.for_trait(str(id)), 26))
	list.add_child(tf)
	col.add_child(UiKit.primary("Career Menu", Screens.go.bind(Screens.CAREER), "career"))


func go_back() -> void:
	Screens.go(Screens.CAREER)


static func _stage_short(stage: String) -> String:
	return {"high_school": "HS", "juco": "JC", "college": "COL", "pro": "PRO"}.get(stage, stage)
