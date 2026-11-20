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
	check(absf(KickRange.fg_from_power(50.0, t) - 50.2) < 0.2, "Power 50 is about 50")
	var prev := 0.0
	var prev_step := 99.0
	for p in range(30, 101, 10):
		var r := KickRange.fg_from_power(p, t)
		check(r > prev, "range grows with Power (%d)" % p)
		if p > 30:
			check(r - prev <= prev_step + 0.001, "diminishing yards per Power (%d)" % p)
			prev_step = r - prev
		prev = r
	eq(KickRange.kickoff_from_power(30.0, t), 52.0, "kickoff range at the start")
	eq(KickRange.kickoff_from_power(100.0, t), 75.0, "kickoff range at Power 100")
	check(KickRange.fg_from_power(0.0, t) >= t.range_min, "never below the minimum")


func test_full_flick_reaches_range_and_no_further() -> void:
	var kt := KickRange.kick_tuning()
	var c := _career()
	c.range_physics = true
	for p in [30.0, 50.0, 75.0, 100.0]:
		c.set_stat("power", p)
		var prof := KickProfile.build(c, t)
		var r := prof.fg_range
		check(prof.power_needed(r, kt) <= 1.0, "Power %d: %.1f yd is reachable" % [p, r])
		check(prof.power_needed(r + 1.0, kt) > 1.0, "Power %d: %.1f yd is not" % [p, r + 1.0])
		eq(prof.max_range_yards(), floori(r + 0.001), "max_range_yards is today's range")


func test_range_physics_switch() -> void:
	var kt := KickRange.kick_tuning()
	check(not t.sp_range_physics, "off by default for new careers")
	check(not CareerData.create("Default", t).range_physics, "a new career copies the default")
	for p in [30.0, 55.0, 100.0]:
		var c := _career()
		c.set_stat("power", p)
		c.range_physics = true
		var on := KickProfile.build(c, t)
		check(absi(on.reach_yards(kt) - floori(on.fg_range)) <= 1,
			"ON, Power %d: the ball carries %d yd, range %.1f (within 1 yd)" % [p, on.reach_yards(kt), on.fg_range])
		c.range_physics = false
		var off := KickProfile.build(c, t)
		eq(off.power_mult, CareerTuning.blend(t.power_mult_at_0, t.power_mult_at_100, p, t.power_curve)
			+ off.range_yd / t.legacy_power_mult_yards, "OFF, Power %d: the old launch speed" % p)
		eq(off.fg_range, on.fg_range, "the range (Hub, coach) is the same either way")
		eq(KickTrust.coach_limit(c, off, t), KickTrust.coach_limit(c, on, t), "so is the coach's limit")
	var c30 := _career()
	c30.set_stat("power", 30)
	check(KickProfile.build(c30, t).reach_yards(kt) > 60, "OFF: today's long ball (Power 30 carries 60+ yd)")


func test_kickoff_carries_kickoff_range_in_both_settings() -> void:
	for physics in [true, false]:
		var c := _career()
		c.set_stat("power", 60)
		c.range_physics = physics
		var prof := KickProfile.build(c, t)
		var rules := CareerGameMode.kickoff_rules_for(t, Progression.game_params(c, t), prof)
		# The kick scene's carry at a full flick: max carry x power_mult.
		check(absf(rules.max_carry_yards * prof.power_mult - prof.kickoff_range) < 0.01,
			"physics %s: a full kickoff carries the kickoff range (%.1f)" % [physics, prof.kickoff_range])


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
	eq(SkillPoints.cost_at(30, t), 2, "cost at 30")
	eq(SkillPoints.cost_at(50, t), 4, "cost at 50")
	eq(SkillPoints.cost_at(70, t), 6, "cost at 70")
	eq(SkillPoints.cost_at(90, t), 9, "cost at 90")
	var c := _career()
	c.skill_points = 3
	var before := c.stat("power")
	check(SkillPoints.upgrade(c, "power", t), "affordable upgrade")
	eq(c.stat("power"), before + 1.0, "one point")
	eq(c.skill_points, 1, "paid 2")
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


