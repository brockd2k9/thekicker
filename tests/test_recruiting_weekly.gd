extends "res://tests/test_case.gd"
## Recruiting points move after every game (Progression.credit_recruiting) and
## the Recruiting screen lists every college (CareerRecords.all_schools).

var t := CareerTuning.get_default()


func _hs() -> CareerManager:
	var c := CareerData.create("Recruit Test", t)
	c.team = Progression.team_from(TeamDatabase.start_team(), CareerData.STAGE_HIGH_SCHOOL)
	c.season_in_stage = 3  # junior year: full weight
	var m := CareerManager.new(c)
	m.rng.seed = 3
	m._start_season(false)
	return m


func test_points_move_after_a_game() -> void:
	var m := _hs()
	var c := m.data
	c.set_stat("power", 80.0)
	c.set_stat("accuracy", 80.0)
	while m.is_bye():
		c.week += 1
	c.phase = CareerManager.PHASE_GAME
	var before := c.recruiting_score
	m.finish_game({"outcome": "W", "us": 24, "them": 7, "kicks": [
		{"kind": "fg", "yards": 44, "made": true, "pressure": 0.3, "label": ""},
		{"kind": "pat", "yards": 20, "made": true, "pressure": 0.1, "label": ""}]})
	check(c.last_week.has("recruiting"), "Results knows the change")
	check(not is_equal_approx(c.recruiting_score, before), "points moved after one game")
	eq(snappedf(c.recruiting_score - before, 0.01), float(c.last_week["recruiting"]), "the change shown is the change made")
	var expect := Progression.recruiting_so_far(c, t)
	eq(float(c.flags["_recruit_credit"]), expect, "credited what the season has earned so far")
	eq(expect, (Progression.recruiting_gain(c, t) - Progression.coach_rec(c, t)) / float(t.games_for(c.stage)),
		"one game = one game's share of the season")


func test_season_total_is_unchanged() -> void:
	var m := _hs()
	var c := m.data
	c.recruiting_score = 30.0
	# A whole season on paper: stats, record, a credit after each game.
	c.season_stats = {"fg_att": 14, "fg_made": 11, "pat_att": 30, "pat_made": 29, "long": 47, "games": 10,
		"points": 62, "game_winners": 1}
	for g in t.games_for(c.stage):
		c.record["w" if g % 3 != 0 else "l"] += 1
		Progression.credit_recruiting(c, t)
	var credited := float(c.flags["_recruit_credit"])
	eq(credited, Progression.recruiting_gain(c, t) - Progression.coach_rec(c, t), "a full season credited")
	eq(c.recruiting_score, 30.0 + credited, "points rose during the season")
	# Season end: the total gain is what it always was; only the rest is added now.
	c.phase = CareerManager.PHASE_SEASON_END
	c.week = m.weeks_in_season() + 1
	c.postseason = {"kind": "none", "status": "missed", "w": 0, "l": 0, "games": []}
	m.end_season()
	var upd: Dictionary = c.flags.get("recruiting_update", {})
	eq(c.recruiting_score, clampf(30.0 + float(upd["gain"]), 0.0, 100.0), "season total unchanged")
	eq(float(c.flags["_recruit_credit"]), 0.0, "credit reset for next season")


func test_pro_and_college_dont_move_recruiting() -> void:
	var c := CareerData.create("Pro", t)
	c.stage = CareerData.STAGE_PRO
	c.recruiting_score = 50.0
	c.record = {"w": 5, "l": 0, "t": 0}
	eq(Progression.credit_recruiting(c, t), 0.0, "no recruiting change outside HS / JUCO")
	eq(c.recruiting_score, 50.0, "unchanged")


func test_every_college_is_listed() -> void:
	var c := _hs().data
	c.recruiting_score = 60.0
	var total := 0
	for div in ["FBS", "FCS", "D2"]:
		var list := CareerRecords.all_schools(c, div)
		var want := TeamDatabase.colleges().filter(func(s: Dictionary) -> bool: return s["division"] == div).size()
		eq(list.size(), want, div + ": every school")
		total += list.size()
		for i in range(1, list.size()):
			check(float(list[i - 1]["interest"]) >= float(list[i]["interest"]), div + ": most interested first")
		for e in list:
			check(float(e["interest"]) >= 0.0 and float(e["interest"]) <= 100.0, "interest 0-100")
	eq(total, TeamDatabase.colleges().size(), "all four-year colleges")
	eq(CareerRecords.all_schools(c).size(), TeamDatabase.colleges().size(), "no level: every school")
