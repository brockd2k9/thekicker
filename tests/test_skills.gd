extends "res://tests/test_case.gd"
## Skill points, field goal / kickoff range, the range -> kick physics mapping,
## Coach and Team changes from kick results, coach doubt, and save version 4.

var t := CareerTuning.get_default()


func _career() -> CareerData:
	var c := CareerData.create("Skills Test", t)
	c.created = 1794983149
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	c.set_stat("energy", 60.0)  # no rested / tired yards
	c.set_stat("health", 60.0)
	return c


# --- range ----------------------------------------------------------------------------

func test_range_curve() -> void:
	eq(KickRange.fg_from_power(30.0, t), 40.0, "a new freshman kicks 40")
	eq(KickRange.fg_from_power(100.0, t), 66.0, "Power 100: 66 before perks")
	var x50 := pow((50.0 - t.range_power_start) / (100.0 - t.range_power_start), t.range_curve)
	eq(KickRange.fg_from_power(50.0, t), t.range_at_start + (t.range_at_100 - t.range_at_start) * x50, "Power 50 on the curve")
	var prev := 0.0
	var prev_step := 99.0
	for p in range(30, 101, 10):
		var r := KickRange.fg_from_power(p, t)
		check(r > prev, "range grows with Power (%d)" % p)
		if p > 30:
			check(r - prev <= prev_step + 0.001, "no more yards per Power as it climbs (%d)" % p)
			prev_step = r - prev
		prev = r
	eq(KickRange.kickoff_from_power(30.0, t), 52.0, "kickoff range at the start")
	eq(KickRange.kickoff_from_power(100.0, t), 75.0, "kickoff range at Power 100")
	check(KickRange.fg_from_power(0.0, t) >= t.range_min, "never below the minimum")


func test_full_flick_reaches_range_and_no_further() -> void:
	var kt := KickRange.kick_tuning()
	var c := _career()
	for p in [30.0, 50.0, 75.0, 100.0]:
		c.set_stat("power", p)
		var prof := KickProfile.build(c, t)
		var r := prof.fg_range
		check(prof.power_needed(r, kt) <= 1.0, "Power %d: %.1f yd is reachable" % [p, r])
		check(prof.power_needed(r + 1.0, kt) > 1.0, "Power %d: %.1f yd is not" % [p, r + 1.0])
		eq(prof.max_range_yards(), floori(r + 0.001), "max_range_yards is today's range")


func test_game_day_range() -> void:
	var c := _career()
	var base := KickProfile.build(c, t)
	c.set_stat("energy", 90.0)
	c.set_stat("health", 95.0)
	var fresh := KickProfile.build(c, t)
	eq(fresh.fg_range - base.fg_range, t.rested_range_yd + t.healthy_range_yd, "rested and healthy add yards")
	check(fresh.outlook.any(func(l: Dictionary) -> bool:
		return l["label"] == "Rested" and str(l["detail"]).contains("+2 yds") and l["good"]), "Outlook: Rested +2 yds")
	c.set_stat("energy", 10.0)
	var tired := KickProfile.build(c, t)
	check(tired.fg_range < base.fg_range, "exhausted: shorter")
	check(tired.outlook.any(func(l: Dictionary) -> bool: return str(l["detail"]).contains("-3 yds")),
		"Outlook shows the yards lost")
	c.set_stat("energy", 60.0)
	c.injury = {"weeks_left": 2, "severity": 1.0}
	check(KickProfile.build(c, t).fg_range < base.fg_range, "injured: shorter")
	c.injury = {"weeks_left": 0, "severity": 0.0}
	c.set_stat("health", 60.0)
	var heavy := KickProfile.build(c, t, {"modifiers": ["heavy_legs"]})
	eq(heavy.fg_range - base.fg_range, -2.0, "converted modifier: heavy legs -2 yds")


func test_kickoff_carry_matches_kickoff_range() -> void:
	var c := _career()
	c.set_stat("power", 70.0)
	var prof := KickProfile.build(c, t)
	var r := CareerGameMode.kickoff_rules_for(t, Progression.game_params(c, t), prof)
	eq(r.max_carry_yards * prof.power_mult, prof.kickoff_range, "full kickoff carries the kickoff range")
	var m := prof.to_kick_modifiers()
	eq(m.kickoff_range_yd, prof.kickoff_range, "KickModifiers carries the kickoff range")
	eq(m.kickoff_mult * KickoffRules.new().max_carry_yards, prof.kickoff_range, "kickoff_mult scale")
	var neutral := KickModifiers.new()
	eq(neutral.power_mult, 1.0, "Practice / Challenge unchanged")
	eq(neutral.kickoff_mult, 1.0, "Practice / Challenge kickoffs unchanged")


