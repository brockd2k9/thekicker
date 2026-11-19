class_name Perks
extends RefCounted
## Perks: on-field abilities bought with skill points (data/career/perks.json).
## Each has a cost and prerequisites (attribute or personality thresholds,
## other perks, personality traits, stage, age) and a small effect. Called
## "Perks" so they aren't confused with personality traits (traits.json).
##
## Effects are read where they apply: KickProfile (profile fields, bad
## weather), KickRange (range_yd, kickoff_yd), KickTrust (trust_miss,
## team_miss), Relationships (team_pressure), CareerGameMode.kickoff_rules_for
## (onside, returns), the coach's limit (coach_range_yd), CareerManager (clutch
## pressure, injuries) and Aging (aging). All numbers live in the data file.

const FILE := "perks.json"


static func defs() -> Array:
	return CareerContent.file(FILE).get("perks", [])


static func def(id: String) -> Dictionary:
	for d in defs():
		if str(d.get("id", "")) == id:
			return d
	return {}


static func owned(c: CareerData, id: String) -> bool:
	return id in c.perks


static func effect(id: String) -> Dictionary:
	return def(id).get("effect", {})


## Sum of a numeric effect over the perks you own.
static func total(c: CareerData, key: String) -> float:
	var s := 0.0
	for id in c.perks:
		s += float(effect(str(id)).get(key, 0.0))
	return s


## Share of the cold / snow penalty you still take (1 = all of it).
static func weather_keep(c: CareerData) -> float:
	var k := 1.0
	for id in c.perks:
		var e := effect(str(id))
		if e.has("weather_keep"):
			k = minf(k, float(e["weather_keep"]))
	return k


## Extra profile effects in cold or snow.
static func bad_weather_fx(c: CareerData) -> Dictionary:
	var out := {}
	for id in c.perks:
		var bw: Dictionary = effect(str(id)).get("bad_weather", {})
		for k in bw:
			out[k] = float(out.get(k, 0.0)) + float(bw[k])
	return out


## Change to an attribute's yearly decline (-0.5 = half).
static func aging_change(c: CareerData, stat: String) -> float:
	var s := 0.0
	for id in c.perks:
		s += float(effect(str(id)).get("aging", {}).get(stat, 0.0))
	return s


## [{text, met}] for each prerequisite, for the Perks tab.
static func requirements(c: CareerData, d: Dictionary) -> Array:
	var out: Array = []
	var req: Dictionary = d.get("requires", {})
	var mins: Dictionary = req.get("min", {})
	for k in mins:
		out.append({"text": "%s %d" % [CareerData.STAT_NAMES.get(k, k), int(mins[k])],
			"met": c.stat(str(k)) >= float(mins[k])})
	for p in req.get("perks", []):
		out.append({"text": str(def(str(p)).get("name", p)), "met": owned(c, str(p))})
	for tr in req.get("traits", []):
		out.append({"text": "%s (trait)" % CareerContent.trait_def(str(tr)).get("name", tr), "met": c.has_trait(str(tr))})
	var stages: Array = req.get("stages", [])
	if not stages.is_empty():
		var names := PackedStringArray()
		for st in stages:
			if not (str(st) in ["juco", "free_agent"]):
				names.append(str(st).replace("_", " ").capitalize())
		out.append({"text": " or ".join(names), "met": c.stage in stages})
	if req.has("min_age"):
		out.append({"text": "Age %d+" % int(req["min_age"]), "met": c.age >= int(req["min_age"])})
	return out


static func requirements_met(c: CareerData, d: Dictionary) -> bool:
	return requirements(c, d).all(func(r: Dictionary) -> bool: return r["met"])


static func can_buy(c: CareerData, id: String) -> bool:
	var d := def(id)
	return not d.is_empty() and not owned(c, id) and requirements_met(c, d) \
		and c.skill_points >= int(d.get("cost", 0))


static func buy(c: CareerData, id: String) -> bool:
	if not can_buy(c, id):
		return false
	c.skill_points -= int(def(id).get("cost", 0))
	c.perks.append(id)
	return true


## Perk lines for the kick profile: [[name, profile effects], ...].
static func profile_lines(c: CareerData) -> Array:
	var out: Array = []
	for id in c.perks:
		var fx: Dictionary = effect(str(id)).get("profile", {})
		if not fx.is_empty():
			out.append([str(def(str(id)).get("name", id)), fx])
	return out


