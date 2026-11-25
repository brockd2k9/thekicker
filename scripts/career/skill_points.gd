class_name SkillPoints
extends RefCounted
## Skill points: how the football attributes (Power, Accuracy, Resilience,
## Toughness) grow. Earned on the field (makes, long and clutch makes, game
## winners, perfect games, good seasons) and in practice (every week, the
## offseason, scenario choices' "skill_points"); spent one attribute point at a
## time on the Skills screen. Each point costs more the higher the attribute is.
##
## THE one place for skill point economy:
##   granting:  earn() (and purchase() for bought points). Nothing else adds SP.
##   costs:     cost_at() / cost() / cost_of_next(). Nothing else computes a price
##              (aging maintenance and the Skills screen call these).
## Earn amounts: CareerTuning "Skill Points". Cost curve and the per-stage caps
## an upgrade can't pass: LevelingConfig (res://tuning/leveling.tres), Leveling.
##
## Upgrades bypass CareerStats' diminishing returns on purpose: the rising cost
## is the diminishing return. Scenario choices still change football stats
## directly (through CareerStats, scaled by scenario_football_scale).


## Dev hook for the balance simulator: when set to a Dictionary, every earn()
## adds its points under its source text. null (the default) in the game.
static var tally: Variant = null


## Adds earned points (also counted for the season and career) and a line for
## this week's Results. n <= 0 does nothing.
static func earn(c: CareerData, n: int, text: String) -> void:
	if n <= 0:
		return
	if tally is Dictionary:
		tally[text] = int(tally.get(text, 0)) + n
	c.skill_points += n
	c.sp_season += n
	c.sp_career += n
	c.sp_sources[text] = int(c.sp_sources.get(text, 0)) + n
	for e in c.sp_week:
		if str(e.get("text", "")) == text:
			e["sp"] = int(e.get("sp", 0)) + n
			return
	c.sp_week.append({"text": text, "sp": n})


## Skill points bought by the player (in-app purchase, later). The store only
## calls this; the points count like any other grant (under `source`).
static func purchase(c: CareerData, n: int, source: String = "Purchased") -> void:
	earn(c, n, source)
## Skill points that come every game or week (kicks, practice, the rival,
## choices), scaled by the season's length (CareerTuning.season_scale). The
## fraction left over carries to the next award (CareerData.flags
## "_sp_carry"), so a long season earns what a 10-game one did. Returns the
## points given.
static func earn_weekly(c: CareerData, n: int, text: String, t: CareerTuning) -> int:
	if n <= 0:
		return 0
	var v := n * t.season_scale(c.stage) + float(c.flags.get("_sp_carry", 0.0))
	var k := floori(v + 0.000001)
	c.flags["_sp_carry"] = maxf(v - k, 0.0)
	if k > 0:
		earn(c, k, text)
	return k


## A scenario choice's skill points (negative = practice skipped). Returns the
## change applied.
static func from_choice(c: CareerData, n: float, t: CareerTuning) -> int:
	var v := roundi(n * t.sp_scenario_scale)
	if v > 0:
		v = earn_weekly(c, v, "Choices", t)
	elif v < 0:
		v = -mini(-v, c.skill_points)
		c.skill_points += v
		c.sp_sources["Choices"] = int(c.sp_sources.get("Choices", 0)) + v
	return v


## Cost (SP) to raise an attribute from `level` to level + 1 (LevelingConfig:
## ceil(cost_base + cost_scale * (L/100)^cost_exponent)). `t` is unused (kept so
## every caller stays the same).
static func cost_at(level: float, _t: CareerTuning = null) -> int:
	var g := Leveling.config()
	var l := clampf(floorf(level), 0.0, 100.0)
	return int(ceilf(g.cost_base + g.cost_scale * pow(l / 100.0, g.cost_exponent)))


## Cost of the next point of `stat` for this career (0 = maxed).
static func cost(c: CareerData, stat: String, t: CareerTuning) -> int:
	if not can_raise(c, stat, t):
		return 0
	return cost_at(c.stat(stat), t)


## False at the attribute max or the stage's caps (Leveling.cap_reason says which).
static func can_raise(c: CareerData, stat: String, _t: CareerTuning = null) -> bool:
	return CareerData.group_of(stat) == CareerData.FOOTBALL \
		and c.stat(stat) + 1.0 <= Leveling.max_value(c, stat) + 0.001


## SP for the next n points of `stat` (0 if any of them is past a cap).
static func cost_of_next(c: CareerData, stat: String, n: int, t: CareerTuning = null) -> int:
	var lvl := c.stat(stat)
	if CareerData.group_of(stat) != CareerData.FOOTBALL or lvl + n > Leveling.max_value(c, stat) + 0.001:
		return 0
	var total := 0
	for i in n:
		total += cost_at(lvl + i, t)
	return total


static func affordable(c: CareerData, stat: String, t: CareerTuning) -> bool:
	return can_raise(c, stat, t) and c.skill_points >= cost(c, stat, t)


