class_name Relationships
extends RefCounted
## The recurring cast: head coach, your teammates (Team standing), holder,
## teacher, best friend, Tyler Brooks, Dad, your little brother and someone
## special (data/career/people.json).
##
## Each person is CareerData.people[id] = {name, value 0..100, known, week_change,
## stage, team (Tyler only)}; story flags stay in CareerData.flags. Scenario
## choices change values ("rel": {coach: 5}), scenarios can require them
## (min/max "rel_coach"), and values feed back into the game:
##   game day   coach (pressure, how far the coach lets you try), team
##              (pressure), holder (aim),
##              Tyler (friend: calmer; playing his team: pressure either way)
##   weekly     Dad / brother (energy), best friend / someone special (fun,
##              social), Tyler as a rival (football growth)
##   season     teacher (GPA)
##   recruiting final season coach recommendation (trust: coach + team),
##              teacher vouching (GPA minimums); draft: trust every college season
## Coach and Team also move with every kick you take (KickTrust).
## Every effect is zero at 50 (the start), so a career nobody has moved plays
## exactly as before. Numbers: CareerTuning "Relationships".
##
## Coach, holder and teacher are per stage: a new person when you move on
## (the old one goes to CareerData.former_people). Tyler Brooks follows his own
## path: a college when high school ends, a pro club when college ends.
## Names and Tyler's path use their own random numbers (seeded from the
## career), never the career's rng, so they can't change anything else.

const FILE := "people.json"
const NEUTRAL := 50.0
const TYLER := "rival"
const TEAM := "team"


static func defs() -> Array:
	return CareerContent.file(FILE).get("people", [])


static func def(id: String) -> Dictionary:
	for d in defs():
		if str(d.get("id", "")) == id:
			return d
	return {}


static func ids() -> Array:
	return defs().map(func(d: Dictionary) -> String: return str(d.get("id", "")))


## Free agents and retired players keep their pro cast.
static func _cast_stage(stage: String) -> String:
	return CareerData.STAGE_PRO if stage in [CareerData.STAGE_FREE_AGENT, CareerData.STAGE_RETIRED] else stage


static func in_stage(d: Dictionary, stage: String) -> bool:
	var st: Array = d.get("stages", [])
	return st.is_empty() or _cast_stage(stage) in st


# --- reading ------------------------------------------------------------------------

static func in_cast(c: CareerData, id: String) -> bool:
	return c.people.has(id)


static func value(c: CareerData, id: String) -> float:
	return float(c.people.get(id, {}).get("value", NEUTRAL))


static func known(c: CareerData, id: String) -> bool:
	return bool(c.people.get(id, {}).get("known", false))


static func name_of(c: CareerData, id: String) -> String:
	return str(c.people.get(id, {}).get("name", def(id).get("role", id)))


## The person's role this stage ("Head Coach", "Special Teams Coach", ...).
static func role(c: CareerData, id: String) -> String:
	var d := def(id)
	return str(d.get("roles", {}).get(_cast_stage(c.stage), d.get("role", id)))


## -1 (at 0) .. 0 (at 50) .. +1 (at 100). 0 for someone not in the cast now.
static func lean(c: CareerData, id: String) -> float:
	if not c.people.has(id):
		return 0.0
	return clampf((value(c, id) - NEUTRAL) / NEUTRAL, -1.0, 1.0)


## "Close", "Friendly Rival"...: the highest tier whose min the value reaches.
static func tier(c: CareerData, id: String) -> String:
	var tiers: Array = def(id).get("tiers", CareerContent.file(FILE).get("tiers", []))
	var v := value(c, id)
	var out := ""
	for t in tiers:
		if v >= float(t.get("min", 0)):
			out = str(t.get("label", ""))
	return out


## {coach: "Coach Vance", holder: ..., tyler: "Tyler Brooks", ...} for {placeholders}
## in scenario text (CareerContent.fill).
static func text_vars(c: CareerData) -> Dictionary:
	var out := {}
	for d in defs():
		var id := str(d.get("id", ""))
		out[id] = name_of(c, id) if c.people.has(id) else str(d.get("role", id))
	out["tyler"] = name_of(c, TYLER)
	# Your team and its town: {club} (the school in high school and college,
	# the club in the pros), {town}.
	out["club"] = str(c.team.get("name", ""))
	out["town"] = str(c.team.get("town", ""))
	return out


# --- the cast -------------------------------------------------------------------------

