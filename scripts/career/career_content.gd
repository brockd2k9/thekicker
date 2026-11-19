class_name CareerContent
extends RefCounted
## Loads the Career Mode content files in res://data/career/ once and checks
## them. Godot loads .json files as JSON resources, so they export with the
## game like any other resource. Bad entries are reported with push_warning
## (see validate()) and skipped where possible, so a typo in a data file
## doesn't crash the game.

const DIR := "res://data/career/"

static var _files: Dictionary = {}
## Every scenario (all SCENARIO_FILES) and id -> scenario, built on first use.
static var _scenario_list: Array = []
static var _scenario_index: Dictionary = {}
## The same without drafts (what the engine picks from).
static var _live_list: Array = []


static func file(name: String) -> Dictionary:
	if not _files.has(name):
		var res: Variant = load(DIR + name) if ResourceLoader.exists(DIR + name) else null
		var data: Variant = (res as JSON).data if res is JSON else null
		if not (data is Dictionary):
			push_warning("CareerContent: can't read %s%s" % [DIR, name])
			data = {}
		_files[name] = data
	return _files[name]


## Forget cached files (debug: after editing data while the game runs).
static func reload() -> void:
	_files.clear()
	_scenario_list.clear()
	_scenario_index.clear()
	_live_list.clear()


## Tests only: replace every scenario with `list` until the next reload().
static func use_scenarios(list: Array) -> void:
	_scenario_list = list
	_scenario_index.clear()
	_live_list = list.filter(func(s: Dictionary) -> bool: return not s.get("draft", false))
	for s in list:
		_scenario_index[str(s.get("id", ""))] = s


# --- game-day modifiers -------------------------------------------------------------

static func modifiers() -> Array:
	return file("modifiers.json").get("modifiers", [])


static func modifier(id: String) -> Dictionary:
	for m in modifiers():
		if m.get("id", "") == id:
			return m
	return {}


## Outlook wording for a profile field: [when it helps, when it hurts].
static func words(field: String) -> Array:
	var w: Dictionary = file("modifiers.json").get("words", {})
	var pair: Variant = w.get(field)
	return pair if pair is Array and pair.size() == 2 else [field, field]


## Outlook label/note for a stat-driven state, e.g. "low_energy".
static func state(id: String) -> Dictionary:
	var s: Dictionary = file("modifiers.json").get("states", {})
	return s.get(id, {"label": id, "note": ""})


# --- traits ---------------------------------------------------------------------------

static func traits() -> Array:
	return file("traits.json").get("traits", [])


static func trait_def(id: String) -> Dictionary:
	for t in traits():
		if t.get("id", "") == id:
			return t
	return {}


# --- world / scenarios / game day ---------------------------------------------------

## Every scenario data file.
## scenarios_hs_graph.json: the high school story graph (HS_001-HS_160), imported
## as drafts by tools/convert_hs_graph.py; drafts are never picked.
const SCENARIO_FILES := ["scenarios_hs.json", "scenarios_college.json", "scenarios_pro.json",
	"scenarios_shared.json", "scenarios_traits.json", "scenarios_hs_graph.json"]


static func world() -> Dictionary:
	return file("world.json")


static func high_schools() -> Array:
	return world().get("high_school", {}).get("schools", [])


static func school(id: String) -> Dictionary:
	for s in high_schools():
		if s.get("id", "") == id:
			return s
	return {}


static func stats_info() -> Dictionary:
	return file("stats_info.json")


static func progression() -> Dictionary:
	return file("progression.json")


static func colleges() -> Array:
	return world().get("college", {}).get("schools", [])


static func jucos() -> Array:
	return world().get("juco", {}).get("schools", [])


static func pro_clubs() -> Array:
	return world().get("pro", {}).get("clubs", [])


## Any team by id: high school, college, junior college or pro club.
static func team_by_id(id: String) -> Dictionary:
	for list in [high_schools(), colleges(), jucos(), pro_clubs()]:
		for s in list:
			if s.get("id", "") == id:
				return s
	return {}


static func game_day() -> Dictionary:
	return file("game_day.json")


static func scenarios() -> Array:
	if _scenario_list.is_empty():
		for f in SCENARIO_FILES:
			_scenario_list.append_array(file(f).get("scenarios", []))
		for s in _scenario_list:
			if not _scenario_index.has(str(s.get("id", ""))):
				_scenario_index[str(s.get("id", ""))] = s
		_live_list = _scenario_list.filter(func(s: Dictionary) -> bool: return not s.get("draft", false))
	return _scenario_list


