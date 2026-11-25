extends "res://tests/test_case.gd"
## Followers: real counts from buzz x stage, Charisma, tiers and milestones,
## games (viral moments, missed game winners), choices (followers, exact,
## conduct, deals), caps, requirements, weekly and season effects, salary,
## fan pressure, display text and save v7.

var t := CareerTuning.get_default()


func _career(stage := CareerData.STAGE_HIGH_SCHOOL) -> CareerManager:
	var c := CareerData.create("Fan Test", t)
	c.created = 1794983149
	c.slot = 0
	c.team = Progression.team_from(TeamDatabase.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c, t)
	m.rng.seed = 11
	m._start_season(false)
	if stage != CareerData.STAGE_HIGH_SCHOOL:
		c.stage = stage
		c.team = Progression.team_from(TeamDatabase.colleges()[0], stage)
		Relationships.enter_stage(c, t)
	c.set_stat("charisma", 0.0)  # no Charisma bonus unless a test wants it
	return m


## A tuning copy with fixed viral chances.
func _tuning(viral: float, viral_miss: float) -> CareerTuning:
	var tt: CareerTuning = t.duplicate()
	tt.viral_chance_game_winner = viral
	tt.viral_chance_long = viral
	tt.viral_miss_chance = viral_miss
	return tt


func test_buzz_scales_by_stage_and_charisma() -> void:
	var hs := _career().data
	eq(Followers.from_buzz(hs, 1.0, t), roundi(t.followers_per_buzz_hs), "high school: small")
	var col := _career(CareerData.STAGE_COLLEGE).data
	eq(Followers.from_buzz(col, 1.0, t), roundi(t.followers_per_buzz_college), "college: medium")
	var pro := _career(CareerData.STAGE_PRO).data
	eq(Followers.from_buzz(pro, 1.0, t), roundi(t.followers_per_buzz_pro), "pro: large")
	pro.set_stat("charisma", 100.0)
	eq(Followers.from_buzz(pro, 1.0, t), roundi(t.followers_per_buzz_pro * (1.0 + t.buzz_charisma_bonus)),
		"Charisma adds to gains")
	eq(Followers.from_buzz(pro, -1.0, t), -roundi(t.followers_per_buzz_pro), "but not to losses")


func test_never_below_zero() -> void:
	var c := _career().data
	Followers.add(c, 50, "Choices", t)
	var n := Followers.gain(c, -100.0, "Scandal", t)
	eq(c.followers, 0, "floored at 0")
	eq(n, -50, "the change is what was actually lost")


func test_tiers_and_milestones() -> void:
	var c := _career().data
	eq(Followers.tier(c, t), 0, "Local Name at 0")
	var sp := c.skill_points
	Followers.add(c, 600, "Choices", t)
	eq(Followers.tier_name(Followers.tier(c, t)), "Hometown Hero", "500+")
	eq(c.skill_points - sp, t.tier_up_sp, "milestone skill points")
	check("Hometown Hero" in c.notice, "milestone notice")
	check(not ("points" in c.notice.replace("skill points", "")), "never says points for followers")
	Followers.add(c, -300, "Choices", t)
	Followers.add(c, 300, "Choices", t)
	eq(c.skill_points - sp, t.tier_up_sp, "dropping and coming back pays nothing again")
	# The season cap on followers' skill points.
	Followers.add(c, 3000000, "Choices", t)
	eq(c.skill_points - sp, t.followers_sp_season_cap, "capped for the season")
	eq(Followers.tier_name(Followers.tier(c, t)), "Household Name", "2M+")


func test_display_text() -> void:
	eq(Followers.short(950), "950", "small exact")
	eq(Followers.short(2400), "2,400", "comma")
	eq(Followers.short(12500), "12.5K", "K with a decimal")
	eq(Followers.short(85000), "85K", "round K")
	eq(Followers.short(340200), "340K", "big K")
	eq(Followers.short(1250000), "1.2M", "M")
	eq(Followers.change_text(120), "+120 followers", "gain")
	eq(Followers.change_text(-3400), "-3,400 followers", "loss")
	eq(Followers.change_text(1), "+1 follower", "one")
	eq(Followers.tier_label(2, t), "Rising Star (5K followers)", "tier label")


