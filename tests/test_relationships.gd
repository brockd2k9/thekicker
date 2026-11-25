extends "res://tests/test_case.gd"
## Relationships: the cast, value changes, effects (zero at neutral), stage
## changes, Tyler Brooks's path, recruiting, and scenario data.

var t := CareerTuning.get_default()


func _career(name := "Rel Test") -> CareerData:
	var c := CareerData.create(name, t)
	c.created = 1794983149
	c.people.clear()
	Relationships.seed_cast(c, t)
	c.team = Progression.team_from(TeamDatabase.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	return c


func test_new_career_has_the_cast() -> void:
	var c := _career()
	for id in ["coach", "holder", "teacher", "best_friend", "rival", "parent", "sibling", "love_interest"]:
		check(c.people.has(id), "has " + id)
		eq(Relationships.value(c, id), 50.0, id + " starts neutral")
		check(Relationships.name_of(c, id) != "", id + " has a name")
	eq(Relationships.name_of(c, "rival"), "Tyler Brooks", "Tyler's fixed name")
	check(Relationships.name_of(c, "coach").begins_with("Coach "), "coach style")
	check(not Relationships.known(c, "rival"), "Tyler unknown until met")
	check(not Relationships.known(c, "love_interest"), "someone special unknown until met")
	check(Relationships.known(c, "coach"), "coach known")
	eq(Relationships.tier(c, "coach"), "Neutral", "tier at 50")
	eq(Relationships.tier(c, "rival"), "Rival", "Tyler's own tiers")


func test_names_are_stable_per_career() -> void:
	var a := _career("Same")
	var b := _career("Same")
	eq(JSON.stringify(a.people), JSON.stringify(b.people), "same career, same cast")


func test_apply_changes() -> void:
	var c := _career()
	var out := Relationships.apply(c, {"coach": 10, "rival": -5, "nobody": 3})
	eq(out, {"coach": 10.0, "rival": -5.0}, "applied")
	eq(Relationships.value(c, "coach"), 60.0, "coach up")
	check(Relationships.known(c, "rival"), "meeting Tyler makes him known")
	eq(float(c.people["coach"]["week_change"]), 10.0, "week change")
	Relationships.apply(c, {"coach": 100})
	eq(Relationships.value(c, "coach"), 100.0, "clamped at 100")


func test_neutral_cast_changes_nothing() -> void:
	var c := _career()
	Relationships.apply(c, {"rival": 0, "love_interest": 0, "best_friend": 0})  # known, still 50
	eq(Relationships.profile_lines(c, t), [], "no profile lines")
	eq(Relationships.weekly_growth(c, t), {}, "no weekly growth")
	eq(Relationships.coach_range_yd(c, t), 0.0, "coach range")
	eq(Relationships.teacher_gpa(c, t), 0.0, "teacher GPA")
	eq(Relationships.coach_recommendation(c, t), 0.0, "no recommendation")
	eq(Relationships.teacher_grace(c, t), 0.0, "no grace")


func test_game_day_effects() -> void:
	var c := _career()
	var base := KickProfile.build(c, t)
	Relationships.apply(c, {"coach": 50, "holder": 50})
	var good := KickProfile.build(c, t)
	check(good.pressure_sensitivity < base.pressure_sensitivity, "trusted coach: calmer")
	check(good.accuracy_spread_deg < base.accuracy_spread_deg, "trusted holder: cleaner")
	check(Relationships.coach_range_yd(c, t) > 0.0, "coach lets you try longer")
	check(good.outlook.any(func(l: Dictionary) -> bool: return str(l["label"]).contains("believes")),
		"outlook line")
	Relationships.apply(c, {"coach": -100, "holder": -100})
	var bad := KickProfile.build(c, t)
	check(bad.pressure_sensitivity > base.pressure_sensitivity, "doubting coach: more pressure")
	check(bad.accuracy_spread_deg > base.accuracy_spread_deg, "strained holder: worse aim")


func test_weekly_effects_and_drift() -> void:
	var c := _career()
	Relationships.apply(c, {"parent": 50, "best_friend": -50, "rival": -50})
	var g := Relationships.weekly_growth(c, t)
	eq(float(g.get("energy", 0.0)), t.rel_family_energy, "Dad at 100: energy")
	check(float(g.get("fun", 0.0)) < 0.0, "falling out with your best friend: less fun")
	eq(float(g.get("power", 0.0)), 0.0, "no direct football growth (skill points now)")
	check(Relationships.rival_sp(c, t) > 0, "rival Tyler pushes you: weekly skill points")
	Relationships.end_week(c, t)
	check(Relationships.value(c, "parent") < 100.0, "drifts toward 50")
	eq(float(c.people["parent"]["week_change"]), 0.0, "week change reset")


func test_stage_change_moves_people_on() -> void:
	var c := _career()
	var hs_coach := Relationships.name_of(c, "coach")
	Relationships.apply(c, {"coach": 20, "rival": 10})
	c.stage = CareerData.STAGE_COLLEGE
	c.season = 5
	Relationships.enter_stage(c, t)
	eq(Relationships.value(c, "coach"), 50.0, "new coach starts neutral")
	eq(Relationships.role(c, "coach"), "Special Teams Coach", "college role")
	check(c.former_people.any(func(f: Dictionary) -> bool: return f["name"] == hs_coach), "old coach is former")
	eq(Relationships.value(c, "rival"), 60.0, "Tyler stays")
	eq(Relationships.role(c, "teacher"), "Academic Advisor", "advisor in college")
	c.stage = CareerData.STAGE_PRO
	Relationships.enter_stage(c, t)
	check(not c.people.has("teacher"), "no teacher in the pros")


func test_tyler_path_and_schedule() -> void:
	var c := _career()
	Relationships.advance_tyler(c, CareerData.STAGE_COLLEGE)
	var tt := Relationships.tyler_team(c)
	check(not TeamDatabase.team(str(tt["id"])).is_empty(), "Tyler signed with a real college")
	eq(tt["stage"], "college", "college")
	var again := _career()
	Relationships.advance_tyler(again, CareerData.STAGE_COLLEGE)
	eq(Relationships.tyler_team(again)["id"], tt["id"], "same career, same school")
	# Meet him, then play college ball elsewhere: his team gets on the schedule.
	c.stage = CareerData.STAGE_COLLEGE
	var other: Dictionary = TeamDatabase.colleges().filter(func(s: Dictionary) -> bool:
		return s["id"] != tt["id"])[0]
	c.team = Progression.team_from(other, CareerData.STAGE_COLLEGE)
	var sched := CareerManager.build_schedule(c, t, RandomNumberGenerator.new())
	var before := JSON.stringify(sched)
	Relationships.schedule_tyler(c, sched)
	eq(JSON.stringify(sched), before, "schedule untouched before you've met him")
	Relationships.apply(c, {"rival": -40})
	Relationships.schedule_tyler(c, sched)
	var wk := -1
	for e in sched:
		if e.get("opponent", {}).get("id", "") == tt["id"]:
			wk = int(e["week"])
	check(wk > 0, "his team is on the schedule")
	c.schedule = sched
	c.week = wk
	var base_add := KickProfile.build(c, t).pressure_add
	check(base_add > 0.0, "bitter rival game: extra pressure")


func test_recruiting_and_gpa() -> void:
	var c := _career()
	c.season_in_stage = 2
	Relationships.apply(c, {"coach": 30})
	eq(Progression.coach_rec(c, t), 0.0, "only in the final season")
	c.season_in_stage = t.high_school_seasons
	eq(Progression.coach_rec(c, t), t.rel_rec_bonus, "coach recommends you")
	Relationships.apply(c, {"coach": -70})
	eq(Progression.coach_rec(c, t), -t.rel_rec_penalty, "lukewarm word")
	var min_gpa := float(Progression.tier("top").get("min_gpa", 2.8))
	c.gpa = min_gpa - 0.05
	check(not Progression.gpa_ok(c, "top"), "below the minimum")
	Relationships.apply(c, {"teacher": 30})
	check(Progression.gpa_ok(c, "top"), "teacher vouches")
	check(Progression.gpa_drift(c, t) > t.gpa_intelligence_drift * (c.stat("intelligence") - 50.0) / 50.0,
		"teacher adds GPA")


func test_scenario_rel_and_requirements() -> void:
	var c := _career()
	var sc := {"id": "rel_scn", "title": "x", "text": "{coach} wants a word.", "category": "team",
		"stages": ["high_school"], "choices": [
			{"label": "Listen", "result": "", "stats": {"life": {"fun": 1}}, "modifiers": ["rested"],
				"rel": {"coach": 8}},
			{"label": "Lead", "result": "", "stats": {"life": {"fun": 1}}, "modifiers": ["rested"],
				"requires": {"min": {"rel_coach": 60}}}]}
	CareerContent.use_scenarios([sc])
	eq(ScenarioEngine.choice_lock(c, sc["choices"][1]), "Requires Head Coach 60+", "requirement text")
	var out := ScenarioEngine.apply_choice(c, "rel_scn", 0, t)
	eq(out["relationships"], {"coach": 8.0}, "choice moved the coach")
	Relationships.apply(c, {"coach": 2})
	eq(ScenarioEngine.choice_lock(c, sc["choices"][1]), "", "unlocked at 60")
	eq(CareerContent.fill(sc["text"], Relationships.text_vars(c)),
		"%s wants a word." % Relationships.name_of(c, "coach"), "{coach} placeholder")
	sc["choices"][0]["rel"] = {"principal": 3}
	sc["choices"][1]["requires"] = {"min": {"rel_mascot": 10}}
	var p := CareerContent.validate()
	check(Array(p).any(func(x: String) -> bool: return x.contains("unknown person 'principal'")), "bad rel id")
	check(Array(p).any(func(x: String) -> bool: return x.contains("rel_mascot")), "bad rel requirement")
	CareerContent.reload()
