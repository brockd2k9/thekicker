extends Node
## Career balance simulator (not part of the game). Plays many careers with
## different choice strategies through the real CareerManager / ScenarioEngine
## / Progression / GameSim / stat rules, and writes a Markdown report.
##
## Run (from the project folder):
##   godot --headless res://tools/career_sim.tscn -- careers=40 seed=1
## Options: spend_careers=N (spending-strategy runs, default 2x careers),
## main=0 (skip the choice-strategy runs), runs=balanced,dedicated (pick runs).
## Report: printed, and saved to user://career_sim_report.md
##
## Careers run from freshman year to retirement through the real progression
## (offers, college choice, tryouts, draft, contracts, release, age cap).
## Sim player policy: take the best offer (no offers: walk-on tryout or junior
## college, 50/50), sign when drafted, take every tryout, re-sign when offered, never
## retire voluntarily. Kicks use a simple make-chance model (stats, distance
## against the field goal range, pressure, narrower posts at higher stages)
## standing in for real swipes. Skill points are spent every week by a simple
## balanced policy (_spend: preserve attributes from age 30, then upgrade;
## Step 4 adds spending strategies and perks).

## Strategy -> how a choice is scored from its projected stat changes.
## Focused players always take the best-scoring choice; random/mixed don't.
const STRATEGIES := {
	"random": {},
	"mixed": {},
	"always-social": {"social": 1.0, "fun": 1.0, "charisma": 2.0},
	"always-train": {"power": 1.5, "accuracy": 1.5, "resilience": 1.5, "toughness": 1.5, "ambition": 1.0},
	"ambitious": {"ambition": 2.0, "leadership": 1.0, "intelligence": 1.0},
	# A reasonable player leaning one way: strongly prefers one personality
	# stat, mildly likes any other personality gain.
	"lean-charisma": {"charisma": 3.0, "ambition": 0.5, "leadership": 0.5, "intelligence": 0.5},
	"lean-ambition": {"ambition": 3.0, "charisma": 0.5, "leadership": 0.5, "intelligence": 0.5},
	"lean-leadership": {"leadership": 3.0, "charisma": 0.5, "ambition": 0.5, "intelligence": 0.5},
	"lean-intelligence": {"intelligence": 3.0, "charisma": 0.5, "ambition": 0.5, "leadership": 0.5},
}
const FOCUSED := ["always-social", "always-train", "ambitious", "lean-charisma", "lean-ambition",
	"lean-leadership", "lean-intelligence"]
## Skill point spending (Step 4). weights: the next point goes to the lowest
## value / weight it can afford. maintain: preserve attributes from age 30
## (in weight order). perks: which perks it buys when affordable; save: wait
## for an available perk instead of buying points (perk-hunter).
const SPEND := {
	"balanced": {"weights": {"power": 1.5, "accuracy": 1.5, "resilience": 1.0, "toughness": 1.0},
		"maintain": true, "perks": "all", "save": false},
	"power-first": {"weights": {"power": 4.0, "accuracy": 1.5, "resilience": 1.0, "toughness": 1.0},
		"maintain": true, "perks": ["big_leg", "cannon", "hang_time"], "save": false},
	"accuracy-first": {"weights": {"power": 1.5, "accuracy": 4.0, "resilience": 1.0, "toughness": 1.0},
		"maintain": true, "perks": ["laser", "smooth_swing"], "save": false},
	"perk-hunter": {"weights": {"power": 1.5, "accuracy": 1.5, "resilience": 1.0, "toughness": 1.0},
		"maintain": true, "perks": "all", "save": true},
	"balanced-no-maint": {"weights": {"power": 1.5, "accuracy": 1.5, "resilience": 1.0, "toughness": 1.0},
		"maintain": false, "perks": "all", "save": false},
}
## Spending runs: [label, choice strategy, spending strategy]. "dedicated" is a
## well-managed career (always trains, Power first) for the range ceiling.
const SPEND_RUNS := [["balanced", "mixed", "balanced"], ["power-first", "mixed", "power-first"],
	["accuracy-first", "mixed", "accuracy-first"], ["perk-hunter", "mixed", "perk-hunter"],
	["balanced-no-maint", "mixed", "balanced-no-maint"], ["dedicated", "always-train", "power-first"]]

## Progression values scenario choices carry count a little for every strategy.
const PROGRESS_WEIGHT := {"recruiting": 0.3, "draft": 0.3, "retention": 0.3, "grades": 3.0}

var _kt: KickTuning
var _rng := RandomNumberGenerator.new()
var _scen_count := {}  # id -> appearances
var _scen_careers := {}  # id -> careers that saw it
## The career being played: spending strategy and what it spent this season.
var _spend_strat := "balanced"
var _spent := {}
## This season's field goals: summed make chance and count (expected FG% =
## the kicker's true quality, for the slump table).
var _exp := [0.0, 0]


