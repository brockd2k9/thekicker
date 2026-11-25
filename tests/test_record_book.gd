extends "res://tests/test_case.gd"
## All-time records (RecordBook, data/records/record_book.json): list sizes,
## order, the FG% minimum, internal consistency, team <= division <=
## conference <= league nesting, determinism, real-life scale, and your
## kicker breaking, tying and entering records.

const R := preload("res://scripts/records/record_book.gd")


func _levels_scopes() -> Array:
	var out: Array = []
	for lv in R.LEVELS:
		for kind in R.KINDS[lv]:
			if kind == "team":
				continue
			for sc in R.scopes(lv, kind):
				out.append([lv, sc["key"]])
	return out


# --- the fictional book ---------------------------------------------------------------------

func test_names_unique_across_levels() -> void:
	var seen := {}
	var n := 0
	for lv in R.LEVELS:
		for name in R.all_names(lv):
			check(not seen.has(name), "%s appears twice (%s, %s)" % [name, seen.get(name, ""), lv])
			seen[name] = lv
			n += 1
	check(n > 10000, "a big book (%d names)" % n)


func test_list_sizes() -> void:
	for ls in _levels_scopes():
		for span in R.SPANS:
			for cat in R.CATS:
				var list := R.ranked(ls[0], ls[1], span, cat)
				check(list.size() <= R.list_size(span, cat), "%s %s %s %s too long" % [ls[0], ls[1], span, cat])
	eq(R.list_size(R.CAREER, "fg_made"), 50, "career FGs made: top 50")
	eq(R.list_size(R.SEASON, "fg_made"), 25, "season FGs made: top 25")
	eq(R.list_size(R.CAREER, "points"), 25, "everything else: top 25")
	# The big books are full.
	for lv_key in [[R.LEVEL_PRO, "level"], [R.LEVEL_COLLEGE, "division:FBS"], [R.LEVEL_HS, "level"]]:
		for span in R.SPANS:
			for cat in ["fg_pct", "fg_att", "fg_made", "xp_made", "points", "made_20", "made_30", "made_40", "long"]:
				if lv_key[0] == R.LEVEL_HS and span == R.CAREER and cat == "fg_pct":
					continue  # few high school kickers reach 50 career attempts (checked below)
				eq(R.ranked(lv_key[0], lv_key[1], span, cat).size(), R.list_size(span, cat),
					"%s %s %s %s full" % [lv_key[0], lv_key[1], span, cat])
	var hs_pct := R.ranked(R.LEVEL_HS, "level", R.CAREER, "fg_pct").size()
	check(hs_pct >= 1 and hs_pct < 25, "high school career FG%%: a short list (%d)" % hs_pct)


func test_sorted_ranked_and_minimum_attempts() -> void:
	for ls in _levels_scopes():
		for span in R.SPANS:
			for cat in R.CATS:
				var list := R.ranked(ls[0], ls[1], span, cat)
				for i in list.size():
					var e: Dictionary = list[i]
					if i > 0:
						check(float(e["value"]) <= float(list[i - 1]["value"]) + 0.000001,
							"%s %s %s %s sorted at %d" % [ls[0], ls[1], span, cat, i + 1])
						var tie := is_equal_approx(float(e["value"]), float(list[i - 1]["value"]))
						eq(int(e["rank"]), int(list[i - 1]["rank"]) if tie else i + 1, "%s %s rank" % [ls[1], cat])
					if cat == "fg_pct":
						check(int(e["att"]) >= R.min_att(ls[0], span), "%s %s %s: %s has %d attempts" % [
							ls[0], ls[1], span, e["name"], e["att"]])
					else:
						check(float(e["value"]) > 0.0, "%s %s %s: no zero entries" % [ls[1], span, cat])


