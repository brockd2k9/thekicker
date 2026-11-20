extends "res://tests/test_case.gd"
## Kick challenges (KickChallenge): every proposed conversion is valid and
## plays a pass and a fail; distances clamp to range - 1; the choice's own
## effects come first; no game skill points, trust or season stats; the
## perfect-challenge bonus; resuming after a reload (kicks saved one by one,
## seeded wind, a kick struck mid-flight is a miss) for challenges, the bench
## audition and stage tryouts; kickoffs; the offseason.

var t := CareerTuning.get_default()


func _career(stage := CareerData.STAGE_HIGH_SCHOOL) -> CareerManager:
	var c := CareerData.create("Challenge Test", t)
	c.created = 1794983149
	c.slot = 0
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c, t)
	m.rng.seed = 3
	m._start_season(false)
	if stage != CareerData.STAGE_HIGH_SCHOOL:
		c.stage = stage
		c.team = Progression.team_from(CareerContent.colleges()[0], stage)
		Relationships.enter_stage(c, t)
	c.set_stat("power", 80.0)  # a range past every proposed distance
	return m


func _conversions() -> Array:
	return fixture("kick_challenge_conversions.json").get("conversions", [])


## Puts conversion `conv` into its scenario (in memory) and runs `body`, then restores it.
func _with(conv: Dictionary, body: Callable) -> void:
	var s := CareerContent.scenario(str(conv["scenario"]))
	check(not s.is_empty(), "scenario %s exists" % conv["scenario"])
	if s.is_empty():
		return
	var i := int(conv["choice"])
	var keep: Dictionary = (s["choices"][i] as Dictionary).duplicate(true)
	s["choices"][i] = (conv["replace"] as Dictionary).duplicate(true)
	body.call(s)
	s["choices"][i] = keep


## Picks the converted choice and takes the kicks: `makes` made, the rest missed.
func _play(m: CareerManager, conv: Dictionary, makes: int) -> void:
	var c := m.data
	c.pending_scenarios = [str(conv["scenario"])]
	c.phase = CareerManager.PHASE_SCENARIO
	m.choose(int(conv["choice"]))
	var n := TryoutMode.total_kicks(c.tryout)
	for k in n:
		m.tryout_kick(k < makes)
	m.finish_tryout(0)


func test_conversions_are_valid() -> void:
	for conv in _conversions():
		var where := "%s choice %d" % [conv["scenario"], int(conv["choice"])]
		var probs := KickChallenge.problems(where, conv["replace"])
		var kc: Dictionary = conv["replace"]["kick_challenge"]
		for b in ["on_pass", "on_fail"]:
			CareerContent._check_block(probs, where + " " + b, kc[b])
		CareerContent._check_followers(probs, where, conv["replace"])
		eq(", ".join(probs), "", where + " has no problems")
		_with(conv, func(s: Dictionary) -> void:
			var set := CareerContent._flags_set(s)
			for f in s.get("expected_flags", []):
				check(f in set, "%s still sets expected flag %s" % [where, f]))
	check(_conversions().size() >= 9, "nine conversions")


func test_every_conversion_passes_and_fails() -> void:
	for conv in _conversions():
		var stage := CareerData.STAGE_COLLEGE if str(conv["scenario"]).begins_with("col_") else CareerData.STAGE_HIGH_SCHOOL
		_with(conv, func(_s: Dictionary) -> void:
			var kc: Dictionary = conv["replace"]["kick_challenge"]
			var ok := _career(stage)
			var rec := ok.data.recruiting_score + ok.data.draft_score
			_play(ok, conv, TryoutMode.total_kicks({"distances": kc["distances"], "kickoffs": kc.get("kickoffs", {})}))
			check(ok.data.last_challenge.get("passed", false), "%s: all made passes" % conv["scenario"])
			eq(str(ok.data.last_challenge["out"]["result"]), str(kc["on_pass"]["result"]), "%s: pass result" % conv["scenario"])
			check(ok.data.recruiting_score + ok.data.draft_score >= rec, "%s: pass progress" % conv["scenario"])
			check(ok.data.phase != CareerManager.PHASE_TRYOUT, "%s: back to the week" % conv["scenario"])
			var bad := _career(stage)
			_play(bad, conv, 0)
			check(not bad.data.last_challenge.get("passed", true), "%s: none made fails" % conv["scenario"])
			eq(str(bad.data.last_challenge["out"]["result"]), str(kc["on_fail"]["result"]), "%s: fail result" % conv["scenario"]))