func _ready() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=")
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	var careers := int(args.get("careers", 40))
	_rng.seed = int(args.get("seed", 1))
	_kt = load("res://tuning/kick_tuning.tres")
	var problems := CareerContent.validate()
	var t0 := Time.get_ticks_msec()
	var results := {}
	# main=0 skips the choice-strategy runs; runs=balanced,dedicated picks
	# spending runs (both for quick tuning loops).
	for strat in (STRATEGIES if str(args.get("main", "1")) != "0" else {}):
		results[strat] = []
		for i in careers:
			results[strat].append(_play_career(strat, i))
	var spend_n := int(args.get("spend_careers", careers * 2))
	var spend_results := {}
	var only: Array = Array(str(args.get("runs", "")).split(",", false))
	for run in SPEND_RUNS:
		if not only.is_empty() and not (run[0] in only):
			spend_results[run[0]] = []
			continue
		spend_results[run[0]] = []
		for i in spend_n:
			spend_results[run[0]].append(_play_career(run[1], 1000 + i, run[2]))
	var report := _report(results, careers, problems, Time.get_ticks_msec() - t0) if not results.is_empty() \
		else "# Career balance report (spending runs only)\n"
	report += _step4_report(spend_results, spend_n, results)
	print(report)
	var f := FileAccess.open("user://career_sim_report.md", FileAccess.WRITE)
	if f:
		f.store_string(report)
		f.close()
		print("Saved: ", ProjectSettings.globalize_path("user://career_sim_report.md"))
	get_tree().quit()


# --- one career -----------------------------------------------------------------------

func _play_career(strat: String, n: int, spend := "balanced") -> Dictionary:
	_spend_strat = spend
	_spent = {"upgrades": 0, "maintain": 0, "perks": 0}
	SkillPoints.tally = {}
	var schools := CareerContent.high_schools()
	var c := CareerData.create("Sim %d" % n, CareerTuning.get_default())
	c.team = Progression.team_from(schools[_rng.randi_range(0, schools.size() - 1)], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c)
	m.rng.seed = _rng.randi()
	m._start_season(false)
	var out := {"hs_traits": [], "col_traits": [], "weeks": 0, "low_weeks": 0, "life_sum": {},
		"life_hist": {}, "seen": {}, "reached": {"high_school": true}, "events": [],
		"college_tier": "", "college_type": "", "draft": {}}
	var guard := 0
	while c.phase != CareerManager.PHASE_RETIRED and guard < 30000:
		guard += 1
		if c.stage == CareerData.STAGE_COLLEGE and out["college_tier"] == "":
			out["college_tier"] = str(c.team.get("tier", ""))
			out["college_type"] = str(c.team.get("offer_type", ""))
		if not (c.stage in out["reached"]):
			out["reached"][c.stage] = true
		match c.phase:
			CareerManager.PHASE_WEEK_START:
				m.begin_week()
				for id in c.pending_scenarios:
					_count_scen(id, out)
				_track_life(c, m.tuning, out)
			CareerManager.PHASE_SCENARIO, CareerManager.PHASE_OFFSEASON:
				var key := "%d_%s" % [c.season, c.stage]
				if c.phase == CareerManager.PHASE_OFFSEASON and out.get("_off", "") != key:
					out["_off"] = key
					for id in c.pending_scenarios:
						_count_scen(id, out)
				m.choose(_choose(c, m.current_scenario(), strat, m.tuning))
			CareerManager.PHASE_OUTLOOK:
				m.start_game()
			CareerManager.PHASE_GAME:
				m.finish_game(_play_game(m))
			CareerManager.PHASE_RESULTS:
				_spend(c, m.tuning)
				m.end_week()
			CareerManager.PHASE_SEASON_END:
				_snapshot(m, out)
				m.end_season()
				if c.phase == CareerManager.PHASE_RECRUITING and m._stage_done() \
						and c.stage == CareerData.STAGE_HIGH_SCHOOL:
					out["hs_recruiting"] = c.recruiting_score
					out["hs_gpa"] = c.gpa
					out["hs_offers"] = c.offers.duplicate(true)
				if c.phase == CareerManager.PHASE_DRAFT and c.stage == CareerData.STAGE_COLLEGE:
					out["draft_score"] = c.draft_score
					out["draft"] = c.draft_result.duplicate()
			CareerManager.PHASE_RECRUITING:
				m.continue_recruiting()
			CareerManager.PHASE_COLLEGE_CHOICE:
				var opts := m.college_options()
				if opts.is_empty():
					out["events"].append("no_options")
					m.retire("no_options")
				else:
					var o: Dictionary = opts[0]
					if o["kind"] != "offer":
						# No offers: half go the walk-on route, half junior college.
						var fall: Array = opts.filter(func(x): return x["kind"] == ("juco" if _rng.randf() < 0.5 else "walk_on_tryout"))
						if not fall.is_empty():
							o = fall[0]
					out["events"].append(("offer_" + str(o["offer"]["tier"])) if o["kind"] == "offer" else str(o["kind"]))
					m.choose_college(o)
			CareerManager.PHASE_TRYOUT:
				var made := _tryout(c)
				var ok := made >= int(c.tryout.get("need", 3))
				out["events"].append("tryout_%s_%s" % [c.tryout.get("purpose", ""), "pass" if ok else "fail"])
				m.finish_tryout(made)
			CareerManager.PHASE_DRAFT:
				if str(c.draft_result.get("kind", "")) == "drafted":
					m.sign_drafted()
				else:
					m.take_tryout()
			CareerManager.PHASE_CONTRACT:
				var st := str(c.contract.get("status", ""))
				if st in ["released", "not_resigned"]:
					out["events"].append(st)
				m.contract_continue()
	out["end_traits"] = c.traits.duplicate()
	out["perks"] = c.perks.duplicate()
	out["sp_src"] = SkillPoints.tally
	out["sp_unspent"] = c.skill_points
	SkillPoints.tally = null
	out["retire_reason"] = str(c.retirement.get("reason", "unfinished"))
	out["retire_age"] = c.age
	out["pro_seasons"] = c.history.filter(func(h: Dictionary) -> bool:
		return h.get("stage", "") == CareerData.STAGE_PRO).size()
	for id in out["seen"]:
		_scen_careers[id] = int(_scen_careers.get(id, 0)) + 1
	return out


