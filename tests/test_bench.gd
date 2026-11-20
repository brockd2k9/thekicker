extends "res://tests/test_case.gd"
## Benching: the thin-ice warning, the trigger, the backup taking field goals,
## no game skill points while benched, the audition, effects, and save v5.

var t := CareerTuning.get_default()


func _career(stage := CareerData.STAGE_HIGH_SCHOOL) -> CareerManager:
	var c := CareerData.create("Bench Test", t)
	c.created = 1794983149
	c.slot = 0
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c, t)
	m.rng.seed = 7
	m._start_season(false)
	if stage != CareerData.STAGE_HIGH_SCHOOL:
		c.stage = stage
		var col: Dictionary = CareerContent.colleges()[0]
		c.team = Progression.team_from(col, stage)
		Relationships.enter_stage(c, t)
	return m


## Low trust and coach doubt: on thin ice.
func _shaky(c: CareerData, coach := 27.0, team := 30.0) -> void:
	c.coach_doubt = {"weeks_left": 3, "reason": "6 of your last 10 field goals missed"}
	Relationships.apply(c, {"coach": coach - Relationships.value(c, "coach"),
		Relationships.TEAM: team - Relationships.value(c, Relationships.TEAM)})


## A bad week: enough missed field goals to be benched (bench_week_misses).
func _miss() -> Array:
	var out: Array = [{"kind": "pat", "made": true, "yards": 20}]
	for i in t.bench_week_misses:
		out.append({"kind": "fg", "made": false, "yards": 35})
	return out


func test_thin_ice_needs_doubt_and_low_trust() -> void:
	var c := _career().data
	check(not Bench.on_thin_ice(c, t), "a fresh career is not on thin ice")
	_shaky(c, 70.0, 70.0)
	check(not Bench.on_thin_ice(c, t), "doubt but high trust: fine")
	_shaky(c)
	check(Bench.on_thin_ice(c, t), "doubt and low trust: thin ice")
	c.coach_doubt = {}
	check(not Bench.on_thin_ice(c, t), "low trust alone is not enough")
	c.stretch_cooldown = 3
	check(Bench.on_thin_ice(c, t), "a fresh bad stretch counts like doubt")


func test_never_benched_without_the_warning() -> void:
	var m := _career()
	var c := m.data
	c.week = 5
	_shaky(c)
	check(not Bench.check_after_game(c, t, _miss()), "no warning this week: no bench")
	Bench.begin_week(c, t, false)
	check(Bench.warned_this_week(c), "warning noted at the start of the week")
	check(not Bench.check_after_game(c, t, [{"kind": "fg", "made": true, "yards": 30}]), "no miss: no bench")
	if t.bench_week_misses > 1:
		check(not Bench.check_after_game(c, t, [{"kind": "fg", "made": false, "yards": 30},
			{"kind": "fg", "made": true, "yards": 30}]), "one miss is not a bad enough week")
	check(Bench.check_after_game(c, t, _miss()), "warned, missed, low trust: benched")
	check(Bench.benched(c), "benched")
	eq(int(c.bench["weeks_left"]), 1, "one week above bench_long_trust")
	check(c.flags.get("benched", false), "story flag")
	check(c.notice.begins_with("BENCHED"), "Hub notice")


func test_bench_rules() -> void:
	var m := _career()
	var c := m.data
	_shaky(c)
	c.week = 2
	Bench.begin_week(c, t, false)
	check(not Bench.check_after_game(c, t, _miss()), "not in the first weeks")
	c.week = 6
	_shaky(c, t.bench_trust + 2.0, t.bench_trust + 3.0)  # between the bench line and the warning
	Bench.begin_week(c, t, false)
	check(Bench.warned_this_week(c), "warned")
	check(not Bench.check_after_game(c, t, _miss()), "trust above the bench line: warned, not benched")
	_shaky(c, 15.0, 20.0)
	Bench.begin_week(c, t, false)
	check(Bench.check_after_game(c, t, _miss()), "benched")
	eq(int(c.bench["weeks_left"]), 2, "trust 25 or lower: two weeks")
	c.bench["weeks_left"] = 0
	Bench.begin_week(c, t, false)
	check(not Bench.on_thin_ice(c, t), "one bench a season: no second warning")
	check(not Bench.check_after_game(c, t, _miss()), "one bench a season")


