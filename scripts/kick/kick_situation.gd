class_name KickSituation
extends RefCounted
## Everything that describes ONE attempt before it is kicked.
## Phase 1 rolls these randomly. Phase 2: the season/game sim creates them
## (real distance from the drive, real score/clock -> pressure).

const YARD_TO_M := 0.9144

## Fictional game situations. pressure is 0 (none) .. 1 (max).
const SCENARIOS := [
	{"label": "Practice rep", "pressure": 0.0, "weight": 3},
	{"label": "1st Quarter - up 7", "pressure": 0.15, "weight": 3},
	{"label": "End of half", "pressure": 0.35, "weight": 2},
	{"label": "4th Qtr - tie game", "pressure": 0.65, "weight": 2},
	{"label": "Down 2 - 0:03 left - GAME WINNER", "pressure": 1.0, "weight": 1},
]

## FIELD_GOAL / EXTRA_POINT: the place kick (snap, hold, block rush, posts).
## KICKOFF / ONSIDE: off a tee, judged where the ball lands (KickoffJudge).
## WARMUP_NET: off a tee into the sideline net (WarmupJudge), no game result.
enum KickType { FIELD_GOAL, EXTRA_POINT, KICKOFF, ONSIDE, WARMUP_NET }

var kick_type: KickType = KickType.FIELD_GOAL
## Tee kicks only: the stage's rules (spot, touchback, return...). null = defaults.
var kickoff_rules: KickoffRules
## Place kicks: the kick's distance. Tee kicks: yards from the tee to the
## receiving team's goal line (set from kickoff_rules.spot_yards).
var distance_yards: int = 30
## Signed crosswind, + pushes toward the kicker's right.
var wind_mph: float = 0.0
## Extra mph at peak gust (0 = steady).
var wind_gust_mph: float = 0.0
## Head / tailwind (signed mph, + = tailwind). Field goals only (KickDifficulty).
var wind_along_mph: float = 0.0
var pressure: float = 0.0
var label: String = ""


func distance_m() -> float:
	return distance_yards * YARD_TO_M


func is_tee_kick() -> bool:
	return is_tee_type(kick_type)


static func is_tee_type(t: KickType) -> bool:
	return t == KickType.KICKOFF or t == KickType.ONSIDE


## Anything that isn't a place kick (no snap, hold or block rush).
static func is_off_tee(t: KickType) -> bool:
	return is_tee_type(t) or t == KickType.WARMUP_NET


static func roll(rng: RandomNumberGenerator, tuning: KickTuning, wind: float) -> KickSituation:
	var s := KickSituation.new()
	s.distance_yards = rng.randi_range(tuning.min_distance_yards, tuning.max_distance_yards)
	s.wind_mph = wind
	var total := 0
	for sc in SCENARIOS:
		total += int(sc["weight"])
	var pick := rng.randi_range(1, total)
	for sc in SCENARIOS:
		pick -= int(sc["weight"])
		if pick <= 0:
			s.label = str(sc["label"])
			s.pressure = float(sc["pressure"])
			break
	return s
