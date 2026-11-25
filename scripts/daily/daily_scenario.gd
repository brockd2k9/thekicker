class_name DailyScenario
extends RefCounted
## The day's kick, made from the date alone: the same seed gives every player
## the same situation, wind, weather, field and kick type on the same day, and
## restarting can't re-roll it. Pure logic, no scene access.
##
## The player's skill tier (TIERS, locked for the day when it's first seen)
## only maps the day's difficulty onto distances and how much the weather
## bites, so a Rookie and a Pro see the same game-winner in the same rain,
## from distances that suit them.
##
## A scenario is a Dictionary:
##   day, tier, weekday (0 = Mon), boss, difficulty (0..1),
##   kick ("fg" / "xp" / "kickoff" / "onside"), yards (place kicks: the
##   distance; tee kicks: the tee spot), wind_mph (signed, + = toward the
##   kicker's right), gust_mph, along_mph (+ = tailwind), weather, field,
##   situation, label, pressure, goal ("make" / "in_play" / "deep" / "hop"),
##   wind_seed, power_mult, spread_deg, window_mult (weather + field effects).

const TIERS := ["Rookie", "Varsity", "College", "Pro"]

## Weather: label, weight, months it can happen in (empty = any), effects.
const WEATHER := {
	"clear": {"label": "Clear", "weight": 4, "months": []},
	"overcast": {"label": "Overcast", "weight": 3, "months": []},
	"rain": {"label": "Rain", "weight": 2, "months": [], "spread": 0.35},
	"cold": {"label": "Bitter cold", "weight": 2, "months": [11, 12, 1, 2, 3], "power": 0.03},
	"snow": {"label": "Snow", "weight": 1, "months": [12, 1, 2], "power": 0.04, "spread": 0.25},
	"heat": {"label": "Heat", "weight": 1, "months": [6, 7, 8, 9], "window": 0.04},
}
## Field condition: label, weight, the weather it needs (empty = any), effects.
const FIELDS := {
	"dry": {"label": "Dry turf", "weight": 4, "needs": []},
	"firm": {"label": "Firm grass", "weight": 2, "needs": []},
	"wet": {"label": "Wet", "weight": 3, "needs": ["rain", "snow"], "window": 0.06},
	"sloppy": {"label": "Sloppy", "weight": 2, "needs": ["rain"], "window": 0.1, "spread": 0.2},
	"frozen": {"label": "Frozen", "weight": 3, "needs": ["cold", "snow"], "power": 0.02},
}
## Game situations per kick type: label and base pressure (0..1).
const SITUATIONS := {
	"fg": [
		{"key": "end_half", "label": "End of half  -  0:01 left", "pressure": 0.35, "weight": 2},
		{"key": "tie_4q", "label": "4th Qtr  -  tie game  -  6:40 left", "pressure": 0.6, "weight": 2},
		{"key": "down_one", "label": "4th Qtr  -  down 1  -  1:52 left", "pressure": 0.75, "weight": 2},
		{"key": "game_winner", "label": "Down 2  -  0:03 left  -  GAME WINNER", "pressure": 1.0, "weight": 1, "boss": true},
		{"key": "icing", "label": "Tie game  -  0:02  -  THEY CALLED TIMEOUT", "pressure": 0.95, "weight": 1, "boss": true},
		{"key": "overtime", "label": "OVERTIME  -  tied  -  make it and win", "pressure": 0.9, "weight": 1, "boss": true},
	],
	"xp": [
		{"key": "after_td", "label": "After the touchdown  -  2nd Qtr", "pressure": 0.2, "weight": 2},
		{"key": "xp_tie", "label": "Down 1  -  0:00  -  extra point to TIE", "pressure": 0.9, "weight": 1},
		{"key": "xp_lead", "label": "Tie game  -  0:24  -  extra point for the LEAD", "pressure": 0.75, "weight": 1},
	],
	"kickoff": [
		{"key": "opening", "label": "Opening kickoff", "pressure": 0.15, "weight": 2},
		{"key": "pin_deep", "label": "Up 3  -  0:41 left  -  pin them deep", "pressure": 0.6, "weight": 1},
	],
	"onside": [
		{"key": "onside_late", "label": "Down 5  -  1:48 left  -  onside or bust", "pressure": 0.7, "weight": 1},
	],
}
const KICK_NAMES := {"fg": "FIELD GOAL", "xp": "EXTRA POINT", "kickoff": "KICKOFF", "onside": "ONSIDE KICK"}
const GOAL_TEXT := {
	"make": "Make it.",
	"in_play": "Keep it in bounds and get it past the 25.",
	"deep": "Land it deep: a touchback or fielded inside the 10.",
	"hop": "Perfect hop: rest it 10-18 yards out, inside the hashes.",
}


## The seed for a day: the same everywhere, different every day. Plain integer
## math (no engine hashing), so it stays the same across platforms and versions.
static func seed_for(day: int) -> int:
	# A 32-bit integer hash of the day (no overflow: every product < 2^60),
	# so neighboring days don't get similar streams.
	var x := (day + 0x7177) & 0xffffffff
	x = (((x >> 16) ^ x) * 0x45d9f3b) & 0xffffffff
	x = (((x >> 16) ^ x) * 0x45d9f3b) & 0xffffffff
	return (x >> 16) ^ x