func test_backup_is_tyler_in_high_school_or_the_backup_kicker() -> void:
	var m := _career()
	var c := m.data
	eq(Bench.backup_id(c), Relationships.TYLER, "high school: Tyler is your teammate")
	var mc := _career(CareerData.STAGE_COLLEGE)
	var cc := mc.data
	cc.people[Relationships.TYLER]["team"] = {"id": "somewhere_else", "stage": "college"}
	eq(Bench.backup_id(cc), Bench.BACKUP, "college, Tyler elsewhere: the backup kicker")
	check(not Relationships.known(cc, Bench.BACKUP), "backup hidden until needed")
	cc.week = 5
	_shaky(cc)
	Bench.begin_week(cc, t, false)
	Bench.check_after_game(cc, t, _miss())
	check(Relationships.known(cc, Bench.BACKUP), "met when benched")
	check(Bench.backup_name(cc) != "", "has a name")
	cc.people[Relationships.TYLER]["team"] = {"id": str(cc.team["id"]), "stage": "college"}
	cc.bench.erase("backup")
	eq(Bench.backup_id(cc), Relationships.TYLER, "same college as Tyler: Tyler")


func test_backup_kicks_the_field_goals() -> void:
	var m := _career()
	var c := m.data
	c.bench = {"weeks_left": 1, "this_week": true, "backup": Relationships.TYLER}
	var sim := m.new_game_sim(KickRange.kick_tuning())
	check(sim.backup_fg, "sim in backup mode")
	var fg_calls := 0
	var guard := 0
	while guard < 2000:
		guard += 1
		var e := sim.next()
		match str(e.get("type", "")):
			"end":
				break
			"warmup":
				fg_calls += 100  # no warmups while benched
				sim.set_warmup("loose")
			"call":
				if str(e["kind"]) == "fg":
					fg_calls += 1
				sim.resolve_call({"made": true, "quality": 0.5, "recovered": false})
	eq(fg_calls, 0, "no field goal calls or warmups for you")
	var fgs := sim.kicks.filter(func(k: Dictionary) -> bool: return k["kind"] == "fg")
	check(fgs.all(func(k: Dictionary) -> bool: return k.get("backup", false)), "every field goal is the backup's")
	check(sim.kicks.filter(func(k: Dictionary) -> bool: return k["kind"] == "pat").all(
		func(k: Dictionary) -> bool: return not k.get("backup", false)), "extra points are still yours")


func test_benched_week_no_game_skill_points_and_no_stats() -> void:
	var m := _career()
	var c := m.data
	c.bench = {"weeks_left": 1, "this_week": true, "backup": Relationships.TYLER}
	c.phase = CareerManager.PHASE_GAME
	var before_fg := int(c.season_stats["fg_att"])
	SkillPoints.tally = {}
	m.finish_game({"outcome": "W", "us": 10, "them": 3, "kicks": [
		{"kind": "fg", "made": true, "yards": 40, "backup": true},
		{"kind": "pat", "made": true, "yards": 20}], "warmups": []})
	var tally: Dictionary = SkillPoints.tally
	SkillPoints.tally = null
	check(not tally.has("Field goals made") and not tally.has("Perfect game"), "no game skill points")
	check(tally.has("Practice"), "practice still counts")
	eq(int(c.season_stats["fg_att"]), before_fg, "the backup's kicks aren't yours")
	eq(int(c.last_week["bench"]["made"]), 1, "Results: the backup's line")


