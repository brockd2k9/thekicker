extends "res://tests/test_case.gd"
## Field tracker: FieldState mapping and text, FieldModel reading GameSim
## events (direction flips, drives, kicks, timeouts), and that it never
## changes the game.

const KT := "res://tuning/kick_tuning.tres"


func _model(us_home := true) -> FieldModel:
	var m := FieldModel.new()
	m.setup({"short": "RID", "mascot": "Falcons", "colors": ["#1f3a8a", "#f2b632"]},
		{"short": "OAK", "mascot": "Owls", "colors": ["#14532d", "#ffffff"]}, us_home, 720.0, 45.0, 50.0, 40, 20)
	return m


func _play(key: String, vars := {}, text := "", extra := {}) -> Dictionary:
	var e := {"type": "play", "key": key, "vars": vars, "text": text if text != "" else key, "elapsed": 100.0,
		"us": 0, "them": 0}
	e.merge(extra, true)
	return e


# --- mapping ---------------------------------------------------------------------------

func test_yard_line_to_position() -> void:
	var w := 600.0
	eq(FieldState.x_of(0.0, w), 50.0, "left goal line after a 10-yard end zone")
	eq(FieldState.x_of(50.0, w), 300.0, "midfield in the middle")
	eq(FieldState.x_of(100.0, w), 550.0, "right goal line")
	eq(FieldState.x_of(-10.0, w), 0.0, "back of the left end zone")
	eq(FieldState.x_of(110.0, w), 600.0, "back of the right end zone")


func test_own_yard_lines_and_direction() -> void:
	eq(FieldState.own_to_abs("away", 25.0), 25.0, "away own 25 (defends the left)")
	eq(FieldState.own_to_abs("home", 25.0), 75.0, "home own 25 (defends the right)")
	eq(FieldState.abs_to_own("home", 75.0), 25.0, "back again")
	eq(FieldState.attack_dir("away"), 1, "away attacks right")
	eq(FieldState.attack_dir("home"), -1, "home attacks left")
	eq(FieldState.to_goal("home", 30.0), 30.0, "home: 30 yards to the left goal")
	eq(FieldState.to_goal("away", 30.0), 70.0, "away: 70 yards to the right goal")


func test_spot_text() -> void:
	var s := _model(true).state  # we're RID at home; OAK away
	eq(s.spot_text("home", FieldState.own_to_abs("home", 37.0)), "OWN 37", "own side")
	eq(s.spot_text("home", FieldState.own_to_abs("home", 63.0)), "OAK 37", "their side: their abbreviation")
	eq(s.spot_text("away", FieldState.own_to_abs("away", 63.0)), "RID 37", "their side from the other bench")
	eq(s.spot_text("home", 50.0), "50", "midfield")


func test_down_and_info_text() -> void:
	var m := _model(true)
	m.apply(_play("drive_start_us", {"spot": 25}))
	eq(m.state.info_text(), "1st & 10 ball on OWN 25", "drive start")
	m.apply(_play("gain_us", {"yards": 4}, "Smith picks up 4 yards."))
	eq(m.state.info_text(), "2nd & 6 ball on OWN 29", "short gain")
	eq(m.state.play_type, "RUSH", "a run")
	m.apply(_play("gain_us", {"yards": 30}, "Quick pass to Lee for 30."))
	eq(m.state.info_text(), "1st & 10 ball on OAK 41", "first down past the line")
	eq(m.state.play_type, "PASS", "a pass")
	m.apply(_play("gain_us", {"yards": 33}))
	eq(m.state.down_text(), "1st & Goal", "inside the 10: goal to go")


# --- direction, drives, kicks ---------------------------------------------------------

func test_direction_flips_on_possession_change() -> void:
	var m := _model(true)  # us = home, attacks left
	m.apply(_play("drive_start_us", {"spot": 30}))
	eq(m.state.possession, "home", "our ball")
	eq(m.state.ball, 70.0, "own 30 = abs 70")
	m.apply(_play("gain_us", {"yards": 10}))
	eq(m.state.ball, 60.0, "home moves left")
	m.apply(_play("turnover_us"))
	eq(m.state.possession, "away", "turnover: their ball")
	eq(m.state.drive_start, 60.0, "their drive starts at the turnover spot")
	m.apply(_play("gain_them", {"yards": 8}))
	eq(m.state.ball, 68.0, "away moves right")
	eq(m.state.first_down, 70.0, "their first-down line is to the right")
	# End zones never move: away left, home right, the whole game.
	m.apply(_play("half"))
	m.apply(_play("drive_start_them", {"spot": 20}))
	eq(m.state.ball, 20.0, "after halftime the away team still starts from the left")


func test_drive_bar_resets_on_new_possession() -> void:
	var m := _model(false)  # us = away
	m.apply(_play("drive_start_us", {"spot": 22}))
	m.apply(_play("gain_us", {"yards": 15}))
	eq([m.state.drive_start, m.state.ball], [22.0, 37.0], "drive bar from 22 to 37")
	m.apply(_play("punt_us"))
	eq(m.state.play_type, "PUNT", "punt tag")
	m.apply(_play("drive_start_them", {"spot": 30}))
	eq([m.state.drive_start, m.state.ball], [70.0, 70.0], "their new drive starts a new bar")


