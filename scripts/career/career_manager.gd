class_name CareerManager
extends RefCounted
## The weekly loop. GameState.career holds the active one; every career screen
## asks it what to show and tells it what the player chose.
##
## data.phase is the resume point (saved), so "Continue" always lands on the
## right step:
##   week_start -> scenario -> outlook -> game -> results -> week_start ...
##   (bye week: week_start -> scenario -> results)
##   last week's results -> season_end -> (stage step) -> offseason -> week_start
## Stage steps after season_end (rules in Progression):
##   high school / junior college: recruiting (score + offers) -> after the last
##     season: college_choice (offers, walk-on tryout, junior college)
##   college: draft points -> after the last season: draft (drafted / camp
##     tryout / open tryout)
##   pro: contract (continue / re-sign / released) -> or retired (age cap, choice)
##   tryout: a field goal series in the kick scene (walk-on, camp, free agent)
##   retired: the career summary (final)
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
const PHASE_RECRUITING := "recruiting"
const PHASE_COLLEGE_CHOICE := "college_choice"
const PHASE_TRYOUT := "tryout"
const PHASE_DRAFT := "draft"
const PHASE_CONTRACT := "contract"
const PHASE_RETIRED := "retired"

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
	c.team = Progression.team_from(s, CareerData.STAGE_HIGH_SCHOOL)
	c.add_route("Freshman kicker at %s" % s.get("name", ""))
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
		PHASE_SEASON_END:
			return Screens.CAREER_SEASON
		PHASE_RECRUITING, PHASE_COLLEGE_CHOICE:
			return Screens.CAREER_RECRUITING
		PHASE_TRYOUT:
			return Screens.CAREER_TRYOUT
		PHASE_DRAFT:
			return Screens.CAREER_DRAFT
		PHASE_CONTRACT:
			return Screens.CAREER_CONTRACT
		PHASE_RETIRED:
			return Screens.CAREER_RETIRED
	return Screens.CAREER_HUB


## True while the weekly loop runs (not a transition screen or retired).
func in_season_loop() -> bool:
	return data.phase in [PHASE_WEEK_START, PHASE_SCENARIO, PHASE_OUTLOOK, PHASE_GAME,
		PHASE_RESULTS, PHASE_SEASON_END, PHASE_OFFSEASON]


# --- the season ---------------------------------------------------------------------

func entry() -> Dictionary:
	var i := data.week - 1
	return data.schedule[i] if i >= 0 and i < data.schedule.size() else {}


func is_bye() -> bool:
	return entry().get("type", "") == "bye"


func weeks_in_season() -> int:
	return data.schedule.size()


## "Freshman" .. "Senior" (high school / college), "Junior college", "Year 3" (pro).
func class_year() -> String:
	var years := ["Freshman", "Sophomore", "Junior", "Senior"]
	match data.stage:
		CareerData.STAGE_HIGH_SCHOOL:
			if data.season_in_stage >= tuning.high_school_seasons:
				return "Senior"
			return years[clampi(data.season_in_stage - 1, 0, 3)]
		CareerData.STAGE_COLLEGE:
			if data.season_in_stage >= tuning.college_seasons:
				return "Senior"
			return years[clampi(data.season_in_stage - 1, 0, 3)]
		CareerData.STAGE_JUCO:
			return "Junior college"
	return "Year %d" % data.season_in_stage


func stage_name() -> String:
	return {"high_school": "High School", "juco": "Junior College", "college": "College",
		"pro": "Pro", "free_agent": "Free Agent", "retired": "Retired"}.get(data.stage, data.stage)


## continuing: a following season (team strength drifts, the offseason's
## game-day modifiers carry into week 1). false for a brand-new career.
func _start_season(continuing: bool) -> void:
	if continuing:
		data.team["strength"] = clampf(float(data.team.get("strength", 50)) +
			rng.randf_range(-tuning.team_strength_drift, tuning.team_strength_drift), 20.0, 90.0)
	data.schedule = build_schedule(data, tuning, rng)
	data.retention_bonus = 0.0
	data.week = 1
	data.record = {"w": 0, "l": 0, "t": 0}
	data.season_stats = CareerData.empty_kick_totals()
	data.season_log = {"ids": {}, "cats": {}}
	# Offseason choices' game-day modifiers carry into week 1.
	if not continuing:
		data.week_modifiers.clear()
	data.pending_scenarios.clear()
	data.game_checkpoint = {}
	data.phase = PHASE_WEEK_START


