extends "res://tests/test_case.gd"
## Scenario impact (minor / normal / major), when the full result shows, the
## stakes chips, the "Because you..." callback, the Recent choices log and the
## reading helpers (ScenarioText). Made-up scenarios (CareerContent.use_scenarios);
## the real content is put back after each test.

var tuning := CareerTuning.get_default()


func _sc(id: String, extra: Dictionary = {}, choices: Array = []) -> Dictionary:
	var s := {"id": id, "title": id, "text": "x", "category": "team", "stages": ["high_school"],
		"choices": choices if not choices.is_empty() else [
			{"label": "a", "result": "ra", "stats": {"life": {"fun": 4}}, "modifiers": ["rested"]},
			{"label": "b", "result": "rb", "stats": {"life": {"fun": -4}}, "modifiers": ["tired"]}]}
	s.merge(extra, true)
	return s


func _career() -> CareerData:
	var c := CareerData.create("Test", tuning)
	c.season_in_stage = 1
	c.week = 3
	c.set_stat("fun", 50.0)
	return c


func test_impact_field_and_default() -> void:
	eq(ScenarioEngine.impact({}), "normal", "untagged = normal")
	eq(ScenarioEngine.impact({"impact": "minor"}), "minor", "minor")
	eq(ScenarioEngine.impact({"impact": "major"}), "major", "major")
	eq(ScenarioEngine.impact({"impact": "huge"}), "normal", "unknown value = normal")


func test_impact_scales_stat_swings() -> void:
	var t := tuning.duplicate() as CareerTuning
	t.scenario_football_scale = 0.5
	t.impact_scale_minor = 0.5
	t.impact_scale_major = 2.0
	var st := {"life": {"fun": 4.0}, "football": {"power": 2.0}}
	var mi := ScenarioEngine.scaled_stats(st, t, "minor")
	var ma := ScenarioEngine.scaled_stats(st, t, "major")
	eq(float(mi["life"]["fun"]), 2.0, "minor halves life")
	eq(float(mi["football"]["power"]), 0.5, "minor stacks with the football scale")
	eq(float(ma["life"]["fun"]), 8.0, "major doubles")
	eq(float(st["life"]["fun"]), 4.0, "the data isn't changed")


func test_minor_choice_gets_a_toast_only() -> void:
	CareerContent.use_scenarios([_sc("m", {"impact": "minor"}, [
		{"label": "a", "result": "ra", "stats": {"life": {"fun": 4}}, "modifiers": ["rested"],
			"set_flags": {"x": true}, "rel": {"coach": 10}},
		{"label": "b", "result": "rb", "stats": {"life": {"fun": -4}}, "modifiers": ["tired"]}])])
	var c := _career()
	var out := ScenarioEngine.apply_choice(c, "m", 0, tuning)
	eq(out.get("reasons"), [], "minor: no result screen even with a flag and a big relationship move")
	CareerContent.reload()


func test_major_always_shows_the_result() -> void:
	CareerContent.use_scenarios([_sc("big", {"impact": "major"})])
	var out := ScenarioEngine.apply_choice(_career(), "big", 0, tuning)
	check("major" in out.get("reasons", []), "major: always the result")
	CareerContent.reload()


func test_normal_result_thresholds() -> void:
	var base := {"label": "a", "result": "ra", "stats": {"life": {"fun": 2}}, "modifiers": ["rested"]}
	var rel_small := base.duplicate(true)
	rel_small["rel"] = {"coach": tuning.result_rel_min - 1.0}
	var rel_big := base.duplicate(true)
	rel_big["rel"] = {"coach": -tuning.result_rel_min}
	var flag := base.duplicate(true)
	flag["set_flags"] = {"x": true}
	var conduct := base.duplicate(true)
	conduct["conduct"] = "good"
	var draft := base.duplicate(true)
	draft["draft"] = 1
	var fans := base.duplicate(true)
	fans["followers"] = tuning.result_followers_min
	var sus := base.duplicate(true)
	sus["suspend_weeks"] = 1
	eq(ScenarioEngine.result_reasons(base, {}, "normal", tuning), [], "plain choice: toast")
	eq(ScenarioEngine.result_reasons(rel_small, {}, "normal", tuning), [], "small relationship move: toast")
	check("relationship" in ScenarioEngine.result_reasons(rel_big, {}, "normal", tuning), "big relationship move")
	check("flag" in ScenarioEngine.result_reasons(flag, {}, "normal", tuning), "a flag")
	check("conduct" in ScenarioEngine.result_reasons(conduct, {}, "normal", tuning), "conduct")
	check("draft" in ScenarioEngine.result_reasons(draft, {}, "normal", tuning), "draft points")
	check("followers" in ScenarioEngine.result_reasons(fans, {}, "normal", tuning), "followers buzz")
	check("followers" in ScenarioEngine.result_reasons(base, {"tier_up": true}, "normal", tuning), "a new follower tier")
	check("money" in ScenarioEngine.result_reasons(base, {"money": -tuning.result_money_min}, "normal", tuning),
		"money past the threshold")
	eq(ScenarioEngine.result_reasons(base, {"money": tuning.result_money_min - 1}, "normal", tuning), [],
		"money under it: toast")
	check("suspension" in ScenarioEngine.result_reasons(sus, {}, "minor", tuning), "a suspension shows even in a minor scene")
	check("trait" in ScenarioEngine.result_reasons(base, {"new_traits": ["driven"]}, "minor", tuning),
		"a new trait shows even in a minor scene")


