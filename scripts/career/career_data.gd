class_name CareerData
extends RefCounted
## The one Career Mode data object: everything about a career, saved as one
## JSON file per slot by CareerSave. Plain data plus small helpers; the rules
## that change it live in CareerStats (stats/traits), the weekly loop (Stage 3)
## and progression (Stage 5).
##
## Stats are floats 0..100 (gains can be fractional); screens show them rounded.
## When the layout changes: bump VERSION and add a step to CareerSave._migrate().

const VERSION := 12

const STAGE_HIGH_SCHOOL := "high_school"
const STAGE_JUCO := "juco"
const STAGE_COLLEGE := "college"
const STAGE_PRO := "pro"
const STAGE_FREE_AGENT := "free_agent"
const STAGE_RETIRED := "retired"
const STAGES := [STAGE_HIGH_SCHOOL, STAGE_JUCO, STAGE_COLLEGE, STAGE_PRO,
	STAGE_FREE_AGENT, STAGE_RETIRED]

## The four stat groups. Keys are unique across groups, so stat("energy") works.
const LIFE := "life"
const FOOTBALL := "football"
const PERSONALITY := "personality"
const GROUP_KEYS := {
	LIFE: ["health", "energy", "fun", "social"],
	FOOTBALL: ["power", "accuracy", "resilience", "toughness"],
	PERSONALITY: ["charisma", "ambition", "leadership", "intelligence"],
}
const GROUP_NAMES := {LIFE: "Life", FOOTBALL: "Football", PERSONALITY: "Personality"}
const STAT_NAMES := {
	"health": "Health", "energy": "Energy", "fun": "Fun", "social": "Social",
	"power": "Kicking Power", "accuracy": "Kicking Accuracy",
	"resilience": "Resilience", "toughness": "Toughness",
	"charisma": "Charisma", "ambition": "Ambition", "leadership": "Leadership",
	"intelligence": "Intelligence",
}

# --- identity --------------------------------------------------------------------
var slot: int = 0
## Unix time (UTC seconds).
var created: int = 0
var updated: int = 0
## name, number (jersey), appearance {skin, hair} (placeholder indices), hometown.
var player: Dictionary = {}

# --- where we are ----------------------------------------------------------------
var stage: String = STAGE_HIGH_SCHOOL
## Season counter across the whole career (1-based).
var season: int = 1
## Season within the current stage (1-based), e.g. HS season 3 = senior year.
var season_in_stage: int = 1
var age: int = 15
## Week of the current season (1-based). 0 = offseason.
var week: int = 1
## Weeks played across the whole career; cooldowns are measured in these.
var week_index: int = 0
## Resume point for "Continue": which screen/step the career is on.
var phase: String = "week_start"

# --- team and season -------------------------------------------------------------
## id, name, short, league, level, colors [primary, secondary] as html strings.
var team: Dictionary = {}
## One entry per week: {week, type ("regular"/"bye"/"playoff"), opponent
## {id, name, strength}, home, result {us, them, outcome} or null}. Postseason
## games are appended one at a time (Postseason): postseason, round,
## round_name, final.
var schedule: Array = []
## The regular-season record (postseason games are in `postseason`).
var record: Dictionary = {"w": 0, "l": 0, "t": 0}
## This season's postseason (Postseason): {} until the regular season ends,
## then {kind: playoff/bowl/none, status: alive/eliminated/champion/bowl_won/
## bowl_lost/missed, w, l, games: [...], name (bowl), text}.
var postseason: Dictionary = {}
## Career postseason totals: appearances, bowls, bowl_wins, titles, wins,
## losses, by_stage {stage: appearances}, title_list [{stage, season, name, team}].
var postseason_career: Dictionary = {}
## The league around the team (League): conferences, divisions, every team's
## strength, this season's full schedule and scores, the postseason field.
## {} for stages without one. An optional field (no save version bump): saves
## without it get one on load (CareerManager._sanitize -> League.migrate).
var league: Dictionary = {}
## This season: fg_att, fg_made, pat_att, pat_made, long, game_winners, points.
var season_stats: Dictionary = {}
## Same keys, whole career.
var career_totals: Dictionary = {}
## One summary per finished season.
var history: Array = []
## The last few games, newest last: {week, opponent, us, them, outcome, kicks}.
var recent_results: Array = []

