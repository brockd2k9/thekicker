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
## Skill point spending styles (each career gets one, in turn; maintenance
## from 30 is on for half of each style). w: attribute weights (buy the lowest
## level for its weight); perks: perks this style saves up for as soon as
## their requirements are met (any = every perk, cheapest first); spare:
## other perks are bought only with this many times their cost in hand.
const SPEND := {
	"balanced": {"w": {"power": 1.0, "accuracy": 1.0, "resilience": 1.0, "toughness": 1.0},
		"perks": [], "spare": 2.0},
	"power-first": {"w": {"power": 3.0, "accuracy": 1.2, "resilience": 0.8, "toughness": 0.8},
		"perks": ["big_leg", "cannon", "hang_time"], "spare": 3.0},
	"accuracy-first": {"w": {"power": 1.2, "accuracy": 3.0, "resilience": 1.0, "toughness": 0.8},
		"perks": ["laser", "smooth_swing", "ice_in_the_veins"], "spare": 3.0},
	"perk-hunter": {"w": {"power": 1.0, "accuracy": 1.0, "resilience": 1.0, "toughness": 1.0},
		"perks": ["any"], "spare": 1.0},
}
const PROGRESS_WEIGHT := {"recruiting": 0.3, "draft": 0.3, "retention": 0.3, "grades": 3.0}

var _kt: KickTuning
var _rng := RandomNumberGenerator.new()
## make=0.85: every field goal and tryout kick is made with this chance (to test
## systems by kicker quality, e.g. benching); 0 = the normal make-chance model.
## bench=0 turns benching off (before/after comparisons).
var _fixed_make := 0.0
## Kick challenges: proposed conversions (conv=path, default the test
## fixture) and their pass chances, summed per conversion / FG% bucket /
## fitness variant: {key: [sum of pass chance, count]}.
var _conv: Array = []
var _chal := {}
var _scen_count := {}  # id -> appearances
var _ret_by_scen := {}  # scenario id -> [standing applied by choices, times]
var _scen_careers := {}  # id -> careers that saw it


