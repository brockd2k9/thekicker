class_name CareerTuning
extends Resource
## Every Career Mode balance number lives here: the stat -> kick curves, low-stat
## penalties, caps, stat-gain rules, season lengths and stage settings.
##
## Two ways to tweak (same as KickTuning):
##   1. Open res://tuning/career_tuning.tres in the Inspector (values saved there
##      override the defaults below).
##   2. Change the defaults in this file.
##
## Stats are 0..100. "at 0" / "at 100" pairs are the value of a kick-profile
## field when the stat is 0 or 100; in between it follows the curve exponent
## (1 = straight line, >1 = the stat pays off late, <1 = early).
## Use the Career Debug screen (debug builds, Career Mode menu) to watch the
## resulting KickProfile while you drag the stats around.

const DEFAULT_PATH := "res://tuning/career_tuning.tres"

@export_group("Power -> Range")
## Multiplier on the kick's top launch speed (KickTuning.max_launch_speed).
## Swipe power needed (no wind) for 30 / 40 / 50 / 60 yd:
##   0.82 -> 47 / 66 / 83 / 99%    0.90 -> 40 / 56 / 70 / 83%
##   1.00 -> 33 / 46 / 58 / 69%    1.08 -> 29 / 41 / 51 / 61%
## (The Career Debug screen shows these for the current profile.)
## Value at Power 0.
@export var power_mult_at_0: float = 0.82
## Value at Power 100.
@export var power_mult_at_100: float = 1.08
@export_range(0.3, 3.0) var power_curve: float = 1.0

@export_group("Accuracy -> Aim")
## Random aim error at release (std-dev, degrees) at Accuracy 0.
@export var spread_at_0: float = 2.2
## Random aim error at release (std-dev, degrees) at Accuracy 100.
@export var spread_at_100: float = 0.2
@export_range(0.3, 3.0) var accuracy_curve: float = 1.0
## Pressure wobble multiplier at Accuracy 0 / 100.
@export var wobble_at_0: float = 1.35
@export var wobble_at_100: float = 0.75
## Kick-window (time to swipe after the hold) multiplier at Accuracy 0 / 100.
@export var window_at_0: float = 0.92
@export var window_at_100: float = 1.08

@export_group("Resilience -> Pressure")
## How hard situation pressure hits (wobble + shorter window) at Resilience 0 / 100.
@export var pressure_sens_at_0: float = 1.35
@export var pressure_sens_at_100: float = 0.7
## Extra pressure (0..1 scale) added per miss in a row during a game.
@export var miss_streak_pressure: float = 0.12
## Misses beyond this don't add more.
@export var miss_streak_cap: int = 3
## At Resilience 100 a miss streak hurts this much less (0.8 = 80% less).
@export_range(0.0, 1.0) var resilience_streak_shield: float = 0.8

@export_group("Toughness -> Wind & Injuries")
## Wind push multiplier at Toughness 0 / 100.
@export var wind_mult_at_0: float = 1.3
@export var wind_mult_at_100: float = 0.8
## At Toughness 100, injury penalties are this much smaller (0.6 = 60% smaller).
@export_range(0.0, 1.0) var toughness_injury_shield: float = 0.6
## Weekly injury chance is lowered by this much at Toughness 100.
@export var toughness_injury_risk_cut: float = 0.03

@export_group("Low Life Stats")
## Below its threshold a life stat starts to hurt; the penalty grows linearly to
## its full size at 0.
@export var low_energy_threshold: float = 35.0
## Power multiplier lost at Energy 0.
@export var low_energy_power: float = 0.08
## Wobble multiplier added at Energy 0.
@export var low_energy_wobble: float = 0.35
@export var low_health_threshold: float = 35.0
## Aim error (degrees) added at Health 0.
@export var low_health_spread: float = 1.0
## Weekly injury chance added at Health 0.
@export var low_health_injury: float = 0.12
@export var low_fun_threshold: float = 30.0
## Resilience gains are multiplied by this while Fun is low.
@export_range(0.0, 1.0) var low_fun_resilience_gain_mult: float = 0.5
@export var low_social_threshold: float = 30.0
## Pressure sensitivity added at Social 0 (low morale).
@export var low_social_pressure: float = 0.15

