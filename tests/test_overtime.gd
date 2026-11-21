extends "res://tests/test_case.gd"
## Overtime (GameSim) by stage: high school (Kansas plan: the 10, up to 4
## rounds, can stay tied), college (the 25; two-point tries from round 3, no
## kicks, never tied), pro (one 10-minute period, both get the ball unless the
## first scores a touchdown, then sudden death; can stay tied). Overtime kicks
## are high pressure; a game-winning overtime field goal is labeled and counts
## as a game winner; the benched backup kicks overtime field goals.

const KT := "res://tuning/kick_tuning.tres"
var t := CareerTuning.get_default()


## A game skipped to the end of regulation, tied. rule: hs / college / pro.
func _tied_sim(rule: String, seed_n: int, backup_fg := false) -> GameSim:
	var c := CareerData.create("OT Test", t)
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var sim := GameSim.new()
	var e := {"opponent": Progression.team_from(CareerContent.high_schools()[1], CareerData.STAGE_HIGH_SCHOOL),
		"home": true, "weather": {}}
	var params := {"fg_min": 25, "fg_max": 50, "pat": 20, "pressure_bonus": 0.0, "ot": rule}
	sim.backup_fg = backup_fg
	sim.setup(c, e, t, seed_n, 60, params)
	sim._queue.clear()
	sim._drive_i = sim._drives.size()
	sim.score_us = 14
	sim.score_them = 14
	sim.elapsed = t.quarter_minutes * 60.0 * 4.0
	return sim


## Plays the overtime out: our kicks made with `make`. Returns the calls seen.
func _play(sim: GameSim, make: bool) -> Array:
	var calls: Array = []
	for i in 400:
		var ev := sim.next()
		match str(ev.get("type", "")):
			"end":
				break
			"call":
				calls.append(ev)
				match str(ev["kind"]):
					"fg", "pat":
						sim.resolve_call({"made": make})
					"kickoff":
						sim.resolve_call({"quality": 0.5, "carry": 50.0, "text": "K"})
					"onside":
						sim.resolve_call({"recovered": false, "text": "O"})
			"warmup":
				sim.set_warmup("pure")
	return calls


func test_high_school_kansas_plan() -> void:
	var ties := 0
	var saw_fg := false
	for seed_n in 60:
		var sim := _tied_sim("hs", seed_n)
		var calls := _play(sim, seed_n % 3 != 0)
		check(sim.finished, "the game ends")
		check(calls.all(func(c: Dictionary) -> bool: return str(c["kind"]) != "kickoff"), "no kickoffs in overtime")
		for c in calls:
			if str(c["kind"]) == "fg":
				saw_fg = true
				check(absi(int(c["yards"]) - t.ot_hs_fg_yards) <= 2, "field goals from about the 10 (%d)" % int(c["yards"]))
			check(float(c["pressure"]) >= t.ot_pressure - 0.001, "overtime kicks are high pressure")
			check(str(c["label"]).contains("OT"), "labeled overtime")
		var s := sim.summary()
		check(int(s["ot"]["rounds"]) <= t.ot_hs_rounds, "at most %d rounds" % t.ot_hs_rounds)
		if s["outcome"] == "T":
			ties += 1
			eq(int(s["ot"]["rounds"]), t.ot_hs_rounds, "a tie only after the last round")
	check(saw_fg, "short overtime field goals happen")
	check(ties < 30, "ties are rare (%d of 60)" % ties)


func test_college_two_point_from_round_three_and_no_ties() -> void:
	var saw_two_point := false  # (rare by chance; test_no_kicks_in_two_point_rounds forces it)
	for seed_n in 80:
		var sim := _tied_sim("college", seed_n)
		var calls := _play(sim, false)  # every kick missed: longer overtimes
		var s := sim.summary()
		check(s["outcome"] != "T", "college overtime never ends tied")
		for c in calls:
			if str(c["kind"]) == "fg":
				check(absi(int(c["yards"]) - t.ot_college_fg_yards) <= 2, "field goals from the 25 (%d)" % int(c["yards"]))
		if bool(s["ot"]["two_point"]):
			saw_two_point = true
			check(int(s["ot"]["rounds"]) >= 3, "two-point tries start in round 3")
		else:
			check(int(s["ot"]["rounds"]) <= 2, "rounds 1-2 kick")


func test_no_kicks_in_two_point_rounds() -> void:
	for seed_n in 40:
		var sim := _tied_sim("college", seed_n)
		sim.next()  # overtime starts
		# Both teams have had the ball twice, still tied: round 3 is next.
		sim.ot["round"] = 2
		sim.ot["idx"] = 2
		var kicked := false
		for i in 400:
			var ev := sim.next()
			if ev["type"] == "end":
				break
			if ev["type"] == "call":
				kicked = true
				sim.resolve_call({"made": true})
		check(not kicked, "the kicker sits out the two-point rounds")
		check(bool(sim.ot["two_point"]), "two-point tries from round 3")
		check(sim.summary()["outcome"] != "T", "and no ties")


func test_pro_one_period() -> void:
	var ties := 0
	for seed_n in 80:
		var sim := _tied_sim("pro", seed_n)
		var calls := _play(sim, seed_n % 2 == 0)
		check(sim.finished, "the game ends")
		check(float(sim.ot["clock"]) >= 0.0, "within the period")
		for c in calls:
			check(str(c["label"]).begins_with("OT "), "pro labels carry the clock (%s)" % c["label"])
		if sim.summary()["outcome"] == "T":
			ties += 1
	check(ties > 0 and ties < 40, "pro overtime can end tied, sometimes (%d of 80)" % ties)


func test_game_winner_label_and_rewards() -> void:
	var found := false
	for seed_n in 120:
		var sim := _tied_sim("hs", seed_n)
		var calls := _play(sim, true)
		for c in calls:
			if str(c["label"]).contains("GAME WINNER"):
				found = true
				eq(float(c["pressure"]), t.game_winner_pressure, "full pressure")
				eq(str(sim.summary()["outcome"]), "W", "a made overtime game winner wins")
				var sp := SkillPoints.from_game(sim.kicks, 50.0, t)
				check(sp.any(func(p: Array) -> bool: return str(p[0]) == "Game winner"), "it pays game-winner skill points")
		if found:
			break
	check(found, "an overtime game winner happens")


func test_backup_kicks_overtime_field_goals() -> void:
	for seed_n in 40:
		var sim := _tied_sim("hs", seed_n, true)
		var calls := _play(sim, true)
		check(calls.all(func(c: Dictionary) -> bool: return str(c["kind"]) != "fg"), "you're never called for a field goal")
		for k in sim.kicks:
			if str(k["kind"]) == "fg":
				check(k.get("backup", false), "the backup kicked it")


func test_regulation_ties_go_to_overtime_and_text() -> void:
	var sim := _tied_sim("pro", 3)
	sim.next()
	check(sim.in_overtime(), "a tie after four quarters starts overtime")
	check(CareerManager.ot_rule_text("hs", t).contains("10"), "high school rule text")
	check(CareerManager.ot_rule_text("college", t).contains("two-point"), "college rule text")
	check(CareerManager.ot_rule_text("pro", t).contains("tied"), "pro rule text")
	eq(CareerManager.ot_tag({"ot": {"rule": "college", "rounds": 3}}), "(3OT)", "result tag")
	eq(CareerManager.ot_tag({}), "", "no overtime, no tag")
