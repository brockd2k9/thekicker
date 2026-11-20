class_name Aging
extends RefCounted
## From age 30 (CareerTuning "Aging"), each football attribute declines at
## the end of every season, a little more every year:
##   decline = (aging_base + aging_per_year * (age - aging_start_age)) * rate
## Power and Toughness fade fastest, Accuracy slower, Resilience slowest
## (experience). Perks can slow one attribute (Iron Leg: Power at half).
## On the Skills screen (Maintenance) you can preserve an attribute for the
## season with skill points: decline * (cost of its next point) * maintain_cost_mult.
## Preserved attributes skip that season's decline. A careful player can hold
## a high level into the mid-30s, but the cost keeps climbing.

const STATS := ["power", "accuracy", "resilience", "toughness"]


static func rate(stat: String, t: CareerTuning) -> float:
	match stat:
		"power":
			return t.aging_rate_power
		"toughness":
			return t.aging_rate_toughness
		"accuracy":
			return t.aging_rate_accuracy
		"resilience":
			return t.aging_rate_resilience
	return 0.0


## Is aging on for this career (this season counts)?
static func active(c: CareerData, t: CareerTuning) -> bool:
	return c.age >= t.aging_start_age and c.stage != CareerData.STAGE_RETIRED


## Points `stat` loses at the end of this season (0 before aging starts).
static func decline(c: CareerData, stat: String, t: CareerTuning) -> float:
	if not active(c, t):
		return 0.0
	var d := (t.aging_base + t.aging_per_year * float(c.age - t.aging_start_age)) * rate(stat, t)
	d *= maxf(1.0 + Perks.aging_change(c, stat), 0.0)
	return snappedf(minf(d, c.stat(stat)), 0.1)


## Skill points to preserve `stat` this season (0 = nothing to preserve).
static func maintain_cost(c: CareerData, stat: String, t: CareerTuning) -> int:
	var d := decline(c, stat, t)
	if d <= 0.0:
		return 0
	return int(ceilf(d * SkillPoints.cost_at(c.stat(stat), t) * t.maintain_cost_mult))


static func maintained(c: CareerData, stat: String) -> bool:
	return int(c.maintained.get(stat, -1)) == c.season


static func can_maintain(c: CareerData, stat: String, t: CareerTuning) -> bool:
	var cost := maintain_cost(c, stat, t)
	return cost > 0 and not maintained(c, stat) and c.skill_points >= cost


static func maintain(c: CareerData, stat: String, t: CareerTuning) -> bool:
	if not can_maintain(c, stat, t):
		return false
	c.skill_points -= maintain_cost(c, stat, t)
	c.maintained[stat] = c.season
	return true


## Season end: unpreserved attributes decline. Returns {stat: -points} (what
## dropped) and clears this season's maintenance.
static func apply_season_end(c: CareerData, t: CareerTuning) -> Dictionary:
	var out := {}
	if not active(c, t):
		return out
	for s in STATS:
		if maintained(c, s):
			continue
		var d := decline(c, s, t)
		if d > 0.0:
			c.set_stat(s, c.stat(s) - d)
			out[s] = -d
	c.maintained.clear()
	return out
