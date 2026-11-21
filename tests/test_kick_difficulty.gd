extends "res://tests/test_case.gd"
## KickDifficulty: crooked swipes, distance scaling, wind, and that it stacks
## with (never replaces) the Career KickModifiers.


## Upward swipe from (360, 1100), `len_px` long, bowed sideways by `bow`
## (fraction of length, + = right) and finishing with a turn of `hook_deg`.
static func _swipe(bow: float, hook_deg: float, len_px := 450.0, speed := 3.0) -> Swipe:
	var s := Swipe.new()
	s.screen_height = 1280.0
	s.start = Vector2(360, 1100)
	var dir := Vector2(0, -1)
	var n := Vector2(1, 0)
	var pts := PackedVector2Array()
	for i in 21:
		var t := i / 20.0
		var p := s.start + dir * len_px * t + n * bow * len_px * sin(PI * t)
		if t > 0.7:
			p += n * len_px * (t - 0.7) * tan(deg_to_rad(hook_deg))
		pts.append(p)
	s.points = pts
	s.end = pts[20]
	s.duration = 0.2
	s.flick_speed_px = speed * 1280.0
	return s


func test_straight_swipe_measures_straight() -> void:
	var s := _swipe(0.0, 0.0)
	eq(s.bow(), 0.0, "no bow")
	eq(s.finish_angle_deg(), 0.0, "no finish turn")
	eq(s.crookedness(20.0, 0.12), 0.0, "not crooked")
	var no_path := Swipe.new()
	no_path.start = Vector2(0, 100)
	no_path.end = Vector2(0, 0)
	no_path.screen_height = 1000.0
	eq(no_path.crookedness(20.0, 0.12), 0.0, "unknown path = straight (old behavior)")


func test_crooked_swipe_signs() -> void:
	check(_swipe(0.1, 0.0).bow() > 0.05, "bulge right is +")
	check(_swipe(-0.1, 0.0).bow() < -0.05, "bulge left is -")
	check(_swipe(0.0, 20.0).finish_angle_deg() > 5.0, "finishing to the right is +")
	check(_swipe(0.0, -20.0).curl_side() < 0.0, "finishing left sends it left")


func test_penalty_is_nonlinear_and_forgiving_when_small() -> void:
	var d := KickDifficulty.new()
	eq(d.penalty(d.straightness_tolerance * 0.9, 20.0), 0.0, "inside the tolerance: free")
	var small := d.penalty(0.35, 20.0)
	var big := d.penalty(0.9, 20.0)
	check(small < 0.05, "small wobble barely costs (%.3f)" % small)
	check(big > 0.6, "clearly crooked costs a lot (%.3f)" % big)
	check(big / maxf(small, 0.0001) > 10.0, "grows faster than linear")


func test_long_kicks_are_less_forgiving() -> void:
	var d := KickDifficulty.new()
	for c in [0.3, 0.5, 0.8]:
		check(d.penalty(c, 55.0) > d.penalty(c, 20.0), "crooked %.1f costs more at 55 yd" % c)
	eq(d.extra_spread_deg(20.0), 0.0, "no extra aim error on short kicks")
	eq(d.extra_spread_deg(60.0), d.extra_spread_at_hard_deg, "full extra aim error past hard_yards")
	eq(d.distance_factor(d.easy_yards), 0.0, "ramp starts at easy_yards")
	eq(d.distance_factor(d.hard_yards), 1.0, "ramp ends at hard_yards")


func test_disabled_is_the_old_kick() -> void:
	var d := KickDifficulty.new()
	d.enabled = false
	eq(d.penalty(1.0, 60.0), 0.0, "no penalty when disabled")
	eq(d.extra_spread_deg(60.0), 0.0, "no extra spread when disabled")


func test_build_shot_punishes_crooked_and_keeps_straight() -> void:
	var kc := KickController.new()
	var t := KickTuning.new()
	var mods := KickModifiers.new()
	var d := KickDifficulty.new()
	d.extra_spread_at_hard_deg = 0.0
	var rng := RandomNumberGenerator.new()
	var straight_old := kc.build_shot(_swipe(0.0, 0.0), t, mods, 0.0, rng)
	var straight_new := kc.build_shot(_swipe(0.0, 0.0), t, mods, 0.0, rng, 0.0, d, 50.0)
	eq(straight_new.velocity, straight_old.velocity, "a straight swipe is unchanged")
	var crooked := _swipe(0.0, -25.0)
	var old := kc.build_shot(crooked, t, mods, 0.0, rng)
	var new := kc.build_shot(crooked, t, mods, 0.0, rng, 0.0, d, 50.0)
	check(new.penalty > 0.3, "crooked swipe penalized (%.2f)" % new.penalty)
	check(new.power < old.power, "less power")
	check(new.final_aim_deg < old.final_aim_deg - 1.0, "pushed further the way it curled (left)")
	check(new.hook_accel < 0.0, "hooks left in flight")
	kc.free()


func test_stacks_with_career_modifiers() -> void:
	var kc := KickController.new()
	var t := KickTuning.new()
	var d := KickDifficulty.new()
	d.extra_spread_at_hard_deg = 0.0
	var mods := KickModifiers.new()
	mods.power_mult = 0.9  # e.g. a tired leg from a scenario choice
	var base := KickModifiers.new()
	var rng := RandomNumberGenerator.new()
	var sw := _swipe(0.0, -25.0)
	var a := kc.build_shot(sw, t, base, 0.0, rng, 0.0, d, 50.0)
	var b := kc.build_shot(sw, t, mods, 0.0, rng, 0.0, d, 50.0)
	eq(a.penalty, b.penalty, "same crooked penalty")
	check(b.velocity.length() < a.velocity.length(), "the Career power_mult still applies on top")
	# Career aim error and the long-kick error combine (one draw, wider spread).
	d.extra_spread_at_hard_deg = 1.0
	mods.accuracy_spread_deg = 1.0
	var rng1 := RandomNumberGenerator.new()
	rng1.seed = 3
	var rng2 := RandomNumberGenerator.new()
	rng2.seed = 3
	var only_career := kc.build_shot(_swipe(0.0, 0.0), t, mods, 0.0, rng1)
	var both := kc.build_shot(_swipe(0.0, 0.0), t, mods, 0.0, rng2, 0.0, d, 60.0)
	check(absf(both.final_aim_deg) > absf(only_career.final_aim_deg), "spreads stack")
	kc.free()


func test_wind_head_tail_component() -> void:
	var w := Wind.new()
	var t := KickTuning.new()
	var rng := RandomNumberGenerator.new()
	w.set_conditions(rng, t, 10.0, 0.0)
	eq(w.acceleration(t).z, 0.0, "no head/tail unless set")
	w.set_along(8.0)
	check(w.acceleration(t).z < 0.0, "tailwind pushes downfield (-Z)")
	w.set_along(-8.0)
	check(w.acceleration(t).z > 0.0, "headwind holds it up")
	w.set_conditions(rng, t, 10.0, 0.0)
	eq(w.along_mph, 0.0, "set_conditions resets head/tail")
	w.free()


func test_vibration_setting_saved_under_old_key() -> void:
	var s := GameSettings.new()
	s.haptics = false
	var d := s.to_dict()
	check(d.has("haptics") and d["haptics"] == false, "saved as 'haptics' (old saves keep their choice)")
	var s2 := GameSettings.new()
	s2.from_dict({"haptics": false})
	check(not s2.haptics, "loaded back")
	check(not Haptics.can_vibrate(), "no vibration on desktop / CI")
