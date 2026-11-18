class_name ChallengeRules
extends KickMode
## Challenge Mode: a run of kicks that get longer, windier and more pressured.
## Three misses and the run is over. Blocks count as misses.
## All difficulty numbers are here.

const MAX_MISSES := 3

## Distance: START_YARDS on kick 1, +YARDS_PER_KICK each kick, +/- jitter,
## capped by KickTuning min/max_distance_yards.
const START_YARDS := 25
const YARDS_PER_KICK := 3.0
const YARDS_JITTER := 2
## Wind: calm for the first CALM_KICKS kicks, then grows WIND_PER_KICK mph per
## kick (random direction) up to KickTuning.max_wind_mph.
const CALM_KICKS := 2
const WIND_PER_KICK := 1.5
## Gusts can appear from this kick on, growing GUST_PER_KICK mph per kick
## up to KickTuning.max_gust_mph.
const GUSTS_FROM_KICK := 7
const GUST_CHANCE := 0.5
const GUST_PER_KICK := 1.5
## Pressure 0..1: +PRESSURE_PER_KICK per kick (max reached on kick 13).
const PRESSURE_PER_KICK := 0.083

var kicks: int = 0
var makes: int = 0
var misses: int = 0
var streak: int = 0
var best_streak: int = 0
var longest_make: int = 0
var total_yards: int = 0


func id() -> StringName:
	return &"challenge"


func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
	var n := kicks  # 0-based index of the kick about to be taken
	var s := KickSituation.new()
	s.distance_yards = clampi(
		START_YARDS + roundi(n * YARDS_PER_KICK) + rng.randi_range(-YARDS_JITTER, YARDS_JITTER),
		tuning.min_distance_yards, tuning.max_distance_yards)

	var base := 0.0
	var gust := 0.0
	if n >= CALM_KICKS:
		var strength := minf((n - CALM_KICKS + 1) * WIND_PER_KICK + rng.randf_range(-1.0, 1.0),
			tuning.max_wind_mph)
		base = roundf(maxf(strength, 1.0)) * (1.0 if rng.randf() < 0.5 else -1.0)
		if n >= GUSTS_FROM_KICK and rng.randf() < GUST_CHANCE:
			var top := minf((n - GUSTS_FROM_KICK + 1) * GUST_PER_KICK, tuning.max_gust_mph)
			gust = roundf(rng.randf_range(0.5, 1.0) * top)
	wind.set_conditions(rng, tuning, base, gust)
	s.wind_mph = base
	s.wind_gust_mph = gust

	s.pressure = clampf(n * PRESSURE_PER_KICK, 0.0, 1.0)
	s.label = "CHALLENGE  -  KICK %d" % (n + 1)
	return s


func wants_next_kick() -> bool:
	return not is_over()


func is_over() -> bool:
	return misses >= MAX_MISSES


func record(r: KickReport) -> void:
	kicks += 1
	if r.made:
		makes += 1
		streak += 1
		best_streak = maxi(best_streak, streak)
		longest_make = maxi(longest_make, r.distance_yards)
		total_yards += r.distance_yards
	else:
		misses += 1
		streak = 0


func misses_left() -> int:
	return maxi(MAX_MISSES - misses, 0)


## Sent to GameState.report_run() when the run ends.
func summary() -> Dictionary:
	return {
		"mode": "challenge",
		"kicks": kicks,
		"makes": makes,
		"misses": misses,
		"best_streak": best_streak,
		"longest_make": longest_make,
		"total_yards": total_yards,
	}
