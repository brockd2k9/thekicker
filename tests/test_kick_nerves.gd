extends "res://tests/test_case.gd"
## Career kick nerves (KickNerves): off-field trouble and slumps make a crooked
## swipe miss wider, and nothing else.

var t := CareerTuning.get_default()


func _career() -> CareerData:
	var c := CareerData.create("Nerves Test", t)
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	for k in ["energy", "health", "fun", "social"]:
		c.set_stat(k, 70.0)
	return c


static func _kicks(made: Array, straight := true) -> Array:
	var out: Array = []
	for m in made:
		out.append({"kind": "fg", "made": m, "straight": straight})
	return out


## Upward swipe bowed to the right (crooked) or straight.
static func _swipe(bow: float) -> Swipe:
	var s := Swipe.new()
	s.screen_height = 1280.0
	s.start = Vector2(360, 1100)
	var pts := PackedVector2Array()
	for i in 21:
		var tt := i / 20.0
		pts.append(s.start + Vector2(0, -450) * tt + Vector2(1, 0) * bow * 450.0 * sin(PI * tt))
	s.points = pts
	s.end = pts[20]
	s.duration = 0.2
	s.flick_speed_px = 3.0 * 1280.0
	return s


func test_calm_career_is_normal() -> void:
	var b := KickNerves.breakdown(_career(), t)
	eq(b["mult"], 1.0, "calm = 1.0")
	eq(b["status"], "", "no status")


func test_low_energy_and_life_raise_it() -> void:
	var c := _career()
	c.set_stat("energy", 10.0)
	var b := KickNerves.breakdown(c, t)
	check(float(b["energy"]) > 0.0 and float(b["mult"]) > 1.0, "low energy raises it")
	eq(b["life"], 0.0, "life stats fine")
	c.set_stat("social", 5.0)
	c.set_stat("fun", 5.0)
	var b2 := KickNerves.breakdown(c, t)
	check(float(b2["life"]) > 0.0 and float(b2["mult"]) > float(b["mult"]), "low life stats add on")
	eq(b2["status"], "Shaky", "readable status")
	for k in ["energy", "health", "fun", "social"]:
		c.set_stat(k, 0.0)
	c.nerves = {"decisions": 1.0, "slump": true}
	eq(KickNerves.breakdown(c, t)["mult"], t.nerves_max_mult, "clamped to the max")


func test_wrong_decisions_add_and_fade() -> void:
	var c := _career()
	KickNerves.on_choice(c, {"conduct": "bad"}, t)
	eq(c.nerves["decisions"], t.nerves_bad_choice, "bad conduct")
	KickNerves.on_choice(c, {"set_flags": {Reputation.CONCERNS: true}}, t)
	eq(c.nerves["decisions"], t.nerves_bad_choice + t.nerves_negative_flag, "negative character flag")
	var before := float(c.nerves["decisions"])
	KickNerves.end_week(c, t)
	eq(c.nerves["decisions"], before, "no fade in the week of the wrong choice")
	c.week_index += 1
	KickNerves.end_week(c, t)
	eq(c.nerves["decisions"], before - t.nerves_decision_fade_week, "fades a little each good week")
	KickNerves.on_choice(c, {"conduct": "good"}, t)
	eq(c.nerves["decisions"], before - t.nerves_decision_fade_week - t.nerves_good_choice, "good choice speeds it")
	for i in 30:
		c.week_index += 1
		KickNerves.end_week(c, t)
	eq(c.nerves["decisions"], 0.0, "gone after enough good weeks")
	KickNerves.on_choice(c, {"conduct": "scandal"}, t)
	KickNerves.on_choice(c, {"conduct": "scandal"}, t)
	KickNerves.on_choice(c, {"conduct": "scandal"}, t)
	eq(c.nerves["decisions"], t.nerves_decision_cap, "capped")


