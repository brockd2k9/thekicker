extends "res://tests/test_case.gd"
## Leagues (League / LeagueConfig / league_teams.json): schedule generation,
## standings, tiebreakers (two- and three-team), seeding and qualifying, the
## bracket, the college conference title game, save / load mid-season, old
## saves getting a league, strength drift.

var t := CareerTuning.get_default()


# --- helpers -----------------------------------------------------------------------------

## A hand-made league: n conferences x m divisions x d teams, no games yet
## (team i is in division i / d, conference i / (m * d)).
func _lg(n: int, m: int, d: int, stage := CareerData.STAGE_PRO) -> Dictionary:
	var ids: Array = []
	var strs: Array = []
	var div: Array = []
	var divs: Array = []
	var confs: Array = []
	for c in n:
		confs.append("Conf %d" % c)
		for v in m:
			divs.append(["Div %d-%d" % [c, v], c])
	for i in n * m * d:
		ids.append("t%d" % i)
		strs.append(50.0)
		div.append(i / d)
	return {"v": League.VERSION, "stage": stage, "scope": "", "seed": 1, "season": 1, "ids": ids, "str": strs,
		"div": div, "divs": divs, "confs": confs, "custom": {}, "weeks": [], "scores": [], "post": {}}


## One played game in a week of its own.
func _game(lg: Dictionary, home: int, away: int, hs: int, as_: int) -> void:
	lg["weeks"].append([home, away])
	lg["scores"].append([hs, as_])


func _manager(stage: String, team_i := 0) -> CareerManager:
	var c := CareerData.create("League Test", t)
	var pool: Array = {CareerData.STAGE_COLLEGE: _fbs(), CareerData.STAGE_PRO: TeamDatabase.pro_teams(),
		CareerData.STAGE_JUCO: TeamDatabase.jucos()}.get(stage, TeamDatabase.high_schools())
	c.team = Progression.team_from(pool[team_i], stage)
	c.stage = stage
	var m := CareerManager.new(c)
	m.rng.seed = 7
	m._start_season(false)
	return m


## FBS colleges, biggest conferences first (title games need 6+ teams).
func _fbs() -> Array:
	var all: Array = TeamDatabase.colleges().filter(func(s: Dictionary) -> bool: return s["division"] == "FBS")
	var count := {}
	for s in all:
		count[s["conference"]] = int(count.get(s["conference"], 0)) + 1
	all.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(count[a["conference"]]) > int(count[b["conference"]]))
	return all


## Plays the regular season on paper: the player's games get `outcome(week)`,
## everyone else is simulated (League.after_week), then the week past it.
func _play_regular(m: CareerManager, outcome: Callable) -> void:
	var c := m.data
	for e in c.schedule:
		if str(e["type"]) == "regular":
			var o: String = outcome.call(int(e["week"]))
			e["result"] = {"us": 45 if o == "W" else 10, "them": 3 if o == "W" else 24, "outcome": o}
			c.record[o.to_lower()] += 1
		League.after_week(c, int(e["week"]))
	c.week = m.weeks_in_season() + 1


func _check_schedule(weeks: Array, count: int, games: int, msg: String, short_ok := 1) -> void:
	var per := {}
	for w in weeks.size():
		var seen := {}
		var pairs: Array = weeks[w]
		for q in range(0, pairs.size(), 2):
			for x in [int(pairs[q]), int(pairs[q + 1])]:
				check(not seen.has(x), "%s: team %d plays twice in week %d" % [msg, x, w + 1])
				seen[x] = true
				per[x] = int(per.get(x, 0)) + 1
			check(int(pairs[q]) != int(pairs[q + 1]), "%s: a team plays itself" % msg)
	var short := 0
	for i in count:
		check(int(per.get(i, 0)) <= games, "%s: team %d too many games" % [msg, i])
		if int(per.get(i, 0)) < games:
			short += 1
	check(short <= short_ok, "%s: %d teams short of %d games" % [msg, short, games])


# --- schedule ----------------------------------------------------------------------------