## Adds everyone missing for the career's current stage (new careers, new
## stages, and old saves from before relationships).
static func seed_cast(c: CareerData, t: CareerTuning) -> void:
	for d in defs():
		var id := str(d.get("id", ""))
		if c.people.has(id) or not in_stage(d, c.stage):
			continue
		var r := _rng(c, "%s:%s:%d" % [id, _cast_stage(c.stage), c.season])
		c.people[id] = {"name": _make_name(d, r), "value": t.rel_start,
			"known": bool(d.get("known_at_start", true)), "week_change": 0.0,
			"stage": _cast_stage(c.stage)}


## A new stage: per-stage people (and anyone who doesn't exist there) move to
## former_people (if you knew them), and the new stage's people arrive.
static func enter_stage(c: CareerData, t: CareerTuning) -> void:
	for d in defs():
		var id := str(d.get("id", ""))
		if not c.people.has(id):
			continue
		if d.get("per_stage", false) or not in_stage(d, c.stage):
			var p: Dictionary = c.people[id]
			if bool(p.get("known", false)):
				c.former_people.append({"id": id, "name": str(p.get("name", "")),
					"value": float(p.get("value", NEUTRAL)), "stage": str(p.get("stage", "")),
					"role": str(d.get("roles", {}).get(str(p.get("stage", "")), d.get("role", id)))})
			c.people.erase(id)
	seed_cast(c, t)


## A choice's "recast": [ids]: someone new takes this role (the pro story's
## "Someone New" for love_interest). The current person moves to former_people
## (if you knew them); the new one is known, a little above neutral
## (rel_recast_start), and {id} names them from then on.
static func recast(c: CareerData, ids: Array, t: CareerTuning) -> Array:
	var out: Array = []
	for raw in ids:
		var id := str(raw)
		var d := def(id)
		if d.is_empty():
			push_warning("Relationships: can't recast unknown person '%s'" % id)
			continue
		var old_name := ""
		if c.people.has(id):
			var p: Dictionary = c.people[id]
			old_name = str(p.get("name", ""))
			if bool(p.get("known", false)):
				c.former_people.append({"id": id, "name": old_name,
					"value": float(p.get("value", NEUTRAL)), "stage": str(p.get("stage", "")),
					"role": str(d.get("roles", {}).get(str(p.get("stage", "")), d.get("role", id)))})
		var n := int(c.flags.get("recast_" + id, 0)) + 1
		c.flags["recast_" + id] = n
		var name := old_name
		for attempt in 8:  # a different name than the person before
			name = _make_name(d, _rng(c, "recast:%s:%d:%d" % [id, n, attempt]))
			if name != old_name:
				break
		c.people[id] = {"name": name, "value": t.rel_recast_start, "known": true, "week_change": 0.0,
			"stage": _cast_stage(c.stage)}
		out.append(id)
	return out


## Applies a choice's "rel" {id: change}. Returns what actually moved {id: change}.
## Someone not in the cast right now (a teacher in the pros) is skipped.
static func apply(c: CareerData, rel: Dictionary) -> Dictionary:
	var out := {}
	for id in rel:
		if not c.people.has(id):
			continue
		var p: Dictionary = c.people[id]
		var old := float(p.get("value", NEUTRAL))
		var v := clampf(old + float(rel[id]), 0.0, 100.0)
		p["value"] = v
		p["known"] = true
		p["week_change"] = float(p.get("week_change", 0.0)) + v - old
		if v != old:
			out[id] = v - old
	return out


# --- effects ------------------------------------------------------------------------

## Kick profile lines for this week: [[label, effects], ...]. Only non-zero
## ones, so a neutral cast adds nothing (KickProfile.build, step 5b).
static func profile_lines(c: CareerData, t: CareerTuning) -> Array:
	var out: Array = []
	var k := lean(c, "coach")
	if k != 0.0:
		out.append(["%s %s" % [name_of(c, "coach"), "believes in you" if k > 0.0 else "has doubts"],
			{"pressure_sensitivity": t.rel_coach_pressure * k}])
	k = lean(c, TEAM)
	if k != 0.0:
		out.append(["Your teammates %s" % ("trust you" if k > 0.0 else "have doubts"),
			{"pressure_sensitivity": t.rel_team_pressure * k * (1.0 + Perks.total(c, "team_pressure"))}])
	k = lean(c, "holder")
	if k != 0.0:
		out.append(["%s's holds" % name_of(c, "holder"), {"accuracy_spread_deg": t.rel_holder_spread * k}])
	if known(c, TYLER):
		k = lean(c, TYLER)
		if k > 0.0:
			out.append(["%s has your back" % name_of(c, TYLER),
				{"pressure_sensitivity": t.rel_tyler_friend_pressure * k}])
		if k != 0.0 and _facing_tyler(c):
			var fx := {"pressure_add": t.rel_tyler_game_pressure * -k} if k < 0.0 else \
				{"pressure_sensitivity": -t.rel_tyler_game_pressure * k}
			out.append(["Facing %s" % name_of(c, TYLER), fx])
	return out


