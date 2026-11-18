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
##   Career events (on = "career"; sent by Career Mode through
##   GameState.report_career_event()):
##     "event": name (career_started, offer, signed, drafted, pro_season,
##       game_winner, traits, pro_reached, retired),
##     "match": {field: value or [values]}, "min_value": {field: number}.
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
	# --- Career Mode ---
	{
		"id": "career_first_offer",
		"name": "Scholarship Offer",
		"description": "Career: receive your first scholarship offer.",
		"condition": {"on": "career", "event": "offer", "match": {"type": ["full", "partial"]}},
	},
	{
		"id": "career_top_program",
		"name": "Big Time",
		"description": "Career: sign with a top college program.",
		"condition": {"on": "career", "event": "signed", "match": {"tier": "top"}},
	},
	{
		"id": "career_drafted",
		"name": "Draft Day",
		"description": "Career: get drafted by a pro team.",
		"condition": {"on": "career", "event": "drafted"},
	},
	{
		"id": "career_first_pro_season",
		"name": "Welcome to the League",
		"description": "Career: finish your first pro season.",
		"condition": {"on": "career", "event": "pro_season", "min_value": {"pro_seasons": 1}},
	},
	{
		"id": "career_game_winner",
		"name": "Walk-Off",
		"description": "Career: make a game-winning kick in the final two minutes.",
		"condition": {"on": "career", "event": "game_winner"},
	},
	{
		"id": "career_all_traits",
		"name": "Complete Package",
		"description": "Career: unlock all 8 traits in one career.",
		"condition": {"on": "career", "event": "traits", "min_value": {"count": 8}},
	},
	{
		"id": "career_comeback",
		"name": "Against the Odds",
		"description": "Career: reach the pros after walking on or going the junior college route.",
		"condition": {"on": "career", "event": "pro_reached", "match": {"comeback": true}},
	},
	{
		"id": "career_full",
		"name": "Full Career",
		"description": "Career: play at least one pro season and see your career through to retirement.",
		"condition": {"on": "career", "event": "retired", "min_value": {"pro_seasons": 1}},
	},
	{
		"id": "career_ironman",
		"name": "Ironman",
		"description": "Career: keep kicking until the age cap of 38.",
		"condition": {"on": "career", "event": "retired", "match": {"reason": "age_cap"}},
	},
]


static func find(id: String) -> Dictionary:
	for a in ALL:
		if a["id"] == id:
			return a
	return {}
