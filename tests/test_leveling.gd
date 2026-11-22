extends "res://tests/test_case.gd"
## Leveling (LevelingConfig / Leveling): the skill point cost curve, the overall
## rating, the per-stage caps, and the high school guarantee (overall <= cap on
## leaving high school, however hard you try).

const SIM := preload("res://tools/career_sim.gd")

var t := CareerTuning.get_default()


func _career(stage := CareerData.STAGE_HIGH_SCHOOL) -> CareerData:
	var c := CareerData.create("Level Test", t)
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	c.stage = stage
	return c


func test_cost_curve_is_steep_and_low_levels_stay_affordable() -> void:
	var at30 := SkillPoints.cost_at(30.0, t)
	var at50 := SkillPoints.cost_at(50.0, t)
	var at70 := SkillPoints.cost_at(70.0, t)
	var at90 := SkillPoints.cost_at(90.0, t)
	check(at30 <= 6, "low attributes stay affordable (%d)" % at30)
	check(at50 > at30 and at70 > at50 and at90 > at70, "climbs")
	check(at90 >= at30 * 6, "steep: 90 costs far more than 30 (%d vs %d)" % [at90, at30])
	check(at70 - at50 > at50 - at30, "accelerates, not flat")


func test_overall_is_the_average_of_the_four() -> void:
	var c := _career()
	c.set_stat("power", 60.0)
	c.set_stat("accuracy", 40.0)
	c.set_stat("resilience", 50.0)
	c.set_stat("toughness", 30.0)
	eq(Leveling.overall(c), 45.0, "average")


func test_upgrades_stop_at_the_stage_caps() -> void:
	var c := _career()
	SkillPoints.earn(c, 1000000, "Test")
	for i in 400:
		for s in Leveling.STATS:
			SkillPoints.upgrade(c, s, t)
	check(Leveling.overall(c) <= Leveling.overall_cap(c.stage), "overall capped (%.1f)" % Leveling.overall(c))
	for s in Leveling.STATS:
		check(c.stat(s) <= Leveling.attribute_cap(c.stage), "%s capped" % s)
	eq(SkillPoints.cost(c, "power", t), 0, "nothing to buy at the cap")
	check(Leveling.cap_reason(c, "power") != "", "the Skills screen says why")
	eq(SkillPoints.cost_of_next(c, "power", 5, t), 0, "+5 refused at the cap")
	# One attribute alone stops at the per-attribute cap.
	var d := _career()
	SkillPoints.earn(d, 1000000, "Test")
	for i in 100:
		SkillPoints.upgrade(d, "power", t)
	eq(d.stat("power"), Leveling.attribute_cap(d.stage), "single attribute cap")


func test_stat_gains_stop_at_the_stage_caps() -> void:
	var c := _career()
	for i in 50:
		CareerStats.apply(c, {"football": {"power": 40.0, "accuracy": 40.0, "resilience": 40.0, "toughness": 40.0}}, t)
		check(Leveling.overall(c) <= Leveling.overall_cap(c.stage) + 0.0001, "never past the overall cap")
	var before := c.stat("power")
	CareerStats.apply(c, {"football": {"power": -5.0}}, t)
	eq(c.stat("power"), before - 5.0, "losses aren't limited")


func test_caps_rise_with_the_stage() -> void:
	var hs := Leveling.overall_cap(CareerData.STAGE_HIGH_SCHOOL)
	var col := Leveling.overall_cap(CareerData.STAGE_COLLEGE)
	var pro := Leveling.overall_cap(CareerData.STAGE_PRO)
	eq(hs, Leveling.config().hs_overall_cap, "high school from the config")
	check(hs <= 55.0, "high school cap is at most 55")
	check(col > hs and pro >= col, "college and pro allow more")
	eq(Leveling.overall_cap(CareerData.STAGE_JUCO), col, "junior college uses the college caps")


func test_enforce_clamps_highest_first() -> void:
	var c := _career()
	c.set_stat("power", 90.0)
	c.set_stat("accuracy", 60.0)
	c.set_stat("resilience", 40.0)
	c.set_stat("toughness", 40.0)
	var lowered := Leveling.enforce(c)
	check(Leveling.overall(c) <= Leveling.overall_cap(c.stage) + 0.0001, "overall fits")
	check(c.stat("power") <= Leveling.attribute_cap(c.stage), "attribute fits")
	check(lowered.has("power"), "the highest came down")
	eq(c.stat("resilience"), 40.0, "the low ones are untouched")


