extends CareerScreen
## Results & Week Summary: the final score (or the bye week), every kick you
## took, your warmups, the stat changes the week caused, Coach / Team changes
## from your kicks, skill points earned (and unspent), and the record.
## Continue = end of week: weekly recovery, autosave, next week.


func _build(col: VBoxContainer) -> void:
	var c := career.data
	var w := c.last_week
	var list: VBoxContainer
	var opp := {"short": str(w.get("mascot", w.get("opponent", "OPP"))).left(12), "colors": w.get("colors", ["#3a3f4b", "#8a93a6"])}
	var op_team := _opponent(str(w.get("opponent", "")))
	if not op_team.is_empty():
		opp = op_team
	if w.get("type", "") == "benched":
		var o := str(w.get("outcome", "T"))
		_banner(col, o)
		col.add_child(CareerUi.scoreboard(c.team, opp, str(int(w.get("us", 0))), str(int(w.get("them", 0))),
			"FINAL")["root"])
		var susp: Dictionary = w.get("suspended", {})
		if not susp.is_empty():
			var left := int(susp.get("left", 0))
			var n := UiKit.chip("You sat out: suspended%s. %s" % [
				(" (%s)" % susp["reason"]) if str(susp.get("reason", "")) != "" else "",
				("%d more game%s." % [left, "" if left == 1 else "s"]) if left > 0 else "You're back next week."],
				UiKit.BAD, false, "whistle", 24)
			col.add_child(n)
		else:
			col.add_child(UiKit.chip("You sat out: academically ineligible (GPA %.2f)." % c.gpa, UiKit.BAD, false, "book", 24))
		list = UiKit.scroll_list(col)
	elif w.get("type", "") == "bye":
		col.add_child(UiKit.title_block("Bye Week %d" % int(w.get("week", c.week)), "No game"))
		col.add_child(UiKit.label("No game. Time to recover.", 30, UiKit.MUTED))
		list = UiKit.scroll_list(col)
	else:
		var o := str(w.get("outcome", "T"))
		_banner(col, o)
		var round_name := str(w.get("postseason", ""))
		col.add_child(CareerUi.scoreboard(c.team, opp, str(int(w.get("us", 0))), str(int(w.get("them", 0))),
			"FINAL", round_name.to_upper() if round_name != "" else "WEEK %d" % int(w.get("week", 0)))["root"])
		col.add_child(CareerUi.centered("%s %s   ·   Record %d-%d" % [
			"vs" if w.get("home", true) else "at", w.get("opponent", ""), int(c.record["w"]),
			int(c.record["l"])], 24, UiKit.MUTED))
		if round_name != "":
			var won := o == "W"
			var msg := ("CHAMPIONS! You won the %s." % round_name) if won and w.get("final", false) \
				else ("You advance." if won else "Your season is over.")
			col.add_child(CareerUi.centered(msg, 28, UiKit.GOOD if won else UiKit.BAD))
		list = UiKit.scroll_list(col)
		# Overtime: what happened, and (college from the third overtime) why
		# you didn't kick.
		var ot: Dictionary = w.get("ot", {}) if w.get("ot") is Dictionary else {}
		if not ot.is_empty():
			var txt := "Overtime%s." % ("" if int(ot.get("rounds", 1)) <= 1 or str(ot.get("rule")) == "pro"
				else " (%d rounds)" % int(ot["rounds"]))
			if bool(ot.get("two_point", false)):
				txt += " From the third overtime college plays two-point tries only, so you didn't kick."
			elif str(w.get("outcome", "")) == "T":
				txt += " Still tied when overtime ran out."
			var oc := UiKit.chip(txt, UiKit.WARN, false, "whistle", 22)
			list.add_child(oc)
		list.add_child(UiKit.section("Your kicks"))
		var kicks: Array = w.get("kicks", [])
		if kicks.is_empty():
			list.add_child(UiKit.label("The coach never called your number.", 26, UiKit.MUTED))
		for k in kicks:
			if str(k.get("kind", "")) in ["fg", "pat", "onside"]:
				list.add_child(_kick_row(k))
		var ko := _kickoff_summary(kicks)
		if ko != null:
			list.add_child(ko)
		var warm: Array = w.get("warmups", [])
		if not warm.is_empty():
			var words := {"pure": "Pure", "loose": "Loose", "skipped": "Skipped"}
			var parts := PackedStringArray()
			for x in warm:
				parts.append(str(words.get(str(x), x)))
			list.add_child(UiKit.stat_row("Sideline warmups", ", ".join(parts), Color(0, 0, 0, 0), "toughness"))
	var rec := CareerUi.record_events(c)
	if rec != null:
		list.add_child(rec)
		career.save()
	list.add_child(UiKit.section("THIS WEEK'S CHANGES"))
	var changes: Dictionary = w.get("changes", {})
	list.add_child(CareerUi.change_chips(changes))
	for t in changes.get("new_traits", []):
		list.add_child(preload("res://scripts/ui/screens/career_scenario.gd").trait_unlock_card(str(t)))
	var moved := {}
	for id in c.people:
		var wc := float(c.people[id].get("week_change", 0.0))
		if absf(wc) >= 0.5:
			moved[id] = wc
	if not moved.is_empty():
		list.add_child(CareerUi.rel_chips(c, moved))
	# Coach / Team from your kicks this week, with the kick that mattered most.
	var tw := c.trust_week
	var tw_text := KickTrust.change_text(float(tw.get("coach", 0.0)), float(tw.get("team", 0.0)))
	if tw_text != "":
		var good := float(tw.get("coach", 0.0)) + float(tw.get("team", 0.0)) >= 0.0
		list.add_child(UiKit.stat_row("From your kicks", tw_text, UiKit.GOOD if good else UiKit.BAD, "whistle"))
		for line in tw.get("lines", []):
			list.add_child(UiKit.label(str(line), 22, UiKit.MUTED))
	var trust: Dictionary = w.get("trust", {})
	if trust.get("slump", false) and not c.coach_doubt.is_empty():
		var n := UiKit.chip("%s has lost faith in your kicking (%s): fewer, shorter field goals for %d weeks."
			% [Relationships.name_of(c, "coach"), c.coach_doubt.get("reason", ""), int(c.coach_doubt.get("weeks_left", 0))],
			UiKit.BAD, false, "whistle", 22)
		list.add_child(n)
	# Benching: the backup's line, or the bench that starts now.
	var bi: Dictionary = w.get("bench", {})
	if bi.get("sat", false):
		list.add_child(UiKit.stat_row("%s on field goals" % bi.get("backup", "The backup"),
			"%d / %d" % [int(bi.get("made", 0)), int(bi.get("att", 0))], UiKit.WARN, "whistle"))
		list.add_child(UiKit.label("You were benched: no game skill points this week (practice still counts). "
			+ ("Your audition is next week." if int(bi.get("weeks_left", 0)) <= 1 else "One more week on the bench."), 22, UiKit.MUTED))
	elif bi.get("started", false):
		var n := UiKit.chip("BENCHED: %s takes your field goals for %d week%s (%s). Then an audition to win the job back."
			% [bi.get("backup", ""), int(bi.get("weeks", 1)), "" if int(bi.get("weeks", 1)) == 1 else "s", bi.get("reason", "")],
			UiKit.BAD, false, "whistle", 24)
		list.add_child(n)
	# Skill points earned this week and what's left to spend.
	var sp := CareerUi.sp_lines(c)
	if not sp.is_empty():
		list.add_child(UiKit.section("SKILL POINTS"))
		list.add_child(UiKit.stat_row(str(sp[0]).split("  (")[0], "%d to spend" % c.skill_points,
			UiKit.GOOD if c.skill_points > 0 else UiKit.MUTED, "skill"))
		if sp.size() > 1:
			list.add_child(UiKit.label(str(sp[1]), 22, UiKit.MUTED))
		if c.skill_points > 0:
			list.add_child(UiKit.button("Spend in Skills", Screens.go.bind(Screens.CAREER_SKILLS),
				UiKit.SECONDARY, "skill"))
	# A reputation change this week (Reputation): what it means for the draft and the pros.
	var rep := Reputation.week_text(c)
	if rep != "":
		var good := Reputation.state(c) != "concerns"
		var rc := UiKit.chip(rep, UiKit.GOOD if good else UiKit.BAD, false, "career", 22)
		list.add_child(rc)
	# Followers this week (real counts) and where they came from.
	var fl := CareerUi.followers_lines(c)
	if not fl.is_empty():
		list.add_child(UiKit.section("FOLLOWERS"))
		list.add_child(UiKit.stat_row(str(fl[0]), "%s  ·  %s" % [Followers.short(c.followers),
			Followers.tier_name(Followers.tier(c, career.tuning))],
			UiKit.GOOD if Followers.week_total(c) >= 0 else UiKit.BAD, "social"))
		if str(fl[1]) != "":
			list.add_child(UiKit.label(str(fl[1]), 22, UiKit.MUTED))
	list.add_child(UiKit.label("Recovery is added when you continue.", 22, UiKit.MUTED))
	if w.has("recruiting"):
		var rp := float(w["recruiting"])
		list.add_child(UiKit.stat_row("Recruiting points", "%s%.1f  (now %d)" % ["+" if rp >= 0.0 else "", rp,
			roundi(c.recruiting_score)], UiKit.GOOD if rp > 0.0 else (UiKit.BAD if rp < 0.0 else UiKit.MUTED), "school"))
	list.add_child(UiKit.section("SEASON"))
	var s := c.season_stats
	list.add_child(UiKit.stat_row("Field goals", "%d / %d" % [int(s["fg_made"]), int(s["fg_att"])]))
	list.add_child(UiKit.stat_row("Extra points", "%d / %d" % [int(s["pat_made"]), int(s["pat_att"])]))
	list.add_child(UiKit.stat_row("Long", ("%d yd" % int(s["long"])) if int(s["long"]) > 0 else "-"))

	var next := UiKit.button("Continue", func() -> void:
		career.end_week()
		go_to_current(), UiKit.PRIMARY, "next")
	if League.valid(c.league, c.stage):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var table := UiKit.button("Standings", Screens.go.bind(Screens.CAREER_STANDINGS), UiKit.SECONDARY, "achievements")
		table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(table)
		row.add_child(next)
		col.add_child(row)
	else:
		col.add_child(next)
	if not OS.has_feature("mobile"):
		next.grab_focus.call_deferred()


