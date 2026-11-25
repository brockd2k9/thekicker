class_name KickoffJudge
extends RefCounted
## Judges kickoffs and onside kicks from where the 3D ball actually came down.
## Pure logic, no scene access. Positions are meters relative to the tee:
## x = toward the kicker's right, z = downfield is negative.
##
## Every result is a Dictionary the career game sim understands
## (GameSim.resolve_call) plus what the HUD banner shows:
## "text" is the play-by-play sentence; "detail" is the short line under the banner.
##   kickoff: {result, banner, detail, good, quality, carry, start_spot, text}
##     result: "touchback" / "deep" / "returned" / "short" / "out_of_bounds"
##   onside:  {result, banner, detail, good, recovered, hop, carry, text}
##     hop: the kick itself was good (right distance and aim), recovered or not
##     result: "recovered" / "lost" / "out_of_bounds"

const YARD := 0.9144
## Half the width of the field (53 1/3 yards), as drawn by field.gdshader.
const FIELD_HALF_WIDTH := 24.38
## Fielded inside this yard line = deep kick; at or beyond the short line = short kick.
const DEEP_LINE := 10.0
const SHORT_LINE := 25.0


## landing: where the ball first came down. hang: seconds in the air (game time).
static func kickoff(landing: Vector3, hang: float, r: KickoffRules,
		rng: RandomNumberGenerator) -> Dictionary:
	var carry := maxf(-landing.z / YARD, 0.0)
	var to_goal := float(r.to_goal_yards())
	if absf(landing.x) > FIELD_HALF_WIDTH:
		return {"result": "out_of_bounds", "banner": "OUT OF BOUNDS", "good": false, "quality": 0.1,
			"carry": carry, "start_spot": r.oob_spot, "detail": "Flag  -  ball at the %d" % r.oob_spot,
			"text": "Kickoff sails out of bounds. Flag. Ball at the %d." % r.oob_spot}
	if carry >= to_goal:
		return {"result": "touchback", "banner": "TOUCHBACK", "good": true, "quality": 1.0,
			"carry": carry, "start_spot": r.touchback_spot,
			"detail": "%d yards  -  ball at the %d" % [roundi(carry), r.touchback_spot],
			"text": "Kickoff %d yards. Into the end zone: touchback, ball at the %d." % [
				roundi(carry), r.touchback_spot]}
	# Fielded in the field of play: same quality rule as the old sideline pad.
	var inside := to_goal - carry  # yards from the receiving team's goal line
	var quality := clampf(1.0 - inside / 40.0, 0.2, 0.9)
	var ret := rng.randf_range(r.return_min_yards, r.return_max_yards) \
		- r.return_hang_cut * maxf(hang - 3.0, 0.0)
	# Capped at midfield: a simple return, not a touchdown run.
	var start := clampi(roundi(inside + maxf(ret, 3.0)), 1, 50)
	var result := "returned"
	var banner := "RETURNED"
	if inside < DEEP_LINE:
		result = "deep"
		banner = "DEEP KICK"
	elif inside >= SHORT_LINE:
		result = "short"
		banner = "SHORT KICK"
	return {"result": result, "banner": banner, "good": result != "short", "quality": quality,
		"carry": carry, "start_spot": start,
		"detail": "Fielded at the %d, out to %s" % [roundi(inside), yard_line_text(start)],
		"text": "Kickoff %d yards, fielded at the %d, returned to %s." % [
			roundi(carry), roundi(inside), yard_line_text(start)]}


## rest: where the ball stopped. aim_deg: the kick's aim (incl. random error).
static func onside(rest: Vector3, aim_deg: float, r: KickoffRules,
		rng: RandomNumberGenerator) -> Dictionary:
	var carry := maxf(-rest.z / YARD, 0.0)
	if absf(rest.x) > FIELD_HALF_WIDTH:
		return {"result": "out_of_bounds", "banner": "OUT OF BOUNDS", "good": false, "recovered": false,
			"hop": false, "carry": carry, "detail": "Out after %d yards" % roundi(carry), "text": "Onside kick rolls out of bounds after %d yards. Their ball." % roundi(carry)}
	# Same risk / reward as the old sideline pad.
	var good := carry >= r.onside_min_yards and carry <= r.onside_max_yards \
		and absf(aim_deg) <= r.onside_aim_deg
	var chance := r.onside_good_chance if good else r.onside_poor_chance
	var recovered := rng.randf() < chance
	var text := "Onside kick travels %d yards" % roundi(carry)
	text += ", a perfect hop!" if good else (", too far." if carry > r.onside_max_yards else ".")
	return {"result": "recovered" if recovered else "lost",
		"banner": "RECOVERED!" if recovered else "THEIR BALL", "good": recovered,
		"recovered": recovered, "hop": good, "carry": carry, "text": text,
		"detail": "%d yards%s" % [roundi(carry), "  -  a perfect hop!" if good else ""]}


## "the 27" or "midfield" (yards from the receiving team's goal line, <= 50).
static func yard_line_text(yards_from_goal: int) -> String:
	if yards_from_goal >= 50:
		return "midfield"
	return "the %d" % yards_from_goal
