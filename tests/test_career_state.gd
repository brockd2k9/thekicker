extends "res://tests/test_case.gd"
## Readable career state for scenario writers: "right now" metrics, game-set
## flags (contract_year, re_signed, released, signed_new_club, pro_clubs),
## {club} / {town}, once_per_club, the "dismissed" flag, and engine state
## winning over cleared story flags.

var t := CareerTuning.get_default()


func _career(stage := CareerData.STAGE_HIGH_SCHOOL) -> CareerManager:
	var c := CareerData.create("State Test", t)
	c.created = 1794983149
	c.slot = 0
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c, t)
	m.rng.seed = 9
	m._start_season(false)
	if stage != CareerData.STAGE_HIGH_SCHOOL:
		c.stage = stage
		c.team = Progression.team_from(CareerContent.colleges()[0], stage)
		Relationships.enter_stage(c, t)
	return m


func test_right_now_metrics() -> void:
	var m := _career()
	var c := m.data
	eq(c.metric("slump_now"), 0.0, "no slump")
	c.coach_doubt = {"weeks_left": 2, "reason": "x"}
	eq(c.metric("slump_now"), 1.0, "slump")
	c.bench = {"weeks_left": 1}
	eq(c.metric("benched_now"), 1.0, "benched")
	c.injury = {"weeks_left": 2, "severity": 0.4}
	eq(c.metric("injured_now"), 1.0, "injured")
	c.season_stats = {"fg_att": 10, "fg_made": 7}
	eq(c.metric("season_fg_pct"), 70.0, "season FG% (0-100)")
	c.season_stats = {"fg_att": 0, "fg_made": 0}
	eq(c.metric("season_fg_pct"), 0.0, "no attempts: 0")
	check(ScenarioEngine.requirements_met(c, {"min": {"injured_now": 1}}), "requires min reads it")
	check(not ScenarioEngine.requirements_met(c, {"max": {"slump_now": 0}}), "requires max reads it")


func test_fg_streak() -> void:
	var m := _career()
	var c := m.data
	c.phase = CareerManager.PHASE_GAME
	m.finish_game({"outcome": "W", "us": 9, "them": 3, "kicks": [{"kind": "fg", "made": true, "yards": 30},
		{"kind": "fg", "made": true, "yards": 33}, {"kind": "pat", "made": false}]})
	eq(c.metric("fg_streak"), 2.0, "+2 makes in a row (extra points don't count)")
	c.phase = CareerManager.PHASE_GAME
	m.finish_game({"outcome": "L", "us": 0, "them": 3, "kicks": [{"kind": "fg", "made": false, "yards": 40}]})
	eq(c.metric("fg_streak"), -1.0, "a miss starts a cold streak")


func test_pro_flags_and_clubs() -> void:
	var m := _career(CareerData.STAGE_COLLEGE)
	var c := m.data
	var clubs := CareerContent.pro_clubs()
	m._enter_stage(CareerData.STAGE_PRO, Progression.team_from(clubs[0], CareerData.STAGE_PRO), "x")
	eq(c.metric("clubs"), 1.0, "one club")
	check(not c.flags.get("signed_new_club", false), "the first club isn't a new club")
	c.contract = {"years_left": 1, "team": str(clubs[0]["id"])}
	m._start_season(true)
	check(c.flags["contract_year"], "a season with 1 year left is a contract year")
	c.contract["status"] = "resign"
	c.contract["offer"] = {"years": 2, "salary": 900000}
	c.phase = CareerManager.PHASE_CONTRACT
	m.contract_continue()
	check(c.flags["re_signed"], "re-signed")
	eq(c.metric("contract_years_left"), 2.0, "contract years left")
	c.season += 1
	m._start_season(true)
	check(c.flags["re_signed"], "still true the season after re-signing")
	c.season += 1
	m._start_season(true)
	check(not c.flags["re_signed"], "then it clears")
	c.history.append({"stage": CareerData.STAGE_PRO, "team": str(clubs[0]["name"])})
	eq(c.metric("pro_seasons"), 1.0, "pro seasons")
	c.contract["status"] = "released"
	c.phase = CareerManager.PHASE_CONTRACT
	m.contract_continue()
	check(c.flags["released"], "released")
	m._enter_stage(CareerData.STAGE_PRO, Progression.team_from(clubs[1], CareerData.STAGE_PRO), "y")
	check(c.flags["signed_new_club"], "a second club is a new club")
	eq(c.metric("clubs"), 2.0, "two clubs")