func test_my_field_goal_sets_the_spot_and_kick() -> void:
	var m := _model(true)
	m.apply(_play("drive_start_us", {"spot": 25}))
	m.apply({"type": "call", "kind": "fg", "yards": 42, "label": "", "elapsed": 300.0, "us": 0, "them": 0})
	eq(FieldState.to_goal("home", m.state.ball), 25.0, "42-yard try = line of scrimmage at the 25")
	eq(m.state.down, 4, "fourth down")
	eq(m.state.kick, {"kind": "fg", "yards": 42}, "your kick shown")
	check(m.state.in_fg_range(), "inside your 45-yard range")
	m.apply(_play("fg_us_good", {"yards": 42}, "Field goal is GOOD from 42!"))
	check(m.state.kick.is_empty(), "kick cleared after the result")
	eq(m.state.play_type, "FG", "FG tag")
	m.apply({"type": "call", "kind": "kickoff", "label": "KICKOFF", "elapsed": 310.0, "us": 3, "them": 0})
	eq(m.state.info_text(), "KICKOFF", "kickoff in the info bar")
	eq(FieldState.abs_to_own("home", m.state.ball), 40.0, "kicking from your 40 (high school)")


func test_icing_timeout_and_halftime_reset() -> void:
	var m := _model(true)
	m.apply(_play("drive_start_us", {"spot": 40}))
	m.apply({"type": "call", "kind": "fg", "yards": 38, "label": "0:04 - DOWN 2 - GAME WINNER", "elapsed": 2870.0,
		"us": 14, "them": 16})
	eq(m.state.timeouts["away"], 2, "the defense ices the kicker")
	eq(m.state.play_type, "TIMEOUT", "timeout shown")
	m.apply(_play("half"))
	eq(m.state.timeouts, {"home": 3, "away": 3}, "three each again at halftime")


func test_late_timeout_only_when_trailing() -> void:
	var m := _model(true)
	m.apply(_play("drive_start_them", {"spot": 30}))
	# 1:00 left in the 2nd quarter; they (away) lead 7-0 -> no timeout.
	m.apply(_play("gain_them", {"yards": 5}, "", {"elapsed": 1380.0, "us": 0, "them": 7}))
	eq(m.state.timeouts["away"], 3, "leading team keeps its timeouts")
	m.apply(_play("gain_them", {"yards": 5}, "", {"elapsed": 1390.0, "us": 7, "them": 0}))
	eq(m.state.timeouts["away"], 2, "trailing team uses one late in the half")


# --- whole games ------------------------------------------------------------------------

func _sim(seed_n: int) -> GameSim:
	var c := CareerData.create("Field Test", CareerTuning.get_default())
	c.team = Progression.team_from(TeamDatabase.high_schools()[seed_n % 4], CareerData.STAGE_HIGH_SCHOOL)
	var mgr := CareerManager.new(c)
	mgr.rng.seed = seed_n
	mgr._start_season(false)
	if mgr.is_bye():
		c.week += 1
	return mgr.new_game_sim(load(KT))


func test_whole_games_stay_on_the_field() -> void:
	for seed_n in [1, 2, 3]:
		var sim := _sim(seed_n)
		var m := FieldModel.new()
		m.setup(sim.us, sim.them, sim.home, sim.quarter_seconds(), 45.0, 50.0)
		var sides := {}
		for i in 3000:
			var e := sim.next()
			m.apply(e)
			var s := m.state
			check(s.ball >= 0.0 and s.ball <= 100.0, "seed %d: ball on the field (%.1f)" % [seed_n, s.ball])
			check(s.down >= 0 and s.down <= 4, "seed %d: down 0-4" % seed_n)
			check(s.timeouts["home"] >= 0 and s.timeouts["away"] >= 0, "timeouts never negative")
			if s.possession != "":
				sides[s.possession] = true
			match str(e.get("type", "")):
				"end":
					break
				"call":
					sim.resolve_call({"made": i % 3 != 0, "quality": 0.7, "carry": 60.0, "recovered": false})
				"warmup":
					sim.set_warmup("pure")
		check(sides.has("home") and sides.has("away"), "seed %d: both teams had the ball" % seed_n)


func test_field_model_does_not_change_the_game() -> void:
	# The same seeded game with and without the field model: same lines, same score.
	var out := []
	for with_model in [false, true]:
		var sim := _sim(7)
		var m := FieldModel.new()
		m.setup(sim.us, sim.them, sim.home, sim.quarter_seconds(), 45.0, 50.0)
		var lines := PackedStringArray()
		for i in 3000:
			var e := sim.next()
			if with_model:
				m.apply(e)
			lines.append(str(e.get("text", e.get("kind", ""))))
			match str(e.get("type", "")):
				"end":
					break
				"call":
					sim.resolve_call({"made": true, "quality": 0.7, "carry": 60.0, "recovered": false})
				"warmup":
					sim.set_warmup("loose")
		out.append([lines, sim.score_us, sim.score_them])
	eq(out[0], out[1], "same game with the field tracker on")


func test_field_goal_after_long_drive_shows_a_believable_down() -> void:
	var m := _model(true)
	m.apply(_play("drive_start_us", {"spot": 31}))
	m.apply(_play("gain_us", {"yards": 9}))
	m.apply({"type": "call", "kind": "fg", "yards": 24, "label": "", "elapsed": 900.0, "us": 0, "them": 0})
	eq(m.state.down_text(), "4th & Goal", "kick from the 7: goal to go")
	m.apply(_play("drive_start_us", {"spot": 31}))
	m.apply(_play("gain_us", {"yards": 9}))
	m.apply({"type": "call", "kind": "fg", "yards": 44, "label": "", "elapsed": 900.0, "us": 0, "them": 0})
	check(m.state.to_go >= 2 and m.state.to_go <= 8, "4th & short (%d)" % m.state.to_go)
	check((m.state.first_down - m.state.ball) * FieldState.attack_dir("home") > 0.0, "first-down line ahead of the ball")