## Every stage's real league: full schedules, division games, byes.
func test_schedule_every_stage() -> void:
	for stage in [CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO, CareerData.STAGE_COLLEGE, CareerData.STAGE_PRO]:
		var m := _manager(stage)
		var lg := m.data.league
		var s := League.config().structure(stage)
		var games := t.games_for(stage)
		var weeks: Array = lg["weeks"]
		_check_schedule(weeks, League.size(lg), games, stage)
		eq(weeks.size(), games + t.byes_per_season, stage + ": weeks")
		var div_games := {}
		var met := {}
		var homes := {}
		var played := {}
		var outside_window := 0
		for w in weeks.size():
			var pairs: Array = weeks[w]
			var busy := {}
			for q in range(0, pairs.size(), 2):
				var a := int(pairs[q])
				var b := int(pairs[q + 1])
				busy[a] = true
				busy[b] = true
				homes[a] = int(homes.get(a, 0)) + 1
				played[a] = int(played.get(a, 0)) + 1
				played[b] = int(played.get(b, 0)) + 1
				var key := "%d-%d" % [mini(a, b), maxi(a, b)]
				met[key] = int(met.get(key, 0)) + 1
				if League.div_of(lg, a) == League.div_of(lg, b):
					div_games[a] = int(div_games.get(a, 0)) + 1
					div_games[b] = int(div_games.get(b, 0)) + 1
				else:
					check(int(met[key]) == 1, "%s: a non-division rematch" % stage)
			for i in League.size(lg):
				if not busy.has(i) and (w + 1 < t.bye_week_earliest or w + 1 > t.bye_week_latest):
					outside_window += 1
		for i in League.size(lg):
			var size := League.division_teams(lg, League.div_of(lg, i)).size()
			var want := int(s["division_games"]) if bool(s["rematches"]) else mini(int(s["division_games"]), size - 1)
			want = mini(want, games)
			check(int(div_games.get(i, 0)) >= want - 1, "%s: %s division games %d of %d" % [stage, lg["ids"][i],
				int(div_games.get(i, 0)), want])
			var h := int(homes.get(i, 0))
			var g := int(played.get(i, 0))
			check(absi(2 * h - g) <= 2, "%s: home games %d of %d" % [stage, h, g])
		# Byes mostly in the window (odd team counts force a few outside it).
		check(outside_window <= League.size(lg) / 2 + 1, "%s: %d byes outside weeks %d-%d" % [stage, outside_window,
			t.bye_week_earliest, t.bye_week_latest])
		if stage == CareerData.STAGE_PRO:
			for i in League.size(lg):
				eq(int(played.get(i, 0)), games, "pro: every club plays 17")
				eq(int(div_games.get(i, 0)), 6, "pro: 6 division games (home and away)")


## Shapes like the team data's: odd counts, uneven conferences, a tiny league.
func test_schedule_odd_shapes() -> void:
	var shapes := {
		"21 in one group": [Array(range(21)).map(func(_i: int) -> int: return 0), 10, 10, false, 0],
		"uneven conferences": [[0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3], 12, 8, false, 0],
		"6 teams, 10 games": [[0, 0, 0, 0, 0, 0], 10, 10, true, 0],
	}
	for name in shapes:
		var sh: Array = shapes[name]
		var rng := RandomNumberGenerator.new()
		rng.seed = 5
		var weeks := League.generate_schedule(sh[0], sh[0], sh[1], sh[2], sh[3], sh[4], 1, 4, 8, rng)
		_check_schedule(weeks, (sh[0] as Array).size(), sh[1], name)
		eq(weeks.size(), int(sh[1]) + 1, name + ": weeks")
	var rng := RandomNumberGenerator.new()
	var none := League.generate_schedule([0, 0, 1, 1, 2, 2, 3, 3], [0, 0, 0, 0, 1, 1, 1, 1], 6, 1, false, 2, 0, 4, 8, rng)
	_check_schedule(none, 8, 6, "no byes", 0)


## The league is the team database's teams and nothing else.
func test_league_is_the_team_database() -> void:
	var expect := {CareerData.STAGE_HIGH_SCHOOL: TeamDatabase.high_schools().size(),
		CareerData.STAGE_JUCO: TeamDatabase.jucos().size(), CareerData.STAGE_PRO: TeamDatabase.pro_teams().size(),
		CareerData.STAGE_COLLEGE: _fbs().size()}
	eq(int(expect[CareerData.STAGE_HIGH_SCHOOL]), 21, "21 high schools")
	eq(int(expect[CareerData.STAGE_PRO]), 32, "32 pro clubs")
	for stage in expect:
		var m := _manager(stage)
		var lg := m.data.league
		eq(League.size(lg), int(expect[stage]), stage + ": every database team, nothing else")
		eq((lg["custom"] as Dictionary).size(), 0, stage + ": no made-up teams")
		for id in lg["ids"]:
			check(TeamDatabase.has_team(str(id)), "%s: %s is a database team" % [stage, id])
		check(League.player_index(m.data) >= 0, stage + ": the player's team is in it")
		# The player's schedule is the league's.
		var p := League.player_index(m.data)
		var ts := League.team_schedule(lg, p)
		for i in ts.size():
			var e: Dictionary = m.data.schedule[i]
			if int(ts[i]["opp"]) < 0:
				eq(str(e["type"]), "bye", stage + ": bye matches")
			else:
				eq(str(e["opponent"]["id"]), str(lg["ids"][int(ts[i]["opp"])]), stage + ": opponent matches")
				eq(bool(e["home"]), bool(ts[i]["home"]), stage + ": home matches")
	# Pro: AFC / NFC, four divisions of four; college: one level, its conferences.
	var pro := _manager(CareerData.STAGE_PRO).data.league
	eq(League.conference_count(pro), 2, "AFC and NFC")
	eq(League.division_count(pro), 8, "8 divisions")
	for d in 8:
		eq(League.division_teams(pro, d).size(), 4, "4 per division")
	var col := _manager(CareerData.STAGE_COLLEGE).data.league
	eq(str(col["scope"]), "FBS", "an FBS player's league is FBS")
	check(League.flat(col), "college conferences are the divisions")
	for i in League.size(col):
		eq(str(TeamDatabase.team(str(col["ids"][i]))["conference"]), League.conference_name(col, League.conf_of(col, i)),
			"conference from the data")


