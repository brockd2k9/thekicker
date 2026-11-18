class_name ScenarioEngine
extends RefCounted
## Picks and applies off-field scenarios (data in data/career/scenarios_*.json).
##
## pick(): every scenario whose rules pass (stage, when, week range, stat
## min/max, traits, flags, one-time, cooldown) goes into a pool; picks are
## weighted random without repeats. apply_choice(): stat changes through
## CareerStats (the same rules the screen previews), game-day modifiers for
## this week, flags, and the scenario log that drives one-time / cooldown.
## (Stage 4 adds guaranteed story beats and follow-ups.)

## "season" (game week), "bye" or "offseason".
static func eligible(c: CareerData, when: String) -> Array:
	var pool: Array = []
	for s in CareerContent.scenarios():
		if is_eligible(c, s, when):
			pool.append(s)
	return pool


static func is_eligible(c: CareerData, s: Dictionary, when: String) -> bool:
	if not (c.stage in s.get("stages", [])):
		return false
	if not (when in s.get("when", ["season", "bye"])):
		return false
	var weeks: Variant = s.get("weeks")
	if weeks is Array and weeks.size() == 2 and when != "offseason":
		if c.week < int(weeks[0]) or c.week > int(weeks[1]):
			return false
	var log: Dictionary = c.scenario_log.get(str(s.get("id", "")), {})
	if not log.is_empty():
		if bool(s.get("once", false)):
			return false
		var cooldown := int(s.get("cooldown", 0))
		if c.week_index - int(log.get("last_week_index", -999)) < cooldown:
			return false
	var req: Dictionary = s.get("requires", {})
	for k in req.get("min", {}):
		if c.stat(k) < float(req["min"][k]):
			return false
	for k in req.get("max", {}):
		if c.stat(k) > float(req["max"][k]):
			return false
	for t in req.get("traits", []):
		if not c.has_trait(str(t)):
			return false
	for f in req.get("flags", []):
		if not c.flags.get(str(f), false):
			return false
	for f in req.get("not_flags", []):
		if c.flags.get(str(f), false):
			return false
	return true


## Up to `count` scenario ids, weighted random, no repeats.
static func pick(c: CareerData, when: String, count: int, rng: RandomNumberGenerator) -> Array:
	var pool := eligible(c, when)
	var out: Array = []
	while out.size() < count and not pool.is_empty():
		var total := 0.0
		for s in pool:
			total += maxf(float(s.get("weight", 1.0)), 0.0)
		if total <= 0.0:
			break
		var r := rng.randf() * total
		var chosen: Dictionary = pool[pool.size() - 1]
		for s in pool:
			r -= maxf(float(s.get("weight", 1.0)), 0.0)
			if r <= 0.0:
				chosen = s
				break
		out.append(str(chosen["id"]))
		pool.erase(chosen)
	return out


## Applies choice `index` of scenario `id`. Returns {"applied": stat changes,
## "new_traits": [...], "result": text, "modifiers": [...]}.
static func apply_choice(c: CareerData, id: String, index: int, tuning: CareerTuning) -> Dictionary:
	var s := CareerContent.scenario(id)
	var choices: Array = s.get("choices", [])
	if index < 0 or index >= choices.size():
		push_warning("ScenarioEngine: bad choice %d for '%s'" % [index, id])
		return {}
	var ch: Dictionary = choices[index]
	var applied := CareerStats.apply(c, ch.get("stats", {}), tuning)
	var mods: Array = []
	for m in ch.get("modifiers", []):
		if not (str(m) in c.week_modifiers):
			c.week_modifiers.append(str(m))
		mods.append(str(m))
	var set_flags: Dictionary = ch.get("set_flags", {})
	for f in set_flags:
		c.flags[f] = set_flags[f]
	var log: Dictionary = c.scenario_log.get(id, {"times": 0})
	log["times"] = int(log.get("times", 0)) + 1
	log["last_week_index"] = c.week_index
	log["last_choice"] = index
	c.scenario_log[id] = log
	return {"applied": applied, "new_traits": applied.get("new_traits", []),
		"result": str(ch.get("result", "")), "modifiers": mods}