## games_per_season games + byes_per_season byes against this stage's teams
## (colleges: your own tier first). Entries are typed ("regular" / "bye") so
## playoff weeks can be appended later.
static func build_schedule(c: CareerData, t: CareerTuning, r: RandomNumberGenerator) -> Array:
	var others := Progression.opponents(c)
	others.shuffle()
	var my_tier := str(c.team.get("tier", ""))
	if my_tier != "":
		var same := others.filter(func(s: Dictionary) -> bool: return s.get("tier", "") == my_tier)
		var rest := others.filter(func(s: Dictionary) -> bool: return s.get("tier", "") != my_tier)
		others = same + rest
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
			"opponent": Progression.team_from(opp, c.stage), "result": null})
	return out


# --- the week -----------------------------------------------------------------------

## Hub "Play Week": roll the week (weather, injury check) and pick its scenarios.
## Saved right away, so quitting can't reroll them.
func begin_week() -> void:
	if data.phase != PHASE_WEEK_START:
		return
	var when := "bye" if is_bye() else "season"
	var count := tuning.bye_scenarios if is_bye() else \
		(2 if rng.randf() < tuning.second_scenario_chance else 1)
	data.pending_scenarios = ScenarioEngine.pick(data, when, count, rng, tuning)
	if not is_bye():
		var e := entry()
		var wind_max := float(Progression.game_params(data, tuning)["wind_max"])
		var wind := rng.randf_range(0.0, wind_max) * (1.0 if rng.randf() < 0.5 else -1.0)
		e["weather"] = {"wind": roundf(wind), "gusty": rng.randf() < tuning.game_gust_chance}
		_injury_roll()
		if is_ineligible():
			data.notice = "Academically ineligible (GPA %.2f, need %.1f): you'll sit out this week's game." \
				% [data.gpa, tuning.college_min_gpa]
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
	elif is_ineligible():
		_bench_game()
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
	sim.setup(data, entry(), tuning, start_game(), max_fg, Progression.game_params(data, tuning))
	return sim


## The kick scene's look this week (posts, widths, team colors).
func kick_look() -> Dictionary:
	var gp := Progression.game_params(data, tuning)
	return Progression.look(str(gp["posts"]), float(gp["width"]), data.team, entry().get("opponent", {}))


## College: below the minimum GPA you sit out games.
func is_ineligible() -> bool:
	return data.stage == CareerData.STAGE_COLLEGE and data.gpa < tuning.college_min_gpa


## An academically ineligible week: the game is played without you.
func _bench_game() -> void:
	var sim := GameSim.new()
	sim.setup(data, entry(), tuning, rng.randi(), 0, Progression.game_params(data, tuning))
	var backup := RandomNumberGenerator.new()
	backup.seed = rng.randi()
	for i in 1000:
		var e := sim.next()
		match str(e.get("type", "")):
			"end":
				break
			"warmup":
				sim.set_warmup("loose")
			"call":
				match str(e["kind"]):
					"fg", "pat":
						sim.resolve_call({"made": backup.randf() < (0.9 if e["kind"] == "pat" else 0.65)})
					"kickoff":
						sim.resolve_call({"quality": 0.5, "carry": 45.0, "text": "The backup kicks off."})
					"onside":
						sim.resolve_call({"recovered": false, "text": "Onside kick."})
	var outcome := sim.outcome()
	data.record[{"W": "w", "L": "l", "T": "t"}[outcome]] += 1
	var applied := CareerStats.apply(data, {"fun": -4.0, "social": -2.0}, tuning)
	var opp: Dictionary = entry().get("opponent", {})
	entry()["result"] = {"us": sim.score_us, "them": sim.score_them, "outcome": outcome}
	data.recent_results.append({"week": data.week, "opponent": opp.get("name", ""), "us": sim.score_us,
		"them": sim.score_them, "outcome": outcome, "line": "Sat out (grades)"})
	while data.recent_results.size() > 5:
		data.recent_results.pop_front()
	data.last_week = {"type": "benched", "week": data.week, "opponent": opp.get("name", ""),
		"mascot": opp.get("mascot", ""), "home": entry().get("home", true), "us": sim.score_us,
		"them": sim.score_them, "outcome": outcome, "kicks": [], "line": "Sat out (grades)",
		"changes": applied}
	data.phase = PHASE_RESULTS


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
		growth[k] = float(growth.get(k, 0.0)) + (tuning.life_baseline - data.stat(k)) * tuning.weekly_life_drift
	CareerStats.apply(data, growth, tuning)
	if data.is_injured():
		data.injury["weeks_left"] = int(data.injury["weeks_left"]) - 1
		if int(data.injury["weeks_left"]) <= 0:
			data.injury = {"weeks_left": 0, "severity": 0.0}
			data.notice = "You're fully healthy again."
	# Bye-week choices' game-day modifiers carry into next week's game.
	if not is_bye():
		data.week_modifiers.clear()
	data.week_index += 1
	data.week += 1
	data.phase = PHASE_SEASON_END if data.week > weeks_in_season() else PHASE_WEEK_START
	save()


