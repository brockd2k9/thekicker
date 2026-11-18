extends CareerScreen
## Recruiting (after each high school / junior college season): the recruiting
## score and what moved it, GPA, new and withdrawn offers.
## College choice (after the last season): every offer, plus the fallbacks
## (walk-on tryouts, junior college). No options at all = the career ends.


func _build(col: VBoxContainer) -> void:
	if career.data.phase == CareerManager.PHASE_COLLEGE_CHOICE:
		_choice(col)
	else:
		_update(col)


func _update(col: VBoxContainer) -> void:
	var c := career.data
	var u: Dictionary = c.flags.get("recruiting_update", {})
	col.add_child(UiKit.title_block("RECRUITING UPDATE"))
	col.add_child(UiKit.label("%s  -  %s" % [career.class_year(), CareerScreen.team_name(c.team)], 26,
		UiKit.MUTED))
	var list := UiKit.scroll_list(col)
	var gain := float(u.get("gain", 0.0))
	list.add_child(UiKit.stat_row("Recruiting score", "%d  (%s%d)" % [roundi(c.recruiting_score),
		"+" if gain >= 0.0 else "", roundi(gain)], UiKit.ACCENT))
	list.add_child(UiKit.stat_row("Level", CareerScreen.recruit_word(c)))
	list.add_child(UiKit.stat_row("GPA", "%.2f" % c.gpa, UiKit.GOOD if c.gpa >= 2.8 else
		(Color.WHITE if c.gpa >= 2.2 else UiKit.BAD)))
	for tier_id in u.get("blocked_by_gpa", []):
		list.add_child(UiKit.label("%s schools are interested, but your GPA is below their %.1f minimum." % [
			Progression.tier(str(tier_id)).get("name", ""), float(Progression.tier(str(tier_id)).get("min_gpa", 0))],
			24, UiKit.BAD))
	list.add_child(UiKit.section("NEW OFFERS"))
	if (u.get("new", []) as Array).is_empty():
		list.add_child(UiKit.label("No new offers this year." if c.season_in_stage > 1 or c.stage == CareerData.STAGE_JUCO
			else "Too early for offers. Coaches are watching.", 26, UiKit.MUTED))
	for off in u.get("new", []):
		list.add_child(_offer_panel(off))
	for off in u.get("rescinded", []):
		list.add_child(UiKit.label("%s withdrew their offer." % off.get("name", ""), 24, UiKit.BAD))
	if c.offers.size() > (u.get("new", []) as Array).size():
		list.add_child(UiKit.section("ALL OFFERS"))
		for off in c.offers:
			list.add_child(_offer_panel(off))
	list.add_child(UiKit.label(_tip(c, bool(u.get("final", false))), 22, UiKit.MUTED))
	var b := UiKit.button("Signing Day" if u.get("final", false) else "Continue", func() -> void:
		career.continue_recruiting()
		go_to_current(), UiKit.PRIMARY)
	col.add_child(b)


static func _tip(c: CareerData, final: bool) -> String:
	if final:
		return "Signing day is next: pick an offer, try to walk on, or go the junior college route."
	return "Recruiting grows with your kicking (accuracy, long makes), your team's record, your leg, " \
		+ "and choices like camps, highlight films and visits. Keep your GPA up: better schools need %.1f+." \
		% float(Progression.tier("top").get("min_gpa", 2.8))


