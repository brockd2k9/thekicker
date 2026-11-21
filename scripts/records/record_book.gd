class_name RecordBook
extends RefCounted
## All-time records: ranked lists per level and scope (league, conference,
## division, team), single season and career, built from the fictional record
## book (data/records/record_book.json, made once by
## tools/records/generate_records.py) plus your kicker's own seasons.
##
## Nothing here is saved except your record events (CareerData.records, kept
## by check()); the fictional book is read-only data and the lists are built
## from it the first time they're needed (cached per scope).
##
## Scopes are keys built from TeamDatabase fields, so team, conference and
## division names all come from data/teams:
##   "level"               the whole level (pro league; high school region)
##   "division:<id>"       a TeamDatabase division (pro AFC / NFC; college FBS / FCS / D2)
##   "conference:<division>/<name>"   a TeamDatabase conference within its
##                         division (pro AFC East; college conferences, whose
##                         names can repeat across divisions; the high school
##                         league division)
##   "team:<id>"
## Junior colleges have no record books and junior college seasons don't
## count toward college records.
##
## An entry: {name, teams [ids], years "1998" / "1995-2003", first_year,
##  seasons, att, made, xp, b [5 made by distance] (or [] unknown), long,
##  value, mine (bool), season (yours), current (season in progress), rank}.

const PATH := "res://data/records/record_book.json"
const LEVEL_HS := CareerRecords.LEVEL_HS
const LEVEL_COLLEGE := CareerRecords.LEVEL_COLLEGE
const LEVEL_PRO := CareerRecords.LEVEL_PRO
const LEVELS := [LEVEL_HS, LEVEL_COLLEGE, LEVEL_PRO]

const SEASON := "season"
const CAREER := "career"
const SPANS := [SEASON, CAREER]
const SPAN_NAMES := {SEASON: "Single Season", CAREER: "Career"}

const CATS := ["fg_pct", "fg_att", "fg_made", "xp_made", "points",
	"made_20", "made_30", "made_40", "made_50", "made_60", "long"]
const CAT_NAMES := {"fg_pct": "Field Goal %", "fg_att": "Field Goal Attempts", "fg_made": "Field Goals Made",
	"xp_made": "Extra Points Made", "points": "Points", "made_20": "FGs Made, 20-29 yd",
	"made_30": "FGs Made, 30-39 yd", "made_40": "FGs Made, 40-49 yd", "made_50": "FGs Made, 50-59 yd",
	"made_60": "FGs Made, 60+ yd", "long": "Longest Field Goal"}
## Short unit words for "7 more FGs to break the record".
const CAT_UNITS := {"fg_att": ["attempt", "attempts"], "fg_made": ["FG", "FGs"], "xp_made": ["extra point", "extra points"],
	"points": ["point", "points"], "made_20": ["FG", "FGs"], "made_30": ["FG", "FGs"], "made_40": ["FG", "FGs"],
	"made_50": ["FG", "FGs"], "made_60": ["FG", "FGs"], "long": ["yard", "yards"]}
const BUCKET_CATS := ["made_20", "made_30", "made_40", "made_50", "made_60"]
const CAT_INDEX := {"fg_pct": 0, "fg_att": 1, "fg_made": 2, "xp_made": 3, "points": 4,
	"made_20": 5, "made_30": 6, "made_40": 7, "made_50": 8, "made_60": 9, "long": 10}

## Field goal % lists: a career needs CAREER_MIN_ATT attempts; a season, one
## attempt per regular-season game at each level (10 / 12 / 17 games: high
## school 8, a little under, since high school kickers try fewer).
const CAREER_MIN_ATT := 50
const SEASON_MIN_ATT := {LEVEL_HS: 8, LEVEL_COLLEGE: 12, LEVEL_PRO: 17}

## Scope kinds per level, and what each level calls them on screen.
const KINDS := {LEVEL_HS: ["level", "conference", "team"], LEVEL_COLLEGE: ["division", "conference", "team"],
	LEVEL_PRO: ["level", "division", "conference", "team"]}
const KIND_NAMES := {
	LEVEL_HS: {"level": "League", "conference": "Division", "team": "Team"},
	LEVEL_COLLEGE: {"division": "Division", "conference": "Conference", "team": "Team"},
	LEVEL_PRO: {"level": "League", "division": "Conference", "conference": "Division", "team": "Team"},
}

