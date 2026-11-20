extends "res://tests/test_case.gd"
## Step 3: perks (data, prerequisites, buying, every effect), aging and
## maintenance, and cold / snow games.

var t := CareerTuning.get_default()


func _career() -> CareerData:
	var c := CareerData.create("Perk Test", t)
	c.created = 1794983149
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	c.set_stat("energy", 60.0)
	c.set_stat("health", 60.0)
	return c


func _give(c: CareerData, id: String) -> void:
	if not (id in c.perks):
		c.perks.append(id)


# --- perks ----------------------------------------------------------------------------

func test_perk_data_is_valid() -> void:
	eq(Perks.problems(), PackedStringArray(), "perks.json has no problems")
	eq(Perks.defs().size(), 15, "15 perks")
	for d in Perks.defs():
		check(Perks.effect_text(d) != "", "%s: effect text" % d["id"])


func test_prerequisites_and_buying() -> void:
	var c := _career()
	c.skill_points = 100
	check(not Perks.can_buy(c, "big_leg"), "Big Leg locked at Power 30")
	var reqs := Perks.requirements(c, Perks.def("big_leg"))
	check(reqs.size() == 1 and not reqs[0]["met"] and str(reqs[0]["text"]).contains("70"), "shows Power 70 unmet")
	c.set_stat("power", 70.0)
	var before := KickRange.fg_range(c, t)
	check(Perks.buy(c, "big_leg"), "buys Big Leg")
	eq(c.skill_points, 100 - int(Perks.def("big_leg")["cost"]), "paid")
	eq(KickRange.fg_range(c, t) - before, 2.0, "+2 yd range")
	check(not Perks.buy(c, "big_leg"), "can't buy twice")
	c.set_stat("power", 90.0)
	check(not Perks.can_buy(c, "cannon"), "Cannon: not in high school")
	c.stage = CareerData.STAGE_COLLEGE
	check(Perks.can_buy(c, "cannon"), "Cannon in college with Big Leg and Power 90")
	c.perks.erase("big_leg")
	check(not Perks.can_buy(c, "cannon"), "Cannon needs Big Leg")
	c.skill_points = 5
	c.set_stat("resilience", 70.0)
	check(not Perks.can_buy(c, "ice_in_the_veins"), "too few skill points")
	check(not Perks.can_buy(c, "film_junkie"), "Film Junkie needs the Film Student trait")
	c.traits.append("film_student")
	check(Perks.requirements_met(c, Perks.def("film_junkie")), "trait prerequisite met")


func test_range_never_past_the_cap() -> void:
	var c := _career()
	c.set_stat("power", 100.0)
	_give(c, "big_leg")
	_give(c, "cannon")
	eq(KickRange.fg_range(c, t), 70.0, "Power 100 + Big Leg + Cannon = 70 (the cap)")
	c.set_stat("energy", 95.0)
	c.set_stat("health", 95.0)
	eq(KickProfile.build(c, t).fg_range, 70.0, "rested: still capped at 70")


func test_profile_perks() -> void:
	var c := _career()
	var base := KickProfile.build(c, t)
	for id in ["ice_in_the_veins", "laser", "smooth_swing", "wind_reader"]:
		_give(c, id)
	var p := KickProfile.build(c, t)
	check(p.pressure_sensitivity < base.pressure_sensitivity, "Ice in the Veins: less pressure")
	check(p.accuracy_spread_deg < base.accuracy_spread_deg, "Laser: tighter aim")
	check(p.wobble_mult < base.wobble_mult, "Smooth Swing: less wobble")
	check(p.wind_mult < base.wind_mult, "Wind Reader: less wind")
	check(p.outlook.any(func(l: Dictionary) -> bool: return l["label"] == "Laser" and l["source"] == "perk"),
		"perks show on the Outlook")


