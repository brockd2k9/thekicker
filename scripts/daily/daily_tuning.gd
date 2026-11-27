class_name DailyTuning
extends Resource
## Every Daily Challenge number in one place. Defaults and docs live here;
## res://tuning/daily_tuning.tres can override any of them in the Inspector.
##
## Reward scale, for comparison (tools/career_sim_baseline.md): a career season
## earns about 45 skill points (practice 9, field goals 9, choices 8, offseason
## 6, warmups 5...). One attribute point costs 1-15 SP (about 3 at 50, 6 at 70,
## 12 at 90). Daily rewards are weekly only: 10 SP for 7 successful days in a
## row, so a perfect 30 days pays 40 SP (4 weeks), a bit under one season.

const DEFAULT_PATH := "res://tuning/daily_tuning.tres"
static var _cached: DailyTuning

@export_group("Rewards")
## Days of successful challenges in a row that make a week (the track's slots).
@export var week_days: int = 7
## Skill points paid on the last day of each completed week (as soon as that
## day's kick is made). Days before it pay nothing.
@export var sp_weekly: int = 10
## Optional: extra skill points for each consecutive completed week in the same
## streak (week 2 pays sp_weekly + this, week 3 + 2x...). 0 = off.
@export var consecutive_week_bonus: int = 0
## Source line for the career's skill points (Results, season history).
@export var sp_source_text: String = "Daily Challenge"

@export_group("Retry, ads and streak saver")
## Rewarded-ad retries per day after a miss.
@export var ad_retries_per_day: int = 1
## "auto": through the AdManager autoload (AdMob on phones, Mock in the editor
## and desktop debug, None on Steam / desktop release; rules and IDs in
## MonetizationConfig); "stub": always the instant stub (no AdManager);
## "none": never ads.
@export_enum("auto", "stub", "none") var ad_mode: String = "auto"
## Force the "no ads" platform behavior (e.g. a Steam build without the tag).
@export var no_ads_platform: bool = false
## What a platform without ads does where an ad would go (retry and streak
## saver): "none" = not offered; "free" = offered without an ad.
@export_enum("none", "free") var no_ads_rule: String = "none"
## The streak saver: after ONE missed day, restore the streak with a rewarded
## ad on the day you come back (once per streak).
@export var streak_saver_enabled: bool = true
## Stub ad (ad_mode "stub" only; the editor's normal mock is AdManager's):
## how long the placeholder shows, and whether it "fills" (false = offline).
@export var stub_ad_seconds: float = 1.5
@export var stub_ad_fill: bool = true

@export_group("Day and clock")
## The day starts at this local hour (0 = midnight). DailyClock.day_number().
@export_range(0, 23) var day_start_hour: int = 0
## The device clock may step back this many seconds (sync jitter) before the
## game calls it a backward clock.
@export var clock_back_tolerance_sec: int = 300

@export_group("Difficulty")
## Difficulty 0..1 by weekday, Monday first. Saturday is the boss kick.
@export var weekday_difficulty: Array[float] = [0.1, 0.2, 0.32, 0.44, 0.55, 1.0, 0.62]
## Boss day (0 = Monday .. 6 = Sunday).
@export var boss_weekday: int = 5
## Field goal distance range by skill tier (Rookie, Varsity, College, Pro):
## difficulty 0 -> the min, 1 -> the max.
@export var fg_min_yards: Array[int] = [22, 25, 28, 32]
@export var fg_max_yards: Array[int] = [38, 45, 51, 56]
## Extra point distance by tier (pro PATs are from the 15).
@export var xp_yards: Array[int] = [20, 20, 20, 33]
## Kickoff tee spot by tier (high school kicks from the 40).
@export var kickoff_spot: Array[int] = [40, 35, 35, 35]
## Wind (mph) at difficulty 0 and 1 (each day rolls 0..this), and gusts from
## gust_from_difficulty on, up to gust_max_mph.
@export var wind_min_mph: float = 3.0
@export var wind_max_mph: float = 16.0
@export var gust_from_difficulty: float = 0.5
@export var gust_max_mph: float = 8.0
## Head / tailwind (mph) at difficulty 1.
@export var along_max_mph: float = 6.0
## Situation pressure is scaled from this (difficulty 0) to 1.0 (difficulty 1).
@export var pressure_floor: float = 0.5
## Kick type odds on non-boss days (the rest are field goals).
@export var chance_extra_point: float = 0.12
@export var chance_kickoff: float = 0.12
@export var chance_onside: float = 0.06
## Weather and field effects are scaled by this per tier (Rookie gets half).
@export var conditions_scale: Array[float] = [0.5, 0.8, 1.0, 1.0]
## FG range (Career) that starts each tier above Rookie: Varsity, College, Pro.
@export var tier_range_yards: Array[float] = [46.0, 52.0, 58.0]
## Without a career: all-time accuracy that starts Varsity / College (after
## tier_min_kicks kicks).
@export var tier_accuracy: Array[float] = [60.0, 75.0]
@export var tier_min_kicks: int = 40


static func get_default() -> DailyTuning:
	if _cached == null:
		var t: Variant = load(DEFAULT_PATH) if ResourceLoader.exists(DEFAULT_PATH) else null
		_cached = t if t is DailyTuning else DailyTuning.new()
	return _cached


## True when streak day n (1 = the first day of a streak) completes a week.
func is_week_end(n: int) -> bool:
	return n > 0 and week_days > 0 and n % week_days == 0


## The payout for the n-th consecutive completed week of a streak (1 = first).
func week_reward(week: int) -> int:
	return maxi(sp_weekly + maxi(consecutive_week_bonus, 0) * maxi(week - 1, 0), 0)


## What streak day n pays: the week's payout on a week's last day, else 0.
func reward_for(n: int) -> int:
	return week_reward(n / week_days) if is_week_end(n) else 0


## Total skill points for a perfect run of `days` (for docs and tests).
func total_for(days: int) -> int:
	var s := 0
	for n in range(1, days + 1):
		s += reward_for(n)
	return s