static func generate(day: int, tier: int, t: DailyTuning) -> Dictionary:
	tier = clampi(tier, 0, TIERS.size() - 1)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_for(day)
	# Every random draw happens here, in a fixed order, whatever the tier:
	# the tier only maps them, so every player shares the day's situation.
	var u_type := rng.randf()
	var u_dist := rng.randf()
	var u_wind := rng.randf()
	var u_wind_dir := rng.randf()
	var u_gust := rng.randf()
	var u_along := rng.randf()
	var u_weather := rng.randf()
	var u_field := rng.randf()
	var u_sit := rng.randf()
	var wind_seed := rng.randi()

	var date := DailyClock.date_of(day)
	var wd := int(date["weekday"])
	var boss := wd == t.boss_weekday
	var diff := clampf(float(t.weekday_difficulty[wd]) if wd < t.weekday_difficulty.size() else 0.5, 0.0, 1.0)

	var kick := "fg"
	if not boss:
		if u_type < t.chance_extra_point:
			kick = "xp"
		elif u_type < t.chance_extra_point + t.chance_kickoff:
			kick = "kickoff"
		elif u_type < t.chance_extra_point + t.chance_kickoff + t.chance_onside:
			kick = "onside"

	var yards := 0
	match kick:
		"fg":
			var lo := _at(t.fg_min_yards, tier, 25)
			var hi := _at(t.fg_max_yards, tier, 45)
			yards = roundi(lerpf(lo, hi, clampf(diff * 0.85 + u_dist * 0.15, 0.0, 1.0)))
		"xp":
			yards = _at(t.xp_yards, tier, 20)
		_:
			yards = _at(t.kickoff_spot, tier, 35)

	# Wind: stronger later in the week; gusts from mid-week on; no wind on the
	# easiest days half the time.
	var top := lerpf(t.wind_min_mph, t.wind_max_mph, diff)
	var wind := roundf(u_wind * top)
	if wind < 2.0 or (diff < 0.2 and u_wind < 0.4):
		wind = 0.0  # calm (no 1 mph breezes)
	if kick == "onside":
		wind = minf(wind, 6.0)  # an onside is a touch kick
	var sign := -1.0 if u_wind_dir < 0.5 else 1.0
	var gust := 0.0
	if wind >= 1.0 and diff >= t.gust_from_difficulty and u_gust < 0.55:
		gust = roundf(lerpf(3.0, t.gust_max_mph, diff))
	var along := 0.0
	if wind >= 1.0 and (kick == "fg" or kick == "xp"):
		along = roundf((u_along * 2.0 - 1.0) * t.along_max_mph * diff)

	var weather := _pick_weather(u_weather, int(date["month"]))
	var field := _pick_field(u_field, weather)
	var sit := _pick_situation(kick, u_sit, boss)
	var pressure := clampf(float(sit["pressure"]) * lerpf(t.pressure_floor, 1.0, diff), 0.0, 1.0)

	var goal := "make"
	if kick == "kickoff":
		goal = "deep" if diff >= 0.5 else "in_play"
	elif kick == "onside":
		goal = "hop"

	var sc := {"day": day, "tier": tier, "weekday": wd, "boss": boss, "difficulty": diff,
		"kick": kick, "yards": yards, "wind_mph": wind * sign, "gust_mph": gust, "along_mph": along,
		"weather": weather, "field": field, "situation": str(sit["key"]), "label": str(sit["label"]),
		"pressure": pressure, "goal": goal, "wind_seed": wind_seed}
	_apply_conditions(sc, _at_f(t.conditions_scale, tier, 1.0))
	return sc


## Weather + field effects as kick multipliers, scaled for the tier.
static func _apply_conditions(sc: Dictionary, scale: float) -> void:
	var w: Dictionary = WEATHER[sc["weather"]]
	var f: Dictionary = FIELDS[sc["field"]]
	var power := float(w.get("power", 0.0)) + float(f.get("power", 0.0))
	var spread := float(w.get("spread", 0.0)) + float(f.get("spread", 0.0))
	var window := float(w.get("window", 0.0)) + float(f.get("window", 0.0))
	sc["power_mult"] = snappedf(1.0 - power * scale, 0.001)
	sc["spread_deg"] = snappedf(spread * scale, 0.01)
	sc["window_mult"] = snappedf(1.0 - window * scale, 0.001)


static func _pick_weather(u: float, month: int) -> String:
	var keys: Array = []
	for k in WEATHER:
		var months: Array = WEATHER[k]["months"]
		if months.is_empty() or month in months:
			keys.append(k)
	return _weighted(keys, WEATHER, u)


static func _pick_field(u: float, weather: String) -> String:
	var keys: Array = []
	for k in FIELDS:
		var needs: Array = FIELDS[k]["needs"]
		if needs.is_empty() or weather in needs:
			keys.append(k)
	# Rain or snow always leaves the field wet, sloppy or frozen.
	if weather in ["rain", "snow"]:
		keys = keys.filter(func(k: String) -> bool: return not (FIELDS[k]["needs"] as Array).is_empty())
	return _weighted(keys, FIELDS, u)