## Stats at the end of high school and of college.
func _snapshot(m: CareerManager, out: Dictionary) -> void:
	var c := m.data
	# Skill points earned this season (before the season bonus), by stage.
	var sps: Dictionary = out.get("sp_seasons", {})
	var st := "college" if c.stage == CareerData.STAGE_JUCO else c.stage
	(sps.get_or_add(st, []) as Array).append(c.sp_season + SkillPoints.season_bonus(c, m.tuning))
	out["sp_seasons"] = sps
	# Per season: range at this age, slumps by kicker quality, what was spent.
	(out.get_or_add("range_by_age", {}) as Dictionary)[c.age] = KickRange.fg_range(c, m.tuning)
	out["max_range"] = maxf(float(out.get("max_range", 0.0)), KickRange.fg_range(c, m.tuning))
	(out.get_or_add("power_by_age", {}) as Dictionary)[c.age] = c.stat("power")
	var slumps := int(c.flags.get("kick_slumps", 0))
	var ss := c.season_stats
	if int(ss.get("fg_att", 0)) >= 8:
		(out.get_or_add("slump_seasons", []) as Array).append([Progression.fg_pct(ss),
			slumps > int(out.get("_slumps", 0)), float(_exp[0]) / maxi(int(_exp[1]), 1), int(ss.get("fg_att", 0))])
	_exp = [0.0, 0]
	out["_slumps"] = slumps
	(out.get_or_add("spent_seasons", []) as Array).append([st, _spent.duplicate()])
	_spent = {"upgrades": 0, "maintain": 0, "perks": 0}
	var tag := ""
	if c.stage == CareerData.STAGE_HIGH_SCHOOL and c.season_in_stage >= m.tuning.high_school_seasons:
		tag = "hs"
	elif c.stage == CareerData.STAGE_COLLEGE and c.season_in_stage >= m.tuning.college_seasons:
		tag = "col"
	if tag == "":
		return
	out[tag + "_traits"] = c.traits.duplicate()
	out[tag + "_personality"] = c.personality.duplicate()
	out[tag + "_football"] = c.football.duplicate()
	# Attribute points bought with skill points vs everything else (scenario
	# choices' direct football changes), since the start.
	var bought := 0.0
	var total := 0.0
	for k in CareerData.GROUP_KEYS[CareerData.FOOTBALL]:
		bought += float(c.sp_upgrades.get(k, 0.0))
		total += c.stat(k) - m.tuning.start_football
	out[tag + "_bought"] = bought
	out[tag + "_direct"] = total - bought
	out[tag + "_range"] = KickRange.fg_range(c, m.tuning)


func _count_scen(id: String, out: Dictionary) -> void:
	_scen_count[id] = int(_scen_count.get(id, 0)) + 1
	out["seen"][id] = true


func _track_life(c: CareerData, t: CareerTuning, out: Dictionary) -> void:
	out["weeks"] += 1
	var low := c.stat("energy") < t.low_energy_threshold or c.stat("health") < t.low_health_threshold \
		or c.stat("fun") < t.low_fun_threshold or c.stat("social") < t.low_social_threshold
	if low:
		out["low_weeks"] += 1
	for k in CareerData.GROUP_KEYS[CareerData.LIFE]:
		out["life_sum"][k] = float(out["life_sum"].get(k, 0.0)) + c.stat(k)
		var hist: Dictionary = out["life_hist"].get(k, {})
		var b := clampi(int(c.stat(k) / 20.0), 0, 4)
		hist[b] = int(hist.get(b, 0)) + 1
		out["life_hist"][k] = hist


func _choose(c: CareerData, s: Dictionary, strat: String, t: CareerTuning) -> int:
	var choices: Array = s.get("choices", [])
	var open: Array = []
	for i in choices.size():
		if ScenarioEngine.choice_lock(c, choices[i]) == "":
			open.append(i)
	if open.is_empty():
		return 0
	var use := strat
	if strat == "mixed":
		use = FOCUSED[_rng.randi_range(0, FOCUSED.size() - 1)]
	if use == "random":
		return open[_rng.randi_range(0, open.size() - 1)]
	var weights: Dictionary = STRATEGIES[use]
	var best: int = open[0]
	var best_score := -INF
	for i in open:
		var p := CareerStats.preview(c, choices[i].get("stats", {}), t)
		var score := _rng.randf() * 0.01  # tie-break
		for g in p:
			for k in p[g]:
				score += float(p[g][k]) * float(weights.get(k, 0.0))
		var prog := ScenarioEngine.progress_changes(choices[i])
		for k in prog:
			score += float(prog[k]) * float(PROGRESS_WEIGHT.get(k, 0.0))
		if score > best_score:
			best_score = score
			best = i
	return best


