extends "res://tests/test_case.gd"
## Daily Challenge: the day function, streaks, the clock guard, deterministic
## scenarios, one claim per day, ad retry limits, ads unavailable, saves and
## migration, and that daily kicks stay out of every stat.

const DAY := 86400


func _daily(offset_min := 0, ads: AdService = null) -> Array:
	var clock := ManualDateSource.new(0, offset_min)
	clock.set_local(2026, 11, 23, 12)  # a Monday, noon
	var t := DailyTuning.new()
	if ads == null:
		var stub := StubAdService.new(t)
		stub.seconds = 0.0
		ads = stub
	var d := DailyChallenge.new(t, clock, ads)
	d.refresh(1)
	return [d, clock]


## Kick today's challenge: begin + finish.
func _kick(d: DailyChallenge, success: bool) -> int:
	check(d.begin_kick(), "can kick (status %s)" % d.status())
	return d.finish_kick(success)


func _next_day(d: DailyChallenge, clock: ManualDateSource, days := 1) -> void:
	clock.unix += DAY * days
	d.refresh(1)


# --- the day function ------------------------------------------------------------------------

func test_day_boundaries_are_local_midnight() -> void:
	var c := ManualDateSource.new(0, -300)  # UTC-5
	var a := DailyClock.day_number(c.at_local(2026, 11, 25, 0, 0), -300)
	var b := DailyClock.day_number(c.at_local(2026, 11, 25, 23, 59), -300)
	eq(b, a, "00:00 and 23:59 are the same day")
	eq(DailyClock.day_number(c.at_local(2026, 11, 26, 0, 0), -300), a + 1, "midnight starts the next day")
	eq(DailyClock.day_number(c.at_local(2026, 11, 25, 0, 0) - 1, -300), a - 1, "one second before midnight is yesterday")
	# One instant, two time zones: UTC+14 is already tomorrow where UTC-12 is today.
	var now := ManualDateSource.new(0, 0).at_local(2026, 11, 25, 6)
	eq(DailyClock.day_number(now, 14 * 60) - DailyClock.day_number(now, -12 * 60), 1, "time zones see different days")
	# Moving the reset to 4 am.
	var at3 := c.at_local(2026, 11, 26, 3, 0)
	eq(DailyClock.day_number(at3, -300, 4), a, "with a 4 am reset, 3 am is still yesterday")
	eq(DailyClock.day_number(c.at_local(2026, 11, 26, 4, 0), -300, 4), a + 1, "4 am starts the day")
	var date := DailyClock.date_of(a)
	eq(int(date["year"]) * 10000 + int(date["month"]) * 100 + int(date["day"]), 20261125, "date of the day")
	eq(int(date["weekday"]), 2, "Nov 25 2026 is a Wednesday (0 = Monday)")
	eq(DailyClock.seconds_to_next_day(c.at_local(2026, 11, 25, 23, 0), -300), 3600, "an hour to the reset")


func test_same_day_refresh_changes_nothing() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	clock.unix += 3600
	var before := d.to_dict()
	before.erase("last_seen_unix")
	d.refresh(3)
	var after := d.to_dict()
	after.erase("last_seen_unix")
	eq(after, before, "same day: nothing but last-seen changes (tier stays locked for the day)")
	eq(int(d.today["tier"]), 1, "tier locked at the first look")
	eq(d.status(), "ready", "ready")
	check(d.is_new(), "NEW badge")


# --- streaks ---------------------------------------------------------------------------------

func test_streak_grows_on_consecutive_days() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	eq(_kick(d, true), 2, "day 1 pays sp_daily")
	eq(d.streak, 1, "streak 1")
	eq(d.status(), "done", "done")
	check(not d.can_kick(), "one kick a day")
	_next_day(d, clock)
	eq(d.status(), "ready", "a new challenge the next day")
	eq(d.streak, 1, "streak alive overnight")
	_kick(d, true)
	_next_day(d, clock)
	eq(_kick(d, true), d.tuning.sp_daily + d.tuning.bonus_for(3), "day 3 pays the milestone bonus")
	eq(d.streak, 3, "streak 3")
	eq(d.longest, 3, "longest 3")
	eq(int(d.stats["completed"]), 3, "3 completed")
	eq(d.success_rate(), 100, "100%")


