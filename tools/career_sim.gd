extends Node
## Career balance simulator (not part of the game). Plays many careers with
## different choice strategies through the real CareerManager / ScenarioEngine
## / GameSim / stat rules, with a simple make-chance model standing in for the
## player's kicks, and writes a Markdown report.
##
## Run (from the project folder):
##   godot --headless res://tools/career_sim.tscn -- careers=40 seed=1
## Report: printed, and saved to user://career_sim_report.md
##
## Until Stage 5 adds recruiting and the draft, this tool moves a career into
## college (and pro) itself after senior year, with a placeholder team, so
## college/pro scenarios and end-of-college traits can be measured.

const COLLEGE_SEASONS := 4
const PRO_SEASONS := 3

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
	c.team = CareerManager._team_from_school(schools[_rng.randi_range(0, schools.size() - 1)])
	var m := CareerManager.new(c)
	m.rng.seed = _rng.randi()
	m._start_season(false)
	var out := {"hs_traits": [], "col_traits": [], "pro_traits": [], "weeks": 0, "low_weeks": 0,
		"life_sum": {}, "seen": {}}
	_run_until_stage_end(m, strat, out, 999)
	out["hs_traits"] = c.traits.duplicate()
	out["hs_personality"] = c.personality.duplicate()
	out["hs_life"] = c.life.duplicate()
	out["hs_football"] = c.football.duplicate()
	# Sim-only stand-in for recruiting (Stage 5): move on to college.
	_move_to(m, CareerData.STAGE_COLLEGE, 62.0)
	_run_until_stage_end(m, strat, out, COLLEGE_SEASONS)
	out["col_traits"] = c.traits.duplicate()
	out["col_personality"] = c.personality.duplicate()
	out["col_life"] = c.life.duplicate()
	out["col_football"] = c.football.duplicate()
	_move_to(m, CareerData.STAGE_PRO, 60.0)
	_run_until_stage_end(m, strat, out, PRO_SEASONS)
	out["pro_traits"] = c.traits.duplicate()
	for id in out["seen"]:
		_scen_careers[id] = int(_scen_careers.get(id, 0)) + 1
	return out


func _move_to(m: CareerManager, stage: String, strength: float) -> void:
	var c := m.data
	c.stage = stage
	c.season += 1
	c.season_in_stage = 1
	c.age += 1
	c.team = {"id": "sim_" + stage, "name": "Sim U", "mascot": "Simulators", "short": "SIM",
		"town": "Sim", "colors": ["#555555", "#aaaaaa"], "strength": strength, "level": stage}
	m._start_season(true)


## Plays seasons until the stage ends (HS: stage_end) or `seasons` seasons are done.
func _run_until_stage_end(m: CareerManager, strat: String, out: Dictionary, seasons: int) -> void:
	var c := m.data
	var done := 0
	var guard := 0
	while guard < 5000:
		guard += 1
		match c.phase:
			CareerManager.PHASE_WEEK_START:
				m.begin_week()
				for id in c.pending_scenarios:
					_scen_count[id] = int(_scen_count.get(id, 0)) + 1
					out["seen"][id] = true
				_track_life(c, m.tuning, out)
			CareerManager.PHASE_SCENARIO, CareerManager.PHASE_OFFSEASON:
				if c.phase == CareerManager.PHASE_OFFSEASON and c.week == 0 and out.get("_off_counted", -1) != c.season:
					out["_off_counted"] = c.season
					for id in c.pending_scenarios:
						_scen_count[id] = int(_scen_count.get(id, 0)) + 1
						out["seen"][id] = true
				m.choose(_choose(c, m.current_scenario(), strat, m.tuning))
			CareerManager.PHASE_OUTLOOK:
				m.start_game()
			CareerManager.PHASE_GAME:
				m.finish_game(_play_game(m))
			CareerManager.PHASE_RESULTS:
				m.end_week()
			CareerManager.PHASE_SEASON_END:
				done += 1
				if done >= seasons and c.stage != CareerData.STAGE_HIGH_SCHOOL:
					c.history.append({"stage": c.stage, "season": c.season, "record": c.record.duplicate()})
					return
				m.end_season()
			CareerManager.PHASE_STAGE_END:
				return