const B36 := "0123456789abcdefghijklmnopqrstuvwxyz"

static var _book: Dictionary = {}
static var _first: Array = []
static var _last: Array = []
## level -> team_id -> Array of players {name, seasons: [{year, team, att, xp, b, long}]}
static var _players: Dictionary = {}
## "level|scope" -> {"span|cat": Array of entries} (the fictional book only)
static var _cache: Dictionary = {}


# --- the data file -------------------------------------------------------------------------

static func book() -> Dictionary:
	if _book.is_empty():
		var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
		_book = v if v is Dictionary else {"levels": {}}
		_first = _book.get("names", {}).get("first", [])
		_last = _book.get("names", {}).get("last", [])
	return _book


## The last year of the fictional book (2025); your seasons come after it.
static func last_year() -> int:
	return int(book().get("last_year", 2025))


static func _n(s: String, at: int, width: int) -> int:
	var v := 0
	for i in width:
		v = v * 36 + B36.find(s[at + i])
	return v


static func _season(s: String, at: int, year: int, team: String) -> Dictionary:
	var b := [_n(s, at + 4, 1), _n(s, at + 5, 1), _n(s, at + 6, 1), _n(s, at + 7, 1), _n(s, at + 8, 1)]
	return {"year": year, "team": team, "att": _n(s, at, 2), "xp": _n(s, at + 2, 2), "b": b,
		"made": int(b[0]) + int(b[1]) + int(b[2]) + int(b[3]) + int(b[4]), "long": _n(s, at + 9, 2)}


static func _name(s: String) -> String:
	return "%s %s" % [_first[_n(s, 0, 2)], _last[_n(s, 2, 2)]]


## The fictional kickers of a team (decoded the first time).
static func team_players(level: String, team_id: String) -> Array:
	book()
	if not _players.has(level):
		_players[level] = {}
		if level == LEVEL_PRO:
			_decode_pro()
	if _players[level].has(team_id):
		return _players[level][team_id]
	var out: Array = []
	if level != LEVEL_PRO:
		var raw := str(_book.get("levels", {}).get(level, {}).get("teams", {}).get(team_id, ""))
		for p in raw.split(",", false):
			var y0 := 1900 + _n(p, 4, 2)
			var seasons: Array = []
			var at := 6
			while at + 11 <= p.length():
				seasons.append(_season(p, at, y0 + seasons.size(), team_id))
				at += 11
			out.append({"name": _name(p), "seasons": seasons})
	_players[level][team_id] = out
	return out


## Pro kickers move between teams: decoded together, then filed under every
## team they played for (the same player dict).
static func _decode_pro() -> void:
	var lv: Dictionary = _book.get("levels", {}).get(LEVEL_PRO, {})
	var teams: Array = lv.get("teams", [])
	for p in str(lv.get("players", "")).split(",", false):
		var seasons: Array = []
		var at := 4
		while at + 15 <= p.length():
			seasons.append(_season(p, at + 4, 1900 + _n(p, at, 2), str(teams[_n(p, at + 2, 2)])))
			at += 15
		var player := {"name": _name(p), "seasons": seasons}
		var seen := {}
		for s in seasons:
			if not seen.has(s["team"]):
				seen[s["team"]] = true
				if not _players[LEVEL_PRO].has(s["team"]):
					_players[LEVEL_PRO][s["team"]] = []
				_players[LEVEL_PRO][s["team"]].append(player)


## Every fictional kicker's name at a level (tests).
static func all_names(level: String) -> Array:
	var out: Array = []
	var seen := {}
	for t in record_teams(level):
		for p in team_players(level, str(t["id"])):
			if not seen.has(p["name"]):
				seen[p["name"]] = true
				out.append(p["name"])
	return out


# --- scopes ---------------------------------------------------------------------------------

## The teams that have record books at a level (junior colleges don't).
static func record_teams(level: String) -> Array:
	return TeamDatabase.teams(level).filter(func(t: Dictionary) -> bool: return str(t.get("tier", "")) != "juco")


static func kind_of(key: String) -> String:
	return key.get_slice(":", 0)