# --- the four stat groups ---------------------------------------------------------
var life: Dictionary = {}
var football: Dictionary = {}
var personality: Dictionary = {}
## Unlocked trait ids (see data/career/traits.json). Kept once unlocked.
var traits: Array = []

# --- story state ------------------------------------------------------------------
## Free-form flags set by scenario choices, e.g. {"has_agent": true}.
var flags: Dictionary = {}
## id -> {times, last_week_index}. Drives one-time / cooldown rules.
var scenario_log: Dictionary = {}
## Game-day modifier ids active this week (data/career/modifiers.json).
var week_modifiers: Array = []
## Scenario ids still to be shown this week (checkpointed after each choice).
var pending_scenarios: Array = []
## Follow-ups waiting to fire: [{id, due}] (due = week_index).
var queued_scenarios: Array = []
## This season's scenario counts for the repetition guard:
## {"ids": {id: n}, "cats": {category: n}}. Reset every season.
var season_log: Dictionary = {"ids": {}, "cats": {}}
## weeks_left > 0 = injured; severity 0..1.
var injury: Dictionary = {"weeks_left": 0, "severity": 0.0}

# --- progression ------------------------------------------------------------------
var recruiting_score: float = 0.0
var draft_score: float = 0.0
## Offers waiting for a decision (recruiting / signing).
var offers: Array = []
## team_id, years_left, salary, retention.
var contract: Dictionary = {}
## Bad seasons / failed tryouts in a row. Too many ends the career.
var poor_streak: int = 0
## Grade point average, 0-4 (academic eligibility for college offers / play).
var gpa: float = 2.9
## Pro: this season's retention points from choices ("retention" in scenario data).
var retention_bonus: float = 0.0
## Last computed pro retention score (0-100), for the Hub.
var retention_score: float = 0.0
## Active tryout: {purpose, title, distances, need, pressure, wind_max, stage,
## team, made, taken}. Empty when none.
var tryout: Dictionary = {}
## Draft day result: {round, team, kind: "drafted"/"camp"/"open"}.
var draft_result: Dictionary = {}
## The career's path, one line per milestone: [{season, age, text}].
var route: Array = []
## The recurring cast (Relationships, data/career/people.json):
## id -> {name, value 0..100, known, week_change, stage, team (Tyler only)}.
var people: Dictionary = {}
## People from earlier stages: [{id, name, value, stage, role}].
var former_people: Array = []
## All-time records (RecordBook.check, save version 10): {best: {list key:
## "entered" / "tie" / "record"}, held: [list keys you're #1 on], log: [events]}.
## The fictional record book itself is data (data/records), never saved.
var records: Dictionary = {}
## Set when the career ends: {reason, text, age, season}.
var retirement: Dictionary = {}
## Mid-game state so a quit restarts the game from its first kick: {"seed"}.
var game_checkpoint: Dictionary = {}
## What happened last week, for the Results & Week Summary screen:
## {type: "game"/"bye", opponent, us, them, outcome, kicks, changes, notes}.
var last_week: Dictionary = {}
## Stage 3 notice shown once on the Hub (e.g. an injury), then cleared.
var notice: String = ""

