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
## Age at the start of the first high school season (freshman year).
@export var start_age: int = 14
@export var start_life: float = 70.0
@export var start_football: float = 30.0
@export var start_personality: float = 35.0

@export_group("Seasons")
## Seasons in each stage. Junior college counts as a short college detour.
@export var high_school_seasons: int = 4
@export var juco_seasons: int = 1
@export var college_seasons: int = 4
## Regular-season games and bye weeks per season (all stages for now).
@export var games_per_season: int = 10
@export var byes_per_season: int = 1
## Pro careers end at this age at the latest (you can retire after any pro season).
@export var pro_age_cap: int = 38
## The bye falls in a random week between these (inclusive).
@export var bye_week_earliest: int = 4
@export var bye_week_latest: int = 8
## Team strength (0-100) drifts by up to this much between seasons.
@export var team_strength_drift: float = 6.0

@export_group("Weekly Loop")
## Off-field scenarios in a game week: 1, plus a second one with this chance.
@export_range(0.0, 1.0) var second_scenario_chance: float = 0.4
## Scenarios in a bye week and in the offseason.
@export var bye_scenarios: int = 2
@export var offseason_scenarios: int = 1
## Applied at the end of every week (through the stat rules). Energy and
## Health recover, practice slowly builds every football stat.
@export var weekly_energy_recovery: float = 10.0
@export var weekly_health_recovery: float = 3.0
@export var weekly_football_growth: float = 0.15
## Every week each life stat also moves this fraction of the way back toward
## start_life, so streaks of good or bad weeks don't pin them at 0 or 100.
## 0 = off.
@export_range(0.0, 0.5) var weekly_life_drift: float = 0.1
## Extra recovery at the end of a bye week.
@export var bye_energy_recovery: float = 15.0
@export var bye_health_recovery: float = 10.0
## Between seasons: every football stat grows this much (before diminishing
## returns), and life stats move this fraction of the way back to start_life.
@export var offseason_football_growth: float = 2.0
@export_range(0.0, 1.0) var offseason_life_reset: float = 0.5
## Injury picked up in the weekly roll: weeks out of full health and severity.
@export var injury_weeks_min: int = 1
@export var injury_weeks_max: int = 3
@export var injury_severity_min: float = 0.3
@export var injury_severity_max: float = 0.8

@export_group("Game Sim")
## Drives per team per half. More drives = more kicks per game.
@export var drives_per_half: int = 4
## Minutes per quarter (shown on the game clock).
@export var quarter_minutes: int = 12
## Drive outcome odds for evenly matched teams; strength difference shifts
## them by strength_effect per 100 points of difference.
@export_range(0.0, 1.0) var base_td_chance: float = 0.27
@export_range(0.0, 1.0) var base_fg_chance: float = 0.17
@export var strength_effect: float = 0.5
## Chance an opponent's extra point is good (theirs are simulated).
@export_range(0.0, 1.0) var opponent_pat_chance: float = 0.9
## Chance an opponent's field goal is good (simulated).
@export_range(0.0, 1.0) var opponent_fg_chance: float = 0.65
## Field goal attempt distances (yards) at this stage.
@export var hs_fg_min_yards: int = 20
@export var hs_fg_max_yards: int = 48
## Extra point distance (yards) at this stage.
@export var hs_pat_yards: int = 20
## The coach won't send you out past this fraction of your max range.
@export_range(0.5, 1.0) var coach_range_trust: float = 0.85
## Situation pressure by quarter (Q1..Q4).
@export var quarter_pressure: PackedFloat32Array = PackedFloat32Array([0.1, 0.2, 0.3, 0.45])
## Extra pressure in a one-score game in the 4th quarter.
@export var close_game_pressure: float = 0.25
## Pressure for a kick that ties or wins it in the final 2 minutes.
@export var game_winner_pressure: float = 1.0
## Extra points carry this fraction of the situation pressure.
@export_range(0.0, 1.0) var pat_pressure_scale: float = 0.6
## Base crosswind for a game: up to this many mph, plus kick-to-kick jitter.
@export var game_wind_max_mph: float = 16.0
@export var kick_wind_jitter_mph: float = 3.0
@export_range(0.0, 1.0) var game_gust_chance: float = 0.35

@export_group("Game Results")
## Life-stat changes from the team result.
@export var win_fun: float = 6.0
@export var win_social: float = 4.0
@export var loss_fun: float = -4.0
@export var loss_social: float = -1.0
## Every game costs this (before the weekly recovery).
@export var game_energy_cost: float = -10.0
@export var game_health_cost: float = -3.0
## Per kick of yours (field goals and extra points).
@export var make_accuracy_gain: float = 0.15
## A make from this far or more also builds Power.
@export var long_make_yards: int = 40
@export var long_make_power_gain: float = 0.5
## A make under this much pressure builds Resilience (and Charisma).
@export_range(0.0, 1.0) var clutch_pressure: float = 0.6
@export var clutch_resilience_gain: float = 1.2
@export var clutch_charisma_gain: float = 2.0
@export var miss_fun: float = -2.0
@export var miss_resilience_gain: float = 0.3
## A perfect day (2+ kicks, no misses) adds this Fun.
@export var perfect_day_fun: float = 4.0
## Good kickoffs (touchback / pinned deep) build Power and Toughness a little.
@export var good_kickoff_power_gain: float = 0.3
@export var good_kickoff_toughness_gain: float = 0.2

@export_group("Sideline Kicks")
## Kickoffs, onside kicks and the warmup net are swiped on the sideline pad.
## Carry (yards) at 100% swipe power and power_mult 1.0.
@export var kickoff_max_carry_yards: float = 75.0
## Kicking off from your own 40 (high school): carry >= 60 lands in the end zone.
@export var kickoff_spot_yards: int = 40
## Aim more than this far off (degrees) = out of bounds.
@export var kickoff_oob_deg: float = 12.0
## How much a bad kickoff helps the opponent's next drive (TD chance + this * (1 - quality)).
@export var kickoff_quality_effect: float = 0.12
## Onside: carry must be in this window (yards) and aim within onside_aim_deg.
@export var onside_min_yards: float = 10.0
@export var onside_max_yards: float = 18.0
@export var onside_aim_deg: float = 15.0
## Recovery chance for a good / poor onside kick.
@export_range(0.0, 1.0) var onside_good_chance: float = 0.45
@export_range(0.0, 1.0) var onside_poor_chance: float = 0.08
## Onside kicks are called after a 4th-quarter score when trailing with this
## many seconds or fewer left.
@export var onside_clock_sec: int = 300
## Warmup net: a "pure" strike is power in this band and aim within net_aim_deg.
@export var net_power_min: float = 0.5
@export var net_power_max: float = 0.92
@export var net_aim_deg: float = 6.0
@export var net_kicks: int = 3
## Pure strikes needed for the best warmup result.
@export var net_pure_needed: int = 2

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
