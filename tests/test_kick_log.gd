extends "res://tests/test_case.gd"
## Expanded kicking stats (CareerRecords + CareerData.kick_log, save version 6)
## and recruiting offers following interest (Progression.school_interest).


func _load(name: String) -> CareerData:
	return CareerData.from_dict(CareerSave._migrate(fixture(name)))


func _fg(yd: int, made: bool, season: int, stage := "high_school") -> Dictionary:
	return {"kind": "fg", "yd": yd, "made": 1 if made else 0, "season": season, "stage": stage}


func _pat(made: bool, season: int, stage := "high_school") -> Dictionary:
	return {"kind": "pat", "yd": 20, "made": 1 if made else 0, "season": season, "stage": stage}


## A career whose history and season lines match `log` exactly (so the log
## counts as complete): finished seasons go to history, the last is current.
func _career(log: Array, current_season: int, current_stage: String) -> CareerData:
	var c := CareerData.create("Log Test", CareerTuning.get_default())
	c.kick_log = log
	c.season = current_season
	c.stage = current_stage
	var by_season := {}
	for e in log:
		var s := int(e["season"])
		if not by_season.has(s):
			by_season[s] = {"stage": str(e["stage"]), "stats": CareerData.empty_kick_totals()}
		var st: Dictionary = by_season[s]["stats"]
		var kind := str(e["kind"])
		st[kind + "_att"] += 1
		if int(e["made"]) == 1:
			st[kind + "_made"] += 1
	var seasons := by_season.keys()
	seasons.sort()
	for s in seasons:
		if int(s) == current_season:
			c.season_stats = by_season[s]["stats"]
		else:
			c.history.append({"stage": by_season[s]["stage"], "season": int(s), "record": {"w": 0, "l": 0, "t": 0},
				"stats": by_season[s]["stats"], "team": "T", "year": ""})
	return c


# --- buckets -----------------------------------------------------------------------------

func test_bucket_boundaries() -> void:
	var cases := {19: 0, 20: 0, 29: 0, 30: 1, 39: 1, 40: 2, 49: 2, 50: 3, 59: 3, 60: 4, 75: 4}
	for yd in cases:
		eq(CareerRecords.bucket_of(int(yd)), int(cases[yd]), "%d yards bucket" % int(yd))


func test_bucket_counts() -> void:
	var s := CareerRecords.kick_summary([_fg(29, true, 1), _fg(30, false, 1), _fg(39, true, 1),
		_fg(40, true, 1), _fg(49, false, 1), _fg(50, true, 1), _fg(59, true, 1), _fg(60, false, 1)])
	eq(s["buckets"][0], {"made": 1, "att": 1}, "20-29")
	eq(s["buckets"][1], {"made": 1, "att": 2}, "30-39")
	eq(s["buckets"][2], {"made": 1, "att": 2}, "40-49")
	eq(s["buckets"][3], {"made": 2, "att": 2}, "50-59")
	eq(s["buckets"][4], {"made": 0, "att": 1}, "60+")


# --- streaks -----------------------------------------------------------------------------

func test_range_streak_ignores_other_ranges() -> void:
	# 25 made, 45 MISS, 26 made, 27 made: the miss is in another range, so the
	# 20-29 streak is 3; the overall field goal streak was broken (longest 2).
	var s := CareerRecords.kick_summary([_fg(25, true, 1), _fg(45, false, 1), _fg(26, true, 1), _fg(27, true, 1)])
	eq(s["bucket_long"][0], 3, "20-29 longest")
	eq(s["bucket_cur"][0], 3, "20-29 current")
	eq(s["bucket_long"][2], 0, "40-49 longest")
	eq(s["fg_long"], 2, "overall longest")
	eq(s["fg_cur"], 2, "overall current")


func test_xp_streak_separate_from_field_goals() -> void:
	var s := CareerRecords.kick_summary([_pat(true, 1), _fg(30, false, 1), _pat(true, 1), _pat(false, 1),
		_pat(true, 1)])
	eq(s["xp_long"], 2, "XP longest (a missed FG doesn't break it)")
	eq(s["xp_cur"], 1, "XP current")
	eq(s["fg_long"], 0, "no made FG")