@export_group("Injuries")
## Base weekly chance of picking up an injury.
@export var injury_base_risk: float = 0.03
## Power multiplier lost while playing hurt at severity 1 (before Toughness).
@export var injury_power: float = 0.1
## Aim error (degrees) added while playing hurt at severity 1 (before Toughness).
@export var injury_spread: float = 1.2

@export_group("Profile Caps")
## Final clamps on the kick profile, after stats, traits and game-day modifiers.
@export var power_mult_min: float = 0.7
@export var power_mult_max: float = 1.15
@export var spread_max: float = 4.0
@export var wobble_mult_min: float = 0.5
@export var wobble_mult_max: float = 2.0
@export var window_mult_min: float = 0.8
@export var window_mult_max: float = 1.2
@export var pressure_sens_min: float = 0.5
@export var pressure_sens_max: float = 1.8
@export var pressure_add_max: float = 0.4
@export var wind_mult_min: float = 0.6
@export var wind_mult_max: float = 1.5
@export var injury_risk_max: float = 0.35

@export_group("Stat Gains")
## Football stat gains shrink as the stat climbs: gain *= 1 - this * value/100.
## 0 = no diminishing returns, 0.6 = a gain at 100 is 40% of a gain at 0.
@export_range(0.0, 1.0) var football_diminishing: float = 0.5
## Personality changes are multiplied by this ("they change slowly").
@export_range(0.0, 2.0) var personality_change_scale: float = 0.5

@export_group("New Career")
@export var start_age: int = 15
@export var start_life: float = 70.0
@export var start_football: float = 30.0
@export var start_personality: float = 35.0

@export_group("Seasons")
## Seasons in each stage. Junior college counts as a short college detour.
@export var high_school_seasons: int = 3
@export var juco_seasons: int = 1
@export var college_seasons: int = 4
## Regular-season games and bye weeks per season (all stages for now).
@export var games_per_season: int = 10
@export var byes_per_season: int = 1
## Pro careers end at this age at the latest (you can retire after any pro season).
@export var pro_age_cap: int = 38

@export_group("Goalposts")
## Inner width between the uprights, meters, per stage (used from Stage 5).
## Regulation: 7.11 m (23 ft 4 in) high school, 5.64 m (18 ft 6 in) college/pro.
## Pro is tightened a little on purpose for difficulty.
@export var goal_width_high_school: float = 7.11
@export var goal_width_college: float = 5.64
@export var goal_width_pro: float = 5.3


static var _cached: CareerTuning


## The tuning resource the game uses (loads the .tres once).
static func get_default() -> CareerTuning:
	if _cached == null:
		var t: Variant = load(DEFAULT_PATH) if ResourceLoader.exists(DEFAULT_PATH) else null
		_cached = t if t is CareerTuning else CareerTuning.new()
	return _cached


## Linear (or curved) blend between an "at 0" and "at 100" value.
static func blend(at_0: float, at_100: float, stat: float, curve: float = 1.0) -> float:
	var x := clampf(stat / 100.0, 0.0, 1.0)
	return lerpf(at_0, at_100, pow(x, curve))


## 0 above the threshold, rising to 1 at stat 0.
static func lowness(stat: float, threshold: float) -> float:
	if threshold <= 0.0:
		return 0.0
	return clampf((threshold - stat) / threshold, 0.0, 1.0)


func goal_width_for(stage: String) -> float:
	match stage:
		CareerData.STAGE_HIGH_SCHOOL:
			return goal_width_high_school
		CareerData.STAGE_COLLEGE, CareerData.STAGE_JUCO:
			return goal_width_college
	return goal_width_pro