func test_missed_day_resets_streak_and_offers_saver_once() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	for i in 4:
		_kick(d, true)
		_next_day(d, clock)
	eq(d.streak, 4, "4 days")
	_next_day(d, clock)  # skipped a day
	eq(d.streak, 0, "a missed day resets the streak")
	eq(d.longest, 4, "longest kept")
	check(d.saver_offered(), "saver offered after exactly one missed day")
	eq(d.saver_streak(), 4, "it would bring back 4")
	eq(d.restore_streak(), 4, "restored")
	check(not d.saver_offered(), "saver gone once used")
	_kick(d, true)
	eq(d.streak, 5, "today continues the restored streak")
	# Miss another day: the saver was used for this streak.
	_next_day(d, clock, 2)
	eq(d.streak, 0, "broken again")
	check(not d.saver_offered(), "only once per streak")
	# A new streak gets its own saver.
	_kick(d, true)
	_next_day(d, clock, 2)
	check(d.saver_offered(), "a new streak has its saver back")


func test_saver_only_after_one_missed_day_and_only_that_day() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	_kick(d, true)
	_next_day(d, clock, 3)  # two days missed
	check(not d.saver_offered(), "two missed days: no saver")
	var r2 := _daily()
	var d2: DailyChallenge = r2[0]
	var c2: ManualDateSource = r2[1]
	_kick(d2, true)
	_next_day(d2, c2, 2)
	check(d2.saver_offered(), "offered on the day you come back")
	_next_day(d2, c2)
	check(not d2.saver_offered(), "gone the day after")


func test_saver_after_todays_success_stacks() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	for i in 3:
		_kick(d, true)
		_next_day(d, clock)
	_next_day(d, clock)
	_kick(d, true)
	eq(d.streak, 1, "a new streak started today")
	eq(d.restore_streak(), 4, "restored 3 + today")
	_next_day(d, clock)
	eq(d.streak, 4, "and it carries on tomorrow")


func test_kick_struck_before_midnight_and_judged_after_counts_for_its_day() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	_kick(d, true)
	_next_day(d, clock)
	var day := d.current_day()
	clock.set_local(2026, 11, 24, 23, 59)
	d.refresh(1)
	check(d.begin_kick(), "struck at 23:59")
	clock.unix += 120  # result at 00:01
	eq(d.finish_kick(true), d.tuning.reward_for(2), "judged after midnight, paid for its day")
	eq(d.last_completed_day, day, "counts for the day it was struck")
	d.refresh(1)
	eq(d.status(), "ready", "the new day's challenge is up")
	eq(d.streak, 2, "streak alive")


func test_kick_left_mid_flight_is_a_miss() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	check(d.begin_kick(), "struck")
	# The app closes; on the next start the saved data is loaded and refreshed.
	var saved: Dictionary = JSON.parse_string(JSON.stringify(d.to_dict()))
	var d2 := DailyChallenge.new(d.tuning, d.clock, d.ads)
	d2.from_dict(saved)
	d2.refresh(1)
	eq(d2.status(), "missed", "counted as a miss, not a free kick")
	eq(int(d2.today["attempts"]), 1, "the attempt is used")
	eq(int(d2.stats["kicks"]), 1, "a kick in the stats")


# --- clock guard -------------------------------------------------------------------------------

func test_clock_moved_backward_locks_and_never_reclaims() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	_kick(d, true)
	var claimed := d.claimed_days.size()
	var sp := d.pending_sp()
	clock.unix -= 3600  # an hour back, same day
	d.refresh(1)
	check(d.clock_back, "backward step noticed")
	check(not d.is_locked(), "same day: not locked")
	eq(d.status(), "done", "still done")
	clock.unix -= DAY  # to yesterday
	d.refresh(1)
	check(d.is_locked(), "a day already seen is locked")
	eq(d.status(), "locked", "locked status")
	check(not d.can_kick(), "no kicks")
	check(not d.begin_kick(), "begin refused")
	eq(d.claim(), 0, "no claims")
	eq(d.claimed_days.size(), claimed, "nothing claimed")
	eq(d.pending_sp(), sp, "no extra reward")
	clock.unix += DAY + 3600
	d.refresh(1)
	check(not d.is_locked(), "unlocked when the clock catches up")
	eq(d.status(), "done", "the day stays done")


