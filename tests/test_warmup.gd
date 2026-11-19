extends "res://tests/test_case.gd"
## The sideline warmup net (3D kick scene, WarmupMode): the rules are the old
## 2D pad's, unchanged; only the presentation moved.


## The old pad's rule (SidelineKick.net, removed), kept here as the reference.
static func _old_pure(power: float, aim: float, t: CareerTuning) -> bool:
	if absf(aim) > t.net_aim_deg:
		return false
	if power < t.net_power_min:
		return false
	if power > t.net_power_max:
		return false
	return true


func test_judge_matches_old_pad_rules() -> void:
	var t: CareerTuning = load("res://tuning/career_tuning.tres")
	var mismatches := 0
	for pi in 41:
		for ai in 49:
			var power := pi / 40.0
			var aim := -12.0 + ai * 0.5
			var r := WarmupJudge.strike(power, aim, t.net_power_min, t.net_power_max, t.net_aim_deg)
			if bool(r["pure"]) != _old_pure(power, aim, t):
				mismatches += 1
	eq(mismatches, 0, "same pure / not pure as the old pad over a power x aim sweep")


func test_feedback_lines() -> void:
	eq(WarmupJudge.strike(0.7, 0.0, 0.5, 0.92, 6.0)["banner"], "PURE!", "pure")
	eq(WarmupJudge.strike(0.7, 8.0, 0.5, 0.92, 6.0)["banner"], "PUSHED IT", "aim right")
	eq(WarmupJudge.strike(0.7, -8.0, 0.5, 0.92, 6.0)["banner"], "PULLED IT", "aim left")
	eq(WarmupJudge.strike(0.3, 0.0, 0.5, 0.92, 6.0)["banner"], "SOFT CONTACT", "too soft")
	eq(WarmupJudge.strike(0.97, 0.0, 0.5, 0.92, 6.0)["banner"], "OVER-SWUNG", "too hard")


func test_session_result_and_mode_flow() -> void:
	var t: CareerTuning = load("res://tuning/career_tuning.tres")
	var m := WarmupMode.from_tuning(t)
	eq(m.kicks, t.net_kicks, "kicks from tuning")
	eq(m.kick_type(), KickSituation.KickType.WARMUP_NET, "warmup kick type")
	check(m.wants_next_kick(), "first kick")
	m.judge(0.7, 0.0)
	m.judge(0.7, 9.0)
	check(m.wants_next_kick(), "third kick to come")
	m.judge(0.75, 1.0)
	check(not m.wants_next_kick(), "session over after %d kicks" % t.net_kicks)
	eq(m.result(), "pure", "2 of 3 pure = pure")
	eq(m.summary()["banner"], "WARMED UP", "summary banner")
	var m2 := WarmupMode.from_tuning(t)
	m2.judge(0.2, 0.0)
	m2.judge(0.7, 0.0)
	m2.judge(0.99, 0.0)
	eq(m2.result(), "loose", "1 of 3 pure = loose")
	eq(WarmupJudge.session_result(t.net_pure_needed, t.net_pure_needed), "pure", "threshold")


func test_warmup_results_still_known_to_the_game_sim() -> void:
	var results: Dictionary = CareerContent.game_day().get("warmup", {}).get("results", {})
	for id in ["pure", "loose", "skipped"]:
		check(results.has(id), "game_day warmup result '%s'" % id)
	check(not CareerContent.game_day().has("pad"), "old pad text removed")
