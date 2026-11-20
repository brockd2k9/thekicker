class_name KickRange
extends RefCounted
## Field goal range and kickoff range: how far this kicker can kick.
##
## Field goal range is the longest field goal a full-strength flick clears
## (no wind). It grows with Power along CareerTuning's "Power -> Range" curve,
## plus perks, and life stats add or take a few yards on game day
## (KickProfile.range_yd). The kick's launch speed is then set from the range
## (speed_mult_for()), so a 100% flick reaches exactly your range and no further.
##
## Kickoff range is its own Power curve (yards of carry at a full flick).
## Practice and Challenge never use any of this (KickModifiers defaults).


const KICK_TUNING_PATH := "res://tuning/kick_tuning.tres"
static var _kt: KickTuning


## The kick scene's tuning (ballistics for the range -> launch speed mapping).
static func kick_tuning() -> KickTuning:
	if _kt == null:
		_kt = load(KICK_TUNING_PATH) as KickTuning
		if _kt == null:
			_kt = KickTuning.new()
	return _kt


## Power curve shared by both ranges: 0 at range_power_start, 1 at Power 100.
static func _x(power: float, t: CareerTuning) -> float:
	var span := maxf(100.0 - t.range_power_start, 1.0)
	return clampf((power - t.range_power_start) / span, 0.0, 1.0)


## Base field goal range (yards) from Power alone.
static func fg_from_power(power: float, t: CareerTuning) -> float:
	return t.range_at_start + (t.range_at_100 - t.range_at_start) * pow(_x(power, t), t.range_curve)


## Base kickoff range (yards of carry) from Power alone.
static func kickoff_from_power(power: float, t: CareerTuning) -> float:
	return t.kickoff_at_start + (t.kickoff_at_100 - t.kickoff_at_start) * pow(_x(power, t), t.kickoff_curve)


## Field goal range on paper (Power + perks + a "range" brand deal), before
## game day. What the Hub shows.
static func fg_range(c: CareerData, t: CareerTuning, power: float = -1.0) -> float:
	var p := c.stat("power") if power < 0.0 else power
	return clampf(fg_from_power(p, t) + perk_yards(c, "range_yd") + Followers.deal_yards(c), t.range_min,
		fg_cap(c, t))


## Highest field goal range this kicker can have, even on a great day:
## range_at_100 (66) without perks; perk range yards raise it (Big Leg 68, Big
## Leg + Cannon 70), never past the range_cap hard cap (70).
static func fg_cap(c: CareerData, t: CareerTuning) -> float:
	return minf(t.range_at_100 + maxf(perk_yards(c, "range_yd"), 0.0), t.range_cap)


## Kickoff range on paper (Power + perks), before game day.
static func kickoff_range(c: CareerData, t: CareerTuning, power: float = -1.0) -> float:
	var p := c.stat("power") if power < 0.0 else power
	return clampf(kickoff_from_power(p, t) + perk_yards(c, "kickoff_yd"), t.range_min, t.kickoff_range_cap)


## Yards from perks you own ("range_yd" / "kickoff_yd", perks.json).
static func perk_yards(c: CareerData, key: String) -> float:
	return Perks.total(c, key)


## Can a full kickoff reach the end zone at this stage? (tee spot from game_params)
static func touchback_possible(kickoff_yards: float, params: Dictionary, t: CareerTuning) -> bool:
	var spot := int(params.get("kickoff_spot", t.kickoff_spot_yards))
	return kickoff_yards >= 100.0 - spot


## The KickModifiers.power_mult that makes a 100% flick clear the crossbar at
## exactly `yards` (+ margin) with no wind, using the kick's own ballistics.
static func speed_mult_for(yards: float, kt: KickTuning, margin: float = 0.0) -> float:
	var d := (yards + margin) * KickSituation.YARD_TO_M
	var th := deg_to_rad(kt.launch_elevation_deg)
	var rise := d * tan(th) - GoalPosts.CROSSBAR_HEIGHT
	if rise <= 0.0 or kt.max_launch_speed <= 0.0:
		return 1.0
	var v := sqrt(kt.gravity * d * d / (2.0 * cos(th) * cos(th) * rise))
	return v / kt.max_launch_speed
