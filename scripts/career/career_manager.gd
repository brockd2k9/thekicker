class_name CareerManager
extends RefCounted
## The weekly loop. GameState.career holds the active one; every career screen
## asks it what to show and tells it what the player chose.
##
## data.phase is the resume point (saved), so "Continue" always lands on the
## right step:
##   week_start -> scenario -> outlook -> game -> results -> week_start ...
##   (bye week: week_start -> scenario -> results)
##   last week's results -> season_end -> offseason (scenarios) -> week_start
##   senior year's season_end -> stage_end ("Senior year complete", Stage 5 adds recruiting)
## Saves: after picking the week's scenarios and after each choice (no
## rerolls), when a game starts (a quit restarts that game), after the game,
## and at the end of every week (autosave).
## Every stat change goes through CareerStats; every number is in CareerTuning.

const PHASE_WEEK_START := "week_start"
const PHASE_SCENARIO := "scenario"
const PHASE_OUTLOOK := "outlook"
const PHASE_GAME := "game"
const PHASE_RESULTS := "results"
const PHASE_SEASON_END := "season_end"
const PHASE_OFFSEASON := "offseason"
const PHASE_STAGE_END := "stage_end"

var data: CareerData
var tuning: CareerTuning
var rng := RandomNumberGenerator.new()


func _init(c: CareerData, t: CareerTuning = null) -> void:
	data = c
	tuning = t if t != null else CareerTuning.get_default()
	rng.randomize()


## A new career in `slot`, at school `school_id`, saved and ready at week 1.
static func create(slot: int, player_name: String, number: int, appearance: Dictionary,
		school_id: String) -> CareerManager:
	var t := CareerTuning.get_default()
	var c := CareerData.create(player_name, t)
	c.slot = slot
	c.player["number"] = number
	c.player["appearance"] = appearance.duplicate()
	var s := CareerContent.school(school_id)
	c.player["hometown"] = str(s.get("town", ""))
	c.team = _team_from_school(s)
	var m := CareerManager.new(c, t)
	m._start_season(false)
	m.save()
	return m


static func load_slot(slot: int) -> CareerManager:
	var c := CareerSave.load_slot(slot)
	return CareerManager.new(c) if c != null else null


func save() -> bool:
	return CareerSave.save(data)


## Which screen this phase belongs on.
func screen_path() -> String:
	match data.phase:
		PHASE_SCENARIO, PHASE_OFFSEASON:
			return Screens.CAREER_SCENARIO
		PHASE_OUTLOOK:
			return Screens.CAREER_OUTLOOK
		PHASE_GAME:
			return Screens.CAREER_GAME
		PHASE_RESULTS:
			return Screens.CAREER_RESULTS
		PHASE_SEASON_END, PHASE_STAGE_END:
			return Screens.CAREER_SEASON
	return Screens.CAREER_HUB


# --- the season ---------------------------------------------------------------------

func entry() -> Dictionary:
	var i := data.week - 1
	return data.schedule[i] if i >= 0 and i < data.schedule.size() else {}


func is_bye() -> bool:
	return entry().get("type", "") == "bye"


func weeks_in_season() -> int:
	return data.schedule.size()


## "Freshman" .. "Senior" for high school.
func class_year() -> String:
	var years := ["Freshman", "Sophomore", "Junior", "Senior"]
	var i := data.season_in_stage - 1
	if data.season_in_stage >= tuning.high_school_seasons:
		return "Senior"
	return years[clampi(i, 0, 3)]


func _start_season(drift: bool) -> void:
	if drift:
		data.team["strength"] = clampf(float(data.team.get("strength", 50)) +
			rng.randf_range(-tuning.team_strength_drift, tuning.team_strength_drift), 20.0, 90.0)
	data.schedule = build_schedule(data.team, tuning, rng)
	data.week = 1
	data.record = {"w": 0, "l": 0, "t": 0}
	data.season_stats = CareerData.empty_kick_totals()
	data.week_modifiers.clear()
	data.pending_scenarios.clear()
	data.game_checkpoint = {}
	data.phase = PHASE_WEEK_START