# --- standings and tiebreakers -----------------------------------------------------------

func test_standings() -> void:
	var lg := _lg(2, 1, 2)  # conf 0: t0 t1 (one division), conf 1: t2 t3
	_game(lg, 0, 1, 21, 14)  # t0 beats t1 (division)
	_game(lg, 2, 0, 10, 10)  # t0 ties t2 (nonconference)
	_game(lg, 0, 3, 3, 17)   # t3 beats t0
	_game(lg, 1, 0, 0, 7)    # t0 beats t1 again
	var st := League.standings(lg)
	var r: Dictionary = st[0]
	eq([int(r["w"]), int(r["l"]), int(r["t"])], [2, 1, 1], "t0 2-1-1")
	eq([int(r["dw"]), int(r["dl"]), int(r["dt"])], [2, 0, 0], "division 2-0")
	eq([int(r["cw"]), int(r["cl"]), int(r["ct"])], [2, 0, 0], "conference 2-0")
	eq([int(r["pf"]), int(r["pa"])], [41, 41], "points for / against")
	eq(str(r["streak"]), "W1", "streak")
	eq(str(st[1]["streak"]), "L2", "t1 lost two")
	eq(League.record_text(r), "2-1-1", "record text with ties")
	eq(League.pct(r), 0.625, "ties count half")
	eq(League.pct(st[3]), 1.0, "t3 1-0")
	eq(League.pct(_lg(1, 1, 2)), 0.0, "no games: 0")


## Two teams: head-to-head first.
func test_tiebreak_two_teams_head_to_head() -> void:
	var lg := _lg(1, 1, 4)
	_game(lg, 0, 1, 10, 20)  # t1 beats t0
	_game(lg, 0, 2, 50, 0)   # t0 crushes t2 (better point differential)
	_game(lg, 1, 3, 0, 7)    # t1 loses to t3
	var st := League.standings(lg)
	eq(League.pct(st[0]), League.pct(st[1]), "same record")
	eq(League.break_tie(lg, st, [0, 1]), [1, 0], "t1 won the game between them")
	eq(League.rank(lg, st, [0, 1]), [1, 0], "rank uses it")


## Two teams that never met: division record, then point differential.
func test_tiebreak_two_teams_division_then_points() -> void:
	var lg := _lg(1, 2, 2)  # division 0: t0 t1, division 1: t2 t3
	_game(lg, 0, 1, 14, 7)  # t0 1-0 in division
	_game(lg, 2, 0, 21, 0)  # t0 loses outside
	_game(lg, 2, 3, 3, 0)   # (t2 division win)
	_game(lg, 3, 2, 3, 0)   # (t3 division win)
	_game(lg, 1, 3, 30, 0)  # t1 wins outside
	var st := League.standings(lg)
	eq(League.pct(st[0]), League.pct(st[1]), "both 1-1")
	eq(League.break_tie(lg, st, [1, 0]), [0, 1], "t0 has the better division record")
	# Different divisions, no meeting, same conference record: point differential.
	var lg2 := _lg(2, 1, 2)
	_game(lg2, 0, 1, 20, 0)  # t0 +20
	_game(lg2, 2, 3, 10, 0)  # t2 +10
	var st2 := League.standings(lg2)
	eq(League.break_tie(lg2, st2, [2, 0]), [0, 2], "point differential")


