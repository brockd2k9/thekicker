class_name CareerContent
extends RefCounted
## Loads the Career Mode content files in res://data/career/ once and checks
## them. Godot loads .json files as JSON resources, so they export with the
## game like any other resource. Bad entries are reported with push_warning
## (see validate()) and skipped where possible, so a typo in a data file
## doesn't crash the game.

const DIR := "res://data/career/"

static var _files: Dictionary = {}


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
const SCENARIO_FILES := ["scenarios_hs.json", "scenarios_college.json", "scenarios_pro.json",
	"scenarios_shared.json", "scenarios_traits.json"]


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
	var all: Array = []
	for f in SCENARIO_FILES:
		all.append_array(file(f).get("scenarios", []))
	return all


static func scenario(id: String) -> Dictionary:
	for s in scenarios():
		if s.get("id", "") == id:
			return s
	return {}


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
			if CareerData.group_of(k) == "" and not (k in CareerData.METRICS):
				problems.append("%s: unknown stat '%s' in requires" % [where, k])
	for key in ["traits", "any_traits"]:
		for t in req.get(key, []):
			if trait_def(str(t)).is_empty():
				problems.append("%s: unknown trait '%s' in requires" % [where, t])
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
		if not (str(sc.get("category", "")) in ScenarioEngine.CATEGORIES):
			problems.append("scenario %s: unknown category '%s'" % [id, sc.get("category", "")])
		for w in sc.get("when", []):
			if not (w in ["season", "bye", "offseason"]):
				problems.append("scenario %s: unknown when '%s'" % [id, w])
		if sc.has("beat") and not (sc["beat"] is Dictionary and sc["beat"].has("season_in_stage")):
			problems.append("scenario %s: beat needs season_in_stage" % id)
		_check_requires(problems, "scenario %s" % id, sc.get("requires", {}))
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
			if n_stats == 0:
				problems.append("scenario %s: choice '%s' changes no stats" % [id, ch.get("label", "")])
			_check_requires(problems, "scenario %s choice" % id, ch.get("requires", {}))
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
	for r in game_day().get("warmup", {}).get("results", {}).values():
		if modifier(str(r.get("modifier", ""))).is_empty():
			problems.append("game_day warmup: unknown modifier '%s'" % r.get("modifier"))
	for p in problems:
		push_warning("CareerContent: " + p)
	return problems