func test_game_followers() -> void:
	var m := _career()
	var c := m.data
	var tt := _tuning(0.0, 0.0)
	var kicks := [{"kind": "fg", "made": true, "yards": 30, "pressure": 0.2, "label": ""},
		{"kind": "fg", "made": true, "yards": 48, "pressure": 1.0, "label": "4Q - DOWN 2 - GAME WINNER"},
		{"kind": "pat", "made": true, "yards": 20}]
	var n := Followers.from_game(c, kicks, 45.0, m.rng, tt)
	var buzz := 2 * tt.buzz_make + tt.buzz_long_make + tt.buzz_clutch_make + tt.buzz_game_winner + tt.buzz_perfect_game
	eq(n, roundi(buzz * tt.followers_per_buzz_hs), "makes, long, clutch, game winner, perfect game")
	var texts := Followers.week_lines(c).map(func(e: Dictionary) -> String: return str(e["text"]))
	check("Game winner" in texts and "Perfect game" in texts, "Results lines")
	# The backup's kicks never count.
	var before := c.followers
	Followers.from_game(c, [{"kind": "fg", "made": true, "yards": 40, "backup": true}], 45.0, m.rng, tt)
	eq(c.followers, before, "backup kicks: nothing")


func test_viral_and_blooper() -> void:
	var m := _career()
	var c := m.data
	var tt := _tuning(1.0, 1.0)
	Followers.add(c, 1000, "Choices", tt)
	c.notice = ""
	var win := [{"kind": "fg", "made": true, "yards": 40, "pressure": 1.0, "label": "GAME WINNER"}]
	var n := Followers.from_game(c, win, 50.0, m.rng, tt)
	var base := tt.buzz_make + tt.buzz_clutch_make + tt.buzz_game_winner
	eq(n, roundi(base * tt.followers_per_buzz_hs) + roundi(base * (tt.viral_mult - 1.0) * tt.followers_per_buzz_hs),
		"viral multiplies the moment")
	check(c.notice.begins_with("VIRAL"), "a clear viral notice")
	eq(int(c.social.get("virals", 0)), 1, "counted")
	c.notice = ""
	var before := c.followers
	Followers.from_game(c, [{"kind": "fg", "made": false, "yards": 40, "label": "GAME WINNER"}], 50.0, m.rng, tt)
	var loss := tt.buzz_missed_game_winner * tt.viral_miss_mult * tt.followers_per_buzz_hs
	eq(c.followers - before, roundi(loss), "a missed game winner, gone viral")
	check("missed game winner" in c.notice, "blooper notice")
	# With the real (rare) chance, most missed game winners don't go viral.
	var lost := 0
	for i in 200:
		var cc := _career().data
		Followers.add(cc, 1000, "Choices", t)
		var r := RandomNumberGenerator.new()
		r.seed = i
		Followers.from_game(cc, [{"kind": "fg", "made": false, "yards": 40, "label": "GAME WINNER"}], 50.0, r, t)
		if cc.followers < 1000 + roundi(t.buzz_missed_game_winner * t.followers_per_buzz_hs):
			lost += 1
	check(lost < 30, "viral misses stay rare (%d of 200)" % lost)


func test_choices() -> void:
	var c := _career(CareerData.STAGE_COLLEGE).data
	var n := Followers.from_choice(c, {"followers": 3}, t)
	eq(n, roundi(3 * t.followers_per_buzz_college), "followers is scaled by stage")
	n = Followers.from_choice(c, {"followers_exact": 5000}, t)
	eq(n, 5000, "followers_exact is a raw count")
	n = Followers.from_choice(c, {"conduct": "good"}, t)
	eq(n, roundi(t.buzz_conduct_good * t.followers_per_buzz_college), "good conduct is rewarded")
	check(n > 0, "good moral choices earn followers")
	n = Followers.from_choice(c, {"conduct": "bad"}, t)
	check(n < 0, "bad conduct costs")
	eq(Followers.choice_preview(c, {"followers": 2, "conduct": "good"}, t),
		roundi((2 + t.buzz_conduct_good) * t.followers_per_buzz_college), "card preview")


