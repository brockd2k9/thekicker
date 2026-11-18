class_name CareerStats
extends RefCounted
## The rules for changing the four stat groups. Every stat change in Career
## Mode (scenario choices, game results, weekly drift) goes through apply(),
## so the gain rules below hold everywhere and the scenario screen can show the
## exact projected change with preview().
##
## Gain rules (numbers in CareerTuning "Stat Gains" / "Low Life Stats"):
##   Life:        raw change; trait "gains" boost increases.
##   Football:    increases shrink as the stat climbs (football_diminishing),
##                are boosted by traits (e.g. Driven), and Resilience increases
##                are cut while Fun is low. Decreases are raw.
##   Personality: every change is scaled by personality_change_scale (they move
##                slowly); trait "gains" boost increases.
## Traits unlock when their personality thresholds are crossed and stay unlocked.

## changes: {"life": {"energy": -10}, "football": {"accuracy": 3}, ...}.
## A flat {"energy": -10} also works. Returns the change actually applied,
## in the same grouped shape (rounded to 0.1), plus "new_traits": [ids].
static func apply(c: CareerData, changes: Dictionary, tuning: CareerTuning) -> Dictionary:
	var applied := _resolve(c, changes, tuning)
	for g in CareerData.GROUP_KEYS:
		for k in applied[g]:
			c.set_stat(k, c.stat(k) + float(applied[g][k]))
	applied["new_traits"] = check_traits(c)
	return applied


## Same as apply() but changes nothing: the projected change for the UI.
static func preview(c: CareerData, changes: Dictionary, tuning: CareerTuning) -> Dictionary:
	return _resolve(c, changes, tuning)


static func _resolve(c: CareerData, changes: Dictionary, tuning: CareerTuning) -> Dictionary:
	var out := {}
	for g in CareerData.GROUP_KEYS:
		out[g] = {}
	var flat := _flatten(changes)
	for key in flat:
		var raw: float = flat[key]
		var g := CareerData.group_of(key)
		if g == "":
			push_warning("CareerStats: unknown stat '%s'" % key)
			continue
		var delta := raw * _gain_mult(c, g, key, raw, tuning)
		var now := c.stat(key)
		# Never past the 0..100 range, so the preview matches what happens.
		delta = clampf(now + delta, 0.0, 100.0) - now
		delta = snappedf(delta, 0.1)
		if absf(delta) >= 0.05:
			out[g][key] = delta
	return out


static func _flatten(changes: Dictionary) -> Dictionary:
	var flat := {}
	for k in changes:
		var v: Variant = changes[k]
		if v is Dictionary:
			for sk in v:
				flat[str(sk)] = float(flat.get(str(sk), 0.0)) + float(v[sk])
		elif k in ["new_traits"]:
			continue
		else:
			flat[str(k)] = float(flat.get(str(k), 0.0)) + float(v)
	return flat


static func _gain_mult(c: CareerData, g: String, key: String, raw: float,
		tuning: CareerTuning) -> float:
	var mult := 1.0
	if g == CareerData.PERSONALITY:
		mult *= tuning.personality_change_scale
	if raw <= 0.0:
		return mult
	mult *= 1.0 + trait_gain_bonus(c, g, key)
	if g == CareerData.FOOTBALL:
		mult *= 1.0 - tuning.football_diminishing * c.stat(key) / 100.0
		if key == "resilience" and c.stat("fun") < tuning.low_fun_threshold:
			mult *= tuning.low_fun_resilience_gain_mult
	return maxf(mult, 0.0)


## Sum of the unlocked traits' "gains" bonuses for this group or stat.
static func trait_gain_bonus(c: CareerData, g: String, key: String) -> float:
	var bonus := 0.0
	for id in c.traits:
		var gains: Dictionary = CareerContent.trait_def(id).get("passive", {}).get("gains", {})
		bonus += float(gains.get(g, 0.0)) + float(gains.get(key, 0.0))
	return bonus


# --- traits ------------------------------------------------------------------------

## Unlocks every trait whose conditions now hold. Returns the new ids.
static func check_traits(c: CareerData) -> Array[String]:
	var fresh: Array[String] = []
	for t in CareerContent.traits():
		var id := str(t.get("id", ""))
		if id == "" or c.has_trait(id):
			continue
		if trait_conditions_met(c, t):
			c.traits.append(id)
			fresh.append(id)
	return fresh


static func trait_conditions_met(c: CareerData, t: Dictionary) -> bool:
	var unlock: Variant = t.get("unlock", [])
	if not (unlock is Array) or (unlock as Array).is_empty():
		return false
	for cond in unlock:
		if c.stat(str(cond.get("stat", ""))) < float(cond.get("min", 0)):
			return false
	return true


## "Ambition 60" or "Charisma 55 + Intelligence 55", for the traits screen.
static func trait_requirement_text(t: Dictionary) -> String:
	var parts := PackedStringArray()
	for cond in t.get("unlock", []):
		var key := str(cond.get("stat", ""))
		parts.append("%s %d" % [CareerData.STAT_NAMES.get(key, key), int(cond.get("min", 0))])
	return " + ".join(parts)
