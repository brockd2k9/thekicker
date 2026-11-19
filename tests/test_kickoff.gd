extends "res://tests/test_case.gd"
## Kickoffs and onside kicks in the 3D kick scene: the judge, the launch solver,
## the per-stage rules and the career wiring. (The 3D flight itself is checked
## by playing real kicks; see README "Tests".)

const YARD := KickoffJudge.YARD


func _rules(spot: int = 35) -> KickoffRules:
	var r := KickoffRules.new()
	r.spot_yards = spot
	r.touchback_spot = 25
	r.oob_spot = 35
	return r


func _landing(carry_yd: float, x_m: float = 0.0) -> Vector3:
	return Vector3(x_m, 0.1, -carry_yd * YARD)


func test_kickoff_touchback() -> void:
	var rng := RandomNumberGenerator.new()
	var res := KickoffJudge.kickoff(_landing(66.0), 3.5, _rules(35), rng)
	eq(res["result"], "touchback", "past the goal line from the 35")
	eq(res["start_spot"], 25, "touchback spot")
	eq(res["quality"], 1.0, "touchback quality")
	check(res["good"], "touchback is good")
	res = KickoffJudge.kickoff(_landing(80.0), 3.5, _rules(35), rng)
	eq(res["result"], "touchback", "past the end line is still a touchback")


func test_kickoff_deep_returned_short() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var res := KickoffJudge.kickoff(_landing(60.0), 4.0, _rules(35), rng)  # fielded at the 5
	eq(res["result"], "deep", "fielded inside the 10")
	check(int(res["start_spot"]) > 5 and int(res["start_spot"]) <= 50, "returned from the 5")
	res = KickoffJudge.kickoff(_landing(48.0), 3.0, _rules(35), rng)  # fielded at the 17
	eq(res["result"], "returned", "fielded at the 17")
	eq(res["quality"], clampf(1.0 - 17.0 / 40.0, 0.2, 0.9), "same quality rule as the sideline pad")
	res = KickoffJudge.kickoff(_landing(30.0), 2.5, _rules(35), rng)  # fielded at the 35
	eq(res["result"], "short", "fielded beyond the 25")
	check(not res["good"], "short kick is bad")
	check(int(res["start_spot"]) <= 50, "returns stop at midfield")


func test_kickoff_hang_time_shortens_return() -> void:
	var r := _rules(35)
	r.return_min_yards = 20.0
	r.return_max_yards = 20.0
	var rng := RandomNumberGenerator.new()
	var low := KickoffJudge.kickoff(_landing(55.0), 3.0, r, rng)
	var high := KickoffJudge.kickoff(_landing(55.0), 4.5, r, rng)
	eq(int(low["start_spot"]), 30, "10 + 20 return")
	eq(int(high["start_spot"]), 24, "1.5 s more hang: 6 yards less")


func test_kickoff_out_of_bounds_from_landing_point() -> void:
	var rng := RandomNumberGenerator.new()
	var res := KickoffJudge.kickoff(_landing(55.0, 25.0), 3.5, _rules(35), rng)
	eq(res["result"], "out_of_bounds", "landed past the sideline")
	eq(res["start_spot"], 35, "out-of-bounds spot")
	eq(res["quality"], 0.1, "same quality as the sideline pad")
	res = KickoffJudge.kickoff(_landing(55.0, -24.0), 3.5, _rules(35), rng)
	check(res["result"] != "out_of_bounds", "just inside the sideline is in")


func test_onside_keeps_risk_reward() -> void:
	var r := _rules(35)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var good_rec := 0
	var poor_rec := 0
	for i in 4000:
		if KickoffJudge.onside(_landing(12.0), 3.0, r, rng)["recovered"]:
			good_rec += 1
		if KickoffJudge.onside(_landing(25.0), 3.0, r, rng)["recovered"]:
			poor_rec += 1
	check(absf(good_rec / 4000.0 - r.onside_good_chance) < 0.03, "good onside ~45%% (%d)" % good_rec)
	check(absf(poor_rec / 4000.0 - r.onside_poor_chance) < 0.02, "poor onside ~8%% (%d)" % poor_rec)
	var wide := KickoffJudge.onside(_landing(12.0), 20.0, r, rng)
	check(not wide["text"].contains("perfect"), "aimed too wide is not a good onside")
	var oob := KickoffJudge.onside(_landing(12.0, 26.0), 3.0, r, rng)
	eq(oob["result"], "out_of_bounds", "rolled out of bounds")
	check(not oob["recovered"], "out of bounds is their ball")