func test_choice_effects_first_then_the_kicks() -> void:
	var conv: Dictionary = _conversions()[0]  # hs_showcase
	_with(conv, func(_s: Dictionary) -> void:
		var m := _career()
		var c := m.data
		var energy := c.stat("energy")
		var rec := c.recruiting_score
		c.pending_scenarios = ["hs_showcase", "hs_kicker_battle"]
		c.phase = CareerManager.PHASE_SCENARIO
		var out := m.choose(0)
		check(out.get("challenge", false), "choose says it's a challenge")
		eq(c.phase, CareerManager.PHASE_TRYOUT, "to the kick scene")
		check(c.stat("energy") < energy, "the choice's own Energy cost applies now")
		eq(c.recruiting_score, rec, "no reward before the kicks")
		eq(str(c.tryout["purpose"]), "challenge", "purpose")
		eq(str(c.tryout["return_phase"]), CareerManager.PHASE_SCENARIO, "returns to the scenarios")
		eq(int(c.scenario_log["hs_showcase"]["times"]), 1, "logged once")
		for k in 5:
			m.tryout_kick(k < 3)
		m.finish_tryout(0)
		eq(c.phase, CareerManager.PHASE_SCENARIO, "the next scenario this week")
		eq(c.pending_scenarios, ["hs_kicker_battle"], "still pending")
		eq(c.recruiting_score, rec + 6.0 * t.scenario_recruiting_scale, "on_pass recruiting (scaled)"))


func test_distances_clamp_to_range() -> void:
	var kc := {"distances": [30, 40, 50, 55], "need": 2}
	eq(KickChallenge.distances(kc, 44.6, t), [30, 40, 43, 43], "range - 1")
	eq(KickChallenge.distances({"distances": [18, 30]}, 25.0, t), [20, 24], "never under challenge_min_yards")
	var m := _career()
	m.data.set_stat("power", 0.0)
	var conv: Dictionary = _conversions()[1]  # the big showcase camp, 35-50
	_with(conv, func(_s: Dictionary) -> void:
		m.data.pending_scenarios = ["hs_scholarship_camp"]
		m.data.phase = CareerManager.PHASE_SCENARIO
		m.choose(0)
		var cap := floori(m.profile().fg_range + 0.001) - 1
		check((m.data.tryout["distances"] as Array).all(func(d: Variant) -> bool: return int(d) <= cap),
			"a weak leg never faces kicks past its range"))


func test_no_game_sp_trust_or_season_stats() -> void:
	var conv: Dictionary = _conversions()[0]
	_with(conv, func(_s: Dictionary) -> void:
		var m := _career()
		var c := m.data
		var coach := Relationships.value(c, "coach")
		var team := Relationships.value(c, Relationships.TEAM)
		var fg := int(c.season_stats.get("fg_att", 0))
		_play(m, conv, 3)
		eq(Relationships.value(c, "coach"), coach, "Coach unchanged (no rel in this scenario)")
		eq(Relationships.value(c, Relationships.TEAM), team, "Team unchanged")
		eq(int(c.season_stats.get("fg_att", 0)), fg, "season stats untouched")
		check(not c.sp_sources.has("Field goals made"), "no game skill points")
		check(not c.sp_sources.has(KickChallenge.SP_SOURCE), "not perfect: no challenge bonus")
		check(c.recent_fg.is_empty(), "the trust window never sees challenge kicks"))


func test_perfect_challenge_bonus() -> void:
	var conv: Dictionary = _conversions()[0]
	_with(conv, func(_s: Dictionary) -> void:
		var m := _career()
		var c := m.data
		c.set_stat("charisma", 0.0)
		_play(m, conv, 5)
		check(c.last_challenge.get("perfect", false), "perfect")
		eq(int(c.sp_sources.get(KickChallenge.SP_SOURCE, 0)), t.sp_perfect_challenge, "+1 skill point, source Challenge")
		eq(int(c.last_challenge["out"]["skill_points"]), 2 + t.sp_perfect_challenge, "on_pass SP + the bonus")
		var fans := roundi(4 * t.followers_per_buzz_hs) + roundi(t.buzz_perfect_challenge * t.followers_per_buzz_hs)
		eq(int(c.last_challenge["out"]["followers"]), fans, "on_pass followers + the perfect bonus"))


func test_default_followers_by_kind() -> void:
	var conv: Dictionary = _conversions()[4].duplicate(true)  # HS_121: no followers in on_pass
	_with(conv, func(_s: Dictionary) -> void:
		var m := _career()
		m.data.set_stat("charisma", 0.0)
		_play(m, conv, 3)
		eq(int(m.data.last_challenge["out"]["followers"]), roundi(t.buzz_challenge_camp * t.followers_per_buzz_hs),
			"a camp pass gets the camp default"))


