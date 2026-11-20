extends "res://tests/test_case.gd"
## Old-save compatibility: every save layout the game has shipped loads,
## upgrades to the current version, keeps its data, and can keep playing.
## Fixtures in tests/fixtures/ are frozen copies of real saves; never edit
## them to make a test pass (add a new fixture for a new version instead).

const SIM := preload("res://tools/career_sim.gd")
const OLD_CAREERS := ["career_v0_minimal.json", "career_v1_stage_end.json",
	"career_v2_hs_junior.json", "career_v2_college.json", "career_v3_college.json"]


func _load(name: String) -> CareerData:
	return CareerData.from_dict(CareerSave._migrate(fixture(name)))


func test_every_old_career_upgrades_to_current_version() -> void:
	for name in OLD_CAREERS:
		var d := CareerSave._migrate(fixture(name))
		eq(int(d["career_version"]), CareerData.VERSION, name + " version")
		var c := CareerData.from_dict(d)
		check(c.stage in CareerData.STAGES, name + " stage")
		check(not c.player.is_empty(), name + " player")
		for g in CareerData.GROUP_KEYS:
			for k in CareerData.GROUP_KEYS[g]:
				check(c.stat(k) >= 0.0 and c.stat(k) <= 100.0, "%s stat %s in range" % [name, k])


func test_v0_gets_defaults_and_keeps_story_state() -> void:
	var c := _load("career_v0_minimal.json")
	eq(c.player["name"], "Old Timer", "name")
	eq(c.week, 4, "week")
	eq(c.gpa, 2.9, "gpa default")
	eq(c.record, {"w": 0, "l": 0, "t": 0}, "record default")
	check(c.flags.get("met_coach", false), "flags kept")
	check(c.scenario_log.has("hs_party_invite"), "scenario log kept")
	eq(c.queued_scenarios, [{"id": "hs_conflict_followup", "due": 5}], "follow-up queue kept")
	eq(c.season_stats, CareerData.empty_kick_totals(), "season stats default")


func test_v1_stage_end_continues_at_recruiting() -> void:
	var c := _load("career_v1_stage_end.json")
	eq(c.phase, "recruiting", "v1 placeholder phase upgraded")
	eq(c.recruiting_score, 48.5, "recruiting score kept")
	check(c.has_trait("driven"), "traits kept")


func test_v2_round_trip_is_lossless() -> void:
	for name in ["career_v2_hs_junior.json", "career_v2_college.json"]:
		var c := _load(name)
		var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
		eq(JSON.stringify(again.to_dict()), JSON.stringify(c.to_dict()), name + " round trip")
		var raw := fixture(name)
		for key in ["flags", "scenario_log", "offers", "history", "route", "schedule"]:
			eq(JSON.stringify(c.to_dict()[key]), JSON.stringify(raw[key]), "%s keeps %s" % [name, key])


func test_old_careers_keep_playing() -> void:
	# Load each mid-season save and play two full weeks through the real loop
	# (the minimal v0 save has no schedule, so it goes through a season end).
	var sim = SIM.new()
	sim._kt = load("res://tuning/kick_tuning.tres")
	for name in ["career_v0_minimal.json", "career_v2_hs_junior.json", "career_v2_college.json",
			"career_v3_college.json"]:
		var c := _load(name)
		c.slot = 0  # in-memory: never written to the player's save slots
		var m := CareerManager.new(c)
		m.rng.seed = 5
		var start := c.week_index
		var guard := 0
		while c.week_index < start + 2 and guard < 50:
			guard += 1
			match c.phase:
				"week_start": m.begin_week()
				"scenario", "offseason": m.choose(sim._choose(c, m.current_scenario(), "mixed", m.tuning))
				"outlook": m.start_game()
				"game": m.finish_game(sim._play_game(m))
				"results": m.end_week()
				"season_end": m.end_season()
				"recruiting": m.continue_recruiting()
				_: break
		eq(c.week_index, start + 2, name + " played two weeks (phase %s)" % c.phase)
	sim.free()