func test_countdown_and_audition() -> void:
	var m := _career()
	var c := m.data
	c.week = 5
	_shaky(c)
	Bench.begin_week(c, t, false)
	Bench.check_after_game(c, t, _miss())
	var rec := c.recruiting_score
	Bench.begin_week(c, t, false)
	check(Bench.this_week(c), "next game is a benched one")
	Bench.end_week(c, t)
	eq(c.recruiting_score, maxf(rec + t.bench_progress_per_week, 0.0), "progress costs a little")
	check(Bench.audition_due(c), "audition due")
	# The audition through the manager: a tryout, then back to the week.
	c.phase = CareerManager.PHASE_WEEK_START
	m.begin_week()
	eq(c.phase, CareerManager.PHASE_TRYOUT, "audition first")
	eq(str(c.tryout["purpose"]), "job", "job audition")
	var coach := Relationships.value(c, "coach")
	m.finish_tryout(t.audition_need)
	eq(c.phase, CareerManager.PHASE_WEEK_START, "back to the week")
	check(not Bench.benched(c) and not Bench.audition_due(c), "job back")
	eq(Relationships.value(c, "coach") - coach, t.audition_coach, "a little coach trust")
	check(c.coach_doubt.is_empty(), "doubt cleared")
	check(c.flags.get("won_job_back", false), "story flag")


func test_failed_auditions() -> void:
	var c := _career().data
	c.bench = {"weeks_left": 0, "audition_due": true, "auditions_failed": 0}
	eq(Bench.finish_audition(c, t, 1), "extended", "first fail: one more week")
	check(Bench.benched(c) and int(c.bench["weeks_left"]) == 1, "one more week")
	c.bench["weeks_left"] = 0
	c.bench["audition_due"] = true
	eq(Bench.finish_audition(c, t, 0), "reinstated", "second fail: reinstated")
	check(not Bench.benched(c) and not Bench.audition_due(c), "job back anyway")


func test_audition_distances() -> void:
	var c := _career().data
	eq(Bench.audition_distances(c, t, 50.0), [30, 33, 35, 37, 40], "high school 30-40")
	eq(Bench.audition_distances(c, t, 38.0), [30, 33, 35, 37, 37], "clamped to range - 1")
	var cc := _career(CareerData.STAGE_COLLEGE).data
	eq(Bench.audition_distances(cc, t, 60.0), [35, 38, 40, 42, 45], "college 35-45")
	eq(Bench.audition_distances(cc, t, 43.0), [35, 38, 40, 42, 42], "clamped")


func test_new_season_gives_the_job_back() -> void:
	var m := _career()
	var c := m.data
	c.bench = {"weeks_left": 2, "audition_due": false, "this_week": true}
	m._start_season(true)
	check(not Bench.benched(c) and not Bench.this_week(c), "fresh season")


func test_v5_round_trip_and_migration() -> void:
	var c := _career().data
	c.bench = {"weeks_left": 1, "weeks": 2, "backup": "rival", "audition_due": false, "benches": 1, "season": 1}
	var back := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(int(back.bench["weeks_left"]), 1, "bench kept")
	eq(str(back.bench["backup"]), "rival", "backup kept")
	var raw := fixture("career_v4_college.json")
	var mig := CareerData.from_dict(CareerSave._migrate(raw.duplicate(true)))
	eq(mig.to_dict()["career_version"], CareerData.VERSION, "v4 -> v%d" % CareerData.VERSION)
	check(mig.bench.is_empty(), "never benched")


func test_frozen_v5_save_loads_unchanged() -> void:
	var raw := fixture("career_v5_benched.json")
	var c := CareerData.from_dict(CareerSave._migrate(raw.duplicate(true)))
	check(Bench.benched(c), "still benched")
	eq(str(c.bench["backup"]), Bench.BACKUP, "backup kept")
	check(Relationships.known(c, Bench.BACKUP), "backup known")
	eq(JSON.stringify(c.to_dict()["people"]), JSON.stringify(raw["people"]), "people kept exactly")
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(JSON.stringify(again.to_dict()), JSON.stringify(c.to_dict()), "v5 round trip")


func test_one_miss_is_enough_in_a_bad_season() -> void:
	var m := _career()
	var c := m.data
	eq(Bench.misses_needed(c, t), t.bench_week_misses, "normally a bad week needs more misses")
	var att := t.bench_poor_season_min_att
	c.season_stats["fg_att"] = att
	c.season_stats["fg_made"] = floori(att * t.bench_poor_season_pct) - 1
	eq(Bench.misses_needed(c, t), 1, "a bad season: one miss")
	c.week = 6
	_shaky(c)
	Bench.begin_week(c, t, false)
	check(Bench.check_after_game(c, t, [{"kind": "fg", "made": false, "yards": 35}]), "benched on one miss")