static func _pick_situation(kick: String, u: float, boss: bool) -> Dictionary:
	var list: Array = SITUATIONS[kick]
	if boss:
		list = list.filter(func(s: Dictionary) -> bool: return bool(s.get("boss", false)))
	var total := 0
	for s in list:
		total += int(s["weight"])
	var pick := u * total
	for s in list:
		pick -= int(s["weight"])
		if pick < 0.0:
			return s
	return list.back()


static func _weighted(keys: Array, table: Dictionary, u: float) -> String:
	var total := 0
	for k in keys:
		total += int(table[k]["weight"])
	var pick := u * total
	for k in keys:
		pick -= int(table[k]["weight"])
		if pick < 0.0:
			return k
	return keys.back()


static func _at(a: Array, i: int, fallback: int) -> int:
	return int(a[i]) if i < a.size() else fallback


static func _at_f(a: Array, i: int, fallback: float) -> float:
	return float(a[i]) if i < a.size() else fallback


# --- into the kick scene --------------------------------------------------------------

static func kick_type(sc: Dictionary) -> int:
	match str(sc.get("kick", "fg")):
		"xp":
			return KickSituation.KickType.EXTRA_POINT
		"kickoff":
			return KickSituation.KickType.KICKOFF
		"onside":
			return KickSituation.KickType.ONSIDE
	return KickSituation.KickType.FIELD_GOAL


static func is_tee(sc: Dictionary) -> bool:
	return str(sc.get("kick", "fg")) in ["kickoff", "onside"]


## The weather and field as kick modifiers (neutral otherwise: daily kicks use
## Challenge Mode's physics, not a career's range).
static func modifiers(sc: Dictionary) -> KickModifiers:
	var m := KickModifiers.new()
	m.power_mult = float(sc.get("power_mult", 1.0))
	m.accuracy_spread_deg = float(sc.get("spread_deg", 0.0))
	m.window_mult = float(sc.get("window_mult", 1.0))
	return m


static func kickoff_rules(sc: Dictionary) -> KickoffRules:
	var r := KickoffRules.new()
	r.spot_yards = int(sc.get("yards", 35))
	return r


## Did this result meet the day's goal? place kicks: made; tee kicks: the
## KickoffJudge result.
static func success(sc: Dictionary, made: bool, tee_result: Dictionary) -> bool:
	match str(sc.get("goal", "make")):
		"in_play":
			return str(tee_result.get("result", "")) in ["touchback", "deep", "returned"]
		"deep":
			return str(tee_result.get("result", "")) in ["touchback", "deep"]
		"hop":
			return bool(tee_result.get("hop", false))
	return made


# --- text --------------------------------------------------------------------------------

## "47-YARD FIELD GOAL" / "EXTRA POINT" / "KICKOFF FROM THE 35"
static func headline(sc: Dictionary) -> String:
	var k := str(sc.get("kick", "fg"))
	match k:
		"fg":
			return "%d-YARD FIELD GOAL" % int(sc["yards"])
		"xp":
			return "%d-YARD EXTRA POINT" % int(sc["yards"])
		"kickoff":
			return "KICKOFF FROM THE %d" % int(sc["yards"])
	return "ONSIDE KICK FROM THE %d" % int(sc["yards"])


## "12 MPH  <-  gusts to 18" / "Calm"
static func wind_text(sc: Dictionary) -> String:
	var w := float(sc.get("wind_mph", 0.0))
	if absf(w) < 0.5:
		return "Calm"
	var s := "%d mph %s" % [roundi(absf(w)), "L to R" if w > 0.0 else "R to L"]
	if float(sc.get("gust_mph", 0.0)) > 0.0:
		s += ", gusts +%d" % roundi(float(sc["gust_mph"]))
	var a := float(sc.get("along_mph", 0.0))
	if absf(a) >= 1.0:
		s += ", %s %d" % ["tail" if a > 0.0 else "head", roundi(absf(a))]
	return s


static func weather_text(sc: Dictionary) -> String:
	return str(WEATHER.get(str(sc.get("weather", "clear")), {}).get("label", "Clear"))


static func field_text(sc: Dictionary) -> String:
	return str(FIELDS.get(str(sc.get("field", "dry")), {}).get("label", "Dry turf"))


static func pressure_text(sc: Dictionary) -> String:
	var p := float(sc.get("pressure", 0.0))
	if p >= 0.85:
		return "Max"
	if p >= 0.6:
		return "High"
	if p >= 0.3:
		return "Medium"
	return "Low"


static func goal_text(sc: Dictionary) -> String:
	return str(GOAL_TEXT.get(str(sc.get("goal", "make")), "Make it."))


## One line for cards: "47-yd field goal  ·  Rain  ·  Down 1, 1:52 left"
static func summary(sc: Dictionary) -> String:
	return "%s  ·  %s  ·  %s" % [headline(sc).capitalize(), weather_text(sc), wind_text(sc)]
