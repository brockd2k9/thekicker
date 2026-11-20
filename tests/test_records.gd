extends "res://tests/test_case.gd"
## CareerRecords: kicking stats per level (Stats screen) and school interest
## (Recruiting screen). Display-only views; these check they add up, work on
## old saves, and agree with the rules that make offers.

const SIM := preload("res://tools/career_sim.gd")


func _load(name: String) -> CareerData:
	return CareerData.from_dict(CareerSave._migrate(fixture(name)))


func _sum_history(c: CareerData, level: String) -> Dictionary:
	var t := CareerData.empty_kick_totals()
	for h in c.history:
		if CareerRecords.level_of(str(h.get("stage", ""))) != level:
			continue
		for k in t:
			if k == "long":
				t[k] = maxi(int(t[k]), int(h["stats"].get(k, 0)))
			else:
				t[k] = int(t[k]) + int(h["stats"].get(k, 0))
	return t


func test_levels_group_stages() -> void:
	eq(CareerRecords.level_of(CareerData.STAGE_HIGH_SCHOOL), CareerRecords.LEVEL_HS, "high school")
	eq(CareerRecords.level_of(CareerData.STAGE_JUCO), CareerRecords.LEVEL_COLLEGE, "junior college is college")
	eq(CareerRecords.level_of(CareerData.STAGE_COLLEGE), CareerRecords.LEVEL_COLLEGE, "college")
	eq(CareerRecords.level_of(CareerData.STAGE_PRO), CareerRecords.LEVEL_PRO, "pro")
	eq(CareerRecords.level_of(CareerData.STAGE_FREE_AGENT), CareerRecords.LEVEL_PRO, "free agent is pro")


func test_old_saves_show_their_seasons_per_level() -> void:
	for name in ["career_v2_hs_junior.json", "career_v2_college.json", "career_v3_college.json",
			"career_v4_college.json"]:
		var c := _load(name)
		var hs_hist := c.history.filter(func(h: Dictionary) -> bool: return h.get("stage", "") == "high_school")
		var hs := CareerRecords.seasons(c, CareerRecords.LEVEL_HS)
		var open_hs := CareerRecords.current_season_open(c) and c.stage == "high_school"
		eq(hs.size(), hs_hist.size() + (1 if open_hs else 0), name + " HS season rows")
		# Level totals over finished seasons match the saved season lines.
		var finished := hs.filter(func(r: Dictionary) -> bool: return not r["current"])
		var t := CareerRecords.total(finished)
		var want := _sum_history(c, CareerRecords.LEVEL_HS)
		for k in ["fg_att", "fg_made", "pat_att", "pat_made", "points", "long"]:
			eq(t[k], want[k], "%s HS total %s" % [name, k])
		if c.stage == "college":
			var col := CareerRecords.seasons(c, CareerRecords.LEVEL_COLLEGE)
			check(not col.is_empty() and col[col.size() - 1]["current"], name + " current college season listed")


func test_finished_season_not_counted_twice() -> void:
	var c := _load("career_v2_college.json")
	var h := {"stage": c.stage, "season": c.season, "record": c.record.duplicate(),
		"stats": c.season_stats.duplicate(), "team": "X", "year": "Senior"}
	var before := CareerRecords.seasons(c, CareerRecords.level_of(c.stage)).size()
	c.history.append(h)  # what end_season() does; season_stats still holds it
	check(not CareerRecords.current_season_open(c), "season closed once it is in history")
	eq(CareerRecords.seasons(c, CareerRecords.level_of(c.stage)).size(), before, "same number of rows")


