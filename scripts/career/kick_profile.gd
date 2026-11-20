class_name KickProfile
extends RefCounted
## The "kick difficulty profile": how hard kicking is for this career this week.
## KickProfile.build() is THE one function that turns stats + traits +
## injury + this week's game-day modifiers (+ in-game context such as a miss
## streak) into numbers. The kick scene only ever sees the result, through
## to_kick_modifiers(); every weight, curve and cap is in CareerTuning.
##
## It also writes the Game Day Outlook lines from the same numbers, so what the
## player reads always matches what the kick does.
##
##   Power      -> fg_range / kickoff_range (KickRange curves + perks), plus
##                 range_yd (game-day yards from life stats, injury, modifiers);
##                 power_mult is derived last so a full flick reaches fg_range
##   Accuracy   -> accuracy_spread_deg  (random aim error at release)
##                 wobble_mult          (pressure aim wobble)
##                 window_mult          (time to swipe after the hold)
##   Resilience -> pressure_sensitivity (how hard situation pressure hits)
##                 pressure_add         (miss streak in this game)
##   Toughness  -> wind_mult            (wind push), injury penalties, injury_risk
##   Energy / Health / Social low -> penalties (see CareerTuning "Low Life Stats")
##   Energy / Health high -> a few extra yards ("Game Day Range")

## Profile fields that modifiers and traits may change (data/career/*.json).
## (Old data may still say "power_mult": it's read as range_yd, see _apply.)
const FIELDS := ["range_yd", "accuracy_spread_deg", "wobble_mult", "window_mult",
	"pressure_sensitivity", "pressure_add", "wind_mult", "injury_risk"]
## Fields where a smaller number is better for the kicker.
const LOWER_IS_BETTER := ["accuracy_spread_deg", "wobble_mult", "pressure_sensitivity",
	"pressure_add", "wind_mult", "injury_risk"]
## Changes smaller than this don't get an Outlook word.
const WORD_EPSILON := 0.005

## Derived from fg_range (KickRange.speed_mult_for): the kick's top launch speed.
var power_mult: float = 1.0
## Game-day yards added to both ranges (life stats, injury, modifiers, traits).
var range_yd: float = 0.0
## Field goal range today (yards): paper range + range_yd, capped.
var fg_range: float = 40.0
## Paper field goal range (Power + perks), before game day.
var fg_range_base: float = 40.0
## Kickoff range today (yards of carry at a full flick).
var kickoff_range: float = 52.0
## Perks you own, summed numeric effects (onside, returns...; Perks), for
## code outside the profile (CareerGameMode.kickoff_rules_for).
var perk_fx: Dictionary = {}
## Legacy "power_mult" effects -> yards (CareerTuning.legacy_power_mult_yards).
var _legacy_yards: float = 40.0
var accuracy_spread_deg: float = 0.0
var wobble_mult: float = 1.0
var window_mult: float = 1.0
var pressure_sensitivity: float = 1.0
## Added to each kick's situation pressure (0..1) by the career game mode.
var pressure_add: float = 0.0
var wind_mult: float = 1.0
## Chance of picking up an injury this week (rolled by the weekly loop).
var injury_risk: float = 0.0
## Game Day Outlook: [{label, detail, good: bool, source: "modifier"/"state"/"trait"}].
var outlook: Array[Dictionary] = []


