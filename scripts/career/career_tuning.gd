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
## Field goal range (yards): the longest kick a full-strength flick clears
## with no wind. range_at_start at Power range_power_start (a new freshman),
## rising to range_at_100 at Power 100 along x^range_curve, where
## x = (Power - range_power_start) / (100 - range_power_start). A curve below 1
## means early points buy more yards than late ones (diminishing returns).
## Perks add to it; game-day life stats add or take a few yards (below).
## Power 30/40/50/60/70/80/90/100 -> 40/46/50/54/57/60/63/66 yd.
@export var range_power_start: float = 30.0
@export var range_at_start: float = 40.0
@export var range_at_100: float = 66.0
@export_range(0.3, 2.0) var range_curve: float = 0.75
## Hard cap on range after perks and game-day changes; and the shortest it can get.
@export var range_cap: float = 70.0
@export var range_min: float = 30.0
## The kick's launch speed is set so 100% power clears the crossbar at
## range + this (so a kick right at your range doesn't clip the bar).
@export var range_physics_margin_yd: float = 0.5
## Kickoff range (yards of carry at a full flick): its own Power curve.
## Power 30/50/70/100 -> 52/61/67/75 yd. A touchback needs 60 (high school,
## tee on the 40) or 65 (college and pro, tee on the 35).
@export var kickoff_at_start: float = 52.0
@export var kickoff_at_100: float = 75.0
@export_range(0.3, 2.0) var kickoff_curve: float = 0.75
@export var kickoff_range_cap: float = 80.0

@export_group("Game Day Range")
## Yards added or taken on game day by life stats (shown on the Outlook).
## Energy at or above rested_energy: +rested_range_yd.
@export var rested_energy: float = 75.0
@export var rested_range_yd: float = 2.0
## Health at or above healthy_health: +healthy_range_yd.
@export var healthy_health: float = 85.0
@export var healthy_range_yd: float = 1.0
## Yards lost at Energy 0 / Health 0 (grows from the low threshold down).
@export var low_energy_range_yd: float = 4.0
@export var low_health_range_yd: float = 3.0
## Yards lost while injured at severity 1 (Toughness shields part of it).
@export var injury_range_yd: float = 6.0
## Game-day modifiers in data that still use the old "power_mult" key are read
## as this many yards per 1.0 (so -0.05 = -2 yd).
@export var legacy_power_mult_yards: float = 40.0

@export_group("Weather")
## Late in the season (from this fraction of the weeks on) a game can be cold
## or snowy. Rolled when the week starts; shown on the Game Day Outlook.
@export_range(0.0, 1.0) var late_season_from: float = 0.6
@export_range(0.0, 1.0) var cold_chance: float = 0.25
@export_range(0.0, 1.0) var snow_chance: float = 0.1
## Cold: the ball doesn't carry. Yards lost (rolled per game, whole yards).
@export var cold_range_min: int = 1
@export var cold_range_max: int = 2
## Snow: yards lost, plus aim error (degrees) from slick footing.
@export var snow_range_min: int = 2
@export var snow_range_max: int = 3
@export var snow_spread: float = 0.25

@export_group("Aging")
## From this age on, football attributes decline at the end of every season
## unless preserved with skill points (Skills screen, Maintenance).
## Decline (points) = (aging_base + aging_per_year * (age - aging_start_age))
## * the attribute's rate. Ages 30 / 35 / 38 -> 1.0 / 3.5 / 5.0 at rate 1.
@export var aging_start_age: int = 30
@export var aging_base: float = 1.0
@export var aging_per_year: float = 0.5
@export var aging_rate_power: float = 1.0
@export var aging_rate_toughness: float = 1.0
@export var aging_rate_accuracy: float = 0.6
@export var aging_rate_resilience: float = 0.3
## Preserving an attribute for a season costs decline * (cost of its next
## point) * this, rounded up. Level 85 at age 30 / 35 / 38: ~5 / 17 / 24 SP.
@export var maintain_cost_mult: float = 0.6

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
@export var low_energy_threshold: float = 40.0
## Wobble multiplier added at Energy 0.
@export var low_energy_wobble: float = 0.35
@export var low_health_threshold: float = 40.0
## Aim error (degrees) added at Health 0.
@export var low_health_spread: float = 1.0
## Weekly injury chance added at Health 0.
@export var low_health_injury: float = 0.12
@export var low_fun_threshold: float = 40.0
## Resilience gains are multiplied by this while Fun is low.
@export_range(0.0, 1.0) var low_fun_resilience_gain_mult: float = 0.5
@export var low_social_threshold: float = 40.0
## Pressure sensitivity added at Social 0 (low morale).
@export var low_social_pressure: float = 0.15

