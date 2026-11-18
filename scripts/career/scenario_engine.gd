class_name ScenarioEngine
extends RefCounted
## Picks and applies off-field scenarios (data in data/career/scenarios_*.json;
## the field reference is the "_doc" at the top of scenarios_hs.json).
##
## pick() fills a week in this order:
##   1. follow-ups that are due (queued by an earlier choice)
##   2. story beats due now (guaranteed scenarios at a set season/week)
##   3. weighted random picks from the eligible pool
## Eligibility: stage, when (season/bye/offseason), week and season ranges,
## requirements (stats, traits, flags, any_of), one-time, cooldown, and the
## repetition guard (per-season cap). Weights shrink for a category each time
## it already appeared this season, and for social categories while Social is
## low. No two scenarios of the same category in one week.
## Numbers: CareerTuning "Scenario Picks".
## apply_choice(): stat changes through CareerStats (the same rules the screen
## previews), game-day modifiers, flags, follow-ups and the logs.

const CATEGORIES := ["social", "school", "training", "health", "work", "media", "family",
	"money", "team", "romance", "community", "career"]


# --- requirements -------------------------------------------------------------------

## requires: {min: {stat: n}, max: {stat: n}, traits: [all of], any_traits: [one of],
## flags: [set], not_flags: [unset], any_of: [requires, ...] (one must pass)}.
static func requirements_met(c: CareerData, req: Dictionary) -> bool:
	for k in req.get("min", {}):
		if c.stat(k) < float(req["min"][k]):
			return false
	for k in req.get("max", {}):
		if c.stat(k) > float(req["max"][k]):
			return false
	for t in req.get("traits", []):
		if not c.has_trait(str(t)):
			return false
	var any_t: Array = req.get("any_traits", [])
	if not any_t.is_empty() and not any_t.any(func(t: Variant) -> bool: return c.has_trait(str(t))):
		return false
	for f in req.get("flags", []):
		if not c.flags.get(str(f), false):
			return false
	for f in req.get("not_flags", []):
		if c.flags.get(str(f), false):
			return false
	var any_of: Array = req.get("any_of", [])
	if not any_of.is_empty() and not any_of.any(func(r: Variant) -> bool: return requirements_met(c, r)):
		return false
	return true


## "Team Captain or Leadership 60+" (empty if no trait/personality gate).
static func requirement_text(req: Dictionary) -> String:
	var parts := PackedStringArray()
	for t in req.get("traits", []):
		parts.append(_trait_name(t))
	var any_t: Array = req.get("any_traits", [])
	if not any_t.is_empty():
		parts.append(" or ".join(PackedStringArray(any_t.map(_trait_name))))
	for k in req.get("min", {}):
		if CareerData.group_of(k) == CareerData.PERSONALITY:
			parts.append("%s %d+" % [CareerData.STAT_NAMES[k], int(req["min"][k])])
	var any_of: Array = req.get("any_of", [])
	if not any_of.is_empty():
		var alts := PackedStringArray()
		for r in any_of:
			var t := requirement_text(r)
			if t != "":
				alts.append(t)
		if not alts.is_empty():
			parts.append(" or ".join(alts))
	return " + ".join(parts)


static func _trait_name(id: Variant) -> String:
	return str(CareerContent.trait_def(str(id)).get("name", id))


## Why a choice is locked ("" = available).
static func choice_lock(c: CareerData, ch: Dictionary) -> String:
	var req: Dictionary = ch.get("requires", {})
	if req.is_empty() or requirements_met(c, req):
		return ""
	var t := requirement_text(req)
	return "Requires " + (t if t != "" else "more experience")


# --- eligibility --------------------------------------------------------------------

## when: "season" (game week), "bye" or "offseason". forced: a due follow-up or
## story beat (skips the random-only rules: cooldown, season cap, beat/follow-up flags).
static func is_eligible(c: CareerData, s: Dictionary, when: String, tuning: CareerTuning,
		forced := false) -> bool:
	var id := str(s.get("id", ""))
	if not (c.stage in s.get("stages", [])):
		return false
	if not (when in s.get("when", ["season", "bye"])):
		return false
	if not forced and (s.get("follow_up_only", false) or s.has("beat")):
		return false
	var weeks: Variant = s.get("weeks")
	if weeks is Array and weeks.size() == 2 and when != "offseason":
		if c.week < int(weeks[0]) or c.week > int(weeks[1]):
			return false
	var seasons: Variant = s.get("seasons")
	if seasons is Array and seasons.size() == 2:
		if c.season_in_stage < int(seasons[0]) or c.season_in_stage > int(seasons[1]):
			return false
	var log: Dictionary = c.scenario_log.get(id, {})
	if not log.is_empty():
		if bool(s.get("once", false)) or s.has("beat"):
			return false
		if not forced and c.week_index - int(log.get("last_week_index", -999)) < int(s.get("cooldown", 0)):
			return false
	if not forced and int(c.season_log.get("ids", {}).get(id, 0)) >= tuning.max_scenario_repeats_per_season:
		return false
	return requirements_met(c, s.get("requires", {}))