func test_old_save_is_clamped_and_refunded() -> void:
	var c := _career()
	for s in Leveling.STATS:
		c.set_stat(s, 80.0)
	c.skill_points = 3
	var back := CareerData.from_dict(c.to_dict())  # loads with no complaint
	eq(back.stat("power"), 80.0, "the save itself loads as it was")
	var m := CareerManager.new(back)
	m._sanitize()
	check(Leveling.overall(back) <= Leveling.overall_cap(back.stage) + 0.0001, "clamped on load")
	check(back.skill_points > 3, "refunded (%d SP)" % back.skill_points)
	check(back.notice.contains("skill points back"), "and told: " + back.notice)
	var sp := back.skill_points
	m._sanitize()
	eq(back.skill_points, sp, "loading again changes nothing")


func test_purchase_is_a_grant() -> void:
	var c := _career()
	SkillPoints.purchase(c, 25)
	eq(c.skill_points, 25, "purchased points land in the balance")
	eq(int(c.sp_sources.get("Purchased", 0)), 25, "counted under their own source")


## The guarantee: a full high school career through the real CareerManager loop,
## choosing for football every time, given a mountain of extra skill points and
## huge stat gains every week, never leaves high school above the cap.
func test_max_effort_high_school_never_leaves_above_cap() -> void:
	var cap := Leveling.overall_cap(CareerData.STAGE_HIGH_SCHOOL)
	check(cap <= 55.0, "configured high school cap %.0f" % cap)
	for seed in [1, 2, 3]:
		var sim: Node = SIM.new()
		sim._kt = load("res://tuning/kick_tuning.tres")
		sim._rng.seed = seed
		var c := _career()
		var m := CareerManager.new(c)
		m.rng.seed = seed
		m._start_season(false)
		var worst := 0.0
		var guard := 0
		while c.stage == CareerData.STAGE_HIGH_SCHOOL and guard < 5000:
			guard += 1
			match c.phase:
				CareerManager.PHASE_WEEK_START:
					m.begin_week()
				CareerManager.PHASE_SCENARIO, CareerManager.PHASE_OFFSEASON, CareerManager.PHASE_EPILOGUE:
					m.choose(sim._choose(c, m.current_scenario(), "always-train", m.tuning))
				CareerManager.PHASE_OUTLOOK:
					m.start_game()
				CareerManager.PHASE_GAME:
					m.finish_game(sim._play_game(m))
				CareerManager.PHASE_TRYOUT:
					m.finish_tryout(sim._tryout(c))
				CareerManager.PHASE_RESULTS:
					_max_effort(c)
					m.end_week()
				CareerManager.PHASE_SEASON_END:
					m.end_season()
				CareerManager.PHASE_RECRUITING:
					if m._stage_done():
						break  # high school is over: this is the moment we check
					m.continue_recruiting()
				_:
					break
			worst = maxf(worst, Leveling.overall(c))
		check(m._stage_done(), "seed %d: played all of high school" % seed)
		check(worst <= cap + 0.0001, "seed %d: never above %.0f in high school (max %.2f)" % [seed, cap, worst])
		check(Leveling.overall(c) <= cap + 0.0001, "seed %d: leaving high school at %.2f" % [seed, Leveling.overall(c)])
		check(Leveling.overall(c) >= cap - 1.0, "seed %d: max effort does reach the cap (%.2f)" % [seed, Leveling.overall(c)])
		sim.free()


## Far more than any real season: 2000 SP a week spent greedily (cheapest
## first) and a big gain to every football attribute.
func _max_effort(c: CareerData) -> void:
	SkillPoints.earn(c, 2000, "Test")
	CareerStats.apply(c, {"football": {"power": 10.0, "accuracy": 10.0, "resilience": 10.0, "toughness": 10.0}}, t)
	var bought := true
	while bought:
		bought = false
		var best := ""
		for s in Leveling.STATS:
			if SkillPoints.affordable(c, s, t) and (best == "" or SkillPoints.cost(c, s, t) < SkillPoints.cost(c, best, t)):
				best = s
		if best != "":
			bought = SkillPoints.upgrade(c, best, t)