@export_group("Injuries")
## Base weekly chance of picking up an injury.
@export var injury_base_risk: float = 0.03
## Aim error (degrees) added while playing hurt at severity 1 (before Toughness).
@export var injury_spread: float = 1.2

@export_group("Profile Caps")
## Final clamps on the kick profile, after stats, traits and game-day modifiers.
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
@export_range(0.0, 1.0) var football_diminishing: float = 0.85
## Increases to Fun and Social (scenarios, wins, recovery) are multiplied by
## this, so they don't sit near 100; Fun and Social have to be looked after.
@export_range(0.0, 2.0) var fun_social_gain_mult: float = 0.7
## Personality changes are multiplied by this ("they change slowly").
@export_range(0.0, 2.0) var personality_change_scale: float = 0.3

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
@export var offseason_scenarios: int = 2
## Applied at the end of every week (through the stat rules). Energy and
## Health recover. weekly_football_growth is 0: football attributes now grow
## through skill points (group "Skill Points"); the knob is kept.
@export var weekly_energy_recovery: float = 10.0
@export var weekly_health_recovery: float = 2.0
@export var weekly_football_growth: float = 0.0
## Every week each life stat also moves this fraction of the way back toward
## life_baseline, so streaks of good or bad weeks don't pin them at 0 or 100.
## 0 = off.
@export_range(0.0, 0.5) var weekly_life_drift: float = 0.1
## Where life stats settle when nothing is happening (the weekly drift target).
## Below start_life on purpose: you have to keep them up.
@export var life_baseline: float = 60.0
## Extra recovery at the end of a bye week.
@export var bye_energy_recovery: float = 15.0
@export var bye_health_recovery: float = 10.0
## Between seasons: every football stat grows this much (0: skill points do
## it now), and life stats move this fraction of the way back to start_life.
@export var offseason_football_growth: float = 0.0
@export_range(0.0, 1.0) var offseason_life_reset: float = 0.5
## Injury picked up in the weekly roll: weeks out of full health and severity.
@export var injury_weeks_min: int = 1
@export var injury_weeks_max: int = 3
@export var injury_severity_min: float = 0.3
@export var injury_severity_max: float = 0.8