static func weight(c: CareerData, s: Dictionary, tuning: CareerTuning) -> float:
	var w := maxf(float(s.get("weight", 1.0)), 0.0)
	var cat := str(s.get("category", ""))
	w *= pow(tuning.category_repeat_decay, int(c.season_log.get("cats", {}).get(cat, 0)))
	if cat in tuning.social_categories and c.stat("social") < tuning.low_social_threshold:
		w *= tuning.low_social_weight_mult
	return w


## A story beat is due at its season_in_stage, from its week on (or in that
## offseason), until it has been seen once.
static func beat_due(c: CareerData, s: Dictionary, when: String) -> bool:
	var beat: Variant = s.get("beat")
	if not (beat is Dictionary) or c.scenario_log.has(str(s.get("id", ""))):
		return false
	if c.season_in_stage != int(beat.get("season_in_stage", 1)):
		return false
	if when == "offseason":
		return "offseason" in s.get("when", [])
	return c.week >= int(beat.get("week", 1))


# --- picking -------------------------------------------------------------------------

## The week's scenario ids: due follow-ups, story beats, then weighted random
## picks up to `count`. Forced ones are always included (even past count).
static func pick(c: CareerData, when: String, count: int, rng: RandomNumberGenerator,
		tuning: CareerTuning) -> Array:
	var out: Array = []
	var cats := {}
	# 1. Due follow-ups.
	for q in c.queued_scenarios.duplicate():
		if int(q.get("due", 0)) > c.week_index:
			continue
		var s := CareerContent.scenario(str(q["id"]))
		if s.is_empty() or not (c.stage in s.get("stages", [])):
			c.queued_scenarios.erase(q)  # gone, or a different stage now
		elif is_eligible(c, s, when, tuning, true) and not (s["id"] in out):
			c.queued_scenarios.erase(q)
			out.append(str(s["id"]))
			cats[str(s.get("category", ""))] = true
	# 2. Story beats.
	for s in CareerContent.scenarios():
		if beat_due(c, s, when) and is_eligible(c, s, when, tuning, true) and not (s["id"] in out):
			out.append(str(s["id"]))
			cats[str(s.get("category", ""))] = true
	# 3. Weighted random.
	var pool: Array = []
	for s in CareerContent.scenarios():
		if not (s["id"] in out) and is_eligible(c, s, when, tuning):
			pool.append(s)
	while out.size() < count:
		var options: Array = pool
		if tuning.no_repeat_category_in_week:
			options = pool.filter(func(s: Dictionary) -> bool: return not cats.has(str(s.get("category", ""))))
		var total := 0.0
		for s in options:
			total += weight(c, s, tuning)
		if options.is_empty() or total <= 0.0:
			break
		var r := rng.randf() * total
		var chosen: Dictionary = options[options.size() - 1]
		for s in options:
			r -= weight(c, s, tuning)
			if r <= 0.0:
				chosen = s
				break
		out.append(str(chosen["id"]))
		cats[str(chosen.get("category", ""))] = true
		pool.erase(chosen)
	return out


# --- applying ------------------------------------------------------------------------

## Applies choice `index` of scenario `id`. Returns {"applied": stat changes,
## "new_traits": [...], "result": text, "modifiers": [...], "follow_up": id}.
static func apply_choice(c: CareerData, id: String, index: int, tuning: CareerTuning) -> Dictionary:
	var s := CareerContent.scenario(id)
	var choices: Array = s.get("choices", [])
	if index < 0 or index >= choices.size():
		push_warning("ScenarioEngine: bad choice %d for '%s'" % [index, id])
		return {}
	var ch: Dictionary = choices[index]
	if choice_lock(c, ch) != "":
		push_warning("ScenarioEngine: choice %d of '%s' is locked" % [index, id])
		return {}
	var applied := CareerStats.apply(c, ch.get("stats", {}), tuning)
	var mods: Array = []
	for m in ch.get("modifiers", []):
		if not (str(m) in c.week_modifiers):
			c.week_modifiers.append(str(m))
		mods.append(str(m))
	var set_flags: Dictionary = ch.get("set_flags", {})
	for f in set_flags:
		c.flags[f] = set_flags[f]
	var follow := ""
	var fu: Variant = ch.get("follow_up")
	if fu is String:
		fu = {"id": fu}
	if fu is Dictionary and fu.has("id"):
		follow = str(fu["id"])
		c.queued_scenarios.append({"id": follow, "due": c.week_index + maxi(int(fu.get("weeks", 1)), 1)})
	var log: Dictionary = c.scenario_log.get(id, {"times": 0})
	log["times"] = int(log.get("times", 0)) + 1
	log["last_week_index"] = c.week_index
	log["last_choice"] = index
	c.scenario_log[id] = log
	var ids: Dictionary = c.season_log["ids"]
	ids[id] = int(ids.get(id, 0)) + 1
	var cats: Dictionary = c.season_log["cats"]
	var cat := str(s.get("category", ""))
	cats[cat] = int(cats.get(cat, 0)) + 1
	return {"applied": applied, "new_traits": applied.get("new_traits", []),
		"result": str(ch.get("result", "")), "modifiers": mods, "follow_up": follow}