## Make chance stand-in for a real kick: stats, distance (past your range),
## pressure, and narrower posts at higher stages.
## Balanced spending: Power and Accuracy count 1.5x, Resilience and Toughness
## 1x; the next point goes to the lowest weighted attribute it can afford.
func _spend(c: CareerData, t: CareerTuning) -> void:
	var cfg: Dictionary = SPEND[_spend_strat]
	var w: Dictionary = cfg["weights"]
	var order := (w.keys() as Array)
	order.sort_custom(func(a, b) -> bool: return float(w[a]) > float(w[b]))
	# 1. From age 30: preserve attributes (most-weighted first).
	if cfg["maintain"]:
		for st in order:
			var cost := Aging.maintain_cost(c, st, t)
			if Aging.maintain(c, st, t):
				_spent["maintain"] = int(_spent["maintain"]) + cost
	# 2. Perks this strategy wants (cheapest first).
	var wanted: Array = []
	for d in Perks.defs():
		var id := str(d["id"])
		if (cfg["perks"] is String or id in cfg["perks"]) and not Perks.owned(c, id) \
				and Perks.requirements_met(c, d):
			wanted.append(d)
	wanted.sort_custom(func(a, b) -> bool: return int(a["cost"]) < int(b["cost"]))
	for d in wanted:
		if Perks.buy(c, str(d["id"])):
			_spent["perks"] = int(_spent["perks"]) + int(d["cost"])
	if cfg["save"] and wanted.any(func(d) -> bool: return not Perks.owned(c, str(d["id"]))):
		return  # perk-hunter: saving up for an available perk
	# 3. Attribute points: the lowest value / weight it can afford.
	for guard in 300:
		var best := ""
		for st in w:
			if SkillPoints.affordable(c, st, t) and (best == "" or c.stat(st) / float(w[st]) < c.stat(best) / float(w[best])):
				best = st
		if best == "":
			return
		var cost := SkillPoints.cost(c, best, t)
		if not SkillPoints.upgrade(c, best, t):
			return
		_spent["upgrades"] = int(_spent["upgrades"]) + cost


## prof (a game's KickProfile): today's range, aim error and pressure
## sensitivity, so perks, rest, injuries and weather count. Without one the
## career's stats are used (tryouts).
func _make_chance(c: CareerData, yards: int, pressure: float, stage: String, prof: KickProfile = null) -> float:
	var t := CareerTuning.get_default()
	var acc := c.stat("accuracy") / 100.0
	var res := c.stat("resilience") / 100.0
	var range := KickRange.fg_range(c, t)
	if prof != null:
		acc = clampf((t.spread_at_0 - prof.accuracy_spread_deg) / maxf(t.spread_at_0 - t.spread_at_100, 0.01), 0.0, 1.2)
		res = clampf((t.pressure_sens_at_0 - prof.pressure_sensitivity) / maxf(t.pressure_sens_at_0 - t.pressure_sens_at_100, 0.01), 0.0, 1.2)
		range = prof.fg_range
	if yards > range:
		return 0.02  # past your range: a full flick falls short
	var narrow: float = {"college": 0.03, "juco": 0.03, "pro": 0.06, "free_agent": 0.06}.get(stage, 0.0)
	var long_pen := maxf(float(yards) - (range - 6.0), 0.0) * 0.03
	var p := 0.97 - (yards - 20) * 0.011 * (1.6 - acc) - pressure * 0.12 * (1.3 - res) - narrow - long_pen
	return clampf(p, 0.15, 0.98)


func _tryout(c: CareerData) -> int:
	var made := 0
	var i := 0
	for d in c.tryout.get("distances", []):
		var p := _make_chance(c, int(d), float(c.tryout.get("pressure", 0.3)) + 0.08 * i, str(c.tryout.get("stage", "pro")))
		if _rng.randf() < p:
			made += 1
		i += 1
	return made


## A whole game with the make-chance model.
func _play_game(m: CareerManager) -> Dictionary:
	var c := m.data
	var sim := m.new_game_sim(_kt)
	var prof := m.profile()
	var guard := 0
	while guard < 1000:
		guard += 1
		var e := sim.next()
		match str(e.get("type", "")):
			"end":
				break
			"warmup":
				var r := _rng.randf()
				sim.set_warmup("pure" if r < 0.5 else ("loose" if r < 0.8 else "skipped"))
			"call":
				match str(e["kind"]):
					"fg", "pat":
						var ce := CareerGameMode.adjust_call(e, prof)
						var pm := _make_chance(c, int(e["yards"]), float(ce.get("pressure", 0.0)), c.stage, prof)
						if str(e["kind"]) == "fg":
							_exp[0] += pm
							_exp[1] += 1
						sim.resolve_call({"made": _rng.randf() < pm})
					"kickoff":
						var q := clampf(_rng.randf() * 0.6 + c.stat("power") / 100.0 * 0.4, 0.0, 1.0)
						sim.resolve_call({"quality": q, "carry": 40.0 + q * 25.0, "text": "Kickoff."})
					"onside":
						sim.resolve_call({"recovered": _rng.randf() < 0.2, "text": "Onside."})
	return sim.summary()


# --- report ---------------------------------------------------------------------------

