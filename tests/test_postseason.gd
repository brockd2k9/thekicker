extends "res://tests/test_case.gd"
## Postseason (PostseasonConfig / Postseason): qualifying by record, the
## bracket appended week by week, win advances / loss ends the season, no ties,
## more pressure, stats and flags.

const SIM := preload("res://tools/career_sim.gd")

var t := CareerTuning.get_default()


func _manager(stage := CareerData.STAGE_HIGH_SCHOOL) -> CareerManager:
	var c := CareerData.create("Post Test", t)
	match stage:
		CareerData.STAGE_COLLEGE:
			c.team = Progression.team_from(CareerContent.colleges()[0], stage)
		CareerData.STAGE_PRO:
			c.team = Progression.team_from(CareerContent.pro_clubs()[0], stage)
		_:
			c.team = Progression.team_from(CareerContent.high_schools()[0], stage)
	c.stage = stage
	var m := CareerManager.new(c)
	m.rng.seed = 7
	m._start_season(false)
	return m


## Plays out the regular season on paper: the record, then the week past it.
func _end_regular(m: CareerManager, w: int, l: int) -> Dictionary:
	m.data.record = {"w": w, "l": l, "t": 0}
	m.data.week = m.weeks_in_season() + 1
	return Postseason.advance(m.data, m.rng, t)


## Finishes the current (postseason) week with this result and advances.
func _play(m: CareerManager, outcome: String) -> Dictionary:
	var e := m.entry()
	e["result"] = {"us": 24 if outcome == "W" else 10, "them": 10 if outcome == "W" else 24, "outcome": outcome}
	m.data.week += 1
	return Postseason.advance(m.data, m.rng, t)


func test_qualifying_by_record() -> void:
	var g := Postseason.config()
	var hs := _manager()
	hs.data.record = {"w": 6, "l": 4, "t": 0}
	eq(Postseason.qualify(hs.data), "playoff" if 0.6 >= g.hs_playoff_min else "", "HS 6-4")
	hs.data.record = {"w": 3, "l": 7, "t": 0}
	eq(Postseason.qualify(hs.data), "", "HS 3-7 stays home")
	var col := _manager(CareerData.STAGE_COLLEGE)
	col.data.record = {"w": 10, "l": 0, "t": 0}
	eq(Postseason.qualify(col.data), "playoff", "college: strong -> playoff")
	col.data.record = {"w": 6, "l": 4, "t": 0}
	eq(Postseason.qualify(col.data), "bowl", "college: decent -> bowl")
	col.data.record = {"w": 2, "l": 8, "t": 0}
	eq(Postseason.qualify(col.data), "", "college: weak -> season over")
	var pro := _manager(CareerData.STAGE_PRO)
	pro.data.record = {"w": 9, "l": 1, "t": 0}
	eq(Postseason.qualify(pro.data), "playoff", "pro: playoffs")
	pro.data.record = {"w": 1, "l": 9, "t": 0}
	eq(Postseason.qualify(pro.data), "", "pro: miss -> season over")
	eq(Postseason.win_share({"w": 5, "l": 4, "t": 1}), 0.55, "ties count half")


func test_missing_the_postseason_ends_the_season() -> void:
	var m := _manager()
	var size := m.weeks_in_season()
	var out := _end_regular(m, 2, 8)
	eq(out["event"], "missed", "missed")
	eq(m.weeks_in_season(), size, "no game added")
	check(m.data.flags.get("missed_postseason", false), "flag missed_postseason")
	check(not m.data.flags.get("made_playoffs", false), "not made_playoffs")


func test_winning_every_round_wins_the_title() -> void:
	var m := _manager()
	var regular := m.weeks_in_season()
	var sp := m.data.skill_points
	var out := _end_regular(m, 9, 1)
	eq(out["event"], "qualified", "qualified")
	check(m.data.flags.get("made_playoffs", false) and m.data.flags.get("in_postseason", false), "flags set")
	eq(m.weeks_in_season(), regular + 1, "one game added")
	check(m.is_postseason(), "this week is a postseason game")
	eq(m.regular_weeks(), regular, "regular weeks unchanged")
	var names := Postseason.rounds(m.data, "playoff")
	for i in names.size():
		eq(str(m.entry()["round_name"]), names[i], "round %d" % i)
		eq(bool(m.entry()["final"]), i == names.size() - 1, "final only last")
		check(m.data.flags.get("championship_game", false) == (i == names.size() - 1), "championship_game flag")
		out = _play(m, "W")
	eq(out["event"], "champion", "champions")
	eq(m.weeks_in_season(), regular + names.size(), "one week per round")
	check(m.data.week > m.weeks_in_season(), "season is over after the final")
	check(m.data.flags.get("won_championship", false), "won_championship")
	check(not m.data.flags.get("in_postseason", true), "no longer in the postseason")
	var car := Postseason.career(m.data)
	eq(int(car["titles"]), 1, "title counted")
	eq(int(car["appearances"]), 1, "appearance counted")
	eq(int(car["wins"]), names.size(), "postseason wins")
	eq(m.data.metric("championships"), 1.0, "metric championships")
	eq(m.data.metric("playoff_appearances"), 1.0, "metric playoff_appearances")
	eq(m.data.skill_points - sp, Postseason.config().title_skill_points, "title skill points")
	eq(int(m.data.record["w"]), 9, "regular record untouched")


