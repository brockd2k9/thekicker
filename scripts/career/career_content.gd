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

## Every scenario data file. Stage 4 adds college, pro and trait-gated files.
const SCENARIO_FILES := ["scenarios_hs.json"]


static func world() -> Dictionary:
	return file("world.json")


static func high_schools() -> Array:
	return world().get("high_school", {}).get("schools", [])


static func school(id: String) -> Dictionary:
	for s in high_schools():
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
		var choices: Array = sc.get("choices", [])
		if choices.size() < 2 or choices.size() > 4:
			problems.append("scenario %s: needs 2-4 choices" % id)
		for ch in choices:
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
		var req: Dictionary = sc.get("requires", {})
		for bound in ["min", "max"]:
			for k in req.get(bound, {}):
				if CareerData.group_of(k) == "":
					problems.append("scenario %s: unknown stat '%s' in requires" % [id, k])
	for r in game_day().get("warmup", {}).get("results", {}).values():
		if modifier(str(r.get("modifier", ""))).is_empty():
			problems.append("game_day warmup: unknown modifier '%s'" % r.get("modifier"))
	for p in problems:
		push_warning("CareerContent: " + p)
	return problems