## games_per_season games + byes_per_season byes. Entries are typed
## ("regular" / "bye") so playoff weeks can be appended later.
static func build_schedule(team: Dictionary, t: CareerTuning, r: RandomNumberGenerator) -> Array:
	var others: Array = []
	for s in CareerContent.high_schools():
		if s.get("id", "") != team.get("id", ""):
			others.append(s)
	others.shuffle()
	var total := t.games_per_season + t.byes_per_season
	var byes: Array = []
	while byes.size() < t.byes_per_season:
		var w := r.randi_range(mini(t.bye_week_earliest, total), mini(t.bye_week_latest, total))
		if not (w in byes):
			byes.append(w)
	var out: Array = []
	var g := 0
	for w in range(1, total + 1):
		if w in byes:
			out.append({"week": w, "type": "bye", "result": null})
			continue
		var opp: Dictionary = others[g % maxi(others.size(), 1)] if not others.is_empty() else {}
		g += 1
		out.append({"week": w, "type": "regular", "home": r.randf() < 0.5,
			"opponent": _team_from_school(opp), "result": null})
	return out


static func _team_from_school(s: Dictionary) -> Dictionary:
	return {"id": s.get("id", ""), "name": s.get("name", "School"), "mascot": s.get("mascot", ""),
		"short": s.get("short", "???"), "town": s.get("town", ""),
		"colors": s.get("colors", ["#1f3a8a", "#f2b632"]), "strength": float(s.get("strength", 50)),
		"level": CareerData.STAGE_HIGH_SCHOOL}


# --- the week -----------------------------------------------------------------------

## Hub "Play Week": roll the week (weather, injury check) and pick its scenarios.
## Saved right away, so quitting can't reroll them.
func begin_week() -> void:
	if data.phase != PHASE_WEEK_START:
		return
	var when := "bye" if is_bye() else "season"
	var count := tuning.bye_scenarios if is_bye() else \
		(2 if rng.randf() < tuning.second_scenario_chance else 1)
	data.pending_scenarios = ScenarioEngine.pick(data, when, count, rng)
	if not is_bye():
		var e := entry()
		var wind := rng.randf_range(0.0, tuning.game_wind_max_mph) * (1.0 if rng.randf() < 0.5 else -1.0)
		e["weather"] = {"wind": roundf(wind), "gusty": rng.randf() < tuning.game_gust_chance}
		_injury_roll()
	data.phase = PHASE_SCENARIO
	if data.pending_scenarios.is_empty():
		_after_scenarios()
	save()


func current_scenario() -> Dictionary:
	if data.pending_scenarios.is_empty():
		return {}
	return CareerContent.scenario(str(data.pending_scenarios[0]))


## Applies choice `index` of the current scenario, checkpoints, and returns
## what happened (ScenarioEngine.apply_choice).
func choose(index: int) -> Dictionary:
	var s := current_scenario()
	if s.is_empty():
		return {}
	var out := ScenarioEngine.apply_choice(data, str(s["id"]), index, tuning)
	data.pending_scenarios.pop_front()
	if data.pending_scenarios.is_empty():
		_after_scenarios()
	save()
	return out


func _after_scenarios() -> void:
	if data.phase == PHASE_OFFSEASON:
		_start_next_season()
	elif is_bye():
		_finish_bye()
	else:
		data.phase = PHASE_OUTLOOK


func _injury_roll() -> void:
	if data.is_injured():
		return
	var p := KickProfile.build(data, tuning)
	if rng.randf() < p.injury_risk:
		data.injury = {"weeks_left": rng.randi_range(tuning.injury_weeks_min, tuning.injury_weeks_max),
			"severity": snappedf(rng.randf_range(tuning.injury_severity_min, tuning.injury_severity_max), 0.05)}
		data.notice = "You tweaked your hip flexor in practice. You'll be playing hurt for %d week(s)." \
			% int(data.injury["weeks_left"])


# --- game day -----------------------------------------------------------------------

## The kick profile for this week (plus in-game context).
func profile(ctx: Dictionary = {}) -> KickProfile:
	return KickProfile.build(data, tuning, ctx)


## Outlook "Play Game": checkpoint the game. Returns the game's seed; the
## same seed is reused if the game is restarted after a quit.
func start_game() -> int:
	if data.game_checkpoint.is_empty():
		data.game_checkpoint = {"seed": rng.randi(), "week": data.week}
	data.phase = PHASE_GAME
	save()
	return int(data.game_checkpoint["seed"])


