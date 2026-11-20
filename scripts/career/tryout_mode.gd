class_name TryoutMode
extends KickMode
## A Career kick series in the kick scene: stage tryouts (walk-on, training
## camp, free agent), the bench audition (purpose "job") and scenario kick
## challenges (purpose "challenge"): field goals at fixed distances, then (kick
## challenges only, optional) kickoffs. Kicks are reported as career kicks
## (they count in My Stats; never in season stats, skill points or trust).
##
## Resumable: CareerData.tryout["results"] holds every kick taken (true =
## made), saved after each kick, so a reload continues at the next kick. Each
## kick's wind comes from the tryout's seed and the kick number, so reloading
## can't reroll it. A kick that was struck but not resolved when the game quit
## counts as a miss (CareerManager.tryout_resume).
## The kick scene is either field goals or tee kicks, so the screen builds one
## scene for the field goals and another for the kickoffs (tee = true).

var distances: Array = []
var pressure: float = 0.3
var wind_max: float = 8.0
var title: String = "TRYOUT"
var seed: int = 0
## Field goals taken / made so far (resumed from the saved results).
var kicks: int = 0
var makes: int = 0
## Kickoffs (kick challenges): how many, and how far one must carry.
var kickoffs: int = 0
var kickoff_min_yards: float = 60.0
var kickoffs_taken: int = 0
var kickoff_rules: KickoffRules = null
## true: this mode runs the kickoffs (a tee-kick scene).
var tee: bool = false


static func from_tryout(t: Dictionary, as_tee := false) -> TryoutMode:
	var m := TryoutMode.new()
	m.distances = t.get("distances", [30, 35, 40, 45, 50])
	m.pressure = float(t.get("pressure", 0.3))
	m.wind_max = float(t.get("wind_max", 8.0))
	m.title = str(t.get("title", "TRYOUT"))
	m.seed = int(t.get("seed", 0))
	var ko: Dictionary = t.get("kickoffs", {}) if t.get("kickoffs") is Dictionary else {}
	m.kickoffs = int(ko.get("count", 0))
	m.kickoff_min_yards = float(ko.get("min_yards", 60.0))
	m.tee = as_tee
	var results: Array = t.get("results", [])
	m.kicks = mini(results.size(), m.distances.size())
	for i in m.kicks:
		if results[i]:
			m.makes += 1
	m.kickoffs_taken = maxi(results.size() - m.distances.size(), 0)
	return m


## Total kicks in the series (field goals + kickoffs).
static func total_kicks(t: Dictionary) -> int:
	var ko: Dictionary = t.get("kickoffs", {}) if t.get("kickoffs") is Dictionary else {}
	return (t.get("distances", []) as Array).size() + int(ko.get("count", 0))


## Field goals done, kickoffs still to take: the screen switches to a tee scene.
static func needs_tee(t: Dictionary) -> bool:
	var n := (t.get("distances", []) as Array).size()
	return (t.get("results", []) as Array).size() >= n and (t.get("results", []) as Array).size() < total_kicks(t)


func id() -> StringName:
	return &"career"


func kick_type() -> int:
	return KickSituation.KickType.KICKOFF if tee else KickSituation.KickType.FIELD_GOAL


## Wind for kick number `i`: from the seed, so a reload gets the same wind.
func wind_for(i: int) -> float:
	var r := RandomNumberGenerator.new()
	r.seed = hash([seed, i])
	return roundf(r.randf_range(0.0, wind_max)) * (1.0 if r.randf() < 0.5 else -1.0)


func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
	var s := KickSituation.new()
	var i := kicks + kickoffs_taken if tee else kicks
	var mph := wind_for(i)
	wind.set_conditions(rng, tuning, mph, 0.0)
	s.wind_mph = mph
	if tee:
		s.kick_type = KickSituation.KickType.KICKOFF
		s.kickoff_rules = kickoff_rules if kickoff_rules != null else KickoffRules.new()
		s.label = "%s  -  KICKOFF %d OF %d (%d+ YD)" % [title, mini(kickoffs_taken + 1, kickoffs), kickoffs,
			roundi(kickoff_min_yards)]
		return s
	s.distance_yards = int(distances[mini(kicks, distances.size() - 1)])
	# Pressure builds through the series.
	s.pressure = clampf(pressure + 0.08 * kicks, 0.0, 1.0)
	s.label = "%s  -  KICK %d OF %d" % [title, mini(kicks + 1, distances.size()), distances.size() + kickoffs]
	return s


func wants_next_kick() -> bool:
	return kickoffs_taken < kickoffs if tee else kicks < distances.size()


func record(r: KickReport) -> void:
	kicks += 1
	if r.made:
		makes += 1


## A kickoff's result (KickoffJudge, the scene's tee_result): made if it
## carries kickoff_min_yards or lands deep / for a touchback.
func record_kickoff(tee_result: Dictionary) -> bool:
	kickoffs_taken += 1
	return kickoff_good(tee_result, kickoff_min_yards)


static func kickoff_good(tee_result: Dictionary, min_yards: float) -> bool:
	return float(tee_result.get("carry", 0.0)) >= min_yards or str(tee_result.get("result", "")) in ["touchback", "deep"]
