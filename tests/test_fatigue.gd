extends "res://tests/test_case.gd"
## Fatigue: low Energy raises injury chance; exhausted weeks warn first and only
## then cost Power and Toughness (capped a season, bought back with skill
## points); practice intensity; good habits.

var t := CareerTuning.get_default()


func _career() -> CareerManager:
	var c := CareerData.create("Fatigue Test", t)
	c.created = 1794983149
	c.slot = 0
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c, t)
	m.rng.seed = 21
	m._start_season(false)
	c.set_stat("power", 50.0)
	c.set_stat("toughness", 50.0)
	return m


func test_low_energy_raises_injury_chance() -> void:
	var c := _career().data
	c.set_stat("energy", 60.0)
	var fresh := KickProfile.build(c, t).injury_risk
	c.set_stat("energy", 10.0)
	var tired := KickProfile.build(c, t)
	var expect := t.low_energy_injury * CareerTuning.lowness(10.0, t.low_energy_threshold)
	check(tired.injury_risk - fresh >= expect - 0.001, "tired: +%.3f injury chance" % expect)
	check(tired.fg_range < KickProfile.build(c, t).fg_range + 0.01, "exhausted costs range too")
	c.set_stat("energy", 25.0)
	var not_exhausted := KickProfile.build(c, t).fg_range
	c.set_stat("energy", 15.0)
	check(KickProfile.build(c, t).fg_range < not_exhausted, "under 20: a further temporary penalty")


func test_warning_always_comes_first() -> void:
	var c := _career().data
	c.set_stat("energy", 10.0)
	c.notice = ""
	Fatigue.end_week(c, t)
	eq(c.stat("power"), 50.0, "the first exhausted week costs nothing permanent")
	check(Fatigue.warned(c), "but the warning is up")
	check("RUNNING ON EMPTY" in c.notice, "and says so")
	c.notice = ""
	Fatigue.end_week(c, t)
	eq(c.stat("power"), 50.0 - t.fatigue_loss_points, "the second one costs Power")
	eq(c.stat("toughness"), 50.0 - t.fatigue_loss_points, "and Toughness")
	check("EXHAUSTED AGAIN" in c.notice, "a clear notice")
	eq(Fatigue.lost(c, "power"), t.fatigue_loss_points, "recorded for Skills")


func test_rest_resets_and_season_cap() -> void:
	var c := _career().data
	c.set_stat("energy", 10.0)
	Fatigue.end_week(c, t)
	c.set_stat("energy", 50.0)
	Fatigue.end_week(c, t)
	check(not Fatigue.warned(c), "a rested week clears the warning")
	c.set_stat("energy", 10.0)
	for i in 12:
		Fatigue.end_week(c, t)
	eq(c.stat("power"), 50.0 - t.fatigue_loss_points * t.fatigue_loss_season_cap, "at most the season cap")
	Fatigue.new_season(c)
	Fatigue.end_week(c, t)
	eq(c.stat("power"), 50.0 - t.fatigue_loss_points * (t.fatigue_loss_season_cap + 1), "a new season, a new cap")


func test_lost_points_can_be_bought_back() -> void:
	var c := _career().data
	c.set_stat("energy", 10.0)
	Fatigue.end_week(c, t)
	Fatigue.end_week(c, t)
	c.skill_points = 50
	check(SkillPoints.upgrade(c, "power", t), "upgrade works after a loss")
	eq(c.stat("power"), 50.0, "the point is back")


func test_practice_intensity() -> void:
	var c := _career().data
	c.set_stat("energy", 60.0)
	eq(Fatigue.practice(c), "normal", "normal by default")
	eq(Fatigue.practice_sp(c, t), t.sp_weekly_practice, "normal practice as always")
	Fatigue.set_practice(c, "light")
	eq(Fatigue.practice_sp(c, t), 0, "light: no practice skill points")
	eq(float(Fatigue.end_week(c, t).get("energy", 0.0)), t.practice_light_energy, "light: more Energy")
	Fatigue.set_practice(c, "hard")
	eq(Fatigue.practice_sp(c, t), t.sp_weekly_practice + t.practice_hard_sp, "hard: +skill points")
	eq(float(Fatigue.end_week(c, t).get("energy", 0.0)), t.practice_hard_energy, "hard: less Energy")
	var hard_risk := KickProfile.build(c, t).injury_risk
	Fatigue.set_practice(c, "normal")
	check(absf(hard_risk - KickProfile.build(c, t).injury_risk - t.practice_hard_injury) < 0.0001, "hard: a little injury risk")
	Fatigue.set_practice(c, "sprint")
	eq(Fatigue.practice(c), "normal", "unknown intensities are ignored")


func test_good_habits() -> void:
	var c := _career().data
	c.set_stat("energy", 80.0)
	var sp := c.skill_points
	for i in t.good_habits_weeks:
		Fatigue.end_week(c, t)
	eq(c.skill_points - sp, t.good_habits_sp, "weeks well rested in a row pay")
	eq(int(c.sp_sources.get(Fatigue.SP_HABITS, 0)), t.good_habits_sp, "source Good habits")
	for i in t.good_habits_weeks * 10:
		Fatigue.end_week(c, t)
	eq(c.skill_points - sp, t.good_habits_sp * t.good_habits_season_cap, "capped a season")


func test_through_the_week() -> void:
	var m := _career()
	var c := m.data
	Fatigue.set_practice(c, "light")
	c.set_stat("energy", 30.0)
	c.phase = CareerManager.PHASE_RESULTS
	m.end_week()
	check(c.stat("energy") > 30.0 + t.weekly_energy_recovery - 0.01, "light practice adds to recovery")
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(Fatigue.practice(again), "light", "the choice is saved")