func _ready() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=")
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	var careers := int(args.get("careers", 40))
	_rng.seed = int(args.get("seed", 1))
	_fixed_make = float(args.get("make", 0.0))
	# bench=0: benching off (for before/after comparisons).
	if str(args.get("bench", "1")) == "0":
		CareerTuning.get_default().bench_max_per_season = 0
	# fans=0: followers give nothing (effects on vs off); tag=X: every choice
	# gets X followers buzz, an estimate of the story session's tags.
	# set=key:value,key:value overrides tuning values for this run (what-ifs).
	for kv in str(args.get("set", "")).split(",", false):
		var pair := kv.split(":")
		if pair.size() == 2:
			CareerTuning.get_default().set(pair[0], float(pair[1]))
	Followers.effects_off = str(args.get("fans", "1")) == "0"
	Followers.sim_choice_buzz = float(args.get("tag", 0.0))
	# rep=0: character reputation and suspensions have no effect.
	Reputation.off = str(args.get("rep", "1")) == "0"
	var conv_path := str(args.get("conv", "res://tests/fixtures/kick_challenge_conversions.json"))
	var cj: Variant = JSON.parse_string(FileAccess.get_file_as_string(conv_path))
	_conv = cj.get("conversions", []) if cj is Dictionary else []
	_kt = load("res://tuning/kick_tuning.tres")
	var problems := CareerContent.validate()
	var t0 := Time.get_ticks_msec()
	var results := {}
	# probe=1: only the aging probe (fast, for tuning Aging); income=N sets its
	# skill points per season (default: the run's measured pro average, or 50).
	if str(args.get("probe", "0")) == "1":
		print(_aging_probe(float(args.get("income", 50))))
		get_tree().quit()
		return
	for strat in STRATEGIES:
		results[strat] = []
		for i in careers:
			results[strat].append(_play_career(strat, i))
	var report := _report(results, careers, problems, Time.get_ticks_msec() - t0)
	var pro_sp: Array = []
	for st in results:
		for r in results[st]:
			pro_sp.append_array(r.get("sp_seasons", {}).get("pro", []))
	report += _aging_probe(_avgf(pro_sp) if not pro_sp.is_empty() else 50.0)
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
	ScenarioEngine.progress_tally = {}
	var out := {"hs_traits": [], "col_traits": [], "weeks": 0, "low_weeks": 0, "life_sum": {},
		"life_hist": {}, "seen": {}, "reached": {"high_school": true}, "events": [],
		"college_tier": "", "college_type": "", "draft": {},
		"spend": SPEND.keys()[n % SPEND.size()], "maint": (n / SPEND.size()) % 2 == 0,
		"spent": {"attributes": 0, "perks": 0, "maintenance": 0}, "max_range": 0.0}
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
				if c.week == 1:
					out["_chal_start"] = _challenge_probs(m)
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
				var sid := str(m.current_scenario().get("id", ""))
				var ret0 := c.retention_bonus
				m.choose(_choose(c, m.current_scenario(), strat, m.tuning))
				if c.retention_bonus != ret0:
					var a: Array = _ret_by_scen.get(sid, [0.0, 0])
					a[0] += c.retention_bonus - ret0
					a[1] += 1
					_ret_by_scen[sid] = a
			CareerManager.PHASE_OUTLOOK:
				m.start_game()
			CareerManager.PHASE_GAME:
				m.finish_game(_play_game(m))
			CareerManager.PHASE_RESULTS:
				_spend(c, m.tuning, out)
				m.end_week()
			CareerManager.PHASE_SEASON_END:
				_snapshot(m, out)
				_record_challenges(m, out)
				m.end_season()
				if c.phase == CareerManager.PHASE_RECRUITING and m._stage_done() \
						and c.stage == CareerData.STAGE_HIGH_SCHOOL:
					out["hs_recruiting"] = c.recruiting_score
					out["hs_gpa"] = c.gpa
					out["hs_offers"] = c.offers.duplicate(true)
				if c.phase == CareerManager.PHASE_DRAFT and c.stage == CareerData.STAGE_COLLEGE:
					out["rep_draft"] = Reputation.state(c)
					# The same kicker's draft day with each reputation (a counterfactual).
					var keep_flags := c.flags.duplicate()
					var cf := {}
					for st in ["", "concerns", "rebuilt"]:
						c.flags.erase(Reputation.CONCERNS)
						c.flags.erase(Reputation.REBUILT)
						if st == "concerns":
							c.flags[Reputation.CONCERNS] = true
						elif st == "rebuilt":
							c.flags[Reputation.CONCERNS] = true
							c.flags[Reputation.REBUILT] = true
						var rr := RandomNumberGenerator.new()
						cf[st] = str(Progression.draft(c, rr)["kind"])
					c.flags = keep_flags
					out["rep_cf"] = cf
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
	out["slumps"] = int(c.flags.get("kick_slumps", 0))
	# Benching: how often, how long, auditions, and whether the career ended soon after.
	out["benches"] = int(c.bench.get("benches", 0))
	out["bench_weeks"] = int(c.bench.get("weeks_total", 0))
	out["bench_last_season"] = int(c.bench.get("season", -1))
	out["end_season"] = c.season
	out["auditions_passed"] = (out["events"] as Array).count("tryout_job_pass")
	out["auditions_failed"] = (out["events"] as Array).count("tryout_job_fail")
	out["choice_progress"] = (ScenarioEngine.progress_tally as Dictionary).duplicate()
	var dg := 0.0
	var rg := 0.0
	for h in c.history:
		dg += float(h.get("draft_gain", 0.0))
		if str(h.get("stage", "")) == CareerData.STAGE_HIGH_SCHOOL:
			rg += float(h.get("recruiting", 0.0)) - rg if false else 0.0
	out["draft_season_gain"] = dg
	ScenarioEngine.progress_tally = null
	out["seasons"] = c.history.size()
	# Followers at the end of every season: [stage, season_in_stage, followers].
	out["fans"] = c.history.map(func(h: Dictionary) -> Array:
		return [str(h.get("stage", "")), int(h.get("season_in_stage", 1)), int(h.get("followers", 0))])
	out["fans_peak"] = maxi(int(c.social.get("peak", 0)), c.followers)
	out["virals"] = int(c.social.get("virals", 0))
	out["rep_end"] = Reputation.state(c)
	out["suspensions"] = c.suspensions_total
	out["fg_pct"] = float(c.career_totals.get("fg_made", 0)) / maxf(float(c.career_totals.get("fg_att", 0)), 1.0)
	var src := {}
	var aged := {}
	var aging_seasons := 0
	for h in c.history:
		for k in h.get("sp_sources", {}):
			src[k] = int(src.get(k, 0)) + int(h["sp_sources"][k])
		if int(h.get("age", 0)) >= m.tuning.aging_start_age:
			aging_seasons += 1
		for k in h.get("aged", {}):
			aged[k] = float(aged.get(k, 0.0)) + float(h["aged"][k])
	out["sp_src"] = src
	out["aged"] = aged
	out["aging_seasons"] = aging_seasons
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
func _spend(c: CareerData, t: CareerTuning, out: Dictionary) -> void:
	var style: Dictionary = SPEND[out["spend"]]
	# From age 30 (half the careers): preserve Power, Accuracy, Toughness, Resilience.
	if out["maint"]:
		for st in ["power", "accuracy", "toughness", "resilience"]:
			var before := c.skill_points
			if Aging.maintain(c, st, t):
				out["spent"]["maintenance"] += before - c.skill_points
	# Perks: the style's own (save up for them once their requirements are met),
	# then any other with `spare` x its cost in hand.
	var saving := false
	var wanted: Array = style["perks"]
	var ids: Array = Perks.defs().map(func(d: Dictionary) -> String: return str(d["id"]))
	ids.sort_custom(func(a: String, b: String) -> bool: return int(Perks.def(a).get("cost", 0)) < int(Perks.def(b).get("cost", 0)))
	for id in ids:
		var mine: bool = "any" in wanted or id in wanted
		var d := Perks.def(id)
		if Perks.owned(c, id) or not Perks.requirements_met(c, d):
			continue
		var cost := int(d.get("cost", 0))
		if mine or c.skill_points >= cost * float(style["spare"]):
			if Perks.buy(c, id):
				out["spent"]["perks"] += cost
			elif mine:
				saving = true
	if not saving:
		var w: Dictionary = style["w"]
		for guard in 200:
			var best := ""
			for s in w:
				if SkillPoints.affordable(c, s, t) and (best == "" or c.stat(s) / w[s] < c.stat(best) / w[best]):
					best = s
			if best == "":
				break
			var cost := SkillPoints.cost(c, best, t)
			if not SkillPoints.upgrade(c, best, t):
				break
			out["spent"]["attributes"] += cost
	out["max_range"] = maxf(float(out["max_range"]), KickRange.fg_range(c, t))


## Stand-in make chance. prof (optional): this game's KickProfile, so the
## game-day range (life stats, weather, perks) and the wind effect (Toughness,
## Wind Reader...) count; wind_mph: the kick's crosswind.
const WIND_MAKE_COST := 0.003  # make chance lost per mph of crosswind at wind_mult 1.0


