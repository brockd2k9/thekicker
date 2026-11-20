class_name Bench
extends RefCounted
## Benching: the coach hands your field goals to the backup for a week or two.
## It is earned, and never a surprise:
##   1. On thin ice (the warning): at the start of a week, the coach doubts you
##      (a slump) or a bad stretch is still fresh, AND trust (Coach and Team,
##      Relationships.trust) is at or below bench_warn_trust. The Hub and the
##      Game Day Outlook say so plainly.
##   2. Benched: at the end of a game week that STARTED on thin ice, if you
##      missed bench_week_misses field goals in that game (one is enough when
##      the season is going badly) and trust is at or below bench_trust.
##      Never before bench_min_week, at most bench_max_per_season a season.
##      1 week, or 2 when trust is at or below bench_long_trust.
##   3. While benched: the backup kicks your field goals (GameSim); you still kick
##      extra points and kickoffs. No game skill points that week (practice and
##      choices still count). Each benched week costs a little progress score.
##   4. The audition (a tryout in the kick scene, purpose "job"): make
##      audition_need of 5 (30-40 yd in high school, 35-45 after, never past your
##      range - 1). Pass: the job back, a little Coach and Team trust, half the
##      progress back. Fail: one more week, then another audition; after
##      audition_max_fails you're reinstated anyway.
## The backup is Tyler Brooks when he's your teammate, otherwise the stage's
## backup kicker (people.json "backup"). Story flags for scenario writers:
## benched, benched_for_tyler, won_job_back, lost_audition.
## Numbers: CareerTuning "Benching". State: CareerData.bench.

const BACKUP := "backup"
const SEASON_STAGES := [CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO, CareerData.STAGE_COLLEGE,
	CareerData.STAGE_PRO]


static func benched(c: CareerData) -> bool:
	return int(c.bench.get("weeks_left", 0)) > 0


static func audition_due(c: CareerData) -> bool:
	return bool(c.bench.get("audition_due", false))


## Is this week's game one you sit out (field goals to the backup)?
static func this_week(c: CareerData) -> bool:
	return bool(c.bench.get("this_week", false))


static func trust(c: CareerData, t: CareerTuning) -> float:
	return Relationships.trust(c, t)


## The warning: one more bad week and you're benched.
static func on_thin_ice(c: CareerData, t: CareerTuning) -> bool:
	if benched(c) or audition_due(c) or not (c.stage in SEASON_STAGES) or not c.people.has("coach"):
		return false
	if int(c.bench.get("season", -1)) == c.season and _benches_this_season(c) >= t.bench_max_per_season:
		return false
	var shaky := not c.coach_doubt.is_empty() or c.stretch_cooldown > 0
	return shaky and trust(c, t) <= t.bench_warn_trust


## Why the coach is losing patience, for the warning text.
static func warn_reason(c: CareerData) -> String:
	if not c.coach_doubt.is_empty():
		return str(c.coach_doubt.get("reason", "too many misses"))
	return "a rough stretch of field goals"


static func _benches_this_season(c: CareerData) -> int:
	return int(c.bench.get("season_benches", 0)) if int(c.bench.get("season", -1)) == c.season else 0


## Tyler Brooks is the backup when he's on your team.
static func tyler_is_teammate(c: CareerData) -> bool:
	if not c.people.has(Relationships.TYLER):
		return false
	if c.stage == CareerData.STAGE_HIGH_SCHOOL:
		return true
	var tt := Relationships.tyler_team(c)
	return not tt.is_empty() and str(tt.get("id", "")) == str(c.team.get("id", ""))


static func backup_id(c: CareerData) -> String:
	if c.bench.has("backup") and c.people.has(str(c.bench["backup"])):
		return str(c.bench["backup"])
	return Relationships.TYLER if tyler_is_teammate(c) else BACKUP


static func backup_name(c: CareerData) -> String:
	return Relationships.name_of(c, backup_id(c))


static func backup_make(c: CareerData, t: CareerTuning) -> float:
	match c.stage:
		CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT:
			return t.backup_make_pro
		CareerData.STAGE_COLLEGE, CareerData.STAGE_JUCO:
			return t.backup_make_college
	return t.backup_make_hs


# --- the week ------------------------------------------------------------------------

## Start of a week (CareerManager.begin_week): note the warning, and whether
## this week's game is a benched one.
static func begin_week(c: CareerData, t: CareerTuning, bye: bool) -> void:
	if on_thin_ice(c, t):
		c.bench["warned"] = c.week_index
	c.bench["this_week"] = benched(c) and not bye


## Was the thin-ice warning shown this week?
static func warned_this_week(c: CareerData) -> bool:
	return int(c.bench.get("warned", -1)) == c.week_index


## After a game you kicked in: bench if the warning came first, you missed
## bench_week_misses field goals, and trust is low enough. Returns true if benched.
static func check_after_game(c: CareerData, t: CareerTuning, kicks: Array) -> bool:
	if this_week(c) or not warned_this_week(c) or c.week < t.bench_min_week:
		return false
	if _benches_this_season(c) >= t.bench_max_per_season:
		return false
	var missed := kicks.filter(func(k: Dictionary) -> bool:
		return str(k.get("kind", "")) == "fg" and not k.get("backup", false) and not k.get("made", false)).size()
	if missed < misses_needed(c, t) or trust(c, t) > t.bench_trust:
		return false
	start(c, t)
	return true


## Field goals you'd have to miss this week to be benched: bench_week_misses,
## or 1 when the season is going badly (FG% under bench_poor_season_pct).
static func misses_needed(c: CareerData, t: CareerTuning) -> int:
	var s := c.season_stats
	if int(s.get("fg_att", 0)) >= t.bench_poor_season_min_att and Progression.fg_pct(s) < t.bench_poor_season_pct:
		return 1
	return t.bench_week_misses