static func team_in(t: Dictionary, key: String) -> bool:
	var v := key.substr(key.find(":") + 1) if ":" in key else ""
	match kind_of(key):
		"level":
			return str(t.get("tier", "")) != "juco"
		"division":
			return str(t.get("division", "")) == v
		"conference":
			return "%s/%s" % [t.get("division", ""), t.get("conference", "")] == v
		"team":
			return str(t.get("id", "")) == v
	return false


## The scopes of a level for one kind, in TeamDatabase order:
## [{key, kind, name, short}].
static func scopes(level: String, kind: String) -> Array:
	var out: Array = []
	var seen := {}
	match kind:
		"level":
			out.append({"key": "level", "kind": kind, "name": level_name(level), "short": level_name(level)})
		"division", "conference":
			for t in record_teams(level):
				var v := str(t.get(kind, ""))
				if v == "":
					continue
				var key := "%s:%s" % [kind, v] if kind == "division" else "conference:%s/%s" % [t.get("division", ""), v]
				if seen.has(key):
					continue
				seen[key] = true
				out.append({"key": key, "kind": kind, "name": scope_name(level, key), "short": v})
		"team":
			for t in record_teams(level):
				out.append({"key": "team:" + str(t["id"]), "kind": kind, "name": str(t["name"]),
					"short": str(t.get("short", ""))})
	return out


## The scopes a team belongs to, widest first (level, division, conference, team).
static func scopes_of_team(level: String, team_id: String) -> Array:
	var t := TeamDatabase.team(team_id)
	if t.is_empty() or str(t.get("level", "")) != level or str(t.get("tier", "")) == "juco":
		return []
	var out: Array = []
	for kind in KINDS[level]:
		match kind:
			"level":
				out.append("level")
			"division":
				out.append("division:%s" % t.get("division", ""))
			"conference":
				out.append("conference:%s/%s" % [t.get("division", ""), t.get("conference", "")])
			"team":
				out.append("team:" + team_id)
	return out


## "Kicker Professional Football League", "South Georgia", "American Football Conference" ...
static func level_name(level: String) -> String:
	var info := TeamDatabase.level_info(level)
	if str(info.get("league", "")) != "":
		return str(info["league"])
	var ts := record_teams(level)
	if not ts.is_empty() and str(ts[0].get("region", "")) != "":
		return str(ts[0]["region"])
	return str(info.get("name", level))


static func scope_name(level: String, key: String) -> String:
	var v := key.substr(key.find(":") + 1) if ":" in key else ""
	match kind_of(key):
		"level":
			return level_name(level)
		"division":
			return str(TeamDatabase.division_info(level, v).get("name", v))
		"conference":
			return v.substr(v.find("/") + 1)
		"team":
			return str(TeamDatabase.team(v).get("name", v))
	return key


static func kind_name(level: String, kind: String) -> String:
	return str(KIND_NAMES.get(level, {}).get(kind, kind.capitalize()))


static func list_size(span: String, cat: String) -> int:
	return 50 if span == CAREER and cat == "fg_made" else 25


static func min_att(level: String, span: String) -> int:
	return CAREER_MIN_ATT if span == CAREER else int(SEASON_MIN_ATT.get(level, 10))


# --- entries and values ---------------------------------------------------------------------

## An entry's value on a list (entries carry them all in "v", CATS order).
static func value(e: Dictionary, cat: String) -> float:
	if e.has("v"):
		return float(e["v"][CAT_INDEX[cat]])
	return _value(e, cat)


static func _value(e: Dictionary, cat: String) -> float:
	match cat:
		"fg_pct":
			return float(e["made"]) / float(e["att"]) if int(e["att"]) > 0 else 0.0
		"fg_att":
			return float(e["att"])
		"fg_made":
			return float(e["made"])
		"xp_made":
			return float(e["xp"])
		"points":
			return float(3 * int(e["made"]) + int(e["xp"]))
		"long":
			return float(e["long"])
	var i := BUCKET_CATS.find(cat)
	return float(e["b"][i]) if i >= 0 and (e["b"] as Array).size() == 5 else 0.0


## Can this entry be on this list? Counts need at least one; FG% needs the
## minimum attempts; distance lists need known distances (your seasons
## before the kick log are unknown).
static func eligible(e: Dictionary, level: String, span: String, cat: String) -> bool:
	if cat in BUCKET_CATS and (e["b"] as Array).size() != 5:
		return false
	if cat == "fg_pct":
		return int(e["att"]) >= min_att(level, span)
	return value(e, cat) > 0.0