func _make_chance(c: CareerData, yards: int, pressure: float, stage: String, prof: KickProfile = null,
		wind_mph := 0.0) -> float:
	if _fixed_make > 0.0:
		return _fixed_make
	var acc := c.stat("accuracy") / 100.0
	var res := c.stat("resilience") / 100.0
	var range := prof.fg_range if prof != null else KickRange.fg_range(c, CareerTuning.get_default())
	if yards > range:
		return 0.02  # past your range: a full flick falls short
	var narrow: float = {"college": 0.03, "juco": 0.03, "pro": 0.06, "free_agent": 0.06}.get(stage, 0.0)
	var long_pen := maxf(float(yards) - (range - 6.0), 0.0) * 0.03
	var wind := absf(wind_mph) * WIND_MAKE_COST * (prof.wind_mult if prof != null else 1.0)
	var p := 0.97 - (yards - 20) * 0.011 * (1.6 - acc) - pressure * 0.12 * (1.3 - res) - narrow - long_pen - wind
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
						sim.resolve_call({"made": _rng.randf() < _make_chance(c, int(e["yards"]),
							float(e.get("pressure", 0.0)), c.stage, prof, float(e.get("wind", 0.0)))})
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
	L.append_array(_skill_sections(all, t))
	L.append_array(_followers_sections(results, all, t))
	L.append_array(_challenge_sections())
	L.append_array(_reputation_section(all))
	L.append_array(_age_section(all))
	L.append_array(_retention_section(all))
	L.append_array(_progress_sources(all))
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


# --- followers -------------------------------------------------------------------------

const FAN_STAGES := [["high_school", 4, "End of high school"], ["college", 4, "End of college"],
	["pro", 1, "Pro season 1"], ["pro", 3, "Pro season 3"], ["pro", 6, "Pro season 6"], ["pro", 10, "Pro season 10"]]


static func _fans_at(r: Dictionary, stage: String, sis: int) -> int:
	for e in r.get("fans", []):
		if e[0] == stage and int(e[1]) == sis:
			return int(e[2])
	return -1


static func _fan_dist(v: Array) -> String:
	if v.is_empty():
		return "-"
	v.sort()
	var med: int = v[v.size() / 2]
	var p10: int = v[clampi(int(0.1 * (v.size() - 1)), 0, v.size() - 1)]
	var p90: int = v[clampi(int(0.9 * (v.size() - 1)), 0, v.size() - 1)]
	return "%s (%s-%s)" % [Followers.short(med), Followers.short(p10), Followers.short(p90)]


func _followers_sections(results: Dictionary, all: Array, t: CareerTuning) -> PackedStringArray:
	var L := PackedStringArray()
	L.append("## Followers (median, p10-p90)")
	L.append("")
	L.append("Extra choice tags: %s. Effects: %s." % ["none (kicks, seasons, viral moments, benching, the audition, "
		+ "and the followers / conduct tags already in the scenario data)"
		if Followers.sim_choice_buzz == 0.0 else "+%.1f buzz on every choice (an estimate of tags still to come)"
		% Followers.sim_choice_buzz,
		"off" if Followers.effects_off else "on"])
	L.append("")
	var head := "| Group | Careers |"
	var sep := "|---|---|"
	for fs in FAN_STAGES:
		head += " %s |" % fs[2]
		sep += "---|"
	L.append(head + " Peak | Viral moments / career |")
	L.append(sep + "---|---|")
	var groups := {"ALL": all}
	for st in SPEND:
		groups["spend: " + st] = all.filter(func(r): return r["spend"] == st)
	for q in [[0.0, 0.65, "FG% under 65"], [0.65, 0.75, "FG% 65-75"], [0.75, 0.85, "FG% 75-85"], [0.85, 1.01, "FG% 85+"]]:
		groups[q[2]] = all.filter(func(r): return float(r["fg_pct"]) >= q[0] and float(r["fg_pct"]) < q[1])
	for g in groups:
		var rs: Array = groups[g]
		var row := "| %s | %d |" % [g, rs.size()]
		for fs in FAN_STAGES:
			var v: Array = rs.map(func(r): return _fans_at(r, fs[0], fs[1])).filter(func(x): return x >= 0)
			row += " %s |" % _fan_dist(v)
		row += " %s | %.1f |" % [_fan_dist(rs.map(func(r): return int(r["fans_peak"]))),
			_avgf(rs.map(func(r): return int(r["virals"])))]
		L.append(row)
	L.append("")
	# Tiers: share of careers at each tier at the end of each season (by stage).
	L.append("## Follower tiers: share of careers at or above each tier at the end of a season")
	L.append("")
	L.append("(How often a scenario gated at that tier could appear that season. Careers still playing that season.)")
	L.append("")
	var thead := "| Season | Careers |"
	var tsep := "|---|---|"
	for i in range(1, Followers.TIER_NAMES.size()):
		thead += " %s |" % Followers.tier_label(i, t)
		tsep += "---|"
	L.append(thead)
	L.append(tsep)
	for st in [["high_school", 4, "HS"], ["college", 4, "College"], ["pro", 12, "Pro"]]:
		for sis in range(1, int(st[1]) + 1):
			var v: Array = all.map(func(r): return _fans_at(r, st[0], sis)).filter(func(x): return x >= 0)
			if v.is_empty():
				continue
			var row := "| %s %d | %d |" % [st[2], sis, v.size()]
			for i in range(1, Followers.TIER_NAMES.size()):
				row += " %s |" % _pct(v.filter(func(x): return x >= Followers.threshold(i, t)).size(), v.size())
			L.append(row)
	L.append("")
	return L