## Three teams who beat each other in a circle: head-to-head can't split them
## (all 1-1), so the division record does, then the two left restart at
## head-to-head.
func test_tiebreak_three_teams_circle() -> void:
	var lg := _lg(1, 2, 4)  # division 0: t0..t3, division 1: t4..t7
	_game(lg, 0, 1, 10, 7)   # t0 > t1
	_game(lg, 1, 2, 10, 7)   # t1 > t2
	_game(lg, 2, 0, 10, 7)   # t2 > t0
	_game(lg, 0, 3, 10, 7)   # t0 beats t3 (division)
	_game(lg, 1, 4, 10, 7)   # t1 beats t4 (outside the division)
	_game(lg, 2, 5, 10, 7)   # t2 beats t5 (outside)
	_game(lg, 3, 1, 7, 0)    # t1 loses to t3 (division)
	_game(lg, 2, 3, 0, 7)    # t2 loses to t3 (division)
	_game(lg, 6, 0, 30, 0)   # t0 loses outside
	var st := League.standings(lg)
	eq(League.pct(st[0]), League.pct(st[1]), "t0 = t1")
	eq(League.pct(st[1]), League.pct(st[2]), "t1 = t2")
	# Division: t0 2-1, t1 1-2, t2 1-2 -> t0 first; then t1 beat t2 head to head.
	eq(League.break_tie(lg, st, [2, 1, 0]), [0, 1, 2], "circle: division record, then head-to-head")


## Three teams where one swept the other two: it's first, and head-to-head
## among the three still orders the other two (t2 beat t1), even though t1
## has the much better point differential.
func test_tiebreak_three_teams_sweep() -> void:
	var lg := _lg(1, 1, 6)
	_game(lg, 0, 1, 20, 0)  # t0 > t1
	_game(lg, 0, 2, 20, 0)  # t0 > t2
	_game(lg, 2, 1, 3, 0)   # t2 > t1
	_game(lg, 3, 0, 9, 0)   # t0 loses twice outside the tie: 2-2
	_game(lg, 4, 0, 9, 0)
	_game(lg, 1, 5, 40, 0)  # t1 wins twice, big: 2-2, +57
	_game(lg, 1, 3, 40, 0)
	_game(lg, 2, 5, 3, 0)   # t2: 2-2, -17
	_game(lg, 4, 2, 3, 0)
	var st := League.standings(lg)
	eq([League.record_text(st[0]), League.record_text(st[1]), League.record_text(st[2])], ["2-2", "2-2", "2-2"],
		"all three 2-2")
	check(int(st[1]["pf"]) - int(st[1]["pa"]) > int(st[2]["pf"]) - int(st[2]["pa"]), "t1 has the better points")
	eq(League.break_tie(lg, st, [1, 2, 0]), [0, 2, 1], "t0 swept; t2 beat t1")
	eq(League.rank(lg, st, [1, 2, 0]), [0, 2, 1], "rank agrees")
	# Drop t0 from the tie: the two left start over at head-to-head.
	eq(League.break_tie(lg, st, [1, 2]), [2, 1], "two-team restart: head-to-head")


## Nothing separates them: a fixed coin flip (same answer every time).
func test_tiebreak_coin_flip_is_stable() -> void:
	var lg := _lg(1, 1, 4)
	var st := League.standings(lg)
	var a := League.break_tie(lg, st, [0, 1, 2, 3])
	eq(a.size(), 4, "everyone ordered")
	eq(League.break_tie(lg, st, [3, 2, 1, 0]), a, "same order whatever the input order")


# --- seeding and qualifying ---------------------------------------------------------------

## Division winners first (even with a losing record), then wild cards. A
## team with a winning record can miss; a 1-2 team can get in.
func test_seeding_division_winners_and_wild_cards() -> void:
	var cfg := LeagueConfig.new()
	cfg.pro_wildcards_per_conference = 1
	League.use_config(cfg)
	var lg := _lg(1, 2, 2)  # division 0: t0 t1, division 1: t2 t3
	_game(lg, 0, 1, 10, 0)  # t0 3-0
	_game(lg, 0, 2, 10, 0)
	_game(lg, 0, 3, 10, 0)
	_game(lg, 1, 2, 10, 0)  # t1 2-1
	_game(lg, 1, 3, 10, 0)
	_game(lg, 2, 3, 10, 0)  # t2 1-2 (wins its weak division), t3 0-3
	var st := League.standings(lg)
	var f := League.field(lg, st)
	eq(f["sides"], [[0, 2, 1]], "winners t0 and t2 (1-2), then wild card t1")
	cfg.pro_wildcards_per_conference = 0
	f = League.field(lg, st)
	eq(f["sides"], [[0, 2]], "no wild cards: t1 misses at 2-1, t2 is in at 1-2")
	eq(f["out"], [[1, 3]], "the rest, best first")
	League.use_config(null)