func test_one_claim_per_day() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	eq(_kick(d, true), 2, "first claim")
	eq(d.claim(), 0, "claim again: nothing")
	eq(d.pending.size(), 1, "one reward queued")
	# Even if today's record were lost (e.g. edited), the day stays claimed.
	d.today = {}
	d.refresh(1)
	eq(d.status(), "ready", "a fresh record for the same day")
	eq(_kick(d, true), 0, "but the day can't pay twice")
	eq(d.pending.size(), 1, "still one reward")
	eq(d.streak, 1, "streak not double counted")


# --- scenarios -------------------------------------------------------------------------------

func test_scenario_is_deterministic_per_day() -> void:
	var t := DailyTuning.new()
	var day := DailyClock.day_number(ManualDateSource.new().at_local(2026, 11, 25), 0)
	eq(DailyScenario.generate(day, 2, t), DailyScenario.generate(day, 2, t), "same day, same scenario")
	var kinds := {}
	var labels := {}
	for i in 60:
		var sc := DailyScenario.generate(day + i, 1, t)
		kinds[sc["kick"]] = true
		labels[sc["label"]] = true
	check(kinds.size() >= 3, "kick types vary over two months (%s)" % [kinds.keys()])
	check(labels.size() >= 6, "situations vary (%d)" % labels.size())
	# Every tier sees the same situation, wind and weather; only distances differ.
	for tier in 4:
		var a := DailyScenario.generate(day, 0, t)
		var b := DailyScenario.generate(day, tier, t)
		for k in ["kick", "situation", "wind_mph", "gust_mph", "weather", "field", "wind_seed", "boss"]:
			eq(b[k], a[k], "tier %d shares %s" % [tier, k])
	# A different tuning instance (another device) gives the same kick.
	var other := DailyTuning.new()
	eq(DailyScenario.generate(day + 3, 3, other), DailyScenario.generate(day + 3, 3, t), "same on every device")


func test_weekly_rhythm_and_boss_day() -> void:
	var t := DailyTuning.new()
	var monday := DailyClock.day_number(ManualDateSource.new().at_local(2026, 11, 23), 0)
	eq(DailyClock.weekday(monday), 0, "Nov 23 2026 is a Monday")
	var mon_avg := 0.0
	var sat_avg := 0.0
	var weeks := 20
	for w in weeks:
		var mon := DailyScenario.generate(monday + w * 7, 2, t)
		var sat := DailyScenario.generate(monday + w * 7 + 5, 2, t)
		check(bool(sat["boss"]) and sat["kick"] == "fg", "Saturday is a boss field goal")
		check(sat["situation"] in ["game_winner", "icing", "overtime"], "boss situation (%s)" % sat["situation"])
		check(not bool(mon["boss"]), "Monday isn't")
		mon_avg += float(mon["difficulty"]) / weeks
		sat_avg += float(sat["difficulty"]) / weeks
		if sat["kick"] == "fg":
			check(int(sat["yards"]) >= int(t.fg_max_yards[2]) - 3, "boss kicks are long for the tier")
	check(sat_avg > mon_avg + 0.5, "Saturday much harder than Monday")


func test_distances_fit_the_tier() -> void:
	var t := DailyTuning.new()
	var day0 := DailyClock.day_number(ManualDateSource.new().at_local(2026, 1, 1), 0)
	for i in 365:
		for tier in 4:
			var sc := DailyScenario.generate(day0 + i, tier, t)
			if sc["kick"] == "fg":
				check(int(sc["yards"]) >= t.fg_min_yards[tier] and int(sc["yards"]) <= t.fg_max_yards[tier],
					"tier %d fg %d yd in range" % [tier, int(sc["yards"])])
			check(float(sc["power_mult"]) >= 0.93 and float(sc["spread_deg"]) <= 0.6 and float(sc["window_mult"]) >= 0.85,
				"weather never makes it unfair (%s)" % [sc])
			check(absf(float(sc["wind_mph"])) <= t.wind_max_mph, "wind capped")
			if tier == 0:
				check(int(sc["yards"]) <= 40, "Rookie never gets a long kick")
				check(float(sc["power_mult"]) >= 0.97, "Rookie weather is gentle")


