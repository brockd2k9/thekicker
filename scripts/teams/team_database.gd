extends Node
## Autoload "TeamDatabase": every team in the game (high school, college, pro),
## loaded from data/teams/*.json. Nothing else defines or hardcodes teams.
##
##   data/teams/high_school.json, college.json, pro.json   the teams (generated
##       by tools/teams/import_teams.py from data/teams/source/*.csv)
##   data/teams/leagues.json   levels, divisions (FBS / FCS / D2 / JUCO ...) and
##       their conferences; which recruiting tier a college division plays at;
##       the start team (Hoboken High School)
##   data/teams/colors.json    color names -> hex
## Field reference: DATA_FORMAT.md. Validator: validate() (run by
## tools/validate_teams.tscn, the tests, and at startup in debug builds).
##
## Lookups return "team records": the data entry plus the fields the game's
## systems already use, so team records stay compatible with saves:
##   id, name (school / club), mascot (= nickname, e.g. "Rebels"), nickname,
##   short (= abbr), abbr, town (= city), city, colors [hex, hex], strength
##   (0-100, the sim's rating), tier (college: top / mid / small / juco),
##   division, conference, level, placeholder, and every other data field.
## Copies are returned; change data/teams, not the records.

const DIR := "res://data/teams/"
const FILES := {"high_school": "high_school.json", "college": "college.json", "pro": "pro.json"}
const LEVELS := ["high_school", "college", "pro"]
## Fallback when leagues.json doesn't name one.
const DEFAULT_START := "hoboken_hs"
## Rating used for the sim when a team has neither "strength" nor "ratings.prestige".
const DEFAULT_STRENGTH := 50.0
## Derived strengths (from prestige, per division) are spread over this range.
const DERIVED_MIN := 35.0
const DERIVED_MAX := 80.0
const REQUIRED := ["id", "name", "nickname", "abbr", "division", "conference", "colors"]

var _raw: Dictionary = {}       # level -> Array of data entries
var _leagues: Dictionary = {}
var _palette: Dictionary = {}
var _records: Dictionary = {}   # id -> team record
var _by_level: Dictionary = {}  # level -> Array of ids (data order)
var _loaded := false


func _ready() -> void:
	ensure_loaded()
	if OS.is_debug_build():
		var r := validate()
		for e in r["errors"]:
			push_error("TeamDatabase: " + e)


func ensure_loaded() -> void:
	if not _loaded:
		load_files()


## (Re)loads data/teams/*.json.
func load_files() -> void:
	var raw := {}
	for lv in LEVELS:
		raw[lv] = _json(DIR + FILES[lv]).get("teams", [])
	load_data(raw, _json(DIR + "leagues.json"), _json(DIR + "colors.json").get("colors", {}))


## Loads teams from dictionaries (tests and the validator use this with
## made-up data). raw: {level: [entries]}.
func load_data(raw: Dictionary, leagues: Dictionary, palette: Dictionary) -> void:
	_loaded = true  # before building records: lookups below must not reload
	_raw = raw
	_leagues = leagues
	_palette = {}
	for k in palette:
		_palette[str(k).to_lower()] = str(palette[k])
	_records = {}
	_by_level = {}
	var derived := _derived_strengths()
	for lv in LEVELS:
		_by_level[lv] = []
		for e in _raw.get(lv, []):
			if not (e is Dictionary) or str(e.get("id", "")) == "":
				continue
			var id := str(e["id"])
			if _records.has(id):
				continue  # validate() reports duplicates
			_records[id] = _record(e, lv, derived)
			_by_level[lv].append(id)
	_loaded = true


static func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return v if v is Dictionary else {}


# --- lookups ------------------------------------------------------------------------------

## A team record by id ({} when unknown).
func team(id: String) -> Dictionary:
	ensure_loaded()
	return (_records[id] as Dictionary).duplicate(true) if _records.has(id) else {}


func has_team(id: String) -> bool:
	ensure_loaded()
	return _records.has(id)


## Every team of a level, in data order.
func teams(level: String) -> Array:
	ensure_loaded()
	var out: Array = []
	for id in _by_level.get(level, []):
		out.append((_records[id] as Dictionary).duplicate(true))
	return out


func high_schools() -> Array:
	return teams("high_school")


## Four-year colleges (FBS, FCS, D2...): every college that isn't junior college.
func colleges() -> Array:
	return teams("college").filter(func(t: Dictionary) -> bool: return t.get("tier", "") != "juco")


## Junior colleges (the JUCO route after high school).
func jucos() -> Array:
	return teams("college").filter(func(t: Dictionary) -> bool: return t.get("tier", "") == "juco")


func pro_teams() -> Array:
	return teams("pro")


