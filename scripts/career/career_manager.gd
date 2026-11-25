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
## After retirement (R10): the closing scenes (scenarios with when "epilogue"),
## then the Hall of Fame vote, then the career summary (PHASE_RETIRED).
const PHASE_EPILOGUE := "epilogue"
const PHASE_HALL := "hall_of_fame"

## All-time records (RecordBook): you set, tied or entered a record list.
## events: [{kind "record" / "tie" / "entered", headline ("NEW RECORD",
## "Entered top 25"), text, level, scope, scope_name, span, cat, value,
## value_text, rank, season, week}], best first. Also kept in data.records
## ("log"), so screens that open later can show them.
signal records_set(events: Array)

var data: CareerData
var tuning: CareerTuning
var rng := RandomNumberGenerator.new()


func _init(c: CareerData, t: CareerTuning = null) -> void:
	data = c
	tuning = t if t != null else CareerTuning.get_default()
	rng.randomize()


## A new career in `slot`, saved and ready at week 1. Every career starts at
## Hoboken High School (TeamDatabase.start_team, data/teams/leagues.json).
static func create(slot: int, player_name: String, number: int, appearance: Dictionary) -> CareerManager:
	var t := CareerTuning.get_default()
	var c := CareerData.create(player_name, t)
	c.slot = slot
	c.player["number"] = number
	c.player["appearance"] = appearance.duplicate()
	var s := TeamDatabase.start_team()
	c.player["hometown"] = str(s.get("town", ""))
	c.team = Progression.team_from(s, CareerData.STAGE_HIGH_SCHOOL)
	c.add_route("Freshman kicker at %s" % s.get("name", ""))
	var m := CareerManager.new(c, t)
	m._start_season(false)
	m.save()
	m._event({"event": "career_started"})
	return m


static func load_slot(slot: int) -> CareerManager:
	var c := CareerSave.load_slot(slot)
	if c == null:
		return null
	var m := CareerManager.new(c)
	m._sanitize()
	return m


## Old saves can reference content that has since been renamed or removed
## (Stage 3 placeholder scenarios, for example): drop unknown pending /
## queued scenarios and game-day modifiers, and move on if a step is left
## with nothing to show.
func _sanitize() -> void:
	data.pending_scenarios = data.pending_scenarios.filter(func(id: Variant) -> bool:
		return not CareerContent.scenario(str(id)).is_empty())
	data.queued_scenarios = data.queued_scenarios.filter(func(q: Variant) -> bool:
		return not CareerContent.scenario(str(q.get("id", ""))).is_empty())
	data.week_modifiers = data.week_modifiers.filter(func(id: Variant) -> bool:
		return not CareerContent.modifier(str(id)).is_empty())
	if data.phase in [PHASE_SCENARIO, PHASE_OFFSEASON] and data.pending_scenarios.is_empty():
		_after_scenarios()
	if data.schedule.is_empty() and in_season_loop() and data.phase != PHASE_OFFSEASON:
		_start_season(true)
	# Saves from before leagues: a league fitted around this season's schedule.
	League.migrate(data, tuning)
	# Saves from before the attribute caps: clamp to this stage, refund the SP.
	Leveling.fix_old_save(data, tuning)


func save() -> bool:
	# New traits since the last save -> a career event (for "all traits").
	if data.traits.size() > int(data.flags.get("traits_reported", 0)):
		data.flags["traits_reported"] = data.traits.size()
		_event({"event": "traits", "count": data.traits.size()})
	return CareerSave.save(data)


## Career milestones go to GameState (My Stats career totals + achievements).
## In-memory careers (slot 0, the balance simulator) report nothing.
## Checks the record books after a game (records and ties) or at the end of
## the season (final: also "entered top 25"), and tells the UI.
func _records(final: bool) -> void:
	var events := RecordBook.check(data, final)
	if events.is_empty():
		return
	var pending: Array = (data.records.get("pending", []) as Array) + events
	data.records["pending"] = pending.slice(maxi(pending.size() - 60, 0))  # the newest, until a screen shows them
	records_set.emit(events)
	for e in events:
		if str(e["kind"]) == "record":
			_event({"event": "record", "level": e["level"], "scope": e["scope_kind"], "cat": e["cat"]})


func _event(e: Dictionary) -> void:
	if data.slot != 0:
		GameState.report_career_event(e)


## How far this career has gone: {rank, text, seasons} for My Stats.
## rank = stage (1 high school, 2 junior college, 3 college, 4 pro) * 100 + pro seasons.
func career_result() -> Dictionary:
	var pro := data.history.filter(func(h: Dictionary) -> bool: return h.get("stage", "") == CareerData.STAGE_PRO)
	var col := data.history.filter(func(h: Dictionary) -> bool: return h.get("stage", "") == CareerData.STAGE_COLLEGE)
	var jc := data.history.filter(func(h: Dictionary) -> bool: return h.get("stage", "") == CareerData.STAGE_JUCO)
	var r := {"seasons": data.history.size()}
	if not pro.is_empty():
		r["rank"] = 400 + pro.size()
		r["text"] = "Pro, %d season%s (%s)" % [pro.size(), "" if pro.size() == 1 else "s", pro[-1].get("team", "")]
	elif not col.is_empty():
		r["rank"] = 300
		r["text"] = "College (%s)" % col[-1].get("team", "")
	elif not jc.is_empty():
		r["rank"] = 200
		r["text"] = "Junior college (%s)" % jc[-1].get("team", "")
	else:
		r["rank"] = 100
		r["text"] = "High school (%s)" % data.team.get("name", "")
	return r


## Which screen this phase belongs on.
func screen_path() -> String:
	match data.phase:
		PHASE_SCENARIO, PHASE_OFFSEASON, PHASE_EPILOGUE:
			return Screens.CAREER_SCENARIO
		PHASE_HALL:
			return Screens.CAREER_HALL
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


