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
## Interest at which a school's tier starts making offers (Progression.school_interest).
const OFFER_INTEREST := 50.0
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

## Interest of one college in you, 0-100 (rules: Progression.school_interest,
## which also decides which school in a tier makes the offer).
static func school_interest(c: CareerData, school: Dictionary) -> float:
	return Progression.school_interest(c, school)


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
		var gpa_short := off.is_empty() and not Progression.gpa_ok(c, str(s.get("tier", "")))
		# At offer-level interest but no offer: the one-offer-per-tier (and
		# per-season) limits went to a school that wants you more, or it's too
		# early in high school for offers.
		out.append({"school": s, "interest": v, "word": interest_word(v), "offer": off,
			"gpa_short": gpa_short, "no_offer_yet": off.is_empty() and not gpa_short and v >= OFFER_INTEREST})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if not is_equal_approx(float(a["interest"]), float(b["interest"])):
			return float(a["interest"]) > float(b["interest"])
		if a["offer"].is_empty() != b["offer"].is_empty():
			return not a["offer"].is_empty()  # equal interest: the school that offered first
		return str(a["school"].get("name", "")) < str(b["school"].get("name", "")))
	return out


# --- kick log: distances, streaks, misc (save version 6) --------------------------------
# Built from CareerData.kick_log (every game kick since version 6). Totals that
# the season lines already keep (FG, XP, long, points, game winners, games)
# are always shown; stats that need single kicks (distance buckets, streaks,
# clutch kicks, kickoffs, onside) are "known" only when every kick of the
# scope was logged, and show "-" otherwise (seasons played before the update).

## Field goal distance buckets: [label, highest yard]. The first bucket also
## takes anything under 20 yards (not possible with the current tuning: the
## shortest field goal is 20 yards in high school, more at higher levels).
const BUCKETS := [["20-29", 29], ["30-39", 39], ["40-49", 49], ["50-59", 59], ["60+", 999]]


static func bucket_of(yards: int) -> int:
	for i in BUCKETS.size():
		if yards <= int(BUCKETS[i][1]):
			return i
	return BUCKETS.size() - 1


## Logged kicks of one level (all seasons, in kick order), optionally one season.
static func log_for(c: CareerData, level: String, season := -1) -> Array:
	return c.kick_log.filter(func(e: Dictionary) -> bool:
		return level_of(str(e.get("stage", ""))) == level and (season < 0 or int(e.get("season", -1)) == season))


## True when every field goal and extra point of these season rows is in the log.
static func logged_complete(c: CareerData, rows: Array) -> bool:
	for r in rows:
		var st: Dictionary = r["stats"]
		var want := int(st.get("fg_att", 0)) + int(st.get("pat_att", 0))
		var have := 0
		for e in c.kick_log:
			if int(e.get("season", -1)) == int(r["season"]) and str(e.get("kind", "")) in ["fg", "pat"]:
				have += 1
		if have != want:
			return false
	return true


## Everything the Stats screen shows from single kicks, for kicks in order:
## {buckets: [{made, att}] x5, fg_long, fg_cur, bucket_long [5], bucket_cur [5],
##  xp_long, xp_cur, clutch_made, clutch_att, kickoffs, touchbacks, carry_total,
##  onside_att, onside_rec}.
## Streaks: made field goals in a row (a miss ends it). A bucket's streak only
## sees kicks in that bucket; kicks elsewhere neither extend nor break it.
static func kick_summary(kicks: Array) -> Dictionary:
	var n := BUCKETS.size()
	var s := {"buckets": [], "fg_long": 0, "fg_cur": 0, "bucket_long": [], "bucket_cur": [],
		"xp_long": 0, "xp_cur": 0, "clutch_made": 0, "clutch_att": 0, "kickoffs": 0, "touchbacks": 0,
		"carry_total": 0, "onside_att": 0, "onside_rec": 0}
	for i in n:
		s["buckets"].append({"made": 0, "att": 0})
		s["bucket_long"].append(0)
		s["bucket_cur"].append(0)
	for e in kicks:
		var made := int(e.get("made", 0)) == 1
		match str(e.get("kind", "")):
			"fg":
				var b := bucket_of(int(e.get("yd", 0)))
				s["buckets"][b]["att"] += 1
				if made:
					s["buckets"][b]["made"] += 1
				s["fg_cur"] = int(s["fg_cur"]) + 1 if made else 0
				s["fg_long"] = maxi(int(s["fg_long"]), int(s["fg_cur"]))
				s["bucket_cur"][b] = int(s["bucket_cur"][b]) + 1 if made else 0
				s["bucket_long"][b] = maxi(int(s["bucket_long"][b]), int(s["bucket_cur"][b]))
				if int(e.get("clutch", 0)) == 1:
					s["clutch_att"] += 1
					if made:
						s["clutch_made"] += 1
			"pat":
				s["xp_cur"] = int(s["xp_cur"]) + 1 if made else 0
				s["xp_long"] = maxi(int(s["xp_long"]), int(s["xp_cur"]))
				if int(e.get("clutch", 0)) == 1:
					s["clutch_att"] += 1
					if made:
						s["clutch_made"] += 1
			"kickoff":
				s["kickoffs"] += 1
				s["carry_total"] += int(e.get("carry", 0))
				if int(e.get("tb", 0)) == 1:
					s["touchbacks"] += 1
			"onside":
				s["onside_att"] += 1
				if int(e.get("rec", 0)) == 1:
					s["onside_rec"] += 1
	return s


