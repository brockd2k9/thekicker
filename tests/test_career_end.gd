extends "res://tests/test_case.gd"
## No pro age cap: careers end through decline, release or retiring; older
## free agents get fewer tryouts; "Ironman" is playing until 40. Also the
## scenario_recruiting_scale / scenario_draft_scale on choices' progress.

var t := CareerTuning.get_default()


func _pro(age: int) -> CareerManager:
	var c := CareerData.create("End Test", t)
	c.created = 1794983149
	c.slot = 0
	c.team = Progression.team_from(CareerContent.pro_clubs()[0], CareerData.STAGE_PRO)
	c.stage = CareerData.STAGE_PRO
	c.age = age
	var m := CareerManager.new(c, t)
	m.rng.seed = 4
	return m


func test_no_age_cap() -> void:
	check(not ("pro_age_cap" in t), "the age cap is gone")
	var m := _pro(41)
	var c := m.data
	c.contract = {"years_left": 3, "team": "x", "team_name": "X", "salary": 900000}
	c.season_stats = {"fg_att": 20, "fg_made": 19, "long": 52, "game_winners": 1}
	c.phase = CareerManager.PHASE_SEASON_END
	m.end_season()
	check(c.phase != CareerManager.PHASE_RETIRED, "a good 41-year-old keeps playing")


func test_older_free_agents_get_fewer_calls() -> void:
	var m := _pro(30)
	eq(m.fa_call_chance(), 1.0, "everyone gets a call at 30")
	m.data.age = t.fa_age_from + 2
	eq(m.fa_call_chance(), 1.0 - 2.0 * t.fa_age_drop, "fewer later")
	m.data.age = 60
	eq(m.fa_call_chance(), 0.0, "none at 60")
	# A 60-year-old in free agency: no calls, the career ends.
	m.data.poor_streak = 0
	m._free_agency("Released.")
	eq(m.data.phase, CareerManager.PHASE_RETIRED, "out of football when nobody calls")


func test_ironman_is_playing_until_40() -> void:
	var d := AchievementDefs.find("career_ironman")
	eq(int(d["condition"]["min_value"]["age"]), 40, "played until 40")


func test_choice_progress_scales() -> void:
	var p := ScenarioEngine.progress_changes({"recruiting": 10, "draft": 4, "grades": 0.2}, t)
	eq(float(p["recruiting"]), 10.0 * t.scenario_recruiting_scale, "recruiting scaled")
	eq(float(p["draft"]), 4.0 * t.scenario_draft_scale, "draft scaled")
	eq(float(p["grades"]), 0.2, "grades untouched")


func test_standing_reference_and_preserving() -> void:
	var m := _pro(31)
	var c := m.data
	c.season_stats = {"fg_att": 20, "fg_made": roundi(20 * t.retention_fg_ref), "long": 45}
	c.retention_bonus = 0.0
	check(absf(Progression.retention(c, t) - 50.0) < 3.0, "kicking at the reference FG%% keeps standing near 50")
	# Preserving attributes at 30+ adds standing at season end.
	c.contract = {"years_left": 3, "team": "x", "team_name": "X", "salary": 900000}
	c.season_stats = {"fg_att": 20, "fg_made": 14, "long": 45}
	c.retention_bonus = 0.0
	c.maintained = {"power": c.season, "accuracy": c.season}
	c.phase = CareerManager.PHASE_SEASON_END
	var keep := Progression.retention(c, t)
	m.end_season()
	check(c.retention_score >= keep + 2.0 * t.retention_maintained - 0.01 or c.retention_score >= 100.0,
		"two preserved attributes: +%.0f standing" % (2.0 * t.retention_maintained))