## Buys one point of `stat`. Returns false if it can't.
static func upgrade(c: CareerData, stat: String, t: CareerTuning) -> bool:
	if not affordable(c, stat, t):
		return false
	c.skill_points -= cost(c, stat, t)
	c.set_stat(stat, minf(c.stat(stat) + 1.0, Leveling.max_value(c, stat)))
	c.sp_upgrades[stat] = float(c.sp_upgrades.get(stat, 0.0)) + 1.0
	return true


## What one more point of `stat` changes, for the Skills screen preview:
## [{label, now, next}] as display strings (only lines that change).
static func preview(c: CareerData, stat: String, t: CareerTuning) -> Array:
	var out: Array = []
	if not can_raise(c, stat, t):
		return out
	var now := c.stat(stat)
	var nxt := minf(now + 1.0, Leveling.max_value(c, stat))
	match stat:
		"power":
			out.append(_line("FG range", "%.1f yd", KickRange.fg_range(c, t, now), KickRange.fg_range(c, t, nxt)))
			out.append(_line("Kickoff range", "%.1f yd", KickRange.kickoff_range(c, t, now),
				KickRange.kickoff_range(c, t, nxt)))
		"accuracy":
			out.append(_line("Aim error", "%.2f deg", CareerTuning.blend(t.spread_at_0, t.spread_at_100, now, t.accuracy_curve),
				CareerTuning.blend(t.spread_at_0, t.spread_at_100, nxt, t.accuracy_curve)))
			out.append(_line("Pressure wobble", "x%.3f", CareerTuning.blend(t.wobble_at_0, t.wobble_at_100, now),
				CareerTuning.blend(t.wobble_at_0, t.wobble_at_100, nxt)))
		"resilience":
			out.append(_line("Pressure effect", "x%.3f", CareerTuning.blend(t.pressure_sens_at_0, t.pressure_sens_at_100, now),
				CareerTuning.blend(t.pressure_sens_at_0, t.pressure_sens_at_100, nxt)))
			out.append(_line("Miss penalties (coach, team)", "-%.2f%%", t.kick_resilience_soften * now,
				t.kick_resilience_soften * nxt))
		"toughness":
			out.append(_line("Wind effect", "x%.3f", CareerTuning.blend(t.wind_mult_at_0, t.wind_mult_at_100, now),
				CareerTuning.blend(t.wind_mult_at_0, t.wind_mult_at_100, nxt)))
			out.append(_line("Weekly injury chance", "%.2f%%", (t.injury_base_risk - t.toughness_injury_risk_cut * now / 100.0) * 100.0,
				(t.injury_base_risk - t.toughness_injury_risk_cut * nxt / 100.0) * 100.0))
	return out


static func _line(label: String, fmt: String, a: float, b: float) -> Dictionary:
	return {"label": label, "now": fmt % a, "next": fmt % b}


# --- earning on the field ------------------------------------------------------------

## Skill points from one finished game's kicks (yours): [[text, sp], ...].
## range: today's field goal range (long makes near it count as long).
static func from_game(kicks: Array, range: float, t: CareerTuning) -> Array:
	var made := 0
	var long := 0
	var clutch := 0
	var winners := 0
	var att := 0
	for k in kicks:
		var kind := str(k.get("kind", ""))
		if not (kind in ["fg", "pat"]) or k.get("backup", false):
			continue
		att += 1
		if not k.get("made", false):
			continue
		if kind != "fg":
			continue
		made += 1
		var yd := int(k.get("yards", 0))
		if yd >= t.long_make_yards or yd >= range - t.sp_long_range_yd:
			long += 1
		if float(k.get("pressure", 0.0)) >= t.clutch_pressure:
			clutch += 1
		if "GAME WINNER" in str(k.get("label", "")):
			winners += 1
	var out: Array = []
	if made > 0:
		out.append(["Field goals made", made * t.sp_make])
	if long > 0:
		out.append(["Long makes", long * t.sp_long_make])
	if clutch > 0:
		out.append(["Clutch makes", clutch * t.sp_clutch_make])
	if winners > 0:
		out.append(["Game winner", winners * t.sp_game_winner])
	var all_made := att >= 2
	for k in kicks:
		if str(k.get("kind", "")) in ["fg", "pat"] and not k.get("made", false) and not k.get("backup", false):
			all_made = false
	if all_made:
		out.append(["Perfect game", t.sp_perfect_game])
	return out


## End-of-season bonus for the FG% (0 if not good enough).
static func season_bonus(c: CareerData, t: CareerTuning) -> int:
	var s := c.season_stats
	if int(s.get("fg_att", 0)) < t.poor_min_attempts:
		return 0
	var pct := Progression.fg_pct(s)
	if pct >= t.sp_great_season_pct:
		return t.sp_great_season
	if pct >= t.sp_good_season_pct:
		return t.sp_good_season
	return 0
