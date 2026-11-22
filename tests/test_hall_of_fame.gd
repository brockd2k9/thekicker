extends "res://tests/test_case.gd"
## R10: the Hall of Fame formula and tiers, the story signals, the
## retirement-reason flags, and the epilogue flow (closing scenes in order,
## re-checked after each choice, then the vote, then the summary).

var t := CareerTuning.get_default()


func _pro(seasons: int, made: int, att: int, gw: int) -> CareerManager:
	var c := CareerData.create("Hall Test", t)
	c.slot = 0
	c.stage = CareerData.STAGE_PRO
	c.team = Progression.team_from(CareerContent.pro_clubs()[0], CareerData.STAGE_PRO)
	for i in seasons:
		var m := made / seasons + (1 if i < made % seasons else 0)
		var a := att / seasons + (1 if i < att % seasons else 0)
		var g := gw / seasons + (1 if i < gw % seasons else 0)
		c.history.append({"stage": CareerData.STAGE_PRO, "team": "Metro Monarchs" if i < seasons - 2 else "Other Club",
			"stats": {"fg_made": m, "fg_att": a, "game_winners": g, "long": 52, "games": 17}})
	return CareerManager.new(c, t)


func _points(hof: Dictionary, label: String) -> int:
	for l in hof["lines"]:
		if l["label"] == label:
			return int(l["points"])
	return -999


func test_the_formula() -> void:
	# 12 seasons, 246 of 300 (82%), 10 game winners, 15 makes of 50+.
	var m := _pro(12, 246, 300, 10)
	for i in 15:
		m.data.kick_log.append({"kind": "fg", "stage": CareerData.STAGE_PRO, "made": 1, "yd": 51})
	var hof := HallOfFame.evaluate(m.data, t)
	eq(_points(hof, "Longevity"), 30, "2.5 a season")
	eq(_points(hof, "Accuracy"), 18, "82% is 7 points over 75%, 2.5 each")
	eq(_points(hof, "Volume"), 25, "0.1 a make")
	eq(_points(hof, "Clutch"), 30, "3 a game winner")
	eq(_points(hof, "Distance"), 15, "1 a make of 50+")
	eq(_points(hof, "Character"), 0, "a clean record")
	check(int(hof["score"]) >= t.hof_inducted and int(hof["score"]) < t.hof_first_ballot, "inducted (%d)" % hof["score"])
	eq(str(hof["tier"]), "inducted", "tier")
	eq(str(hof["club"]), "Metro Monarchs", "the club of most seasons")


func test_caps_and_minimums() -> void:
	var m := _pro(30, 600, 700, 40)
	var hof := HallOfFame.evaluate(m.data, t)
	eq(_points(hof, "Longevity"), roundi(t.hof_season_cap), "longevity capped")
	eq(_points(hof, "Clutch"), roundi(t.hof_clutch_cap), "clutch capped")
	var short := HallOfFame.evaluate(_pro(3, 80, 100, 0).data, t)
	eq(_points(short, "Accuracy"), 0, "too few attempts: no accuracy points")
	var poor := HallOfFame.evaluate(_pro(10, 100, 200, 0).data, t)
	eq(_points(poor, "Accuracy"), -roundi(t.hof_acc_below_cap), "50%: capped penalty")


func test_character_counts() -> void:
	var m := _pro(12, 246, 300, 10)
	m.data.suspensions_total = 2
	m.data.flags["was_dismissed"] = true
	var hof := HallOfFame.evaluate(m.data, t)
	eq(_points(hof, "Character"), roundi(2 * t.hof_per_suspension + t.hof_dismissed), "suspensions and a dismissal")


func test_tiers() -> void:
	eq(HallOfFame.tier_for(t.hof_first_ballot, t), "first_ballot", "first ballot")
	eq(HallOfFame.tier_for(t.hof_inducted, t), "inducted", "inducted")
	eq(HallOfFame.tier_for(t.hof_finalist, t), "finalist", "finalist")
	eq(HallOfFame.tier_for(t.hof_ring_of_honor, t), "ring_of_honor", "ring of honor")
	eq(HallOfFame.tier_for(t.hof_ring_of_honor - 1, t), "none", "none")
	check(not HallOfFame.evaluate(CareerData.create("HS only", t), t)["eligible"], "no pro seasons: no vote")