func test_no_automatic_football_growth() -> void:
	# The settings are gone (not just 0), and a game, a week and an offseason
	# leave football attributes alone.
	for knob in ["weekly_football_growth", "offseason_football_growth", "make_accuracy_gain",
			"long_make_power_gain", "clutch_resilience_gain", "miss_resilience_gain",
			"good_kickoff_power_gain", "good_kickoff_toughness_gain"]:
		check(not (knob in t), "%s removed" % knob)
	var c := CareerData.create("Growth", t)
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c, t)
	var ch := m.game_changes({"outcome": "W", "warmups": ["pure", "skipped"], "kicks": [
		{"kind": "fg", "made": true, "yards": 50, "pressure": 0.9}, {"kind": "fg", "made": false, "yards": 30},
		{"kind": "kickoff", "quality": 1.0}]})
	for k in CareerData.GROUP_KEYS[CareerData.FOOTBALL]:
		check(not ch.has(k), "a game doesn't change " + k)
	m._start_season(false)
	var before := {}
	for k in CareerData.GROUP_KEYS[CareerData.FOOTBALL]:
		before[k] = c.stat(k)
	c.phase = CareerManager.PHASE_RESULTS
	m.end_week()
	m._start_next_season()
	for k in CareerData.GROUP_KEYS[CareerData.FOOTBALL]:
		eq(c.stat(k), float(before[k]), "a week and an offseason don't change " + k)


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
	for made in [true, false, true, false, false]:
		kicks.append(_kick("fg", made))
	var res := KickTrust.apply_game(c, kicks, 50.0, t)
	check(res["slump"], "3 misses in the last 5: slump")
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
	KickTrust.apply_game(c, [_kick("fg", false), _kick("fg", false), _kick("fg", false)], 50.0, t)
	check(c.coach_doubt.is_empty(), "3 misses: window not full, too few tries for the season rule")
	KickTrust.apply_game(c, [_kick("fg", true), _kick("fg", true)], 50.0, t)
	check(not c.coach_doubt.is_empty(), "window full with 3 misses: slump")
	KickTrust.apply_game(c, [_kick("fg", true), _kick("fg", true), _kick("fg", true),
		_kick("fg", true), _kick("fg", true)], 50.0, t)
	check(c.coach_doubt.is_empty(), "5 straight makes clear the doubt early")


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


# --- ported: coach limit in the game sim, bad stretch, Team drift, warmups, SP sources ---

func test_game_sim_respects_the_coach_limit() -> void:
	var c := _career()
	var e := {"week": 1, "type": "regular", "home": true, "weather": {"wind": 0},
		"opponent": Progression.team_from(CareerContent.high_schools()[1], "high_school")}
	var longest := 0
	var fgs := 0
	for seed in 60:
		var sim := GameSim.new()
		sim.setup(c, e, t, seed, 35, {"call_random_yd": 2, "call_cap_yd": 36})
		for i in 2000:
			var ev := sim.next()
			if ev.get("type", "") == "end":
				break
			if ev.get("type", "") == "call":
				if ev["kind"] == "fg":
					fgs += 1
					longest = maxi(longest, int(ev["yards"]))
				sim.resolve_call({"made": true, "quality": 0.5, "carry": 50.0, "recovered": false})
	check(fgs > 20, "field goals were called (%d)" % fgs)
	check(longest <= 36, "never past the limit + 2, capped at the range (longest %d)" % longest)


func _fg(made: bool) -> Dictionary:
	return {"kind": "fg", "made": made, "yards": 35, "q": 2, "us": 7, "them": 7, "label": "", "pressure": 0.2}


func test_bad_stretch() -> void:
	var c := _career()
	var kicks: Array = []
	for made in [true, false, true, false, false, false, true, false, false, true]:  # 4 of 10
		kicks.append(_fg(made))
	var before := c.recruiting_score
	var coach_before := Relationships.value(c, "coach")
	var team_before := Relationships.value(c, Relationships.TEAM)
	check(KickTrust._bad_stretch(c, kicks, t), "under 50% over 10")
	check(c.flags.get("coach_lost_faith", false), "flag")
	eq(Relationships.value(c, "coach"), coach_before + t.stretch_coach, "Coach -8")
	eq(Relationships.value(c, Relationships.TEAM), team_before + t.stretch_team, "Team -3")
	eq(c.recruiting_score, maxf(before + t.stretch_progress, 0.0), "recruiting -2")
	eq(c.stretch_cooldown, t.stretch_cooldown_weeks, "then a 5-week rest")
	check(not KickTrust._bad_stretch(c, [_fg(false)], t), "not again during the rest")
	for i in t.stretch_cooldown_weeks:
		KickTrust.end_week(c)
	eq(c.stretch_cooldown, 0, "rest over")
	var d := _career()
	check(not KickTrust._bad_stretch(d, [_fg(false), _fg(false), _fg(false)], t), "too few attempts")
	var col := _career()
	col.stage = CareerData.STAGE_COLLEGE
	col.draft_score = 20.0
	KickTrust._bad_stretch(col, kicks, t)
	eq(col.draft_score, 20.0 + t.stretch_progress, "college: draft stock -2")


func test_team_social_drift() -> void:
	var c := _career()
	Relationships.apply(c, {Relationships.TEAM: 50})
	eq(float(Relationships.weekly_growth(c, t).get("social", 0.0)), t.rel_team_social, "Team at 100: +1 Social a week")
	Relationships.apply(c, {Relationships.TEAM: -100})
	eq(float(Relationships.weekly_growth(c, t).get("social", 0.0)), -t.rel_team_social, "Team at 0: -1")


func test_warmup_sp_cap_and_sources() -> void:
	var c := _career()
	var m := CareerManager.new(c, t)
	m._start_season(false)
	m.data.phase = CareerManager.PHASE_GAME
	var sp0 := c.skill_points
	m.finish_game({"outcome": "W", "us": 14, "them": 7, "kicks": [], "warmups": ["pure", "pure"]})
	eq(int(c.sp_sources.get("Sideline warmup", 0)), t.sp_warmup_max_per_game, "two pure warmups: capped at 1")
	check(c.skill_points > sp0, "SP earned")
	var total := 0
	for k in c.sp_sources:
		total += int(c.sp_sources[k])
	eq(total, c.sp_season, "every SP this season has a source")