func test_streak_carries_over_seasons_but_not_levels() -> void:
	# HS season 1: made, made. HS season 2: made, made (current HS streak 4).
	# College season 5: made. The college streak starts fresh.
	var log := [_fg(30, true, 1), _fg(31, true, 1), _fg(32, true, 2), _fg(45, true, 2),
		_fg(33, true, 5, "college")]
	var c := _career(log, 5, "college")
	var hs := CareerRecords.expanded(c, CareerRecords.LEVEL_HS)
	check(hs["known"], "HS fully logged")
	eq(hs["summary"]["fg_long"], 4, "HS streak runs across seasons 1-2")
	eq(hs["summary"]["bucket_long"][1], 3, "30-39 streak across seasons")
	check(not hs["playing"], "HS is finished: no current streak shown")
	var col := CareerRecords.expanded(c, CareerRecords.LEVEL_COLLEGE)
	eq(col["summary"]["fg_long"], 1, "college starts fresh")
	check(col["playing"], "college is the current level")
	var tot := CareerRecords.expanded(c, "total")
	check(tot["known"], "total fully logged")
	eq(tot["summary"]["fg_long"], 4, "total = best level streak")
	eq(tot["summary"]["fg_cur"], 1, "total current = current level's")
	eq(tot["summary"]["buckets"][1], {"made": 4, "att": 4}, "total 30-39 counts all levels")


func test_season_view_longest_this_season_current_carries() -> void:
	var log := [_fg(30, true, 1), _fg(31, true, 1), _fg(32, true, 2)]
	var c := _career(log, 2, "high_school")
	var s := CareerRecords.expanded(c, "season")
	check(s["known"], "season logged")
	eq(s["summary"]["fg_long"], 1, "longest within this season")
	eq(s["summary"]["fg_cur"], 3, "current streak carries over from last season")


# --- old saves and logging --------------------------------------------------------------

func test_old_saves_load_with_empty_log_and_dashes() -> void:
	for name in ["career_v0_minimal.json", "career_v1_stage_end.json", "career_v2_hs_junior.json",
			"career_v2_college.json", "career_v3_college.json", "career_v4_college.json", "career_v5_benched.json"]:
		var d := CareerSave._migrate(fixture(name))
		eq(int(d["career_version"]), CareerData.VERSION, name + " upgraded")
		var c := CareerData.from_dict(d)
		check(c.kick_log.is_empty(), name + " starts with an empty kick log")
		for scope in ["season", CareerRecords.LEVEL_HS, "total"]:
			var ex := CareerRecords.expanded(c, scope)
			var t: Dictionary = ex["totals"]
			if int(t["fg_att"]) + int(t["pat_att"]) > 0:
				check(not ex["known"], "%s %s: unlogged kicks -> '-' (not guessed)" % [name, scope])
	# Totals from the season lines still show for old saves.
	var c2 := _load("career_v2_college.json")
	var hs := CareerRecords.expanded(c2, CareerRecords.LEVEL_HS)
	check(int(hs["totals"]["fg_att"]) > 0, "old HS totals still there")


func test_kicks_are_logged_and_saved() -> void:
	var c := _load("career_v5_benched.json")
	c.slot = 0
	var m := CareerManager.new(c)
	var before := c.kick_log.size()
	m._record_kicks([
		{"kind": "fg", "yards": 44, "made": true, "label": "Down 2 - GAME WINNER"},
		{"kind": "pat", "yards": 20, "made": false, "label": ""},
		{"kind": "kickoff", "quality": 1.0, "carry": 66.4},
		{"kind": "onside", "recovered": true},
		{"kind": "fg", "yards": 30, "made": true, "backup": true}])  # the backup's kick isn't yours
	eq(c.kick_log.size() - before, 4, "four of your kicks logged")
	var fg: Dictionary = c.kick_log[before]
	eq([fg["kind"], fg["yd"], fg["made"], fg.get("clutch", 0), fg.get("gw", 0)], ["fg", 44, 1, 1, 1], "field goal entry")
	eq(int(c.kick_log[before + 2]["tb"]), 1, "touchback")
	eq(int(c.kick_log[before + 3]["rec"]), 1, "onside recovered")
	# Round trip through the save format.
	var back := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(back.kick_log.size(), c.kick_log.size(), "kick log saved and loaded")


