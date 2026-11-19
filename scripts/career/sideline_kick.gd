class_name SidelineKick
extends RefCounted
## The warmup net, swiped on the sideline pad. (Kickoffs and onside kicks
## moved to the 3D kick scene: KickoffJudge.)
## The swipe is turned into power and aim by the SAME math as the field goal
## (KickController.power_from_swipe + KickTuning aim settings, unchanged), and
## the career's KickProfile applies (power_mult, aim error). Judged with simple
## rules; numbers in CareerTuning ("Sideline Kicks"). Pure logic, no scene access.

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