func _report(results: Dictionary, n: int, problems: PackedStringArray, ms: int) -> String:
	var t := CareerTuning.get_default()
	var all: Array = []
	for s in results:
		all.append_array(results[s])
	var L := PackedStringArray()
	L.append("# Career balance report")
	L.append("")
	L.append("%d careers per strategy (%d total), freshman year to retirement. %.1f s. Content problems: %d." % [
		n, all.size(), ms / 1000.0, problems.size()])
	L.append("Personality change scale %.2f. Trait thresholds: %s." % [t.personality_change_scale, _thresholds()])
	L.append("")
	# --- progression
	L.append("## How far careers get (share of careers)")
	L.append("")
	L.append("| Strategy | College | via JUCO | via walk-on | Pro | Drafted | Pro seasons (avg / max) | Retire age (avg) |")
	L.append("|---|---|---|---|---|---|---|---|")
	var rows := results.duplicate()
	rows["ALL"] = all
	for s in rows:
		var rs: Array = rows[s]
		var drafted := rs.filter(func(r): return str(r["draft"].get("kind", "")) == "drafted").size()
		var ps: Array = rs.map(func(r): return int(r["pro_seasons"]))
		L.append("| %s | %s | %s | %s | %s | %s | %.1f / %d | %.1f |" % [s,
			_pct(rs.filter(func(r): return r["reached"].has("college")).size(), rs.size()),
			_pct(rs.filter(func(r): return r["reached"].has("juco")).size(), rs.size()),
			_pct(rs.filter(func(r): return "tryout_walk_on_pass" in r["events"]).size(), rs.size()),
			_pct(rs.filter(func(r): return r["reached"].has("pro")).size(), rs.size()),
			_pct(drafted, rs.size()), _avgf(ps), ps.max() if not ps.is_empty() else 0,
			_avgf(rs.map(func(r): return int(r["retire_age"])))])
	L.append("")
	L.append("## Routes and fallbacks (all strategies)")
	L.append("")
	var ev := {}
	for r in all:
		var seen := {}
		for e in r["events"]:
			if not seen.has(e):
				ev[e] = int(ev.get(e, 0)) + 1
				seen[e] = true
	L.append("| Event (at least once in a career) | Careers |")
	L.append("|---|---|")
	var keys := ev.keys()
	keys.sort()
	for k in keys:
		L.append("| %s | %s |" % [k, _pct(ev[k], all.size())])
	L.append("")
	L.append("| College entered as | Top | Mid-major | Small |")
	L.append("|---|---|---|---|")
	for typ in ["full", "partial", "walk_on"]:
		var cells := PackedStringArray()
		for tier_id in ["top", "mid", "small"]:
			cells.append(_pct(all.filter(func(r): return r["college_tier"] == tier_id and r["college_type"] == typ).size(), all.size()))
		L.append("| %s | %s |" % [Progression.OFFER_NAMES.get(typ, typ), " | ".join(cells)])
	L.append("")
	L.append("| Draft result | Careers |")
	L.append("|---|---|")
	var dk := {}
	for r in all:
		var d: Dictionary = r["draft"]
		var key := "never reached the draft" if d.is_empty() else \
			("round %d" % int(d["round"]) if d.get("kind") == "drafted" else \
			("undrafted, camp invite" if d.get("kind") == "camp" else "undrafted, open tryout"))
		dk[key] = int(dk.get(key, 0)) + 1
	var dkeys := dk.keys()
	dkeys.sort()
	for k in dkeys:
		L.append("| %s | %s |" % [k, _pct(dk[k], all.size())])
	L.append("")
	L.append("| Retirement reason | Careers |")
	L.append("|---|---|")
	var rr := {}
	for r in all:
		rr[r["retire_reason"]] = int(rr.get(r["retire_reason"], 0)) + 1
	for k in rr:
		L.append("| %s | %s |" % [k, _pct(rr[k], all.size())])
	L.append("")
	L.append("## Recruiting and academics at the end of high school (mean, p10-p90)")
	L.append("")
	L.append("| Strategy | Recruiting score | GPA | Offers (avg) | Best offer: top / mid / small / none |")
	L.append("|---|---|---|---|---|")
	for s in results:
		var rs: Array = results[s]
		var best := {"top": 0, "mid": 0, "small": 0, "none": 0}
		for r in rs:
			var offs: Array = r.get("hs_offers", [])
			best[str(offs[0]["tier"]) if not offs.is_empty() else "none"] += 1
		L.append("| %s | %s | %s | %.1f | %s / %s / %s / %s |" % [s, _dist_key(rs, "hs_recruiting"),
			_dist_key(rs, "hs_gpa", true), _avgf(rs.map(func(r): return (r.get("hs_offers", []) as Array).size())),
			_pct(best["top"], rs.size()), _pct(best["mid"], rs.size()), _pct(best["small"], rs.size()), _pct(best["none"], rs.size())])
	L.append("")
	L.append("Draft score at the end of college (careers that got there): %s" % _dist_key(all.filter(func(r): return r.has("draft_score")), "draft_score"))
	L.append("")
	# --- traits
	L.append("## Traits unlocked")
	L.append("")
	L.append("| Strategy | End of HS: avg | 0 / 1-2 / 3+ | End of college: avg | 0 / 1-2 / 3-4 / 5+ | End of career: avg |")
	L.append("|---|---|---|---|---|---|")
	for s in results:
		var rc: Array = results[s].filter(func(r): return r.has("col_personality"))
		var hs := _counts(results[s], "hs_traits")
		var col := _counts(rc, "col_traits")
		L.append("| %s | %.1f | %s | %.1f | %s | %.1f |" % [s, _avg(hs), _bucket(hs, [[0, 0], [1, 2], [3, 99]]),
			_avg(col), _bucket(col, [[0, 0], [1, 2], [3, 4], [5, 99]]), _avg(_counts(results[s], "end_traits"))])
	L.append("")
	L.append("(End-of-college numbers only count careers that finished 4 college seasons.)")
	L.append("")
	L.append("## Personality, end of high school (mean, p10-p90)")
	L.append("")
	L.append("| Strategy | Charisma | Ambition | Leadership | Intelligence |")
	L.append("|---|---|---|---|---|")
	for s in results:
		var cells := PackedStringArray()
		for k in CareerData.GROUP_KEYS[CareerData.PERSONALITY]:
			cells.append(_dist(results[s], "hs_personality", k))
		L.append("| %s | %s |" % [s, " | ".join(cells)])
	L.append("")
	L.append("## Football stats, end of HS -> end of college (mean)")
	L.append("")
	L.append("| Strategy | Power | Accuracy | Resilience | Toughness |")
	L.append("|---|---|---|---|---|")
	for s in results:
		var rc: Array = results[s].filter(func(r): return r.has("col_football"))
		var cells := PackedStringArray()
		for k in CareerData.GROUP_KEYS[CareerData.FOOTBALL]:
			cells.append("%d -> %d" % [roundi(_mean(results[s], "hs_football", k)), roundi(_mean(rc, "col_football", k))])
		L.append("| %s | %s |" % [s, " | ".join(cells)])
	L.append("")
	L.append("## Skill points and range")
	L.append("")
	L.append("Skill points earned per season (mean, season bonus included), attribute points bought with")
	L.append("skill points vs gained directly from scenario choices (4 attributes, summed, since the")
	L.append("start), and field goal range, at the end of high school / college.")
	L.append("")
	L.append("| Strategy | SP / season HS | SP / season college | SP / season pro | Bought HS / col | Direct HS / col | FG range HS / col |")
	L.append("|---|---|---|---|---|---|---|")
	for s in results:
		var per := {}
		for st in ["high_school", "college", "pro"]:
			var xs: Array = []
			for r in results[s]:
				xs.append_array(r.get("sp_seasons", {}).get(st, []))
			per[st] = ("%.0f" % _avgf(xs)) if not xs.is_empty() else "-"
		var rc: Array = results[s].filter(func(r): return r.has("col_bought"))
		var rh: Array = results[s].filter(func(r): return r.has("hs_bought"))
		var f := func(rs: Array, key: String) -> String:
			return ("%.0f" % _avgf(rs.map(func(r): return float(r[key])))) if not rs.is_empty() else "-"
		L.append("| %s | %s | %s | %s | %s / %s | %s / %s | %s / %s |" % [s, per["high_school"], per["college"], per["pro"],
			f.call(rh, "hs_bought"), f.call(rc, "col_bought"), f.call(rh, "hs_direct"), f.call(rc, "col_direct"),
			f.call(rh, "hs_range"), f.call(rc, "col_range")])
	L.append("")
	# --- life
	L.append("## Life stats (average over every week played; share of weeks with any life stat low)")
	L.append("")
	L.append("| Strategy | Health | Energy | Fun | Social | Weeks with a low stat |")
	L.append("|---|---|---|---|---|---|")
	for s in results:
		var weeks := 0.0
		var low := 0.0
		var sums := {}
		for r in results[s]:
			weeks += r["weeks"]
			low += r["low_weeks"]
			for k in r["life_sum"]:
				sums[k] = float(sums.get(k, 0.0)) + r["life_sum"][k]
		var cells := PackedStringArray()
		for k in CareerData.GROUP_KEYS[CareerData.LIFE]:
			cells.append(str(roundi(float(sums.get(k, 0.0)) / maxf(weeks, 1.0))))
		L.append("| %s | %s | %s |" % [s, " | ".join(cells), _pct(roundi(low), roundi(weeks))])
	L.append("")
	L.append("Distribution of weekly values (all strategies):")
	L.append("")
	L.append("| Stat | 0-19 | 20-39 | 40-59 | 60-79 | 80-100 |")
	L.append("|---|---|---|---|---|---|")
	for k in CareerData.GROUP_KEYS[CareerData.LIFE]:
		var hist := [0, 0, 0, 0, 0]
		for r in all:
			var h: Dictionary = r["life_hist"].get(k, {})
			for b in h:
				hist[int(b)] += int(h[b])
		var tot: int = hist.reduce(func(a, x): return a + x, 0)
		L.append("| %s | %s |" % [CareerData.STAT_NAMES[k], " | ".join(PackedStringArray(hist.map(func(x): return _pct(x, tot))))])
	L.append("")
	# --- scenarios
	L.append("## Scenario appearances (all strategies; per career, and share of careers that saw it)")
	L.append("")
	L.append("| Scenario | Stage | Gate | Per career | Careers |")
	L.append("|---|---|---|---|---|")
	for sc in CareerContent.scenarios():
		if sc.get("draft", false):
			continue  # no content yet; never picked
		var id := str(sc["id"])
		var gate := ScenarioEngine.requirement_text(sc.get("requires", {}))
		if sc.has("beat"):
			gate = "story beat"
		elif sc.get("follow_up_only", false):
			gate = "follow-up"
		elif gate == "" and not (sc.get("requires", {}) as Dictionary).is_empty():
			gate = "stat/score requirement"
		L.append("| %s | %s | %s | %.2f | %s |" % [id, ", ".join(PackedStringArray(sc.get("stages", []))).replace("high_school", "HS"),
			gate, float(_scen_count.get(id, 0)) / all.size(), _pct(int(_scen_careers.get(id, 0)), all.size())])
	return "\n".join(L) + "\n"