func _choice(col: VBoxContainer) -> void:
	var c := career.data
	col.add_child(UiKit.title_block("SIGNING DAY"))
	col.add_child(UiKit.label("Recruiting %d  -  GPA %.2f" % [roundi(c.recruiting_score), c.gpa], 26,
		UiKit.MUTED))
	var list := UiKit.scroll_list(col)
	var options := career.college_options()
	if options.is_empty():
		list.add_child(UiKit.label("No school has a roster spot for you, and your run of rough seasons has "
			+ "closed the walk-on and junior college doors.", 28))
		col.add_child(UiKit.button("Hang Up the Cleats", func() -> void:
			career.retire("no_options")
			go_to_current(), UiKit.DANGER))
		return
	for opt in options:
		var parts := CareerUi.card(_pick.bind(opt))
		var v: VBoxContainer = parts[1]
		match str(opt["kind"]):
			"offer":
				var off: Dictionary = opt["offer"]
				var s := CareerContent.team_by_id(str(off["school"]))
				v.add_child(_stripe(s))
				v.add_child(UiKit.label("%s %s" % [s.get("name", ""), s.get("mascot", "")], 32, UiKit.TEXT, UiTokens.FONT_DISPLAY))
				v.add_child(UiKit.label("%s  -  %s" % [Progression.OFFER_NAMES.get(str(off["type"]), ""),
					Progression.tier(str(off["tier"])).get("name", "")], 26, UiKit.ACCENT))
				v.add_child(UiKit.label(_tier_line(str(off["tier"]), s), 22, UiKit.MUTED))
			"walk_on_tryout":
				var def: Dictionary = Progression.rules().get("tryouts", {}).get("walk_on", {})
				v.add_child(UiKit.label("Walk-on tryout: %s" % opt["name"], 30))
				v.add_child(UiKit.label("%s. Make %d of %d field goals (%s yd) to earn a roster spot." % [
					Progression.tier(str(opt["tier"])).get("name", ""), int(def.get("need", 3)),
					(def.get("distances", []) as Array).size(), _range_text(def.get("distances", []))], 22, UiKit.MUTED))
			"juco":
				v.add_child(UiKit.label("Junior college", 30))
				v.add_child(UiKit.label("Play %d season at a junior college, then get recruited again." % career.tuning.juco_seasons,
					22, UiKit.MUTED))
		list.add_child(parts[0])


static func _range_text(d: Array) -> String:
	return "%d-%d" % [int(d[0]), int(d[d.size() - 1])] if not d.is_empty() else "?"


static func _tier_line(tier_id: String, s: Dictionary) -> String:
	var tr := Progression.tier(tier_id)
	return "Team: %s. Exposure to pro scouts x%.1f. Kicks up to %d yd." % [
		CareerScreen.strength_word(float(s.get("strength", 50))), float(tr.get("exposure", 1.0)),
		int(tr.get("fg_max_yards", 50))]


static func _stripe(s: Dictionary) -> HBoxContainer:
	return CareerUi.team_stripe(s, 60, 8)


func _offer_panel(off: Dictionary) -> PanelContainer:
	var s := CareerContent.team_by_id(str(off.get("school", "")))
	var cols: Array = s.get("colors", [])
	var parts := UiKit.card(Color.from_string(str(cols[0]), UiKit.ACCENT) if not cols.is_empty() else UiKit.ACCENT, 6)
	var p: PanelContainer = parts[0]
	var v: VBoxContainer = parts[1]
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	v.add_child(h)
	h.add_child(UiIcons.rect("school", Color.from_string(str(cols[1]), UiKit.ACCENT) if cols.size() > 1 else UiKit.ACCENT, 40))
	var name := UiKit.label("%s %s" % [s.get("name", ""), s.get("mascot", "")], 30, UiKit.TEXT, UiTokens.FONT_DISPLAY)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(name)
	var tags := HFlowContainer.new()
	tags.add_theme_constant_override("h_separation", 8)
	tags.add_theme_constant_override("v_separation", 6)
	v.add_child(tags)
	var full := str(off.get("type", "")) == "full"
	tags.add_child(UiKit.chip(str(Progression.OFFER_NAMES.get(str(off.get("type", "")), "")), UiKit.GOOD if full else UiKit.ACCENT,
		full, "", 22))
	tags.add_child(UiKit.chip(str(Progression.tier(str(off.get("tier", ""))).get("name", "")), UiKit.MUTED, false, "", 22))
	return p


func _pick(opt: Dictionary) -> void:
	if get_node_or_null("Modal") != null:
		return
	var text := ""
	match str(opt["kind"]):
		"offer":
			text = "Sign with %s?" % opt["offer"].get("name", "")
		"walk_on_tryout":
			text = "Try out as a walk-on at %s? If you're cut, you'll be back here." % opt["name"]
		"juco":
			text = "Go to junior college for a season?"
	var v := UiKit.modal(self, "DECISION")
	var l := UiKit.label(text, 30)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l)
	var root := UiKit.modal_root(v)
	v.add_child(UiKit.button("Yes", func() -> void:
		career.choose_college(opt)
		go_to_current(), UiKit.PRIMARY, "check"))
	v.add_child(UiKit.button("Not Yet", root.queue_free))