## Yards the coach relationship adds to (or takes from) his longest call.
static func coach_range_yd(c: CareerData, t: CareerTuning) -> float:
	return t.rel_coach_range_yd * lean(c, "coach")


## Trust (0..100): the coach's word, backed by the locker room.
static func trust(c: CareerData, t: CareerTuning) -> float:
	var w := t.rel_trust_coach_weight
	return value(c, "coach") * w + value(c, TEAM) * (1.0 - w)


## Stat changes added to the end-of-week growth: {stat: change}, non-zero only.
static func weekly_growth(c: CareerData, t: CareerTuning) -> Dictionary:
	var g := {}
	for id in ["parent", "sibling"]:
		_add(g, "energy", t.rel_family_energy * lean(c, id))
	for id in ["best_friend", "love_interest"]:
		if known(c, id):
			_add(g, "fun", t.rel_friend_fun * lean(c, id))
			_add(g, "social", t.rel_friend_social * lean(c, id))
	_add(g, "social", t.rel_team_social * lean(c, TEAM))
	if known(c, TYLER) and lean(c, TYLER) < 0.0:
		for s in CareerData.GROUP_KEYS[CareerData.FOOTBALL]:
			_add(g, s, t.rel_tyler_rival_growth * -lean(c, TYLER))
	return g


## End of week: everyone drifts a little toward 50; this week's changes reset.
static func end_week(c: CareerData, t: CareerTuning) -> void:
	for id in c.people:
		var p: Dictionary = c.people[id]
		var v := float(p.get("value", NEUTRAL))
		p["value"] = v + (NEUTRAL - v) * t.rel_weekly_drift
		p["week_change"] = 0.0


## GPA points from the teacher this season.
static func teacher_gpa(c: CareerData, t: CareerTuning) -> float:
	return t.rel_teacher_gpa * lean(c, "teacher")


## Added to your GPA when checking a college's minimum (a teacher who vouches).
static func teacher_grace(c: CareerData, t: CareerTuning) -> float:
	return t.rel_teacher_gpa_grace if c.people.has("teacher") and value(c, "teacher") >= t.rel_teacher_vouch else 0.0


## Coach's recommendation in the final recruiting season: + bonus, - penalty, or 0.
static func coach_recommendation(c: CareerData, t: CareerTuning) -> float:
	if not c.people.has("coach"):
		return 0.0
	var v := trust(c, t)
	if v >= t.rel_rec_high:
		return t.rel_rec_bonus
	if v <= t.rel_rec_low:
		return -t.rel_rec_penalty
	return 0.0


## Draft points from the coach's word this college season: +/- rel_draft_rec,
## linear from 50 (trust).
static func draft_recommendation(c: CareerData, t: CareerTuning) -> float:
	if not c.people.has("coach"):
		return 0.0
	return t.rel_draft_rec * clampf((trust(c, t) - NEUTRAL) / NEUTRAL, -1.0, 1.0)


## Skill points per week from a rival Tyler (below 50, once you know him).
static func rival_sp(c: CareerData, t: CareerTuning) -> int:
	if not known(c, TYLER) or lean(c, TYLER) >= 0.0:
		return 0
	return roundi(t.rel_tyler_rival_sp * -lean(c, TYLER))


static func _add(g: Dictionary, k: String, v: float) -> void:
	if v != 0.0:
		g[k] = float(g.get(k, 0.0)) + v


# --- Tyler Brooks -------------------------------------------------------------------

## Tyler's team: {id, name, short, stage} or {} (still in high school).
static func tyler_team(c: CareerData) -> Dictionary:
	return c.people.get(TYLER, {}).get("team", {})


