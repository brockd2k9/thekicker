extends CareerScreen
## Recruiting (Hub → Recruiting): your recruiting points and every college
## (FBS / FCS / D2 tabs), most interested first, with each school's interest
## level and any offer it has made. Points move after every game. Interest comes from the same rules that
## make offers (CareerRecords.school_interest): your points against each
## school tier's bar. After you sign, it shows the final picture.
## (The recruiting update and signing day after each season stay on their
## own screen, career_recruiting.gd.)


## The level shown (FBS / FCS / D2), while the game runs ("" = where the
## most interested school is).
static var division_shown := ""
const DIVISIONS := [["FBS", "FBS"], ["FCS", "FCS"], ["D2", "Division II"]]


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
		_all_schools(col, list)
	list.add_child(UiKit.label("Recruiting points move after every game with your kicking (accuracy, long "
		+ "makes), your team's record, your leg and range, and choices like camps, highlight films and visits; "
		+ "the coach's word, your followers and the playoffs add theirs after the season. Schools start "
		+ "offering at 50 interest, after the season, the most interested school in each tier first (one new "
		+ "offer per tier a season, none as a freshman); better schools also need a higher GPA. Junior colleges "
		+ "(%d) take any kicker a four-year school doesn't sign." % TeamDatabase.jucos().size(), 22, UiKit.MUTED))
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


## Every college of the chosen level, most interested first.
func _all_schools(col: VBoxContainer, list: VBoxContainer) -> void:
	var c := career.data
	if division_shown == "":
		var best := CareerRecords.all_schools(c)
		division_shown = str(best[0]["school"].get("division", "FBS")) if not best.is_empty() else "FBS"
	var seg: BrandSegmented = load("res://scenes/ui/brand/segmented_toggle.tscn").instantiate()
	seg.options = PackedStringArray(DIVISIONS.map(func(d: Array) -> String: return str(d[0])))
	seg.selected = maxi(DIVISIONS.map(func(d: Array) -> String: return str(d[0])).find(division_shown), 0)
	seg.option_selected.connect(func(i: int) -> void:
		division_shown = str(DIVISIONS[i][0])
		Screens.go(Screens.CAREER_RECRUITING_BOARD))
	col.add_child(seg)
	col.move_child(seg, list.get_parent().get_parent().get_index())
	var schools := CareerRecords.all_schools(c, division_shown)
	var watching := schools.filter(func(e: Dictionary) -> bool:
		return float(e["interest"]) >= CareerRecords.LIST_MIN_INTEREST or not e["offer"].is_empty()).size()
	var name := ""
	for d in DIVISIONS:
		if d[0] == division_shown:
			name = d[1]
	list.add_child(UiKit.section("%s schools (%d)  ·  %d watching you" % [name, schools.size(), watching]))
	for e in schools:
		list.add_child(_compact_row(e))


## One school in a line: name, conference and where they stand; interest on
## the right with a thin bar.
func _compact_row(e: Dictionary) -> Control:
	var s: Dictionary = e["school"]
	var interest := float(e["interest"])
	var colr := _interest_color(interest)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(h)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(left)
	left.add_child(UiKit.label(str(s.get("name", "")), 28, UiKit.TEXT))
	var sub := "%s  ·  %s" % [str(s.get("conference", "")), str(e["word"])]
	var off: Dictionary = e["offer"]
	var sub_col := UiKit.MUTED
	if not off.is_empty():
		sub += "  ·  OFFER: " + str(Progression.OFFER_NAMES.get(str(off.get("type", "")), "Offer"))
		sub_col = UiKit.GOOD
	elif e["gpa_short"]:
		sub += "  ·  needs GPA %.1f" % float(Progression.tier(str(s.get("tier", ""))).get("min_gpa", 0))
		sub_col = UiKit.BAD
	elif e["no_offer_yet"]:
		sub += "  ·  could offer after the season"
		sub_col = UiKit.WARN
	left.add_child(UiKit.label(sub, 22, sub_col))
	var num := UiKit.line("%d" % roundi(interest), 34, colr, UiTokens.FONT_BANNER)
	num.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(num)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = 100
	bar.value = interest
	bar.custom_minimum_size.y = 6
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := UiKit._box(colr, 0)
	fill.set_content_margin_all(0)
	bar.add_theme_stylebox_override("fill", fill)
	v.add_child(bar)
	return v


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
	var fill := UiKit._box(col, 0)
	fill.set_content_margin_all(0)
	bar.add_theme_stylebox_override("fill", fill)
	v.add_child(bar)
	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", 8)
	chips.add_theme_constant_override("v_separation", 6)
	v.add_child(chips)
	chips.add_child(UiKit.chip(str(e["word"]), col, false, "", 22))
	chips.add_child(UiKit.chip(str(Progression.tier(str(s.get("tier", ""))).get("name", "")), UiKit.MUTED, false, "", 22))
	chips.add_child(UiKit.chip(CareerUi.league_line(s), UiKit.MUTED, false, "", 22))
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