func test_qualifying_from_the_standings() -> void:
	var cfg := LeagueConfig.new()
	cfg.pro_wildcards_per_conference = 0
	League.use_config(cfg)
	var lg := _lg(1, 2, 2)
	_game(lg, 0, 1, 10, 0)
	_game(lg, 0, 2, 10, 0)
	_game(lg, 0, 3, 10, 0)
	_game(lg, 1, 2, 10, 0)
	_game(lg, 1, 3, 10, 0)
	_game(lg, 2, 3, 10, 0)
	# The player is t1: 2-1 and out. Their record would have qualified before.
	var c := CareerData.create("Q", t)
	c.stage = CareerData.STAGE_PRO
	lg["ids"][1] = str(TeamDatabase.pro_teams()[0]["id"])
	c.team = Progression.team_from(TeamDatabase.pro_teams()[0], CareerData.STAGE_PRO)
	c.league = lg
	c.season = 1
	c.record = {"w": 2, "l": 1, "t": 0}
	check(League.active(c), "league decides")
	var q := League.qualification(c)
	eq(str(q["kind"]), "", "2-1 and out")
	check(str(q["reason"]).begins_with("2nd in the"), "why: " + str(q["reason"]))
	var out := Postseason.advance(c, RandomNumberGenerator.new(), t)
	eq(out["event"], "missed", "missed the postseason")
	check(c.flags.get("missed_postseason", false), "missed_postseason")
	check(not c.flags.get("division_champion", true), "not a division champion")
	check(str(c.postseason["text"]).contains("2nd in the"), "the text says why: " + str(c.postseason["text"]))
	# The same league with the player as t2 (1-2, wins the division): in.
	var c2 := CareerData.create("Q2", t)
	c2.stage = CareerData.STAGE_PRO
	var lg2 := lg.duplicate(true)
	lg2["ids"][1] = "t1"
	lg2["ids"][2] = str(TeamDatabase.pro_teams()[0]["id"])
	lg2["post"] = {}
	c2.team = c.team.duplicate()
	c2.league = lg2
	c2.season = 1
	c2.record = {"w": 1, "l": 2, "t": 0}
	out = Postseason.advance(c2, RandomNumberGenerator.new(), t)
	eq(out["event"], "qualified", "1-2 division winner is in")
	check(c2.flags.get("made_playoffs", false) and c2.flags.get("division_champion", false), "flags")
	eq(int(c2.postseason["seed"]), 2, "the #2 seed")
	var e: Dictionary = c2.schedule.back()
	eq(str(e["opponent"]["id"]), "t0", "plays the #1 seed")
	eq(str(e["round_name"]), "Gridiron Championship", "a two-team field is the final")
	League.use_config(null)


func test_bracket_seed_order_and_byes() -> void:
	eq(League.seed_order(8), [1, 8, 4, 5, 2, 7, 3, 6], "8-team order")
	var br := League.make_bracket([[10, 11, 12, 13, 14, 15, 16]])  # 7 teams: #1 gets a bye
	eq(br["slots"], [10, -1, 13, 14, 11, 16, 12, 15], "seed 1 has the bye")
	eq(League.bracket_rounds(br), 3, "3 rounds")
	var two := League.make_bracket([[1, 2, 3, 4], [5, 6, 7, 8]])
	eq(League.bracket_rounds(two), 3, "two sides of 4: 3 rounds (the last is between sides)")
	eq((two["slots"] as Array).slice(4), [5, 8, 6, 7], "second side after the first")


## The default pro league: 7 per conference, the #1 seed skips the first round.
func test_pro_top_seed_bye() -> void:
	var m := _manager(CareerData.STAGE_PRO)
	var c := m.data
	var lg := c.league
	var p := League.player_index(c)
	# Everyone else even; the player wins out.
	for i in League.size(lg):
		lg["str"][i] = 50.0
	_play_regular(m, func(_w: int) -> String: return "W")
	var q := League.qualification(c)
	eq(str(q["kind"]), "playoff", "10-0 is in")
	eq(int(q["seed"]), 1, "the #1 seed")
	check(bool(q["bye"]), "with a bye")
	var out := Postseason.advance(c, m.rng, t)
	eq(out["event"], "qualified", "qualified")
	check(str(out["text"]).contains("bye"), "the text says bye: " + str(out["text"]))
	eq(str(m.entry()["round_name"]), Postseason.rounds(c, "playoff")[1], "starts in the second round")
	check(bool(m.entry()["home"]), "the top seed is at home")
	eq(int(League.picture(c)["player"]["seed"]), 1, "playoff picture: #1")
	# Win it all: the bracket follows the player.
	var opps := {}
	while str(c.postseason.get("status", "")) == "alive":
		var e := m.entry()
		check(not opps.has(e["opponent"]["id"]), "a new opponent each round")
		opps[e["opponent"]["id"]] = true
		e["result"] = {"us": 30, "them": 3, "outcome": "W"}
		c.week += 1
		out = Postseason.advance(c, m.rng, t)
	eq(out["event"], "champion", "champions")
	eq(League.finish(c), p, "the bracket's champion is the player")
	eq(int(Postseason.career(c)["wins"]), 3, "three postseason wins")


