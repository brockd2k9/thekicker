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
##   Power      -> power_mult           (range: top launch speed)
##   Accuracy   -> accuracy_spread_deg  (random aim error at release)
##                 wobble_mult          (pressure aim wobble)
##                 window_mult          (time to swipe after the hold)
##   Resilience -> pressure_sensitivity (how hard situation pressure hits)
##                 pressure_add         (miss streak in this game)
##   Toughness  -> wind_mult            (wind push), injury penalties, injury_risk
##   Energy / Health / Social low -> penalties (see CareerTuning "Low Life Stats")

## Profile fields that modifiers and traits may change (data/career/*.json).
const FIELDS := ["power_mult", "accuracy_spread_deg", "wobble_mult", "window_mult",
	"pressure_sensitivity", "pressure_add", "wind_mult", "injury_risk"]
## Fields where a smaller number is better for the kicker.
const LOWER_IS_BETTER := ["accuracy_spread_deg", "wobble_mult", "pressure_sensitivity",
	"pressure_add", "wind_mult", "injury_risk"]
## Changes smaller than this don't get an Outlook word.
const WORD_EPSILON := 0.005

var power_mult: float = 1.0
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


## data: the career. ctx (optional): {"miss_streak": int} during a game, and
## "modifiers": [ids] to override data.week_modifiers (debug screen).
static func build(data: CareerData, tuning: CareerTuning, ctx: Dictionary = {}) -> KickProfile:
	var p := KickProfile.new()
	var t := tuning
	var power := data.stat("power")
	var acc := data.stat("accuracy")
	var res := data.stat("resilience")
	var tough := data.stat("toughness")

	# 1. Football stats set the baseline.
	p.power_mult = CareerTuning.blend(t.power_mult_at_0, t.power_mult_at_100, power, t.power_curve)
	p.accuracy_spread_deg = CareerTuning.blend(t.spread_at_0, t.spread_at_100, acc, t.accuracy_curve)
	p.wobble_mult = CareerTuning.blend(t.wobble_at_0, t.wobble_at_100, acc)
	p.window_mult = CareerTuning.blend(t.window_at_0, t.window_at_100, acc)
	p.pressure_sensitivity = CareerTuning.blend(t.pressure_sens_at_0, t.pressure_sens_at_100, res)
	p.wind_mult = CareerTuning.blend(t.wind_mult_at_0, t.wind_mult_at_100, tough)
	p.injury_risk = t.injury_base_risk - t.toughness_injury_risk_cut * tough / 100.0

	# 2. Low life stats.
	var f := CareerTuning.lowness(data.stat("energy"), t.low_energy_threshold)
	if f > 0.0:
		p._add_state("low_energy", {
			"power_mult": -t.low_energy_power * f, "wobble_mult": t.low_energy_wobble * f})
	f = CareerTuning.lowness(data.stat("health"), t.low_health_threshold)
	if f > 0.0:
		p._add_state("low_health", {
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
			"power_mult": -t.injury_power * sev * shield,
			"accuracy_spread_deg": t.injury_spread * sev * shield})

	# 4. Traits' passive effects.
	var streak_scale := 1.0
	for id in data.traits:
		var def := CareerContent.trait_def(id)
		var passive: Dictionary = def.get("passive", {})
		streak_scale += float(passive.get("miss_streak", 0.0))
		var fx: Dictionary = passive.get("profile", {})
		if not fx.is_empty():
			p._add_line(str(def.get("name", id)), fx, "trait")

	# 5. This week's game-day modifiers (from scenario choices).
	var mods: Array = ctx.get("modifiers", data.week_modifiers)
	for id in mods:
		var m := CareerContent.modifier(str(id))
		if m.is_empty():
			push_warning("KickProfile: unknown modifier '%s'" % id)
			continue
		p._add_line(str(m.get("label", id)), m.get("effects", {}), "modifier")

	# 6. Miss streak in this game (Resilience and traits soften it).
	var streak := mini(int(ctx.get("miss_streak", 0)), t.miss_streak_cap)
	if streak > 0:
		var per := t.miss_streak_pressure * (1.0 - t.resilience_streak_shield * res / 100.0)
		p._add_state("miss_streak", {"pressure_add": per * streak * maxf(streak_scale, 0.0)})

	p._clamp(t)
	return p


## What the kick scene reads (field_goal_game.gd `modifiers`).
func to_kick_modifiers() -> KickModifiers:
	var m := KickModifiers.new()
	m.power_mult = power_mult
	m.accuracy_spread_deg = accuracy_spread_deg
	m.pressure_sensitivity = pressure_sensitivity
	m.window_mult = window_mult
	m.wobble_mult = wobble_mult
	m.wind_mult = wind_mult
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


## Longest field goal (yards) at full swipe power, no wind.
func max_range_yards(kt: KickTuning) -> int:
	var yd := 20
	while yd < 120 and power_needed(yd + 1, kt) <= 1.0:
		yd += 1
	return yd


# --- internals ---------------------------------------------------------------------

func _apply(effects: Dictionary) -> void:
	for k in effects:
		if k in FIELDS:
			set(k, value(k) + float(effects[k]))


func _add_state(id: String, effects: Dictionary) -> void:
	var s := CareerContent.state(id)
	_apply(effects)
	var detail := describe(effects)
	var note := str(s.get("note", ""))
	if detail == "":
		detail = note
	outlook.append({"label": str(s.get("label", id)), "detail": detail, "note": note,
		"good": false, "source": "state"})


func _add_line(label: String, effects: Dictionary, source: String) -> void:
	_apply(effects)
	outlook.append({"label": label, "detail": describe(effects),
		"good": net_good(effects), "source": source})


func _clamp(t: CareerTuning) -> void:
	power_mult = clampf(power_mult, t.power_mult_min, t.power_mult_max)
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
		parts.append(str(CareerContent.words(k)[0 if helps else 1]))
	return ", ".join(parts)


## True if the effects help the kicker more than they hurt (by count).
static func net_good(effects: Dictionary) -> bool:
	var score := 0
	for k in effects:
		if k in FIELDS and absf(float(effects[k])) >= WORD_EPSILON:
			score += 1 if _helps(k, float(effects[k])) else -1
	return score >= 0


static func _helps(field: String, delta: float) -> bool:
	return delta < 0.0 if field in LOWER_IS_BETTER else delta > 0.0