## a ranks ahead of b: higher value, then (FG%) more attempts, then earlier
## year (who did it first), then name.
static func ahead(a: Dictionary, b: Dictionary, cat: String) -> bool:
	var va := value(a, cat)
	var vb := value(b, cat)
	if not is_equal_approx(va, vb):
		return va > vb
	if cat == "fg_pct" and int(a["att"]) != int(b["att"]):
		return int(a["att"]) > int(b["att"])
	if int(a["first_year"]) != int(b["first_year"]):
		return int(a["first_year"]) < int(b["first_year"])
	return str(a["name"]) < str(b["name"])


## Keeps `top` (sorted, best first) at most n long while adding e.
static func _offer(top: Array, e: Dictionary, n: int, cat: String) -> void:
	if top.size() >= n and not ahead(e, top[top.size() - 1], cat):
		return
	var i := top.size()
	while i > 0 and ahead(e, top[i - 1], cat):
		i -= 1
	top.insert(i, e)
	if top.size() > n:
		top.pop_back()


static func _entry(name: String, seasons: Array) -> Dictionary:
	var e := {"name": name, "teams": [], "att": 0, "made": 0, "xp": 0, "b": [0, 0, 0, 0, 0], "long": 0,
		"seasons": seasons.size(), "first_year": 0, "years": "", "mine": false}
	var y0 := 99999
	var y1 := 0
	for s in seasons:
		e["att"] += int(s["att"])
		e["made"] += int(s["made"])
		e["xp"] += int(s["xp"])
		e["long"] = maxi(int(e["long"]), int(s["long"]))
		if (e["b"] as Array).size() == 5 and (s["b"] as Array).size() == 5:
			for i in 5:
				e["b"][i] += int(s["b"][i])
		else:
			e["b"] = []
		if not (s["team"] in e["teams"]):
			e["teams"].append(s["team"])
		y0 = mini(y0, int(s["year"]))
		y1 = maxi(y1, int(s["year"]))
	e["first_year"] = y0
	e["years"] = str(y0) if y0 == y1 else "%d-%d" % [y0, y1]
	var v := PackedFloat64Array()
	for cat in CATS:
		v.append(_value(e, cat))
	e["v"] = v
	return e


## The fictional book's lists for a scope: {"span|cat": [entries]} (cached).
## Fast path: a candidate (a season, or a career's seasons in the scope) only
## becomes an entry when one of its values reaches a list's cutoff.
static func baseline(level: String, key: String) -> Dictionary:
	var ck := "%s|%s" % [level, key]
	if _cache.has(ck):
		return _cache[ck]
	var tops := {}
	var cuts := {}
	for span in SPANS:
		var arr: Array = []
		for cat in CATS:
			arr.append([])
		tops[span] = arr
		cuts[span] = [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0]  # an Array: shared, not copied
	var in_scope := {}
	for t in record_teams(level):
		if team_in(t, key):
			in_scope[str(t["id"])] = true
	var done := {}
	for tid in in_scope:
		for p in team_players(level, tid):
			if done.has(p["name"]):
				continue
			done[p["name"]] = true  # names are unique in the book
			var here: Array = []
			var c := PackedInt32Array([0, 0, 0, 0, 0, 0, 0, 0, 0])  # att, made, xp, b0..b4, long
			for st in p["seasons"]:
				if not in_scope.has(st["team"]):
					continue
				here.append(st)
				var b: Array = st["b"]
				_consider(level, SEASON, tops, cuts, p["name"], [st], int(st["att"]), int(st["made"]), int(st["xp"]),
					b, int(st["long"]))
				c[0] += int(st["att"])
				c[1] += int(st["made"])
				c[2] += int(st["xp"])
				for i in 5:
					c[3 + i] += int(b[i])
				c[8] = maxi(c[8], int(st["long"]))
			if not here.is_empty():
				_consider(level, CAREER, tops, cuts, p["name"], here, c[0], c[1], c[2],
					[c[3], c[4], c[5], c[6], c[7]], c[8])
	var lists := {}
	for span in SPANS:
		for i in CATS.size():
			lists["%s|%s" % [span, CATS[i]]] = tops[span][i]
	_cache[ck] = lists
	return lists