# --- kick challenges ----------------------------------------------------------------

## When each conversion can happen: stage, seasons in stage, and when in the
## season ("start": week 1, "end": the offseason after it, "mid": average).
const CHAL_WHEN := {
	"hs_showcase": ["high_school", 1, 3, "end"], "hs_scholarship_camp": ["high_school", 3, 3, "end"],
	"HS_040": ["high_school", 2, 2, "mid"], "HS_121": ["high_school", 3, 3, "end"],
	"HS_016": ["high_school", 1, 1, "mid"], "hs_kicker_battle": ["high_school", 1, 3, "mid"],
	"col_walkon_battle": ["college", 1, 1, "start"], "col_combine_invite": ["college", 4, 4, "end"],
}
const FITNESS := ["normal", "tired", "heavy_legs", "injured"]


const QUALITIES := [0.6, 0.7, 0.8, 0.9]
const FIT_WOBBLE := 0.15
const FIT_SPREAD := 0.04


## Pass chance of every conversion that can happen now, for copies of this
## kicker at each quality (expected game FG%, by setting Accuracy and
## Resilience; same age, Power and range) and fitness:
## {conv index: {quality: {fitness: chance}}}.
func _challenge_probs(m: CareerManager) -> Dictionary:
	var out := {}
	if _fixed_make > 0.0:
		return out
	var c := m.data
	var t := m.tuning
	var idx: Array = []
	for i in _conv.size():
		var w: Array = CHAL_WHEN.get(str(_conv[i]["scenario"]), [])
		var stage := "college" if c.stage == CareerData.STAGE_JUCO else c.stage
		if not w.is_empty() and w[0] == stage and c.season_in_stage >= int(w[1]) and c.season_in_stage <= int(w[2]):
			idx.append(i)
	if idx.is_empty():
		return out
	var copies := {}
	for q in QUALITIES:
		copies[q] = _quality_copy(c, t, q)
	for i in idx:
		var byq := {}
		for q in QUALITIES:
			if copies[q] == null:
				continue
			var res := {}
			for f in FITNESS:
				res[f] = _pass_chance(copies[q], t, _conv[i]["replace"]["kick_challenge"], f)
			byq[q] = res
		out[i] = byq
	return out


## A copy of the kicker at normal fitness (life stats at the start values, no
## modifiers or injury) whose expected FG% is about q; null if unreachable.
func _quality_copy(c: CareerData, t: CareerTuning, q: float) -> Variant:
	var k := CareerData.from_dict(c.to_dict())
	for s in CareerData.GROUP_KEYS[CareerData.LIFE]:
		k.set_stat(s, t.start_life)
	k.week_modifiers = []
	k.injury = {"weeks_left": 0, "severity": 0.0}
	var lo := 0.0
	var hi := 100.0
	for it in 14:
		var mid := (lo + hi) * 0.5
		k.set_stat("accuracy", mid)
		k.set_stat("resilience", mid)
		if _expected_fg(k, t) < q:
			lo = mid
		else:
			hi = mid
	k.set_stat("accuracy", hi)
	k.set_stat("resilience", hi)
	# Out of reach on Accuracy alone (a 90% freshman, a 60% senior): move
	# Power too (a strong kicker has range well past the distances).
	var fg := _expected_fg(k, t)
	if absf(fg - q) > 0.025:
		var up := fg < q
		lo = k.stat("power") if up else 0.0
		hi = 100.0 if up else k.stat("power")
		for it in 14:
			var mid := (lo + hi) * 0.5
			k.set_stat("power", mid)
			if _expected_fg(k, t) < q:
				lo = mid
			else:
				hi = mid
		k.set_stat("power", hi)
	if absf(_expected_fg(k, t) - q) > 0.025:
		return null
	return k


## A kicker's expected field goal % in games: the make model averaged over
## the stage's field goal distances (fg_min up to range - 1), pressure 0.4.
func _expected_fg(k: CareerData, t: CareerTuning) -> float:
	var prof := KickProfile.build(k, t)
	var gp := Progression.game_params(k, t)
	var hi := mini(int(gp["fg_max"]), floori(prof.fg_range) - 1)
	var stage := "college" if k.stage == CareerData.STAGE_JUCO else k.stage
	var s := 0.0
	var n := 0
	for d in range(int(gp["fg_min"]), hi + 1):
		s += _make_chance(k, d, 0.4, stage, prof)
		n += 1
	return s / maxi(n, 1)