static func start(c: CareerData, t: CareerTuning) -> void:
	var weeks := 2 if trust(c, t) <= t.bench_long_trust else 1
	var id := Relationships.TYLER if tyler_is_teammate(c) else BACKUP
	c.bench["weeks_left"] = weeks
	c.bench["weeks"] = weeks
	c.bench["reason"] = warn_reason(c)
	c.bench["backup"] = id
	c.bench["audition_due"] = false
	c.bench["auditions_failed"] = 0
	c.bench["progress_lost"] = 0.0
	c.bench["season_benches"] = _benches_this_season(c) + 1
	c.bench["season"] = c.season
	c.bench["benches"] = int(c.bench.get("benches", 0)) + 1
	if c.people.has(id):
		c.people[id]["known"] = true
	var friend := id == Relationships.TYLER and Relationships.lean(c, id) > 0.0
	var rival := id == Relationships.TYLER and Relationships.lean(c, id) < 0.0
	Relationships.apply(c, {Relationships.TEAM: t.bench_team_friend if friend else t.bench_team})
	CareerStats.apply(c, {"fun": t.bench_fun + (t.bench_rival_fun if rival else 0.0)}, t)
	c.flags["benched"] = true
	if id == Relationships.TYLER:
		c.flags["benched_for_tyler"] = true
	c.notice = "BENCHED: %s will kick your field goals for %d week%s (%s). You still kick extra points and kickoffs. Win the job back in an audition after that." \
		% [backup_name(c), weeks, "" if weeks == 1 else "s", c.bench["reason"]]


## End of week (CareerManager.end_week): a benched game week counts down and
## costs a little progress; when it runs out the audition is due.
static func end_week(c: CareerData, t: CareerTuning) -> void:
	if not this_week(c):
		return
	c.bench["this_week"] = false
	c.bench["weeks_left"] = maxi(int(c.bench.get("weeks_left", 0)) - 1, 0)
	c.bench["weeks_total"] = int(c.bench.get("weeks_total", 0)) + 1
	c.bench["season_weeks"] = (int(c.bench.get("season_weeks", 0)) if int(c.bench.get("weeks_season", -1)) == c.season else 0) + 1
	c.bench["weeks_season"] = c.season
	_progress(c, t.bench_progress_per_week)
	c.bench["progress_lost"] = float(c.bench.get("progress_lost", 0.0)) + t.bench_progress_per_week
	if int(c.bench["weeks_left"]) == 0:
		c.bench["audition_due"] = true


## Benched weeks this season (season summary).
static func season_weeks(c: CareerData) -> int:
	return int(c.bench.get("season_weeks", 0)) if int(c.bench.get("weeks_season", -1)) == c.season else 0


## A new season (or stage) starts with the job back.
static func new_season(c: CareerData) -> void:
	c.bench["weeks_left"] = 0
	c.bench["audition_due"] = false
	c.bench["this_week"] = false


static func _progress(c: CareerData, v: float) -> void:
	match c.stage:
		CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO:
			c.recruiting_score = clampf(c.recruiting_score + v, 0.0, 100.0)
		CareerData.STAGE_COLLEGE:
			c.draft_score = clampf(c.draft_score + v, 0.0, 100.0)
		CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT:
			c.retention_bonus += v


# --- the audition ------------------------------------------------------------------

## 5 kicks: 30-40 yd in high school, 35-45 after, never past range - 1.
static func audition_distances(c: CareerData, t: CareerTuning, range: float) -> Array:
	var base: PackedInt32Array = t.audition_distances_hs if c.stage == CareerData.STAGE_HIGH_SCHOOL else t.audition_distances
	var cap := maxi(floori(range + 0.001) - 1, 20)
	var out: Array = []
	for d in base:
		out.append(mini(int(d), cap))
	return out


## The tryout record for CareerManager (TryoutMode reads it).
static func audition(c: CareerData, t: CareerTuning, range: float) -> Dictionary:
	var stage := "pro" if c.stage in [CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT] else \
		("high_school" if c.stage == CareerData.STAGE_HIGH_SCHOOL else "college")
	return {"title": "WIN BACK THE JOB", "distances": audition_distances(c, t, range), "need": t.audition_need,
		"pressure": t.audition_pressure, "wind_max": t.audition_wind_max, "stage": stage, "purpose": "job",
		"team": str(c.team.get("id", "")), "team_name": str(c.team.get("name", ""))}


## The audition is over. Returns what happened: "passed", "extended" or "reinstated".
static func finish_audition(c: CareerData, t: CareerTuning, made: int) -> String:
	c.bench["audition_due"] = false
	if made >= t.audition_need:
		c.bench["weeks_left"] = 0
		Relationships.apply(c, {"coach": t.audition_coach, Relationships.TEAM: t.audition_team})
		c.coach_doubt = {}
		_progress(c, -float(c.bench.get("progress_lost", 0.0)) * t.bench_audition_refund)
		c.flags["won_job_back"] = true
		c.notice = "You won the job back. %s heads back to the sideline." % backup_name(c)
		return "passed"
	c.bench["auditions_failed"] = int(c.bench.get("auditions_failed", 0)) + 1
	c.flags["lost_audition"] = true
	if int(c.bench["auditions_failed"]) >= t.audition_max_fails:
		c.bench["weeks_left"] = 0
		c.notice = "%s struggled too. The coach gives you the job back: make it count." % backup_name(c)
		return "reinstated"
	c.bench["weeks_left"] = 1
	c.notice = "Not enough. %s keeps the field goals one more week, then you get another audition." % backup_name(c)
	return "extended"