func test_stakes_and_risky_choices() -> void:
	var c := _career()
	var safe := {"label": "a", "stats": {"life": {"fun": 3}}, "modifiers": ["rested"], "rel": {"coach": 4},
		"grades": 0.1}
	var st := ScenarioEngine.stakes(c, safe, "normal", tuning)
	var kinds := st.map(func(x: Dictionary) -> String: return str(x["kind"]))
	check("life" in kinds and "rel" in kinds and "grades" in kinds and "football" in kinds,
		"life, a person, grades and game day (football) all show: %s" % [kinds])
	var rel: Dictionary = st.filter(func(x: Dictionary) -> bool: return x["kind"] == "rel")[0]
	eq(rel["value"], "+4", "a safe choice shows the exact number")
	var down: Dictionary = ScenarioEngine.stakes(c, {"stats": {"life": {"fun": -3}}, "modifiers": []}, "normal", tuning)[0]
	eq(down["value"], "\u22123", "a loss uses the minus sign")
	var risky := {"label": "b", "stats": {"life": {"fun": 3}}, "modifiers": ["rested"], "conduct": "bad",
		"rel": {"coach": 4}}
	check(ScenarioEngine.is_risky(risky, "normal", tuning), "bad conduct is risky")
	for x in ScenarioEngine.stakes(c, risky, "normal", tuning):
		eq(x["value"], "", "risky: direction only (%s)" % x["kind"])
	var cond: Array = ScenarioEngine.stakes(c, risky, "normal", tuning).filter(
		func(x: Dictionary) -> bool: return x["kind"] == "conduct")
	eq(cond.size(), 1, "a conduct chip")
	eq(int(cond[0]["dir"]), -1, "pointing down")
	check(ScenarioEngine.is_risky(safe, "major", tuning), "every choice in a major scene hides numbers")
	var forced := safe.duplicate(true)
	forced["risky"] = true
	check(ScenarioEngine.is_risky(forced, "normal", tuning), "risky: true in the data")
	var mixed := {"stats": {"life": {"fun": 3, "energy": -3}}, "modifiers": []}
	var life: Dictionary = ScenarioEngine.stakes(c, mixed, "normal", tuning)[0]
	eq(int(life["dir"]), 0, "both ways = mixed")
	eq(life["value"], "", "mixed shows no number")


func test_callback_line() -> void:
	CareerContent.use_scenarios([
		_sc("first", {}, [
			{"label": "Skip the party", "result": "r", "stats": {"life": {"fun": -2}}, "modifiers": ["rested"],
				"set_flags": {"skipped_party": true}, "callback": "skipped the party for extra reps"},
			{"label": "Go to the party", "result": "r", "stats": {"life": {"fun": 3}}, "modifiers": ["tired"],
				"set_flags": {"went_party": true}}]),
		_sc("later", {"requires": {"flags": ["skipped_party"]}}),
		_sc("later_b", {"requires": {"any_of": [{"any_flags": ["went_party"]}]}}),
		_sc("plain")])
	var c := _career()
	ScenarioEngine.apply_choice(c, "first", 0, tuning)
	eq(ScenarioEngine.because(c, CareerContent.scenario("later")), "Because you skipped the party for extra reps.",
		"the choice's callback text")
	eq(ScenarioEngine.because(c, CareerContent.scenario("plain")), "", "a scene no choice led to")
	var c2 := _career()
	ScenarioEngine.apply_choice(c2, "first", 1, tuning)
	eq(ScenarioEngine.because(c2, CareerContent.scenario("later_b")), "Because you chose \"Go to the party\" in first.",
		"no callback text: the label and scene (any_of counts)")
	c2.flags["went_party"] = false
	eq(ScenarioEngine.because(c2, CareerContent.scenario("later_b")), "", "a cleared flag: no line")
	# Survives a save.
	var back := CareerData.from_dict(c.to_dict())
	eq(ScenarioEngine.because(back, CareerContent.scenario("later")), "Because you skipped the party for extra reps.",
		"saved and loaded")
	CareerContent.reload()


func test_follow_up_callback() -> void:
	CareerContent.use_scenarios([
		_sc("start", {}, [{"label": "Call him back", "result": "r", "stats": {"life": {"fun": 1}},
			"modifiers": ["rested"], "follow_up": {"id": "next", "weeks": 1}},
			{"label": "No", "result": "r", "stats": {"life": {"fun": -1}}, "modifiers": ["tired"]}]),
		_sc("next", {"follow_up_only": true})])
	var c := _career()
	ScenarioEngine.apply_choice(c, "start", 0, tuning)
	eq(ScenarioEngine.because(c, CareerContent.scenario("next")), "Because you chose \"Call him back\" in start.",
		"a follow-up names the choice that queued it")
	ScenarioEngine.apply_choice(c, "next", 0, tuning)
	eq(ScenarioEngine.because(c, CareerContent.scenario("next")), "", "and only the once")
	CareerContent.reload()