func test_weather_is_seasonal() -> void:
	var t := DailyTuning.new()
	var july := DailyClock.day_number(ManualDateSource.new().at_local(2026, 7, 1), 0)
	for i in 31:
		var sc := DailyScenario.generate(july + i, 1, t)
		check(sc["weather"] != "snow", "no snow in July")
		if sc["weather"] in ["rain", "snow"]:
			check(sc["field"] in ["wet", "sloppy", "frozen"], "rain leaves the field wet")


func test_success_rules_per_kick_type() -> void:
	check(DailyScenario.success({"goal": "make"}, true, {}), "field goal made")
	check(not DailyScenario.success({"goal": "make"}, false, {}), "missed")
	check(DailyScenario.success({"goal": "deep"}, false, {"result": "touchback"}), "touchback is deep")
	check(not DailyScenario.success({"goal": "deep"}, false, {"result": "returned"}), "returned isn't deep")
	check(DailyScenario.success({"goal": "in_play"}, false, {"result": "returned"}), "in play")
	check(not DailyScenario.success({"goal": "in_play"}, false, {"result": "out_of_bounds"}), "out of bounds fails")
	check(DailyScenario.success({"goal": "hop"}, false, {"result": "lost", "hop": true}), "a good hop counts even if lost")
	var rules := KickoffRules.new()
	var rng := RandomNumberGenerator.new()
	var res := KickoffJudge.onside(Vector3(0, 0, -14.0 * KickoffJudge.YARD), 3.0, rules, rng)
	check(bool(res["hop"]), "a 14-yard straight onside is a good hop")


func test_daily_mode_builds_the_situation() -> void:
	var t := DailyTuning.new()
	var day := DailyClock.day_number(ManualDateSource.new().at_local(2026, 11, 28), 0)
	var sc := DailyScenario.generate(day, 2, t)
	var m := DailyMode.new(sc)
	eq(m.id(), &"daily", "mode id")
	check(not m.wants_next_kick(), "one kick")
	var wind := Wind.new()
	var s := m.next_situation(RandomNumberGenerator.new(), KickTuning.new(), wind)
	eq(s.distance_yards, int(sc["yards"]), "distance")
	eq(s.wind_mph, float(sc["wind_mph"]), "wind")
	check(s.along_preset, "head / tailwind fixed by the day")
	eq(s.pressure, float(sc["pressure"]), "pressure")
	wind.free()


# --- rewards ---------------------------------------------------------------------------------

func test_reward_numbers() -> void:
	var t := DailyTuning.new()
	eq(t.reward_for(1), 2, "day 1")
	eq(t.reward_for(3), 4, "day 3 milestone")
	eq(t.reward_for(7), 7, "day 7 milestone")
	eq(t.reward_for(14), 10, "day 14")
	eq(t.reward_for(21), 7, "every 7th day after the milestones")
	eq(t.reward_for(30), 14, "day 30")
	eq(t.reward_for(60), 14, "every 30th day")
	eq(t.total_for(7), 21, "a perfect week")
	eq(t.total_for(30), 97, "a perfect month")
	for n in range(1, 400):
		check(t.reward_for(n) <= t.max_reward_per_day, "capped on day %d" % n)


func test_track_shows_claimed_today_and_next() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	var tr := d.track()
	eq(tr.size(), 7, "7 days")
	eq(str(tr[0]["state"]), "today", "day 1 is today")
	_kick(d, true)
	_next_day(d, clock)
	_kick(d, true)
	tr = d.track()
	eq(str(tr[1]["state"]), "claimed", "day 2 claimed")
	eq(str(tr[2]["state"]), "next", "day 3 to come")
	eq(int(tr[2]["bonus"]), 2, "day 3 shows its bonus")
	eq(int(d.next_milestone()["n"]), 3, "next milestone day 3")


