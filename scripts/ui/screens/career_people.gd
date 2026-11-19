extends CareerScreen
## People: the recurring cast (Relationships, data/career/people.json). Everyone
## you know: name, role, how close you are (tier and bar), this week's change,
## what they do for you, and for Tyler Brooks where he plays now. People you
## haven't met yet stay hidden; people from earlier stages are under Former.


func _build(col: VBoxContainer) -> void:
	var c := career.data
	col.add_child(UiKit.title_block("PEOPLE"))
	var list := UiKit.scroll_list(col)
	list.add_theme_constant_override("separation", 12)
	var unmet := 0
	for d in Relationships.defs():
		var id := str(d.get("id", ""))
		if not c.people.has(id):
			continue
		if Relationships.known(c, id):
			list.add_child(_card(c, id, d))
		else:
			unmet += 1
	if unmet > 0:
		list.add_child(UiKit.label("Someone you haven't met yet may still come into your life.", 22, UiKit.MUTED))
	if not c.former_people.is_empty():
		list.add_child(UiKit.section("FORMER"))
		for i in range(c.former_people.size() - 1, -1, -1):
			list.add_child(_former_row(c.former_people[i]))
	UiKit.stagger(list, 0.04)
	col.add_child(UiKit.button("Back", go_back, UiKit.SECONDARY, "back"))


func _card(c: CareerData, id: String, d: Dictionary) -> PanelContainer:
	var value := Relationships.value(c, id)
	var color := CareerUi.stat_color(value)
	var parts := UiKit.card(color, 6)
	var v: VBoxContainer = parts[1]
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(head)
	head.add_child(UiIcons.rect(str(d.get("icon", "social")), color, 48))
	var names := VBoxContainer.new()
	names.add_theme_constant_override("separation", 0)
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	names.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(names)
	names.add_child(UiKit.label(Relationships.name_of(c, id).to_upper(), 32, UiKit.TEXT, UiTokens.FONT_DISPLAY))
	names.add_child(UiKit.label(Relationships.role(c, id), 22, UiKit.MUTED))
	var tier := UiKit.chip(Relationships.tier(c, id).to_upper(), color, false, "", 22)
	tier.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(tier)
	v.add_child(StatBar.new("", "Relationship", value, color, 22))
	var wc := float(c.people[id].get("week_change", 0.0))
	if absf(wc) >= 0.5:
		v.add_child(UiKit.label("%s%d this week" % ["+" if wc > 0.0 else "", roundi(wc)], 22,
			UiKit.GOOD if wc > 0.0 else UiKit.BAD))
	if id == Relationships.TYLER:
		var tt := Relationships.tyler_team(c)
		if not tt.is_empty():
			var mine := str(tt.get("id", "")) == str(c.team.get("id", ""))
			v.add_child(UiKit.label("Your teammate again." if mine else "Plays for %s." % tt.get("name", ""),
				22, UiKit.ACCENT))
	v.add_child(UiKit.label(str(d.get("about", "")), 22, UiKit.MUTED))
	return parts[0]


func _former_row(f: Dictionary) -> PanelContainer:
	var v := float(f.get("value", 50.0))
	var where := str({"high_school": "high school", "juco": "junior college", "college": "college",
		"pro": "pros"}.get(str(f.get("stage", "")), ""))
	var d := Relationships.def(str(f.get("id", "")))
	return UiKit.stat_row("%s  ·  %s, %s" % [f.get("name", ""), f.get("role", ""), where],
		"%d" % roundi(v), CareerUi.stat_color(v), str(d.get("icon", "social")))
