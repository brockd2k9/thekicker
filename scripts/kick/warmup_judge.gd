class_name WarmupJudge
extends RefCounted
## The sideline-net warmup rules (moved unchanged from the old 2D pad's
## SidelineKick.net / net_result). Pure logic, no scene access.
## A "pure" strike: swipe power in [power_min, power_max] and aim within
## aim_deg (aim includes the KickProfile's random error). Numbers come from
## CareerTuning ("Sideline Kicks": net_*).


## power: 0..1 swipe power (KickController.power_from_swipe, no power_mult).
## aim_deg: + = right. Returns {pure, banner, detail, good}.
static func strike(power: float, aim_deg: float, power_min: float, power_max: float,
		aim_limit: float) -> Dictionary:
	if absf(aim_deg) > aim_limit:
		var right := aim_deg > 0.0
		return {"pure": false, "good": false, "banner": "PUSHED IT" if right else "PULLED IT",
			"detail": "Off the %s edge of the net" % ("right" if right else "left")}
	if power < power_min:
		return {"pure": false, "good": false, "banner": "SOFT CONTACT", "detail": "Swing through it"}
	if power > power_max:
		return {"pure": false, "good": false, "banner": "OVER-SWUNG", "detail": "Ease off a little"}
	return {"pure": true, "good": true, "banner": "PURE!", "detail": "Good rhythm"}


## The session's result id for GameSim.set_warmup(): "pure" or "loose".
static func session_result(pure: int, pure_needed: int) -> String:
	return "pure" if pure >= pure_needed else "loose"
