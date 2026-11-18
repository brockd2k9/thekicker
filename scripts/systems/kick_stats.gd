class_name KickStats
extends RefCounted
## All-time kicking stats, saved between sessions (see SaveStore).
## Session numbers (since the app was opened) stay in GameState as before.
## Every mode feeds this through GameState.kick_resolved, so Career kicks will
## count here too without any changes.

const MISS_TYPES := ["wide_left", "wide_right", "short", "blocked"]

var attempts: int = 0
var makes: int = 0
var current_make_streak: int = 0
var longest_make_streak: int = 0
var current_miss_streak: int = 0
var longest_miss_streak: int = 0
## Longest made field goal, yards (0 = none yet).
var longest_make_yards: int = 0
## Miss counts by type (keys from MISS_TYPES).
var misses_by_type: Dictionary = {}
var challenge_runs: int = 0
var challenge_best_makes: int = 0


func _init() -> void:
	reset()


func reset() -> void:
	attempts = 0
	makes = 0
	current_make_streak = 0
	longest_make_streak = 0
	current_miss_streak = 0
	longest_miss_streak = 0
	longest_make_yards = 0
	misses_by_type = {}
	for t in MISS_TYPES:
		misses_by_type[t] = 0
	challenge_runs = 0
	challenge_best_makes = 0


func record_kick(r: KickReport) -> void:
	attempts += 1
	if r.made:
		makes += 1
		current_make_streak += 1
		current_miss_streak = 0
		longest_make_streak = maxi(longest_make_streak, current_make_streak)
		longest_make_yards = maxi(longest_make_yards, r.distance_yards)
	else:
		current_miss_streak += 1
		current_make_streak = 0
		longest_miss_streak = maxi(longest_miss_streak, current_miss_streak)
		var key := String(r.miss_type)
		misses_by_type[key] = int(misses_by_type.get(key, 0)) + 1


## summary: see ChallengeRules.summary().
func record_run(summary: Dictionary) -> void:
	if summary.get("mode", "") == "challenge":
		challenge_runs += 1
		challenge_best_makes = maxi(challenge_best_makes, int(summary.get("makes", 0)))


func accuracy_percent() -> int:
	if attempts == 0:
		return 0
	return roundi(100.0 * makes / attempts)


## Named stat lookup for achievement conditions, e.g. value("makes").
func value(key: String) -> float:
	var d := to_dict()
	return float(d.get(key, 0))


func to_dict() -> Dictionary:
	return {
		"attempts": attempts,
		"makes": makes,
		"current_make_streak": current_make_streak,
		"longest_make_streak": longest_make_streak,
		"current_miss_streak": current_miss_streak,
		"longest_miss_streak": longest_miss_streak,
		"longest_make_yards": longest_make_yards,
		"misses_by_type": misses_by_type.duplicate(),
		"challenge_runs": challenge_runs,
		"challenge_best_makes": challenge_best_makes,
	}


func from_dict(d: Dictionary) -> void:
	reset()
	attempts = int(d.get("attempts", 0))
	makes = int(d.get("makes", 0))
	current_make_streak = int(d.get("current_make_streak", 0))
	longest_make_streak = int(d.get("longest_make_streak", 0))
	current_miss_streak = int(d.get("current_miss_streak", 0))
	longest_miss_streak = int(d.get("longest_miss_streak", 0))
	longest_make_yards = int(d.get("longest_make_yards", 0))
	var m: Variant = d.get("misses_by_type", {})
	if m is Dictionary:
		for t in MISS_TYPES:
			misses_by_type[t] = int((m as Dictionary).get(t, 0))
	challenge_runs = int(d.get("challenge_runs", 0))
	challenge_best_makes = int(d.get("challenge_best_makes", 0))