func _thresholds() -> String:
	var parts := PackedStringArray()
	for tr in CareerContent.traits():
		parts.append("%s (%s)" % [tr["name"], CareerStats.trait_requirement_text(tr)])
	return ", ".join(parts)


static func _pct(k: int, total: int) -> String:
	return "%d%%" % roundi(100.0 * k / maxi(total, 1))


static func _counts(rs: Array, key: String) -> Array:
	return rs.map(func(r: Dictionary) -> int: return (r.get(key, []) as Array).size())


static func _avg(xs: Array) -> float:
	return float(xs.reduce(func(a: float, x: int) -> float: return a + x, 0.0)) / maxi(xs.size(), 1)


static func _avgf(xs: Array) -> float:
	var s := 0.0
	for x in xs:
		s += float(x)
	return s / maxi(xs.size(), 1)


static func _bucket(xs: Array, ranges: Array) -> String:
	var parts := PackedStringArray()
	for r in ranges:
		var k := xs.filter(func(x: int) -> bool: return x >= r[0] and x <= r[1]).size()
		parts.append(_pct(k, xs.size()))
	return " / ".join(parts)


static func _mean(rs: Array, key: String, stat: String) -> float:
	var s := 0.0
	var n := 0
	for r in rs:
		if r.has(key):
			s += float(r[key][stat])
			n += 1
	return s / maxi(n, 1)


