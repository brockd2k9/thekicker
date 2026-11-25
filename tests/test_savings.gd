extends "res://tests/test_case.gd"
## Savings: pro pay after taxes and the agent, the "money" choice field (never
## below $0), requirements, the validator, display text, that money buys
## nothing, and save v8.

var t := CareerTuning.get_default()


func _career(stage := CareerData.STAGE_HIGH_SCHOOL) -> CareerManager:
	var c := CareerData.create("Money Test", t)
	c.created = 1794983149
	c.slot = 0
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c, t)
	m.rng.seed = 5
	m._start_season(false)
	if stage == CareerData.STAGE_PRO:
		c.stage = stage
		c.team = Progression.team_from(CareerContent.pro_clubs()[0], stage)
		c.contract = {"team": c.team["id"], "years_left": 3, "salary": 1000000, "how": "drafted"}
	return m


func test_pro_pay_after_taxes_and_agent() -> void:
	var pro := _career(CareerData.STAGE_PRO).data
	var expect := roundi(1000000 * (1.0 - t.savings_tax_rate - t.savings_agent_fee))
	eq(Savings.season_net(pro, t), expect, "salary minus taxes and the agent's fee")
	eq(Savings.pay_season(pro, t), expect, "paid")
	eq(pro.savings, expect, "into savings")
	eq(int(pro.money_log["salary"]), expect, "logged as salary")
	eq(Savings.season_net(_career().data, t), 0, "no pay outside the pros")


func test_season_end_pays_the_pros() -> void:
	var m := _career(CareerData.STAGE_PRO)
	var c := m.data
	c.phase = CareerManager.PHASE_SEASON_END
	var before := c.savings
	m.end_season()
	var h: Dictionary = c.history[-1]
	eq(int(h.get("pay", 0)), Savings.season_net(c, t) if c.stage == CareerData.STAGE_PRO else int(h.get("pay", 0)),
		"the season's pay is in the history")
	check(c.savings > before, "savings grew")
	eq(int(h.get("savings", -1)), c.savings, "and the season's savings")


func test_money_choices_and_the_floor() -> void:
	var c := _career().data
	eq(Savings.from_choice(c, {"money": 5000}), 5000, "a summer job")
	eq(c.savings, 5000, "saved")
	eq(Savings.preview(c, {"money": -20000}), -5000, "the card shows what you actually lose")
	eq(Savings.from_choice(c, {"money": -20000}), -5000, "never below $0")
	eq(c.savings, 0, "broke")
	eq(int(c.money_log["choices_in"]), 5000, "in")
	eq(int(c.money_log["choices_out"]), 5000, "out")
	eq(int(c.money_log["peak"]), 5000, "peak")
	eq(Savings.from_choice(c, {"label": "no money"}), 0, "no field, no change")


func test_money_buys_nothing() -> void:
	var c := _career().data
	var sp := c.skill_points
	var stats := {}
	for k in CareerData.STAT_NAMES:
		stats[k] = c.stat(k)
	var out := ScenarioEngine.apply_effects(c, {"money": 2000000}, t)
	eq(int(out["money"]), 2000000, "reported")
	eq(c.skill_points, sp, "no skill points")
	for k in CareerData.STAT_NAMES:
		eq(c.stat(k), float(stats[k]), "%s unchanged" % k)
	eq(KickProfile.build(c, t).fg_range, KickProfile.build(_career().data, t).fg_range, "the kick is the same")


func test_savings_requirement() -> void:
	var c := _career().data
	var req := {"min": {"savings": 1000000}}
	check(not ScenarioEngine.requirements_met(c, req), "not yet")
	Savings.add(c, 1000000)
	check(ScenarioEngine.requirements_met(c, req), "now")
	check(not ScenarioEngine.requirements_met(c, {"max": {"savings": 999999}}), "max works too")
	eq(ScenarioEngine.requirement_text(req), "$1.00M saved", "lock text")
	var problems := PackedStringArray()
	CareerContent._check_requires(problems, "x", req)
	eq(problems.size(), 0, "savings is a known metric")


func test_validator() -> void:
	eq(Savings.problems("x", {"money": 250000}).size(), 0, "dollars")
	eq(Savings.problems("x", {"money": -3000000}).size(), 0, "a loss")
	eq(Savings.problems("x", {"money": 1.5}).size(), 1, "whole dollars")
	eq(Savings.problems("x", {"money": "lots"}).size(), 1, "a number")
	eq(Savings.problems("x", {"money": Savings.MAX_CHOICE + 1}).size(), 1, "within the limit")
	check("money" in KickChallenge.BLOCK_FIELDS, "challenge results can carry money")


func test_text() -> void:
	eq(Savings.text(900), "$900", "dollars")
	eq(Savings.text(350000), "$350K", "thousands")
	eq(Savings.text(1250000), "$1.25M", "millions")
	eq(Savings.change_text(-2000000), "-$2.00M", "a loss")
	eq(Savings.change_text(50000), "+$50K", "a gain")


func test_migration_to_v8() -> void:
	var raw := fixture("career_v7_followers.json")
	var c := CareerData.from_dict(CareerSave._migrate(raw.duplicate(true)))
	eq(c.savings, 0, "a college save starts with nothing")
	var pro := raw.duplicate(true)
	pro["stage"] = CareerData.STAGE_PRO
	pro["contract"] = {"salary": 1000000, "years_left": 1}
	pro["history"] = [{"stage": CareerData.STAGE_PRO}, {"stage": CareerData.STAGE_PRO}, {"stage": "college"}]
	var p := CareerData.from_dict(CareerSave._migrate(pro))
	eq(p.savings, 2 * roundi(1000000 * (1.0 - t.savings_tax_rate - t.savings_agent_fee)),
		"two pro seasons at the current salary")
	eq(int(p.money_log["peak"]), p.savings, "peak")
	var again := CareerData.from_dict(CareerSave._migrate(p.to_dict()))
	eq(again.savings, p.savings, "saved and loaded")
	eq(JSON.stringify(again.money_log), JSON.stringify(p.money_log), "the log too")
	eq(int(p.to_dict()["career_version"]), CareerData.VERSION, "current version after the v8 step")
