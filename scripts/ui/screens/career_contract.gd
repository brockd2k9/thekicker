extends CareerScreen
## Contract review after every pro season: your standing (retention) and what
## it means. Under contract -> next season; contract up -> re-sign offer (or
## not); low standing -> released. Retire is always available.


func _build(col: VBoxContainer) -> void:
	var c := career.data
	var k := c.contract
	var status := str(k.get("status", "continue"))
	col.add_child(UiKit.title_block("CONTRACT REVIEW"))
	col.add_child(UiKit.label("%s  -  Age %d" % [k.get("team_name", ""), c.age], 28, UiKit.MUTED))
	var list := UiKit.scroll_list(col)
	var t := career.tuning
	list.add_child(UiKit.stat_row("Standing", "%d  -  %s" % [roundi(c.retention_score),
		CareerScreen.standing_word(c.retention_score, t)], CareerUi.stat_color(c.retention_score)))
	var fgp := Progression.fg_pct(c.season_stats)
	list.add_child(UiKit.stat_row("Field goals", "%d / %d  (%d%%)" % [int(c.season_stats["fg_made"]),
		int(c.season_stats["fg_att"]), roundi(fgp * 100.0)]))
	if c.age > 32:
		list.add_child(UiKit.label("Age is starting to count against you. Hard limit: %d." % t.pro_age_cap, 24, UiKit.MUTED))
	var main: Button
	match status:
		"continue":
			list.add_child(UiKit.stat_row("Contract", "%d year%s left, %s" % [int(k["years_left"]),
				"" if int(k["years_left"]) == 1 else "s", Progression.money(int(k.get("salary", 0)))]))
			list.add_child(UiKit.label("You're under contract. Release risk below %d standing." % roundi(t.release_below),
				24, UiKit.MUTED))
			main = UiKit.button("Next Season", _continue, UiKit.PRIMARY)
		"resign":
			var off: Dictionary = k.get("offer", {})
			list.add_child(UiKit.label("Your contract is up, and the team wants you back.", 30, UiKit.GOOD))
			list.add_child(UiKit.stat_row("Offer", "%d years, %s / season" % [int(off.get("years", 1)),
				Progression.money(int(off.get("salary", 0)))], UiKit.ACCENT))
			main = UiKit.button("Re-sign", _continue, UiKit.PRIMARY)
		"not_resigned":
			list.add_child(UiKit.label("Your contract is up and the team is moving on.", 30, UiKit.BAD))
			main = UiKit.button("Free Agency", _continue)
		"released":
			list.add_child(UiKit.label("RELEASED. %s" % ("You were dismissed from the team." if k.get("dismissed", false)
				else "Your standing fell below %d." % roundi(t.release_below)), 32, UiKit.BAD))
			main = UiKit.button("Free Agency", _continue)
	list.add_child(UiKit.label("You can retire after any pro season.", 22, UiKit.MUTED))
	col.add_child(CareerUi.button_row([UiKit.button("Retire", _retire, UiKit.DANGER), main]))


func _continue() -> void:
	career.contract_continue()
	go_to_current()


func _retire() -> void:
	UiKit.confirm(self, "RETIRE?", "Your career ends here and you'll see your career summary.", "Retire",
		func() -> void:
			career.retire("chose")
			go_to_current())
