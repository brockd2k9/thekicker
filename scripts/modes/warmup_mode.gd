class_name WarmupMode
extends KickMode
## The sideline-net warmup in the kick scene: `kicks` swipes into the net
## (WARMUP_NET), each judged by WarmupJudge, then a session result
## ("pure" / "loose") for GameSim.set_warmup(). No wind, no pressure, and not
## reported to GameState (field-goal stats).

var kicks: int = 3
var pure_needed: int = 2
var power_min: float = 0.5
var power_max: float = 0.92
var aim_deg: float = 6.0

var taken: int = 0
var pure: int = 0


static func from_tuning(t: CareerTuning) -> WarmupMode:
	var m := WarmupMode.new()
	m.kicks = t.net_kicks
	m.pure_needed = t.net_pure_needed
	m.power_min = t.net_power_min
	m.power_max = t.net_power_max
	m.aim_deg = t.net_aim_deg
	return m


func id() -> StringName:
	return &"warmup"


func kick_type() -> int:
	return KickSituation.KickType.WARMUP_NET


func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
	wind.set_conditions(rng, tuning, 0.0, 0.0)  # a sheltered sideline net: no wind
	var s := KickSituation.new()
	s.kick_type = KickSituation.KickType.WARMUP_NET
	s.distance_yards = 0
	s.label = "Kick %d of %d" % [taken + 1, kicks]
	return s


## One strike: power / aim as read from the swipe. Returns the judge's result.
func judge(power: float, aim: float) -> Dictionary:
	var r := WarmupJudge.strike(power, aim, power_min, power_max, aim_deg)
	taken += 1
	if r["pure"]:
		pure += 1
	return r


func wants_next_kick() -> bool:
	return taken < kicks


func result() -> String:
	return WarmupJudge.session_result(pure, pure_needed)


## The closing banner: {banner, detail, good}.
func summary() -> Dictionary:
	var r := result()
	return {"banner": "WARMED UP" if r == "pure" else "LOOSE", "good": r == "pure",
		"detail": "%d of %d pure" % [pure, taken]}