func test_launch_lands_at_target_carry() -> void:
	var kt := KickTuning.new()
	var start := Vector3(0.0, 0.4, 0.0)
	for carry_yd in [20.0, 45.0, 65.0, 75.0]:
		var v := KickLaunch.velocity(carry_yd * YARD, 0.0, kt.kickoff_elevation_deg, kt.gravity,
			kt.flight_speed_scale, start, kt.ball_visual_scale, kt.ball_visual_scale_far, false)
		var got := KickLaunch._distance(v.length(), kt.kickoff_elevation_deg, kt.gravity, kt.flight_speed_scale,
			start, kt.ball_visual_scale, kt.ball_visual_scale_far, false) / YARD
		check(absf(got - carry_yd) < 0.5, "kickoff carry %d yd (got %.2f)" % [carry_yd, got])
	var dir := KickLaunch.direction(10.0, 0.0)
	check(dir.x > 0.0 and dir.z < 0.0, "aim right goes right and downfield")


func test_career_mode_maps_kick_types() -> void:
	var r := _rules(40)
	var ko := CareerGameMode.from_call({"kind": "kickoff", "wind": 6.0, "pressure": 0.0, "label": "KICKOFF"}, 0.3, r)
	eq(ko.kick_type(), KickSituation.KickType.KICKOFF, "kickoff type")
	check(ko.situation.kickoff_rules == r, "rules passed through")
	eq(ko.situation.pressure, 0.0, "kickoffs carry no miss-streak pressure")
	var on := CareerGameMode.from_call({"kind": "onside"}, 0.0, r)
	eq(on.kick_type(), KickSituation.KickType.ONSIDE, "onside type")
	var fg := CareerGameMode.from_call({"kind": "fg", "yards": 41, "pressure": 0.5, "label": "Q2"}, 0.1)
	eq(fg.kick_type(), KickSituation.KickType.FIELD_GOAL, "field goal type")
	eq(fg.situation.pressure, 0.6, "field goals still add the miss-streak pressure")
	eq(fg.situation.label, "FIELD GOAL  -  Q2", "field goal label unchanged")
	var pat := CareerGameMode.from_call({"kind": "pat", "yards": 20, "label": "Q1"}, 0.0)
	eq(pat.situation.label, "EXTRA POINT  -  Q1", "extra point label unchanged")
	check(not pat.situation.is_tee_kick(), "extra point is a place kick")


func test_stage_kickoff_rules() -> void:
	var t: CareerTuning = load("res://tuning/career_tuning.tres")
	var c := CareerData.new()
	var expect := {CareerData.STAGE_HIGH_SCHOOL: [40, 20, 35], CareerData.STAGE_COLLEGE: [35, 25, 35],
		CareerData.STAGE_PRO: [35, 30, 40]}
	for stage in expect:
		c.stage = stage
		c.team = {"tier": "d1"}
		var r := CareerGameMode.kickoff_rules_for(t, Progression.game_params(c, t))
		eq([r.spot_yards, r.touchback_spot, r.oob_spot], expect[stage], "%s kickoff spots" % stage)
		eq(r.max_carry_yards, t.kickoff_max_carry_yards, "same carry curve")
		eq(r.onside_good_chance, t.onside_good_chance, "same onside odds")


func test_game_sim_uses_kickoff_start_spot() -> void:
	var t: CareerTuning = load("res://tuning/career_tuning.tres")
	var c := CareerData.new()
	c.team = {"name": "Testers", "mascot": "Testers", "strength": 50}
	var week := {"opponent": {"name": "Others", "mascot": "Others", "strength": 50}, "home": true}
	for seed in range(1, 40):
		var sim := GameSim.new()
		sim.setup(c, week, t, seed, 50)
		var e := sim.next()
		while e["type"] == "play":
			e = sim.next()
		if e["type"] != "call" or e["kind"] != "kickoff":
			continue  # they kick first in this game
		sim.resolve_call({"quality": 0.6, "carry": 50.0, "text": "Kickoff 50 yards.", "start_spot": 37,
			"result": "returned"})
		eq(sim.kicks[0].get("outcome", ""), "returned", "kickoff outcome recorded")
		for i in 50:
			e = sim.next()
			if e["type"] == "play" and str(e["text"]).contains("Others") and str(e["text"]).contains("37"):
				return
			if e["type"] != "play":
				break
		check(false, "their next drive starts at the kickoff's 37")
		return
	check(false, "no game where we kick first")
