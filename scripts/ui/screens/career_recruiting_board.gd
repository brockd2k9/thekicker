extends CareerScreen
## Recruiting (Hub → Recruiting): your recruiting points and the colleges
## interested in you, most interested first, with each school's interest
## level and any offer it has made. Interest comes from the same rules that
## make offers (CareerRecords.school_interest): your points against each
## school tier's bar. After you sign, it shows the final picture.
## (The recruiting update and signing day after each season stay on their
## own screen, career_recruiting.gd.)


func _build(col: VBoxContainer) -> void:
	var c := career.data
	var recruiting := c.stage in [CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO]
	col.add_child(UiKit.title_block("Recruiting", career.stage_name() + "  ·  " + career.class_year()))
	col.add_child(_points_card(recruiting))
	var list := UiKit.scroll_list(col)
	if not recruiting:
		var done := UiKit.card(UiKit.MUTED, 6)
		var v: VBoxContainer = done[1]
		v.add_child(UiKit.label("RECRUITING IS OVER", 26, UiKit.TEXT, UiTokens.FONT_DISPLAY))
		v.add_child(UiKit.label(_signed_text(), 24, UiKit.MUTED))
		list.add_child(done[0])
	else:
		var schools := CareerRecords.interested_schools(c)
		list.add_child(UiKit.section("Interested schools (%d)" % schools.size()))
		if schools.is_empty():
			list.add_child(UiKit.label("No college is watching yet. Make kicks, win games and pick choices "
				+ "that build recruiting points.", 26, UiKit.MUTED))
		for s in schools:
			list.add_child(_school_row(s))
		UiKit.stagger(list, 0.03)
	list.add_child(UiKit.label("Recruiting points grow after each season with your kicking (accuracy, long "
		+ "makes), your team's record, your leg and choices like camps, highlight films and visits. Schools "
		+ "start offering at 50 interest, the most interested school in each tier first (one new offer per "
		+ "tier a season, none as a freshman); better schools also need a higher GPA.", 22, UiKit.MUTED))
	col.add_child(UiKit.button("Back", go_back, UiKit.SECONDARY, "back"))


## Big recruiting number, a bar, and chips (level, GPA, offers).
func _points_card(active: bool) -> PanelContainer:
	var c := career.data
	var parts := UiKit.card(UiKit.ACCENT, 6)
	var v: VBoxContainer = parts[1]
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	v.add_child(h)
	h.add_child(UiIcons.rect("school", UiKit.ACCENT, 48))
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", -4)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(left)
	left.add_child(UiKit.label("RECRUITING POINTS", 22, UiKit.MUTED, UiTokens.FONT_CONDENSED))
	left.add_child(UiKit.label(CareerScreen.recruit_word(c), 28, UiKit.TEXT, UiTokens.FONT_DISPLAY))
	h.add_child(UiKit.line("%d" % roundi(c.recruiting_score), 64, UiKit.ACCENT, UiTokens.FONT_BANNER))
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = 100
	bar.value = c.recruiting_score
	bar.custom_minimum_size.y = 12
	v.add_child(bar)
	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", 8)
	chips.add_theme_constant_override("v_separation", 6)
	v.add_child(chips)
	chips.add_child(UiKit.chip("GPA %.2f" % c.gpa, UiKit.MUTED, false, "book", 22))
	if active:
		var n := c.offers.size()
		chips.add_child(UiKit.chip("%d offer%s" % [n, "" if n == 1 else "s"], UiKit.GOOD if n > 0 else UiKit.MUTED,
			n > 0, "", 22))
	return parts[0]


func _school_row(e: Dictionary) -> PanelContainer:
	var s: Dictionary = e["school"]
	var cols: Array = s.get("colors", [])
	var c1 := Color.from_string(str(cols[0]), UiKit.ACCENT) if not cols.is_empty() else UiKit.ACCENT
	var parts := UiKit.card(c1, 6)
	var v: VBoxContainer = parts[1]
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	v.add_child(top)
	var name := UiKit.label("%s %s" % [s.get("name", ""), s.get("mascot", "")], 28, UiKit.TEXT, UiTokens.FONT_DISPLAY)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name)
	var interest := float(e["interest"])
	var col := _interest_color(interest)
	top.add_child(UiKit.line("%d" % roundi(interest), 34, col, UiTokens.FONT_BANNER))
	# Interest bar.
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = 100
	bar.value = interest
	bar.custom_minimum_size.y = 10
	var fill := StyleBoxFlat.new()
	fill.bg_color = col
	fill.set_corner_radius_all(5)
	bar.add_theme_stylebox_override("fill", fill)
	v.add_child(bar)
	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", 8)
	chips.add_theme_constant_override("v_separation", 6)
	v.add_child(chips)
	chips.add_child(UiKit.chip(str(e["word"]), col, false, "", 22))
	chips.add_child(UiKit.chip(str(Progression.tier(str(s.get("tier", ""))).get("name", "")), UiKit.MUTED, false, "", 22))
	var off: Dictionary = e["offer"]
	if not off.is_empty():
		chips.add_child(UiKit.chip("OFFER: " + str(Progression.OFFER_NAMES.get(str(off.get("type", "")), "Offer")),
			UiKit.GOOD, true, "check", 22))
	elif e["no_offer_yet"]:
		var why := UiKit.label("Interest high, no offer yet this season", 22, UiKit.WARN, UiTokens.FONT_CONDENSED)
		v.add_child(why)
	if off.is_empty() and e["gpa_short"]:
		chips.add_child(UiKit.chip("GPA below %.1f" % float(Progression.tier(str(s.get("tier", ""))).get("min_gpa", 0)),
			UiKit.BAD, false, "book", 22))
	return parts[0]


static func _interest_color(v: float) -> Color:
	if v >= 60.0:
		return UiKit.GOOD
	if v >= 40.0:
		return UiKit.ACCENT
	if v >= 20.0:
		return UiKit.WARN
	return UiKit.MUTED


## Where recruiting led: the college (or junior college) you signed with.
func _signed_text() -> String:
	var c := career.data
	for h in c.history:
		var st := str(h.get("stage", ""))
		if st == CareerData.STAGE_COLLEGE:
			return "You signed with %s. Final recruiting points: %d." % [h.get("team", ""), roundi(c.recruiting_score)]
	if c.stage == CareerData.STAGE_COLLEGE:
		return "You signed with %s. Final recruiting points: %d." % [CareerScreen.team_name(c.team),
			roundi(c.recruiting_score)]
	return "Final recruiting points: %d." % roundi(c.recruiting_score)