## WIN / LOSS / TIE banner that punches in.
func _banner(col: VBoxContainer, o: String) -> void:
	var tag := CareerManager.ot_tag(career.data.last_week)
	var word: String = {"W": "WIN", "L": "LOSS", "T": "TIE"}.get(o, o)
	if tag != "":
		word = "TIE (after OT)" if o == "T" else "%s %s" % [word, tag]
	col.add_child(CareerUi.result_banner(word,
		UiKit.GOOD if o == "W" else (UiKit.BAD if o == "L" else UiKit.MUTED)))
	UiKit.feedback(&"week_result")


## The opponent's team (for its colors) from this season's schedule, by name.
func _opponent(name: String) -> Dictionary:
	for e in career.data.schedule:
		var t: Dictionary = e.get("opponent", {})
		if not t.is_empty() and (CareerScreen.team_name(t) == name or str(t.get("name", "")) == name
				or str(t.get("town", "")) == name):
			return t
	return {}


static func _kick_row(k: Dictionary) -> PanelContainer:
	var kind := str(k.get("kind", ""))
	match kind:
		"fg", "pat":
			var made: bool = k.get("made", false)
			var name := ("FG %d yd" % int(k.get("yards", 0))) if kind == "fg" else "Extra point"
			var lbl := str(k.get("label", ""))
			if "GAME WINNER" in lbl or "TO TIE" in lbl:
				name += "  (clutch)"
			return UiKit.stat_row(name, "GOOD" if made else "MISS", UiKit.GOOD if made else UiKit.BAD,
				"check" if made else "cross")
		"onside":
			var rec: bool = k.get("recovered", false)
			return UiKit.stat_row("Onside kick", "RECOVERED" if rec else "Lost", UiKit.GOOD if rec else UiKit.BAD,
				"check" if rec else "cross")
	return UiKit.stat_row(kind, str(k.get("result", "")))


## All kickoffs in one row: "Kickoffs (4)   avg 41 yd, 1 TB".
static func _kickoff_summary(kicks: Array) -> PanelContainer:
	var n := 0
	var carry := 0.0
	var tb := 0
	var oob := 0
	for k in kicks:
		if str(k.get("kind", "")) != "kickoff":
			continue
		n += 1
		carry += float(k.get("carry", 0.0))
		var q := float(k.get("quality", 0.0))
		if q >= 0.99:
			tb += 1
		elif q <= 0.1:
			oob += 1
	if n == 0:
		return null
	var v := "avg %d yd" % roundi(carry / n)
	if tb > 0:
		v += ", %d TB" % tb
	if oob > 0:
		v += ", %d OOB" % oob
	return UiKit.stat_row("Kickoffs (%d)" % n, v, UiKit.BAD if oob > 0 else Color(0, 0, 0, 0), "ball")