func test_short_memory_and_captain() -> void:
	var c := _career()
	var miss := {"kind": "fg", "made": false, "yards": 35, "q": 2, "us": 0, "them": 0, "pressure": 0.2, "label": ""}
	var base := KickTrust.step(KickTrust.view(c), miss, 50.0, t)
	_give(c, "short_memory")
	var sm := KickTrust.step(KickTrust.view(c), miss, 50.0, t)
	check(absf(float(sm["coach"])) < absf(float(base["coach"])), "Short Memory: coach")
	check(absf(float(sm["team"])) < absf(float(base["team"])), "Short Memory: team")
	_give(c, "captains_calm")
	var cc := KickTrust.step(KickTrust.view(c), miss, 50.0, t)
	check(absf(float(cc["team"])) < absf(float(sm["team"])), "Captain's Calm: team")
	eq(float(cc["coach"]), float(sm["coach"]), "Captain's Calm: coach unchanged")
	var p0 := KickProfile.build(c, t)
	_give(c, "short_memory")
	var p1 := KickProfile.build(c, t, {"miss_streak": 2})
	var c2 := _career()
	var p2 := KickProfile.build(c2, t, {"miss_streak": 2})
	check(p1.pressure_add < p2.pressure_add, "Short Memory: miss streak hurts less")
	check(p0.fg_range > 0.0, "builds")


func test_clutch_onside_hang_time_film_junkie() -> void:
	var c := _career()
	_give(c, "clutch")
	var p := KickProfile.build(c, t)
	var gw := {"kind": "fg", "pressure": 1.0, "label": "0:40 - DOWN 2 - GAME WINNER"}
	eq(float(CareerGameMode.adjust_call(gw, p)["pressure"]), 0.75, "Clutch: game winner pressure x0.75")
	var normal := {"kind": "fg", "pressure": 0.5, "label": "Q2 - UP 3"}
	eq(float(CareerGameMode.adjust_call(normal, p)["pressure"]), 0.5, "Clutch: routine kicks unchanged")
	var params := Progression.game_params(c, t)
	var r0 := CareerGameMode.kickoff_rules_for(t, params, KickProfile.build(_career(), t))
	_give(c, "onside_specialist")
	_give(c, "hang_time")
	c.set_stat("power", 60.0)
	var p2 := KickProfile.build(c, t)
	var r1 := CareerGameMode.kickoff_rules_for(t, params, p2)
	check(r1.onside_max_yards > r0.onside_max_yards and r1.onside_aim_deg > r0.onside_aim_deg, "Onside Specialist: bigger window")
	check(r1.onside_good_chance > r0.onside_good_chance, "Onside Specialist: better recovery")
	check(r1.return_max_yards < r0.return_max_yards, "Hang Time: shorter returns")
	eq(KickRange.kickoff_range(c, t) - KickRange.kickoff_from_power(60.0, t), 3.0, "Hang Time: +3 yd kickoff range")
	var lim := KickTrust.coach_limit(c, p2, t)
	_give(c, "film_junkie")
	check(KickTrust.coach_limit(c, KickProfile.build(c, t), t) >= lim, "Film Junkie: coach calls longer (up to your range)")


func test_quick_recovery() -> void:
	var c := _career()
	var base := KickProfile.build(c, t).injury_risk
	_give(c, "quick_recovery")
	check(KickProfile.build(c, t).injury_risk < base, "lower injury chance")
	eq(Perks.total(c, "injury_weeks"), -1.0, "injuries a week shorter")


# --- aging ----------------------------------------------------------------------------

func test_aging_decline_rates() -> void:
	var c := _career()
	c.stage = CareerData.STAGE_PRO
	c.set_stat("power", 85.0)
	c.set_stat("accuracy", 85.0)
	c.set_stat("resilience", 85.0)
	c.set_stat("toughness", 85.0)
	c.age = 29
	eq(Aging.decline(c, "power", t), 0.0, "no decline at 29")
	c.age = 30
	eq(Aging.decline(c, "power", t), 1.0, "Power -1 at 30")
	eq(Aging.decline(c, "toughness", t), 1.0, "Toughness -1 at 30")
	eq(Aging.decline(c, "accuracy", t), 0.6, "Accuracy -0.6 at 30")
	eq(Aging.decline(c, "resilience", t), 0.3, "Resilience -0.3 at 30")
	c.age = 35
	eq(Aging.decline(c, "power", t), 3.5, "Power -3.5 at 35")
	c.age = 38
	eq(Aging.decline(c, "power", t), 5.0, "Power -5 at 38")
	_give(c, "iron_leg")
	eq(Aging.decline(c, "power", t), 2.5, "Iron Leg halves Power decline")
	eq(Aging.decline(c, "toughness", t), 5.0, "Iron Leg: Toughness unchanged")