static func _dist(rs: Array, key: String, stat: String) -> String:
	var v: Array = rs.filter(func(r): return r.has(key)).map(func(r: Dictionary) -> float: return float(r[key][stat]))
	return _fmt_dist(v, false)


static func _dist_key(rs: Array, key: String, decimals := false) -> String:
	var v: Array = rs.filter(func(r): return r.has(key)).map(func(r: Dictionary) -> float: return float(r[key]))
	return _fmt_dist(v, decimals)


static func _fmt_dist(v: Array, decimals: bool) -> String:
	if v.is_empty():
		return "-"
	v.sort()
	var mean := 0.0
	for x in v:
		mean += float(x)
	mean /= v.size()
	var p10: float = v[clampi(int(0.1 * (v.size() - 1)), 0, v.size() - 1)]
	var p90: float = v[clampi(int(0.9 * (v.size() - 1)), 0, v.size() - 1)]
	if decimals:
		return "%.2f (%.2f-%.2f)" % [mean, p10, p90]
	return "%d (%d-%d)" % [roundi(mean), roundi(p10), roundi(p90)]


# --- Step 4: spending, range, slumps, aging, perks ---------------------------------------

const AGES := [14, 15, 16, 17, 18, 19, 20, 21, 22, 24, 26, 28, 30, 32, 34, 36, 38]
const SOURCE_GROUPS := {"Practice (tired)": "Practice", "Field goals made": "Makes", "Long makes": "Long makes",
	"Clutch makes": "Clutch makes", "Game winner": "Game winners", "Perfect game": "Perfect games",
	"Sideline warmup": "Warmups", "Choices": "Choices", "Season bonus": "Season bonus",
	"Offseason training": "Offseason", "Practice": "Practice"}