## Every scenario that has content (no drafts).
static func live_scenarios() -> Array:
	scenarios()
	return _live_list


static func scenario(id: String) -> Dictionary:
	scenarios()
	return _scenario_index.get(id, {})


## One random line from game_day.json "plays"/<key>, with {placeholders} filled.
static func play_line(key: String, vars: Dictionary, rng: RandomNumberGenerator) -> String:
	var lines: Array = game_day().get("plays", {}).get(key, [])
	if lines.is_empty():
		return ""
	return fill(str(lines[rng.randi_range(0, lines.size() - 1)]), vars)


## "{us} lead" + {"us": "Ridgeline"} -> "Ridgeline lead".
static func fill(text: String, vars: Dictionary) -> String:
	for k in vars:
		text = text.replace("{%s}" % k, str(vars[k]))
	return text


# --- checks ---------------------------------------------------------------------------

static func _check_requires(problems: PackedStringArray, where: String, req: Dictionary) -> void:
	for bound in ["min", "max"]:
		for k in req.get(bound, {}):
			if CareerData.group_of(k) == "" and not (k in CareerData.METRICS) \
					and not (str(k).begins_with("rel_") and str(k).substr(4) in Relationships.ids()):
				problems.append("%s: unknown stat '%s' in requires" % [where, k])
	for key in ["traits", "any_traits"]:
		for t in req.get(key, []):
			if trait_def(str(t)).is_empty():
				problems.append("%s: unknown trait '%s' in requires" % [where, t])
	for key in ["flags", "any_flags", "not_flags"]:
		var v: Variant = req.get(key, [])
		if not (v is Array) or (v as Array).any(func(f: Variant) -> bool: return not (f is String)):
			problems.append("%s: requires %s must be a list of flag names" % [where, key])
	for r in req.get("any_of", []):
		_check_requires(problems, where, r)


## Teen-audience word check (data/career/content_rules.json).
static func _check_words(problems: PackedStringArray, id: String, texts: Array) -> void:
	var blocked: Array = file("content_rules.json").get("blocked_words", [])
	for t in texts:
		var low := " %s " % str(t).to_lower()
		for w in blocked:
			if low.contains(str(w)):
				problems.append("scenario %s: content rule - contains '%s'" % [id, w])