func _track_life(c: CareerData, t: CareerTuning, out: Dictionary) -> void:
	out["weeks"] += 1
	var low := c.stat("energy") < t.low_energy_threshold or c.stat("health") < t.low_health_threshold \
		or c.stat("fun") < t.low_fun_threshold or c.stat("social") < t.low_social_threshold
	if low:
		out["low_weeks"] += 1
	for k in CareerData.GROUP_KEYS[CareerData.LIFE]:
		out["life_sum"][k] = float(out["life_sum"].get(k, 0.0)) + c.stat(k)


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
		if score > best_score:
			best_score = score
			best = i
	return best


## A whole game with a simple make-chance model (better stats = more makes).
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
				var acc := c.stat("accuracy") / 100.0
				var res := c.stat("resilience") / 100.0
				match str(e["kind"]):
					"fg", "pat":
						var p := 0.97 - (int(e["yards"]) - 20) * 0.012 * (1.6 - acc) \
							- float(e.get("pressure", 0.0)) * 0.12 * (1.3 - res)
						sim.resolve_call({"made": _rng.randf() < clampf(p, 0.2, 0.98)})
					"kickoff":
						var q := clampf(_rng.randf() * 0.6 + c.stat("power") / 100.0 * 0.4, 0.0, 1.0)
						sim.resolve_call({"quality": q, "carry": 40.0 + q * 25.0, "text": "Kickoff."})
					"onside":
						sim.resolve_call({"recovered": _rng.randf() < 0.2, "text": "Onside."})
	return sim.summary()


# --- report ---------------------------------------------------------------------------