func _step4_report(sr: Dictionary, n: int, main: Dictionary) -> String:
	var L := PackedStringArray()
	L.append("")
	L.append("## Spending strategies (%d careers each, choice strategy in brackets)" % n)
	L.append("")
	L.append("balanced: Power and Accuracy 1.5x, preserves from 30, buys any perk it can afford. power-first /")
	L.append("accuracy-first: that attribute 4x and only its perks. perk-hunter: saves for every available")
	L.append("perk. balanced-no-maint: never preserves. dedicated: always trains, power-first.")
	L.append("")
	L.append("| Run | Pro | Drafted | FG range end HS | end college | peak | reach 50 / 60 / 65 / 70 | perks | tryouts passed | draft score |")
	L.append("|---|---|---|---|---|---|---|---|---|---|")
	for run in SPEND_RUNS:
		var rs: Array = sr[run[0]]
		var hs := rs.filter(func(r): return r.has("hs_range"))
		var col := rs.filter(func(r): return r.has("col_range"))
		var reach := PackedStringArray()
		for yd in [50, 60, 65, 70]:
			reach.append(_pct(rs.filter(func(r): return float(r.get("max_range", 0.0)) >= yd - 0.001).size(), rs.size()))
		var tp := 0
		var tf := 0
		for r in rs:
			for ev in r["events"]:
				if str(ev).begins_with("tryout_"):
					if str(ev).ends_with("_pass"):
						tp += 1
					else:
						tf += 1
		L.append("| %s (%s) | %s | %s | %.1f | %.1f | %.1f | %s | %.1f | %s of %d | %.0f |" % [run[0], run[1],
			_pct(rs.filter(func(r): return r["reached"].has("pro")).size(), rs.size()),
			_pct(rs.filter(func(r): return str(r["draft"].get("kind", "")) == "drafted").size(), rs.size()),
			_avgf(hs.map(func(r): return r["hs_range"])), _avgf(col.map(func(r): return r["col_range"])),
			_avgf(rs.map(func(r): return r.get("max_range", 0.0))), " / ".join(reach),
			_avgf(rs.map(func(r): return r["perks"].size())), _pct(tp, tp + tf), tp + tf,
			_avgf(rs.filter(func(r): return r.has("draft_score")).map(func(r): return r["draft_score"]))])
	L.append("")
	# --- range by age
	L.append("## Field goal range by age (mean at season end; careers still playing in brackets)")
	L.append("")
	var head := "| Age |"
	var sep := "|---|"
	for run in SPEND_RUNS:
		head += " %s |" % run[0]
		sep += "---|"
	L.append(head)
	L.append(sep)
	for age in AGES:
		var row := "| %d |" % age
		for run in SPEND_RUNS:
			var xs: Array = []
			for r in sr[run[0]]:
				var by: Dictionary = r.get("range_by_age", {})
				if by.has(age):
					xs.append(by[age])
			row += (" %.1f (%d) |" % [_avgf(xs), xs.size()]) if not xs.is_empty() else " - |"
		L.append(row)
	L.append("")
	# --- regression
	L.append("## Aging after 30: preserving vs not (mean Power and FG range at season end)")
	L.append("")
	L.append("| Age | balanced: Power / range | balanced-no-maint: Power / range | dedicated: Power / range |")
	L.append("|---|---|---|---|")
	for age in [29, 30, 31, 32, 33, 34, 35, 36, 37, 38]:
		var cells := PackedStringArray()
		for name in ["balanced", "balanced-no-maint", "dedicated"]:
			var pw: Array = []
			var rg: Array = []
			for r in sr[name]:
				if r.get("power_by_age", {}).has(age):
					pw.append(r["power_by_age"][age])
					rg.append(r["range_by_age"][age])
			cells.append(("%.0f / %.1f (%d)" % [_avgf(pw), _avgf(rg), pw.size()]) if not pw.is_empty() else "-")
		L.append("| %d | %s |" % [age, " | ".join(cells)])
	L.append("")
	# --- slumps
	L.append("## Coach doubt (slumps) by kicker quality")
	L.append("")
	L.append("Seasons with 8+ field goal attempts, grouped by the kicker's quality that season (expected FG%:")
	L.append("the kick model's average make chance; actual FG% in brackets); share of seasons in which a slump")
	L.append("started. Rule: %d of the last %d missed, or season FG%% under %d%% after %d attempts." % [
		CareerTuning.get_default().kick_window_misses, CareerTuning.get_default().kick_window,
		roundi(CareerTuning.get_default().kick_season_pct * 100.0), CareerTuning.get_default().kick_season_min_att])
	L.append("")
	L.append("| Expected FG% | Quality | Seasons (avg attempts) | Actual FG% | With a slump |")
	L.append("|---|---|---|---|---|")
	var pool: Array = []
	for d in [sr, main]:
		for k in d:
			for r in d[k]:
				pool.append_array(r.get("slump_seasons", []))
	for b in [[0.0, 0.6, "low"], [0.6, 0.7, "low"], [0.7, 0.75, "average"], [0.75, 0.8, "average"],
			[0.8, 0.9, "high"], [0.9, 1.01, "high"]]:
		var xs := pool.filter(func(x): return x.size() > 2 and float(x[2]) >= b[0] and float(x[2]) < b[1])
		L.append("| %d-%d%% | %s | %d (%.0f) | %.0f%% | %s |" % [roundi(b[0] * 100), mini(roundi(b[1] * 100), 100), b[2],
			xs.size(), _avgf(xs.map(func(x): return x[3])), 100.0 * _avgf(xs.map(func(x): return x[0])),
			_pct(xs.filter(func(x): return x[1]).size(), xs.size())])
	L.append("")
	# --- skill points
	L.append("## Skill points earned per season, by source (mean per season played)")
	L.append("")
	var groups := ["Makes", "Long makes", "Clutch makes", "Game winners", "Perfect games", "Warmups", "Practice",
		"Rival", "Choices", "Season bonus", "Offseason"]
	L.append("| Run | " + " | ".join(groups) + " | Total | Spent: points / preserve / perks | Unspent at end |")
	L.append("|---|" + "---|".repeat(groups.size()) + "---|---|---|")
	for run in SPEND_RUNS:
		var tot := {}
		var seasons := 0
		var spent := {"upgrades": 0, "maintain": 0, "perks": 0}
		for r in sr[run[0]]:
			seasons += (r.get("spent_seasons", []) as Array).size()
			for src in r.get("sp_src", {}):
				var g := str(SOURCE_GROUPS.get(src, "Rival"))
				tot[g] = int(tot.get(g, 0)) + int(r["sp_src"][src])
			for ps in r.get("spent_seasons", []):
				for k in spent:
					spent[k] = int(spent[k]) + int(ps[1].get(k, 0))
		var cells := PackedStringArray()
		var sum := 0.0
		for g in groups:
			var v := float(tot.get(g, 0)) / maxi(seasons, 1)
			sum += v
			cells.append("%.1f" % v)
		L.append("| %s | %s | %.1f | %.1f / %.1f / %.1f | %.0f |" % [run[0], " | ".join(cells), sum,
			float(spent["upgrades"]) / maxi(seasons, 1), float(spent["maintain"]) / maxi(seasons, 1),
			float(spent["perks"]) / maxi(seasons, 1), _avgf(sr[run[0]].map(func(r): return r["sp_unspent"]))])
	L.append("")
	L.append("Skill points earned per season by stage (mean):")
	L.append("")
	L.append("| Run | High school | College | Pro |")
	L.append("|---|---|---|---|")
	for run in SPEND_RUNS:
		var cells := PackedStringArray()
		for st in ["high_school", "college", "pro"]:
			var xs: Array = []
			for r in sr[run[0]]:
				xs.append_array(r.get("sp_seasons", {}).get(st, []))
			cells.append(("%.0f" % _avgf(xs)) if not xs.is_empty() else "-")
		L.append("| %s | %s |" % [run[0], " | ".join(cells)])
	L.append("")
	# --- perks
	L.append("## Perk usage (share of careers that bought it)")
	L.append("")
	L.append("| Perk | " + " | ".join(SPEND_RUNS.map(func(x): return x[0])) + " |")
	L.append("|---|" + "---|".repeat(SPEND_RUNS.size()))
	for d in Perks.defs():
		var cells := PackedStringArray()
		for run in SPEND_RUNS:
			var rs: Array = sr[run[0]]
			cells.append(_pct(rs.filter(func(r): return str(d["id"]) in r["perks"]).size(), rs.size()))
		L.append("| %s (%d) | %s |" % [d["name"], int(d["cost"]), " | ".join(cells)])
	L.append("")
	return "\n".join(L) + "\n"
