extends "res://tests/test_case.gd"
## CareerContent.validate() on the real data, and the story graph checks on
## made-up scenario lists.


func _has(problems: PackedStringArray, part: String) -> bool:
	return Array(problems).any(func(p: String) -> bool: return p.contains(part))


func test_real_content_is_valid() -> void:
	CareerContent.reload()
	var problems := CareerContent.validate()
	eq(problems.size(), 0, "content problems: %s" % "; ".join(problems))


func test_graph_drafts_present_and_draft_only() -> void:
	var drafts := CareerContent.scenarios().filter(func(s: Dictionary) -> bool:
		return str(s.get("id", "")).begins_with("HS_"))
	check(drafts.size() >= 140, "graph imported (%d)" % drafts.size())
	var hs160 := CareerContent.scenario("HS_160")
	eq(hs160.get("beat", {}), {"season_in_stage": 4.0, "week": 10.0}, "HS_160 is the senior week 10 beat")
	check(not hs160.has("requires"), "HS_160 has no scenario-level requirement")


func test_flag_never_set() -> void:
	var p := CareerContent.graph_problems([{"id": "a", "requires": {"any_flags": ["ghost"]}}])
	check(_has(p, "flag 'ghost' is required but nothing sets it"), "reported")
	p = CareerContent.graph_problems([{"id": "a", "requires": {"flags": ["walk_on"]}}])
	eq(p.size(), 0, "engine flags are allowed")
	p = CareerContent.graph_problems([{"id": "a", "choices": [{"requires": {"not_flags": ["ghost"]}}]}])
	check(_has(p, "'ghost'"), "choice requirements are checked too")


func test_draft_expected_flags_count_as_set() -> void:
	var p := CareerContent.graph_problems([
		{"id": "src", "draft": true, "expected_flags": ["cause"], "seasons": [1, 1]},
		{"id": "dst", "seasons": [2, 2], "requires": {"any_flags": ["cause"]}}])
	eq(p.size(), 0, "draft promise is enough: %s" % "; ".join(p))


func test_finished_scenario_must_set_expected_flags() -> void:
	var p := CareerContent.graph_problems([{"id": "src", "expected_flags": ["cause"],
		"choices": [{"set_flags": {"other": true}}]}])
	check(_has(p, "no choice sets expected flag 'cause'"), "reported")
	p = CareerContent.graph_problems([{"id": "src", "expected_flags": ["cause"],
		"choices": [{"set_flags": {"cause": false}}]}])
	check(_has(p, "expected flag 'cause'"), "clearing a flag doesn't count as setting it")


func test_self_required_flag() -> void:
	var p := CareerContent.graph_problems([{"id": "loop", "requires": {"any_flags": ["mine"]},
		"choices": [{"set_flags": {"mine": true}}]}])
	check(_has(p, "requires flag 'mine' that only it sets"), "reported")


func test_flag_set_too_late() -> void:
	var src := {"id": "src", "seasons": [4, 4], "choices": [{"set_flags": {"cause": true}}]}
	var p := CareerContent.graph_problems([src, {"id": "dst", "seasons": [2, 2],
		"requires": {"flags": ["cause"]}}])
	check(_has(p, "only set after this scenario's window"), "later season")
	var early := {"id": "src", "seasons": [3, 3], "weeks": [6, 9], "choices": [{"set_flags": {"cause": true}}]}
	p = CareerContent.graph_problems([early, {"id": "dst", "seasons": [3, 3], "weeks": [1, 5],
		"requires": {"flags": ["cause"]}}])
	check(_has(p, "only set after"), "later weeks of the same season")
	p = CareerContent.graph_problems([early, {"id": "dst", "seasons": [3, 3], "weeks": [10, 11],
		"requires": {"flags": ["cause"]}}])
	eq(p.size(), 0, "earlier weeks are fine")
	var off := {"id": "src", "seasons": [3, 3], "when": ["offseason"], "choices": [{"set_flags": {"cause": true}}]}
	p = CareerContent.graph_problems([off, {"id": "dst", "seasons": [3, 3], "requires": {"flags": ["cause"]}}])
	check(_has(p, "only set after"), "offseason comes after its season")
	p = CareerContent.graph_problems([off, {"id": "dst", "seasons": [4, 4], "requires": {"flags": ["cause"]}}])
	eq(p.size(), 0, "offseason comes before the next season")
	var pro := {"id": "src", "stages": ["pro"], "choices": [{"set_flags": {"cause": true}}]}
	p = CareerContent.graph_problems([pro, {"id": "dst", "stages": ["college"], "requires": {"flags": ["cause"]}}])
	check(_has(p, "only set after"), "stage order")


func test_duplicates_resolved() -> void:
	for id in ["HS_010", "HS_037", "HS_038", "HS_041", "HS_042", "HS_047", "HS_050", "HS_066",
			"HS_096", "HS_100"]:
		check(CareerContent.scenario(id).is_empty(), id + " dropped")
	var call := CareerContent.scenario("hs_recruiter_call")
	check((call["choices"] as Array).any(func(ch: Dictionary) -> bool:
		return ch.get("set_flags", {}).get("recruiter_trust", false)), "hs_recruiter_call sets recruiter_trust")
	eq(CareerContent.scenario("HS_147").get("requires", {}).get("any_flags", []),
		["befriended_tyler", "hostile_tyler_rivalry"], "HS_147 belongs to Tyler")


func test_hs142_needs_a_reason() -> void:
	var s := CareerContent.scenario("HS_142")
	eq(s.get("requires", {}).get("any_flags", []),
		["challenged_coach_decision", "hid_injury", "exaggerated_progress", "blamed_someone_else"],
		"HS_142 trigger")
	eq(s.get("weeks", []), [2.0, 6.0], "senior weeks 2-6")
	eq(s.get("seasons", []), [4.0, 4.0], "senior year")