## Losing ends it; the rest of the bracket is played out.
func test_bracket_plays_out_after_elimination() -> void:
	var m := _manager(CareerData.STAGE_HIGH_SCHOOL)
	var c := m.data
	_play_regular(m, func(_w: int) -> String: return "W")
	var out := Postseason.advance(c, m.rng, t)
	eq(out["event"], "qualified", "10-0 is in")
	check(c.flags.get("division_champion", false), "division champion")
	m.entry()["result"] = {"us": 3, "them": 30, "outcome": "L"}
	c.week += 1
	out = Postseason.advance(c, m.rng, t)
	eq(out["event"], "eliminated", "out")
	var champ := League.finish(c)
	check(champ >= 0 and champ != League.player_index(c), "someone else won it")


func test_college_conference_title_game_then_playoff() -> void:
	var m := _manager(CareerData.STAGE_COLLEGE)
	var c := m.data
	_play_regular(m, func(_w: int) -> String: return "W")
	var regular := m.weeks_in_season()
	var out := Postseason.advance(c, m.rng, t)
	eq(out["event"], "conference", "10-0: the conference title game first")
	eq(m.weeks_in_season(), regular + 1, "one week added")
	var e := m.entry()
	eq(str(e["postseason"]), "conference", "a conference week")
	check(str(e["round_name"]).ends_with("Championship"), "named: " + str(e["round_name"]))
	check(m.is_postseason(), "a postseason week (pressure, no ties)")
	check(m.game_params().get("no_tie", false), "no ties")
	check(c.flags.get("conference_title_game", false) and c.flags.get("in_postseason", false), "flags")
	check(c.flags.get("division_champion", false), "division champion")
	check(not c.flags.get("championship_game", true), "not a final")
	eq(m.regular_weeks(), regular, "regular weeks unchanged")
	e["result"] = {"us": 27, "them": 20, "outcome": "W"}
	c.week += 1
	out = Postseason.advance(c, m.rng, t)
	eq(out["event"], "qualified", "into the playoff")
	check(c.flags.get("conference_champion", false), "conference champion")
	check(not c.flags.get("conference_title_game", true), "title game over")
	check(c.flags.get("made_playoffs", false), "made_playoffs")
	eq(int(c.postseason["w"]), 1, "the title game counts as a postseason win")
	check(str(c.postseason["text"]).contains("champions"), "text: " + str(c.postseason["text"]))
	check(int(c.postseason["seed"]) >= 1 and int(c.postseason["seed"]) <= 4, "a top-4 seed: bye")
	eq(str(m.entry()["round_name"]), Postseason.rounds(c, "playoff")[1], "a top-4 seed starts in the quarterfinal")


func test_college_title_game_loss_can_still_go_bowling() -> void:
	var m := _manager(CareerData.STAGE_COLLEGE, 3)
	var c := m.data
	_play_regular(m, func(w: int) -> String: return "W" if w % 3 != 0 else "L")
	var out := Postseason.advance(c, m.rng, t)
	if out["event"] == "conference":
		m.entry()["result"] = {"us": 10, "them": 13, "outcome": "L"}
		c.week += 1
		out = Postseason.advance(c, m.rng, t)
		check(str(out["text"]).begins_with("Lost the"), "the title game loss is mentioned")
		check(not c.flags.get("conference_champion", true), "not conference champion")
		eq(int(Postseason.career(c)["losses"]), 1, "the loss counts")
	check(out["event"] in ["qualified", "missed"], "decided: " + str(out["event"]))
	if c.flags.get("bowl_game", false):
		check(bool(m.entry()["final"]), "a bowl is one game")
		check(str(m.entry()["opponent"]["id"]) != "", "against a bowl team from the league")