## Tyler moves on: "college" when high school ends, "pro" when college ends.
## His school is picked by his own talent (top / mid / small tier), so you
## may or may not end up together.
static func advance_tyler(c: CareerData, next_stage: String) -> void:
	if not c.people.has(TYLER):
		return
	var r := _rng(c, "tyler:" + next_stage)
	var pool: Array
	if next_stage == CareerData.STAGE_COLLEGE:
		var talent := r.randf()
		var tier_id := "top" if talent > 0.75 else ("mid" if talent > 0.25 else "small")
		pool = TeamDatabase.colleges().filter(func(s: Dictionary) -> bool: return s.get("tier", "") == tier_id)
	else:
		pool = TeamDatabase.pro_teams()
	if pool.is_empty():
		return
	var s: Dictionary = pool[r.randi_range(0, pool.size() - 1)]
	c.people[TYLER]["team"] = {"id": str(s.get("id", "")), "name": str(s.get("name", "")),
		"short": str(s.get("short", "")), "stage": next_stage}


## Old saves past high school: give Tyler the steps he'd have taken.
static func catch_up_tyler(c: CareerData) -> void:
	if not c.people.has(TYLER) or not tyler_team(c).is_empty():
		return
	if c.stage in [CareerData.STAGE_JUCO, CareerData.STAGE_COLLEGE]:
		advance_tyler(c, CareerData.STAGE_COLLEGE)
	elif c.stage in [CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT, CareerData.STAGE_RETIRED]:
		advance_tyler(c, CareerData.STAGE_PRO)


## Is Tyler's team on the other sideline this week?
static func _facing_tyler(c: CareerData) -> bool:
	var tt := tyler_team(c)
	if tt.is_empty() or str(tt.get("id", "")) == str(c.team.get("id", "")):
		return false
	for e in c.schedule:
		if int(e.get("week", 0)) == c.week:
			return str(e.get("opponent", {}).get("id", "")) == str(tt.get("id", ""))
	return false


## Once you know Tyler and he's at your level on another team, make sure his
## team is on your schedule (the last regular opponent is swapped for his).
static func schedule_tyler(c: CareerData, schedule: Array) -> void:
	var tt := tyler_team(c)
	if not known(c, TYLER) or tt.is_empty() or str(tt.get("stage", "")) != _cast_stage(c.stage) \
			or str(tt.get("id", "")) == str(c.team.get("id", "")):
		return
	var last := -1
	for i in schedule.size():
		if str(schedule[i].get("type", "")) != "regular":
			continue
		if str(schedule[i].get("opponent", {}).get("id", "")) == str(tt["id"]):
			return
		last = i
	var team := TeamDatabase.team(str(tt["id"]))
	if last >= 0 and not team.is_empty():
		schedule[last]["opponent"] = Progression.team_from(team, c.stage)


# --- internals ----------------------------------------------------------------------

static func _rng(c: CareerData, salt: String) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = hash("%d|%s|%s" % [c.created, str(c.player.get("name", "")), salt])
	return r


static func _make_name(d: Dictionary, r: RandomNumberGenerator) -> String:
	var n: Dictionary = d.get("name", {})
	if n.has("fixed"):
		return str(n["fixed"])
	var names: Dictionary = CareerContent.world().get("names", {})
	var first: Array = names.get("first", ["Sam"])
	var last: Array = names.get("last", ["Smith"])
	var pick := func(a: Array) -> String: return str(a[r.randi_range(0, a.size() - 1)])
	match str(n.get("style", "full")):
		"coach":
			return "Coach " + pick.call(last)
		"first":
			return pick.call(first)
		"list":
			var lst: Array = CareerContent.file(FILE).get("names", {}).get(str(d.get("id", "")), [])
			return pick.call(lst) if not lst.is_empty() else pick.call(first)
	return "%s %s" % [pick.call(first), pick.call(last)]


## Problems in people.json (CareerContent.validate()).
static func problems() -> PackedStringArray:
	var out := PackedStringArray()
	var seen := {}
	for d in defs():
		var id := str(d.get("id", ""))
		if id == "" or seen.has(id):
			out.append("people: missing or duplicate id '%s'" % id)
		seen[id] = true
		if not UiIcons.has(str(d.get("icon", ""))):
			out.append("people %s: unknown icon '%s'" % [id, d.get("icon", "")])
		var n: Dictionary = d.get("name", {})
		if not n.has("fixed") and not (str(n.get("style", "")) in ["coach", "full", "first", "list"]):
			out.append("people %s: name needs fixed or style coach/full/first/list" % id)
		for st in d.get("stages", []):
			if not (st in CareerData.STAGES):
				out.append("people %s: unknown stage '%s'" % [id, st])
		var prev := -1.0
		for t in d.get("tiers", CareerContent.file(FILE).get("tiers", [])):
			if float(t.get("min", 0)) <= prev:
				out.append("people %s: tiers must go up" % id)
			prev = float(t.get("min", 0))
	return out
