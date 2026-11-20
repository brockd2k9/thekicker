class_name CareerRecords
extends RefCounted
## Read-only views of a career for the Stats and Recruiting screens:
##   * kicking stats per level (High School / College / Pro), season by season,
##     built from CareerData.history (every finished season keeps its stage and
##     kicking line) plus the season in progress. No extra save data: old saves
##     already have it, so they show their full record.
##   * how interested each college is, from the same rules that make offers
##     (Progression.offer_type: your recruiting points against each tier's bar).
## Nothing here changes the career.

const LEVEL_HS := "high_school"
const LEVEL_COLLEGE := "college"
const LEVEL_PRO := "pro"
const LEVELS := [LEVEL_HS, LEVEL_COLLEGE, LEVEL_PRO]
const LEVEL_NAMES := {LEVEL_HS: "High School", LEVEL_COLLEGE: "College", LEVEL_PRO: "Pro"}
const LEVEL_SHORT := {LEVEL_HS: "HS", LEVEL_COLLEGE: "College", LEVEL_PRO: "Pro"}

## Interest words, by minimum interest (0-100).
const INTEREST_WORDS := [[80, "Recruiting hard"], [60, "Very interested"], [40, "Interested"],
	[20, "Watching"], [0, "Not yet"]]
## Schools below this interest (and without an offer) aren't listed.
const LIST_MIN_INTEREST := 15.0


# --- kicking stats ----------------------------------------------------------------------

## Stage -> level. Junior college counts as College; free agency as Pro.
static func level_of(stage: String) -> String:
	match stage:
		CareerData.STAGE_JUCO, CareerData.STAGE_COLLEGE:
			return LEVEL_COLLEGE
		CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT:
			return LEVEL_PRO
	return LEVEL_HS


## True while the season in progress isn't in history yet (it is added at the
## season summary; until the next season starts season_stats still holds it).
static func current_season_open(c: CareerData) -> bool:
	if c.stage in [CareerData.STAGE_RETIRED, CareerData.STAGE_FREE_AGENT]:
		return false
	if not c.history.is_empty():
		var last: Dictionary = c.history[c.history.size() - 1]
		if int(last.get("season", -1)) == c.season:
			return false
	return true


## Season rows for one level (oldest first):
## {season, year, stage, team, record {w,l,t}, stats, current (bool)}.
static func seasons(c: CareerData, level: String) -> Array:
	var out: Array = []
	for h in c.history:
		if level_of(str(h.get("stage", ""))) != level:
			continue
		out.append({"season": int(h.get("season", 0)), "year": str(h.get("year", "")),
			"stage": str(h.get("stage", "")), "team": str(h.get("team", "")),
			"record": _record(h.get("record", {})), "stats": CareerData._totals(h.get("stats", {})),
			"current": false})
	if current_season_open(c) and level_of(c.stage) == level:
		out.append({"season": c.season, "year": "", "stage": c.stage, "team": str(c.team.get("name", "")),
			"record": _record(c.record), "stats": CareerData._totals(c.season_stats), "current": true})
	return out


## Sum of season rows' stats (longest = the best single long).
static func total(rows: Array) -> Dictionary:
	var t := CareerData.empty_kick_totals()
	for r in rows:
		var s: Dictionary = r["stats"]
		for k in t:
			if k == "long":
				t[k] = maxi(int(t[k]), int(s.get(k, 0)))
			else:
				t[k] = int(t[k]) + int(s.get(k, 0))
	return t


## Win-loss-tie over season rows.
static func total_record(rows: Array) -> Dictionary:
	var r := {"w": 0, "l": 0, "t": 0}
	for row in rows:
		for k in r:
			r[k] += int(row["record"].get(k, 0))
	return r


## The season in progress (zeros before the first game; also after the season
## summary until the next season starts, showing the season just finished).
static func this_season(c: CareerData) -> Dictionary:
	return CareerData._totals(c.season_stats)


static func pct_text(stats: Dictionary) -> String:
	return ("%d%%" % roundi(Progression.fg_pct(stats) * 100.0)) if int(stats.get("fg_att", 0)) > 0 else "-"


static func record_text(r: Dictionary) -> String:
	return "%d-%d%s" % [int(r.get("w", 0)), int(r.get("l", 0)),
		("-%d" % int(r["t"])) if int(r.get("t", 0)) > 0 else ""]


static func _record(r: Variant) -> Dictionary:
	var d: Dictionary = r if r is Dictionary else {}
	return {"w": int(d.get("w", 0)), "l": int(d.get("l", 0)), "t": int(d.get("t", 0))}


# --- recruiting -------------------------------------------------------------------------

## Interest of one college in you, 0-100. 50 is where its tier starts making
## offers (Progression.offer_type: recruiting points == the tier's minimum),
## +/- 2.5 per recruiting point, plus a small fixed per-school lean so schools
## in the same tier differ. An offer keeps a school at least at the matching
## interest; a GPA below the tier's minimum caps it (they can't offer).
static func school_interest(c: CareerData, school: Dictionary) -> float:
	var tier_id := str(school.get("tier", "small"))
	var tr := Progression.tier(tier_id)
	var margin := c.recruiting_score - float(tr.get("min_recruiting", 100))
	var lean := float(absi(hash("%s|%d" % [school.get("id", ""), c.created])) % 13) - 6.0
	var v := 50.0 + margin * 2.5 + lean
	var off := offer_from(c, str(school.get("id", "")))
	if not off.is_empty():
		v = maxf(v, {"full": 85.0, "partial": 65.0, "walk_on": 45.0}.get(str(off.get("type", "")), 45.0))
	elif not Progression.gpa_ok(c, tier_id):
		v = minf(v, 35.0)
	return clampf(v, 0.0, 100.0)


static func interest_word(v: float) -> String:
	for w in INTEREST_WORDS:
		if v >= float(w[0]):
			return str(w[1])
	return "Not yet"


static func offer_from(c: CareerData, school_id: String) -> Dictionary:
	for off in c.offers:
		if str(off.get("school", "")) == school_id:
			return off
	return {}


## Colleges with real interest (or an offer), most interested first:
## [{school, interest, word, offer, gpa_short}].
static func interested_schools(c: CareerData) -> Array:
	var out: Array = []
	for s in CareerContent.colleges():
		var v := school_interest(c, s)
		var off := offer_from(c, str(s.get("id", "")))
		if v < LIST_MIN_INTEREST and off.is_empty():
			continue
		out.append({"school": s, "interest": v, "word": interest_word(v), "offer": off,
			"gpa_short": off.is_empty() and not Progression.gpa_ok(c, str(s.get("tier", "")))})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if not is_equal_approx(float(a["interest"]), float(b["interest"])):
			return float(a["interest"]) > float(b["interest"])
		return str(a["school"].get("name", "")) < str(b["school"].get("name", "")))
	return out