func test_choice_through_the_engine() -> void:
	var c := _career().data
	var id := ""
	for s in CareerContent.scenarios():
		if not s.get("choices", []).is_empty() and (s.get("choices", [])[0] as Dictionary).get("requires", {}).is_empty():
			id = str(s["id"])
			break
	var s := CareerContent.scenario(id)
	var ch: Dictionary = (s["choices"] as Array)[0]
	var had := ch.duplicate(true)
	ch["followers"] = 4
	var out := ScenarioEngine.apply_choice(c, id, 0, t)
	eq(int(out.get("followers", 0)), roundi(4 * t.followers_per_buzz_hs), "apply_choice returns the change")
	eq(c.followers, int(out["followers"]), "and adds it")
	(s["choices"] as Array)[0] = had


func test_deals_and_scandal() -> void:
	var c := _career().data
	check(Followers.add_deal(c, {"id": "shop", "name": "Ridgeline Sports", "kind": "range", "value": 1.0}, t), "deal 1")
	check(Followers.add_deal(c, {"id": "drink", "name": "Bolt", "kind": "sp", "value": 1}, t), "deal 2")
	check(not Followers.add_deal(c, {"id": "third", "name": "X", "kind": "fun", "value": 1}, t), "at most deals_max")
	check(not Followers.add_deal(c, {"id": "bad", "name": "X", "kind": "money", "value": 1}, t), "unknown kind")
	var base := KickRange.fg_from_power(c.stat("power"), t)
	eq(KickRange.fg_range(c, t), base + 1.0, "range deal adds yards")
	var sp := c.skill_points
	var ch := Followers.end_week(c, t)
	eq(c.skill_points - sp, 1, "sp deal pays weekly")
	eq(float(ch.get("energy", 0.0)), 2 * t.deal_energy_week, "each deal costs Energy")
	Followers.from_choice(c, {"conduct": "scandal"}, t)
	check(Followers.deals(c).is_empty(), "a scandal ends the deals")
	check("sponsors drop you" in c.notice, "and says so")
	Followers.add_deal(c, {"id": "shop", "name": "Ridgeline Sports", "kind": "fun", "value": 1, "seasons": 1}, t)
	Followers.new_season(c)
	check(Followers.deals(c).is_empty(), "a one-season deal ends with the season")


func test_week_effects() -> void:
	var c := _career().data
	var fun := c.stat("fun")
	Followers.gain(c, t.buzz_week_good, "Choices", t)
	var ch := Followers.end_week(c, t)
	eq(float(ch.get("fun", 0.0)), t.followers_week_fun, "a big week: Fun")
	eq(float(ch.get("social", 0.0)), t.followers_week_social, "and Social")
	check(Followers.week_lines(c).is_empty(), "a fresh week")
	Followers.add(c, 5000, "Choices", t)
	Followers.end_week(c, t)
	Followers.gain(c, t.buzz_week_bad, "Benched", t)
	ch = Followers.end_week(c, t)
	eq(float(ch.get("fun", 0.0)), t.followers_week_bad_fun, "a bad week: less Fun")
	eq(c.stat("fun"), fun, "end_week only returns the changes")


func test_season_bonus_salary_and_pressure() -> void:
	var c := _career(CareerData.STAGE_PRO).data
	eq(Followers.progress_bonus(c, t), 0.0, "no bonus for Local Name")
	c.followers = Followers.threshold(3, t)  # Campus Celebrity
	eq(Followers.progress_bonus(c, t), minf(2.0 * t.followers_progress_per_tier, t.followers_standing_cap),
		"pros: standing bonus")
	c.followers = Followers.threshold(6, t)
	eq(Followers.progress_bonus(c, t), t.followers_standing_cap, "never past the cap")
	var col := _career(CareerData.STAGE_COLLEGE).data
	col.followers = Followers.threshold(6, t)
	eq(Followers.progress_bonus(col, t), t.followers_progress_cap, "college: the draft bonus cap (0: off)")
	eq(Followers.salary_bonus(c, t), t.followers_salary_cap, "salary bump capped at 10%")
	eq(Followers.salary(c, 1000000, t), roundi(1000000 * (1.0 + t.followers_salary_cap)), "salary")
	eq(Followers.fan_pressure(c, t), t.fan_pressure_cap, "fan pressure capped")
	c.followers = Followers.threshold(2, t)  # Rising Star
	eq(Followers.fan_pressure(c, t), 0.0, "no fan pressure up to Rising Star")
	c.followers = Followers.threshold(3, t)
	eq(Followers.fan_pressure(c, t), t.fan_pressure_per_tier, "one tier above")
	c.season_stats = {"fg_att": 20, "fg_made": 19}
	var r := Followers.season_end(c, t)
	eq(int(r["followers"]), roundi(t.buzz_great_season * t.followers_per_buzz_pro), "a great season")