func test_a_loss_ends_the_season() -> void:
	var m := _manager()
	_end_regular(m, 8, 2)
	_play(m, "W")
	var size := m.weeks_in_season()
	var out := _play(m, "L")
	eq(out["event"], "eliminated", "eliminated")
	eq(m.weeks_in_season(), size, "nothing added")
	check(m.data.week > m.weeks_in_season(), "season over")
	check(m.data.flags.get("eliminated", false), "eliminated flag")
	eq(Postseason.summary_text(m.data.postseason), "Lost in the %s" % Postseason.rounds(m.data, "playoff")[1],
		"summary")
	eq(int(Postseason.career(m.data)["losses"]), 1, "loss counted")


func test_college_bowl_is_one_game() -> void:
	var m := _manager(CareerData.STAGE_COLLEGE)
	var out := _end_regular(m, 6, 4)
	eq(out["event"], "qualified", "bowl bound")
	check(m.data.flags.get("bowl_game", false), "bowl_game flag")
	check(bool(m.entry()["final"]), "the bowl is the only game")
	check(str(m.entry()["round_name"]).ends_with("Bowl"), "a bowl name: " + str(m.entry()["round_name"]))
	out = _play(m, "W")
	eq(out["event"], "bowl_won", "bowl won")
	check(not m.data.flags.get("won_championship", false), "a bowl isn't the title")
	eq(int(Postseason.career(m.data)["bowl_wins"]), 1, "bowl win counted")


func test_postseason_params_no_ties_and_more_pressure() -> void:
	var m := _manager()
	var base := Progression.game_params(m.data, t)
	_end_regular(m, 9, 1)
	var p := m.game_params()
	check(p.get("no_tie", false), "no ties")
	check(float(p["pressure_bonus"]) > float(base["pressure_bonus"]), "more pressure")
	var final := {"type": "playoff", "round": 3, "final": true}
	var first := {"type": "playoff", "round": 0, "final": false}
	check(float(Postseason.adjust_params(base.duplicate(), final)["pressure_bonus"]) >
		float(Postseason.adjust_params(base.duplicate(), first)["pressure_bonus"]), "the final is the biggest")
	eq(Postseason.adjust_params(base.duplicate(), {"type": "regular"}), base, "regular weeks unchanged")


## Postseason games never end tied (high school and pro overtime would).
func test_game_sim_no_ties() -> void:
	for stage in [CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_PRO, CareerData.STAGE_COLLEGE]:
		var m := _manager(stage)
		var params := Progression.game_params(m.data, t)
		params["no_tie"] = true
		var ties := 0
		var ots := 0
		for seed in 300:
			var sim := GameSim.new()
			sim.setup(m.data, {"opponent": m.data.team.duplicate(), "home": true}, t, seed, 60, params)
			var r := RandomNumberGenerator.new()
			r.seed = seed
			_auto(sim, r)
			ots += 0 if sim.ot.is_empty() else 1
			if sim.outcome() == "T":
				ties += 1
		eq(ties, 0, "%s: no ties" % stage)
		check(ots > 0, "%s: overtime happened (%d)" % [stage, ots])


func _auto(sim: GameSim, r: RandomNumberGenerator) -> void:
	for i in 3000:
		var e := sim.next()
		match str(e.get("type", "")):
			"end":
				return
			"warmup":
				sim.set_warmup("loose")
			"call":
				match str(e["kind"]):
					"fg", "pat":
						sim.resolve_call({"made": r.randf() < 0.7})
					"kickoff":
						sim.resolve_call({"quality": 0.5, "carry": 45.0, "text": "Kickoff."})
					"onside":
						sim.resolve_call({"recovered": false, "text": "Onside."})