## Returns a list of problems (empty = all good) and warns about each.
static func validate() -> PackedStringArray:
	var problems := PackedStringArray()
	var ids := {}
	for m in modifiers():
		var id := str(m.get("id", ""))
		if id == "" or ids.has(id):
			problems.append("modifier: missing or duplicate id '%s'" % id)
		ids[id] = true
		for k in m.get("effects", {}):
			if not (k in KickProfile.FIELDS):
				problems.append("modifier %s: unknown effect '%s'" % [id, k])
	ids.clear()
	for t in traits():
		var id := str(t.get("id", ""))
		if id == "" or ids.has(id):
			problems.append("trait: missing or duplicate id '%s'" % id)
		ids[id] = true
		var unlock: Variant = t.get("unlock")
		if not (unlock is Array) or (unlock as Array).is_empty():
			problems.append("trait %s: needs an 'unlock' list" % id)
		else:
			for cond in unlock:
				if CareerData.group_of(str(cond.get("stat", ""))) == "":
					problems.append("trait %s: unknown unlock stat '%s'" % [id, cond.get("stat")])
		var passive: Dictionary = t.get("passive", {})
		for k in passive.get("profile", {}):
			if not (k in KickProfile.FIELDS):
				problems.append("trait %s: unknown profile effect '%s'" % [id, k])
		for k in passive.get("gains", {}):
			if not (k in CareerData.GROUP_KEYS) and CareerData.group_of(k) == "":
				problems.append("trait %s: unknown gains key '%s'" % [id, k])
	ids.clear()
	for sc in scenarios():
		var id := str(sc.get("id", ""))
		if id == "" or ids.has(id):
			problems.append("scenario: missing or duplicate id '%s'" % id)
		ids[id] = true
		for st in sc.get("stages", []):
			if not (st in CareerData.STAGES):
				problems.append("scenario %s: unknown stage '%s'" % [id, st])
		if not sc.get("draft", false) and not (str(sc.get("category", "")) in ScenarioEngine.CATEGORIES):
			problems.append("scenario %s: unknown category '%s'" % [id, sc.get("category", "")])
		for w in sc.get("when", []):
			if not (w in ["season", "bye", "offseason"]):
				problems.append("scenario %s: unknown when '%s'" % [id, w])
		if sc.has("beat") and not (sc["beat"] is Dictionary and sc["beat"].has("season_in_stage")):
			problems.append("scenario %s: beat needs season_in_stage" % id)
		if sc.get("story", false):
			if sc.has("beat"):
				problems.append("scenario %s: story and beat can't both be set" % id)
			var se: Variant = sc.get("seasons")
			if not (se is Array and se.size() == 2):
				problems.append("scenario %s: story needs seasons [first, last]" % id)
			var wk: Variant = sc.get("weeks")
			if sc.get("when", []) != ["offseason"] and not (wk is Array and wk.size() == 2):
				problems.append("scenario %s: story needs weeks [first, last] (or when [offseason])" % id)
		_check_requires(problems, "scenario %s" % id, sc.get("requires", {}))
		if sc.get("draft", false):
			# No text or choices yet: only the graph data is checked.
			if str(sc.get("title", "")) == "":
				problems.append("scenario %s: draft needs a title" % id)
			continue
		_check_words(problems, id, [sc.get("title", ""), sc.get("text", "")])
		var choices: Array = sc.get("choices", [])
		if choices.size() < 2 or choices.size() > 4:
			problems.append("scenario %s: needs 2-4 choices" % id)
		for ch in choices:
			_check_words(problems, id, [ch.get("label", ""), ch.get("result", "")])
			if (ch.get("modifiers", []) as Array).is_empty():
				problems.append("scenario %s: choice '%s' has no game-day modifier" % [id, ch.get("label", "")])
			var n_stats := ScenarioEngine.progress_changes(ch).size()
			for g in ch.get("stats", {}):
				n_stats += (ch["stats"][g] as Dictionary).size() if ch["stats"][g] is Dictionary else 0
			n_stats += (ch.get("rel", {}) as Dictionary).size() if ch.get("rel") is Dictionary else 0
			if n_stats == 0:
				problems.append("scenario %s: choice '%s' changes no stats" % [id, ch.get("label", "")])
			_check_requires(problems, "scenario %s choice" % id, ch.get("requires", {}))
			var rel: Variant = ch.get("rel", {})
			if not (rel is Dictionary):
				problems.append("scenario %s: choice rel must be {person: change}" % id)
			else:
				for pid in rel:
					if not (str(pid) in Relationships.ids()):
						problems.append("scenario %s: unknown person '%s' in rel" % [id, pid])
			var fu: Variant = ch.get("follow_up")
			if fu != null:
				var fid := str(fu.get("id", "")) if fu is Dictionary else str(fu)
				var target := scenario(fid)
				if target.is_empty():
					problems.append("scenario %s: follow_up '%s' doesn't exist" % [id, fid])
				elif not target.get("follow_up_only", false):
					problems.append("scenario %s: follow_up '%s' should be follow_up_only" % [id, fid])
			for g in ch.get("stats", {}):
				if not (g in CareerData.GROUP_KEYS):
					problems.append("scenario %s: unknown stat group '%s'" % [id, g])
					continue
				for k in ch["stats"][g]:
					if CareerData.group_of(k) != g:
						problems.append("scenario %s: '%s' is not a %s stat" % [id, k, g])
			for m in ch.get("modifiers", []):
				if modifier(str(m)).is_empty():
					problems.append("scenario %s: unknown modifier '%s'" % [id, m])
	problems.append_array(graph_problems(scenarios()))
	problems.append_array(Relationships.problems())
	for r in game_day().get("warmup", {}).get("results", {}).values():
		if modifier(str(r.get("modifier", ""))).is_empty():
			problems.append("game_day warmup: unknown modifier '%s'" % r.get("modifier"))
	for p in problems:
		push_warning("CareerContent: " + p)
	return problems


# --- story graph checks -------------------------------------------------------------

## Flags the game itself sets (CareerManager), not scenario choices.
const ENGINE_FLAGS := ["walk_on", "juco", "failed_tryouts", "fa_attempts", "recruiting_update",
	"traits_reported"]
const _STAGE_ORDER := {"high_school": 0, "juco": 1, "college": 2, "pro": 3, "free_agent": 3}