@export_group("Scenario Picks")
## Repetition guard: the same scenario at most this many times per season.
@export var max_scenario_repeats_per_season: int = 2
## Each time a category already appeared this season, its scenarios' weight is
## multiplied by this (0.5 = half as likely after one, a quarter after two).
@export_range(0.0, 1.0) var category_repeat_decay: float = 0.5
## Never two scenarios of the same category in one week.
@export var no_repeat_category_in_week: bool = true
## While Social is below low_social_threshold, scenarios in these categories
## are this much less likely (fewer invitations when you're isolated).
@export_range(0.0, 1.0) var low_social_weight_mult: float = 0.3
@export var social_categories: PackedStringArray = PackedStringArray(["social", "romance", "media", "community"])
## Story scenarios ("story": true in the data) are this much more likely while
## their week window is open; in the window's last week they're forced.
@export var story_weight_mult: float = 4.0
## At most this many forced scenarios a week (story scenarios at the end of
## their window, due follow-ups, story beats). Follow-ups and beats over the
## cap wait a week; random picks still fill up to the week's normal count.
@export var max_forced_per_week: int = 2

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
@export var hs_fg_max_yards: int = 50
## Extra point distance (yards) at this stage.
@export var hs_pat_yards: int = 20
## The coach knows your range: the longest field goal he calls is your
## game-day range minus this margin (plus the coach relationship and minus
## coach doubt, group "Relationships").
@export var coach_range_margin_yd: float = 2.0
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
@export var win_fun: float = 3.0
@export var win_social: float = 2.0
@export var loss_fun: float = -4.0
@export var loss_social: float = -1.0
## Every game costs this (before the weekly recovery).
@export var game_energy_cost: float = -12.0
@export var game_health_cost: float = -3.0
## Direct football stat changes from your kicks. All 0 now: kicks earn skill
## points instead (group "Skill Points"). The knobs are kept.
@export var make_accuracy_gain: float = 0.0
## A make from this far or more counts as a long make (skill points, Power gain).
@export var long_make_yards: int = 45
@export var long_make_power_gain: float = 0.0
## A make under this much pressure is a clutch make (skill points, Charisma).
@export_range(0.0, 1.0) var clutch_pressure: float = 0.6
@export var clutch_resilience_gain: float = 0.0
@export var clutch_charisma_gain: float = 2.0
@export var miss_fun: float = -2.0
@export var miss_resilience_gain: float = 0.0
## A perfect day (2+ kicks, no misses) adds this Fun.
@export var perfect_day_fun: float = 2.0
## Good kickoffs (touchback / pinned deep): direct Power / Toughness gain (0 now).
@export var good_kickoff_power_gain: float = 0.0
@export var good_kickoff_toughness_gain: float = 0.0

@export_group("Sideline Kicks")
## Kickoffs, onside kicks and the sideline warmup net (all in the 3D kick scene).
## Carry (yards) at 100% swipe power and power_mult 1.0.
@export var kickoff_max_carry_yards: float = 75.0
## Kicking off from your own 40 (high school): carry >= 60 lands in the end zone.
@export var kickoff_spot_yards: int = 40
## College and pro kick off from their own 35 (75 yards of carry for a touchback).
@export var kickoff_spot_yards_college: int = 35
@export var kickoff_spot_yards_pro: int = 35
## Where the receiving team starts after a touchback, per stage.
@export var touchback_spot_hs: int = 20
@export var touchback_spot_college: int = 25
@export var touchback_spot_pro: int = 30
## Where the receiving team starts after a kickoff out of bounds, per stage.
@export var kickoff_oob_spot_hs: int = 35
@export var kickoff_oob_spot_college: int = 35
@export var kickoff_oob_spot_pro: int = 40
## Kickoff return: yards gained from where the ball is fielded (random in this
## range), minus kickoff_return_hang_cut per second of hang time over 3 s.
@export var kickoff_return_min_yards: float = 15.0
@export var kickoff_return_max_yards: float = 30.0
@export var kickoff_return_hang_cut: float = 4.0
## Only used by the balance simulator's stand-in kickoffs now (the 3D kickoff
## judges out of bounds from where the ball lands, wind included).
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

@export_group("Stage Difficulty")
## Field goal attempt distances and extra point distance (yards) per stage.
## A college's tier can lower the college max (progression.json fg_max_yards).
@export var college_fg_min_yards: int = 22
@export var college_fg_max_yards: int = 58
@export var college_pat_yards: int = 20
@export var pro_fg_min_yards: int = 25
@export var pro_fg_max_yards: int = 62
@export var pro_pat_yards: int = 33
## Extra situation pressure on every kick (bigger crowds, bigger stakes).
## College tiers add their own pressure_bonus on top.
@export var college_pressure_bonus: float = 0.05
@export var pro_pressure_bonus: float = 0.12
## Strongest game-day crosswind per stage (high school uses game_wind_max_mph).
@export var college_wind_max_mph: float = 18.0
@export var pro_wind_max_mph: float = 20.0

