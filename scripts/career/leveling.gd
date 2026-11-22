class_name Leveling
extends RefCounted
## Overall rating and the per-stage attribute caps (numbers: LevelingConfig,
## res://tuning/leveling.tres).
##
## Overall = the average of the four football attributes. Each stage has a
## highest overall and a highest single attribute. The caps are enforced in
## every way an attribute can rise:
##   * SkillPoints.can_raise / upgrade: a point past a cap can't be bought;
##   * CareerStats._resolve: gains (scenarios, relationships...) stop at the caps;
##   * enforce(): a hard clamp when a stage ends (CareerManager) and on load.
## So leaving high school above hs_overall_cap is impossible.

const PATH := "res://tuning/leveling.tres"
const STATS := ["power", "accuracy", "resilience", "toughness"]

static var _cached: LevelingConfig


static func config() -> LevelingConfig:
	if _cached == null:
		var r: Variant = load(PATH) if ResourceLoader.exists(PATH) else null
		_cached = r if r is LevelingConfig else LevelingConfig.new()
	return _cached


## Tests / tools: use these numbers instead of the file (null = back to the file).
static func use_config(cfg: LevelingConfig) -> void:
	_cached = cfg


## Average of the four football attributes.
static func overall(c: CareerData) -> float:
	return overall_of({"power": c.stat("power"), "accuracy": c.stat("accuracy"),
		"resilience": c.stat("resilience"), "toughness": c.stat("toughness")})


static func overall_of(values: Dictionary) -> float:
	var sum := 0.0
	for s in STATS:
		sum += float(values.get(s, 0.0))
	return sum / STATS.size()


static func overall_cap(stage: String) -> float:
	var g := config()
	match stage:
		CareerData.STAGE_HIGH_SCHOOL:
			return minf(g.hs_overall_cap, g.attribute_max)
		CareerData.STAGE_JUCO, CareerData.STAGE_COLLEGE:
			return minf(g.college_overall_cap, g.attribute_max)
	return minf(g.pro_overall_cap, g.attribute_max)


static func attribute_cap(stage: String) -> float:
	var g := config()
	match stage:
		CareerData.STAGE_HIGH_SCHOOL:
			return minf(g.hs_attribute_cap, g.attribute_max)
		CareerData.STAGE_JUCO, CareerData.STAGE_COLLEGE:
			return minf(g.college_attribute_cap, g.attribute_max)
	return minf(g.pro_attribute_cap, g.attribute_max)


## The highest `stat` may go right now, given the other attributes in `values`
## (defaults to the career's): the stage's attribute cap, and no higher than
## keeps the overall within the stage's overall cap.
static func max_value(c: CareerData, stat: String, values: Dictionary = {}) -> float:
	var v := values if not values.is_empty() else _values(c)
	var others := 0.0
	for s in STATS:
		if s != stat:
			others += float(v.get(s, 0.0))
	var by_overall := overall_cap(c.stage) * STATS.size() - others
	return minf(attribute_cap(c.stage), by_overall)


## Why `stat` can't go higher now ("" = it can): for the Skills screen.
static func cap_reason(c: CareerData, stat: String) -> String:
	var now := c.stat(stat)
	if now + 1.0 <= max_value(c, stat) + 0.001:
		return ""
	if now + 1.0 > config().attribute_max + 0.001:
		return "Maxed out."
	var where := stage_word(c.stage)
	if now + 1.0 > attribute_cap(c.stage) + 0.001:
		return "At the %s limit for one attribute (%d)." % [where, roundi(attribute_cap(c.stage))]
	return "At the %s overall limit (%d): raise it in the next stage." % [where, roundi(overall_cap(c.stage))]


static func stage_word(stage: String) -> String:
	match stage:
		CareerData.STAGE_HIGH_SCHOOL:
			return "high school"
		CareerData.STAGE_JUCO, CareerData.STAGE_COLLEGE:
			return "college"
	return "pro"


## Hard clamp to the career's stage caps: lowers the highest attributes first
## until every attribute and the overall fit. Returns {stat: points lowered}.
static func enforce(c: CareerData) -> Dictionary:
	var lowered := {}
	var acap := attribute_cap(c.stage)
	for s in STATS:
		if c.stat(s) > acap:
			lowered[s] = float(lowered.get(s, 0.0)) + c.stat(s) - acap
			c.set_stat(s, acap)
	var ocap := overall_cap(c.stage)
	var guard := 0
	while overall(c) > ocap + 0.0001 and guard < 1000:
		guard += 1
		var top := ""
		for s in STATS:
			if top == "" or c.stat(s) > c.stat(top):
				top = s
		var excess := (overall(c) - ocap) * STATS.size()
		# Bring the top attribute down to the next highest (or by the whole excess).
		var second := -INF
		for s in STATS:
			if s != top:
				second = maxf(second, c.stat(s))
		var cut := minf(excess, maxf(c.stat(top) - second, 0.0))
		if cut <= 0.0:
			cut = excess / STATS.size()  # all equal: lower them evenly
			for s in STATS:
				lowered[s] = float(lowered.get(s, 0.0)) + cut
				c.set_stat(s, c.stat(s) - cut)
			continue
		lowered[top] = float(lowered.get(top, 0.0)) + cut
		c.set_stat(top, c.stat(top) - cut)
	return lowered


## A loaded career over its stage's caps (a save from before them): clamp it,
## refund what the removed points would cost now (clamp_refund_mult), and say so
## on the Hub. Returns the refund (0 = nothing to do).
static func fix_old_save(c: CareerData, t: CareerTuning) -> int:
	var before := _values(c)
	var lowered := enforce(c)
	if lowered.is_empty():
		return 0
	var refund := 0.0
	for s in lowered:
		var top := float(before[s])
		var bottom := c.stat(s)
		var lvl := floorf(bottom)
		while lvl < top - 0.001:
			var part := minf(lvl + 1.0, top) - maxf(lvl, bottom)
			refund += SkillPoints.cost_at(lvl, t) * maxf(part, 0.0)
			lvl += 1.0
	var sp := roundi(refund * config().clamp_refund_mult)
	if sp > 0:
		SkillPoints.earn(c, sp, "Refund (attribute caps)")
	var names := PackedStringArray()
	for s in lowered:
		names.append("%s -%d" % [str(CareerData.STAT_NAMES.get(s, s)), ceili(float(lowered[s]) - 0.001)])
	var text := "New attribute limits for %s: %s. You got %d skill points back." % [
		stage_word(c.stage), ", ".join(names), sp]
	c.notice = text if c.notice == "" else c.notice + " " + text
	return sp


static func _values(c: CareerData) -> Dictionary:
	var v := {}
	for s in STATS:
		v[s] = c.stat(s)
	return v