static func _consider(level: String, span: String, tops: Dictionary, cuts: Dictionary, name: String,
		seasons: Array, att: int, made: int, xp: int, b: Array, long_yd: int) -> void:
	var v := [float(made) / float(att) if att > 0 else 0.0, float(att), float(made), float(xp),
		float(3 * made + xp), float(b[0]), float(b[1]), float(b[2]), float(b[3]), float(b[4]), float(long_yd)]
	var cut: Array = cuts[span]
	var arr: Array = tops[span]
	var e := {}
	for i in CATS.size():
		if i == 0:
			if att < min_att(level, span):
				continue
		elif float(v[i]) <= 0.0:
			continue
		if float(v[i]) < float(cut[i]) - 0.0000001:
			continue
		if e.is_empty():
			e = _entry(name, seasons)
		var top: Array = arr[i]
		var n := list_size(span, CATS[i])
		_offer(top, e, n, CATS[i])
		if top.size() >= n:
			cut[i] = value(top[top.size() - 1], CATS[i])


## Forget cached lists (tests; after the data file changes).
static func clear_cache() -> void:
	_cache.clear()
	_players.clear()
	_book = {}


# --- your kicker --------------------------------------------------------------------------

## The calendar year of your first season: the year the career began.
static func start_year(c: CareerData) -> int:
	var t := c.created if c.created > 0 else int(Time.get_unix_time_from_system())
	return int(Time.get_datetime_dict_from_unix_time(t)["year"])


static func year_of(c: CareerData, season: int) -> int:
	return start_year(c) + season - 1


## Your record-book seasons at a level, oldest first:
## [{season, year, team, att, made, xp, b, long, current}]. Junior college and
## seasons without a known team or a kick are left out.
static func my_seasons(c: CareerData, level: String) -> Array:
	var out: Array = []
	for r in CareerRecords.seasons(c, level):
		if str(r.get("stage", "")) in [CareerData.STAGE_JUCO, CareerData.STAGE_FREE_AGENT]:
			continue
		var tid := _season_team(c, r)
		var st: Dictionary = r["stats"]
		if tid == "" or int(st.get("fg_att", 0)) + int(st.get("pat_att", 0)) == 0:
			continue
		var b: Array = []
		if CareerRecords.logged_complete(c, [r]):
			var sm := CareerRecords.kick_summary(c.kick_log.filter(func(e: Dictionary) -> bool:
				return int(e.get("season", -1)) == int(r["season"])))
			b = (sm["buckets"] as Array).map(func(x: Dictionary) -> int: return int(x["made"]))
		out.append({"season": int(r["season"]), "year": year_of(c, int(r["season"])), "team": tid,
			"att": int(st.get("fg_att", 0)), "made": int(st.get("fg_made", 0)), "xp": int(st.get("pat_made", 0)),
			"b": b, "long": int(st.get("long", 0)), "current": bool(r.get("current", false))})
	return out


## A season row's team id: saved with the season (version 10), else the team
## of that name, else (the season in progress) your team.
static func _season_team(c: CareerData, r: Dictionary) -> String:
	if bool(r.get("current", false)):
		return str(c.team.get("id", ""))
	for h in c.history:
		if int(h.get("season", -1)) == int(r["season"]):
			if str(h.get("team_id", "")) != "":
				return str(h["team_id"])
	return team_id_by_name(str(r.get("team", "")))


static func team_id_by_name(name: String) -> String:
	if name == "":
		return ""
	for lv in LEVELS:
		for t in TeamDatabase.teams(lv):
			if str(t.get("name", "")) == name:
				return str(t["id"])
	return ""


## Your entries for one scope: every season there (SEASON) or the seasons
## there added up (CAREER, one entry). seasons: my_seasons(c, level), when the
## caller already has it.
static func my_entries(c: CareerData, level: String, key: String, span: String, seasons: Variant = null) -> Array:
	if c == null:
		return []
	var all: Array = seasons if seasons is Array else my_seasons(c, level)
	var mine := all.filter(func(s: Dictionary) -> bool:
		return team_in(TeamDatabase.team(str(s["team"])), key))
	var out: Array = []
	if span == SEASON:
		for s in mine:
			var e := _entry(c.display_name(), [s])
			e["mine"] = true
			e["season"] = s["season"]
			e["current"] = s["current"]
			out.append(e)
	elif not mine.is_empty():
		var e := _entry(c.display_name(), mine)
		e["mine"] = true
		e["current"] = (mine[mine.size() - 1] as Dictionary)["current"]
		out.append(e)
	return out