## data: the career. ctx (optional): {"miss_streak": int} during a game,
## "extra_modifiers": [ids] for in-game ones (sideline warmup), and
## "modifiers": [ids] to override data.week_modifiers.
static func build(data: CareerData, tuning: CareerTuning, ctx: Dictionary = {}) -> KickProfile:
	var p := KickProfile.new()
	var t := tuning
	p._legacy_yards = t.legacy_power_mult_yards
	var power := data.stat("power")
	var acc := data.stat("accuracy")
	var res := data.stat("resilience")
	var tough := data.stat("toughness")

	# 1. Football stats set the baseline. Range: KickRange (power_mult at the end).
	p.fg_range_base = KickRange.fg_range(data, t, power)
	p.accuracy_spread_deg = CareerTuning.blend(t.spread_at_0, t.spread_at_100, acc, t.accuracy_curve)
	p.wobble_mult = CareerTuning.blend(t.wobble_at_0, t.wobble_at_100, acc)
	p.window_mult = CareerTuning.blend(t.window_at_0, t.window_at_100, acc)
	p.pressure_sensitivity = CareerTuning.blend(t.pressure_sens_at_0, t.pressure_sens_at_100, res)
	p.wind_mult = CareerTuning.blend(t.wind_mult_at_0, t.wind_mult_at_100, tough)
	p.injury_risk = t.injury_base_risk - t.toughness_injury_risk_cut * tough / 100.0

	# 2. Life stats: rested / healthy add yards; low ones cost yards and more.
	if data.stat("energy") >= t.rested_energy and t.rested_range_yd != 0.0:
		p._add_state("rested_legs", {"range_yd": t.rested_range_yd}, true)
	if data.stat("health") >= t.healthy_health and t.healthy_range_yd != 0.0:
		p._add_state("healthy", {"range_yd": t.healthy_range_yd}, true)
	var f := CareerTuning.lowness(data.stat("energy"), t.low_energy_threshold)
	if f > 0.0:
		p._add_state("low_energy", {
			"range_yd": -t.low_energy_range_yd * f, "wobble_mult": t.low_energy_wobble * f})
	f = CareerTuning.lowness(data.stat("health"), t.low_health_threshold)
	if f > 0.0:
		p._add_state("low_health", {"range_yd": -t.low_health_range_yd * f,
			"accuracy_spread_deg": t.low_health_spread * f, "injury_risk": t.low_health_injury * f})
	f = CareerTuning.lowness(data.stat("social"), t.low_social_threshold)
	if f > 0.0:
		p._add_state("low_social", {"pressure_sensitivity": t.low_social_pressure * f})
	if data.stat("fun") < t.low_fun_threshold:
		p._add_state("low_fun", {})  # no kick effect: slows Resilience gains

	# 3. Injury (Toughness softens it).
	if data.is_injured():
		var sev := float(data.injury.get("severity", 0.0))
		var shield := 1.0 - t.toughness_injury_shield * tough / 100.0
		p._add_state("injured", {
			"range_yd": -t.injury_range_yd * sev * shield,
			"accuracy_spread_deg": t.injury_spread * sev * shield})

	# 4. Traits' passive effects, then perks (perks.json "profile"; miss streak).
	var streak_scale := 1.0 + Perks.total(data, "miss_streak")
	for line in Perks.profile_lines(data):
		p._add_line(str(line[0]), line[1], "perk")
	for k in ["onside_window_yd", "onside_aim_deg", "onside_recover", "return_cut_yd", "clutch_pressure"]:
		var v := Perks.total(data, k)
		if v != 0.0:
			p.perk_fx[k] = v
	for id in data.traits:
		var def := CareerContent.trait_def(id)
		var passive: Dictionary = def.get("passive", {})
		streak_scale += float(passive.get("miss_streak", 0.0))
		var fx: Dictionary = passive.get("profile", {})
		if not fx.is_empty():
			p._add_line(str(def.get("name", id)), fx, "trait")

	# 5. This week's game-day modifiers (from scenario choices).
	var mods: Array = ctx.get("modifiers", data.week_modifiers).duplicate()
	mods.append_array(ctx.get("extra_modifiers", []))
	for id in mods:
		var m := CareerContent.modifier(str(id))
		if m.is_empty():
			push_warning("KickProfile: unknown modifier '%s'" % id)
			continue
		p._add_line(str(m.get("label", id)), m.get("effects", {}), "modifier")

	# 5a. Cold or snow (late season): yards lost, snow also costs aim.
	# Perks with "weather_keep" (Cold Weather Kicker) keep only that share.
	var w := _week_weather(data)
	var temp := str(w.get("temp", ""))
	if temp in ["cold", "snow"]:
		var keep := Perks.weather_keep(data)
		var fx := {"range_yd": -float(w.get("chill", 1)) * keep}
		if temp == "snow":
			fx["accuracy_spread_deg"] = t.snow_spread * keep
		fx.merge(Perks.bad_weather_fx(data))
		p._add_state("snow_game" if temp == "snow" else "cold_game", fx)

	# 5b. The people around you (coach, holder, Tyler Brooks); nothing at neutral.
	for line in Relationships.profile_lines(data, t):
		if describe(line[1]) != "":  # too small to notice: no Outlook line either
			p._add_line(str(line[0]), line[1], "person")

	# 6. Miss streak in this game (Resilience and traits soften it).
	var streak := mini(int(ctx.get("miss_streak", 0)), t.miss_streak_cap)
	if streak > 0:
		var per := t.miss_streak_pressure * (1.0 - t.resilience_streak_shield * res / 100.0)
		p._add_state("miss_streak", {"pressure_add": per * streak * maxf(streak_scale, 0.0)})

	p.injury_risk *= maxf(1.0 + Perks.total(data, "injury_risk_mult"), 0.0)
	p._clamp(t)
	p._finish_range(data, t)
	return p