func test_maintenance_costs_and_season_end() -> void:
	var c := _career()
	c.stage = CareerData.STAGE_PRO
	c.age = 30
	for s in Aging.STATS:
		c.set_stat(s, 85.0)
	var cost30 := Aging.maintain_cost(c, "power", t)
	eq(cost30, int(ceilf(1.0 * SkillPoints.cost_at(85.0, t) * t.maintain_cost_mult)), "decline x next point x mult at 30")
	c.age = 35
	var cost35 := Aging.maintain_cost(c, "power", t)
	check(cost35 > cost30 * 2, "much more at 35 (got %d)" % cost35)
	c.skill_points = cost35
	check(Aging.maintain(c, "power", t), "preserve Power")
	eq(c.skill_points, 0, "paid")
	check(not Aging.maintain(c, "power", t), "once per season")
	var out := Aging.apply_season_end(c, t)
	eq(c.stat("power"), 85.0, "preserved Power held")
	eq(c.stat("toughness"), 85.0 - 3.5, "Toughness declined")
	check(not out.has("power") and out.has("toughness"), "decline report")
	check(c.maintained.is_empty(), "maintenance resets")
	c.age = 25
	eq(Aging.apply_season_end(c, t), {}, "no aging before 30")


func test_season_end_applies_aging() -> void:
	var c := _career()
	c.stage = CareerData.STAGE_PRO
	c.age = 32
	c.team = Progression.team_from(CareerContent.pro_clubs()[0], CareerData.STAGE_PRO)
	c.contract = Progression.contract(str(CareerContent.pro_clubs()[0]["id"]), "drafted", 3)
	c.set_stat("power", 80.0)
	var m := CareerManager.new(c, t)
	m._start_season(true)
	c.phase = CareerManager.PHASE_SEASON_END
	m.end_season()
	eq(c.stat("power"), 80.0 - 2.0, "Power -2 at 32 after the season")
	check(c.history[-1].get("aged", {}).has("power"), "history records it")


# --- weather --------------------------------------------------------------------------

func _with_weather(c: CareerData, w: Dictionary) -> void:
	c.week = 9
	c.schedule = [{"week": 9, "type": "regular", "opponent": {"strength": 50}, "weather": w}]


func test_cold_and_snow_games() -> void:
	var c := _career()
	_with_weather(c, {"wind": 0.0})
	var base := KickProfile.build(c, t)
	_with_weather(c, {"wind": 0.0, "temp": "cold", "chill": 2})
	var cold := KickProfile.build(c, t)
	eq(base.fg_range - cold.fg_range, 2.0, "cold: -2 yd")
	check(cold.outlook.any(func(l: Dictionary) -> bool: return l["label"] == "Cold Night" and str(l["detail"]).contains("-2 yds")),
		"Outlook: Cold Night -2 yds")
	_with_weather(c, {"wind": 0.0, "temp": "snow", "chill": 3})
	var snow := KickProfile.build(c, t)
	eq(base.fg_range - snow.fg_range, 3.0, "snow: -3 yd")
	check(snow.accuracy_spread_deg > base.accuracy_spread_deg, "snow: aim penalty")
	_give(c, "cold_weather_kicker")
	var perk := KickProfile.build(c, t)
	check(base.fg_range - perk.fg_range < 1.0, "Cold Weather Kicker removes most of it")
	check(perk.wind_mult < base.wind_mult, "Cold Weather Kicker: steadier in the wind in bad weather")


func test_cold_only_late_in_the_season() -> void:
	var c := _career()
	var m := CareerManager.new(c, t)
	m._start_season(false)
	var early := 0
	var late := 0
	for i in 300:
		var w := {}
		c.week = 2
		m._roll_cold(w)
		early += 1 if w.has("temp") else 0
		w = {}
		c.week = m.weeks_in_season()
		m._roll_cold(w)
		late += 1 if w.has("temp") else 0
	eq(early, 0, "never early in the season")
	check(late > 60 and late < 160, "late season: about 35%% cold or snow (got %d / 300)" % late)