func test_partial_season_shows_dashes_then_next_season_is_known() -> void:
	# An old save upgraded mid-season: its earlier kicks aren't in the log.
	var c := _load("career_v5_benched.json")
	var m := CareerManager.new(c)
	if int(c.season_stats["fg_att"]) + int(c.season_stats["pat_att"]) == 0:
		c.season_stats["fg_att"] = 2  # make sure the season had kicks before the update
	m._record_kicks([{"kind": "fg", "yards": 35, "made": true, "label": ""}])
	check(not CareerRecords.expanded(c, "season")["known"], "partly logged season shows '-'")
	# A new season, fully logged.
	c.history.append({"stage": c.stage, "season": c.season, "stats": c.season_stats.duplicate(),
		"record": {"w": 0, "l": 0, "t": 0}, "team": "T", "year": ""})
	c.season += 1
	c.season_stats = CareerData.empty_kick_totals()
	m._record_kicks([{"kind": "fg", "yards": 52, "made": true, "label": ""}])
	var s := CareerRecords.expanded(c, "season")
	check(s["known"], "new season is fully logged")
	eq(s["summary"]["buckets"][3], {"made": 1, "att": 1}, "50-59 counted")


# --- recruiting ---------------------------------------------------------------------------

func test_most_interested_school_in_a_tier_offers() -> void:
	for seed_n in [1, 2, 3, 4, 5]:
		var c := CareerData.create("Recruit %d" % seed_n, CareerTuning.get_default())
		c.created = 1000 + seed_n * 7919
		c.stage = CareerData.STAGE_HIGH_SCHOOL
		c.season_in_stage = 4
		c.gpa = 4.0
		c.recruiting_score = 80.0
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_n
		Progression.update_offers(c, rng)
		check(not c.offers.is_empty(), "offers made (seed %d)" % seed_n)
		for off in c.offers:
			var tier_id := str(off["tier"])
			var offered := TeamDatabase.team(str(off["school"]))
			for s in TeamDatabase.colleges():
				if str(s["tier"]) != tier_id or CareerRecords.offer_from(c, str(s["id"])).size() > 0:
					continue
				check(Progression.school_lean(c, str(s["id"])) <= Progression.school_lean(c, str(offered.get("id", ""))),
					"seed %d: %s (no offer) isn't more interested than %s (offer)" % [seed_n, s["name"], offered.get("name")])
		# Listed in interest order, and schools without an offer never outrank
		# an offering school of the same tier.
		var listed := CareerRecords.interested_schools(c)
		for i in listed.size():
			for j in range(i + 1, listed.size()):
				var a: Dictionary = listed[i]
				var b: Dictionary = listed[j]
				if a["school"]["tier"] == b["school"]["tier"] and a["offer"].is_empty() and not b["offer"].is_empty():
					check(false, "seed %d: %s listed above offering %s" % [seed_n, a["school"]["name"], b["school"]["name"]])


func test_high_interest_without_offer_is_flagged() -> void:
	var c := CareerData.create("Recruit", CareerTuning.get_default())
	c.stage = CareerData.STAGE_HIGH_SCHOOL
	c.gpa = 4.0
	c.recruiting_score = 90.0
	c.offers.clear()
	var listed := CareerRecords.interested_schools(c)
	var flagged := listed.filter(func(e: Dictionary) -> bool: return e["no_offer_yet"])
	check(not flagged.is_empty(), "offer-level interest without an offer is flagged")
	for e in flagged:
		check(float(e["interest"]) >= CareerRecords.OFFER_INTEREST and e["offer"].is_empty(), "flag only at 50+ without offer")