## Season summary "Continue": history, the stage's season-end step (recruiting,
## draft points, contract), then the offseason or the next stage.
func end_season() -> void:
	if data.phase != PHASE_SEASON_END:
		return
	var poor := Progression.is_poor_season(data, tuning)
	data.poor_streak = data.poor_streak + 1 if poor else 0
	var h := {"stage": data.stage, "season": data.season, "season_in_stage": data.season_in_stage,
		"year": class_year(), "team": data.team.get("name", ""), "age": data.age,
		"record": data.record.duplicate(), "stats": data.season_stats.duplicate()}
	match data.stage:
		CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO:
			var gain := Progression.recruiting_gain(data, tuning)
			data.recruiting_score = clampf(data.recruiting_score + gain, 0.0, 100.0)
			data.gpa = clampf(data.gpa + Progression.gpa_drift(data, tuning), 0.0, 4.0)
			var upd := Progression.update_offers(data, rng)
			upd["gain"] = gain
			upd["final"] = _stage_done()
			data.flags["recruiting_update"] = upd
			h["recruiting"] = data.recruiting_score
			data.phase = PHASE_RECRUITING
		CareerData.STAGE_COLLEGE:
			var gain := Progression.draft_gain(data, tuning)
			data.draft_score = clampf(data.draft_score + gain, 0.0, 100.0)
			data.gpa = clampf(data.gpa + Progression.gpa_drift(data, tuning), 0.0, 4.0)
			h["draft"] = data.draft_score
			h["draft_gain"] = gain
			if _stage_done():
				data.draft_result = Progression.draft(data, rng)
				data.phase = PHASE_DRAFT
			else:
				_begin_offseason()
		CareerData.STAGE_PRO:
			data.retention_score = Progression.retention(data, tuning)
			h["retention"] = data.retention_score
			_pro_season_end()
	data.history.append(h)
	save()


func _stage_done() -> bool:
	match data.stage:
		CareerData.STAGE_HIGH_SCHOOL:
			return data.season_in_stage >= tuning.high_school_seasons
		CareerData.STAGE_JUCO:
			return data.season_in_stage >= tuning.juco_seasons
		CareerData.STAGE_COLLEGE:
			return data.season_in_stage >= tuning.college_seasons
	return false


func _begin_offseason() -> void:
	data.phase = PHASE_OFFSEASON
	data.week = 0
	data.pending_scenarios = ScenarioEngine.pick(data, "offseason", tuning.offseason_scenarios, rng, tuning)
	if data.pending_scenarios.is_empty():
		_start_next_season()


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


## A new stage starts with its offseason (that stage's offseason scenarios),
## then season 1.
func _enter_stage(stage: String, team: Dictionary, route_text: String) -> void:
	data.stage = stage
	data.team = team
	data.season_in_stage = 0
	data.offers.clear()
	data.tryout = {}
	data.add_route(route_text)
	_begin_offseason()


# --- recruiting and college choice --------------------------------------------------

## Recruiting screen "Continue": the offseason, or (last season) the college choice.
func continue_recruiting() -> void:
	if data.phase != PHASE_RECRUITING:
		return
	if _stage_done():
		data.phase = PHASE_COLLEGE_CHOICE
	else:
		_begin_offseason()
	save()


## Everything you can pick on the college choice screen: offers first, then
## fallbacks (walk-on tryouts, junior college). Empty = the career is over.
func college_options() -> Array:
	var out: Array = []
	for off in data.offers:
		out.append({"kind": "offer", "offer": off})
	out.append_array(Progression.fallback_options(data, tuning))
	return out