@export_group("Academics")
## GPA on a 0-4 scale. Scenario choices change it ("grades" in the data).
@export var start_gpa: float = 2.9
## Each season GPA moves by this * (Intelligence - 50) / 50.
@export var gpa_intelligence_drift: float = 0.12
## In college, below this GPA you're academically ineligible: you sit out
## games until it's back up (the game is simulated without you).
@export var college_min_gpa: float = 2.0

@export_group("Recruiting")
## Recruiting score (0-100) gained at the end of each high school season:
## season_weight * (base + fg_pct * (FG% - 65) + long * yards past 35 +
## record * (wins - losses) + leg * ((Power + Accuracy) / 2 - 50)),
## plus scenario choices ("recruiting" in the data) and trait bonuses.
@export var recruiting_season_weights: PackedFloat32Array = PackedFloat32Array([0.4, 0.7, 1.0, 1.0])
@export var recruiting_base: float = 1.5
@export var recruiting_fg_pct: float = 0.3
@export var recruiting_long: float = 0.5
@export var recruiting_record: float = 0.5
@export var recruiting_leg: float = 0.15
## Points per yard of field goal range past recruiting_range_from.
@export var recruiting_range: float = 0.6
@export var recruiting_range_from: float = 45.0
## A junior college season counts this much (then offers come again).
@export var juco_recruiting_weight: float = 1.4

@export_group("Draft")
## Draft score (0-100) gained each college season, times the school's exposure:
## season_weight * (base + fg_pct * (FG% - 70) + long * yards past 40 +
## record * (wins - losses) + leg * ((Power + Accuracy) / 2 - 55)),
## plus choices ("draft" in the data) and trait bonuses.
@export var draft_season_weights: PackedFloat32Array = PackedFloat32Array([0.4, 0.6, 0.9, 1.1])
@export var draft_base: float = 2.5
@export var draft_fg_pct: float = 0.35
@export var draft_long: float = 0.5
@export var draft_record: float = 0.4
@export var draft_leg: float = 0.2
## Points per yard of field goal range past draft_range_from.
@export var draft_range: float = 0.6
@export var draft_range_from: float = 52.0

@export_group("Pro Contracts")
## Retention (0-100) at the end of each pro season: 50 + fg_pct * (FG% - 80)
## + long * yards past 45 + clutch * game winners - age * years past 32,
## plus this season's choices ("retention" in the data) and trait bonuses.
@export var retention_fg_pct: float = 1.2
@export var retention_long: float = 0.6
@export var retention_clutch: float = 4.0
@export var retention_age: float = 5.0
## Points per yard of field goal range past retention_range_from.
@export var retention_range: float = 0.3
@export var retention_range_from: float = 55.0
## Below this you're released (even mid-contract).
@export var release_below: float = 35.0
## At contract end the team re-signs you at this retention or more.
@export var resign_min: float = 50.0

