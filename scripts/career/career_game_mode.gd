class_name CareerGameMode
extends KickMode
## Plugs one Career kick (field goal, extra point, kickoff or onside kick)
## into the kick scene.
## The sideline screen builds a fresh kick scene per attempt, with this mode
## (the situation the game sim called for) and the KickProfile's modifiers.
## wants_next_kick() is false: after the result, the screen takes you back to
## the bench. Kicks are reported with mode = &"career", so they count in My
## Stats and Achievements like any other kick.

var situation: KickSituation
var gust_mph: float = 0.0


## call: a GameSim "call" event. pressure_add: from the KickProfile (miss streak).
## rules: kickoff / onside only (kickoff_rules_for()).
static func from_call(call: Dictionary, pressure_add: float, rules: KickoffRules = null) -> CareerGameMode:
	var m := CareerGameMode.new()
	var s := KickSituation.new()
	s.distance_yards = int(call.get("yards", 20))
	s.pressure = clampf(float(call.get("pressure", 0.0)) + pressure_add, 0.0, 1.0)
	s.wind_mph = float(call.get("wind", 0.0))
	match str(call.get("kind", "fg")):
		"kickoff":
			s.kick_type = KickSituation.KickType.KICKOFF
		"onside":
			s.kick_type = KickSituation.KickType.ONSIDE
		"pat":
			s.kick_type = KickSituation.KickType.EXTRA_POINT
	if s.is_tee_kick():
		s.kickoff_rules = rules if rules != null else KickoffRules.new()
		# Kickoff calls carry no pressure (GameSim), so no miss-streak pressure either.
		s.pressure = clampf(float(call.get("pressure", 0.0)), 0.0, 1.0)
		s.label = ""
	else:
		var kind := "EXTRA POINT" if call.get("kind") == "pat" else "FIELD GOAL"
		s.label = "%s  -  %s" % [kind, call.get("label", "")]
	m.situation = s
	m.gust_mph = float(call.get("gust", 0.0))
	return m


## The kickoff rules for a career game: CareerTuning + this stage (game_params).
## profile: this game's KickProfile; a full-strength kickoff then carries
## exactly its kickoff_range (the scene multiplies max carry by power_mult,
## which is set for field goal range, so it's divided back out here).
static func kickoff_rules_for(t: CareerTuning, params: Dictionary, profile: KickProfile = null) -> KickoffRules:
	var r := KickoffRules.new()
	r.max_carry_yards = t.kickoff_max_carry_yards
	if profile != null and profile.power_mult > 0.0:
		r.max_carry_yards = profile.kickoff_range / profile.power_mult
	r.spot_yards = int(params.get("kickoff_spot", t.kickoff_spot_yards))
	r.touchback_spot = int(params.get("touchback_spot", t.touchback_spot_hs))
	r.oob_spot = int(params.get("kickoff_oob_spot", t.kickoff_oob_spot_hs))
	r.return_min_yards = t.kickoff_return_min_yards
	r.return_max_yards = t.kickoff_return_max_yards
	r.return_hang_cut = t.kickoff_return_hang_cut
	r.onside_min_yards = t.onside_min_yards
	r.onside_max_yards = t.onside_max_yards
	r.onside_aim_deg = t.onside_aim_deg
	r.onside_good_chance = t.onside_good_chance
	r.onside_poor_chance = t.onside_poor_chance
	if profile != null:  # perks (Hang Time, Onside Specialist)
		var fx := profile.perk_fx
		r.onside_max_yards += float(fx.get("onside_window_yd", 0.0))
		r.onside_aim_deg += float(fx.get("onside_aim_deg", 0.0))
		r.onside_good_chance = clampf(r.onside_good_chance + float(fx.get("onside_recover", 0.0)), 0.0, 1.0)
		var cut := float(fx.get("return_cut_yd", 0.0))
		r.return_min_yards = maxf(r.return_min_yards - cut, 0.0)
		r.return_max_yards = maxf(r.return_max_yards - cut, r.return_min_yards)
	return r


## A field goal / extra point call with perks applied: Clutch takes some
## pressure off game-winning and tying kicks.
static func adjust_call(call: Dictionary, profile: KickProfile) -> Dictionary:
	var lbl := str(call.get("label", ""))
	var cp := float(profile.perk_fx.get("clutch_pressure", 0.0))
	if cp == 0.0 or not ("GAME WINNER" in lbl or "TO TIE" in lbl):
		return call
	var out := call.duplicate()
	out["pressure"] = float(call.get("pressure", 0.0)) * maxf(1.0 + cp, 0.0)
	return out


func id() -> StringName:
	return &"career"


func kick_type() -> int:
	return situation.kick_type


func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
	wind.set_conditions(rng, tuning, situation.wind_mph, gust_mph)
	return situation


func wants_next_kick() -> bool:
	return false
