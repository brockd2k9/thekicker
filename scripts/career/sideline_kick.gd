class_name SidelineKick
extends RefCounted
## Kickoffs, onside kicks and the warmup net, swiped on the sideline pad.
## The swipe is turned into power and aim by the SAME math as the field goal
## (KickController.power_from_swipe + KickTuning aim settings, unchanged), and
## the career's KickProfile applies (power_mult, aim error). These are judged
## with simple rules instead of the 3D flight; numbers in CareerTuning
## ("Sideline Kicks"). Pure logic, no scene access.

## Returns {"ok": false, "hint"} for a swipe that can't be a kick, else
## {"ok": true, "power", "aim_deg"} (aim includes the profile's random error).
static func read_swipe(swipe: Swipe, kt: KickTuning, profile: KickProfile,
		rng: RandomNumberGenerator) -> Dictionary:
	var kc := KickController.new()
	var problem := kc.validate(swipe, kt)
	var power := kc.power_from_swipe(swipe, kt)
	kc.free()
	if problem != "":
		return {"ok": false, "hint": problem}
	var aim := clampf(swipe.tilt_deg() * kt.aim_sensitivity, -kt.max_aim_deg, kt.max_aim_deg)
	if profile.accuracy_spread_deg > 0.0:
		aim += rng.randfn(0.0, profile.accuracy_spread_deg)
	return {"ok": true, "power": power, "aim_deg": aim}


## {"quality": 0..1, "carry": yards, "text"}.
static func kickoff(k: Dictionary, profile: KickProfile, t: CareerTuning) -> Dictionary:
	var carry := t.kickoff_max_carry_yards * float(k["power"]) * profile.power_mult
	carry = maxf(carry, 5.0)
	var to_goal := 100.0 - t.kickoff_spot_yards  # yards from the kicking spot to the goal line
	var q := 0.0
	var text := ""
	if absf(float(k["aim_deg"])) > t.kickoff_oob_deg:
		q = 0.1
		text = "Kickoff sails out of bounds. Flag. Penalty."
	elif carry >= to_goal:
		q = 1.0
		text = "Kickoff %d yards. Into the end zone: touchback." % roundi(carry)
	else:
		var inside := to_goal - carry  # where it lands, yards from their goal line
		q = clampf(1.0 - inside / 40.0, 0.2, 0.9)
		text = "Kickoff %d yards, fielded at the %d." % [roundi(carry), roundi(inside)]
	return {"quality": q, "carry": carry, "text": text}


## {"recovered": bool, "good": bool, "carry", "text"}. rng rolls the recovery.
static func onside(k: Dictionary, profile: KickProfile, t: CareerTuning,
		rng: RandomNumberGenerator) -> Dictionary:
	var carry := t.kickoff_max_carry_yards * float(k["power"]) * profile.power_mult
	var good := carry >= t.onside_min_yards and carry <= t.onside_max_yards \
		and absf(float(k["aim_deg"])) <= t.onside_aim_deg
	var chance := t.onside_good_chance if good else t.onside_poor_chance
	var text := "Onside kick travels %d yards" % roundi(carry)
	text += ", a perfect hop!" if good else (", too far." if carry > t.onside_max_yards else ".")
	return {"recovered": rng.randf() < chance, "good": good, "carry": carry, "text": text}


## A strike into the warmup net: {"pure": bool, "text"}.
static func net(k: Dictionary, t: CareerTuning) -> Dictionary:
	var p := float(k["power"])
	var aim := absf(float(k["aim_deg"]))
	if aim > t.net_aim_deg:
		return {"pure": false, "text": "Hooked it off the edge of the net."}
	if p < t.net_power_min:
		return {"pure": false, "text": "Soft contact."}
	if p > t.net_power_max:
		return {"pure": false, "text": "Over-swung it."}
	return {"pure": true, "text": "Pure!"}


## Warmup result id from the number of pure strikes.
static func net_result(pure: int, t: CareerTuning) -> String:
	return "pure" if pure >= t.net_pure_needed else "loose"