## This week's weather from the schedule ({} if none).
static func _week_weather(data: CareerData) -> Dictionary:
	for e in data.schedule:
		if int(e.get("week", 0)) == data.week:
			var w: Variant = e.get("weather", {})
			return w if w is Dictionary else {}
	return {}


## Today's ranges from the paper range + range_yd, then the launch speed:
## range physics on = a full flick reaches fg_range; off = the old Power curve
## (game-day yards back in old power units). Kickoffs carry kickoff_range
## either way (CareerGameMode.kickoff_rules_for divides by power_mult).
func _finish_range(data: CareerData, t: CareerTuning) -> void:
	fg_range = clampf(fg_range_base + range_yd, t.range_min, t.range_cap)
	kickoff_range = clampf(KickRange.kickoff_range(data, t) + range_yd, t.range_min, t.kickoff_range_cap)
	if data.range_physics:
		power_mult = KickRange.speed_mult_for(fg_range, KickRange.kick_tuning(), t.range_physics_margin_yd)
	else:
		power_mult = clampf(CareerTuning.blend(t.power_mult_at_0, t.power_mult_at_100, data.stat("power"),
			t.power_curve) + range_yd / maxf(t.legacy_power_mult_yards, 1.0), 0.3, 2.0)


## What the kick scene reads (field_goal_game.gd `modifiers`).
func to_kick_modifiers() -> KickModifiers:
	var m := KickModifiers.new()
	m.power_mult = power_mult
	m.accuracy_spread_deg = accuracy_spread_deg
	m.pressure_sensitivity = pressure_sensitivity
	m.window_mult = window_mult
	m.wobble_mult = wobble_mult
	m.wind_mult = wind_mult
	m.kickoff_range_yd = kickoff_range
	m.kickoff_mult = kickoff_range / KickoffRules.new().max_carry_yards
	return m


func value(field: String) -> float:
	return float(get(field))


func to_dict() -> Dictionary:
	var d := {}
	for f in FIELDS:
		d[f] = value(f)
	return d


## Swipe power (0..1) needed to clear the crossbar from `yards` with no wind,
## for this profile's power_mult. > 1 = out of range. Uses the kick's own
## ballistics (no drag) from KickTuning.
func power_needed(yards: float, kt: KickTuning) -> float:
	var d := yards * KickSituation.YARD_TO_M
	var th := deg_to_rad(kt.launch_elevation_deg)
	var rise := d * tan(th) - GoalPosts.CROSSBAR_HEIGHT
	if rise <= 0.0:
		return INF
	var v := sqrt(kt.gravity * d * d / (2.0 * cos(th) * cos(th) * rise))
	var top := kt.max_launch_speed * power_mult
	if top <= kt.min_launch_speed:
		return INF
	# Same "Power %" the kick's debug readout shows (after the swipe power curve).
	return maxf((v - kt.min_launch_speed) / (top - kt.min_launch_speed), 0.0)


