extends "res://tests/test_case.gd"
## ScenarioEngine: any_flags, drafts, story windows, the forced-per-week cap,
## lock_text. Uses made-up scenarios (CareerContent.use_scenarios) and puts the
## real content back afterwards.

var tuning := CareerTuning.get_default()


func _sc(id: String, extra: Dictionary = {}) -> Dictionary:
	var s := {"id": id, "title": id, "text": "x", "category": "team", "stages": ["high_school"],
		"choices": [{"label": "a", "result": "a", "stats": {"life": {"fun": 1}}, "modifiers": ["rested"]},
			{"label": "b", "result": "b", "stats": {"life": {"fun": -1}}, "modifiers": ["tired"]}]}
	s.merge(extra, true)
	return s


func _career(season := 1, week := 1) -> CareerData:
	var c := CareerData.create("Test", tuning)
	c.season_in_stage = season
	c.week = week
	return c


func _pick(c: CareerData, when := "season", count := 1, seed := 1) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	return ScenarioEngine.pick(c, when, count, rng, tuning)


func test_any_flags() -> void:
	var c := _career()
	var req := {"any_flags": ["a", "b"]}
	check(not ScenarioEngine.requirements_met(c, req), "no flag set")
	c.flags["b"] = true
	check(ScenarioEngine.requirements_met(c, req), "one of them set")
	c.flags["b"] = false
	check(not ScenarioEngine.requirements_met(c, req), "a false flag doesn't count")
	c.flags["a"] = true
	check(ScenarioEngine.requirements_met(c, {"flags": ["a"], "any_flags": ["b", "a"], "not_flags": ["z"]}),
		"together with flags and not_flags")


func test_drafts_are_never_picked() -> void:
	CareerContent.use_scenarios([_sc("draft_one", {"draft": true, "choices": []}),
		_sc("draft_story", {"draft": true, "story": true, "seasons": [1, 1], "weeks": [1, 1]}),
		_sc("draft_beat", {"draft": true, "beat": {"season_in_stage": 1, "week": 1}})])
	var c := _career()
	check(not ScenarioEngine.is_eligible(c, CareerContent.scenario("draft_one"), "season", tuning, true),
		"draft not eligible even when forced")
	eq(_pick(c, "season", 3), [], "nothing picked")
	CareerContent.reload()


func test_story_weight_boost() -> void:
	var c := _career()
	var plain := _sc("plain")
	var story := _sc("story", {"story": true, "seasons": [1, 1], "weeks": [1, 5]})
	eq(ScenarioEngine.weight(c, story, tuning), ScenarioEngine.weight(c, plain, tuning) * tuning.story_weight_mult,
		"story weight multiplied")


func test_story_forced_only_in_last_week_of_window() -> void:
	var story := _sc("story", {"story": true, "seasons": [1, 2], "weeks": [3, 5], "category": "school"})
	CareerContent.use_scenarios([story])
	check(not ScenarioEngine.story_due(_career(1, 5), story, "season"), "not forced in an earlier season")
	check(not ScenarioEngine.story_due(_career(2, 4), story, "season"), "not forced before the last week")
	check(ScenarioEngine.story_due(_career(2, 5), story, "season"), "forced in the last week")
	check(not ScenarioEngine.story_due(_career(2, 6), story, "season"), "not forced after the window")
	var seen := _career(2, 5)
	seen.scenario_log["story"] = {"times": 1, "last_week_index": 0}
	check(not ScenarioEngine.story_due(seen, story, "season"), "not forced once seen")
	eq(_pick(_career(2, 5), "season", 0), ["story"], "picked in the last week even with no random slots")
	CareerContent.reload()


func test_story_respects_requirements() -> void:
	var story := _sc("story", {"story": true, "seasons": [1, 1], "weeks": [1, 2],
		"requires": {"any_flags": ["cause"]}})
	CareerContent.use_scenarios([story])
	eq(_pick(_career(1, 2), "season", 0), [], "requirements not met: not forced")
	var c := _career(1, 2)
	c.flags["cause"] = true
	eq(_pick(c, "season", 0), ["story"], "requirements met: forced")
	CareerContent.reload()


func test_offseason_story() -> void:
	var story := _sc("camp", {"story": true, "seasons": [3, 3], "when": ["offseason"]})
	check(ScenarioEngine.story_due(_career(3, 0), story, "offseason"), "due in that offseason")
	check(not ScenarioEngine.story_due(_career(2, 0), story, "offseason"), "not the season before")
	check(not ScenarioEngine.story_due(_career(3, 5), story, "season"), "not during the season")


func test_forced_cap_keeps_followups_queued() -> void:
	CareerContent.use_scenarios([_sc("f1", {"follow_up_only": true, "category": "school"}),
		_sc("f2", {"follow_up_only": true, "category": "health"}),
		_sc("f3", {"follow_up_only": true, "category": "money"})])
	var c := _career()
	for id in ["f1", "f2", "f3"]:
		c.queued_scenarios.append({"id": id, "due": 0})
	var out := _pick(c, "season", 1)
	eq(out.size(), tuning.max_forced_per_week, "capped")
	eq(c.queued_scenarios.size(), 3 - tuning.max_forced_per_week, "the rest stay queued")
	eq(_pick(c, "season", 1), ["f3"], "and come up the next week")
	CareerContent.reload()


func test_story_last_chance_comes_before_followups() -> void:
	CareerContent.use_scenarios([_sc("f1", {"follow_up_only": true, "category": "school"}),
		_sc("f2", {"follow_up_only": true, "category": "health"}),
		_sc("story", {"story": true, "seasons": [1, 1], "weeks": [1, 4], "category": "money"})])
	var c := _career(1, 4)
	c.queued_scenarios = [{"id": "f1", "due": 0}, {"id": "f2", "due": 0}]
	var out := _pick(c, "season", 1)
	eq(out[0], "story", "story first")
	eq(c.queued_scenarios.size(), 1, "one follow-up waits")
	CareerContent.reload()


func test_beat_with_locked_choices() -> void:
	var beat := _sc("next_chapter", {"beat": {"season_in_stage": 4, "week": 10}, "seasons": [4, 4]})
	beat["choices"] = [
		{"label": "Commit", "result": "", "stats": {"life": {"fun": 1}}, "modifiers": ["rested"],
			"requires": {"flags": ["recruiting_values_clear"]}, "lock_text": "a clear recruiting plan"},
		{"label": "Wait", "result": "", "stats": {"life": {"fun": 1}}, "modifiers": ["rested"]}]
	CareerContent.use_scenarios([beat])
	var c := _career(4, 10)
	eq(_pick(c, "season", 0), ["next_chapter"], "the beat always plays")
	eq(ScenarioEngine.choice_lock(c, beat["choices"][0]), "Requires a clear recruiting plan", "lock_text shown")
	eq(ScenarioEngine.choice_lock(c, beat["choices"][1]), "", "open choice")
	c.flags["recruiting_values_clear"] = true
	eq(ScenarioEngine.choice_lock(c, beat["choices"][0]), "", "unlocked by the flag")
	CareerContent.reload()
