extends CareerScreen
## The Hall of Fame vote (R10): after the closing scenes, before the career
## summary. Each part of the case with its points, the total against the
## tiers, and the result. Formula: HallOfFame; numbers: CareerTuning "Hall of Fame".


func _build(col: VBoxContainer) -> void:
	var c := career.data
	var t := career.tuning
	var hof: Dictionary = c.retirement.get("hof", {})
	if hof.is_empty():
		hof = HallOfFame.evaluate(c, t)
	col.add_child(UiKit.title_block("Hall of Fame", "The vote"))
	var tier := str(hof.get("tier", "none"))
	var good := tier != "none"
	var hero := UiKit.card(UiKit.GOOD if HallOfFame.earned(tier) else (UiKit.ACCENT if good else UiKit.MUTED), 2)
	var hv: VBoxContainer = hero[1]
	var name_l := UiKit.label(HallOfFame.tier_text(hof).to_upper(), 46, UiKit.TEXT, UiTokens.FONT_DISPLAY)
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hv.add_child(name_l)
	hv.add_child(UiKit.label("Score %d  ·  %s" % [int(hof.get("score", 0)), _next_line(int(hof.get("score", 0)), t)],
		26, UiKit.MUTED))
	col.add_child(hero[0])
	var list := UiKit.scroll_list(col)
	list.add_child(UiKit.section("The case"))
	for l in hof.get("lines", []):
		var pts := int(l.get("points", 0))
		list.add_child(UiKit.stat_row(str(l.get("label", "")), "%s  ·  %+d" % [str(l.get("detail", "")), pts],
			UiKit.GOOD if pts > 0 else (UiKit.BAD if pts < 0 else UiKit.MUTED)))
	list.add_child(UiKit.section("The tiers"))
	for row in [["Ring of Honor", t.hof_ring_of_honor], ["Finalist", t.hof_finalist],
			["Hall of Fame", t.hof_inducted], ["First ballot", t.hof_first_ballot]]:
		list.add_child(UiKit.stat_row(str(row[0]), "%d+" % int(row[1])))
	col.add_child(UiKit.primary("Continue", func() -> void:
		career.finish_hall_of_fame()
		go_to_current(), "next"))


## "Hall of Fame at 100" / "8 short of the Hall of Fame" / "First ballot".
static func _next_line(score: int, t: CareerTuning) -> String:
	if score >= t.hof_first_ballot:
		return "first ballot at %d" % t.hof_first_ballot
	if score >= t.hof_inducted:
		return "%d short of the first ballot" % (t.hof_first_ballot - score)
	return "%d short of the Hall of Fame" % (t.hof_inducted - score)


func go_back() -> void:
	Screens.go(Screens.CAREER)