func _report(results: Dictionary, n: int, problems: PackedStringArray, ms: int) -> String:
	var t := CareerTuning.get_default()
	var L := PackedStringArray()
	L.append("# Career balance report")
	L.append("")
	L.append("%d careers per strategy (%d total), %d HS + %d college + %d pro seasons each. %.1f s. Content problems: %d." % [
		n, n * results.size(), t.high_school_seasons, COLLEGE_SEASONS, PRO_SEASONS, ms / 1000.0, problems.size()])
	L.append("Personality change scale %.2f. Trait thresholds: %s." % [t.personality_change_scale, _thresholds()])
	L.append("")
	L.append("## Traits unlocked")
	L.append("")
	L.append("| Strategy | End of HS: avg | 0 / 1-2 / 3+ | End of college: avg | 0 / 1-2 / 3-4 / 5+ | After %d pro seasons: avg |" % PRO_SEASONS)
	L.append("|---|---|---|---|---|---|")
	for s in results:
		var hs := _counts(results[s], "hs_traits")
		var col := _counts(results[s], "col_traits")
		var pro := _counts(results[s], "pro_traits")
		L.append("| %s | %.1f | %s | %.1f | %s | %.1f |" % [s, _avg(hs),
			_bucket(hs, [[0, 0], [1, 2], [3, 99]]), _avg(col),
			_bucket(col, [[0, 0], [1, 2], [3, 4], [5, 99]]), _avg(pro)])
	L.append("")
	L.append("## Which traits (share of careers, end of HS -> end of college)")
	L.append("")
	var tids: Array = CareerContent.traits().map(func(x: Dictionary) -> String: return str(x["id"]))
	L.append("| Strategy | " + " | ".join(PackedStringArray(tids.map(func(x: String) -> String:
		return str(CareerContent.trait_def(x).get("name", x))))) + " |")
	L.append("|---|" + "---|".repeat(tids.size()))
	for s in results:
		var cells := PackedStringArray()
		for id in tids:
			cells.append("%d%% -> %d%%" % [_share(results[s], "hs_traits", id), _share(results[s], "col_traits", id)])
		L.append("| %s | %s |" % [s, " | ".join(cells)])
	L.append("")
	for when in [["hs", "End of high school"], ["col", "End of college"]]:
		L.append("## Personality, %s (mean, p10-p90)" % when[1].to_lower())
		L.append("")
		L.append("| Strategy | Charisma | Ambition | Leadership | Intelligence |")
		L.append("|---|---|---|---|---|")
		for s in results:
			var cells := PackedStringArray()
			for k in CareerData.GROUP_KEYS[CareerData.PERSONALITY]:
				cells.append(_dist(results[s], when[0] + "_personality", k))
			L.append("| %s | %s |" % [s, " | ".join(cells)])
		L.append("")
	L.append("## Football stats, end of HS -> end of college (mean)")
	L.append("")
	L.append("| Strategy | Power | Accuracy | Resilience | Toughness |")
	L.append("|---|---|---|---|---|")
	for s in results:
		var cells := PackedStringArray()
		for k in CareerData.GROUP_KEYS[CareerData.FOOTBALL]:
			cells.append("%d -> %d" % [roundi(_mean(results[s], "hs_football", k)), roundi(_mean(results[s], "col_football", k))])
		L.append("| %s | %s |" % [s, " | ".join(cells)])
	L.append("")
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
		L.append("| %s | %s | %d%% |" % [s, " | ".join(cells), roundi(100.0 * low / maxf(weeks, 1.0))])
	L.append("")
	L.append("## Scenario appearances (all strategies; per career, and share of careers that saw it)")
	L.append("")
	L.append("| Scenario | Stage | Gate | Per career | Careers |")
	L.append("|---|---|---|---|---|")
	var total_careers := n * results.size()
	for sc in CareerContent.scenarios():
		var id := str(sc["id"])
		var gate := ScenarioEngine.requirement_text(sc.get("requires", {}))
		if sc.has("beat"):
			gate = "story beat"
		elif sc.get("follow_up_only", false):
			gate = "follow-up"
		L.append("| %s | %s | %s | %.2f | %d%% |" % [id, ", ".join(PackedStringArray(sc.get("stages", []))).replace("high_school", "HS"),
			gate, float(_scen_count.get(id, 0)) / total_careers, roundi(100.0 * _scen_careers.get(id, 0) / total_careers)])
	return "\n".join(L) + "\n"


func _thresholds() -> String:
	var parts := PackedStringArray()
	for tr in CareerContent.traits():
		parts.append("%s (%s)" % [tr["name"], CareerStats.trait_requirement_text(tr)])
	return ", ".join(parts)


static func _counts(rs: Array, key: String) -> Array:
	return rs.map(func(r: Dictionary) -> int: return (r[key] as Array).size())


static func _avg(xs: Array) -> float:
	return float(xs.reduce(func(a: float, x: int) -> float: return a + x, 0.0)) / maxi(xs.size(), 1)


static func _bucket(xs: Array, ranges: Array) -> String:
	var parts := PackedStringArray()
	for r in ranges:
		var k := xs.filter(func(x: int) -> bool: return x >= r[0] and x <= r[1]).size()
		parts.append("%d%%" % roundi(100.0 * k / maxi(xs.size(), 1)))
	return " / ".join(parts)


static func _share(rs: Array, key: String, id: String) -> int:
	var k := rs.filter(func(r: Dictionary) -> bool: return id in r[key]).size()
	return roundi(100.0 * k / maxi(rs.size(), 1))


static func _mean(rs: Array, key: String, stat: String) -> float:
	var s := 0.0
	for r in rs:
		s += float(r[key][stat])
	return s / maxi(rs.size(), 1)


static func _dist(rs: Array, key: String, stat: String) -> String:
	var v: Array = rs.map(func(r: Dictionary) -> float: return float(r[key][stat]))
	v.sort()
	var p := func(q: float) -> int: return roundi(v[clampi(int(q * (v.size() - 1)), 0, v.size() - 1)])
	return "%d (%d-%d)" % [roundi(_mean(rs, key, stat)), p.call(0.1), p.call(0.9)]