func test_touchback_check() -> void:
	var hs := {"kickoff_spot": 40}
	var col := {"kickoff_spot": 35}
	check(not KickRange.touchback_possible(59.0, hs, t), "59 from the 40: short")
	check(KickRange.touchback_possible(60.0, hs, t), "60 from the 40: end zone")
	check(not KickRange.touchback_possible(64.0, col, t), "64 from the 35: short")


# --- skill points ---------------------------------------------------------------------

func test_upgrade_costs_and_purchase() -> void:
	for lvl in [30, 50, 70, 90]:
		eq(SkillPoints.cost_at(lvl, t), int(ceilf(t.upgrade_cost_base + t.upgrade_cost_scale
			* pow(lvl / 100.0, t.upgrade_cost_exp))), "cost at %d" % lvl)
	check(SkillPoints.cost_at(90, t) > SkillPoints.cost_at(70, t) and SkillPoints.cost_at(70, t) > SkillPoints.cost_at(30, t),
		"cost rises with the level")
	var c := _career()
	var cost := SkillPoints.cost_at(c.stat("power"), t)
	c.skill_points = cost + 1
	var before := c.stat("power")
	check(SkillPoints.upgrade(c, "power", t), "affordable upgrade")
	eq(c.stat("power"), before + 1.0, "one point")
	eq(c.skill_points, 1, "paid the cost")
	check(not SkillPoints.upgrade(c, "power", t), "can't afford the next")
	eq(float(c.sp_upgrades.get("power", 0.0)), 1.0, "upgrade logged")
	check(not SkillPoints.upgrade(c, "energy", t), "life stats can't be bought")
	c.set_stat("accuracy", 100.0)
	c.skill_points = 100
	check(not SkillPoints.upgrade(c, "accuracy", t), "maxed")
	eq(SkillPoints.cost(c, "accuracy", t), 0, "maxed: no cost")


func test_upgrade_preview() -> void:
	var c := _career()
	var pv := SkillPoints.preview(c, "power", t)
	eq(pv.size(), 2, "power preview: FG and kickoff range")
	eq(str(pv[0]["label"]), "FG range", "first line")
	check(str(pv[0]["now"]) != str(pv[0]["next"]), "shows a change")
	for s in ["accuracy", "resilience", "toughness"]:
		check(not SkillPoints.preview(c, s, t).is_empty(), s + " preview")


func test_skill_points_from_a_game() -> void:
	var kicks := [
		{"kind": "fg", "yards": 30, "made": true, "pressure": 0.2, "label": ""},
		{"kind": "fg", "yards": 47, "made": true, "pressure": 0.7, "label": "0:40 - DOWN 1 - GAME WINNER"},
		{"kind": "pat", "yards": 20, "made": true},
		{"kind": "kickoff", "quality": 0.9}]
	var got := {}
	for pair in SkillPoints.from_game(kicks, 48.0, t):
		got[pair[0]] = pair[1]
	eq(got.get("Field goals made", 0), 2, "makes")
	eq(got.get("Long makes", 0), 1, "long make")
	eq(got.get("Clutch makes", 0), 1, "clutch make")
	eq(got.get("Game winner", 0), t.sp_game_winner, "game winner")
	eq(got.get("Perfect game", 0), t.sp_perfect_game, "perfect game")
	kicks[0]["made"] = false
	check(not SkillPoints.from_game(kicks, 48.0, t).any(func(p: Array) -> bool: return p[0] == "Perfect game"),
		"a miss: no perfect game")


func test_scenario_skill_points_and_scale() -> void:
	var c := _career()
	SkillPoints.from_choice(c, 3, t)
	eq(c.skill_points, 3, "choice SP")
	SkillPoints.from_choice(c, -5, t)
	eq(c.skill_points, 0, "never below 0")
	var t2 := CareerTuning.new()
	t2.scenario_football_scale = 0.5
	var s := ScenarioEngine.scaled_stats({"football": {"power": 2.0}, "life": {"fun": 4.0}}, t2)
	eq(float(s["football"]["power"]), 1.0, "football gains scaled")
	eq(float(s["life"]["fun"]), 4.0, "other gains untouched")


func test_passive_football_growth_is_off() -> void:
	eq(t.weekly_football_growth, 0.0, "weekly")
	eq(t.offseason_football_growth, 0.0, "offseason")
	eq(t.make_accuracy_gain, 0.0, "per make")


