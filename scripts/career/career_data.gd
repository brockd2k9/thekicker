class_name CareerData
extends RefCounted
## The one Career Mode data object: everything about a career, saved as one
## JSON file per slot by CareerSave. Plain data plus small helpers; the rules
## that change it live in CareerStats (stats/traits), the weekly loop (Stage 3)
## and progression (Stage 5).
##
## Stats are floats 0..100 (gains can be fractional); screens show them rounded.
## When the layout changes: bump VERSION and add a step to CareerSave._migrate().

const VERSION := 1

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
## One entry per week: {week, type ("regular"/"bye"; "playoff" later), opponent
## {id, name, strength}, home, result {us, them, outcome} or null}.
var schedule: Array = []
var record: Dictionary = {"w": 0, "l": 0, "t": 0}
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
## Mid-game state so a quit restarts the game from its first kick: {"seed"}.
var game_checkpoint: Dictionary = {}
## What happened last week, for the Results & Week Summary screen:
## {type: "game"/"bye", opponent, us, them, outcome, kicks, changes, notes}.
var last_week: Dictionary = {}
## Stage 3 notice shown once on the Hub (e.g. an injury), then cleared.
var notice: String = ""


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


func set_stat(key: String, value: float) -> void:
	var g := group_of(key)
	if g == "":
		push_warning("CareerData: unknown stat '%s'" % key)
		return
	group(g)[key] = clampf(value, 0.0, 100.0)


func has_trait(id: String) -> bool:
	return id in traits


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
		"injury": injury.duplicate(),
		"recruiting_score": recruiting_score,
		"draft_score": draft_score,
		"offers": offers.duplicate(true),
		"contract": contract.duplicate(true),
		"poor_streak": poor_streak,
		"game_checkpoint": game_checkpoint.duplicate(true),
		"last_week": last_week.duplicate(true),
		"notice": notice,
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
	var inj := _dict(d, "injury")
	c.injury = {"weeks_left": maxi(int(inj.get("weeks_left", 0)), 0),
		"severity": clampf(float(inj.get("severity", 0.0)), 0.0, 1.0)}
	c.recruiting_score = float(d.get("recruiting_score", 0.0))
	c.draft_score = float(d.get("draft_score", 0.0))
	c.offers = _array(d, "offers")
	c.contract = _dict(d, "contract")
	c.poor_streak = maxi(int(d.get("poor_streak", 0)), 0)
	c.game_checkpoint = _dict(d, "game_checkpoint")
	c.last_week = _dict(d, "last_week")
	c.notice = str(d.get("notice", ""))
	return c


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