## The Stats screen's expanded numbers for one scope:
##   scope "season": this season (streak "current" = the level's live streak,
##                   which can carry over from last season).
##   a level:        that level's seasons; streaks run across its seasons.
##   "total":        all levels; streak = the best of the levels (each level
##                   starts fresh), current = the current level's.
## Returns {totals (season-line totals), known (single-kick stats complete),
##  summary (kick_summary), cur_known (current streaks shown), playing (bool)}.
static func expanded(c: CareerData, scope: String) -> Dictionary:
	var cur_level := level_of(c.stage)
	var playing := current_season_open(c)
	var out := {}
	match scope:
		"season":
			var row := {"season": c.season, "stats": this_season(c)}
			out["totals"] = row["stats"]
			out["known"] = logged_complete(c, [row])
			out["summary"] = kick_summary(c.kick_log.filter(func(e: Dictionary) -> bool:
				return int(e.get("season", -1)) == c.season))
			var lv_rows := seasons(c, cur_level)
			out["cur_known"] = logged_complete(c, lv_rows)
			var live := kick_summary(log_for(c, cur_level))
			out["summary"]["fg_cur"] = live["fg_cur"]
			out["summary"]["bucket_cur"] = live["bucket_cur"]
			out["summary"]["xp_cur"] = live["xp_cur"]
			out["playing"] = playing
		"total":
			var all_rows: Array = []
			var known := true
			var best := kick_summary([])
			for lv in LEVELS:
				var rows := seasons(c, lv)
				if rows.is_empty():
					continue
				all_rows.append_array(rows)
				known = known and logged_complete(c, rows)
				var s := kick_summary(log_for(c, lv))
				best["fg_long"] = maxi(int(best["fg_long"]), int(s["fg_long"]))
				best["xp_long"] = maxi(int(best["xp_long"]), int(s["xp_long"]))
				for i in BUCKETS.size():
					best["bucket_long"][i] = maxi(int(best["bucket_long"][i]), int(s["bucket_long"][i]))
			# Counts over the whole log; streak "current" from the current level.
			var whole := kick_summary(c.kick_log)
			for k in ["buckets", "clutch_made", "clutch_att", "kickoffs", "touchbacks", "carry_total",
					"onside_att", "onside_rec"]:
				best[k] = whole[k]
			var live := kick_summary(log_for(c, cur_level))
			best["fg_cur"] = live["fg_cur"]
			best["bucket_cur"] = live["bucket_cur"]
			best["xp_cur"] = live["xp_cur"]
			out["totals"] = total(all_rows)
			out["known"] = known and not all_rows.is_empty()
			out["summary"] = best
			out["cur_known"] = out["known"]
			out["playing"] = playing
		_:
			var rows := seasons(c, scope)
			out["totals"] = total(rows)
			out["known"] = logged_complete(c, rows) and not rows.is_empty()
			out["summary"] = kick_summary(log_for(c, scope))
			out["cur_known"] = out["known"]
			# "Current" streaks only for the level you're playing now.
			out["playing"] = playing and scope == cur_level
	return out