# --- skill points, range, kick trust (save version 4) ---
## Unspent skill points (SkillPoints: earned on the field and in practice,
## spent on attribute upgrades in the Skills screen).
var skill_points: int = 0
## Earned this season / whole career (spent ones included).
## Range physics for this career (CareerTuning.sp_range_physics when created;
## off for saves from before the switch).
var range_physics: bool = false
var sp_season: int = 0
## SP earned this week by source, for the Results screen: [{text, sp}].
var sp_week: Array = []
var sp_career: int = 0
## Attribute points bought with skill points: {stat: points} (career totals).
var sp_upgrades: Dictionary = {}
## Perk ids owned (data/career/perks.json, Step 3).
var perks: Array = []
## Aging: attributes preserved this season {stat: season} (Step 3).
var maintained: Dictionary = {}
## Your last field goal attempts, oldest first (true = made). KickTrust's
## "too many misses" window; kept across games and seasons.
var recent_fg: Array = []
## Your last field goals for the bad-stretch check (KickTrust; newest last),
## and weeks until a bad stretch can cost trust again.
var fg_history: Array = []
var stretch_cooldown: int = 0
## This season's skill points by source ("Field goals made", "Practice", ...),
## saved into each season's history (balance simulator).
var sp_sources: Dictionary = {}
## Daily Challenge rewards already added to this career (claim ids, newest
## last): a reward can never be paid twice, even after a crash (save v9).
var daily_claims: Array = []
## Coach doubt after a slump: {weeks_left, reason}. Empty = none.
var coach_doubt: Dictionary = {}
## This week's Coach / Team changes from your kicks: {coach, team, lines: [text]}.
var trust_week: Dictionary = {}

# --- kick log (save version 6) ---
## Every kick you take in a game, oldest first, for the Stats screen
## (distance buckets, streaks, kickoffs). Logged from version 6 on; saves from
## before have an empty log, so their past seasons show "-" for those stats.
## Field goal / extra point: {kind: "fg"/"pat", yd, made, season, stage,
##   clutch (game winner / tying kick), gw (made game winner)}.
## Kickoff: {kind: "kickoff", season, stage, carry (yd), tb (touchback)}.
## Onside: {kind: "onside", season, stage, rec (recovered)}.
## Booleans are stored as 0/1 to keep the file small.
var kick_log: Array = []

# --- benching (save version 5) ---
## Bench: {weeks_left, weeks (this bench), reason, backup (person id),
## warned (week_index the thin-ice warning was shown), audition_due,
## auditions_failed, season (last season benched), benches (career count),
## weeks_total (career benched weeks), progress_lost (this bench, for the
## audition refund), this_week (true while this week's game is benched)}.
## Empty = never benched. Rules: Bench.
var bench: Dictionary = {}

# --- followers (save version 7) ---
## Social media followers (a real count; Followers). Never below 0.
var followers: int = 0
## Followers bookkeeping: {peak, best_tier, season_gain, season_sources
## {text: followers}, week [{text, n, buzz}] (this week's Results lines),
## deals [{id, name, kind, value, seasons_left}], virals, sp_season}.
var social: Dictionary = {}
## Savings / net worth in dollars (Savings): a score and a story hook only.
var savings: int = 0
## Where it came from: {salary, choices_in, choices_out, peak}.
var money_log: Dictionary = {}
## The last kick challenge's outcome, for the tryout screen's result:
## {passed, made, kicks, need, perfect, title, scenario, out}.
var last_challenge: Dictionary = {}
## A suspension (a choice's suspend_weeks): {weeks_left, weeks, reason}; empty =
## none. suspensions_total: career count. Rules: Reputation.
var suspension: Dictionary = {}
var suspensions_total: int = 0
## Field goals of yours in a row: +n makes / -n misses (games only).
var fg_streak: int = 0
## Fatigue: {practice (light / normal / hard), exhausted_weeks, loss_season_n,
## lost {stat: points}, lost_total, rested_weeks, habits_season_n}.
var fatigue: Dictionary = {}
## Kick nerves (KickNerves): {decisions, bad_week, slump, clean_run, miss_run,
## recent}. Empty = calm; missing in older saves means the same.
var nerves: Dictionary = {}