## Short "what it does" text for the Perks tab, from the effect numbers.
static func effect_text(d: Dictionary) -> String:
	var e: Dictionary = d.get("effect", {})
	var parts := PackedStringArray()
	if e.has("profile"):
		var w := KickProfile.describe(e["profile"])
		if w != "":
			parts.append(w)
	if e.has("range_yd"):
		parts.append("%+d yd field goal range" % int(e["range_yd"]))
	if e.has("kickoff_yd"):
		parts.append("%+d yd kickoff range" % int(e["kickoff_yd"]))
	if e.has("return_cut_yd"):
		parts.append("-%d yd kick returns" % int(e["return_cut_yd"]))
	if e.has("miss_streak"):
		parts.append("%d%% less miss-streak pressure" % roundi(-float(e["miss_streak"]) * 100.0))
	if e.has("trust_miss"):
		parts.append("misses cost %d%% less with Coach and Team" % roundi(-float(e["trust_miss"]) * 100.0))
	if e.has("team_miss"):
		parts.append("misses cost %d%% less with the Team" % roundi(-float(e["team_miss"]) * 100.0))
	if e.has("team_pressure"):
		parts.append("Team trust calms you %d%% more" % roundi(float(e["team_pressure"]) * 100.0))
	if e.has("clutch_pressure"):
		parts.append("%d%% less pressure on game-winning and tying kicks" % roundi(-float(e["clutch_pressure"]) * 100.0))
	if e.has("coach_range_yd"):
		parts.append("coach calls kicks %+d yd longer" % int(e["coach_range_yd"]))
	if e.has("onside_window_yd"):
		parts.append("bigger onside window, +%d%% recovery" % roundi(float(e.get("onside_recover", 0.0)) * 100.0))
	if e.has("weather_keep"):
		parts.append("cold and snow cost %d%% less" % roundi((1.0 - float(e["weather_keep"])) * 100.0))
	if e.has("injury_weeks"):
		parts.append("injuries heal %d week faster" % -int(e["injury_weeks"]))
	if e.has("injury_risk_mult"):
		parts.append("%d%% lower injury chance" % roundi(-float(e["injury_risk_mult"]) * 100.0))
	for st in e.get("aging", {}):
		parts.append("%s declines %d%% slower with age" % [CareerData.STAT_NAMES.get(st, st),
			roundi(-float(e["aging"][st]) * 100.0)])
	return ", ".join(parts)


## Problems in perks.json (CareerContent.validate()).
static func problems() -> PackedStringArray:
	var out := PackedStringArray()
	var seen := {}
	var known_fx := ["profile", "range_yd", "kickoff_yd", "miss_streak", "trust_miss", "team_miss",
		"team_pressure", "clutch_pressure", "coach_range_yd", "return_cut_yd", "onside_window_yd",
		"onside_aim_deg", "onside_recover", "weather_keep", "bad_weather", "injury_weeks",
		"injury_risk_mult", "aging"]
	for d in defs():
		var id := str(d.get("id", ""))
		if id == "" or seen.has(id):
			out.append("perks: missing or duplicate id '%s'" % id)
		seen[id] = true
		if int(d.get("cost", 0)) <= 0:
			out.append("perk %s: needs a cost" % id)
		if not UiIcons.has(str(d.get("icon", ""))):
			out.append("perk %s: unknown icon '%s'" % [id, d.get("icon", "")])
		var req: Dictionary = d.get("requires", {})
		for k in req.get("min", {}):
			if CareerData.group_of(str(k)) == "":
				out.append("perk %s: unknown stat '%s'" % [id, k])
		for p in req.get("perks", []):
			if def(str(p)).is_empty():
				out.append("perk %s: unknown perk '%s'" % [id, p])
		for tr in req.get("traits", []):
			if CareerContent.trait_def(str(tr)).is_empty():
				out.append("perk %s: unknown trait '%s'" % [id, tr])
		for st in req.get("stages", []):
			if not (st in CareerData.STAGES):
				out.append("perk %s: unknown stage '%s'" % [id, st])
		for k in d.get("effect", {}):
			if not (k in known_fx):
				out.append("perk %s: unknown effect '%s'" % [id, k])
		for k in d.get("effect", {}).get("profile", {}):
			if not (k in KickProfile.FIELDS):
				out.append("perk %s: unknown profile field '%s'" % [id, k])
	return out