## A ranked list: the fictional book plus your entries (c may be null), best
## first, at most list_size entries. Ties share a rank (1, 2, 2, 4).
static func ranked(level: String, key: String, span: String, cat: String, c: CareerData = null,
		mine: Variant = null) -> Array:
	var top: Array = (baseline(level, key)["%s|%s" % [span, cat]] as Array).duplicate()
	var n := list_size(span, cat)
	for e in (mine if mine is Array else my_entries(c, level, key, span)):
		if eligible(e, level, span, cat):
			_offer(top, e, n, cat)
	var out: Array = []
	for i in top.size():
		var e: Dictionary = (top[i] as Dictionary).duplicate()
		var prev: Dictionary = out[i - 1] if i > 0 else {}
		e["value"] = value(e, cat)
		e["rank"] = int(prev["rank"]) if i > 0 and is_equal_approx(float(prev["value"]), float(e["value"])) else i + 1
		out.append(e)
	return out


## "18", "91.7%", "66 yd".
static func value_text(v: float, cat: String) -> String:
	if cat == "fg_pct":
		return "%.1f%%" % (v * 100.0)
	if cat == "long":
		return "%d yd" % int(v)
	return str(int(v))


## Where you stand on a list: {have (bool), value, rank (0 = not on it),
##  next_gap (to pass the entry above; 0 when #1), record_gap (to pass #1;
##  0 when you hold it), eligible (FG%: enough attempts), text}.
static func standing(level: String, key: String, span: String, cat: String, c: CareerData) -> Dictionary:
	var mine := my_entries(c, level, key, span)
	if mine.is_empty():
		return {"have": false, "text": "No %s yet." % ("seasons here" if span == SEASON else "career here")}
	var best: Dictionary = mine[0]
	for e in mine:
		if ahead(e, best, cat):
			best = e
	var list := ranked(level, key, span, cat, c)
	var v := value(best, cat)
	var rank := 0
	for e in list:
		if e["mine"] and int(e.get("season", -1)) == int(best.get("season", -1)):
			rank = int(e["rank"])
			break
	var others := list.filter(func(e: Dictionary) -> bool: return not e["mine"])
	var out := {"have": true, "value": v, "rank": rank, "eligible": eligible(best, level, span, cat),
		"next_gap": 0.0, "record_gap": 0.0, "entry": best}
	var first: float = float(others[0]["value"]) if not others.is_empty() else 0.0
	if rank != 1:
		out["record_gap"] = maxf(first - v, 0.0)
		# The entry right above you (or the last one, when you're not on the list).
		var above := others.filter(func(e: Dictionary) -> bool: return float(e["value"]) > v + 0.0000001 \
			or (is_equal_approx(float(e["value"]), v) and not ahead(best, e, cat)))
		if not above.is_empty():
			out["next_gap"] = float(above[above.size() - 1]["value"]) - v
	out["text"] = gap_text(out, level, span, cat, list.size() >= list_size(span, cat))
	return out


## "7 more FGs to break the record", "You hold the record", ...
static func gap_text(st: Dictionary, level: String, span: String, cat: String, full: bool) -> String:
	if not st.get("have", false):
		return ""
	if cat == "fg_pct" and not st["eligible"]:
		return "Needs %d field goal attempts to qualify." % min_att(level, span)
	if int(st["rank"]) == 1:
		return "You hold the record."
	var gap := float(st["record_gap"])
	if cat == "fg_pct":
		return "%.1f%% behind the record." % (gap * 100.0)
	var unit: Array = CAT_UNITS.get(cat, ["", ""])
	var need := int(gap) + 1
	if int(st["rank"]) == 0 and full:
		var to_list := int(float(st["next_gap"])) + 1
		return "%d more %s to make the list; %d to break the record." % [to_list, unit[0] if to_list == 1 else unit[1], need]
	return "%d more %s to break the record." % [need, unit[0] if need == 1 else unit[1]]