## A fresh career with starting stats from the tuning file.
static func create(player_name: String, tuning: CareerTuning) -> CareerData:
	var d := CareerData.new()
	var now := int(Time.get_unix_time_from_system())
	d.created = now
	d.updated = now
	d.player = {"name": player_name, "number": 3, "appearance": {"skin": 0, "hair": 0},
		"hometown": ""}
	d.age = tuning.start_age
	for k in GROUP_KEYS[LIFE]:
		d.life[k] = tuning.start_life
	for k in GROUP_KEYS[FOOTBALL]:
		d.football[k] = tuning.start_football
	for k in GROUP_KEYS[PERSONALITY]:
		d.personality[k] = tuning.start_personality
	d.season_stats = empty_kick_totals()
	d.career_totals = empty_kick_totals()
	d.gpa = tuning.start_gpa
	d.range_physics = tuning.sp_range_physics
	Relationships.seed_cast(d, tuning)
	return d


static func empty_kick_totals() -> Dictionary:
	return {"fg_att": 0, "fg_made": 0, "pat_att": 0, "pat_made": 0, "long": 0,
		"game_winners": 0, "points": 0, "games": 0}


# --- stat access ------------------------------------------------------------------

func group(name: String) -> Dictionary:
	match name:
		LIFE:
			return life
		FOOTBALL:
			return football
		PERSONALITY:
			return personality
	push_warning("CareerData: unknown stat group '%s'" % name)
	return {}


## Which group a stat key belongs to ("" if none).
static func group_of(key: String) -> String:
	for g in GROUP_KEYS:
		if key in GROUP_KEYS[g]:
			return g
	return ""


## Any stat by key, e.g. stat("energy"). 0 for unknown keys.
func stat(key: String) -> float:
	var g := group_of(key)
	if g == "":
		return 0.0
	return float(group(g).get(key, 0.0))


## Stats plus the progression numbers scenario requirements can test:
## "recruiting", "draft", "retention", "gpa", "age", and "rel_<person id>"
## (a relationship value, e.g. "rel_coach"; 50 for someone not in the cast now).
const METRICS := ["recruiting", "draft", "retention", "gpa", "age", "followers",
	"slump_now", "benched_now", "injured_now", "fg_streak", "season_fg_pct", "pro_seasons",
	"contract_years_left", "clubs", "savings", "playoff_appearances", "championships", "postseason_wins"]


func metric(key: String) -> float:
	match key:
		"recruiting":
			return recruiting_score
		"draft":
			return draft_score
		"retention":
			return retention_score
		"gpa":
			return gpa
		"age":
			return float(age)
		"followers":
			return float(followers)
		# "Right now" values for scenario requirements (the present, whatever
		# the story flags say).
		"slump_now":
			return 1.0 if not coach_doubt.is_empty() else 0.0
		"benched_now":
			return 1.0 if Bench.benched(self) else 0.0
		"injured_now":
			return 1.0 if is_injured() else 0.0
		"fg_streak":
			return float(fg_streak)
		"season_fg_pct":
			var att := int(season_stats.get("fg_att", 0))
			return 100.0 * int(season_stats.get("fg_made", 0)) / att if att > 0 else 0.0
		"pro_seasons":
			return float(pro_seasons())
		"contract_years_left":
			return float(int(contract.get("years_left", 0)))
		"clubs":
			return float(pro_clubs().size())
		"savings":
			return float(savings)
		# Postseason (career totals).
		"playoff_appearances":
			return float(int(postseason_career.get("appearances", 0)))
		"championships":
			return float(int(postseason_career.get("titles", 0)))
		"postseason_wins":
			return float(int(postseason_career.get("wins", 0)))
	if key.begins_with("rel_"):
		return Relationships.value(self, key.substr(4))
	return stat(key)


## Adds a line to the career path ("Signed with ...").
func add_route(text: String) -> void:
	route.append({"season": season, "age": age, "stage": stage, "text": text})


func set_stat(key: String, value: float) -> void:
	var g := group_of(key)
	if g == "":
		push_warning("CareerData: unknown stat '%s'" % key)
		return
	group(g)[key] = clampf(value, 0.0, 100.0)


func has_trait(id: String) -> bool:
	return id in traits


## Pro seasons played (finished; history).
func pro_seasons() -> int:
	return history.filter(func(h: Dictionary) -> bool: return str(h.get("stage", "")) == STAGE_PRO).size()