## Flag problems across scenarios (static so tests can pass made-up lists):
##   * a flag is required (requires flags / any_flags / not_flags, also on
##     choices) but no choice sets it (drafts count their expected_flags)
##   * a scenario requires a flag only it sets (it can never become eligible that way)
##   * a required flag is only set later than the scenario can happen (season /
##     week windows, offseason after the season, stage order)
##   * a finished (non-draft) scenario doesn't set one of its expected_flags
static func graph_problems(list: Array) -> PackedStringArray:
	var problems := PackedStringArray()
	var setters := {}  # flag -> [scenario]
	for sc in list:
		for f in _flags_set(sc):
			if not setters.has(f):
				setters[f] = []
			setters[f].append(sc)
	for sc in list:
		var id := str(sc.get("id", ""))
		var req: Dictionary = sc.get("requires", {})
		var reads := _flags_read(req)
		for ch in sc.get("choices", []):
			reads.append_array(_flags_read(ch.get("requires", {})))
		for f in reads:
			if not setters.has(f) and not (f in ENGINE_FLAGS):
				problems.append("scenario %s: flag '%s' is required but nothing sets it" % [id, f])
		var own: Array = req.get("flags", []) + req.get("any_flags", [])
		for f in own:
			var src: Array = setters.get(f, [])
			if not src.is_empty() and src.all(func(x: Dictionary) -> bool: return str(x.get("id", "")) == id):
				problems.append("scenario %s: requires flag '%s' that only it sets" % [id, f])
			elif not src.is_empty() and not (f in ENGINE_FLAGS) \
					and not src.any(func(x: Dictionary) -> bool: return _can_precede(x, sc)):
				problems.append("scenario %s: flag '%s' is only set after this scenario's window" % [id, f])
		if not sc.get("draft", false):
			var set_now := _flags_set(sc)
			for f in sc.get("expected_flags", []):
				if not (f in set_now):
					problems.append("scenario %s: no choice sets expected flag '%s'" % [id, f])
	return problems


## Flags a scenario's choices set to true (a draft: its expected_flags).
static func _flags_set(sc: Dictionary) -> Array:
	var out: Array = []
	if sc.get("draft", false):
		out.append_array(sc.get("expected_flags", []))
	for ch in sc.get("choices", []):
		var sf: Variant = ch.get("set_flags", {})
		if sf is Dictionary:
			for f in sf:
				if sf[f] and not (f in out):
					out.append(str(f))
	return out


static func _flags_read(req: Dictionary) -> Array:
	var out: Array = []
	for key in ["flags", "any_flags", "not_flags"]:
		for f in req.get(key, []):
			out.append(str(f))
	for r in req.get("any_of", []):
		out.append_array(_flags_read(r))
	return out


## [stage, season, week] bounds of when a scenario can happen; the offseason
## after season s is week 99 of season s. Follow-up-only scenarios happen
## whenever they're queued, so they're open-ended.
static func _time_span(sc: Dictionary) -> Array:
	var ranks: Array = (sc.get("stages", []) as Array).map(func(st: Variant) -> int:
		return int(_STAGE_ORDER.get(str(st), 0)))
	if ranks.is_empty():
		ranks = [0]
	var se: Variant = sc.get("seasons")
	var wk: Variant = sc.get("weeks")
	var when: Array = sc.get("when", ["season", "bye"])
	var s0 := int(se[0]) if se is Array and se.size() == 2 else 0
	var s1 := int(se[1]) if se is Array and se.size() == 2 else 99
	var w0 := int(wk[0]) if wk is Array and wk.size() == 2 else 1
	var w1 := int(wk[1]) if wk is Array and wk.size() == 2 else 98
	if when == ["offseason"]:
		w0 = 99
	if "offseason" in when:
		w1 = 99
	var beat: Variant = sc.get("beat")
	if beat is Dictionary:
		s0 = int(beat.get("season_in_stage", 1))
		s1 = s0
		w0 = 99 if when == ["offseason"] else int(beat.get("week", 1))
	if sc.get("follow_up_only", false):
		return [[ranks.min(), 0, 0], [99, 99, 99]]
	return [[ranks.min(), s0, w0], [ranks.max(), s1, w1]]


## Can `setter` happen strictly before `target` in some career? (Requirements
## are checked when the week is picked, so the same week is too late.)
static func _can_precede(setter: Dictionary, target: Dictionary) -> bool:
	var a: Array = _time_span(setter)[0]
	var b: Array = _time_span(target)[1]
	for i in 3:
		if a[i] != b[i]:
			return a[i] < b[i]
	return false