# --- record events (saved) ------------------------------------------------------------------

## Checks your current level's lists (every scope your team is in) and
## records what changed in c.records:
##   "best":  list key (+ "|season" for single seasons) -> "entered" / "tie" / "record"
##   "held":  list keys where you're #1 now
##   "log":   every event (newest last, at most LOG_MAX)
## Returns the new events, best first. Called after every game (final =
## false: only records and ties, and not FG%, which can still change) and at
## the end of the season (final = true: everything, including "entered").
const LOG_MAX := 300
const STATE_RANK := {"": 0, "entered": 1, "tie": 2, "record": 3}


static func check(c: CareerData, final: bool) -> Array:
	var level := CareerRecords.level_of(c.stage)
	if c.stage in [CareerData.STAGE_JUCO, CareerData.STAGE_FREE_AGENT, CareerData.STAGE_RETIRED]:
		return []
	if not (c.records.get("best") is Dictionary):
		c.records["best"] = {}
	if not (c.records.get("log") is Array):
		c.records["log"] = []
	var events: Array = []
	var held: Array = (c.records.get("held", []) as Array).filter(func(k: Variant) -> bool:
		return not str(k).begins_with(level + "|"))
	var seasons := my_seasons(c, level)
	for key in scopes_of_team(level, str(c.team.get("id", ""))):
		for span in SPANS:
			var mine := my_entries(c, level, key, span, seasons)
			for cat in CATS:
				var list := ranked(level, key, span, cat, c, mine)
				var lkey := "%s|%s|%s|%s" % [level, key, span, cat]
				var holds := false
				for i in list.size():
					var e: Dictionary = list[i]
					if not e["mine"]:
						continue
					if int(e["rank"]) == 1:
						holds = true
					# Only your season in progress (or your career) can change now.
					if span == SEASON and not bool(e.get("current", false)) and not final:
						continue
					var ev := _event_for(c, list, i, level, key, span, cat, final)
					if not ev.is_empty():
						events.append(ev)
				if holds:
					held.append(lkey)
	c.records["held"] = held
	for ev in events:
		c.records["log"].append(ev)
	while (c.records["log"] as Array).size() > LOG_MAX:
		(c.records["log"] as Array).pop_front()
	events.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(STATE_RANK[a["kind"]]) > int(STATE_RANK[b["kind"]]))
	return events


static func _event_for(c: CareerData, list: Array, i: int, level: String, key: String, span: String,
		cat: String, final: bool) -> Dictionary:
	var e: Dictionary = list[i]
	if cat == "fg_pct" and not final:
		return {}
	var kind := "entered"
	if int(e["rank"]) == 1:
		# Tied with someone else at #1, or ahead of everyone.
		var tied := false
		for j in list.size():
			if j != i and int(list[j]["rank"]) == 1:
				tied = true
		kind = "tie" if tied else "record"
	if kind == "entered" and not final:
		return {}
	var lkey := "%s|%s|%s|%s" % [level, key, span, cat]
	var bkey := lkey + ("|%d" % int(e.get("season", 0)) if span == SEASON else "")
	var before := str(c.records["best"].get(bkey, ""))
	if int(STATE_RANK[kind]) <= int(STATE_RANK.get(before, 0)):
		return {}
	c.records["best"][bkey] = kind
	var size := list_size(span, cat)
	var scope := scope_name(level, key)
	var what := "%s, %s" % [CAT_NAMES[cat], SPAN_NAMES[span].to_lower()]
	var head: String = {"record": "NEW RECORD", "tie": "RECORD TIED", "entered": "Entered top %d" % size}[kind]
	return {"kind": kind, "level": level, "scope": key, "scope_name": scope, "scope_kind": kind_of(key),
		"span": span, "cat": cat, "value": float(e["value"]), "value_text": value_text(float(e["value"]), cat),
		"rank": int(e["rank"]), "size": size, "season": c.season, "week": c.week,
		"headline": head, "text": "%s: %s (%s), %s" % [head, what, scope, value_text(float(e["value"]), cat)]}


## List keys ("level|scope|span|cat") where you're #1, as of the last check.
static func held(c: CareerData) -> Array:
	return (c.records.get("held", []) as Array).duplicate()