## Today's field goal range (yards): what the Hub, the Outlook and the coach use.
## With range physics off the ball itself can carry further (reach_yards()).
func max_range_yards(_kt: KickTuning = null) -> int:
	return floori(fg_range + 0.001)


## How far a full flick actually carries over the bar (no wind), from the
## kick's own ballistics: = max_range_yards() with range physics on.
func reach_yards(kt: KickTuning = null) -> int:
	var k := kt if kt != null else KickRange.kick_tuning()
	var yd := 15
	while yd < 120 and power_needed(yd + 1, k) <= 1.0:
		yd += 1
	return yd


# --- internals ---------------------------------------------------------------------

func _apply(effects: Dictionary) -> void:
	for k in effects:
		if k in FIELDS:
			set(k, value(k) + float(effects[k]))
		elif k == "power_mult":  # old data: power is range now
			range_yd += float(effects[k]) * _legacy_yards


func _add_state(id: String, effects: Dictionary, good := false) -> void:
	var s := CareerContent.state(id)
	_apply(effects)
	var detail := describe(effects)
	var note := str(s.get("note", ""))
	if detail == "":
		detail = note
	outlook.append({"label": str(s.get("label", id)), "detail": detail, "note": note,
		"good": good, "source": "state"})


func _add_line(label: String, effects: Dictionary, source: String) -> void:
	_apply(effects)
	outlook.append({"label": label, "detail": describe(effects),
		"good": net_good(effects), "source": source})


func _clamp(t: CareerTuning) -> void:
	accuracy_spread_deg = clampf(accuracy_spread_deg, 0.0, t.spread_max)
	wobble_mult = clampf(wobble_mult, t.wobble_mult_min, t.wobble_mult_max)
	window_mult = clampf(window_mult, t.window_mult_min, t.window_mult_max)
	pressure_sensitivity = clampf(pressure_sensitivity, t.pressure_sens_min, t.pressure_sens_max)
	pressure_add = clampf(pressure_add, 0.0, t.pressure_add_max)
	wind_mult = clampf(wind_mult, t.wind_mult_min, t.wind_mult_max)
	injury_risk = clampf(injury_risk, 0.0, t.injury_risk_max)


## "+accuracy, steadier aim" from a set of effects (wording in modifiers.json).
static func describe(effects: Dictionary) -> String:
	var parts := PackedStringArray()
	for k in FIELDS:  # fixed order, so lines read consistently
		if not effects.has(k) or absf(float(effects[k])) < WORD_EPSILON:
			continue
		var helps := _helps(k, float(effects[k]))
		if k == "range_yd":  # yards are worth showing as a number
			var yd := roundi(float(effects[k]))
			parts.append(("%+d yd%s" % [yd, "" if absi(yd) == 1 else "s"]) if yd != 0 \
				else ("+range" if helps else "-range"))
			continue
		parts.append(str(CareerContent.words(k)[0 if helps else 1]))
	return ", ".join(parts)


## True if the effects help the kicker more than they hurt (by count).
static func net_good(effects: Dictionary) -> bool:
	var score := 0
	for k in effects:
		if k == "power_mult":
			score += 1 if float(effects[k]) > 0.0 else -1
		elif k in FIELDS and absf(float(effects[k])) >= WORD_EPSILON:
			score += 1 if _helps(k, float(effects[k])) else -1
	return score >= 0


static func _helps(field: String, delta: float) -> bool:
	return delta < 0.0 if field in LOWER_IS_BETTER else delta > 0.0