func test_entries_are_consistent() -> void:
	for ls in _levels_scopes():
		for span in R.SPANS:
			for cat in R.CATS:
				for e in R.ranked(ls[0], ls[1], span, cat):
					var made := int(e["made"])
					var b: Array = e["b"]
					eq(int(b[0]) + int(b[1]) + int(b[2]) + int(b[3]) + int(b[4]), made, "%s buckets add up" % e["name"])
					eq(R.value(e, "points"), float(3 * made + int(e["xp"])), "%s points" % e["name"])
					check(made <= int(e["att"]), "%s made <= attempts" % e["name"])
					if cat == "fg_pct":
						eq(float(e["value"]), float(made) / float(e["att"]), "%s FG%%" % e["name"])
					if made > 0:
						var top := 4
						while int(b[top]) == 0:
							top -= 1
						eq(CareerRecords.bucket_of(int(e["long"])), top, "%s longest %d fits the buckets" % [e["name"], e["long"]])
					if span == R.SEASON:
						eq(int(e["seasons"]), 1, "one season")
						check(not ("-" in str(e["years"])), "a season is one year")
					check(int(e["first_year"]) <= R.last_year(), "years in the past")


## A team's best can't beat its conference, division or league best.
func test_nesting() -> void:
	for lv in R.LEVELS:
		for t in R.record_teams(lv):
			var keys := R.scopes_of_team(lv, str(t["id"]))
			for span in R.SPANS:
				for cat in R.CATS:
					var prev := INF
					var prev_key := ""
					for key in keys:  # widest first
						var list := R.ranked(lv, key, span, cat)
						if list.is_empty():
							prev = 0.0
							continue
						var v := float(list[0]["value"])
						check(v <= prev + 0.000001, "%s %s %s: %s (%s) beats %s (%s)" % [
							lv, span, cat, key, v, prev_key, prev])
						prev = v
						prev_key = key


func test_deterministic() -> void:
	var key: String = R.scopes(R.LEVEL_COLLEGE, "conference")[0]["key"]
	var a := JSON.stringify(R.ranked(R.LEVEL_COLLEGE, key, R.CAREER, "points"))
	R.clear_cache()
	var b := JSON.stringify(R.ranked(R.LEVEL_COLLEGE, key, R.CAREER, "points"))
	eq(a, b, "same lists after a reload")


func test_real_life_scale() -> void:
	var top := func(lv: String, key: String, span: String, cat: String) -> float:
		return float(R.ranked(lv, key, span, cat)[0]["value"])
	var pro_career := float(top.call(R.LEVEL_PRO, "level", R.CAREER, "fg_made"))
	check(pro_career >= 350 and pro_career <= 650, "pro career FGs made leader in the hundreds (%d)" % pro_career)
	var pro50 := float(R.ranked(R.LEVEL_PRO, "level", R.CAREER, "fg_made")[49]["value"])
	check(pro50 >= 150, "pro career #50 still in the hundreds (%d)" % pro50)
	var pro_long := float(top.call(R.LEVEL_PRO, "level", R.SEASON, "long"))
	check(pro_long >= 62 and pro_long <= 67, "pro longest in the mid-60s (%d)" % pro_long)
	var pro_season := float(top.call(R.LEVEL_PRO, "level", R.SEASON, "fg_made"))
	check(pro_season >= 38 and pro_season <= 50, "pro season FGs made record (%d)" % pro_season)
	var fbs_long := float(top.call(R.LEVEL_COLLEGE, "division:FBS", R.SEASON, "long"))
	check(fbs_long >= 65 and fbs_long <= 70, "college record kick in the high 60s (%d)" % fbs_long)
	var fbs_career := float(top.call(R.LEVEL_COLLEGE, "division:FBS", R.CAREER, "fg_made"))
	check(fbs_career >= 60 and fbs_career <= 100, "college career FGs made (%d)" % fbs_career)
	var hs_season := float(top.call(R.LEVEL_HS, "level", R.SEASON, "fg_made"))
	check(hs_season >= 10 and hs_season <= 25, "high school season FGs made (%d)" % hs_season)
	var hs_long := float(top.call(R.LEVEL_HS, "level", R.SEASON, "long"))
	check(hs_long >= 50 and hs_long <= 62, "high school longest (%d)" % hs_long)
	check(float(top.call(R.LEVEL_PRO, "level", R.SEASON, "fg_pct")) <= 1.0, "FG% at most 100%")