# --- kick trust -----------------------------------------------------------------------

func _kick(kind: String, made: bool, yards := 35, q := 2, us := 7, them := 7, label := "", pressure := 0.2) -> Dictionary:
	return {"kind": kind, "made": made, "yards": yards, "q": q, "us": us, "them": them,
		"label": label, "pressure": pressure}


func _delta(c: CareerData, k: Dictionary, range := 50.0) -> Dictionary:
	return KickTrust.step(KickTrust.view(c), k, range, t)


func test_misses_cost_more_than_makes_earn() -> void:
	var c := _career()
	var miss := _delta(c, _kick("fg", false))
	var make := _delta(c, _kick("fg", true))
	check(float(miss["coach"]) < 0.0 and float(miss["team"]) < 0.0, "miss lowers both")
	check(float(make["coach"]) > 0.0 and float(make["team"]) > 0.0, "make raises both")
	check(absf(float(miss["coach"])) > absf(float(make["coach"])), "a miss outweighs a make")


func test_situation_and_difficulty_scale() -> void:
	var c := _career()
	var routine := absf(float(_delta(c, _kick("fg", false))["coach"]))
	var gw := _delta(c, _kick("fg", false, 40, 4, 14, 16, "1:10 - DOWN 2 - GAME WINNER", 1.0))
	check(absf(float(gw["coach"])) > routine * 2.0, "a missed game winner costs the most")
	eq(str(gw["reason"]), "Missed a game-winning kick.", "reason line")
	var go := _delta(c, _kick("fg", false, 35, 4, 20, 21))
	eq(str(go["reason"]), "Missed a go-ahead kick.", "go-ahead")
	var tie := _delta(c, _kick("fg", false, 35, 4, 18, 21))
	eq(str(tie["reason"]), "Missed a tying kick.", "tying")
	check(absf(float(go["coach"])) > routine, "go-ahead matters more than routine")
	var easy := absf(float(_delta(c, _kick("fg", false, 25))["coach"]))
	var edge := absf(float(_delta(c, _kick("fg", false, 48))["coach"]))
	check(easy > routine and routine > edge, "short miss > routine > edge-of-range miss")
	var pat := absf(float(_delta(c, _kick("pat", false, 20))["coach"]))
	var short_fg := absf(float(_delta(c, _kick("fg", false, 20))["coach"]))
	check(pat < short_fg, "extra points matter less")
	var big := _delta(c, _kick("fg", true, 40, 4, 14, 16, "1:10 - DOWN 2 - GAME WINNER", 1.0))
	check(float(big["coach"]) > float(_delta(c, _kick("fg", true))["coach"]) * 2.0, "a made game winner earns a lot")


func test_resilience_and_leadership_soften_misses() -> void:
	var c := _career()
	var base := _delta(c, _kick("fg", false))
	c.set_stat("resilience", 100.0)
	c.set_stat("leadership", 100.0)
	var soft := _delta(c, _kick("fg", false))
	check(absf(float(soft["coach"])) < absf(float(base["coach"])), "Resilience: coach")
	check(absf(float(soft["team"])) < absf(float(base["team"])) * 0.8, "Resilience + Leadership: team")


func test_slump_window_and_coach_doubt() -> void:
	var c := _career()
	var kicks := []
	for i in t.kick_window - t.kick_window_misses:
		kicks.append(_kick("fg", true))
	for i in t.kick_window_misses:
		kicks.append(_kick("fg", false))
	var res := KickTrust.apply_game(c, kicks, 50.0, t)
	check(res["slump"], "%d misses in the last %d: slump" % [t.kick_window_misses, t.kick_window])
	check(not c.coach_doubt.is_empty(), "coach doubt starts")
	check(c.flags.get("kicking_slump", false), "story flag for HS_142")
	check(Relationships.value(c, "coach") < 50.0, "coach trust lost")
	var prof := KickProfile.build(c, t)
	var doubt_lim := KickTrust.coach_limit(c, prof, t)
	check(doubt_lim <= floori(prof.fg_range - t.doubt_range_yd), "doubt: shorter calls")
	var sim := GameSim.new()
	sim.setup(c, {"opponent": {"strength": 50}}, t, 1, doubt_lim)
	eq(sim._fg_chance_mult, t.doubt_fg_chance_mult, "doubt: fewer field goal drives")
	for i in t.doubt_weeks:
		KickTrust.end_week(c)
	check(c.coach_doubt.is_empty(), "doubt fades after its weeks")
	eq(KickTrust.coach_limit(c, prof, t), floori(prof.fg_range - t.coach_range_margin_yd
		+ Relationships.coach_range_yd(c, t) + 0.001), "full range again")


