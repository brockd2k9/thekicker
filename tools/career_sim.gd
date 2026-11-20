extends Node
## Career balance simulator (not part of the game). Plays many careers with
## different choice strategies through the real CareerManager / ScenarioEngine
## / Progression / GameSim / stat rules, and writes a Markdown report.
##
## Run (from the project folder):
##   godot --headless res://tools/career_sim.tscn -- careers=40 seed=1
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
## Progression values scenario choices carry count a little for every strategy.
const PROGRESS_WEIGHT := {"recruiting": 0.3, "draft": 0.3, "retention": 0.3, "grades": 3.0}

var _kt: KickTuning
var _rng := RandomNumberGenerator.new()
var _scen_count := {}  # id -> appearances
var _scen_careers := {}  # id -> careers that saw it


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
	for strat in STRATEGIES:
		results[strat] = []
		for i in careers:
			results[strat].append(_play_career(strat, i))
	var report := _report(results, careers, problems, Time.get_ticks_msec() - t0)
	print(report)
	var f := FileAccess.open("user://career_sim_report.md", FileAccess.WRITE)
	if f:
		f.store_string(report)
		f.close()
		print("Saved: ", ProjectSettings.globalize_path("user://career_sim_report.md"))
	get_tree().quit()


# --- one career -----------------------------------------------------------------------

func _play_career(strat: String, n: int) -> Dictionary:
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
	# From age 30: preserve Power, then Accuracy, Toughness, Resilience first.
	for st in ["power", "accuracy", "toughness", "resilience"]:
		Aging.maintain(c, st, t)
	var w := {"power": 1.5, "accuracy": 1.5, "resilience": 1.0, "toughness": 1.0}
	for guard in 200:
		var best := ""
		for s in w:
			if SkillPoints.affordable(c, s, t) and (best == "" or c.stat(s) / w[s] < c.stat(best) / w[best]):
				best = s
		if best == "" or not SkillPoints.upgrade(c, best, t):
			return


func _make_chance(c: CareerData, yards: int, pressure: float, stage: String) -> float:
	var acc := c.stat("accuracy") / 100.0
	var res := c.stat("resilience") / 100.0
	var range := KickRange.fg_range(c, CareerTuning.get_default())
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
						sim.resolve_call({"made": _rng.randf() < _make_chance(c, int(e["yards"]),
							float(e.get("pressure", 0.0)), c.stage)})
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
