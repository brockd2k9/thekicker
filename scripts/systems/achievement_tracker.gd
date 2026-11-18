class_name AchievementTracker
extends RefCounted
## Unlock state for the data in AchievementDefs, and the condition checker.
## GameState calls check_kick() after every kick and check_run() after every run.

## id -> unix time (UTC seconds) it was unlocked.
var unlocked: Dictionary = {}


func is_unlocked(id: String) -> bool:
	return unlocked.has(id)


func unlocked_at(id: String) -> int:
	return int(unlocked.get(id, 0))


func unlocked_count() -> int:
	return unlocked.size()


## Returns the definitions that were newly unlocked by this kick.
func check_kick(kick: Dictionary, stats: KickStats) -> Array[Dictionary]:
	return _check("kick", kick, stats)


## summary: see ChallengeRules.summary().
func check_run(summary: Dictionary, stats: KickStats) -> Array[Dictionary]:
	return _check("run", summary, stats)


## e: a Career Mode event, e.g. {"event": "drafted", "round": 5}.
func check_career(e: Dictionary, stats: KickStats) -> Array[Dictionary]:
	return _check("career", e, stats)


func _check(event: String, data: Dictionary, stats: KickStats) -> Array[Dictionary]:
	var fresh: Array[Dictionary] = []
	var now := int(Time.get_unix_time_from_system())
	for def in AchievementDefs.ALL:
		var id: String = def["id"]
		if unlocked.has(id):
			continue
		if _matches(def["condition"], event, data, stats):
			unlocked[id] = now
			fresh.append(def)
	return fresh


static func _matches(c: Dictionary, event: String, data: Dictionary, stats: KickStats) -> bool:
	var on: String = c.get("on", "")
	if on != "" and on != event:
		return false
	if c.has("stat") and stats.value(c["stat"]) < float(c.get("at_least", 1)):
		return false
	if c.has("mode") and data.get("mode", "") != c["mode"]:
		return false
	if c.has("made") and bool(data.get("made", false)) != bool(c["made"]):
		return false
	if c.has("min_yards") and int(data.get("distance_yards", 0)) < int(c["min_yards"]):
		return false
	if c.has("min_pressure") and float(data.get("pressure", 0.0)) < float(c["min_pressure"]) - 0.001:
		return false
	if c.has("min_wind_mph") and absf(float(data.get("wind_at_kick_mph", 0.0))) < float(c["min_wind_mph"]):
		return false
	if c.has("min_makes") and int(data.get("makes", 0)) < int(c["min_makes"]):
		return false
	# Career events: "event" names it; "match" fields must equal (or be one of
	# a list); "min_value" fields must be at least the number.
	if c.has("event") and str(data.get("event", "")) != str(c["event"]):
		return false
	var m: Dictionary = c.get("match", {})
	for k in m:
		var want: Variant = m[k]
		var got: Variant = data.get(k)
		if want is Array:
			if not (got in want):
				return false
		elif got != want:
			return false
	var mins: Dictionary = c.get("min_value", {})
	for k in mins:
		if float(data.get(k, 0)) < float(mins[k]):
			return false
	return true


func to_dict() -> Dictionary:
	return {"unlocked": unlocked.duplicate()}


func from_dict(d: Dictionary) -> void:
	unlocked = {}
	var u: Variant = d.get("unlocked", {})
	if u is Dictionary:
		for id in u:
			unlocked[str(id)] = int(u[id])