## Strong, old programs hold more records and have deeper books.
func test_strong_programs_hold_more() -> void:
	var fbs := R.record_teams(R.LEVEL_COLLEGE).filter(func(t: Dictionary) -> bool: return t["division"] == "FBS")
	fbs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["strength"]) > float(b["strength"]))
	var third := fbs.size() / 3
	var strong := {}
	var weak := {}
	for i in third:
		strong[str(fbs[i]["id"])] = true
		weak[str(fbs[fbs.size() - 1 - i]["id"])] = true
	var held := [0, 0]
	for cat in ["fg_made", "points", "xp_made", "fg_pct"]:
		for e in R.ranked(R.LEVEL_COLLEGE, "division:FBS", R.SEASON, cat):
			if strong.has(str(e["teams"][0])):
				held[0] += 1
			elif weak.has(str(e["teams"][0])):
				held[1] += 1
	check(held[0] > held[1], "strong FBS programs hold more division records (%d vs %d)" % held)
	var depth := [0, 0]
	for id in strong:
		depth[0] += R.team_players(R.LEVEL_COLLEGE, id).size()
	for id in weak:
		depth[1] += R.team_players(R.LEVEL_COLLEGE, id).size()
	check(depth[0] > depth[1], "older, bigger programs have deeper books (%d vs %d kickers)" % depth)


func test_scope_names_come_from_the_team_database() -> void:
	eq(R.level_name(R.LEVEL_PRO), str(TeamDatabase.level_info("pro")["league"]), "pro league")
	eq(R.level_name(R.LEVEL_HS), str(TeamDatabase.start_team()["region"]), "high school region")
	var afc := R.scopes(R.LEVEL_PRO, "division")
	eq(afc.size(), 2, "AFC / NFC")
	eq(str(afc[0]["name"]), str(TeamDatabase.division_info("pro", "AFC")["name"]), "conference name")
	eq(R.scopes(R.LEVEL_PRO, "conference").size(), 8, "8 pro divisions")
	eq(R.scopes(R.LEVEL_COLLEGE, "division").size(), 3, "FBS / FCS / D2 (no junior college)")
	eq(R.scopes(R.LEVEL_HS, "conference").size(), 1, "the high school division")
	eq(R.scopes_of_team(R.LEVEL_PRO, "buffalo_bisons"), ["level", "division:AFC", "conference:AFC/AFC East", "team:buffalo_bisons"], "Buffalo")
	eq(R.scope_name(R.LEVEL_PRO, "conference:AFC/AFC East"), "AFC East", "division name")
	# A conference name used in two college divisions is two scopes.
	var msc := R.scopes(R.LEVEL_COLLEGE, "conference").filter(func(s: Dictionary) -> bool:
		return s["name"] == "Mountain States Conference")
	eq(msc.size(), 2, "Mountain States Conference in FBS and D2")
	eq(R.scopes_of_team(R.LEVEL_COLLEGE, str(TeamDatabase.jucos()[0]["id"])), [], "junior colleges have no books")


# --- your kicker ----------------------------------------------------------------------------

## A career at `team` with one finished season of `att` / `made` FGs (all from
## 30-39, plus one of `long` yards) and `xp` extra points, logged kick by kick.
func _career(level_stage: String, team: String, att: int, made: int, xp: int, long_yd := 35) -> CareerData:
	var c := CareerData.create("Record Setter", CareerTuning.get_default())
	c.slot = 0
	c.stage = level_stage
	c.season = 1
	c.team = Progression.team_from(TeamDatabase.team(team), level_stage)
	c.kick_log = []
	for i in att:
		var yd := long_yd if i == 0 else 35
		c.kick_log.append({"season": 1, "stage": level_stage, "kind": "fg", "yd": yd, "made": 1 if i < made else 0})
	for i in xp:
		c.kick_log.append({"season": 1, "stage": level_stage, "kind": "pat", "made": 1})
	var st := CareerData.empty_kick_totals()
	st["fg_att"] = att
	st["fg_made"] = made
	st["pat_att"] = xp
	st["pat_made"] = xp
	st["long"] = long_yd if made > 0 else 0
	st["games"] = 17
	c.season_stats = st
	c.history = [{"stage": level_stage, "season": 1, "season_in_stage": 1, "team": c.team["name"],
		"team_id": team, "stats": st.duplicate(), "record": {"w": 9, "l": 8, "t": 0}}]
	c.records = {}
	return c