func test_retirement_sets_the_signals() -> void:
	var m := _pro(12, 246, 300, 10)
	m.retire("chose")
	var f := m.data.flags
	eq(f.get("hall_of_fame_tier"), str(m.data.retirement["hof"]["tier"]), "the tier")
	eq(bool(f.get("hall_of_fame_earned")), HallOfFame.earned(str(f["hall_of_fame_tier"])), "earned")
	eq(bool(f.get("hof_" + str(f["hall_of_fame_tier"]))), true, "one true tier flag")
	check(bool(f.get("retired_by_choice")), "by choice")
	check(not bool(f.get("retired_out_of_football")), "not forced out")
	var r := _pro(5, 100, 140, 1)
	r.data.flags["last_exit"] = "released"
	r.retire("out_of_football")
	check(bool(r.data.flags.get("retired_out_of_football")), "forced out")
	check(bool(r.data.flags.get("retired_released")), "released last")
	check(not bool(r.data.flags.get("retired_unsigned")), "not the unsigned one")


## The real closing scenes (story content) are set aside for a test: marked
## as seen, so only the test's own scenes (or none) play.
func _set_real_epilogue_aside(c: CareerData) -> void:
	for s in CareerContent.scenarios():
		var id := str(s.get("id", ""))
		if "epilogue" in s.get("when", []) and not id.begins_with("ZZ_"):
			c.scenario_log[id] = {"count": 1, "set_aside": true}


func test_no_closing_scenes_goes_to_the_vote_then_the_summary() -> void:
	var m := _pro(12, 246, 300, 10)
	_set_real_epilogue_aside(m.data)
	m.retire("chose")
	eq(m.data.phase, CareerManager.PHASE_HALL, "the vote")
	eq(m.screen_path(), Screens.CAREER_HALL, "on its screen")
	m.finish_hall_of_fame()
	eq(m.data.phase, CareerManager.PHASE_RETIRED, "then the summary")
	var hs := CareerManager.new(CareerData.create("HS only", t), t)
	hs.data.slot = 0
	_set_real_epilogue_aside(hs.data)
	hs.retire("no_options")
	eq(hs.data.phase, CareerManager.PHASE_RETIRED, "no pro career: straight to the summary")


func test_closing_scenes_in_order_and_rechecked() -> void:
	var made := [
		_scene("ZZ_E01", 0, {}, {"took_coaching": true}),
		_scene("ZZ_E02", 0, {"flags": ["hall_of_fame_earned"]}, {}),
		_scene("ZZ_E03", 0, {"flags": ["took_coaching"]}, {}),
		_scene("ZZ_E00", 5, {}, {}),
	]
	for s in made:
		CareerContent.scenarios().append(s)
		CareerContent._scenario_index[s["id"]] = s
	var problems := PackedStringArray()
	for s in made:
		CareerContent._check_requires(problems, "x", s["requires"])
	eq(problems.size(), 0, "valid scenes")
	var m := _pro(12, 246, 300, 10)
	_set_real_epilogue_aside(m.data)
	m.retire("chose")
	var seen: Array = []
	while m.data.phase == CareerManager.PHASE_EPILOGUE:
		seen.append(m.data.pending_scenarios[0])
		m.choose(0)
	var expect := ["ZZ_E01"]
	if bool(m.data.flags.get("hall_of_fame_earned", false)):
		expect.append("ZZ_E02")
	expect.append_array(["ZZ_E03", "ZZ_E00"])
	eq(seen, expect, "in order, gated by the flags, E03 opened by E01's choice")
	eq(m.data.phase, CareerManager.PHASE_HALL, "then the vote")
	for s in made:
		CareerContent.scenarios().erase(s)
		CareerContent._scenario_index.erase(s["id"])


func _scene(id: String, order: int, req: Dictionary, flags: Dictionary) -> Dictionary:
	var s := {"id": id, "title": id, "text": "x", "category": "career", "stages": [CareerData.STAGE_RETIRED],
		"when": ["epilogue"], "requires": req,
		"choices": [{"label": "On", "result": "x", "stats": {"personality": {"leadership": 1}}, "set_flags": flags}]}
	if order != 0:
		s["order"] = order
	return s