func choose_college(option: Dictionary) -> void:
	match str(option.get("kind", "")):
		"offer":
			var off: Dictionary = option["offer"]
			var s := CareerContent.team_by_id(str(off["school"]))
			var team := Progression.team_from(s, CareerData.STAGE_COLLEGE)
			team["offer_type"] = off["type"]
			var start: Dictionary = Progression.tier(str(off["tier"])).get("start_draft", {})
			data.draft_score = float(start.get(str(off["type"]), 0.0))
			data.flags["walk_on"] = off["type"] == Progression.OFFER_WALK_ON
			data.poor_streak = 0
			_enter_stage(CareerData.STAGE_COLLEGE, team, "Signed with %s (%s, %s)" % [s.get("name", ""),
				Progression.OFFER_NAMES.get(off["type"], ""), Progression.tier(str(off["tier"])).get("name", "")])
		"walk_on_tryout":
			start_tryout("walk_on", str(option["school"]))
		"juco":
			var jucos := CareerContent.jucos()
			var s: Dictionary = jucos[rng.randi_range(0, jucos.size() - 1)]
			_enter_stage(CareerData.STAGE_JUCO, Progression.team_from(s, CareerData.STAGE_JUCO),
				"Went the junior college route at %s" % s.get("name", ""))
	save()


# --- tryouts ------------------------------------------------------------------------

## purpose: walk_on / camp / free_agent (progression.json "tryouts").
func start_tryout(purpose: String, team_id: String) -> void:
	var def: Dictionary = Progression.rules().get("tryouts", {}).get(purpose, {})
	var team := CareerContent.team_by_id(team_id)
	data.tryout = def.duplicate(true)
	data.tryout.merge({"purpose": purpose, "team": team_id, "team_name": str(team.get("name", "")),
		"made": 0, "taken": 0, "seed": rng.randi()}, true)
	data.phase = PHASE_TRYOUT
	save()


func tryout_passed() -> bool:
	return int(data.tryout.get("made", 0)) >= int(data.tryout.get("need", 99))


## The tryout's kicks are done: join the team, or fall back.
func finish_tryout(made: int) -> void:
	if data.phase != PHASE_TRYOUT:
		return
	data.tryout["made"] = made
	var purpose := str(data.tryout.get("purpose", ""))
	var team_id := str(data.tryout.get("team", ""))
	var team := CareerContent.team_by_id(team_id)
	var passed := tryout_passed()
	data.add_route("%s tryout with %s: %s (%d of %d)" % [purpose.replace("_", " ").capitalize(),
		team.get("name", ""), "made the team" if passed else "cut", made, (data.tryout.get("distances", []) as Array).size()])
	if passed:
		data.poor_streak = 0
		data.flags["fa_attempts"] = 0
		match purpose:
			"walk_on":
				var t := Progression.team_from(team, CareerData.STAGE_COLLEGE)
				t["offer_type"] = Progression.OFFER_WALK_ON
				data.flags["walk_on"] = true
				data.draft_score = 0.0
				_enter_stage(CareerData.STAGE_COLLEGE, t, "Walked on at %s" % team.get("name", ""))
			_:
				data.contract = Progression.contract(team_id, "camp" if purpose == "camp" else "free_agent")
				_enter_stage(CareerData.STAGE_PRO, Progression.team_from(team, CareerData.STAGE_PRO),
					"Signed with the %s (%d year, %s)" % [team.get("name", ""), int(data.contract["years_left"]),
					Progression.money(int(data.contract["salary"]))])
	else:
		data.poor_streak += 1
		var failed: Array = data.flags.get("failed_tryouts", [])
		failed.append(team_id)
		data.flags["failed_tryouts"] = failed
		data.tryout = {}
		if purpose == "walk_on":
			data.phase = PHASE_COLLEGE_CHOICE
			if college_options().is_empty():
				retire("no_options")
		elif purpose == "free_agent":
			data.flags["fa_attempts"] = int(data.flags.get("fa_attempts", 0)) + 1
			if int(data.flags["fa_attempts"]) >= tuning.free_agent_attempts:
				retire("out_of_football")
			else:
				# A year passes before the next chance.
				data.age += 1
				data.season += 1
				_free_agency("A year passes without a team.")
		else:
			_free_agency("Cut at training camp.")
	save()