func test_breaking_a_record_inserts_you_and_drops_the_last() -> void:
	var key := "team:buffalo_bisons"
	var before := R.ranked(R.LEVEL_PRO, key, R.SEASON, "fg_made")
	var record := int(before[0]["value"])
	var last: Dictionary = before[before.size() - 1]
	var c := _career(CareerData.STAGE_PRO, "buffalo_bisons", record + 3, record + 1, 40, 52)
	var after := R.ranked(R.LEVEL_PRO, key, R.SEASON, "fg_made", c)
	eq(after.size(), before.size(), "the list keeps its size")
	check(after[0]["mine"], "you're #1")
	eq(str(after[0]["name"]), "Record Setter", "with your real name")
	eq(int(after[0]["rank"]), 1, "rank 1")
	if before.size() == R.list_size(R.SEASON, "fg_made"):
		var still := after.filter(func(e: Dictionary) -> bool:
			return e["name"] == last["name"] and e["years"] == last["years"])
		check(still.is_empty(), "the old #%d dropped off" % before.size())
	var events := R.check(c, true)
	var recs := events.filter(func(e: Dictionary) -> bool:
		return e["kind"] == "record" and e["scope"] == key and e["cat"] == "fg_made" and e["span"] == R.SEASON)
	eq(recs.size(), 1, "one NEW RECORD event")
	if not recs.is_empty():
		eq(str(recs[0]["headline"]), "NEW RECORD", "headline")
		eq(int(recs[0]["value"]), record + 1, "value")
	check(("pro|%s|season|fg_made" % key) in R.held(c), "you hold it")
	check(not (c.records["log"] as Array).is_empty(), "logged in the save")
	eq(R.check(c, true).size(), 0, "nothing new the second time")
	var st := R.standing(R.LEVEL_PRO, key, R.SEASON, "fg_made", c)
	eq(int(st["rank"]), 1, "standing: #1")
	eq(str(st["text"]), "You hold the record.", "standing text")


func test_tying_and_entering() -> void:
	var key := "team:buffalo_bisons"
	var list := R.ranked(R.LEVEL_PRO, key, R.SEASON, "fg_made")
	var record := int(list[0]["value"])
	var c := _career(CareerData.STAGE_PRO, "buffalo_bisons", record + 5, record, 10)
	var ties := R.check(c, true).filter(func(e: Dictionary) -> bool:
		return e["scope"] == key and e["cat"] == "fg_made" and e["span"] == R.SEASON)
	eq(ties.size(), 1, "one event")
	if not ties.is_empty():
		eq(str(ties[0]["kind"]), "tie", "a tie")
		eq(str(ties[0]["headline"]), "RECORD TIED", "headline")
	# Entering the list without the record.
	var tenth := int(list[9]["value"])
	var c2 := _career(CareerData.STAGE_PRO, "buffalo_bisons", tenth + 4, tenth, 10)
	var ent := R.check(c2, true).filter(func(e: Dictionary) -> bool:
		return e["scope"] == key and e["cat"] == "fg_made" and e["span"] == R.SEASON)
	eq(ent.size(), 1, "one event")
	if not ent.is_empty():
		eq(str(ent[0]["kind"]), "entered", "entered")
		eq(str(ent[0]["headline"]), "Entered top 25", "headline")
		check(int(ent[0]["rank"]) <= 11, "near #10")
	# Mid-season checks never announce "entered" (only records and ties).
	var c3 := _career(CareerData.STAGE_PRO, "buffalo_bisons", tenth + 4, tenth, 10)
	check(R.check(c3, false).filter(func(e: Dictionary) -> bool: return e["kind"] == "entered").is_empty(),
		"no 'entered' mid-season")