func test_resume_after_reload() -> void:
	var conv: Dictionary = _conversions()[0]
	_with(conv, func(_s: Dictionary) -> void:
		var m := _career()
		var c := m.data
		c.pending_scenarios = ["hs_showcase"]
		c.phase = CareerManager.PHASE_SCENARIO
		m.choose(0)
		m.tryout_kick(true)
		m.tryout_kick(false)
		var wind := TryoutMode.from_tryout(c.tryout).wind_for(2)
		# "Quit": reload from the saved dictionary.
		var again := CareerManager.new(CareerData.from_dict(CareerSave._migrate(c.to_dict())), t)
		var mode := TryoutMode.from_tryout(again.data.tryout)
		eq(mode.kicks, 2, "continues at kick 3")
		eq(mode.makes, 1, "with the makes so far")
		eq(mode.wind_for(2), wind, "the same wind for kick 3")
		# The ball is in the air when the game quits: a miss.
		again.tryout_struck()
		var third := CareerManager.new(CareerData.from_dict(CareerSave._migrate(again.data.to_dict())), t)
		third.tryout_resume()
		eq((third.data.tryout["results"] as Array), [true, false, false], "a struck kick is a miss")
		third.tryout_resume()
		eq((third.data.tryout["results"] as Array).size(), 3, "only once"))


func test_audition_and_tryouts_resume_too() -> void:
	var m := _career()
	var c := m.data
	c.bench = {"weeks_left": 0, "audition_due": true, "backup": Bench.BACKUP}
	m.start_audition()
	m.tryout_kick(true)
	m.tryout_struck()
	m.tryout_resume()
	eq(c.tryout["results"], [true, false], "audition: the struck kick is a miss")
	eq(TryoutMode.from_tryout(c.tryout).kicks, 2, "and resumes at kick 3")
	for k in 3:
		m.tryout_kick(true)
	m.finish_tryout(0)  # the screen's count is ignored: the saved kicks decide
	eq(str(c.bench["last_audition"]["result"]), "passed", "4 of 5 made")
	var w := _career()
	w.start_tryout("walk_on", str(CareerContent.colleges()[0]["id"]))
	w.tryout_kick(false)
	w.tryout_struck()
	w.tryout_resume()
	eq(w.data.tryout["results"], [false, false], "stage tryouts too")


func test_kickoffs() -> void:
	var tr := {"distances": [40, 45], "kickoffs": {"count": 2, "min_yards": 65}, "results": [true]}
	eq(TryoutMode.total_kicks(tr), 4, "field goals + kickoffs")
	check(not TryoutMode.needs_tee(tr), "field goals first")
	tr["results"] = [true, false]
	check(TryoutMode.needs_tee(tr), "then the tee scene")
	var mode := TryoutMode.from_tryout(tr, true)
	check(mode.wants_next_kick(), "kickoffs left")
	check(TryoutMode.kickoff_good({"carry": 66.0, "result": "returned"}, 65.0), "carry counts")
	check(TryoutMode.kickoff_good({"carry": 50.0, "result": "touchback"}, 65.0), "a touchback counts")
	check(not TryoutMode.kickoff_good({"carry": 50.0, "result": "returned"}, 65.0), "short and returned")
	check(not TryoutMode.kickoff_good({"carry": 58.0, "result": "deep"}, 65.0), "deep but short of min_yards")


func test_offseason_challenge_continues_the_offseason() -> void:
	var conv: Dictionary = _conversions()[1]  # hs_scholarship_camp is an offseason scenario
	_with(conv, func(_s: Dictionary) -> void:
		var m := _career()
		var c := m.data
		var season := c.season
		c.pending_scenarios = ["hs_scholarship_camp"]
		c.phase = CareerManager.PHASE_OFFSEASON
		m.choose(0)
		eq(str(c.tryout["return_phase"]), CareerManager.PHASE_OFFSEASON, "remembers the offseason")
		check(bool(c.flags.get("camp_showcase", false)), "the story flag is set when you pick it")
		for k in 5:
			m.tryout_kick(false)
		m.finish_tryout(0)
		eq(c.season, season + 1, "the offseason ends into the next season")
		eq(c.phase, CareerManager.PHASE_WEEK_START, "week 1"))


func test_validation_catches_mistakes() -> void:
	var bad := {"label": "x", "kick_challenge": {"kind": "dance", "distances": [10], "need": 9, "pressure": "huge",
		"on_pass": {"stats": {}, "coins": 3}}}
	var p := KickChallenge.problems("x", bad)
	var all := ", ".join(p)
	for what in ["kind", "distances", "need", "pressure", "on_fail", "result", "coins"]:
		check(what in all, "reports " + what)