## Pro clubs played for, by name (flags "pro_clubs"; older saves: from the
## history and the current team).
func pro_clubs() -> Array:
	var out: Array = []
	if flags.get("pro_clubs") is Array:
		out = (flags["pro_clubs"] as Array).duplicate()
	else:
		for h in history:
			if str(h.get("stage", "")) == STAGE_PRO and not (str(h.get("team", "")) in out):
				out.append(str(h.get("team", "")))
		if stage == STAGE_PRO and not (str(team.get("name", "")) in out):
			out.append(str(team.get("name", "")))
	return out


func is_injured() -> bool:
	return int(injury.get("weeks_left", 0)) > 0


func display_name() -> String:
	var n := str(player.get("name", ""))
	return n if n != "" else "Rookie"


# --- save format ------------------------------------------------------------------

func to_dict() -> Dictionary:
	return {
		"career_version": VERSION,
		"slot": slot,
		"created": created,
		"updated": updated,
		"player": player.duplicate(true),
		"stage": stage,
		"season": season,
		"season_in_stage": season_in_stage,
		"age": age,
		"week": week,
		"week_index": week_index,
		"phase": phase,
		"team": team.duplicate(true),
		"schedule": schedule.duplicate(true),
		"record": record.duplicate(),
		"season_stats": season_stats.duplicate(),
		"career_totals": career_totals.duplicate(),
		"history": history.duplicate(true),
		"recent_results": recent_results.duplicate(true),
		"life": life.duplicate(),
		"football": football.duplicate(),
		"personality": personality.duplicate(),
		"traits": traits.duplicate(),
		"flags": flags.duplicate(true),
		"scenario_log": scenario_log.duplicate(true),
		"week_modifiers": week_modifiers.duplicate(),
		"pending_scenarios": pending_scenarios.duplicate(),
		"queued_scenarios": queued_scenarios.duplicate(true),
		"season_log": season_log.duplicate(true),
		"injury": injury.duplicate(),
		"recruiting_score": recruiting_score,
		"draft_score": draft_score,
		"offers": offers.duplicate(true),
		"contract": contract.duplicate(true),
		"poor_streak": poor_streak,
		"game_checkpoint": game_checkpoint.duplicate(true),
		"gpa": gpa,
		"retention_bonus": retention_bonus,
		"retention_score": retention_score,
		"tryout": tryout.duplicate(true),
		"draft_result": draft_result.duplicate(true),
		"postseason": postseason.duplicate(true),
		"postseason_career": postseason_career.duplicate(true),
		"league": League.pack(league),
		"route": route.duplicate(true),
		"retirement": retirement.duplicate(true),
		"last_week": last_week.duplicate(true),
		"people": people.duplicate(true),
		"former_people": former_people.duplicate(true),
		"records": records.duplicate(true),
		"notice": notice,
		"skill_points": skill_points,
		"range_physics": range_physics,
		"sp_season": sp_season,
		"sp_career": sp_career,
		"sp_week": sp_week.duplicate(true),
		"sp_upgrades": sp_upgrades.duplicate(),
		"perks": perks.duplicate(),
		"maintained": maintained.duplicate(),
		"recent_fg": recent_fg.duplicate(),
		"fg_history": fg_history.duplicate(),
		"stretch_cooldown": stretch_cooldown,
		"sp_sources": sp_sources.duplicate(),
		"daily_claims": daily_claims.duplicate(),
		"coach_doubt": coach_doubt.duplicate(),
		"trust_week": trust_week.duplicate(true),
		"bench": bench.duplicate(true),
		"kick_log": kick_log.duplicate(true),
		"followers": followers,
		"social": social.duplicate(true),
		"savings": savings,
		"money_log": money_log.duplicate(true),
		"last_challenge": last_challenge.duplicate(true),
		"suspension": suspension.duplicate(),
		"suspensions_total": suspensions_total,
		"fg_streak": fg_streak,
		"fatigue": fatigue.duplicate(true),
		"nerves": nerves.duplicate(true),
	}