func test_rewards_reach_the_career_once() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	_kick(d, true)
	_next_day(d, clock)
	_kick(d, true)
	var c := CareerData.from_dict(CareerSave._migrate(fixture("career_v8_pre_daily.json")))
	var sp0 := c.skill_points
	eq(d.deliver_to(c), 4, "two days delivered")
	eq(c.skill_points, sp0 + 4, "added to the Skills balance")
	eq(int(c.sp_sources.get("Daily Challenge", 0)), 4, "own source line")
	# Crash after the career save, before the main save drops them: pending
	# is still there, but the career knows the claims.
	var c2 := CareerData.from_dict(JSON.parse_string(JSON.stringify(c.to_dict())))
	eq(d.deliver_to(c2), 0, "never paid twice")
	eq(c2.skill_points, sp0 + 4, "balance unchanged")
	d.clear_delivered(c2)
	eq(d.pending.size(), 0, "pending cleared")


# --- ads -----------------------------------------------------------------------------------------

func test_ad_retry_once_per_day() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	_kick(d, false)
	eq(d.status(), "missed", "missed")
	check(d.retry_offered(), "retry offered")
	check(d.retry_needs_ad(), "with an ad")
	check(d.grant_retry(), "ad watched: retry granted")
	eq(d.status(), "retry", "retry ready")
	check(not d.grant_retry(), "no second grant before kicking")
	_kick(d, false)
	eq(d.status(), "failed", "second miss: done for the day")
	check(not d.retry_offered(), "no more retries")
	check(not d.grant_retry(), "grant refused")
	check(not d.begin_kick(), "no third kick")
	eq(d.pending.size(), 0, "no reward")
	eq(d.success_rate(), 0, "0% so far")
	_next_day(d, clock)
	eq(d.status(), "ready", "tomorrow is a new day")
	_kick(d, false)
	check(d.retry_offered(), "and a new retry")
	d.grant_retry()
	eq(_kick(d, true), 2, "a made retry pays the full reward")


func test_ads_unavailable() -> void:
	# Offline / no fill: the retry exists but the button is hidden behind a message.
	var stub := StubAdService.new(DailyTuning.new())
	stub.seconds = 0.0
	stub.fill = false
	var d: DailyChallenge = _daily(0, stub)[0]
	_kick(d, false)
	check(d.retry_offered(), "retry still offered (saved for later)")
	check(not d.ads.is_ready(AdService.RETRY), "but no ad is ready")
	check(d.ads.unavailable_text() != "", "with a friendly message")
	# Steam / no-ads platform, rule "none": no retry, no saver.
	var none := _daily(0, NoAdService.new())
	var dn: DailyChallenge = none[0]
	var cn: ManualDateSource = none[1]
	check(not dn.ads.platform_has_ads(), "no ads on this platform")
	_kick(dn, false)
	check(not dn.retry_offered(), "rule none: no retry")
	eq(dn.status(), "missed", "missed, nothing else")
	_next_day(dn, cn)
	_kick(dn, true)
	_next_day(dn, cn, 2)
	check(not dn.saver_offered(), "rule none: no streak saver")
	# Rule "free": the retry and the saver without an ad.
	var free := _daily(0, NoAdService.new())
	var df: DailyChallenge = free[0]
	df.tuning.no_ads_rule = "free"
	_kick(df, false)
	check(df.retry_offered() and not df.retry_needs_ad(), "rule free: retry without an ad")
	check(df.grant_retry(), "granted")


func test_ad_service_selection() -> void:
	var t := DailyTuning.new()
	t.ad_mode = "none"
	check(AdService.create(t) is NoAdService, "none")
	t.ad_mode = "stub"
	check(AdService.create(t) is StubAdService, "stub")
	t.ad_mode = "auto"
	t.no_ads_platform = true
	check(AdService.create(t) is NoAdService, "no-ads platform flag")
	check(not MobileAdService.new().is_ready(AdService.RETRY), "the mobile placeholder reports not ready")


# --- saves ---------------------------------------------------------------------------------------