## Regular-season weeks (games and byes), without the postseason.
func regular_weeks() -> int:
	return data.schedule.filter(func(e: Dictionary) -> bool: return not Postseason.is_postseason(e)).size()


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
	Bench.new_season(data)
	Postseason.new_season(data)
	_season_flags()
	Followers.new_season(data)
	Fatigue.new_season(data)
	if continuing:
		data.team["strength"] = clampf(float(data.team.get("strength", 50)) +
			rng.randf_range(-tuning.team_strength_drift, tuning.team_strength_drift), 20.0, 90.0)
	# The stage's league (League): every team's schedule; yours is taken from it.
	if League.prepare_season(data, tuning):
		data.schedule = League.player_schedule(data)
		Relationships.schedule_tyler(data, data.schedule)
		League.align_to_schedule(data)
	else:
		data.schedule = build_schedule(data, tuning, rng)
		Relationships.schedule_tyler(data, data.schedule)
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


## Game-set flags at the start of a season (for scenario writers):
##   contract_year    this pro season started with 1 contract year left
##   re_signed        re-signed: true through the next season
##   signed_new_club  signed with a new pro club (not the first): true through
##                    the first season there
## released (ever released / not re-signed) and pro_clubs (names) stay.
func _season_flags() -> void:
	# (data.season is already the season about to be played.)
	data.flags["contract_year"] = data.stage == CareerData.STAGE_PRO and int(data.contract.get("years_left", 0)) == 1
	for f in ["re_signed", "signed_new_club"]:
		if bool(data.flags.get(f, false)) and data.season > int(data.flags.get(f + "_season", data.season)):
			data.flags[f] = false


## Engine state wins over story flags: scenes may clear kicking_slump,
## coach_lost_faith or benched, but while the coach still doubts you, a bad
## stretch is still fresh, or you're still benched, they're set again (after
## every choice and at the start of every week). Use the metrics slump_now /
## benched_now for "right now".
func _sync_flags() -> void:
	if not data.coach_doubt.is_empty():
		data.flags["kicking_slump"] = true
	if data.stretch_cooldown > 0:
		data.flags["coach_lost_faith"] = true
	if Bench.benched(data):
		data.flags["benched"] = true


## CareerTuning.games_for(stage) games (high school 10, college 12, pro 17)
## + byes_per_season byes against this stage's teams: your own conference
## first (pro: your division, "AFC East"), then your division (pro: "AFC") or
## college tier, then the rest. Entries are typed ("regular" / "bye");
## postseason weeks ("playoff") are appended by Postseason.advance().
## Only for stages without a league: seasons with one take the player's
## schedule from the league's (League.player_schedule).
static func build_schedule(c: CareerData, t: CareerTuning, r: RandomNumberGenerator) -> Array:
	var others := Progression.opponents(c)
	Progression.shuffle(others, r)
	var my_conf := str(TeamDatabase.team(str(c.team.get("id", ""))).get("conference", c.team.get("conference", "")))
	var my_tier := str(c.team.get("tier", ""))
	var my_div := str(TeamDatabase.team(str(c.team.get("id", ""))).get("division", c.team.get("division", "")))
	var rank := func(s: Dictionary) -> int:
		if my_conf != "" and str(s.get("conference", "")) == my_conf:
			return 0
		if my_tier != "" and str(s.get("tier", "")) == my_tier:
			return 1
		return 1 if my_tier == "" and my_div != "" and str(s.get("division", "")) == my_div else 2
	var groups: Array = [[], [], []]
	for s in others:
		groups[rank.call(s)].append(s)
	others = groups[0] + groups[1] + groups[2]
	var total := t.games_for(c.stage) + t.byes_per_season
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
	# Benched and the time is up: the audition comes first (a tryout), then the week.
	if Bench.audition_due(data):
		start_audition()
		return
	# A suspended game isn't a benched game (Reputation): pass it as a bye.
	Bench.begin_week(data, tuning, is_bye() or Reputation.suspended(data))
	_sync_flags()
	var when := "bye" if is_bye() else "season"
	var count := tuning.bye_scenarios if is_bye() else \
		(2 if rng.randf() < tuning.second_scenario_chance else 1)
	data.pending_scenarios = ScenarioEngine.pick(data, when, count, rng, tuning)
	if not is_bye():
		var e := entry()
		var wind_max := float(game_params()["wind_max"])
		var wind := rng.randf_range(0.0, wind_max) * (1.0 if rng.randf() < 0.5 else -1.0)
		e["weather"] = {"wind": roundf(wind), "gusty": rng.randf() < tuning.game_gust_chance}
		_roll_cold(e["weather"])
		_injury_roll()
		if Reputation.suspended(data):
			data.notice = "SUSPENDED: you sit out this week's game%s. %d game%s left." % [
				(" (%s)" % data.suspension.get("reason", "")) if str(data.suspension.get("reason", "")) != "" else "",
				int(data.suspension["weeks_left"]), "" if int(data.suspension["weeks_left"]) == 1 else "s"]
		elif is_ineligible():
			data.notice = "Academically ineligible (GPA %.2f, need %.1f): you'll sit out this week's game." \
				% [data.gpa, tuning.college_min_gpa]
	data.phase = PHASE_SCENARIO
	if data.pending_scenarios.is_empty():
		_after_scenarios()
	save()


## Late in the season: maybe a cold or snowy game ("temp" and "chill" yards).
func _roll_cold(w: Dictionary) -> void:
	if float(data.week) < ceilf(weeks_in_season() * tuning.late_season_from):
		return
	var r := rng.randf()
	if r < tuning.snow_chance:
		w["temp"] = "snow"
		w["chill"] = rng.randi_range(tuning.snow_range_min, tuning.snow_range_max)
	elif r < tuning.snow_chance + tuning.cold_chance:
		w["temp"] = "cold"
		w["chill"] = rng.randi_range(tuning.cold_range_min, tuning.cold_range_max)


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
	_sync_flags()
	data.pending_scenarios.pop_front()
	if out.get("challenge", false):
		start_challenge(str(s["id"]), index)
		return out
	if data.pending_scenarios.is_empty():
		_after_scenarios()
	save()
	return out


func _after_scenarios() -> void:
	if data.phase == PHASE_EPILOGUE:
		_next_epilogue()
	elif data.phase == PHASE_OFFSEASON:
		_start_next_season()
	elif is_bye():
		_finish_bye()
	elif is_ineligible() or Reputation.suspended(data):
		_bench_game()
	else:
		data.phase = PHASE_OUTLOOK