## A GameSim for this week's game (fresh, from the checkpoint seed).
func new_game_sim(kt: KickTuning) -> GameSim:
	var sim := GameSim.new()
	var max_fg := int(profile().max_range_yards(kt) * tuning.coach_range_trust)
	sim.setup(data, entry(), tuning, start_game(), max_fg)
	return sim


## The game is over: record, stats, life/football changes, results screen.
func finish_game(summary: Dictionary) -> void:
	var opp: Dictionary = entry().get("opponent", {})
	var outcome := str(summary.get("outcome", "T"))
	data.record[{"W": "w", "L": "l", "T": "t"}[outcome]] += 1
	var changes := game_changes(summary)
	var applied := CareerStats.apply(data, changes, tuning)
	var line := _record_kicks(summary.get("kicks", []))
	var e := entry()
	e["result"] = {"us": summary.get("us", 0), "them": summary.get("them", 0), "outcome": outcome}
	var result := {"week": data.week, "opponent": opp.get("name", ""), "us": summary.get("us", 0),
		"them": summary.get("them", 0), "outcome": outcome, "line": line}
	data.recent_results.append(result)
	while data.recent_results.size() > 5:
		data.recent_results.pop_front()
	data.last_week = {"type": "game", "week": data.week, "opponent": opp.get("name", ""),
		"mascot": opp.get("mascot", ""), "home": e.get("home", true),
		"us": summary.get("us", 0), "them": summary.get("them", 0),
		"outcome": outcome, "kicks": summary.get("kicks", []), "warmups": summary.get("warmups", []),
		"line": line, "changes": applied}
	data.game_checkpoint = {}
	data.phase = PHASE_RESULTS
	save()
	GameState.report_run({"mode": "career", "outcome": outcome,
		"makes": int(_count(summary.get("kicks", []), true)),
		"kicks": int(_count(summary.get("kicks", []), false)),
		"stage": data.stage})


## The stat changes a finished game causes (before the stat rules).
func game_changes(summary: Dictionary) -> Dictionary:
	var ch := {}
	match str(summary.get("outcome", "T")):
		"W":
			_add(ch, "fun", tuning.win_fun)
			_add(ch, "social", tuning.win_social)
		"L":
			_add(ch, "fun", tuning.loss_fun)
			_add(ch, "social", tuning.loss_social)
	_add(ch, "energy", tuning.game_energy_cost)
	_add(ch, "health", tuning.game_health_cost)
	var att := 0
	var made := 0
	for k in summary.get("kicks", []):
		match str(k.get("kind", "")):
			"fg", "pat":
				att += 1
				if k.get("made", false):
					made += 1
					_add(ch, "accuracy", tuning.make_accuracy_gain)
					if int(k.get("yards", 0)) >= tuning.long_make_yards:
						_add(ch, "power", tuning.long_make_power_gain)
					if float(k.get("pressure", 0.0)) >= tuning.clutch_pressure:
						_add(ch, "resilience", tuning.clutch_resilience_gain)
						_add(ch, "charisma", tuning.clutch_charisma_gain)
				else:
					_add(ch, "fun", tuning.miss_fun)
					_add(ch, "resilience", tuning.miss_resilience_gain)
			"kickoff":
				if float(k.get("quality", 0.0)) >= 0.85:
					_add(ch, "power", tuning.good_kickoff_power_gain)
					_add(ch, "toughness", tuning.good_kickoff_toughness_gain)
	if att >= 2 and made == att:
		_add(ch, "fun", tuning.perfect_day_fun)
	var results: Dictionary = CareerContent.game_day().get("warmup", {}).get("results", {})
	for w in summary.get("warmups", []):
		var stats: Dictionary = results.get(str(w), {}).get("stats", {})
		for g in stats:
			for k in stats[g]:
				_add(ch, k, float(stats[g][k]))
	return ch


static func _add(ch: Dictionary, key: String, v: float) -> void:
	ch[key] = float(ch.get(key, 0.0)) + v


static func _count(kicks: Array, made_only: bool) -> int:
	var n := 0
	for k in kicks:
		if str(k.get("kind", "")) in ["fg", "pat"] and (not made_only or k.get("made", false)):
			n += 1
	return n


