extends "res://tests/test_case.gd"
## Reputation: character_concerns / rebuilt_reputation on draft day and in the
## first pro seasons, the notices, and suspensions (suspend_weeks): games sat
## out like academic ineligibility, no game skill points or followers, not a
## benched week, capped at 3.

var t := CareerTuning.get_default()


func _career(stage := CareerData.STAGE_HIGH_SCHOOL) -> CareerManager:
	var c := CareerData.create("Rep Test", t)
	c.created = 1794983149
	c.slot = 0
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c, t)
	m.rng.seed = 5
	m._start_season(false)
	if stage != CareerData.STAGE_HIGH_SCHOOL:
		c.stage = stage
		c.team = Progression.team_from(CareerContent.colleges()[0], stage)
		Relationships.enter_stage(c, t)
	return m


## A scenario with a choice we can edit (restored by the caller).
func _scenario() -> Dictionary:
	for s in CareerContent.scenarios():
		if not s.get("choices", []).is_empty() and (s.get("choices", [])[0] as Dictionary).get("requires", {}).is_empty() \
				and not (s["choices"][0] as Dictionary).has("kick_challenge"):
			return s
	return {}


func test_state_and_draft_day() -> void:
	var c := _career(CareerData.STAGE_COLLEGE).data
	eq(Reputation.state(c), "", "clean record")
	var rounds: Array = Progression.rules().get("draft", {}).get("rounds", [])
	var last: Dictionary = rounds[rounds.size() - 1]
	c.draft_score = float(last["min"]) + 2.0
	var r := RandomNumberGenerator.new()
	eq(str(Progression.draft(c, r)["kind"]), "drafted", "drafted without concerns")
	c.flags[Reputation.CONCERNS] = true
	eq(Reputation.state(c), "concerns", "concerns")
	eq(Reputation.draft_adjust(c, t), t.rep_concerns_draft, "the draft penalty")
	var d := Progression.draft(c, r)
	check(str(d["kind"]) != "drafted", "concerns drop him out of the draft")
	eq(float(d["character"]), t.rep_concerns_draft, "the draft result records why")
	c.flags[Reputation.REBUILT] = true
	eq(Reputation.state(c), "rebuilt", "rebuilt wins over concerns")
	eq(str(Progression.draft(c, r)["kind"]), "drafted", "a rebuilt reputation clears the penalty")
	c.flags.erase(Reputation.REBUILT)
	c.flags[Reputation.CONCERNS] = false
	eq(Reputation.state(c), "", "a recovery scene clears concerns")


func test_pro_standing() -> void:
	var c := _career(CareerData.STAGE_PRO).data
	c.season_stats = {"fg_att": 20, "fg_made": 16, "long": 45}
	var base := Progression.retention(c, t)
	c.flags[Reputation.CONCERNS] = true
	eq(Progression.retention(c, t), base + t.rep_concerns_retention, "concerns cost early standing")
	c.flags[Reputation.REBUILT] = true
	eq(Progression.retention(c, t), base + t.rep_rebuilt_retention, "rebuilt adds a little")
	for i in t.rep_pro_seasons:
		c.history.append({"stage": CareerData.STAGE_PRO})
	eq(Progression.retention(c, t), base, "only the first pro seasons")


func test_notices() -> void:
	var c := _career(CareerData.STAGE_COLLEGE).data
	c.notice = ""
	Reputation.on_flags(c, {Reputation.CONCERNS: true}, t)
	check("Character concerns" in c.notice and str(roundi(-t.rep_concerns_draft)) in c.notice, "says what it costs")
	check(Reputation.week_text(c) != "", "and a Results line this week")
	c.week_index += 1
	eq(Reputation.week_text(c), "", "only that week")
	c.notice = ""
	Reputation.on_flags(c, {Reputation.REBUILT: true}, t)
	check("rebuilt your reputation" in c.notice, "the way back is announced")
	c.notice = ""
	Reputation.on_flags(c, {"some_story_flag": true}, t)
	eq(c.notice, "", "other flags say nothing")


func test_suspension_sits_out_games() -> void:
	var s := _scenario()
	var keep: Dictionary = (s["choices"][0] as Dictionary).duplicate(true)
	s["choices"][0]["suspend_weeks"] = 2
	var m := _career()
	var c := m.data
	# A game week (not a bye).
	while m.is_bye():
		c.week += 1
	c.phase = CareerManager.PHASE_SCENARIO
	c.pending_scenarios = [str(s["id"])]
	var sp := c.sp_sources.duplicate()
	var fans := c.followers
	m.choose(0)
	s["choices"][0] = keep
	check("SUSPENDED for 2 games" in c.notice, "a clear notice")
	eq(c.phase, CareerManager.PHASE_RESULTS, "the game is sat out right away")
	eq(str(c.last_week["line"]), "Sat out (suspended)", "Results say why")
	eq(int(c.last_week["suspended"]["left"]), 1, "one game left")
	check(not c.sp_sources.has("Field goals made"), "no game skill points")
	check(c.recent_fg.is_empty(), "nothing for slumps")
	eq(int(c.bench.get("weeks_total", 0)), 0, "not a benched week")
	check(c.followers - fans <= 0 or Followers.week_lines(c).all(func(e: Dictionary) -> bool:
		return str(e["text"]) == "Choices"), "no followers from kicks")
	check(sp.size() <= c.sp_sources.size(), "practice still counts")
	m.end_week()
	while m.is_bye():
		m.begin_week()
		while c.phase == CareerManager.PHASE_SCENARIO:
			m.choose(0)
		m.end_week()
	m.begin_week()
	check("SUSPENDED" in c.notice, "the second game is announced at the start of the week")
	while c.phase == CareerManager.PHASE_SCENARIO:
		m.choose(0)
	eq(str(c.last_week.get("line", "")), "Sat out (suspended)", "second game sat out")
	check(not Reputation.suspended(c), "served")
	check("suspension is over" in c.notice, "and the end is announced")


func test_suspension_cap_and_stage_change() -> void:
	var m := _career()
	var c := m.data
	Reputation.suspend(c, 9, "Test", t)
	eq(int(c.suspension["weeks_left"]), t.suspend_max_weeks, "capped at 3")
	Reputation.suspend(c, 1, "Again", t)
	eq(int(c.suspension["weeks_left"]), t.suspend_max_weeks, "never past the cap")
	m._enter_stage(CareerData.STAGE_COLLEGE, Progression.team_from(CareerContent.colleges()[0], CareerData.STAGE_COLLEGE), "x")
	check(not Reputation.suspended(c), "a new stage starts clean")


func test_validation() -> void:
	var p := PackedStringArray()
	CareerContent._check_followers(p, "x", {"suspend_weeks": 5})
	check(", ".join(p).contains("suspend_weeks"), "5 is too many")
	p = PackedStringArray()
	CareerContent._check_followers(p, "x", {"suspend_weeks": 2})
	eq(p.size(), 0, "2 is fine")


func test_save_round_trip() -> void:
	var c := _career().data
	Reputation.suspend(c, 2, "The Balcony Dare", t)
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(int(again.suspension["weeks_left"]), 2, "kept")
	eq(str(again.suspension["reason"]), "The Balcony Dare", "with the reason")
	eq(again.suspensions_total, 1, "career count")