func test_club_and_town_placeholders() -> void:
	var c := _career().data
	var v := Relationships.text_vars(c)
	eq(str(v["club"]), str(c.team["name"]), "{club} is the school in high school")
	eq(CareerContent.fill("Welcome to {town}.", v), "Welcome to %s." % c.team.get("town", ""), "{town}")


func test_once_per_club() -> void:
	var m := _career(CareerData.STAGE_COLLEGE)
	var c := m.data
	var s := {"id": "test_arrival", "once_per_club": true, "stages": [c.stage]}
	check(ScenarioEngine.is_eligible(c, s, "season", t), "never seen")
	c.scenario_log["test_arrival"] = {"times": 1, "clubs": [ScenarioEngine._club_key(c)]}
	check(not ScenarioEngine.is_eligible(c, s, "season", t), "seen at this club")
	c.team = Progression.team_from(CareerContent.colleges()[1], c.stage)
	check(ScenarioEngine.is_eligible(c, s, "season", t), "a new club: again")
	c.scenario_log["test_arrival"] = {"times": 1}
	check(not ScenarioEngine.is_eligible(c, s, "season", t), "an old log entry counts as seen here")


func test_engine_state_wins_over_cleared_flags() -> void:
	var m := _career()
	var c := m.data
	c.coach_doubt = {"weeks_left": 2, "reason": "x"}
	c.flags["kicking_slump"] = false  # a scene "clears" it mid-slump
	m._sync_flags()
	check(c.flags["kicking_slump"], "still in a slump: the flag comes back")
	c.coach_doubt = {}
	c.flags["kicking_slump"] = false
	m._sync_flags()
	check(not c.flags["kicking_slump"], "after the slump, clearing sticks")
	c.bench = {"weeks_left": 1}
	c.flags["benched"] = false
	m._sync_flags()
	check(c.flags["benched"], "benched comes back while benched")


func test_dismissed_in_college() -> void:
	var m := _career(CareerData.STAGE_COLLEGE)
	var c := m.data
	c.draft_score = 95.0
	c.notice = ""
	Reputation.on_flags(c, {Reputation.DISMISSED: true}, t)
	c.flags[Reputation.DISMISSED] = true
	check("DISMISSED" in c.notice, "a clear notice")
	c.phase = CareerManager.PHASE_SEASON_END
	m.end_season()
	eq(c.phase, CareerManager.PHASE_DRAFT, "straight to draft day, even before senior year")
	eq(str(c.draft_result["kind"]), "open", "not drafted: the open tryout")
	check(not c.flags[Reputation.DISMISSED] and c.flags["was_dismissed"], "carried out once")


func test_dismissed_in_the_pros() -> void:
	var m := _career(CareerData.STAGE_COLLEGE)
	var c := m.data
	m._enter_stage(CareerData.STAGE_PRO, Progression.team_from(CareerContent.pro_clubs()[0], CareerData.STAGE_PRO), "x")
	c.contract = {"years_left": 3, "team": "x", "team_name": "X", "salary": 900000}
	c.season_stats = {"fg_att": 20, "fg_made": 20, "long": 55}
	c.flags[Reputation.DISMISSED] = true
	c.phase = CareerManager.PHASE_SEASON_END
	m.end_season()
	if c.phase == CareerManager.PHASE_CONTRACT:
		eq(str(c.contract["status"]), "released", "released at season end, however well he kicked")
		check(c.contract.get("dismissed", false), "and the contract screen knows why")
	check(not c.flags[Reputation.DISMISSED], "carried out once")