## This kicker (already a quality copy) at a fitness: the chance to make
## `need` of the challenge's kicks.
func _pass_chance(base: CareerData, t: CareerTuning, kc: Dictionary, fitness: String) -> float:
	var k := base
	if fitness != "normal":
		k = CareerData.from_dict(base.to_dict())
	match fitness:
		"tired":
			k.set_stat("energy", 25.0)
		"heavy_legs":
			k.week_modifiers = ["heavy_legs"]
		"injured":
			k.injury = {"weeks_left": 2, "severity": 0.5}
	var prof := KickProfile.build(k, t)
	var stage := "pro" if k.stage in [CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT] else \
		("high_school" if k.stage == CareerData.STAGE_HIGH_SCHOOL else "college")
	# The make model only sees fitness through range; in the kick scene being
	# tired or hurt also adds aim wobble and spread (estimate: FIT_WOBBLE per
	# unit of wobble_mult, FIT_SPREAD per degree of spread, against normal).
	var fit_pen := 0.0
	if fitness != "normal":
		var base_prof := KickProfile.build(base, t)
		fit_pen = FIT_WOBBLE * maxf(prof.wobble_mult - base_prof.wobble_mult, 0.0) \
			+ FIT_SPREAD * maxf(prof.accuracy_spread_deg - base_prof.accuracy_spread_deg, 0.0)
	var ps: Array = []
	var dist := KickChallenge.distances(kc, prof.fg_range, t)
	var wind := KickChallenge.wind_max(kc, t) * 0.5
	for j in dist.size():
		var pr := KickChallenge.pressure(kc, t) + 0.08 * j + prof.pressure_add
		ps.append(clampf(_make_chance(k, int(dist[j]), pr, stage, prof, wind) - fit_pen, 0.02, 0.98))
	var ko := KickChallenge.kickoffs(kc)
	for j in int(ko.get("count", 0)):
		ps.append(_kickoff_chance(prof.kickoff_range, float(ko["min_yards"])))
	return _at_least(ps, KickChallenge.need(kc))


## Stand-in kickoff model: a kickoff carries 80-100% of the kickoff range.
static func _kickoff_chance(kick_range: float, min_yards: float) -> float:
	return clampf((kick_range - min_yards) / (kick_range * 0.2), 0.0, 1.0)


## Chance of at least `need` successes from independent chances ps.
static func _at_least(ps: Array, need: int) -> float:
	var dp := [1.0]
	for p in ps:
		var nx := []
		nx.resize(dp.size() + 1)
		nx.fill(0.0)
		for i in dp.size():
			nx[i] += float(dp[i]) * (1.0 - float(p))
			nx[i + 1] += float(dp[i]) * float(p)
		dp = nx
	var s := 0.0
	for i in range(need, dp.size()):
		s += float(dp[i])
	return s


## Season end: the chances for the challenges this season could hold (start,
## end, or their mean), by quality and fitness.
func _record_challenges(m: CareerManager, out: Dictionary) -> void:
	if _fixed_make > 0.0:
		return
	var end_p := _challenge_probs(m)
	var start_p: Dictionary = out.get("_chal_start", {})
	for i in end_p:
		var w: Array = CHAL_WHEN[str(_conv[i]["scenario"])]
		for q in end_p[i]:
			for f in FITNESS:
				var e := float(end_p[i][q][f])
				var sp: Dictionary = start_p.get(i, {})
				var st := float((sp.get(q, end_p[i][q]) as Dictionary)[f])
				var p := e if w[3] == "end" else (st if w[3] == "start" else (st + e) * 0.5)
				var key := "%d|%s|%s" % [i, q, f]
				var a: Array = _chal.get(key, [0.0, 0])
				a[0] += p
				a[1] += 1
				_chal[key] = a


func _challenge_sections() -> PackedStringArray:
	var L := PackedStringArray()
	if _chal.is_empty():
		return L
	L.append("## Kick challenges: pass chance by kicker quality")
	L.append("")
	L.append("Each kicker the simulator meets at that point in a career, copied at an expected game FG% of "
		+ "60/70/80/90 (Accuracy and Resilience set; same age, Power, range and stage), normal fitness (life "
		+ "stats at the start values). Wind: half the max. Kickoffs: a stand-in model (80-100% of the "
		+ "kickoff range). Last column: the 75% kicker (mean of 70% and 80%) at normal fitness / tired "
		+ "(Energy 25) / heavy legs / injured.")
	L.append("")
	L.append("| Challenge | 60% | 70% | 80% | 90% | 75%: normal / tired / heavy legs / injured |")
	L.append("|---|---|---|---|---|---|")
	for i in _conv.size():
		var kc: Dictionary = _conv[i]["replace"]["kick_challenge"]
		var row := "| %s (%s) |" % [_conv[i]["scenario"], kc.get("title", "")]
		for q in QUALITIES:
			row += " %s |" % _chal_cell(i, q, "normal")
		var fit := PackedStringArray()
		for f in FITNESS:
			fit.append(_chal_mid(i, f))
		row += " %s |" % " / ".join(fit)
		L.append(row)
	L.append("")
	return L


## The 75% kicker: the mean of the 70% and 80% copies.
func _chal_mid(i: int, f: String) -> String:
	var a: Array = _chal.get("%d|%s|%s" % [i, 0.7, f], [0.0, 0])
	var b: Array = _chal.get("%d|%s|%s" % [i, 0.8, f], [0.0, 0])
	if int(a[1]) == 0 or int(b[1]) == 0:
		return "-"
	return "%d%%" % roundi(50.0 * (float(a[0]) / int(a[1]) + float(b[0]) / int(b[1])))


func _chal_cell(i: int, q: float, f: String) -> String:
	var a: Array = _chal.get("%d|%s|%s" % [i, q, f], [0.0, 0])
	if int(a[1]) == 0:
		return "-"
	return "%d%% (n=%d)" % [roundi(100.0 * float(a[0]) / int(a[1])), int(a[1])]