func test_recent_choices_log() -> void:
	CareerContent.use_scenarios([_sc("m", {"impact": "minor"}), _sc("big", {"impact": "major"})])
	var t := tuning.duplicate() as CareerTuning
	t.choice_log_size = 3
	var c := _career()
	for i in 4:
		ScenarioEngine.apply_choice(c, "m", i % 2, t)
	ScenarioEngine.apply_choice(c, "big", 0, t)
	eq(c.choice_log.size(), 3, "capped at choice_log_size")
	var last: Dictionary = c.choice_log[c.choice_log.size() - 1]
	eq(last["title"], "big", "newest last")
	eq(last["result"], "ra", "the result text is kept")
	check(bool(last["shown"]), "major: shown")
	check(not bool(c.choice_log[0]["shown"]), "minor: toast only")
	check((last["applied"] as Dictionary).has("life"), "what it changed")
	var back := CareerData.from_dict(c.to_dict())
	eq(back.choice_log.size(), 3, "saved and loaded")
	CareerContent.reload()


func test_beats() -> void:
	var short := "One line only."
	eq(ScenarioText.beats(short), [short], "short text: one beat")
	var long := "The bus is late. Your phone buzzes twice. Coach wants you at the field early, and your friends want you at the diner. You can't do both tonight, and someone will be let down."
	var b := ScenarioText.beats(long)
	check(b.size() >= 2, "long text in beats (%d)" % b.size())
	for x in b:
		check(str(x).length() <= ScenarioText.BEAT_CHARS, "each beat fits 2 to 3 lines: %s" % x)
	eq(" ".join(PackedStringArray(b)), long, "nothing lost")


func test_key_phrase_and_speaker() -> void:
	var text := "Your math assignment is due tomorrow. You know you can't put off the homework forever."
	eq(ScenarioText.key_phrase({}, text), "You know you can't put off the homework forever.", "default: the last sentence")
	eq(ScenarioText.key_phrase({"key": "due tomorrow"}, text), "due tomorrow", "the data's key")
	eq(ScenarioText.key_phrase({}, "Only one sentence here."), "", "one sentence: nothing highlighted")
	var bb := ScenarioText.bbcode("A [note] and due tomorrow.", "due tomorrow", Color.RED)
	check(bb.contains("[lb]note]") and bb.contains("[b]due tomorrow[/b]"), "escaped, key in bold: %s" % bb)
	eq(ScenarioText.speaker({"text": "After practice {holder} and {coach} talk."}), "holder", "the first person named")
	eq(ScenarioText.speaker({"text": "{coach} calls.", "speaker": ""}), "", "speaker \"\" = none")
	eq(ScenarioText.speaker({"text": "Nobody here."}), "", "nobody")


func test_real_data_validates_new_fields() -> void:
	CareerContent.use_scenarios([_sc("bad", {"impact": "huge", "speaker": "nobody", "key": "not in text"}, [
		{"label": "a", "result": "r", "stats": {"life": {"fun": 1}}, "modifiers": ["rested"],
			"callback": "Because you did it", "risky": "yes"},
		{"label": "b", "result": "r", "stats": {"life": {"fun": -1}}, "modifiers": ["tired"]}])])
	var p := "\n".join(CareerContent.validate())
	for want in ["impact must be", "speaker 'nobody'", "key must be", "callback must be", "risky must be"]:
		check(p.contains(want), "validate reports: " + want)
	CareerContent.reload()
	eq(CareerContent.validate().size(), 0, "the real data has no problems")


func test_scenario_screen_reads_in_beats() -> void:
	var m := CareerManager.new(CareerData.create("Test Kicker", tuning))
	var keep := GameState.career
	GameState.career = m
	CareerContent.use_scenarios([_sc("read", {"impact": "major",
		"text": "The bus is late. Your phone buzzes twice. Coach wants you at the field early, and your friends want you at the diner. You can't do both tonight, and someone will be let down."})])
	m.data.phase = CareerManager.PHASE_SCENARIO
	m.data.pending_scenarios = ["read"]
	var scr: Control = load(Screens.CAREER_SCENARIO).instantiate()
	(Engine.get_main_loop() as SceneTree).current_scene.add_child(scr)
	scr._show_beat(0)
	check(not scr.reading_done(), "choices wait for the last beat")
	var taps := 0
	while scr.advance() and taps < 10:
		taps += 1
	check(scr.reading_done(), "tapping through shows the choices")
	check(taps >= 2, "a tap finishes the line, the next one moves on (%d taps)" % taps)
	check(scr.find_child("Stakes", true, false) != null, "choice cards have stakes chips")
	scr.free()
	GameState.career = keep
	CareerContent.reload()
