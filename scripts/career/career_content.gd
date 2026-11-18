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
	for p in problems:
		push_warning("CareerContent: " + p)
	return problems