## Where draft stock comes from (careers that reached draft day): the
## season-end formula vs scenario choices, and recruiting / grades from choices.
func _progress_sources(all: Array) -> PackedStringArray:
	var L := PackedStringArray()
	var rs := all.filter(func(r): return r.has("draft_score"))
	L.append("## Progress from scenario choices vs the season formula (per career)")
	L.append("")
	L.append("| | Careers | Draft stock at draft day | from season formula | from choices | Recruiting from choices | GPA from choices |")
	L.append("|---|---|---|---|---|---|---|")
	L.append("| Reached draft day | %d | %.1f | %.1f | %.1f | %.1f | %.2f |" % [rs.size(),
		_avgf(rs.map(func(r): return float(r["draft_score"]))),
		_avgf(rs.map(func(r): return float(r.get("draft_season_gain", 0.0)))),
		_avgf(rs.map(func(r): return float(r.get("choice_progress", {}).get("draft", 0.0)))),
		_avgf(all.map(func(r): return float(r.get("choice_progress", {}).get("recruiting", 0.0)))),
		_avgf(all.map(func(r): return float(r.get("choice_progress", {}).get("grades", 0.0))))])
	L.append("")
	return L


## Pro standing (retention) from scenario choices, by scene: the total over
## all careers, worst first (what shortens pro careers).
func _retention_section(all: Array) -> PackedStringArray:
	var L := PackedStringArray()
	var ids := _ret_by_scen.keys()
	ids.sort_custom(func(a, b) -> bool: return float(_ret_by_scen[a][0]) < float(_ret_by_scen[b][0]))
	var total := 0.0
	for id in ids:
		total += float(_ret_by_scen[id][0])
	var pros := all.filter(func(r): return r["reached"].has("pro")).size()
	L.append("## Pro standing from scenario choices (all careers; most negative first)")
	L.append("")
	L.append("Net standing from choices per pro career: %.1f (release below %d, re-sign from %d)." % [
		total / maxi(pros, 1), roundi(CareerTuning.get_default().release_below), roundi(CareerTuning.get_default().resign_min)])
	L.append("")
	L.append("| Scene | Title | Times a choice moved standing | Standing total | Per time |")
	L.append("|---|---|---|---|---|")
	for id in ids.slice(0, 40):
		var a: Array = _ret_by_scen[id]
		L.append("| %s | %s | %d | %.1f | %.1f |" % [id, str(CareerContent.scenario(id).get("title", "")),
			int(a[1]), float(a[0]), float(a[0]) / maxi(int(a[1]), 1)])
	L.append("")
	return L


## How old careers end (no age cap): share of all careers and of pro careers
## still playing at 38 / 40 / 42 / 45, and how they end.
func _age_section(all: Array) -> PackedStringArray:
	var L := PackedStringArray()
	var pros := all.filter(func(r): return r["reached"].has("pro"))
	L.append("## Career end age (no age cap)")
	L.append("")
	L.append("| Played to at least | 36 | 38 | 40 | 42 | 45 | Oldest | Pro seasons (avg) |")
	L.append("|---|---|---|---|---|---|---|---|")
	var careful := pros.filter(func(r): return r["maint"] and float(r["fg_pct"]) >= 0.75)
	for g in [["All careers", all], ["Pro careers", pros], ["Pro, preserving + 75%+ FG", careful],
			["Pro, preserving", pros.filter(func(r): return r["maint"])], ["Pro, not preserving", pros.filter(func(r): return not r["maint"])]]:
		var rs: Array = g[1]
		var row := "| %s (%d) |" % [g[0], rs.size()]
		for a in [36, 38, 40, 42, 45]:
			row += " %s |" % _pct(rs.filter(func(r): return int(r["retire_age"]) >= a).size(), rs.size())
		row += " %d | %.1f |" % [rs.map(func(r): return int(r["retire_age"])).max() if not rs.is_empty() else 0,
			_avgf(rs.map(func(r): return int(r["pro_seasons"])))]
		L.append(row)
	L.append("")
	var why := {}
	for r in pros.filter(func(r): return int(r["retire_age"]) >= 36):
		why[r["retire_reason"]] = int(why.get(r["retire_reason"], 0)) + 1
	L.append("Pro careers ending at 36+: %s." % ", ".join(PackedStringArray(why.keys().map(
		func(k): return "%s %d" % [k, why[k]]))))
	L.append("")
	return L


## Character reputation on draft day (Reputation): pro and draft rates for
## careers with and without the flags (compare a rep=0 run).
func _reputation_section(all: Array) -> PackedStringArray:
	var L := PackedStringArray()
	L.append("## Character reputation on draft day (reputation effects %s)" % ("off" if Reputation.off else "on"))
	L.append("")
	L.append("| On draft day | Careers | Drafted | Pro | Pro seasons (avg) |")
	L.append("|---|---|---|---|---|")
	var reached := all.filter(func(r): return r.has("rep_draft"))
	for st in [["", "Clean record"], ["concerns", "Character concerns"], ["rebuilt", "Rebuilt reputation"]]:
		var rs := reached.filter(func(r): return str(r["rep_draft"]) == st[0])
		L.append("| %s | %d | %s | %s | %.1f |" % [st[1], rs.size(),
			_pct(rs.filter(func(r): return str(r["draft"].get("kind", "")) == "drafted").size(), rs.size()),
			_pct(rs.filter(func(r): return r["reached"].has("pro")).size(), rs.size()),
			_avgf(rs.map(func(r): return int(r["pro_seasons"])))])
	L.append("")
	L.append("Same kickers on draft day, by reputation (every career that reached the draft, its draft stock "
		+ "unchanged): drafted with a clean record %s, with character concerns %s, with a rebuilt reputation %s." % [
		_pct(reached.filter(func(r): return str(r.get("rep_cf", {}).get("", "")) == "drafted").size(), reached.size()),
		_pct(reached.filter(func(r): return str(r.get("rep_cf", {}).get("concerns", "")) == "drafted").size(), reached.size()),
		_pct(reached.filter(func(r): return str(r.get("rep_cf", {}).get("rebuilt", "")) == "drafted").size(), reached.size())])
	L.append("")
	L.append("Suspensions per career: %.2f." % _avgf(all.map(func(r): return int(r.get("suspensions", 0)))))
	L.append("")
	return L