## Season / career kicking totals. Returns "FG 2/3  XP 3/3".
func _record_kicks(kicks: Array) -> String:
	var fg := [0, 0]
	var xp := [0, 0]
	for k in kicks:
		var kind := str(k.get("kind", ""))
		if not (kind in ["fg", "pat"]):
			continue
		var made: bool = k.get("made", false)
		for totals in [data.season_stats, data.career_totals]:
			totals[kind + "_att"] = int(totals.get(kind + "_att", 0)) + 1
			if made:
				totals[kind + "_made"] = int(totals.get(kind + "_made", 0)) + 1
				totals["points"] = int(totals.get("points", 0)) + (3 if kind == "fg" else 1)
				if kind == "fg":
					totals["long"] = maxi(int(totals.get("long", 0)), int(k.get("yards", 0)))
				if "GAME WINNER" in str(k.get("label", "")):
					totals["game_winners"] = int(totals.get("game_winners", 0)) + 1
		var pair := fg if kind == "fg" else xp
		pair[1] += 1
		if made:
			pair[0] += 1
	for totals in [data.season_stats, data.career_totals]:
		totals["games"] = int(totals.get("games", 0)) + 1
	var parts := PackedStringArray()
	if fg[1] > 0:
		parts.append("FG %d/%d" % fg)
	if xp[1] > 0:
		parts.append("XP %d/%d" % xp)
	return "  ".join(parts) if not parts.is_empty() else "No kicks"


func _finish_bye() -> void:
	var applied := CareerStats.apply(data, {"energy": tuning.bye_energy_recovery,
		"health": tuning.bye_health_recovery}, tuning)
	data.last_week = {"type": "bye", "week": data.week, "changes": applied}
	data.phase = PHASE_RESULTS


# --- end of week / season -----------------------------------------------------------

## Results "Continue": weekly recovery and growth, injury countdown, next week.
## This is the end-of-week autosave.
func end_week() -> void:
	if data.phase != PHASE_RESULTS:
		return
	var growth := {"energy": tuning.weekly_energy_recovery, "health": tuning.weekly_health_recovery}
	for k in CareerData.GROUP_KEYS[CareerData.FOOTBALL]:
		growth[k] = tuning.weekly_football_growth
	for k in CareerData.GROUP_KEYS[CareerData.LIFE]:
		growth[k] = float(growth.get(k, 0.0)) + (tuning.start_life - data.stat(k)) * tuning.weekly_life_drift
	CareerStats.apply(data, growth, tuning)
	if data.is_injured():
		data.injury["weeks_left"] = int(data.injury["weeks_left"]) - 1
		if int(data.injury["weeks_left"]) <= 0:
			data.injury = {"weeks_left": 0, "severity": 0.0}
			data.notice = "You're fully healthy again."
	data.week_modifiers.clear()
	data.week_index += 1
	data.week += 1
	data.phase = PHASE_SEASON_END if data.week > weeks_in_season() else PHASE_WEEK_START
	save()


## Season summary "Continue": history, then the offseason or the end of the stage.
func end_season() -> void:
	if data.phase != PHASE_SEASON_END:
		return
	data.history.append({"stage": data.stage, "season": data.season,
		"season_in_stage": data.season_in_stage, "year": class_year(), "team": data.team.get("name", ""),
		"record": data.record.duplicate(), "stats": data.season_stats.duplicate()})
	if data.stage == CareerData.STAGE_HIGH_SCHOOL and data.season_in_stage >= tuning.high_school_seasons:
		data.phase = PHASE_STAGE_END
	else:
		data.phase = PHASE_OFFSEASON
		data.week = 0
		data.pending_scenarios = ScenarioEngine.pick(data, "offseason", tuning.offseason_scenarios, rng)
		if data.pending_scenarios.is_empty():
			_start_next_season()
	save()


func _start_next_season() -> void:
	var growth := {}
	for k in CareerData.GROUP_KEYS[CareerData.FOOTBALL]:
		growth[k] = tuning.offseason_football_growth
	for k in CareerData.GROUP_KEYS[CareerData.LIFE]:
		growth[k] = (tuning.start_life - data.stat(k)) * tuning.offseason_life_reset
	CareerStats.apply(data, growth, tuning)
	data.injury = {"weeks_left": 0, "severity": 0.0}
	data.season += 1
	data.season_in_stage += 1
	data.age += 1
	_start_season(true)