func test_played_career_levels_add_up_to_career_totals() -> void:
	# Play a career from freshman year into the pros with the real loop; the
	# per-level sums must equal the career totals the game keeps.
	var sim = SIM.new()
	sim._kt = load("res://tuning/kick_tuning.tres")
	sim._rng.seed = 3
	var c := CareerData.create("Records Test", CareerTuning.get_default())
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c)
	m.rng.seed = 9
	m._start_season(false)
	var guard := 0
	while c.stage != CareerData.STAGE_RETIRED and c.history.size() < 7 and guard < 5000:
		guard += 1
		match c.phase:
			"week_start": m.begin_week()
			"scenario", "offseason": m.choose(sim._choose(c, m.current_scenario(), "always-train", m.tuning))
			"outlook": m.start_game()
			"game": m.finish_game(sim._play_game(m))
			"results": m.end_week()
			"season_end": m.end_season()
			"recruiting": m.continue_recruiting()
			"college_choice":
				var opts := m.college_options()
				if opts.is_empty():
					break
				m.choose_college(opts[0])
			"tryout": m.finish_tryout(int(c.tryout.get("need", 3)))
			"draft":
				if str(c.draft_result.get("kind", "")) == "drafted":
					m.sign_drafted()
				else:
					m.take_tryout()
			"contract": m.contract_continue()
			_: break
	check(c.history.size() >= 5, "played past high school (%d seasons)" % c.history.size())
	var all_rows: Array = []
	for lv in CareerRecords.LEVELS:
		all_rows.append_array(CareerRecords.seasons(c, lv))
	var t := CareerRecords.total(all_rows)
	for k in ["fg_att", "fg_made", "pat_att", "pat_made", "points", "games", "game_winners", "long"]:
		eq(t[k], c.career_totals[k], "levels add up to career total: " + k)
	sim.free()


func test_interest_follows_recruiting_points() -> void:
	var c := _load("career_v2_hs_junior.json")
	c.offers.clear()
	c.gpa = 4.0
	var s: Dictionary = CareerContent.colleges()[0]
	c.recruiting_score = 10.0
	var low := CareerRecords.school_interest(c, s)
	c.recruiting_score = 90.0
	var high := CareerRecords.school_interest(c, s)
	check(high > low, "more points, more interest (%.0f > %.0f)" % [high, low])
	# At a tier's offer bar, interest sits around 50 (the per-school lean is +/- 6).
	var tr := Progression.tier(str(s["tier"]))
	c.recruiting_score = float(tr.get("min_recruiting", 50))
	var at_bar := CareerRecords.school_interest(c, s)
	check(at_bar >= 44.0 and at_bar <= 56.0, "about 50 at the offer bar (%.0f)" % at_bar)


func test_offers_and_gpa_shape_interest() -> void:
	var c := _load("career_v2_hs_junior.json")
	c.recruiting_score = 0.0
	var s: Dictionary = CareerContent.colleges()[0]
	c.offers = [{"school": str(s["id"]), "name": str(s["name"]), "tier": str(s["tier"]), "type": "full",
		"season": c.season}]
	check(CareerRecords.school_interest(c, s) >= 85.0, "a full offer means top interest")
	var listed := CareerRecords.interested_schools(c)
	check(listed.any(func(e: Dictionary) -> bool: return e["school"]["id"] == s["id"] and not e["offer"].is_empty()),
		"offering school is listed with its offer")
	c.offers.clear()
	c.recruiting_score = 100.0
	c.gpa = 0.5
	var capped := CareerRecords.school_interest(c, s)
	check(capped <= 35.0, "GPA below the bar caps interest (%.0f)" % capped)


func test_interested_schools_sorted() -> void:
	var c := _load("career_v2_hs_junior.json")
	c.recruiting_score = 55.0
	c.gpa = 3.5
	var listed := CareerRecords.interested_schools(c)
	check(not listed.is_empty(), "some schools interested at 55 points")
	for i in range(1, listed.size()):
		check(float(listed[i - 1]["interest"]) >= float(listed[i]["interest"]), "sorted by interest")
	for e in listed:
		check(float(e["interest"]) >= CareerRecords.LIST_MIN_INTEREST or not e["offer"].is_empty(),
			"only real interest is listed")