func test_slump_window_clears_early() -> void:
	var c := _career()
	var misses: Array = []
	for i in t.kick_window_misses:
		misses.append(_kick("fg", false))
	KickTrust.apply_game(c, misses, 50.0, t)
	check(c.coach_doubt.is_empty(), "window not full yet, too few tries for the season rule")
	var makes: Array = []
	for i in t.kick_window - t.kick_window_misses:
		makes.append(_kick("fg", true))
	KickTrust.apply_game(c, makes, 50.0, t)
	check(not c.coach_doubt.is_empty(), "window full with too many misses: slump")
	var streak: Array = []
	for i in t.kick_window:
		streak.append(_kick("fg", true))
	KickTrust.apply_game(c, streak, 50.0, t)
	check(c.coach_doubt.is_empty(), "a full window of makes clears the doubt early")


func test_live_view_matches_saved_result() -> void:
	var c := _career()
	var kicks := [_kick("fg", true), _kick("pat", false), _kick("fg", false, 45, 4, 10, 10)]
	var v := KickTrust.view(c)
	var coach := 0.0
	for k in kicks:
		coach += float(KickTrust.step(v, k, 50.0, t)["coach"])
	var before := Relationships.value(c, "coach")
	KickTrust.apply_game(c, kicks, 50.0, t)
	eq(Relationships.value(c, "coach") - before, coach, "the save gets what the screen showed")
	eq(c.recent_fg.size(), 2, "field goals only in the window")


func test_backup_kicks_dont_count() -> void:
	var c := _career()
	var k := _kick("fg", false)
	k["backup"] = true
	var d := _delta(c, k)
	eq(float(d["coach"]), 0.0, "backup miss: no change")


func test_change_text() -> void:
	eq(KickTrust.change_text(-4.2, -2.6), "Coach -4, Team -3", "both")
	eq(KickTrust.change_text(1.2, 0.3), "Coach +1", "rounded zero left out")


# --- saves ----------------------------------------------------------------------------

func test_v3_save_migrates_to_v4() -> void:
	var raw := fixture("career_v3_college.json")
	var c := CareerData.from_dict(CareerSave._migrate(raw.duplicate(true)))
	eq(c.to_dict()["career_version"], CareerData.VERSION, "now version %d" % CareerData.VERSION)
	eq(c.skill_points, t.sp_migrate_college, "college save: starting skill points")
	check(c.people.has(Relationships.TEAM), "Team standing added")
	var team := Relationships.value(c, Relationships.TEAM)
	check(team >= 35.0 and team <= 65.0, "Team from the record")
	check(KickRange.fg_range(c, t) >= 40.0, "range from the save's Power")
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(JSON.stringify(again.to_dict()), JSON.stringify(c.to_dict()), "v4 round trip")


func test_v4_fields_round_trip() -> void:
	var c := _career()
	c.skill_points = 17
	c.sp_season = 9
	c.sp_career = 40
	c.sp_upgrades = {"power": 3.0}
	c.recent_fg = [true, false, true]
	c.coach_doubt = {"weeks_left": 2, "reason": "x"}
	c.sp_week = [{"text": "Practice", "sp": 2}]
	var back := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(back.skill_points, 17, "skill points")
	eq(back.recent_fg, [true, false, true], "window")
	eq(int(back.coach_doubt.get("weeks_left", 0)), 2, "doubt")
	eq(float(back.sp_upgrades.get("power", 0.0)), 3.0, "upgrades")
	eq(back.sp_week.size(), 1, "week's SP lines")


func test_frozen_v4_save_loads_unchanged() -> void:
	var raw := fixture("career_v4_college.json")
	var c := CareerData.from_dict(CareerSave._migrate(raw.duplicate(true)))
	eq(c.skill_points, 23, "skill points kept")
	eq(c.recent_fg, [true, false, true, true, false], "kick window kept")
	eq(int(c.coach_doubt.get("weeks_left", 0)), 2, "coach doubt kept")
	check(c.flags.get("kicking_slump", false), "slump flag kept")
	eq(JSON.stringify(c.to_dict()["people"]), JSON.stringify(raw["people"]), "people kept exactly")
	eq(JSON.stringify(c.to_dict()["sp_upgrades"]), JSON.stringify(raw["sp_upgrades"]), "upgrades kept")
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(JSON.stringify(again.to_dict()), JSON.stringify(c.to_dict()), "v4 round trip")