@export_group("Relationships")
## The recurring cast (data/career/people.json). Values are 0..100 and start at
## rel_start. Every effect below is "at 100"; it scales linearly to 0 at 50 and
## flips sign below 50 (at 0 it's the full amount the other way). So a fresh
## career (everyone at 50) plays exactly as without relationships.
@export var rel_start: float = 50.0
## Each week every value moves this fraction of the way back toward 50.
@export_range(0.0, 0.5) var rel_weekly_drift: float = 0.02
## Head coach: change in pressure sensitivity (negative = calmer kicks).
@export var rel_coach_pressure: float = -0.12
## Head coach: yards added to (at 100) or taken from (at 0) the longest field
## goal he calls.
@export var rel_coach_range_yd: float = 2.0
## Holder: change in aim spread in degrees (negative = cleaner holds).
@export var rel_holder_spread: float = -0.25
## Dad and your little brother: extra Energy recovered every week (each).
@export var rel_family_energy: float = 1.5
## Best friend and someone special: weekly Fun and Social drift (each).
@export var rel_friend_fun: float = 1.0
@export var rel_friend_social: float = 1.0
## Teacher / academic advisor: GPA points added each season.
@export var rel_teacher_gpa: float = 0.08
## Tyler Brooks (once you've met him). Friend side (above 50): pressure
## sensitivity change at 100. Rival side (below 50): extra skill points per
## week at 0 (he pushes you; rel_tyler_rival_growth, the old direct football
## growth, is 0). Each applies only on its own side.
@export var rel_tyler_friend_pressure: float = -0.06
@export var rel_tyler_rival_growth: float = 0.0
@export var rel_tyler_rival_sp: float = 1.0
## Playing against Tyler's team: pressure_add at 0 (bitter rival) and the
## same amount off at 100 (friend). Linear through 50 like the rest.
@export var rel_tyler_game_pressure: float = 0.06
## Recruiting, final high school (or junior college) season only: a coach at
## or above rec_high recommends you (+rel_rec_bonus recruiting points); at or
## below rec_low the coach's lukewarm word costs rel_rec_penalty.
@export var rel_rec_high: float = 70.0
@export var rel_rec_bonus: float = 6.0
@export var rel_rec_low: float = 25.0
@export var rel_rec_penalty: float = 4.0
## A teacher at or above this vouches for you: college GPA minimums are
## checked against your GPA plus rel_teacher_gpa_grace.
@export var rel_teacher_vouch: float = 70.0
@export var rel_teacher_gpa_grace: float = 0.1
## Team standing (your teammates' trust): pressure sensitivity change at 100.
@export var rel_team_pressure: float = -0.08
## Trust (coach recommendation): rel_trust_coach_weight * Coach + the rest * Team.
## Recruiting uses it in the final high school / junior college season (the
## rec_high / rec_low thresholds above); the draft gets up to +/- rel_draft_rec
## points every college season, scaled linearly from 50.
@export_range(0.0, 1.0) var rel_trust_coach_weight: float = 0.7
@export var rel_draft_rec: float = 3.0

## --- Kick results (every field goal and extra point you kick) ---
## Base change to Coach / Team for a miss and for a make, before multipliers.
@export var kick_miss_coach: float = -4.0
@export var kick_miss_team: float = -3.0
@export var kick_make_coach: float = 1.5
@export var kick_make_team: float = 1.0
## Situation: the largest that applies. A game winner is a go-ahead kick in
## the final 2 minutes (the GAME WINNER tag); go-ahead and tying are 4th quarter.
@export var kick_mult_game_winner: float = 3.0
@export var kick_mult_go_ahead: float = 2.0
@export var kick_mult_tying: float = 1.8
@export var kick_mult_close_late: float = 1.6
@export var kick_mult_high_pressure: float = 1.4
@export var kick_mult_q4: float = 1.25
## "Close" for close_late: a 4th-quarter kick with the score within this many points.
@export var kick_close_points: int = 8
## High pressure: situation pressure at or above this.
@export_range(0.0, 1.0) var kick_high_pressure: float = 0.6
## Difficulty. Easy: at most kick_easy_yards, or at most kick_easy_range_frac of
## your range. Edge: within kick_edge_yards of your range.
@export var kick_easy_yards: int = 30
@export_range(0.0, 1.0) var kick_easy_range_frac: float = 0.55
@export var kick_edge_yards: int = 5
@export var kick_easy_miss_mult: float = 1.5
@export var kick_easy_make_mult: float = 0.7
@export var kick_edge_miss_mult: float = 0.5
@export var kick_edge_make_mult: float = 1.5
## Extra points count this much (miss / make).
@export var kick_pat_miss_mult: float = 0.5
@export var kick_pat_make_mult: float = 0.25
## Softening on misses: Resilience (both) and Leadership (Team only), at 100.
@export_range(0.0, 1.0) var kick_resilience_soften: float = 0.25
@export_range(0.0, 1.0) var kick_leadership_soften: float = 0.3
## Recovery: while the coach is below 50, makes count this much more at
## Resilience 100 (0.3 = 30% more), and double while the coach doubts you.
@export var kick_recovery_resilience: float = 0.3
@export var kick_doubt_make_mult: float = 2.0