func test_removed_content_is_dropped() -> void:
	var d := fixture("career_v2_hs_junior.json")
	d["queued_scenarios"] = [{"id": "no_longer_exists", "due": 0}]
	var c := CareerData.from_dict(CareerSave._migrate(d))
	var rng := RandomNumberGenerator.new()
	ScenarioEngine.pick(c, "season", 1, rng, CareerTuning.get_default())
	check(c.queued_scenarios.is_empty(), "unknown follow-up dropped from the queue")


func test_main_save_v1_upgrades() -> void:
	var d: Dictionary = SaveStore.new()._migrate(fixture("main_save_v1.json"))
	eq(int(d["version"]), SaveStore.VERSION, "version")
	eq(d["career"], {"last_slot": 0}, "career section")
	eq(d["stats"]["practice"]["made"], 9.0, "stats kept")
	check(d["achievements"]["unlocked"].has("first_make"), "achievements kept")


func test_pre_relationship_saves_get_a_neutral_cast() -> void:
	var hs := _load("career_v2_hs_junior.json")
	eq(Relationships.role(hs, "coach"), "Head Coach", "HS coach")
	check(hs.people.has("teacher") and hs.people.has("rival"), "full HS cast")
	for id in hs.people:
		if id == Relationships.TEAM:
			continue  # new in v4: starts from the career's FG% (test_v4_*)
		eq(Relationships.value(hs, id), 50.0, id + " neutral (no effect on the old save)")
	var team := Relationships.value(hs, Relationships.TEAM)
	check(team >= 35.0 and team <= 65.0, "Team standing starts from the record (35-65)")
	check(Relationships.tyler_team(hs).is_empty(), "Tyler still in high school")
	var col := _load("career_v2_college.json")
	eq(Relationships.role(col, "coach"), "Special Teams Coach", "college coach")
	eq(str(Relationships.tyler_team(col).get("stage", "")), "college", "Tyler went to college too")
	eq(col.former_people, [], "nobody known from earlier stages")
	var again := _load("career_v2_college.json")
	eq(JSON.stringify(again.people), JSON.stringify(col.people), "the same cast every load")


func test_v3_relationships_load_unchanged() -> void:
	var raw := fixture("career_v3_college.json")
	var c := _load("career_v3_college.json")
	var people: Dictionary = c.to_dict()["people"]
	check(people.has(Relationships.TEAM), "v4 adds Team standing")
	people.erase(Relationships.TEAM)
	check(people.has(Bench.BACKUP) and not bool(people[Bench.BACKUP]["known"]), "v5 adds the backup kicker, hidden")
	people.erase(Bench.BACKUP)
	eq(JSON.stringify(people), JSON.stringify(raw["people"]), "people kept exactly")
	eq(JSON.stringify(c.to_dict()["former_people"]), JSON.stringify(raw["former_people"]), "former people kept")
	check(Relationships.known(c, "rival") and Relationships.value(c, "rival") < 50.0, "Tyler met, a rival")
	eq(str(Relationships.tyler_team(c).get("stage", "")), "college", "Tyler's college kept")
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(JSON.stringify(again.to_dict()), JSON.stringify(c.to_dict()), "v3 round trip")


func test_wrong_typed_skill_point_fields_fall_back() -> void:
	# A hand-edited (or foreign-format) save: SP fields that aren't numbers load as 0.
	var d := fixture("career_v2_college.json")
	d["career_version"] = 4
	d["skill_points"] = "lots"
	d["sp_career"] = {"earned": 234, "spent": 232}
	d["sp_season"] = [1, 2]
	d["range_physics"] = "yes"
	var c := CareerData.from_dict(CareerSave._migrate(d))
	check(c != null, "loads")
	eq(c.skill_points, 0, "skill_points")
	eq(c.sp_career, 0, "sp_career")
	eq(c.sp_season, 0, "sp_season")
	check(not c.range_physics, "range_physics")
