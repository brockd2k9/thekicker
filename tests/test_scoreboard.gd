extends "res://tests/test_case.gd"
## The score bug's logic (ScoreBugState): clock and quarter text, the stats
## strip, team abbreviations, signals only on real changes, and GameSim's
## possession on its events.


func test_clock_label() -> void:
	eq(ScoreBugState.clock_label(836.0), "13:56", "13:56")
	eq(ScoreBugState.clock_label(900.0), "15:00", "full quarter")
	eq(ScoreBugState.clock_label(9.0), "0:09", "seconds pad to two digits")
	eq(ScoreBugState.clock_label(59.9), "0:59", "rounds down like GameSim.clock_text")
	eq(ScoreBugState.clock_label(0.0), "0:00", "zero")
	eq(ScoreBugState.clock_label(-5.0), "0:00", "never negative")


func test_quarter_label() -> void:
	eq(ScoreBugState.quarter_label(1), "1ST", "1st")
	eq(ScoreBugState.quarter_label(2), "2ND", "2nd")
	eq(ScoreBugState.quarter_label(3), "3RD", "3rd")
	eq(ScoreBugState.quarter_label(4), "4TH", "4th")
	eq(ScoreBugState.quarter_label(5), "OT", "overtime")
	eq(ScoreBugState.quarter_label(6), "2OT", "second overtime")
	eq(ScoreBugState.quarter_label(0), "1ST", "before kickoff")


func test_time_from_game_seconds() -> void:
	var q := 720.0  # 12-minute quarters
	eq(ScoreBugState.time_from(0.0, q), [1, 720.0], "kickoff")
	eq(ScoreBugState.time_from(719.0, q), [1, 1.0], "end of the 1st")
	eq(ScoreBugState.time_from(720.0, q), [2, 720.0], "start of the 2nd")
	eq(ScoreBugState.time_from(2000.0, q), [3, 160.0], "mid 3rd")
	eq(ScoreBugState.time_from(4000.0, q), [4, 0.0], "past the end holds the 4th at 0:00")


func test_header_text_and_final() -> void:
	var s := ScoreBugState.new()
	s.set_time(64.0, 900.0)
	eq(s.header_text(), "1ST 13:56", "header")
	s.set_final()
	eq(s.header_text(), "FINAL", "final")


func test_stats_strip_values() -> void:
	var kicks := [
		{"kind": "fg", "yards": 44, "made": true},
		{"kind": "fg", "yards": 51, "made": false},
		{"kind": "pat", "yards": 20, "made": true},
		{"kind": "pat", "yards": 20, "made": true},
		{"kind": "kickoff", "quality": 1.0},
		{"kind": "fg", "yards": 55, "made": true, "backup": true}]  # the backup's: not yours
	var line := ScoreBugState.kicker_line(kicks)
	eq(line, {"fg_made": 1, "fg_att": 2, "pat_made": 2, "pat_att": 2, "long": 44, "points": 5}, "line")
	eq(ScoreBugState.format_stats(line), "FG 1/2 · XP 2/2 · LNG 44 · 5 PTS", "strip text")
	eq(ScoreBugState.format_stats(ScoreBugState.empty_stats()), "FG 0/0 · XP 0/0 · LNG - · 0 PTS", "empty strip")


func test_add_kick_updates_line_and_score_once() -> void:
	var s := ScoreBugState.new()
	s.setup({"short": "RID"}, {"short": "BAY"}, true, 7)
	s.set_score(7, 3)
	var got := {"stats": 0, "score": []}
	s.stats_changed.connect(func() -> void: got["stats"] += 1)
	s.score_changed.connect(func(side: String) -> void: got["score"].append(side))
	s.add_kick("fg", 42, true)
	eq(s.stats, {"fg_made": 1, "fg_att": 1, "pat_made": 0, "pat_att": 0, "long": 42, "points": 3}, "line after FG")
	eq([s.home_score, s.away_score], [10, 3], "home (us) +3")
	eq(got["score"], ["home"], "one score signal, home side")
	# The sim then reports the same numbers: nothing changes, no signals.
	s.set_score(10, 3)
	s.set_stats(ScoreBugState.kicker_line([{"kind": "fg", "yards": 42, "made": true}]))
	eq(got["stats"], 1, "same line again: no second stats signal")
	eq(got["score"].size(), 1, "same score again: no second score signal")
	s.add_kick("pat", 20, false)
	eq(s.stats["pat_att"], 1, "missed XP counted")
	eq(s.home_score, 10, "missed XP adds nothing")