## --- Too many misses (coach doubt) ---
## Window: your last kick_window field goal attempts (across games).
## A slump: kick_window_misses or more misses in the window, OR a season FG%
## below kick_season_pct after at least kick_season_min_att attempts.
@export var kick_window: int = 5
@export var kick_window_misses: int = 3
@export_range(0.0, 1.0) var kick_season_pct: float = 0.55
@export var kick_season_min_att: int = 6
## When a slump starts: the coach loses this much, and doubts you for
## doubt_weeks weeks: his longest call drops doubt_range_yd and he goes for
## field goals doubt_fg_chance_mult as often. Doubt ends early once the window
## has at most doubt_clear_misses misses.
@export var kick_slump_coach: float = -5.0
@export var doubt_weeks: int = 3
@export var doubt_range_yd: float = 6.0
@export_range(0.0, 1.0) var doubt_fg_chance_mult: float = 0.75
@export var doubt_clear_misses: int = 1

@export_group("Skill Points")
## Earned on the field (per kick of yours, field goals only) ...
@export var sp_make: int = 1
## ... a long make (long_make_yards+, or within sp_long_range_yd of your range) ...
@export var sp_long_make: int = 1
@export var sp_long_range_yd: float = 3.0
## ... a make under pressure (clutch_pressure+) ...
@export var sp_clutch_make: int = 1
## ... a game winner ...
@export var sp_game_winner: int = 3
## ... a perfect game (2+ kicks of yours, all made) ...
@export var sp_perfect_game: int = 1
## ... and in practice: every week (game or bye); low Energy costs some.
@export var sp_weekly_practice: int = 1
@export var sp_weekly_practice_tired: int = 0
## End of season: FG% at good_pct+ (at least poor_min_attempts tries) / great_pct+.
@export var sp_good_season: int = 6
@export var sp_great_season: int = 9
@export_range(0.0, 1.0) var sp_good_season_pct: float = 0.8
@export_range(0.0, 1.0) var sp_great_season_pct: float = 0.9
## Offseason training (once between seasons).
@export var sp_offseason: int = 6
## Scenario choices' "skill_points" are multiplied by this.
@export var sp_scenario_scale: float = 1.0
## Scenario choices still change football stats directly ("stats": {"football"});
## those changes are multiplied by this (the simulator checks total growth).
@export_range(0.0, 2.0) var scenario_football_scale: float = 0.5
## Upgrade cost: raising an attribute from level L to L+1 costs
## ceil(upgrade_cost_base + upgrade_cost_scale * (L/100)^upgrade_cost_exp).
## 30 -> 2 SP, 50 -> 4, 70 -> 6, 90 -> 9, 99 -> 10.
@export var upgrade_cost_base: float = 1.0
@export var upgrade_cost_scale: float = 9.0
@export var upgrade_cost_exp: float = 2.0
## Upgrades stop here.
@export var attribute_max: float = 100.0
## Saves from before skill points (version < 4) start with this many per
## season played in high school / at college or junior college / in the pros.
@export var sp_migrate_hs_per_season: int = 5
@export var sp_migrate_college: int = 30
@export var sp_migrate_pro: int = 50

@export_group("Career End")
## A season is "poor" with an FG% below this (at least poor_min_attempts tries).
@export_range(0.0, 1.0) var poor_fg_pct: float = 0.6
@export var poor_min_attempts: int = 3
## This many poor seasons / failed tryouts in a row, with no offer on the
## table, ends the career.
@export var career_end_poor_streak: int = 3
## Open free-agent tryouts you get in one spell of free agency before your
## playing days are over.
@export var free_agent_attempts: int = 2

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
