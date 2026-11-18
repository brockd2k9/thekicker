class_name AchievementDefs
extends RefCounted
## Achievement definitions as data. Add a row here and it appears on the
## Achievements screen and gets checked automatically. No other code changes.
##
## condition keys (all must match):
##   "on":           "kick" (checked after each kick) or "run" (after each
##                   Challenge/Career run). Omit for stat-only conditions,
##                   which are checked after every kick and run.
##   "stat", "at_least":  all-time KickStats value >= number
##                   (keys: see KickStats.to_dict(), e.g. "makes",
##                   "current_make_streak", "longest_make_yards").
##   Kick filters (on = "kick"):
##     "made": bool, "min_yards": int, "min_pressure": 0..1,
##     "min_wind_mph": float (wind at the moment of the kick, either direction),
##     "mode": "practice" / "challenge" / "career".
##   Run filters (on = "run"):
##     "mode": "challenge", "min_makes": int.
##
## Steam later: map each id to a Steam achievement API name.

const ALL: Array[Dictionary] = [
	{
		"id": "first_make",
		"name": "First Make",
		"description": "Make your first field goal.",
		"condition": {"stat": "makes", "at_least": 1},
	},
	{
		"id": "five_in_a_row",
		"name": "5-in-a-Row",
		"description": "Make 5 field goals in a row.",
		"condition": {"stat": "current_make_streak", "at_least": 5},
	},
	{
		"id": "ten_in_a_row",
		"name": "Automatic",
		"description": "Make 10 field goals in a row.",
		"condition": {"stat": "current_make_streak", "at_least": 10},
	},
	{
		"id": "fifty_plus",
		"name": "50+ Yard Make",
		"description": "Make a field goal from 50 yards or more.",
		"condition": {"on": "kick", "made": true, "min_yards": 50},
	},
	{
		"id": "sixty_yarder",
		"name": "Moonshot",
		"description": "Make a field goal from 60 yards.",
		"condition": {"on": "kick", "made": true, "min_yards": 60},
	},
	{
		"id": "clutch_kick",
		"name": "Clutch Kick",
		"description": "Make a kick under CLUTCH pressure.",
		"condition": {"on": "kick", "made": true, "min_pressure": 0.9},
	},
	{
		"id": "windy_day",
		"name": "Windy Day",
		"description": "Make a kick into a 15+ mph crosswind.",
		"condition": {"on": "kick", "made": true, "min_wind_mph": 15.0},
	},
	{
		"id": "century",
		"name": "Century",
		"description": "Make 100 field goals in total.",
		"condition": {"stat": "makes", "at_least": 100},
	},
	{
		"id": "challenge_ten",
		"name": "Gauntlet",
		"description": "Make 10 kicks in a single Challenge run.",
		"condition": {"on": "run", "mode": "challenge", "min_makes": 10},
	},
]


static func find(id: String) -> Dictionary:
	for a in ALL:
		if a["id"] == id:
			return a
	return {}