func test_away_team_mapping() -> void:
	var s := ScoreBugState.new()
	s.setup({"short": "RID"}, {"short": "BAY"}, false)  # we're away
	s.set_score(14, 6)
	eq([s.away["abbr"], s.away_score, s.home["abbr"], s.home_score], ["RID", 14, "BAY", 6], "us on the top row")
	s.set_possession("us")
	eq(s.possession, "away", "our ball = away row")
	s.set_possession("them")
	eq(s.possession, "home", "their ball = home row")
	s.set_possession("")
	eq(s.possession, "", "nobody")


func test_abbreviations() -> void:
	eq(ScoreBugState.abbreviation({"short": "rid"}), "RID", "existing short, upper-cased")
	eq(ScoreBugState.abbreviation({"short": "???", "town": "Pine Bluff East"}), "PBE", "initials of a multi-word town")
	eq(ScoreBugState.abbreviation({"town": "Ridgeline"}), "RID", "first three letters")
	eq(ScoreBugState.abbreviation({"name": "St. Mary's Academy"}), "SMA", "punctuation ignored")
	eq(ScoreBugState.abbreviation({}), "TM", "nothing to go on")
	for t in CareerContent.high_schools() + CareerContent.colleges():
		var a := ScoreBugState.abbreviation(t)
		check(a.length() >= 2 and a.length() <= 4, "%s -> %s is 2-4 letters" % [t.get("name"), a])


func test_game_sim_events_carry_possession() -> void:
	var c := CareerData.create("Bug Test", CareerTuning.get_default())
	c.team = Progression.team_from(CareerContent.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c)
	m.rng.seed = 4
	m._start_season(false)
	if m.is_bye():
		c.week += 1
	var sim := m.new_game_sim(load("res://tuning/kick_tuning.tres"))
	var seen := {}
	var guard := 0
	while guard < 2000:
		guard += 1
		var e := sim.next()
		var t := str(e.get("type", ""))
		if t == "end":
			break
		if t in ["play", "call", "warmup"]:
			check(e.has("poss"), "%s event has poss" % t)
			seen[str(e.get("poss", ""))] = true
		if t == "call":
			eq(e["poss"], "us", "your kick: your ball")
			sim.resolve_call({"made": true, "quality": 0.8, "carry": 60.0, "recovered": false})
		elif t == "warmup":
			sim.set_warmup("skipped")
	check(seen.has("us") and seen.has("them"), "both teams had the ball")
	check(sim.quarter_seconds() > 0.0, "quarter length")


func test_possession_does_not_change_the_game_script() -> void:
	# Same seed, same game: adding possession must not touch the random rolls.
	var lines := []
	for run in 2:
		var c := CareerData.create("Bug Test", CareerTuning.get_default())
		c.team = Progression.team_from(CareerContent.high_schools()[1], CareerData.STAGE_HIGH_SCHOOL)
		var m := CareerManager.new(c)
		m.rng.seed = 11
		m._start_season(false)
		var sim := m.new_game_sim(load("res://tuning/kick_tuning.tres"))
		var out := PackedStringArray()
		for i in 300:
			var e := sim.next()
			if e.get("type", "") == "end":
				break
			if e.get("type", "") == "call":
				sim.resolve_call({"made": true, "quality": 0.8, "carry": 60.0})
			elif e.get("type", "") == "warmup":
				sim.set_warmup("pure")
			out.append(str(e.get("text", e.get("kind", ""))))
		lines.append(out)
	eq(lines[0], lines[1], "same seed, same play-by-play")
