class_name CareerGameMode
extends KickMode
## Plugs one Career field goal / extra point into the existing kick scene.
## The sideline screen builds a fresh kick scene per attempt, with this mode
## (the situation the game sim called for) and the KickProfile's modifiers.
## wants_next_kick() is false: after the result, the screen takes you back to
## the bench. Kicks are reported with mode = &"career", so they count in My
## Stats and Achievements like any other kick.

var situation: KickSituation
var gust_mph: float = 0.0


## call: a GameSim "call" event. pressure_add: from the KickProfile (miss streak).
static func from_call(call: Dictionary, pressure_add: float) -> CareerGameMode:
	var m := CareerGameMode.new()
	var s := KickSituation.new()
	s.distance_yards = int(call.get("yards", 20))
	s.pressure = clampf(float(call.get("pressure", 0.0)) + pressure_add, 0.0, 1.0)
	s.wind_mph = float(call.get("wind", 0.0))
	var kind := "EXTRA POINT" if call.get("kind") == "pat" else "FIELD GOAL"
	s.label = "%s  -  %s" % [kind, call.get("label", "")]
	m.situation = s
	m.gust_mph = float(call.get("gust", 0.0))
	return m


func id() -> StringName:
	return &"career"


func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
	wind.set_conditions(rng, tuning, situation.wind_mph, gust_mph)
	return situation


func wants_next_kick() -> bool:
	return false