## Reads a (migrated) save dict. Missing or wrong-typed fields fall back to
## defaults, and stats are clamped, so a hand-edited file can't break the game.
## Note: JSON has one number type, so whole numbers inside free-form entries
## (schedule, history, offers...) come back as floats; read them with int().
static func from_dict(d: Dictionary) -> CareerData:
	var c := CareerData.new()
	c.slot = int(d.get("slot", 0))
	c.created = int(d.get("created", 0))
	c.updated = int(d.get("updated", 0))
	var pl := _dict(d, "player")
	var look := _dict(pl, "appearance")
	c.player = {"name": str(pl.get("name", "")), "number": int(pl.get("number", 3)),
		"appearance": {"skin": int(look.get("skin", 0)), "hair": int(look.get("hair", 0))},
		"hometown": str(pl.get("hometown", ""))}
	c.stage = str(d.get("stage", STAGE_HIGH_SCHOOL))
	if not (c.stage in STAGES):
		c.stage = STAGE_HIGH_SCHOOL
	c.season = maxi(int(d.get("season", 1)), 1)
	c.season_in_stage = maxi(int(d.get("season_in_stage", 1)), 1)
	c.age = int(d.get("age", 15))
	c.week = maxi(int(d.get("week", 1)), 0)
	c.week_index = maxi(int(d.get("week_index", 0)), 0)
	c.phase = str(d.get("phase", "week_start"))
	c.team = _dict(d, "team")
	c.schedule = _array(d, "schedule")
	c.record = {"w": 0, "l": 0, "t": 0}
	var r := _dict(d, "record")
	for k in c.record:
		c.record[k] = int(r.get(k, 0))
	c.season_stats = _totals(_dict(d, "season_stats"))
	c.career_totals = _totals(_dict(d, "career_totals"))
	c.history = _array(d, "history")
	c.recent_results = _array(d, "recent_results")
	for g in GROUP_KEYS:
		var src := _dict(d, g)
		var dst := c.group(g)
		for k in GROUP_KEYS[g]:
			dst[k] = clampf(float(src.get(k, 50.0)), 0.0, 100.0)
	for t in _array(d, "traits"):
		c.traits.append(str(t))
	c.flags = _dict(d, "flags")
	c.scenario_log = _dict(d, "scenario_log")
	for m in _array(d, "week_modifiers"):
		c.week_modifiers.append(str(m))
	for s in _array(d, "pending_scenarios"):
		c.pending_scenarios.append(str(s))
	for q in _array(d, "queued_scenarios"):
		if q is Dictionary and q.has("id"):
			c.queued_scenarios.append({"id": str(q["id"]), "due": int(q.get("due", 0))})
	var sl := _dict(d, "season_log")
	c.season_log = {"ids": sl.get("ids", {}) if sl.get("ids") is Dictionary else {},
		"cats": sl.get("cats", {}) if sl.get("cats") is Dictionary else {}}
	var inj := _dict(d, "injury")
	c.injury = {"weeks_left": maxi(int(inj.get("weeks_left", 0)), 0),
		"severity": clampf(float(inj.get("severity", 0.0)), 0.0, 1.0)}
	c.recruiting_score = float(d.get("recruiting_score", 0.0))
	c.draft_score = float(d.get("draft_score", 0.0))
	c.offers = _array(d, "offers")
	c.contract = _dict(d, "contract")
	c.poor_streak = maxi(int(d.get("poor_streak", 0)), 0)
	c.game_checkpoint = _dict(d, "game_checkpoint")
	c.gpa = clampf(float(d.get("gpa", 2.9)), 0.0, 4.0)
	c.retention_bonus = float(d.get("retention_bonus", 0.0))
	c.retention_score = float(d.get("retention_score", 0.0))
	c.tryout = _dict(d, "tryout")
	c.draft_result = _dict(d, "draft_result")
	c.postseason = _dict(d, "postseason")
	c.postseason_career = _dict(d, "postseason_career")
	c.league = League.unpack(_dict(d, "league"))
	c.route = _array(d, "route")
	c.retirement = _dict(d, "retirement")
	c.last_week = _dict(d, "last_week")
	c.notice = str(d.get("notice", ""))
	c.skill_points = maxi(_num(d, "skill_points"), 0)
	c.range_physics = d.get("range_physics") is bool and d["range_physics"]
	c.sp_season = maxi(_num(d, "sp_season"), 0)
	c.sp_career = maxi(_num(d, "sp_career"), 0)
	c.sp_week = _array(d, "sp_week")
	var up := _dict(d, "sp_upgrades")
	for k in up:
		if group_of(str(k)) == FOOTBALL:
			c.sp_upgrades[str(k)] = float(up[k])
	for id in _array(d, "perks"):
		c.perks.append(str(id))
	var mt := _dict(d, "maintained")
	for k in mt:
		c.maintained[str(k)] = int(mt[k])
	for b in _array(d, "recent_fg"):
		c.recent_fg.append(bool(b))
	for b in _array(d, "fg_history"):
		c.fg_history.append(bool(b))
	c.stretch_cooldown = maxi(_num(d, "stretch_cooldown"), 0)
	var src := _dict(d, "sp_sources")
	for k in src:
		c.sp_sources[str(k)] = _num(src, k)
	for id in _array(d, "daily_claims"):
		c.daily_claims.append(str(id))
	c.coach_doubt = _dict(d, "coach_doubt")
	c.trust_week = _dict(d, "trust_week")
	c.bench = _dict(d, "bench")
	for e in _array(d, "kick_log"):
		if e is Dictionary and str(e.get("kind", "")) != "":
			c.kick_log.append(e)
	c.records = _dict(d, "records")
	c.followers = maxi(_num(d, "followers"), 0)
	c.social = _dict(d, "social")
	c.savings = maxi(_num(d, "savings"), 0)
	c.money_log = _dict(d, "money_log")
	c.last_challenge = _dict(d, "last_challenge")
	c.suspension = _dict(d, "suspension")
	c.suspensions_total = maxi(_num(d, "suspensions_total"), 0)
	c.fg_streak = _num(d, "fg_streak")
	c.fatigue = _dict(d, "fatigue")
	c.nerves = _dict(d, "nerves")
	for id in _dict(d, "people"):
		var p: Variant = d["people"][id]
		if p is Dictionary and not Relationships.def(str(id)).is_empty():
			c.people[str(id)] = {"name": str(p.get("name", "")),
				"value": clampf(float(p.get("value", 50.0)), 0.0, 100.0),
				"known": bool(p.get("known", false)), "week_change": float(p.get("week_change", 0.0)),
				"stage": str(p.get("stage", c.stage))}
			if p.get("team") is Dictionary and not (p["team"] as Dictionary).is_empty():
				c.people[str(id)]["team"] = (p["team"] as Dictionary).duplicate()
	for f in _array(d, "former_people"):
		if f is Dictionary:
			c.former_people.append(f)
	# Saves from before relationships (version < 3), or people added to
	# people.json since: the current stage's cast arrives at 50 (neutral).
	Relationships.seed_cast(c, CareerTuning.get_default())
	Relationships.catch_up_tyler(c)
	# Version 3 -> 4: Team standing starts from your record (CareerSave._migrate).
	if d.has("_team_start") and c.people.has(Relationships.TEAM):
		c.people[Relationships.TEAM]["value"] = clampf(float(d["_team_start"]), 0.0, 100.0)
	return c


## A whole number from a save field; 0 if it's missing or not a number.
static func _num(d: Dictionary, key: Variant) -> int:
	var v: Variant = d.get(key)
	return int(v) if v is int or v is float else 0


static func _dict(d: Dictionary, key: String) -> Dictionary:
	var v: Variant = d.get(key)
	return (v as Dictionary).duplicate(true) if v is Dictionary else {}


static func _array(d: Dictionary, key: String) -> Array:
	var v: Variant = d.get(key)
	return (v as Array).duplicate(true) if v is Array else []


static func _totals(src: Dictionary) -> Dictionary:
	var t := empty_kick_totals()
	for k in t:
		t[k] = int(src.get(k, 0))
	return t
