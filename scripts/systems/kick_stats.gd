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
## Career Mode, across every career (kicks = field goals, extra points and
## tryout kicks reported with mode "career").
var careers_started: int = 0
var careers_completed: int = 0
var career_attempts: int = 0
var career_makes: int = 0
## Longest career so far, in seasons played.
var longest_career_seasons: int = 0
## Best result so far: a rank (stage * 100 + pro seasons) and its text,
## e.g. "Pro, 6 seasons (Metro Monarchs)".
var best_career_rank: int = 0
var best_career_text: String = ""


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
	careers_started = 0
	careers_completed = 0
	career_attempts = 0
	career_makes = 0
	longest_career_seasons = 0
	best_career_rank = 0
	best_career_text = ""


func record_kick(r: KickReport) -> void:
	attempts += 1
	if r.mode == &"career":
		career_attempts += 1
		if r.made:
			career_makes += 1
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


## e: a Career Mode event (see GameState.report_career_event).
## "seasons", "rank" and "result_text" ride along on season_end / retired.
func record_career_event(e: Dictionary) -> void:
	match str(e.get("event", "")):
		"career_started":
			careers_started += 1
		"retired":
			careers_completed += 1
	if e.has("seasons"):
		longest_career_seasons = maxi(longest_career_seasons, int(e["seasons"]))
	if e.has("rank") and int(e["rank"]) > best_career_rank:
		best_career_rank = int(e["rank"])
		best_career_text = str(e.get("result_text", ""))


func accuracy_percent() -> int:
	if attempts == 0:
		return 0
	return roundi(100.0 * makes / attempts)


## Named stat lookup for achievement conditions, e.g. value("makes").
func value(key: String) -> float:
	var v: Variant = to_dict().get(key, 0)
	return float(v) if (v is int or v is float) else 0.0


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
		"careers_started": careers_started,
		"careers_completed": careers_completed,
		"career_attempts": career_attempts,
		"career_makes": career_makes,
		"longest_career_seasons": longest_career_seasons,
		"best_career_rank": best_career_rank,
		"best_career_text": best_career_text,
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
	careers_started = int(d.get("careers_started", 0))
	careers_completed = int(d.get("careers_completed", 0))
	career_attempts = int(d.get("career_attempts", 0))
	career_makes = int(d.get("career_makes", 0))
	longest_career_seasons = int(d.get("longest_career_seasons", 0))
	best_career_rank = int(d.get("best_career_rank", 0))
	best_career_text = str(d.get("best_career_text", ""))