## Step 4 sections: spending styles, the 70-yard leg, slumps by kicker quality,
## the skill point economy, aging after 30 and perk usage.
func _skill_sections(all: Array, t: CareerTuning) -> PackedStringArray:
	var L := PackedStringArray()
	var by := {}
	for r in all:
		(by.get_or_add(str(r["spend"]), []) as Array).append(r)
	var reached70 := func(rs: Array) -> int:
		return rs.filter(func(r): return float(r["max_range"]) >= t.range_cap - 0.01).size()
	L.append("## Spending styles (each career spends its skill points one way)")
	L.append("")
	L.append("| Style | Careers | Pro | Drafted | FG range HS / col | Best range (mean) | Perks owned | Reached 70 yd |")
	L.append("|---|---|---|---|---|---|---|---|")
	var rows := by.duplicate()
	rows["ALL"] = all
	for s in rows:
		var rs: Array = rows[s]
		var rh := rs.filter(func(r): return r.has("hs_range"))
		var rc := rs.filter(func(r): return r.has("col_range"))
		L.append("| %s | %d | %s | %s | %.1f / %.1f | %.1f | %.1f | %s |" % [s, rs.size(),
			_pct(rs.filter(func(r): return r["reached"].has("pro")).size(), rs.size()),
			_pct(rs.filter(func(r): return str(r["draft"].get("kind", "")) == "drafted").size(), rs.size()),
			_avgf(rh.map(func(r): return r["hs_range"])), _avgf(rc.map(func(r): return r["col_range"])),
			_avgf(rs.map(func(r): return r["max_range"])), _avgf(rs.map(func(r): return (r["perks"] as Array).size())),
			"%.1f%%" % (100.0 * reached70.call(rs) / maxi(rs.size(), 1))])
	L.append("")
	L.append("Reaching %d yd needs Power 100 plus Big Leg and Cannon. Share of all careers: **%.1f%%** (target under ~2%%)." % [
		int(t.range_cap), 100.0 * reached70.call(all) / maxi(all.size(), 1)])
	L.append("")
	L.append("## Slumps by kicker quality (career FG%)")
	L.append("")
	L.append("| Career FG% | Careers | Slumps per 10 seasons | Careers with a slump |")
	L.append("|---|---|---|---|")
	for tier in [[0.0, 0.65, "under 65%"], [0.65, 0.7, "65-70%"], [0.7, 0.8, "70-80%"], [0.8, 0.85, "80-85%"],
			[0.85, 1.01, "85%+"]]:
		var rs := all.filter(func(r): return float(r["fg_pct"]) >= tier[0] and float(r["fg_pct"]) < tier[1])
		var seasons := 0.0
		var slumps := 0.0
		for r in rs:
			seasons += float(r["seasons"])
			slumps += float(r["slumps"])
		L.append("| %s | %d | %.1f | %s |" % [tier[2], rs.size(), 10.0 * slumps / maxf(seasons, 1.0),
			_pct(rs.filter(func(r): return int(r["slumps"]) > 0).size(), rs.size())])
	L.append("")
	L.append("## Benching by kicker quality (career FG%)")
	L.append("")
	L.append("Targets: 80%+ under 5% of careers benched at least once, 70-80% 15-35%, under 65% over 60%.")
	L.append("")
	L.append("| Career FG% | Careers | Benched at least once | Benches per 10 seasons | Bench weeks per bench | Career over within 1 season of a bench |")
	L.append("|---|---|---|---|---|---|")
	for tier in [[0.0, 0.65, "under 65%"], [0.65, 0.7, "65-70%"], [0.7, 0.8, "70-80%"], [0.8, 1.01, "80%+"]]:
		var rs := all.filter(func(r): return float(r["fg_pct"]) >= tier[0] and float(r["fg_pct"]) < tier[1])
		var seasons := 0.0
		var benches := 0.0
		var weeks := 0.0
		for r in rs:
			seasons += float(r["seasons"])
			benches += float(r["benches"])
			weeks += float(r["bench_weeks"])
		var benched := rs.filter(func(r): return int(r["benches"]) > 0)
		var soon := benched.filter(func(r): return _ended_soon(r))
		L.append("| %s | %d | %s | %.1f | %.1f | %s |" % [tier[2], rs.size(), _pct(benched.size(), rs.size()),
			10.0 * benches / maxf(seasons, 1.0), weeks / maxf(benches, 1.0), _pct(soon.size(), benched.size())])
	var ap := 0
	var af := 0
	for r in all:
		ap += int(r["auditions_passed"])
		af += int(r["auditions_failed"])
	L.append("")
	L.append("Auditions: %d passed, %d failed (%s passed)." % [ap, af, _pct(ap, ap + af)])
	L.append("")
	var seasons_all := 0.0
	var src := {}
	var spent := {"attributes": 0.0, "perks": 0.0, "maintenance": 0.0}
	for r in all:
		seasons_all += float(r["seasons"])
		for k in r["sp_src"]:
			src[k] = float(src.get(k, 0.0)) + float(r["sp_src"][k])
		for k in spent:
			spent[k] += float(r["spent"][k])
	var earned := 0.0
	for k in src:
		earned += float(src[k])
	L.append("## Skill point economy (all careers, per season played)")
	L.append("")
	L.append("| Earned from | SP / season | Share |")
	L.append("|---|---|---|")
	var keys := src.keys()
	keys.sort_custom(func(a, b) -> bool: return float(src[a]) > float(src[b]))
	for k in keys:
		L.append("| %s | %.1f | %s |" % [k, float(src[k]) / maxf(seasons_all, 1.0), _pct(roundi(float(src[k])), roundi(earned))])
	L.append("| **Total earned** | **%.1f** | |" % (earned / maxf(seasons_all, 1.0)))
	var spent_total := 0.0
	for k in spent:
		spent_total += spent[k]
	L.append("")
	L.append("| Spent on | SP / season | Share |")
	L.append("|---|---|---|")
	for k in spent:
		L.append("| %s | %.1f | %s |" % [k, spent[k] / maxf(seasons_all, 1.0), _pct(roundi(spent[k]), roundi(spent_total))])
	L.append("| **Total spent** | **%.1f** | |" % (spent_total / maxf(seasons_all, 1.0)))
	L.append("")
	L.append("## Aging after 30 (careers that played a season at 30+)")
	L.append("")
	L.append("| Maintenance | Careers | Seasons at 30+ | Points lost per season: Power / Accuracy / Resilience / Toughness | Maintenance SP per season |")
	L.append("|---|---|---|---|---|")
	for maint in [true, false]:
		var rs := all.filter(func(r): return r["maint"] == maint and int(r["aging_seasons"]) > 0)
		var ns := 0.0
		var lost := {}
		var msp := 0.0
		for r in rs:
			ns += float(r["aging_seasons"])
			msp += float(r["spent"]["maintenance"])
			for k in r["aged"]:
				lost[k] = float(lost.get(k, 0.0)) - float(r["aged"][k])
		var cells := PackedStringArray()
		for k in ["power", "accuracy", "resilience", "toughness"]:
			cells.append("%.1f" % (float(lost.get(k, 0.0)) / maxf(ns, 1.0)))
		L.append("| %s | %d | %.1f avg | %s | %.1f |" % ["yes" if maint else "no", rs.size(), ns / maxf(rs.size(), 1),
			" / ".join(cells), msp / maxf(ns, 1.0)])
	L.append("")
	L.append("## Perk usage (share of careers owning it at the end)")
	L.append("")
	var styles := by.keys()
	L.append("| Perk | Cost | All | %s |" % " | ".join(styles))
	L.append("|---|---|---|%s" % "---|".repeat(styles.size()))
	for d in Perks.defs():
		var id := str(d["id"])
		var cells := PackedStringArray()
		for s in styles:
			var rs: Array = by[s]
			cells.append(_pct(rs.filter(func(r): return id in r["perks"]).size(), rs.size()))
		L.append("| %s | %d | %s | %s |" % [str(d.get("name", id)), int(d.get("cost", 0)),
			_pct(all.filter(func(r): return id in r["perks"]).size(), all.size()), " | ".join(cells)])
	L.append("")
	return L