## The team every career starts at: Hoboken High School.
func start_team_id() -> String:
	ensure_loaded()
	return str(_leagues.get("start_team", DEFAULT_START))


func start_team() -> Dictionary:
	return team(start_team_id())


## Other teams in the same conference (schedules play these first).
func conference_mates(t: Dictionary) -> Array:
	var conf := str(t.get("conference", ""))
	return teams(str(t.get("level", "high_school"))).filter(func(o: Dictionary) -> bool:
		return str(o.get("conference", "")) == conf and str(o.get("id", "")) != str(t.get("id", "")))


## Division info from leagues.json ({} when unknown).
func division_info(level: String, division: String) -> Dictionary:
	ensure_loaded()
	return _leagues.get("levels", {}).get(level, {}).get("divisions", {}).get(division, {})


## "#c8102e" for a color name or hex ("" when unknown).
func color_hex(name: String) -> String:
	var n := name.strip_edges()
	if n.begins_with("#"):
		return n
	return str(_palette.get(n.to_lower(), ""))


# --- records ------------------------------------------------------------------------------

func _record(e: Dictionary, level: String, derived: Dictionary) -> Dictionary:
	var r: Dictionary = e.duplicate(true)
	var id := str(e["id"])
	r["level"] = level
	r["nickname"] = str(e.get("nickname", e.get("name", "")))
	r["mascot"] = r["nickname"]  # older systems and saves call the nickname "mascot"
	if e.has("mascot"):
		r["mascot_figure"] = e["mascot"]
	r["abbr"] = str(e.get("abbr", "")).to_upper()
	r["short"] = r["abbr"]
	r["town"] = str(e.get("city", ""))
	r["city"] = r["town"]
	var names: Array = e.get("colors", [])
	var hexes: Array = []
	for c in names:
		var h := color_hex(str(c))
		if h != "":
			hexes.append(h)
	while hexes.size() < 2:
		hexes.append("#7d838c" if hexes.is_empty() else "#f4f4f2")
	r["color_names"] = names.duplicate()
	r["colors"] = hexes
	r["strength"] = float(e["strength"]) if e.has("strength") else float(derived.get(id, DEFAULT_STRENGTH))
	var div := division_info(level, str(e.get("division", "")))
	r["tier"] = str(div.get("tier", "")) if level == "college" else ""
	r["placeholder"] = bool(e.get("placeholder", false))
	return r


## Strength from prestige, spread over DERIVED_MIN..MAX within each division
## (so every division has strong and weak teams). Teams with their own
## "strength" keep it; teams without prestige get DEFAULT_STRENGTH.
func _derived_strengths() -> Dictionary:
	var by_div := {}
	for lv in LEVELS:
		for e in _raw.get(lv, []):
			if e is Dictionary and not e.has("strength") and e.get("ratings", {}) is Dictionary \
					and (e.get("ratings", {}) as Dictionary).has("prestige"):
				var key := "%s/%s" % [lv, e.get("division", "")]
				if not by_div.has(key):
					by_div[key] = []
				by_div[key].append(e)
	var out := {}
	for key in by_div:
		var lst: Array = by_div[key]
		var lo := INF
		var hi := -INF
		for e in lst:
			var p := float(e["ratings"]["prestige"])
			lo = minf(lo, p)
			hi = maxf(hi, p)
		for e in lst:
			var p := float(e["ratings"]["prestige"])
			var f := (p - lo) / (hi - lo) if hi > lo else 0.5
			out[str(e.get("id", ""))] = roundf(lerpf(DERIVED_MIN, DERIVED_MAX, f))
	return out


# --- validation ---------------------------------------------------------------------------