func test_requirements() -> void:
	var c := _career().data
	check(not ScenarioEngine.requirements_met(c, {"followers_tier": "rising_star"}), "not yet a Rising Star")
	check(ScenarioEngine.requirements_met(c, {"max_followers_tier": "hometown_hero"}), "nobody knows you yet")
	c.followers = 6000
	check(ScenarioEngine.requirements_met(c, {"followers_tier": "rising_star"}), "Rising Star")
	check(not ScenarioEngine.requirements_met(c, {"max_followers_tier": "hometown_hero"}), "too famous now")
	check(ScenarioEngine.requirements_met(c, {"min": {"followers": 5000}}), "min.followers")
	check(not ScenarioEngine.requirements_met(c, {"max": {"followers": 5000}}), "max.followers")
	check(ScenarioEngine.requirements_met(c, {"any_of": [{"traits": ["nope"]}, {"followers_tier": "rising_star"}]}),
		"inside any_of")
	eq(ScenarioEngine.requirement_text({"followers_tier": "rising_star"}), "Rising Star (5K followers)", "lock text")


func test_game_and_bench_hooks() -> void:
	var m := _career()
	var c := m.data
	c.week = 5
	c.coach_doubt = {"weeks_left": 3, "reason": "misses"}
	Relationships.apply(c, {"coach": 27.0 - Relationships.value(c, "coach"),
		Relationships.TEAM: 30.0 - Relationships.value(c, Relationships.TEAM)})
	Followers.add(c, 2000, "Choices", t)
	Followers.end_week(c, t)
	Bench.begin_week(c, t, false)
	var before := c.followers
	m.data.phase = CareerManager.PHASE_GAME
	m.finish_game({"outcome": "L", "us": 3, "them": 10, "kicks": [
		{"kind": "fg", "made": false, "yards": 35}, {"kind": "fg", "made": false, "yards": 38}]})
	check(Bench.benched(c), "benched")
	eq(c.followers - before, roundi(t.buzz_benched * t.followers_per_buzz_hs), "being benched costs followers")


func test_migration_to_v7() -> void:
	var raw := fixture("career_v5_benched.json")
	var c := CareerData.from_dict(CareerSave._migrate(raw.duplicate(true)))
	eq(c.followers, t.followers_migrate_college, "a first-year college save starts at the college base")
	eq(int(c.social["best_tier"]), Followers.tier(c, t), "no milestone rewards for the starting count")
	var hs := fixture("career_v2_hs_junior.json")
	var h := CareerData.from_dict(CareerSave._migrate(hs.duplicate(true)))
	eq(h.followers, t.followers_migrate_hs + t.followers_migrate_hs_per_season * (int(hs.get("season_in_stage", 1)) - 1),
		"high school: base + seasons played")
	eq(Followers.migrate_start(CareerData.STAGE_PRO, 3, 3, t),
		t.followers_migrate_pro + 2 * t.followers_migrate_pro_per_season, "pros: base + pro seasons")


func test_frozen_v7_save_loads_unchanged() -> void:
	var raw := fixture("career_v7_followers.json")
	check(not raw.is_empty(), "fixture exists")
	var c := CareerData.from_dict(CareerSave._migrate(raw.duplicate(true)))
	eq(c.followers, int(raw["followers"]), "followers kept")
	eq(JSON.stringify(c.to_dict()["social"]), JSON.stringify(raw["social"]), "social kept exactly")
	check(not Followers.deals(c).is_empty(), "deal kept")
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(JSON.stringify(again.to_dict()), JSON.stringify(c.to_dict()), "v7 round trip")