# --- draft, free agency, contracts ------------------------------------------------

## Draft screen "Sign": drafted players sign their rookie contract.
func sign_drafted() -> void:
	var d := data.draft_result
	if data.phase != PHASE_DRAFT or str(d.get("kind", "")) != "drafted":
		return
	data.contract = Progression.contract(str(d["team"]), "drafted", int(d["round"]))
	var team := CareerContent.team_by_id(str(d["team"]))
	_enter_stage(CareerData.STAGE_PRO, Progression.team_from(team, CareerData.STAGE_PRO),
		"Drafted in round %d by the %s (%d years, %s)" % [int(d["round"]), team.get("name", ""),
		int(data.contract["years_left"]), Progression.money(int(data.contract["salary"]))])
	save()


## Draft / free agency screen: take the tryout on offer (camp or open).
func take_tryout() -> void:
	var d := data.draft_result
	var kind := str(d.get("kind", "open"))
	start_tryout("camp" if kind == "camp" else "free_agent", str(d.get("team", "")))


## No team: a year in free agency, then another open tryout (or the end).
func _free_agency(why: String) -> void:
	data.stage = CareerData.STAGE_FREE_AGENT
	if data.poor_streak >= tuning.career_end_poor_streak or data.age >= tuning.pro_age_cap:
		retire("out_of_football")
		return
	var clubs := CareerContent.pro_clubs().filter(func(s: Dictionary) -> bool:
		return not (str(s["id"]) in data.flags.get("failed_tryouts", [])))
	if clubs.is_empty():
		retire("out_of_football")
		return
	var club: Dictionary = clubs[rng.randi_range(0, clubs.size() - 1)]
	data.draft_result = {"round": 0, "kind": "free_agency", "team": str(club["id"]),
		"team_name": str(club["name"]), "why": why}
	data.phase = PHASE_DRAFT


## After a pro season: age cap, release, contract end, or keep going.
func _pro_season_end() -> void:
	data.contract["years_left"] = int(data.contract.get("years_left", 1)) - 1
	if data.age >= tuning.pro_age_cap:
		retire("age_cap")
		return
	var status := "continue"
	if data.retention_score < tuning.release_below:
		status = "released"
	elif int(data.contract["years_left"]) <= 0:
		if data.retention_score >= tuning.resign_min:
			status = "resign"
			data.contract["offer"] = Progression.resign_offer(data.retention_score, rng)
		else:
			status = "not_resigned"
	data.contract["status"] = status
	data.phase = PHASE_CONTRACT


## Contract screen buttons.
func contract_continue() -> void:
	if data.phase != PHASE_CONTRACT:
		return
	match str(data.contract.get("status", "")):
		"continue":
			_begin_offseason()
		"resign":
			var off: Dictionary = data.contract.get("offer", {})
			data.contract["years_left"] = int(off.get("years", 1))
			data.contract["salary"] = int(off.get("salary", 0))
			data.contract.erase("offer")
			data.add_route("Re-signed with the %s (%d years, %s)" % [data.contract.get("team_name", ""),
				int(off.get("years", 1)), Progression.money(int(off.get("salary", 0)))])
			_begin_offseason()
		"released", "not_resigned":
			data.poor_streak += 1
			data.add_route("%s by the %s" % ["Released" if data.contract["status"] == "released" else "Not re-signed",
				data.contract.get("team_name", "")])
			data.flags["failed_tryouts"] = [str(data.contract.get("team", ""))]
			data.contract = {}
			_free_agency("Looking for a new team.")
	save()


## Ends the career: reason age_cap / chose / out_of_football / no_options.
func retire(reason: String) -> void:
	var text: String = {"age_cap": "Retired at %d, the end of the road." % data.age,
		"chose": "Retired on your own terms at %d." % data.age,
		"out_of_football": "No team called. Your playing days are over at %d." % data.age,
		"no_options": "No college roster spot. Your playing days end after high school."}.get(reason, "Retired.")
	data.retirement = {"reason": reason, "text": text, "age": data.age, "season": data.season,
		"stage": data.stage}
	data.add_route(text)
	data.stage = CareerData.STAGE_RETIRED
	data.phase = PHASE_RETIRED
	save()