func _injury_roll() -> void:
	if data.is_injured():
		return
	var p := KickProfile.build(data, tuning)
	if rng.randf() < p.injury_risk:
		data.injury = {"weeks_left": maxi(rng.randi_range(tuning.injury_weeks_min, tuning.injury_weeks_max)
				+ int(Perks.total(data, "injury_weeks")), 1),
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
	var p := profile()
	var max_fg := KickTrust.coach_limit(data, p, tuning)
	var params := game_params()
	params["call_random_yd"] = tuning.coach_call_random_yd
	params["call_cap_yd"] = floori(p.fg_range + 0.001)
	params["fan_pressure"] = Followers.fan_pressure(data, tuning)
	sim.setup(data, entry(), tuning, start_game(), max_fg, params)
	if Bench.this_week(data):  # benched: the backup kicks the field goals
		sim.backup_fg = true
		sim.backup_name = Bench.backup_name(data)
		sim.backup_make = Bench.backup_make(data, tuning)
	return sim


## This week's game parameters: the stage's (Progression.game_params), plus
## the postseason's (no ties, more pressure) in a postseason week.
func game_params() -> Dictionary:
	return Postseason.adjust_params(Progression.game_params(data, tuning), entry())


## True in a postseason week (Postseason).
func is_postseason() -> bool:
	return Postseason.is_postseason(entry())


## "(OT)" / "(2OT)" for a result that went to overtime, "" otherwise.
static func ot_tag(r: Dictionary) -> String:
	var ot: Dictionary = r.get("ot", {}) if r.get("ot") is Dictionary else {}
	if ot.is_empty():
		return ""
	var n := int(ot.get("rounds", 1))
	return "(OT)" if str(ot.get("rule", "")) == "pro" or n <= 1 else "(%dOT)" % n


## This stage's overtime rule in one line (Outlook).
static func ot_rule_text(rule: String, t: CareerTuning) -> String:
	match rule:
		"pro":
			return "Overtime: one %d-minute period; both teams get the ball unless the first scores a touchdown, then the next score wins. It can end tied." % roundi(t.ot_pro_minutes)
		"college":
			return "Overtime: each team gets the ball at the 25 (field goals around %d yards). From the third overtime, two-point tries only: no kicks." % t.ot_college_fg_yards
	return "Overtime: each team gets the ball at the 10 (field goals around %d yards), up to %d rounds; then it stays a tie." % [t.ot_hs_fg_yards, t.ot_hs_rounds]


## The kick scene's look this week (posts, widths, team colors, the stadium).
func kick_look() -> Dictionary:
	var gp := game_params()
	var look := Progression.look(str(gp["posts"]), float(gp["width"]), data.team, entry().get("opponent", {}))
	look["stadium"] = Stadiums.for_game(data, entry(), tuning)
	return look


## College: below the minimum GPA you sit out games.
func is_ineligible() -> bool:
	return data.stage == CareerData.STAGE_COLLEGE and data.gpa < tuning.college_min_gpa


## An academically ineligible week: the game is played without you.
## Also a suspended game (Reputation): no kicks, no game skill points or
## followers, not a benched week, no slump (only practice counts).
func _bench_game() -> void:
	var suspended := Reputation.suspended(data)
	var why := "Sat out (suspended)" if suspended else "Sat out (grades)"
	if suspended:
		data.bench["this_week"] = false  # a suspension never counts as a benched week
	var sim := GameSim.new()
	sim.backup = true
	sim.setup(data, entry(), tuning, rng.randi(), 0, game_params())
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
	_count_result(outcome)
	var applied := CareerStats.apply(data, {"fun": tuning.suspend_fun, "social": tuning.suspend_social}
		if suspended else {"fun": -4.0, "social": -2.0}, tuning)
	var team := {}
	if suspended and data.people.has(Relationships.TEAM):
		team = Relationships.apply(data, {Relationships.TEAM: tuning.suspend_team})
	var opp: Dictionary = entry().get("opponent", {})
	var ot: Dictionary = sim.summary().get("ot", {})
	entry()["result"] = {"us": sim.score_us, "them": sim.score_them, "outcome": outcome}
	League.after_week(data, data.week)
	data.recent_results.append({"week": data.week, "opponent": opp.get("name", ""), "us": sim.score_us,
		"them": sim.score_them, "outcome": outcome, "line": why, "ot": ot})
	while data.recent_results.size() > 5:
		data.recent_results.pop_front()
	data.last_week = {"type": "benched", "week": data.week, "opponent": opp.get("name", ""),
		"mascot": opp.get("mascot", ""), "home": entry().get("home", true), "us": sim.score_us,
		"them": sim.score_them, "outcome": outcome, "kicks": [], "line": why,
		"changes": applied, "ot": ot}
	if suspended:
		data.last_week["suspended"] = {"reason": str(data.suspension.get("reason", "")),
			"left": Reputation.served(data), "team": team}
	_tag_postseason()
	_week_practice()
	data.phase = PHASE_RESULTS


## A postseason game's Results: which round, and was it the final.
func _tag_postseason() -> void:
	if is_postseason():
		data.last_week["postseason"] = str(entry().get("round_name", "Postseason"))
		data.last_week["final"] = bool(entry().get("final", false))


## The game is over: record, stats, life/football changes, results screen.
func finish_game(summary: Dictionary) -> void:
	var opp: Dictionary = entry().get("opponent", {})
	var outcome := str(summary.get("outcome", "T"))
	_count_result(outcome)
	var changes := game_changes(summary)
	var applied := CareerStats.apply(data, changes, tuning)
	# Coach / Team from your kicks (the same steps the game screen showed),
	# then skill points. Both read today's range and the pre-game window.
	var range := profile().fg_range
	var trust := KickTrust.apply_game(data, summary.get("kicks", []), range, tuning)
	var sat := Bench.this_week(data)
	# Benched weeks earn no game skill points (practice and choices still do).
	for pair in ([] if sat else SkillPoints.from_game(summary.get("kicks", []), range, tuning)):
		SkillPoints.earn_weekly(data, int(pair[1]), str(pair[0]), tuning)
	# Sideline warmups: at most sp_warmup_max_per_game skill points a game day.
	var warm_res: Dictionary = CareerContent.game_day().get("warmup", {}).get("results", {})
	var warm_sp := 0
	for w in summary.get("warmups", []):
		warm_sp += int(warm_res.get(str(w), {}).get("skill_points", 0))
	var warm_left := maxi(tuning.sp_warmup_max_per_season - int(data.sp_sources.get("Sideline warmup", 0)), 0)
	if not sat:
		SkillPoints.earn(data, mini(mini(warm_sp, tuning.sp_warmup_max_per_game), warm_left), "Sideline warmup")
	# Followers: your kicks (the backup's don't count); a benched week costs some.
	Followers.from_game(data, summary.get("kicks", []), range, rng, tuning)
	if sat:
		Followers.gain(data, tuning.buzz_bench_week, "Benched", tuning)
	_week_practice()
	# Benching: the backup's line this week, or a new bench after this game.
	var bench_info := {}
	if sat:
		var bk: Array = summary.get("kicks", []).filter(func(k: Dictionary) -> bool:
			return str(k.get("kind", "")) == "fg" and k.get("backup", false))
		bench_info = {"sat": true, "backup": Bench.backup_name(data),
			"made": bk.filter(func(k: Dictionary) -> bool: return k.get("made", false)).size(), "att": bk.size(),
			"weeks_left": int(data.bench.get("weeks_left", 0))}
	elif Bench.check_after_game(data, tuning, summary.get("kicks", [])):
		Followers.gain(data, tuning.buzz_benched, "Benched", tuning)
		bench_info = {"started": true, "backup": Bench.backup_name(data), "weeks": int(data.bench["weeks"]),
			"reason": str(data.bench.get("reason", ""))}
	for k in summary.get("kicks", []):
		if str(k.get("kind", "")) == "fg" and not k.get("backup", false):
			if k.get("made", false):
				data.fg_streak = data.fg_streak + 1 if data.fg_streak > 0 else 1
			else:
				data.fg_streak = data.fg_streak - 1 if data.fg_streak < 0 else -1
	# Kick nerves: a slump starts after a run of misses, ends after clean kicks.
	KickNerves.after_game(data, summary.get("kicks", []), tuning)
	var line := _record_kicks(summary.get("kicks", []))
	var e := entry()
	e["result"] = {"us": summary.get("us", 0), "them": summary.get("them", 0), "outcome": outcome}
	var result := {"week": data.week, "opponent": opp.get("name", ""), "us": summary.get("us", 0),
		"them": summary.get("them", 0), "outcome": outcome, "line": line}
	if summary.has("ot"):  # overtime (GameSim): rule, rounds, two_point
		e["result"]["ot"] = summary["ot"]
		result["ot"] = summary["ot"]
	# The rest of the league's week too, so Results and Standings agree.
	League.after_week(data, data.week)
	data.recent_results.append(result)
	while data.recent_results.size() > 5:
		data.recent_results.pop_front()
	data.last_week = {"type": "game", "week": data.week, "opponent": opp.get("name", ""),
		"mascot": opp.get("mascot", ""), "home": e.get("home", true),
		"us": summary.get("us", 0), "them": summary.get("them", 0),
		"outcome": outcome, "kicks": summary.get("kicks", []), "warmups": summary.get("warmups", []),
		"line": line, "changes": applied, "trust": trust, "bench": bench_info, "ot": summary.get("ot", {})}
	_tag_postseason()
	data.game_checkpoint = {}
	data.phase = PHASE_RESULTS
	_records(false)
	save()
	for k in summary.get("kicks", []):
		if k.get("made", false) and not k.get("backup", false) and "GAME WINNER" in str(k.get("label", "")):
			_event({"event": "game_winner", "yards": int(k.get("yards", 0))})
	if data.slot != 0:
		GameState.report_run({"mode": "career", "outcome": outcome,
			"makes": int(_count(summary.get("kicks", []), true)),
			"kicks": int(_count(summary.get("kicks", []), false)),
			"stage": data.stage})


## A regular-season game counts in the record; a postseason game is counted by
## Postseason.advance() at the end of the week.
func _count_result(outcome: String) -> void:
	if not is_postseason():
		data.record[{"W": "w", "L": "l", "T": "t"}[outcome]] += 1


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
		if k.get("backup", false):
			continue  # the backup's kicks don't change your stats
		match str(k.get("kind", "")):
			"fg", "pat":
				att += 1
				if k.get("made", false):
					made += 1
					if float(k.get("pressure", 0.0)) >= tuning.clutch_pressure:
						_add(ch, "charisma", tuning.clutch_charisma_gain)
				else:
					_add(ch, "fun", tuning.miss_fun)
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
		if k.get("backup", false):
			continue
		if str(k.get("kind", "")) in ["fg", "pat"] and (not made_only or k.get("made", false)):
			n += 1
	return n


## Season / career kicking totals. Returns "FG 2/3  XP 3/3".
func _record_kicks(kicks: Array) -> String:
	var fg := [0, 0]
	var xp := [0, 0]
	for k in kicks:
		var kind := str(k.get("kind", ""))
		if k.get("backup", false):
			continue  # the backup's kicks aren't yours
		_log_kick(k)
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


## One kick into CareerData.kick_log (Stats screen: distances, streaks,
## kickoffs). Same kicks the season totals count.
func _log_kick(k: Dictionary) -> void:
	var kind := str(k.get("kind", ""))
	var e := {"kind": kind, "season": data.season, "stage": data.stage}
	match kind:
		"fg", "pat":
			var lbl := str(k.get("label", ""))
			var made: bool = k.get("made", false)
			e["yd"] = int(k.get("yards", 0))
			e["made"] = 1 if made else 0
			if "GAME WINNER" in lbl or "TO TIE" in lbl:
				e["clutch"] = 1
			if made and "GAME WINNER" in lbl:
				e["gw"] = 1
		"kickoff":
			e["carry"] = roundi(float(k.get("carry", 0.0)))
			e["tb"] = 1 if float(k.get("quality", 0.0)) >= 0.99 else 0
		"onside":
			e["rec"] = 1 if k.get("recovered", false) else 0
		_:
			return
	data.kick_log.append(e)


func _finish_bye() -> void:
	var applied := CareerStats.apply(data, {"energy": tuning.bye_energy_recovery,
		"health": tuning.bye_health_recovery}, tuning)
	data.last_week = {"type": "bye", "week": data.week, "changes": applied}
	_week_practice()
	data.phase = PHASE_RESULTS


## This week's practice skill points (shown on the Results screen): the weekly
## practice (less when Energy is low) and a rival Tyler pushing you.
func _week_practice() -> void:
	var tired := data.stat("energy") < tuning.low_energy_threshold
	var intensity := Fatigue.practice(data)
	SkillPoints.earn_weekly(data, Fatigue.practice_sp(data, tuning),
		"Practice" + (" (%s)" % intensity if intensity != "normal" else (" (tired)" if tired else "")), tuning)
	SkillPoints.earn_weekly(data, Relationships.rival_sp(data, tuning),
		"%s pushing you" % Relationships.name_of(data, Relationships.TYLER), tuning)


# --- end of week / season -----------------------------------------------------------

## Results "Continue": weekly recovery and growth, injury countdown, next week.
## This is the end-of-week autosave.
func end_week() -> void:
	if data.phase != PHASE_RESULTS:
		return
	# Fatigue first, on the week's Energy before recovery: exhaustion, the
	# warning, permanent loss, good habits; then practice intensity's Energy.
	var practice := Fatigue.end_week(data, tuning)
	var growth := {"energy": tuning.weekly_energy_recovery + float(practice.get("energy", 0.0)),
		"health": tuning.weekly_health_recovery}
	for k in CareerData.GROUP_KEYS[CareerData.LIFE]:
		growth[k] = float(growth.get(k, 0.0)) + (tuning.life_baseline - data.stat(k)) * tuning.weekly_life_drift
	var rel := Relationships.weekly_growth(data, tuning)
	for k in rel:
		growth[k] = float(growth.get(k, 0.0)) + float(rel[k])
	CareerStats.apply(data, growth, tuning)
	Relationships.end_week(data, tuning)
	KickTrust.end_week(data)
	KickNerves.end_week(data, tuning)
	Bench.end_week(data, tuning)
	CareerStats.apply(data, Followers.end_week(data, tuning), tuning)
	data.sp_week.clear()
	data.trust_week = {}
	if data.is_injured():
		data.injury["weeks_left"] = int(data.injury["weeks_left"]) - 1
		if int(data.injury["weeks_left"]) <= 0:
			data.injury = {"weeks_left": 0, "severity": 0.0}
			data.notice = "You're fully healthy again."
	# Bye-week choices' game-day modifiers carry into next week's game.
	if not is_bye():
		data.week_modifiers.clear()
	# The league's week (League), if the game didn't already (a bye week).
	League.after_week(data, data.week)
	data.week_index += 1
	data.week += 1
	# Past the schedule: the postseason decides (another game is appended, or
	# the season is over).
	if data.week > weeks_in_season():
		var post := Postseason.advance(data, rng, tuning)
		if str(post.get("text", "")) != "":
			data.notice = str(post["text"]) if data.notice == "" else data.notice + " " + str(post["text"])
		if str(post.get("event", "")) in ["qualified", "champion"]:
			_event({"event": "postseason", "kind": post["event"]})
	data.phase = PHASE_SEASON_END if data.week > weeks_in_season() else PHASE_WEEK_START
	if data.phase == PHASE_SEASON_END:
		# All-time records for the finished season and the career so far
		# (shown on the season summary).
		_records(true)
	save()


## Season summary "Continue": history, the stage's season-end step (recruiting,
## draft points, contract), then the offseason or the next stage.
func end_season() -> void:
	if data.phase != PHASE_SEASON_END:
		return
	# Stage caps (Leveling): every season, and so every stage, ends within them.
	# Gains already stop at the caps; this is the hard guarantee.
	Leveling.enforce(data)
	var poor := Progression.is_poor_season(data, tuning)
	data.poor_streak = data.poor_streak + 1 if poor else 0
	# Pros who preserve their attributes (maintenance, from aging_start_age)
	# keep their standing better: retention_maintained per attribute preserved.
	var preserved := 0
	if Aging.active(data, tuning):
		for st in Aging.STATS:
			if Aging.maintained(data, st):
				preserved += 1
	var aged := Aging.apply_season_end(data, tuning)
	var bonus := SkillPoints.season_bonus(data, tuning)
	SkillPoints.earn(data, bonus, "Season bonus")
	data.sp_week.clear()
	# Followers: a good season's gain, then the small progress bonus below.
	var fans := Followers.season_end(data, tuning)
	data.social["week"] = []
	var h := {"stage": data.stage, "season": data.season, "season_in_stage": data.season_in_stage,
		"year": class_year(), "team": data.team.get("name", ""), "team_id": str(data.team.get("id", "")),
		"age": data.age,
		"record": data.record.duplicate(), "stats": data.season_stats.duplicate(),
		"sp": data.sp_season, "sp_bonus": bonus, "aged": aged, "sp_sources": data.sp_sources.duplicate(),
		"overall": snappedf(Leveling.overall(data), 0.1),
		"postseason": data.postseason.duplicate(true), "postseason_text": Postseason.summary_text(data.postseason),
		"fg_range": snappedf(KickRange.fg_range(data, tuning), 0.1),
		"kickoff_range": snappedf(KickRange.kickoff_range(data, tuning), 0.1),
		"followers": data.followers, "followers_gain": int(data.social.get("season_gain", 0)),
		"follower_sources": (data.social.get("season_sources", {}) as Dictionary).duplicate(),
		"follower_bonus": float(fans["progress"])}
	# Recorded first, so a retirement at the age cap includes this season.
	data.history.append(h)
	match data.stage:
		CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO:
			var gain := Progression.recruiting_gain(data, tuning) + float(fans["progress"]) \
				+ Postseason.progress_bonus(data)
			data.recruiting_score = clampf(data.recruiting_score + gain, 0.0, 100.0)
			data.gpa = clampf(data.gpa + Progression.gpa_drift(data, tuning), 0.0, 4.0)
			var upd := Progression.update_offers(data, rng)
			for off in upd["new"]:
				_event({"event": "offer", "type": off["type"], "tier": off["tier"]})
			upd["gain"] = gain
			upd["final"] = _stage_done()
			upd["coach_rec"] = Progression.coach_rec(data, tuning)
			if _stage_done() and data.stage == CareerData.STAGE_HIGH_SCHOOL:
				Relationships.advance_tyler(data, CareerData.STAGE_COLLEGE)
				if Relationships.known(data, Relationships.TYLER):
					upd["tyler"] = Relationships.tyler_team(data).duplicate()
			data.flags["recruiting_update"] = upd
			h["recruiting"] = data.recruiting_score
			data.phase = PHASE_RECRUITING
		CareerData.STAGE_COLLEGE:
			var gain := Progression.draft_gain(data, tuning) + float(fans["progress"]) \
				+ Postseason.progress_bonus(data)
			data.draft_score = clampf(data.draft_score + gain, 0.0, 100.0)
			data.gpa = clampf(data.gpa + Progression.gpa_drift(data, tuning), 0.0, 4.0)
			h["draft"] = data.draft_score
			h["draft_gain"] = gain
			# Dismissed (story flag "dismissed"): out of the program now, and out of
			# the draft: undrafted free agency (the open tryout path).
			var dismissed := bool(data.flags.get("dismissed", false))
			if _stage_done() or dismissed:
				Relationships.advance_tyler(data, CareerData.STAGE_PRO)
				data.draft_result = Progression.draft(data, rng)
				if dismissed:
					data.draft_result["kind"] = "open"
					data.draft_result["round"] = 0
					data.draft_result["dismissed"] = true
					_dismissal_done()
				data.phase = PHASE_DRAFT
			else:
				_begin_offseason()
		CareerData.STAGE_PRO:
			# The season's pay, after taxes and the agent's fee (Savings).
			h["pay"] = Savings.pay_season(data, tuning)
			data.retention_bonus += float(fans["progress"]) + tuning.retention_maintained * preserved \
				+ Postseason.progress_bonus(data)
			data.retention_score = Progression.retention(data, tuning)
			h["retention"] = data.retention_score
			_pro_season_end()
	h["savings"] = data.savings
	var res := career_result()
	_event({"event": "season_end", "seasons": res["seasons"], "rank": res["rank"], "result_text": res["text"]})
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
	for k in CareerData.GROUP_KEYS[CareerData.LIFE]:
		growth[k] = (tuning.start_life - data.stat(k)) * tuning.offseason_life_reset
	CareerStats.apply(data, growth, tuning)
	data.injury = {"weeks_left": 0, "severity": 0.0}
	data.sp_season = 0
	data.sp_sources = {}
	SkillPoints.earn(data, tuning.sp_offseason, "Offseason training")
	data.sp_week.clear()
	data.notice = "Offseason training: +%d skill points. You have %d to spend in Skills." \
		% [tuning.sp_offseason, data.skill_points]
	data.season += 1
	if data.age + 1 == tuning.aging_start_age:
		data.notice += " Turning %d: from now on your attributes decline a little every season. " \
			% tuning.aging_start_age + "Preserve them in Skills (Maintenance) before the season ends."
	data.season_in_stage += 1
	data.age += 1
	_start_season(true)


## A new stage starts with its offseason (that stage's offseason scenarios),
## then season 1.
func _enter_stage(stage: String, team: Dictionary, route_text: String) -> void:
	if stage == CareerData.STAGE_PRO:
		var clubs := data.pro_clubs() if data.stage == CareerData.STAGE_PRO or data.flags.get("pro_clubs") is Array \
			else data.history.filter(func(h: Dictionary) -> bool: return h.get("stage", "") == CareerData.STAGE_PRO) \
				.map(func(h: Dictionary) -> String: return str(h.get("team", "")))
		var name := str(team.get("name", ""))
		var had := clubs.filter(func(x: Variant) -> bool: return str(x) != "").size() > 0
		if not (name in clubs):
			clubs.append(name)
		data.flags["pro_clubs"] = clubs.filter(func(x: Variant) -> bool: return str(x) != "")
		if had:
			data.flags["signed_new_club"] = true
			data.flags["signed_new_club_season"] = data.season + 1
	data.stage = stage
	data.team = team
	data.season_in_stage = 0
	Relationships.enter_stage(data, tuning)
	Followers.end_deals(data)  # brand deals don't follow you to a new stage
	data.suspension = {}  # a new stage starts clean
	data.offers.clear()
	data.tryout = {}
	data.add_route(route_text)
	if stage == CareerData.STAGE_PRO:
		var comeback := bool(data.flags.get("walk_on", false)) or bool(data.flags.get("juco", false))
		_event({"event": "pro_reached", "comeback": comeback})
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
			var s := TeamDatabase.team(str(off["school"]))
			var team := Progression.team_from(s, CareerData.STAGE_COLLEGE)
			team["offer_type"] = off["type"]
			var start: Dictionary = Progression.tier(str(off["tier"])).get("start_draft", {})
			data.draft_score = float(start.get(str(off["type"]), 0.0))
			data.flags["walk_on"] = off["type"] == Progression.OFFER_WALK_ON
			data.poor_streak = 0
			_event({"event": "signed", "tier": str(off["tier"]), "type": str(off["type"])})
			_enter_stage(CareerData.STAGE_COLLEGE, team, "Signed with %s (%s, %s)" % [s.get("name", ""),
				Progression.OFFER_NAMES.get(off["type"], ""), Progression.tier(str(off["tier"])).get("name", "")])
		"walk_on_tryout":
			start_tryout("walk_on", str(option["school"]))
		"juco":
			var jucos := TeamDatabase.jucos()
			var s: Dictionary = jucos[rng.randi_range(0, jucos.size() - 1)]
			data.flags["juco"] = true
			_enter_stage(CareerData.STAGE_JUCO, Progression.team_from(s, CareerData.STAGE_JUCO),
				"Went the junior college route at %s" % s.get("name", ""))
	save()


# --- tryouts ------------------------------------------------------------------------

## purpose: walk_on / camp / free_agent (progression.json "tryouts").
func start_tryout(purpose: String, team_id: String) -> void:
	var def: Dictionary = Progression.rules().get("tryouts", {}).get(purpose, {})
	var team := TeamDatabase.team(team_id)
	data.tryout = def.duplicate(true)
	data.tryout.merge({"purpose": purpose, "team": team_id, "team_name": str(team.get("name", "")), "results": [],
		"made": 0, "taken": 0, "seed": rng.randi()}, true)
	data.phase = PHASE_TRYOUT
	save()


## Benched long enough: the audition to win the job back (a tryout in the
## kick scene; Bench.audition sets the kicks).
func start_audition() -> void:
	data.tryout = Bench.audition(data, tuning, profile().fg_range)
	data.tryout.merge({"made": 0, "taken": 0, "results": [], "seed": rng.randi()}, true)
	data.phase = PHASE_TRYOUT
	save()


## A scenario choice's kick challenge (KickChallenge): the kicks happen in the
## tryout screen, then the week (or offseason) carries on where it was.
func start_challenge(scenario_id: String, index: int) -> void:
	var ch: Dictionary = (CareerContent.scenario(scenario_id).get("choices", []) as Array)[index]
	data.tryout = KickChallenge.tryout(data, KickChallenge.of(ch), scenario_id, index, profile().fg_range,
		data.phase, rng.randi(), tuning)
	data.phase = PHASE_TRYOUT
	save()


## The ball has been kicked: saved, so quitting before the result is a miss.
func tryout_struck() -> void:
	if data.phase != PHASE_TRYOUT:
		return
	data.tryout["struck"] = true
	save()


## One tryout kick's result (saved, so a reload continues at the next kick).
func tryout_kick(made: bool) -> void:
	if data.phase != PHASE_TRYOUT:
		return
	var results: Array = data.tryout.get("results", [])
	if results.size() >= TryoutMode.total_kicks(data.tryout):
		return
	results.append(made)
	data.tryout["results"] = results
	data.tryout["struck"] = false
	data.tryout["taken"] = results.size()
	data.tryout["made"] = results.count(true)
	save()


## Opening the tryout screen: a kick that was struck but never resolved (the
## game quit mid-flight) counts as a miss.
func tryout_resume() -> void:
	if data.phase == PHASE_TRYOUT and bool(data.tryout.get("struck", false)):
		tryout_kick(false)


## All kicks taken?
func tryout_done() -> bool:
	return (data.tryout.get("results", []) as Array).size() >= TryoutMode.total_kicks(data.tryout)


func tryout_passed() -> bool:
	return int(data.tryout.get("made", 0)) >= int(data.tryout.get("need", 99))


## The tryout's kicks are done: join the team, or fall back.
## made: from the screen; the saved per-kick results win when there are any.
func finish_tryout(made: int) -> void:
	if data.phase != PHASE_TRYOUT:
		return
	if data.tryout.has("results") and not (data.tryout["results"] as Array).is_empty():
		made = (data.tryout["results"] as Array).count(true)
	data.tryout["made"] = made
	var purpose := str(data.tryout.get("purpose", ""))
	if purpose == "challenge":
		var res := KickChallenge.finish(data, data.tryout, tuning)
		data.last_challenge = res.duplicate(true)
		data.last_challenge["title"] = str(data.tryout.get("title", ""))
		data.last_challenge["scenario"] = str(data.tryout.get("scenario", ""))
		data.phase = str(data.tryout.get("return_phase", PHASE_SCENARIO))
		data.tryout = {}
		if data.pending_scenarios.is_empty():
			_after_scenarios()
		save()
		return
	if purpose == "job":  # the bench audition: back to the week either way
		data.tryout["result"] = Bench.finish_audition(data, tuning, made)
		if str(data.tryout["result"]) == "passed":
			Followers.gain(data, tuning.buzz_audition_won, "Won the job back", tuning)
		data.bench["last_audition"] = {"made": made, "need": int(data.tryout.get("need", 3)),
			"kicks": (data.tryout.get("distances", []) as Array).size(), "result": data.tryout["result"],
			"week_index": data.week_index}
		data.tryout = {}
		data.phase = PHASE_WEEK_START
		save()
		return
	var team_id := str(data.tryout.get("team", ""))
	var team := TeamDatabase.team(team_id)
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
				data.flags["last_exit"] = ""
				data.contract["salary"] = Followers.salary(data, int(data.contract["salary"]), tuning)
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
	data.contract["salary"] = Followers.salary(data, int(data.contract["salary"]), tuning)
	_event({"event": "drafted", "round": int(d["round"])})
	var team := TeamDatabase.team(str(d["team"]))
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
	if data.poor_streak >= tuning.career_end_poor_streak:
		retire("out_of_football")
		return
	# Older free agents get fewer calls (no age cap: this is how it ends).
	if rng.randf() >= fa_call_chance():
		data.flags["fa_attempts"] = int(data.flags.get("fa_attempts", 0)) + 1
		if int(data.flags["fa_attempts"]) >= tuning.free_agent_attempts:
			retire("out_of_football")
			return
		data.age += 1
		data.season += 1
		data.notice = "No team called this year: clubs look hard at a %d-year-old kicker." % (data.age - 1)
		_free_agency(why)
		return
	var clubs := TeamDatabase.pro_teams().filter(func(s: Dictionary) -> bool:
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
	var pro_seasons := data.history.filter(func(h: Dictionary) -> bool:
		return h.get("stage", "") == CareerData.STAGE_PRO).size()
	_event({"event": "pro_season", "pro_seasons": pro_seasons})
	var status := "continue"
	if bool(data.flags.get("dismissed", false)):
		# Dismissed (story flag): released at season end, whatever the standing.
		status = "released"
		data.contract["dismissed"] = true
		_dismissal_done()
	elif data.retention_score < tuning.release_below:
		status = "released"
	elif int(data.contract["years_left"]) <= 0:
		if data.retention_score >= tuning.resign_min:
			status = "resign"
			data.contract["offer"] = Progression.resign_offer(data.retention_score, rng)
			data.contract["offer"]["salary"] = Followers.salary(data, int(data.contract["offer"]["salary"]), tuning)
		else:
			status = "not_resigned"
	data.contract["status"] = status
	data.phase = PHASE_CONTRACT


## The story's "dismissed" flag has been carried out: cleared (so it can't fire
## twice), with was_dismissed left for scenario writers.
func _dismissal_done() -> void:
	data.flags["dismissed"] = false
	data.flags["was_dismissed"] = true


## Retirement-reason flags for the closing scenes: retired_by_choice,
## retired_out_of_football (no team or roster spot), and for a pro who was let
## go first, retired_released or retired_unsigned (the last club's exit).
func _retirement_flags(reason: String) -> void:
	var chose := reason in ["chose", "age_cap"]
	data.flags["retired_by_choice"] = chose
	data.flags["retired_out_of_football"] = not chose
	var exit := str(data.flags.get("last_exit", ""))
	data.flags["retired_released"] = not chose and exit == "released"
	data.flags["retired_unsigned"] = not chose and exit == "not_resigned"


## The next closing scene (in id order, or "order"), each once, re-checked
## after every choice so earlier choices can open later scenes. None left: the
## Hall of Fame vote (pro careers) or the career summary.
func _next_epilogue() -> void:
	var left := CareerContent.scenarios().filter(func(s: Dictionary) -> bool:
		return "epilogue" in s.get("when", []) and not data.scenario_log.has(str(s.get("id", ""))) \
			and ScenarioEngine.is_eligible(data, s, "epilogue", tuning, true))
	if not left.is_empty():
		left.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			var ka := [int(a.get("order", 0)), str(a.get("id", ""))]
			var kb := [int(b.get("order", 0)), str(b.get("id", ""))]
			return ka[0] < kb[0] or (ka[0] == kb[0] and ka[1] < kb[1]))
		data.pending_scenarios = [str(left[0]["id"])]
		data.phase = PHASE_EPILOGUE
		return
	var hof: Dictionary = data.retirement.get("hof", {})
	data.phase = PHASE_HALL if bool(hof.get("eligible", false)) else PHASE_RETIRED


## The Hall of Fame screen's Continue: on to the career summary.
func finish_hall_of_fame() -> void:
	if data.phase != PHASE_HALL:
		return
	data.phase = PHASE_RETIRED
	save()


## Contract screen buttons.
func contract_continue() -> void:
	if data.phase != PHASE_CONTRACT:
		return
	match str(data.contract.get("status", "")):
		"continue":
			_begin_offseason()
		"resign":
			data.flags["re_signed"] = true
			data.flags["re_signed_season"] = data.season + 1
			var off: Dictionary = data.contract.get("offer", {})
			data.contract["years_left"] = int(off.get("years", 1))
			data.contract["salary"] = int(off.get("salary", 0))
			data.contract.erase("offer")
			data.add_route("Re-signed with the %s (%d years, %s)" % [data.contract.get("team_name", ""),
				int(off.get("years", 1)), Progression.money(int(off.get("salary", 0)))])
			_begin_offseason()
		"released", "not_resigned":
			data.flags["released"] = true
			data.flags["last_exit"] = str(data.contract["status"])  # retirement-reason flags
			data.poor_streak += 1
			data.add_route("%s by the %s" % ["Released" if data.contract["status"] == "released" else "Not re-signed",
				data.contract.get("team_name", "")])
			data.flags["failed_tryouts"] = [str(data.contract.get("team", ""))]
			data.contract = {}
			_free_agency("Looking for a new team.")
	save()


## The chance a club gives this free agent a tryout this year (1 until
## fa_age_from, then fa_age_drop less a year; never below fa_elite_floor after
## an elite season, at any age).
func fa_call_chance() -> float:
	var chance := clampf(1.0 - tuning.fa_age_drop * maxf(float(data.age - tuning.fa_age_from), 0.0), 0.0, 1.0)
	if elite_last_season():
		chance = maxf(chance, tuning.fa_elite_floor)
	return chance


## The last season played was elite (fa_elite_fg or better on at least
## fa_elite_min_attempts field goals): clubs still call, whatever the age.
func elite_last_season() -> bool:
	for i in range(data.history.size() - 1, -1, -1):
		var s: Dictionary = data.history[i].get("stats", {})
		var att := int(s.get("fg_att", 0))
		if att == 0:
			continue  # a season without kicks (free agency): look further back
		return att >= tuning.fa_elite_min_attempts and float(s.get("fg_made", 0)) / att >= tuning.fa_elite_fg
	return false


## Ends the career: reason chose / out_of_football / no_options (age_cap: old
## saves, from before there was no age cap).
func retire(reason: String) -> void:
	var text: String = {"age_cap": "Retired at %d, the end of the road." % data.age,
		"chose": "Retired on your own terms at %d." % data.age,
		"out_of_football": "No team called. Your playing days are over at %d." % data.age,
		"no_options": "No college roster spot. Your playing days end after high school."}.get(reason, "Retired.")
	data.retirement = {"reason": reason, "text": text, "age": data.age, "season": data.season,
		"stage": data.stage}
	data.add_route(text)
	_retirement_flags(reason)
	var hof := HallOfFame.evaluate(data, tuning)
	data.retirement["hof"] = hof
	HallOfFame.set_flags(data, hof)
	data.stage = CareerData.STAGE_RETIRED
	data.queued_scenarios.clear()
	data.pending_scenarios.clear()
	data.phase = PHASE_EPILOGUE
	_next_epilogue()
	var res := career_result()
	_event({"event": "retired", "reason": reason, "age": data.age, "seasons": res["seasons"],
		"pro_seasons": data.history.filter(func(h: Dictionary) -> bool:
			return h.get("stage", "") == CareerData.STAGE_PRO).size(),
		"rank": res["rank"], "result_text": res["text"]})
	save()