func test_postseason_game_counts_in_kicking_stats_not_record() -> void:
	var m := _manager()
	_end_regular(m, 8, 2)
	m.data.phase = CareerManager.PHASE_GAME
	var games := int(m.data.season_stats.get("games", 0))
	m.finish_game({"outcome": "W", "us": 17, "them": 14, "kicks": [
		{"kind": "fg", "yards": 41, "made": true, "pressure": 0.9, "label": "GAME WINNER"}]})
	eq(int(m.data.record["w"]), 8, "regular record unchanged")
	eq(int(m.data.season_stats["games"]), games + 1, "game counted in season stats")
	eq(int(m.data.season_stats["fg_made"]), 1, "the kick counted")
	eq(int(m.data.season_stats["long"]), 41, "longest FG")
	eq(str(m.data.last_week.get("postseason", "")), Postseason.rounds(m.data, "playoff")[0], "Results knows the round")
	m.end_week()
	eq(m.data.phase, CareerManager.PHASE_WEEK_START, "won: next round is next week")
	check(m.is_postseason() and int(m.entry()["round"]) == 1, "round 2 scheduled")


func test_save_round_trip_and_old_saves() -> void:
	var m := _manager()
	_end_regular(m, 9, 1)
	var back := CareerData.from_dict(m.data.to_dict())
	eq(back.postseason.get("kind", ""), "playoff", "postseason saved")
	eq(int(back.postseason_career.get("appearances", 0)), 1, "career totals saved")
	var d := m.data.to_dict()
	d.erase("postseason")
	d.erase("postseason_career")
	var old := CareerData.from_dict(d)
	eq(old.metric("championships"), 0.0, "old save: no titles")
	eq(Postseason.summary_text(old.postseason), "", "old save: nothing to show")


func test_engine_flags_are_declared() -> void:
	for f in Postseason.SEASON_FLAGS:
		check(f in CareerContent.ENGINE_FLAGS, "%s is an engine flag" % f)
	for k in ["playoff_appearances", "championships", "postseason_wins"]:
		check(k in CareerData.METRICS, "%s is a metric" % k)


func test_season_end_records_postseason_and_new_season_resets() -> void:
	var m := _manager()
	_end_regular(m, 9, 1)
	for i in Postseason.rounds(m.data, "playoff").size():
		_play(m, "W")
	m.data.phase = CareerManager.PHASE_SEASON_END
	var rec := m.data.recruiting_score
	m.end_season()
	var h: Dictionary = m.data.history.back()
	eq(str(h["postseason"]["status"]), "champion", "history has the postseason")
	check(str(h["postseason_text"]).begins_with("Won the"), "and a line for it")
	check(m.data.recruiting_score > rec, "recruiting rose")
	m._start_season(true)
	eq(m.data.postseason, {}, "new season: undecided")
	check(not m.data.flags.get("won_championship", true), "season flags reset")
	eq(m.data.metric("championships"), 1.0, "career title kept")


## A real season through the CareerManager loop (simulated kicks): the
## schedule only grows by postseason weeks, and the season always ends.
func test_full_seasons_through_the_loop() -> void:
	var made := 0
	for seed in [1, 2, 3, 4, 5, 6]:
		var sim: Node = SIM.new()
		sim._kt = load("res://tuning/kick_tuning.tres")
		sim._rng.seed = seed
		var m := _manager()
		m.data.team["strength"] = 85.0
		m.rng.seed = seed
		var guard := 0
		while m.data.phase != CareerManager.PHASE_SEASON_END and guard < 500:
			guard += 1
			match m.data.phase:
				CareerManager.PHASE_WEEK_START:
					m.begin_week()
				CareerManager.PHASE_SCENARIO:
					m.choose(sim._choose(m.data, m.current_scenario(), "mixed", m.tuning))
				CareerManager.PHASE_OUTLOOK:
					m.start_game()
				CareerManager.PHASE_GAME:
					m.finish_game(sim._play_game(m))
				CareerManager.PHASE_TRYOUT:
					m.finish_tryout(sim._tryout(m.data))
				CareerManager.PHASE_RESULTS:
					m.end_week()
				_:
					break
		eq(m.data.phase, CareerManager.PHASE_SEASON_END, "seed %d: season ended" % seed)
		var status := str(m.data.postseason.get("status", ""))
		check(status in ["missed", "eliminated", "champion"], "seed %d: postseason decided (%s)" % [seed, status])
		var post := m.data.schedule.filter(func(e: Dictionary) -> bool: return Postseason.is_postseason(e))
		for e in post:
			check(e.get("result") is Dictionary, "seed %d: every postseason game was played" % seed)
			check(str(e["result"]["outcome"]) != "T", "seed %d: no ties" % seed)
		if status != "missed":
			made += 1
		sim.free()
	check(made > 0, "a strong team makes the playoffs sometimes (%d/6)" % made)