## College bowls: the next teams in the ranking with at least .500, in pairs.
func test_college_field_and_bowls() -> void:
	var m := _manager(CareerData.STAGE_COLLEGE)
	var c := m.data
	_play_regular(m, func(w: int) -> String: return "W" if w % 2 == 0 else "L")
	var lg := c.league
	var st := League.standings(lg)
	var f := League.field(lg, st)
	var s := League.config().structure(CareerData.STAGE_COLLEGE)
	eq((f["sides"][0] as Array).size(), int(s["field"]), "a full field")
	eq((f["bowls"] as Array).size() % 2, 0, "bowl teams in pairs")
	check((f["bowls"] as Array).size() <= int(s["bowl_slots"]), "no more than the bowl slots")
	for b in f["bowls"]:
		check(League.pct(st[b]) >= float(s["bowl_min"]) - 0.001, "bowl teams are .500 or better")
		check(not (b in f["sides"][0]), "not in the playoff")
	# The best auto_bids conference champions (by the ranking) are in.
	var champs: Array = (f["champions"] as Dictionary).values()
	var best := League.poll_order(lg, st, champs).filter(func(i: int) -> bool: return i in champs)
	for ch in best.slice(0, int(s["auto_bids"])):
		check(ch in f["sides"][0], "conference champion %d in the field" % ch)
	check(not (f["champions"] as Dictionary).is_empty(), "conferences have champions")


# --- the season loop, saves -------------------------------------------------------------

func test_weeks_simulate_and_save_mid_season() -> void:
	var m := _manager(CareerData.STAGE_HIGH_SCHOOL)
	var c := m.data
	for w in [1, 2, 3]:
		var e: Dictionary = c.schedule[w - 1]
		if str(e["type"]) == "regular":
			e["result"] = {"us": 17, "them": 14, "outcome": "W"}
		League.after_week(c, w)
	# Every game of the week is in, the player's with the real score.
	var p := League.player_index(c)
	var ts := League.team_schedule(c.league, p)
	for w in 3:
		if int(ts[w]["opp"]) >= 0:
			eq([int(ts[w]["us"]), int(ts[w]["them"])], [17, 14], "week %d: the real score" % (w + 1))
	for sc in (c.league["scores"] as Array).slice(0, 3):
		check(not (sc as Array).is_empty(), "the week was played")
	check((c.league["scores"][3] as Array).is_empty(), "week 4 not yet")
	# Save and load: the same league, and week 4 comes out the same either way.
	var back := CareerData.from_dict(JSON.parse_string(JSON.stringify(c.to_dict())))
	check(League.valid(back.league, back.stage), "league survives JSON")
	eq(JSON.stringify(League.standings(back.league)), JSON.stringify(League.standings(c.league)), "same standings")
	League.after_week(c, 4)
	League.after_week(back, 4)
	eq(JSON.stringify(back.league["scores"][3]), JSON.stringify(c.league["scores"][3]), "same simulated week after a load")
	# Packed in the save (weeks and scores as bytes), the same after loading.
	var packed: Dictionary = c.to_dict()["league"]
	eq(int(packed.get("packed", 0)), 1, "packed")
	eq(JSON.stringify(League.unpack(JSON.parse_string(JSON.stringify(packed)))["scores"]),
		JSON.stringify(c.league["scores"]), "unpacks to the same scores")
	# Compact: a few KB.
	check(JSON.stringify(packed).length() < 3000, "league save is small (%d chars)" % JSON.stringify(packed).length())
	var col := _manager(CareerData.STAGE_COLLEGE).data
	var big := JSON.stringify(col.to_dict()["league"]).length()
	check(big < 12000, "a 138-team college league saves small (%d chars)" % big)


func test_end_week_simulates_the_league() -> void:
	var m := _manager(CareerData.STAGE_PRO)
	var c := m.data
	c.phase = CareerManager.PHASE_RESULTS
	if not m.is_bye():
		m.entry()["result"] = {"us": 20, "them": 17, "outcome": "W"}
	m.end_week()
	check(not (c.league["scores"][0] as Array).is_empty(), "week 1 is in the books")
	eq(c.week, 2, "week 2")


func test_old_save_gets_a_league() -> void:
	var raw := fixture("career_v8_midseason.json")
	check(not raw.has("league"), "fixture is from before leagues")
	var c := CareerData.from_dict(CareerSave._migrate(raw.duplicate(true)))
	var before: Array = c.schedule.duplicate(true)
	var m := CareerManager.new(c)
	m._sanitize()
	check(League.valid(c.league, c.stage), "a league was made")
	var p := League.player_index(c)
	check(p >= 0, "the player's team is in it")
	# Same opponents, home / away and byes as the schedule being played.
	var ts := League.team_schedule(c.league, p)
	for i in before.size():
		var e: Dictionary = before[i]
		if str(e["type"]) == "bye":
			eq(int(ts[i]["opp"]), -1, "week %d: still a bye" % (i + 1))
		else:
			eq(str(c.league["ids"][int(ts[i]["opp"])]), str(e["opponent"]["id"]), "week %d: same opponent" % (i + 1))
			eq(bool(ts[i]["home"]), bool(e["home"]), "week %d: same home / away" % (i + 1))
	# Weeks already finished are simulated, with the player's real results.
	var st := League.standings(c.league)
	eq(League.record_text(st[p]), "%d-%d" % [int(c.record["w"]), int(c.record["l"])], "league record = the save's")
	for w in c.week - 1:
		check(not (c.league["scores"][w] as Array).is_empty(), "week %d simulated" % (w + 1))
	for w in range(c.week - 1, (c.league["weeks"] as Array).size()):
		check((c.league["scores"][w] as Array).is_empty(), "week %d not yet" % (w + 1))
	# Every team still plays at most once a week.
	for w in (c.league["weeks"] as Array).size():
		var seen := {}
		var pairs: Array = c.league["weeks"][w]
		for x in pairs:
			check(not seen.has(int(x)), "week %d: one game per team" % (w + 1))
			seen[int(x)] = true
	# Saved and loaded again: nothing changes.
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	var m2 := CareerManager.new(again)
	m2._sanitize()
	eq(JSON.stringify(again.league), JSON.stringify(c.league), "the league is kept, not remade")