# --- aging probe ------------------------------------------------------------------------

## Two identical pros from age 30 to 37 on the same skill points per season:
## one preserves (Power, Accuracy, Toughness, Resilience, while it can afford
## it, then upgrades with the rest), one never preserves and spends everything
## on upgrades (buying lost points back). Real Aging / SkillPoints code; no games.
func _aging_probe(income: float) -> String:
	var t := CareerTuning.get_default()
	var start := {"power": 85.0, "accuracy": 85.0, "resilience": 70.0, "toughness": 75.0}
	var runs := {}
	for keep in [true, false]:
		var c := CareerData.create("Probe", t)
		c.stage = CareerData.STAGE_PRO
		for k in start:
			c.set_stat(k, start[k])
		c.age = t.aging_start_age
		var rows: Array = []
		var carry := 0.0
		for season in range(t.aging_start_age, 38):
			carry += income
			c.skill_points += int(carry)
			carry -= int(carry)
			c.season = season
			if keep:
				for st in ["power", "accuracy", "toughness", "resilience"]:
					Aging.maintain(c, st, t)
			for guard in 400:
				var best := ""
				for st in start:
					if SkillPoints.affordable(c, st, t) and (best == "" or c.stat(st) / (1.5 if st in ["power", "accuracy"] else 1.0)
							< c.stat(best) / (1.5 if best in ["power", "accuracy"] else 1.0)):
						best = st
				if best == "" or not SkillPoints.upgrade(c, best, t):
					break
			Aging.apply_season_end(c, t)
			rows.append([c.age, c.stat("power"), KickRange.fg_range(c, t), c.stat("accuracy")])
			c.age += 1
		runs[keep] = rows
	var L := PackedStringArray()
	L.append("")
	L.append("## Aging probe: preserving vs not (same pro, %.0f skill points a season)" % income)
	L.append("")
	L.append("Start at 30: Power 85, Accuracy 85, Resilience 70, Toughness 75. Values after each season's decline.")
	L.append("")
	L.append("| Age | Preserves: Power / Accuracy / FG range | Never preserves: Power / Accuracy / FG range | Range gap |")
	L.append("|---|---|---|---|")
	for i in runs[true].size():
		var a: Array = runs[true][i]
		var b: Array = runs[false][i]
		L.append("| %d | %.0f / %.0f / %.1f | %.0f / %.0f / %.1f | %+.1f yd |" % [a[0], a[1], a[3], a[2], b[1], b[3], b[2], a[2] - b[2]])
	L.append("")
	return "\n".join(L) + "\n"


## A benched career that ended within a season of its last bench (not at the age cap).
static func _ended_soon(r: Dictionary) -> bool:
	return int(r["end_season"]) - int(r["bench_last_season"]) <= 1
