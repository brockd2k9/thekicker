class_name DailyMode
extends KickMode
## The Daily Challenge in the kick scene: exactly one kick, the day's
## scenario (DailyScenario). Wind is seeded by the day, so its gust rhythm is
## the same for everyone. Kicks report with mode &"daily", which GameState
## leaves out of every stat (UNRECORDED_MODES).

var scenario: Dictionary


func _init(sc: Dictionary = {}) -> void:
	scenario = sc


func id() -> StringName:
	return DailyChallenge.MODE


func kick_type() -> int:
	return DailyScenario.kick_type(scenario)


func next_situation(_rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
	var s := KickSituation.new()
	s.kick_type = kick_type() as KickSituation.KickType
	s.distance_yards = int(scenario.get("yards", 30))
	if DailyScenario.is_tee(scenario):
		s.kickoff_rules = DailyScenario.kickoff_rules(scenario)
	var r := RandomNumberGenerator.new()
	r.seed = int(scenario.get("wind_seed", 1))
	var base := float(scenario.get("wind_mph", 0.0))
	wind.set_conditions(r, tuning, base, float(scenario.get("gust_mph", 0.0)))
	s.wind_mph = base
	s.wind_gust_mph = float(scenario.get("gust_mph", 0.0))
	s.wind_along_mph = float(scenario.get("along_mph", 0.0))
	s.along_preset = true
	s.pressure = float(scenario.get("pressure", 0.0))
	s.label = str(scenario.get("label", "DAILY CHALLENGE"))
	return s


func wants_next_kick() -> bool:
	return false