func test_slump_hysteresis() -> void:
	var c := _career()
	c.set_stat("energy", 20.0)
	var calm := KickNerves.breakdown(c, t)
	var miss_n: Array = []
	for i in t.nerves_slump_misses - 1:
		miss_n.append(false)
	eq(KickNerves.after_game(c, _kicks(miss_n), t), "", "one miss short of a slump")
	eq(KickNerves.after_game(c, _kicks([false]), t), "entered", "N misses in a row: slump")
	var b := KickNerves.breakdown(c, t)
	eq(b["status"], "In a slump", "status")
	check(float(b["slump"]) > 0.0, "slump extra")
	check(float(b["energy"]) > float(calm["energy"]), "low energy hits harder in a slump")
	KickNerves.after_game(c, _kicks([true]), t)
	var eased := KickNerves.breakdown(c, t)
	check(float(eased["slump"]) < float(b["slump"]) and eased["in_slump"], "one good kick only partly eases it")
	KickNerves.after_game(c, _kicks([true], false), t)
	eq(c.nerves["clean_run"], 0, "a crooked make doesn't count toward getting out")
	var clean: Array = []
	for i in t.nerves_slump_exit_clean - 1:
		clean.append(true)
	KickNerves.after_game(c, _kicks(clean), t)
	check(c.nerves["slump"], "M-1 clean kicks: still in")
	eq(KickNerves.after_game(c, _kicks([true]), t), "left", "M clean kicks in a row: out")
	check(t.nerves_slump_exit_clean > t.nerves_slump_misses, "harder to get out than in")
	eq(KickNerves.after_game(c, _kicks([false]), t), "", "one miss after leaving: not straight back in")


func test_bad_stretch_enters_slump() -> void:
	var c := _career()
	var mixed: Array = []
	for i in t.nerves_slump_window:
		mixed.append(i % 3 == 0)  # about a third made, never N misses in a row
	eq(KickNerves.after_game(c, _kicks(mixed), t), "entered", "bad stretch")


func test_only_sideways_deviation_changes() -> void:
	var kc := KickController.new()
	var kt := KickTuning.new()
	var d := KickDifficulty.new()
	d.extra_spread_at_hard_deg = 0.0
	var normal := KickModifiers.new()
	var shaky := KickModifiers.new()
	shaky.straightness_penalty_mult = 2.0
	var rng := RandomNumberGenerator.new()
	var s1 := kc.build_shot(_swipe(0.0), kt, normal, 0.0, rng, 0.0, d, 50.0)
	var s2 := kc.build_shot(_swipe(0.0), kt, shaky, 0.0, rng, 0.0, d, 50.0)
	eq(s2.velocity, s1.velocity, "a straight swipe is unchanged")
	var c1 := kc.build_shot(_swipe(0.12), kt, normal, 0.0, rng, 0.0, d, 50.0)
	var c2 := kc.build_shot(_swipe(0.12), kt, shaky, 0.0, rng, 0.0, d, 50.0)
	check(c1.penalty > 0.0, "the test swipe is crooked")
	eq(c2.power, c1.power, "power unchanged")
	eq(c2.elevation_deg, c1.elevation_deg, "launch angle unchanged")
	check(absf(c2.final_aim_deg) > absf(c1.final_aim_deg), "sideways miss is bigger")
	check(absf(c2.hook_accel) > absf(c1.hook_accel), "hook / slice is bigger")
	kc.free()


func test_career_only() -> void:
	eq(KickModifiers.new().straightness_penalty_mult, 1.0, "Practice / Challenge modifiers stay at 1.0")
	var c := _career()
	c.set_stat("energy", 5.0)
	var p := KickProfile.build(c, t)
	check(p.straightness_penalty_mult > 1.0, "Career profile sets it")
	eq(p.to_kick_modifiers().straightness_penalty_mult, p.straightness_penalty_mult, "passed to the kick")
	check(p.outlook.any(func(l: Dictionary) -> bool: return l["label"] == "Shaky"), "Outlook says Shaky")


func test_saved_and_sim_tracks_straight() -> void:
	var c := _career()
	c.nerves = {"decisions": 0.2, "slump": true, "clean_run": 2, "recent": [false, true]}
	var back := CareerData.from_dict(c.to_dict())
	eq(back.nerves, c.nerves, "nerves round-trip through the save")
	var old := c.to_dict()
	old.erase("nerves")
	eq(CareerData.from_dict(old).nerves, {}, "older saves start calm")
	var sim := GameSim.new()
	var week := {"opponent": {"name": "Others", "mascot": "Others", "strength": 50}, "home": true}
	for seed in range(1, 60):
		sim = GameSim.new()
		sim.setup(c, week, t, seed, 50)
		for i in 400:
			var e := sim.next()
			if e["type"] == "call" and str(e["kind"]) in ["fg", "pat"]:
				sim.resolve_call({"made": true, "straight": false})
				eq(sim.kicks[-1].get("straight", true), false, "GameSim keeps the straight flag")
				return
			if e["type"] == "call":
				sim.resolve_call({"quality": 0.5, "carry": 50.0, "text": "", "recovered": false})
			elif e["type"] == "warmup":
				sim.set_warmup("loose")
			elif e["type"] == "end":
				break
	check(false, "no field goal call found")