## Checks the loaded data. {"errors": [...], "warnings": [...]}, one line each,
## naming the team (id and name) and what's wrong. Errors break the game or
## saves; warnings are worth a look (defaults used, likely typos).
func validate() -> Dictionary:
	ensure_loaded()
	var errors := PackedStringArray()
	var warnings := PackedStringArray()
	var seen_ids := {}
	var names := {}
	for lv in LEVELS:
		var abbr_conf := {}
		var abbr_level := {}
		for e in _raw.get(lv, []):
			if not (e is Dictionary):
				errors.append("%s: an entry isn't an object" % lv)
				continue
			var id := str(e.get("id", ""))
			var who := "%s '%s' (%s)" % [lv, id, e.get("name", "?")]
			for f in REQUIRED:
				var v: Variant = e.get(f)
				if v == null or (v is String and (v as String).strip_edges() == "") or (v is Array and (v as Array).is_empty()):
					errors.append("%s: missing required field '%s'" % [who, f])
			if id != "":
				if not id.is_valid_identifier() or id != id.to_lower():
					errors.append("%s: id must be lowercase letters, digits and _ (got '%s')" % [who, id])
				if seen_ids.has(id):
					errors.append("%s: duplicate id (also used by %s)" % [who, seen_ids[id]])
				seen_ids[id] = who
			names[str(e.get("name", "")).to_lower()] = id
			# Division / conference must be in leagues.json.
			var div := str(e.get("division", ""))
			var dinfo := division_info(lv, div)
			if div != "" and dinfo.is_empty():
				errors.append("%s: unknown division '%s' (not in leagues.json for %s)" % [who, div, lv])
			var conf := str(e.get("conference", ""))
			if conf == "":
				pass  # reported as missing above
			elif not dinfo.is_empty() and not (conf in (dinfo.get("conferences", []) as Array)):
				errors.append("%s: unknown conference '%s' (not listed under %s in leagues.json)" % [who, conf, div])
			# Abbreviations: unique within a conference (they play each other),
			# and preferably within the level.
			var ab := str(e.get("abbr", "")).to_upper()
			if ab != "":
				if ab.length() < 2 or ab.length() > 4:
					warnings.append("%s: abbreviation '%s' should be 2-4 letters" % [who, ab])
				var ck := "%s|%s" % [conf, ab]
				if abbr_conf.has(ck):
					errors.append("%s: abbreviation '%s' collides with %s in %s" % [who, ab, abbr_conf[ck], conf])
				elif abbr_level.has(ab):
					warnings.append("%s: abbreviation '%s' also used by %s" % [who, ab, abbr_level[ab]])
				abbr_conf[ck] = who
				abbr_level[ab] = who
			for c in e.get("colors", []):
				if color_hex(str(c)) == "":
					errors.append("%s: unknown color '%s' (add it to data/teams/colors.json)" % [who, c])
			var uni: Variant = e.get("uniforms", {})
			if uni is Dictionary:
				for side in uni:
					for part in uni[side]:
						if color_hex(str(uni[side][part])) == "":
							errors.append("%s: unknown %s %s color '%s'" % [who, side, part, uni[side][part]])
			if not e.has("strength") and not (e.get("ratings", {}) is Dictionary and (e.get("ratings", {}) as Dictionary).has("prestige")):
				warnings.append("%s: no strength or prestige; the sim uses %d" % [who, DEFAULT_STRENGTH])
			for f in ["name", "nickname"]:
				var s := str(e.get(f, ""))
				if s != "" and _doubled_word(s) != "":
					warnings.append("%s: %s repeats a word ('%s')" % [who, f, _doubled_word(s)])
			var st: Variant = e.get("stadium", {})
			if st is Dictionary and _doubled_word(str(st.get("name", ""))) != "":
				warnings.append("%s: stadium name repeats a word ('%s')" % [who, st.get("name", "")])
			if bool(e.get("placeholder", false)):
				warnings.append("%s: placeholder team (replace with real data)" % who)
	# Rivals must be real teams; every level and division needs teams to play.
	for lv in LEVELS:
		for e in _raw.get(lv, []):
			if not (e is Dictionary):
				continue
			var rv: Variant = e.get("rival", {})
			if rv is Dictionary and not (rv as Dictionary).is_empty():
				var rid := str(rv.get("id", names.get(str(rv.get("name", "")).to_lower(), "")))
				if rid == "" or not seen_ids.has(rid):
					errors.append("%s '%s': rival '%s' isn't a team in the data" % [lv, e.get("id", ""), rv.get("name", rid)])
	for lv in LEVELS:
		var n := (_raw.get(lv, []) as Array).size()
		if n < 2:
			errors.append("%s: needs at least 2 teams to play games (has %d)" % [lv, n])
		for div in _leagues.get("levels", {}).get(lv, {}).get("divisions", {}):
			for conf in _leagues["levels"][lv]["divisions"][div].get("conferences", []):
				var members := (_raw.get(lv, []) as Array).filter(func(e: Variant) -> bool:
					return e is Dictionary and str(e.get("conference", "")) == str(conf))
				if members.is_empty():
					warnings.append("%s %s: conference '%s' has no teams" % [lv, div, conf])
	if not seen_ids.has(start_team_id()):
		errors.append("start team '%s' (leagues.json start_team) isn't in the data" % start_team_id())
	elif not ("high_school" in str(seen_ids[start_team_id()])):
		errors.append("start team '%s' must be a high school" % start_team_id())
	return {"errors": errors, "warnings": warnings}


static func _doubled_word(s: String) -> String:
	var w := s.split(" ", false)
	for i in range(1, w.size()):
		if w[i].to_lower() == w[i - 1].to_lower():
			return s
	return ""