func test_state_survives_a_save_round_trip() -> void:
	var r := _daily()
	var d: DailyChallenge = r[0]
	var clock: ManualDateSource = r[1]
	_kick(d, true)
	_next_day(d, clock)
	_kick(d, false)
	d.grant_retry()
	var raw: Dictionary = JSON.parse_string(JSON.stringify(d.to_dict()))
	var d2 := DailyChallenge.new(d.tuning, d.clock, d.ads)
	d2.from_dict(raw)
	eq(d2.to_dict(), d.to_dict(), "lossless")
	eq(d2.status(), "retry", "retry survives a restart")
	d2.refresh(1)
	eq(d2.status(), "retry", "still the retry")


func test_old_main_saves_get_daily_defaults() -> void:
	for name in ["main_save_v1.json", "main_save_v2.json"]:
		var d: Dictionary = SaveStore.new()._migrate(fixture(name))
		eq(int(d["version"]), SaveStore.VERSION, "%s upgraded" % name)
		check(d.get("daily") is Dictionary, "%s has a daily section" % name)
		var dc := DailyChallenge.new(DailyTuning.new(), ManualDateSource.new(0, 0), NoAdService.new())
		dc.from_dict(d["daily"])
		eq(dc.streak, 0, "no streak")
		eq(dc.claimed_days.size(), 0, "nothing claimed")
	var v2: Dictionary = SaveStore.new()._migrate(fixture("main_save_v2.json"))
	eq(int(v2["stats"]["makes"]), 12, "v2 stats kept")
	eq(int(v2["career"]["last_slot"]), 1, "v2 career slot kept")


func test_career_v8_upgrades_to_v9() -> void:
	var raw := fixture("career_v8_pre_daily.json")
	var d := CareerSave._migrate(raw.duplicate(true))
	eq(int(d["career_version"]), CareerData.VERSION, "current version")
	var c := CareerData.from_dict(d)
	eq(c.daily_claims.size(), 0, "no daily claims yet")
	eq(c.skill_points, 9, "skill points kept")
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(again.to_dict(), c.to_dict(), "round trip")


# --- kept apart from every stat --------------------------------------------------------------------

func test_daily_kicks_never_touch_stats_or_records() -> void:
	var gs: Node = (Engine.get_main_loop() as SceneTree).root.get_node("GameState")
	var stats_before: Dictionary = gs.stats.to_dict()
	var ach_before: Dictionary = gs.achievements.to_dict()
	var session := [gs.attempts, gs.makes, gs.streak]
	var s := KickSituation.new()
	s.distance_yards = 61
	s.pressure = 1.0
	s.wind_mph = 18.0
	for made in [true, false, true]:
		gs.report_kick(KickReport.create(KickResult.Outcome.GOOD if made else KickResult.Outcome.WIDE_LEFT,
			s, 18.0, DailyChallenge.MODE))
	eq(gs.stats.to_dict(), stats_before, "My Stats / records unchanged")
	eq(gs.achievements.to_dict(), ach_before, "no achievements")
	eq([gs.attempts, gs.makes, gs.streak], session, "session streak unchanged")
	check(DailyChallenge.MODE in gs.UNRECORDED_MODES, "daily is an unrecorded mode")
	# Career data only changes through delivered skill points.
	var c := CareerData.from_dict(CareerSave._migrate(fixture("career_v8_pre_daily.json")))
	var before := c.to_dict()
	var r := _daily()
	var d: DailyChallenge = r[0]
	_kick(d, true)
	d.deliver_to(c)
	var after := c.to_dict()
	for k in ["career_totals", "season_stats", "kick_log", "recent_fg", "fg_history", "history", "record"]:
		if before.has(k):
			eq(after[k], before[k], "%s untouched" % k)


func test_screens_compile() -> void:
	for p in ["res://scripts/ui/screens/daily_screen.gd", "res://scripts/ui/screens/daily_kick_screen.gd",
			"res://scripts/ui/daily_ui.gd", "res://scripts/ui/screens/main_menu.gd",
			"res://scripts/ui/screens/career_hub.gd"]:
		var s: Variant = load(p)
		check(s is GDScript and (s as GDScript).can_instantiate(), "%s compiles" % p)
	check(ResourceLoader.exists(Screens.DAILY) and ResourceLoader.exists(Screens.DAILY_KICK), "scenes exist")
	check(load("res://tuning/daily_tuning.tres") is DailyTuning, "tuning file loads")
