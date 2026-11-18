extends CareerScreen
## Draft Day (after the last college season) and Free Agency (after a cut or a
## release): drafted -> sign the rookie deal; undrafted -> training camp
## tryout or open tryout; free agency -> another tryout. Retiring is always an
## option when you don't have a contract.


func _build(col: VBoxContainer) -> void:
	var c := career.data
	var d := c.draft_result
	var kind := str(d.get("kind", ""))
	var list: VBoxContainer
	if kind == "free_agency":
		col.add_child(CareerUi.centered("FREE AGENCY", 54, UiKit.ACCENT))
		col.add_child(CareerUi.centered("Age %d  -  %s" % [c.age, d.get("why", "")], 26, UiKit.MUTED))
		list = UiKit.scroll_list(col)
		list.add_child(UiKit.label("The %s will give you a look at an open tryout." % d.get("team_name", ""), 30))
		_tryout_info(list, "free_agent")
		_poor_note(list)
		col.add_child(CareerUi.button_row([UiKit.button("Retire", _retire, UiKit.DANGER),
			UiKit.button("Try Out", _tryout, UiKit.ACCENT.darkened(0.45))]))
		return
	col.add_child(CareerUi.centered("DRAFT DAY", 58, UiKit.ACCENT))
	col.add_child(CareerUi.centered("%s  -  Draft stock %d" % [CareerScreen.team_name(c.team), roundi(c.draft_score)],
		26, UiKit.MUTED))
	list = UiKit.scroll_list(col)
	var team := CareerContent.team_by_id(str(d.get("team", "")))
	match kind:
		"drafted":
			list.add_child(_stripe_panel(team, "ROUND %d" % int(d["round"]),
				"The %s select %s!" % [team.get("name", ""), c.display_name()]))
			var k := Progression.contract(str(d["team"]), "drafted", int(d["round"]))
			list.add_child(UiKit.stat_row("Rookie contract", "%d years" % int(k["years_left"]), UiKit.ACCENT))
			list.add_child(UiKit.stat_row("Salary", "%s / season" % Progression.money(int(k["salary"]))))
			col.add_child(UiKit.button("Sign Your Contract", func() -> void:
				career.sign_drafted()
				go_to_current(), UiKit.ACCENT.darkened(0.45)))
		"camp":
			list.add_child(_stripe_panel(team, "UNDRAFTED", "Seven rounds, no call. Then your phone rings: the %s "
				% team.get("name", "") + "want you in training camp."))
			_tryout_info(list, "camp")
			col.add_child(CareerUi.button_row([UiKit.button("Retire", _retire, UiKit.DANGER),
				UiKit.button("Go to Camp", _tryout, UiKit.ACCENT.darkened(0.45))]))
		_:
			list.add_child(_stripe_panel(team, "UNDRAFTED", "No team called. The %s are holding an open tryout."
				% team.get("name", "")))
			_tryout_info(list, "free_agent")
			col.add_child(CareerUi.button_row([UiKit.button("Retire", _retire, UiKit.DANGER),
				UiKit.button("Try Out", _tryout, UiKit.ACCENT.darkened(0.45))]))
	list.add_child(UiKit.section("COLLEGE CAREER"))
	for h in career.data.history:
		if h.get("stage", "") == CareerData.STAGE_COLLEGE:
			var s: Dictionary = h.get("stats", {})
			list.add_child(UiKit.stat_row("%s (%s)" % [h.get("year", ""), h.get("team", "")],
				"FG %d/%d  long %d" % [int(s.get("fg_made", 0)), int(s.get("fg_att", 0)), int(s.get("long", 0))]))


func _tryout_info(list: VBoxContainer, purpose: String) -> void:
	var def: Dictionary = Progression.rules().get("tryouts", {}).get(purpose, {})
	var dist: Array = def.get("distances", [])
	list.add_child(UiKit.stat_row("Tryout", "make %d of %d" % [int(def.get("need", 3)), dist.size()], UiKit.ACCENT))
	list.add_child(UiKit.stat_row("Distances", "%s yd" % ", ".join(PackedStringArray(dist.map(func(x): return str(int(x)))))))


func _poor_note(list: VBoxContainer) -> void:
	var left := career.tuning.career_end_poor_streak - career.data.poor_streak
	if left <= 1:
		list.add_child(UiKit.label("This could be your last chance.", 26, UiKit.BAD))


static func _stripe_panel(team: Dictionary, head: String, body: String) -> PanelContainer:
	var p := PanelContainer.new()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	p.add_child(v)
	var h := HBoxContainer.new()
	for col in team.get("colors", []):
		var r := ColorRect.new()
		r.color = Color.from_string(str(col), Color.GRAY)
		r.custom_minimum_size = Vector2(90, 10)
		h.add_child(r)
	v.add_child(h)
	v.add_child(UiKit.label(head, 44, UiKit.ACCENT))
	v.add_child(UiKit.label(body, 30))
	return p


func _tryout() -> void:
	career.take_tryout()
	go_to_current()


func _retire() -> void:
	UiKit.confirm(self, "RETIRE?", "Your career ends here and you'll see your career summary.", "Retire",
		func() -> void:
			career.retire("chose")
			go_to_current())