func test_distance_lists_need_the_kick_log() -> void:
	var c := _career(CareerData.STAGE_HIGH_SCHOOL, "hoboken_hs", 30, 25, 40, 58)
	var mine := R.my_entries(c, R.LEVEL_HS, "team:hoboken_hs", R.SEASON)
	eq(mine.size(), 1, "one season")
	eq((mine[0]["b"] as Array), [0, 24, 0, 1, 0], "distances from the kick log (35 yd x 24, 58 yd)")
	c.kick_log = []
	mine = R.my_entries(c, R.LEVEL_HS, "team:hoboken_hs", R.SEASON)
	eq((mine[0]["b"] as Array), [], "unknown without the log")
	check(R.ranked(R.LEVEL_HS, "team:hoboken_hs", R.SEASON, "made_30", c).filter(func(e: Dictionary) -> bool:
		return e["mine"]).is_empty(), "not on distance lists")
	check(not R.ranked(R.LEVEL_HS, "team:hoboken_hs", R.SEASON, "fg_made", c).filter(func(e: Dictionary) -> bool:
		return e["mine"]).is_empty(), "still on the others")


func test_fg_pct_minimum_for_you() -> void:
	var c := _career(CareerData.STAGE_PRO, "buffalo_bisons", 10, 10, 0)
	check(R.ranked(R.LEVEL_PRO, "team:buffalo_bisons", R.SEASON, "fg_pct", c).filter(func(e: Dictionary) -> bool:
		return e["mine"]).is_empty(), "10/10 isn't enough attempts for a pro season")
	var st := R.standing(R.LEVEL_PRO, "team:buffalo_bisons", R.SEASON, "fg_pct", c)
	eq(str(st["text"]), "Needs 17 field goal attempts to qualify.", "standing says why")


func test_standing_gaps() -> void:
	var key := "team:hoboken_hs"
	var list := R.ranked(R.LEVEL_HS, key, R.CAREER, "fg_made")
	var record := int(list[0]["value"])
	var c := _career(CareerData.STAGE_HIGH_SCHOOL, "hoboken_hs", 10, 3, 5)
	var st := R.standing(R.LEVEL_HS, key, R.CAREER, "fg_made", c)
	eq(int(st["record_gap"]), record - 3, "gap to #1")
	check(str(st["text"]).ends_with("%d more FGs to break the record" % (record - 2)), "text: %s" % st["text"])
	var rank := int(st["rank"])
	if rank == 0:
		check(str(st["text"]).contains("to make the list"), "off the list: %s" % st["text"])
	elif rank > 2:
		check(str(st["text"]).contains("for #%d" % (rank - 1)), "next rank: %s" % st["text"])


func test_my_years_follow_the_career_start() -> void:
	var c := _career(CareerData.STAGE_PRO, "buffalo_bisons", 10, 8, 5)
	c.created = int(Time.get_unix_time_from_datetime_dict({"year": 2026, "month": 3, "day": 1, "hour": 12, "minute": 0, "second": 0}))
	eq(R.year_of(c, 1), 2026, "first season")
	eq(R.year_of(c, 9), 2034, "ninth season")
	eq(str(R.my_entries(c, R.LEVEL_PRO, "level", R.SEASON)[0]["years"]), "2026", "shown on the list")


func test_save_keeps_records_and_team_ids() -> void:
	var c := _career(CareerData.STAGE_PRO, "buffalo_bisons", 60, 59, 40, 60)
	R.check(c, true)
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(JSON.stringify(again.records), JSON.stringify(c.records), "records saved")
	var old := c.to_dict()
	old["career_version"] = 11
	old.erase("records")
	for h in old["history"]:
		h.erase("team_id")
	var m := CareerData.from_dict(CareerSave._migrate(old))
	eq(str(m.history[0]["team_id"]), "buffalo_bisons", "v12 finds the team id by name")
	eq(m.records, {}, "old saves start with no records")


func test_manager_fires_the_signal() -> void:
	var c := _career(CareerData.STAGE_PRO, "buffalo_bisons", 60, 59, 40, 60)
	c.history = []
	var m := CareerManager.new(c)
	var got: Array = []
	m.records_set.connect(func(ev: Array) -> void: got.append_array(ev))
	m._records(false)
	check(not got.is_empty(), "records_set fired")
	check(got.filter(func(e: Dictionary) -> bool: return e["kind"] == "entered").is_empty(), "mid-season: records only")
	check(not (c.records.get("pending", []) as Array).is_empty(), "kept for the UI")