## The rival's game (Relationships.schedule_tyler) and anything else that
## changes the player's schedule: the league follows.
func test_align_to_schedule() -> void:
	var m := _manager(CareerData.STAGE_HIGH_SCHOOL)
	var c := m.data
	var lg := c.league
	var p := League.player_index(c)
	var last := -1
	for i in c.schedule.size():
		if str(c.schedule[i]["type"]) == "regular":
			last = i
	var want := -1
	var current := int(League.team_schedule(lg, p)[last]["opp"])
	for i in League.size(lg):
		if i != p and i != current:
			want = i
			break
	c.schedule[last]["opponent"] = League.team(lg, want)
	c.schedule[last]["home"] = false
	League.align_to_schedule(c)
	var g: Dictionary = League.team_schedule(lg, p)[last]
	eq(int(g["opp"]), want, "the league has the new opponent")
	check(not bool(g["home"]), "away")
	var seen := {}
	for x in lg["weeks"][last]:
		check(not seen.has(int(x)), "one game per team")
		seen[int(x)] = true


# --- strength and stages ------------------------------------------------------------------

func test_strength_drifts_between_seasons() -> void:
	var m := _manager(CareerData.STAGE_PRO)
	var c := m.data
	var before: Array = (c.league["str"] as Array).duplicate()
	var ids: Array = (c.league["ids"] as Array).duplicate()
	c.season += 1
	m._start_season(true)
	eq(c.league["ids"], ids, "same league next season")
	var changed := 0
	var g := League.config()
	for i in before.size():
		var d := absf(float(c.league["str"][i]) - float(before[i]))
		if d > 0.0:
			changed += 1
		if i != League.player_index(c):
			check(d <= g.strength_drift + 70.0 * g.strength_regression + 0.11, "drift is slow (%.1f)" % d)
	check(changed > before.size() / 2, "most teams moved")
	eq(int(c.league["season"]), c.season, "this season's schedule")
	eq(float(c.league["str"][League.player_index(c)]), snappedf(float(c.team["strength"]), 0.1), "the player's team strength")


func test_new_stage_new_league() -> void:
	var m := _manager(CareerData.STAGE_HIGH_SCHOOL)
	var c := m.data
	var hs_ids: Array = (c.league["ids"] as Array).duplicate()
	c.stage = CareerData.STAGE_COLLEGE
	c.team = Progression.team_from(_fbs()[2], CareerData.STAGE_COLLEGE)
	c.season += 1
	m._start_season(true)
	eq(str(c.league["stage"]), CareerData.STAGE_COLLEGE, "a college league")
	check(c.league["ids"] != hs_ids, "different teams")
	check(League.player_index(c) >= 0, "the new team is in it")
	# A free agent has no league season: the old schedule builder.
	c.stage = CareerData.STAGE_FREE_AGENT
	check(not League.prepare_season(c, t), "no league for free agents")


func test_hub_line_and_picture() -> void:
	var m := _manager(CareerData.STAGE_HIGH_SCHOOL)
	var c := m.data
	eq(League.picture_line(c), "", "too early in the season")
	var from := League.config().playoff_picture_from_week
	for w in from:
		var e: Dictionary = c.schedule[w]
		if str(e["type"]) == "regular":
			e["result"] = {"us": 21, "them": 0, "outcome": "W"}
		League.after_week(c, w + 1)
	var pic := League.picture(c)
	check(bool(pic["show"]), "shown from week %d" % from)
	eq((pic["sides"] as Array).size(), 1, "one state bracket")
	for sd in pic["sides"]:
		eq((sd["in"] as Array).size(), 8, "the top 8")
		eq((sd["out"] as Array).size(), League.config().playoff_picture_bubble, "the bubble")
	check(League.picture_line(c).begins_with("Playoff picture: in"), League.picture_line(c))
