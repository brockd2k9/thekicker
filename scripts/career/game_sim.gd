class_name GameSim
extends RefCounted
## One career game, simulated drive by drive while you watch from the bench.
## The screen pulls events with next():
##   {"type": "play", "text", "elapsed", "poss", "key", "vars"}  play-by-play
##       line ("poss": who has the ball; "key"/"vars": the play line's key and
##       numbers, e.g. "gain_us" {"yards": 12}, for the field tracker)
##   {"type": "warmup", "spot", "elapsed"}     offense in range: warm up on the net?
##   {"type": "call", "kind": "fg"/"pat"/"kickoff"/"onside", "yards",
##    "pressure", "label", "wind", "gust", "elapsed"}  coach sends you in
##   {"type": "end"}
## After a "call" the screen MUST report the kick with resolve_call() before
## asking for more; the score, pressure and the rest of the game react to it.
## After a "warmup" it reports set_warmup("pure"/"loose"/"skipped").
## Same seed = same game script up to the first different kick result, so a
## quit-and-restart replays the same opponent flow.
## All odds and pressure numbers are in CareerTuning ("Game Sim").

var us: Dictionary
var them: Dictionary
var home: bool = true
var score_us: int = 0
var score_them: int = 0
var finished: bool = false
## Seconds since kickoff.
var elapsed: float = 0.0
## Who has the ball: "us" / "them" / "" (halftime, game over). Display only
## (score bug); every event carries it as "poss".
var possession: String = ""
## Field goals / extra points missed in a row this game (feeds the profile).
var miss_streak: int = 0
## Game-day modifier from this half's sideline warmup (or "cold_leg" if you
## skipped it). Lasts until halftime; offered at most once per half.
var warm_modifier: String = ""
var _warmup_offered_this_half := false
## Everything you kicked: {kind, yards, made, result, pressure, label, us, them
## (score before the kick), q, left (seconds left in the game), backup}.
var kicks: Array = []
## True when the backup kicks for you (you sat out): KickTrust skips these.
var backup: bool = false
## Benched (Bench): the backup kicks the field goals (resolved here, never
## called to the player) with this make chance; extra points and kickoffs are
## still yours. No warmup offers (you aren't kicking field goals).
var backup_fg: bool = false
var backup_name: String = "The backup"
var backup_make: float = 0.7
## "pure" / "loose" / "skipped", one per warmup offer.
var warmups: Array = []
## Overtime (a tie after four quarters; rules by stage, params "ot"):
## {rule: hs/college/pro, round, order: [first, second], idx (possessions
## this round), start_us, start_them (scores at the round's start), clock
## (pro seconds left), poss (pro possessions), two_point, done}. Empty = none.
var ot: Dictionary = {}

var _t: CareerTuning
var _rng := RandomNumberGenerator.new()
var _max_fg_yards: int = 60
## Coach doubt (KickTrust): field goal drives happen this much as often.
var _fg_chance_mult: float = 1.0
var _wind_base: float = 0.0
var _gusty: bool = false
var _queue: Array = []
var _drives: Array = []  # "us" / "them", in order
var _drive_i: int = 0
var _we_kick_first: bool = true
var _waiting: Dictionary = {}
var _opp_td_bonus: float = 0.0
## Where the opponent starts after your kickoff (its start_spot); 0 = random.
var _their_next_start: int = 0
var _names: Array = []
var _p: Dictionary = {}

const HALFTIME := "_half"


## week_entry: a schedule entry (opponent, home, weather). max_fg_yards: the
## longest kick the coach will try (from your profile's range). params: this
## stage's game parameters (Progression.game_params: fg_min, fg_max, pat,
## pressure_bonus); defaults to high school.
func setup(c: CareerData, week_entry: Dictionary, tuning: CareerTuning, seed: int,
		max_fg_yards: int, params: Dictionary = {}) -> void:
	_t = tuning
	_p = {"fg_min": tuning.hs_fg_min_yards, "fg_max": tuning.hs_fg_max_yards,
		"pat": tuning.hs_pat_yards, "pressure_bonus": 0.0}
	_p.merge(params, true)
	_rng.seed = seed
	us = c.team
	them = week_entry.get("opponent", {})
	home = bool(week_entry.get("home", true))
	_max_fg_yards = max_fg_yards
	_fg_chance_mult = tuning.doubt_fg_chance_mult if not c.coach_doubt.is_empty() else 1.0
	var weather: Dictionary = week_entry.get("weather", {})
	_wind_base = float(weather.get("wind", 0.0))
	_gusty = bool(weather.get("gusty", false))
	_names = _teammate_names()
	_we_kick_first = _rng.randf() < 0.5
	for half in 2:
		if half == 1:
			_drives.append(HALFTIME)
		var first := "them" if (_we_kick_first == (half == 0)) else "us"
		var second := "us" if first == "them" else "them"
		for i in _t.drives_per_half:
			_drives.append(first)
			_drives.append(second)
	_line("kickoff_start")
	if _we_kick_first:
		_push_call("kickoff")


## Length of a quarter in game seconds (score bug clock).
func quarter_seconds() -> float:
	return _quarter_sec()


func quarter() -> int:
	return mini(int(elapsed / _quarter_sec()) + 1, 4)


func in_overtime() -> bool:
	return not ot.is_empty()


## "Q3 6:21" for a game time (default: now).
func clock_text(at: float = -1.0) -> String:
	if in_overtime() and at < 0.0:
		if str(ot["rule"]) == "pro":
			var c := maxf(float(ot.get("clock", 0.0)), 0.0)
			return "OT %d:%02d" % [int(c) / 60, int(c) % 60]
		return "OT" if int(ot.get("round", 1)) == 1 else "%dOT" % int(ot["round"])
	var t := elapsed if at < 0.0 else at
	var q := mini(int(t / _quarter_sec()) + 1, 4)
	var left := maxf(_quarter_sec() * q - t, 0.0)
	return "Q%d %d:%02d" % [q, int(left) / 60, int(left) % 60]


func next() -> Dictionary:
	if not _waiting.is_empty():
		push_warning("GameSim: next() while waiting for resolve_call()")
		return {"type": "wait"}
	while _queue.is_empty():
		if finished:
			return {"type": "end"}
		_simulate_drive()
	var e: Dictionary = _queue.pop_front()
	if e["type"] == "call":
		_waiting = e
	return e


## result: fg/pat {"made": bool}; kickoff {"quality": 0..1, "carry", "text",
## optional "start_spot" (their next drive's yard line, shown in the play-by-play)};
## onside {"recovered": bool, "text"}.
func resolve_call(result: Dictionary) -> void:
	var call := _waiting
	_waiting = {}
	if call.is_empty():
		return
	var kind: String = call["kind"]
	var entry := {"kind": kind, "yards": int(call.get("yards", 0)),
		"pressure": float(call.get("pressure", 0.0)), "label": str(call.get("label", "")),
		"us": int(call.get("us", 0)), "them": int(call.get("them", 0)), "q": int(call.get("q", 1)),
		"left": float(call.get("left", 0.0))}
	if backup or (kind == "fg" and backup_fg):
		entry["backup"] = true
	match kind:
		"fg", "pat":
			var made := bool(result.get("made", false))
			entry["made"] = made
			# Was the swipe straight? (KickNerves: only straight makes get you out of a slump.)
			entry["straight"] = bool(result.get("straight", true))
			entry["result"] = "GOOD" if made else "NO GOOD"
			miss_streak = 0 if made else miss_streak + 1
			if made:
				if kind == "fg":
					score_us += 3
				else:
					score_us += 1
			_line(("%s_us_good" if made else "%s_us_miss") % kind, {"yards": entry["yards"]})
			if (kind == "pat" or made) and not in_overtime():
				_push_kickoff_after_score()
		"kickoff":
			var q := clampf(float(result.get("quality", 0.5)), 0.0, 1.0)
			entry["quality"] = q
			entry["carry"] = float(result.get("carry", 0.0))
			entry["result"] = str(result.get("text", ""))
			_opp_td_bonus = _t.kickoff_quality_effect * (1.0 - q)
			_their_next_start = int(result.get("start_spot", 0))
			if result.has("result"):
				entry["outcome"] = str(result["result"])
			_text(entry["result"], "kickoff_result", {"spot": _their_next_start})
		"onside":
			var rec := bool(result.get("recovered", false))
			entry["recovered"] = rec
			entry["result"] = str(result.get("text", ""))
			_text(entry["result"])
			_line("onside_recovered" if rec else "onside_lost")
			if rec:
				_drives.insert(_drive_i, "us")  # an extra possession, right now
	kicks.append(entry)


## The player's answer to a "warmup" event.
func set_warmup(result: String) -> void:
	warmups.append(result)
	var r: Dictionary = CareerContent.game_day().get("warmup", {}).get("results", {}).get(result, {})
	warm_modifier = str(r.get("modifier", ""))
	if r.has("text"):
		_text(str(r["text"]))


func outcome() -> String:
	if score_us > score_them:
		return "W"
	if score_us < score_them:
		return "L"
	return "T"


func summary() -> Dictionary:
	var out := {"us": score_us, "them": score_them, "outcome": outcome(),
		"kicks": kicks.duplicate(true), "warmups": warmups.duplicate()}
	if in_overtime():
		out["ot"] = {"rule": str(ot["rule"]), "rounds": int(ot.get("round", 1)),
			"two_point": bool(ot.get("two_point", false))}
	return out


# --- simulation --------------------------------------------------------------------

func _simulate_drive() -> void:
	if _drive_i >= _drives.size():
		# Tied after four quarters: overtime (once), then the final whistle.
		if ot.is_empty() and score_us == score_them:
			_start_overtime()
			return
		if in_overtime() and not bool(ot.get("done", false)):
			_ot_step()
			return
		finished = true
		possession = ""
		_line("final")
		return
	var team: String = _drives[_drive_i]
	if team == HALFTIME:
		_drive_i += 1
		elapsed = maxf(elapsed, _quarter_sec() * 2.0)
		warm_modifier = ""
		_warmup_offered_this_half = false
		possession = ""
		_line("half")
		if not _we_kick_first:
			_push_call("kickoff")
		return
	var dur := _drive_duration()
	_drive_i += 1
	possession = team
	var start := elapsed
	if team == "us":
		_our_drive(start, dur)
	else:
		_their_drive(start, dur)
	elapsed = start + dur


## Splits the time left in the half fairly over the drives left in it.
func _drive_duration() -> float:
	var half_idx := _drives.find(HALFTIME)
	var in_first := half_idx > _drive_i
	var half_end := _quarter_sec() * (2.0 if in_first else 4.0)
	var stop := half_idx if in_first else _drives.size()
	var left := maxi(stop - _drive_i, 1)
	var time_left := maxf(half_end - elapsed - 4.0, 1.0)
	if left == 1:
		return time_left
	return time_left / left * _rng.randf_range(0.8, 1.15)


func _our_drive(start: float, dur: float) -> void:
	var adv := (float(us.get("strength", 50)) - float(them.get("strength", 50))) / 100.0 * _t.strength_effect
	var td := clampf(_t.base_td_chance + adv, 0.05, 0.75)
	var fg := clampf(_t.base_fg_chance + adv * 0.3, 0.05, 0.5) * _fg_chance_mult
	var roll := _rng.randf()
	var spot := _rng.randi_range(15, 40)
	elapsed = start
	_line("drive_start_us", {"spot": spot})
	elapsed = start + dur * 0.3
	_line("gain_us", {"yards": _rng.randi_range(6, 22)})
	if roll < td + fg:
		# Driving into range: the coach tells you to get loose.
		elapsed = start + dur * 0.55
		if not _warmup_offered_this_half and not backup_fg:
			_warmup_offered_this_half = true
			_queue.append({"type": "warmup", "spot": "opponent %d" % _rng.randi_range(25, 40),
				"elapsed": elapsed, "us": score_us, "them": score_them, "poss": possession})
		elapsed = start + dur * 0.85
		if roll < td:
			_line("gain_us", {"yards": _rng.randi_range(4, 15)})
			elapsed = start + dur * 0.95
			score_us += 6
			_line("td_us", {"yards": _rng.randi_range(1, 25)})
			_push_call("pat")
		else:
			var yards := _fg_distance()
			# The coach's limit moves +/- call_random_yd per chance, never past
			# your range (call_cap_yd); both optional (career games set them).
			var limit := _max_fg_yards
			var r := int(_p.get("call_random_yd", 0))
			if r > 0:
				limit = mini(limit + _rng.randi_range(-r, r), int(_p.get("call_cap_yd", limit + r)))
			if yards > limit:
				_line("coach_no_trust", {"yards": yards})
			else:
				_push_call("fg", yards)
	elif _rng.randf() < 0.3:
		elapsed = start + dur * 0.8
		_line("turnover_us")
	else:
		elapsed = start + dur * 0.8
		_line("punt_us")


func _their_drive(start: float, dur: float) -> void:
	var adv := (float(them.get("strength", 50)) - float(us.get("strength", 50))) / 100.0 * _t.strength_effect
	var td := clampf(_t.base_td_chance + adv + _opp_td_bonus, 0.05, 0.8)
	var fg := clampf(_t.base_fg_chance + adv * 0.3, 0.05, 0.5)
	_opp_td_bonus = 0.0
	var roll := _rng.randf()
	elapsed = start
	# Same random roll as always (keeps the game script stable), then the
	# kickoff's real field position if there was one.
	var spot := _rng.randi_range(15, 40)
	if _their_next_start > 0:
		spot = _their_next_start
		_their_next_start = 0
	_line("drive_start_them", {"spot": spot})
	elapsed = start + dur * 0.5
	_line("gain_them", {"yards": _rng.randi_range(5, 25)})
	elapsed = start + dur * 0.9
	if roll < td:
		var pat_good := _rng.randf() < _t.opponent_pat_chance
		score_them += 7 if pat_good else 6
		_line("td_them")
		if not pat_good:
			_line("pat_them_miss")
	elif roll < td + fg:
		if _rng.randf() < _t.opponent_fg_chance:
			score_them += 3
			_line("fg_them_good")
		else:
			_line("fg_them_miss")
	elif _rng.randf() < 0.3:
		_line("turnover_them", {"player": _name()})
	else:
		_line("punt_them")


func _fg_distance() -> int:
	# Two rolls averaged: mid-range kicks are most common.
	var a := _rng.randi_range(int(_p["fg_min"]), int(_p["fg_max"]))
	var b := _rng.randi_range(int(_p["fg_min"]), int(_p["fg_max"]))
	return roundi((a + b) * 0.5)


func _push_kickoff_after_score() -> void:
	var diff := score_us - score_them
	var left := _quarter_sec() * 4.0 - elapsed
	if quarter() == 4 and diff < 0 and left <= _t.onside_clock_sec:
		_push_call("onside")
	else:
		_push_call("kickoff")


## over: {"pressure", "label"} for overtime kicks (else the situation's).
func _push_call(kind: String, yards: int = 0, over: Dictionary = {}) -> void:
	# Your kick: your team is on the field.
	var e := {"type": "call", "kind": kind, "elapsed": elapsed, "us": score_us, "them": score_them, "poss": "us",
		"q": quarter(), "left": maxf(_quarter_sec() * 4.0 - elapsed, 0.0)}
	if kind == "pat":
		yards = int(_p["pat"])
	e["yards"] = yards
	if kind == "fg" or kind == "pat":
		var p := _situation_pressure(kind) if over.is_empty() else over
		e["pressure"] = p["pressure"]
		e["label"] = p["label"]
		e["wind"] = _kick_wind()
		e["gust"] = _rng.randf_range(2.0, 7.0) if _gusty and absf(e["wind"]) > 0.5 else 0.0
	else:
		e["pressure"] = 0.0
		e["label"] = kind.to_upper()
		e["wind"] = _kick_wind()
		e["gust"] = 0.0
	if kind == "fg" and backup_fg:
		_text("%s jogs on for the field goal." % backup_name, "fg_backup", {"yards": yards})
		_waiting = e
		resolve_call({"made": _rng.randf() < backup_make})
		return
	_queue.append(e)


func _situation_pressure(kind: String) -> Dictionary:
	var q := quarter()
	var diff := score_us - score_them  # before this kick
	var left := _quarter_sec() * 4.0 - elapsed
	var pts := 3 if kind == "fg" else 1
	var p := float(_t.quarter_pressure[clampi(q - 1, 0, _t.quarter_pressure.size() - 1)]) \
		+ float(_p["pressure_bonus"])
	var tag := ""
	if q == 4 and absi(diff) <= 8:
		# Fans are watching (Followers.fan_pressure, via params): close 4th
		# quarters. (Game winners are already at full pressure.)
		p += _t.close_game_pressure + float(_p.get("fan_pressure", 0.0))
	if q == 4 and left <= 120.0 and diff < 0 and diff + pts >= 0:
		p = _t.game_winner_pressure
		tag = "GAME WINNER" if diff + pts > 0 else "TO TIE"
	elif kind == "pat":
		p *= _t.pat_pressure_scale
	var score := "UP %d" % diff if diff > 0 else ("DOWN %d" % -diff if diff < 0 else "TIED")
	var label := "%s - %s" % [clock_text(), score]
	if tag != "":
		label += " - " + tag
	return {"pressure": clampf(p, 0.0, 1.0), "label": label}


func _kick_wind() -> float:
	var w := _wind_base + _rng.randf_range(-_t.kick_wind_jitter_mph, _t.kick_wind_jitter_mph)
	if absf(_wind_base) < 0.5 and absf(w) < 2.0:
		return 0.0
	return roundf(w)


func _quarter_sec() -> float:
	return _t.quarter_minutes * 60.0


# --- text --------------------------------------------------------------------------

func _line(key: String, extra: Dictionary = {}) -> void:
	var vars := {"us": us.get("mascot", us.get("name", "Us")),
		"them": them.get("mascot", them.get("name", "Them")),
		"us_score": score_us, "them_score": score_them, "player": _name()}
	vars.merge(extra, true)
	var t := CareerContent.play_line(key, vars, _rng)
	if t != "":
		_text(t, key, extra)


## A play-by-play line. key / vars (the play line's key and its numbers, e.g.
## "gain_us" {"yards": 12}) are for the field tracker (FieldModel); display only.
func _text(t: String, key := "", vars: Dictionary = {}) -> void:
	var e := {"type": "play", "text": t, "elapsed": elapsed, "us": score_us, "them": score_them,
		"poss": possession}
	if key != "":
		e["key"] = key
		e["vars"] = vars.duplicate()
	_queue.append(e)


func _name() -> String:
	return str(_names[_rng.randi_range(0, _names.size() - 1)]) if not _names.is_empty() else "the back"


func _teammate_names() -> Array:
	var n: Dictionary = CareerContent.world().get("names", {})
	var first: Array = n.get("first", ["Sam"])
	var last: Array = n.get("last", ["Smith"])
	var out: Array = []
	for i in 6:
		out.append("%s %s" % [first[_rng.randi_range(0, first.size() - 1)],
			last[_rng.randi_range(0, last.size() - 1)]])
	return out


# --- overtime ---------------------------------------------------------------------

func _start_overtime() -> void:
	var rule := str(_p.get("ot", "hs"))
	var first := "us" if _rng.randf() < 0.5 else "them"
	ot = {"rule": rule, "round": 1, "order": [first, "them" if first == "us" else "us"], "idx": 0,
		"start_us": score_us, "start_them": score_them, "two_point": false, "done": false,
		"clock": _t.ot_pro_minutes * 60.0, "poss": 0}
	possession = ""
	elapsed = maxf(elapsed, _quarter_sec() * 4.0)
	match rule:
		"pro":
			_text("Tied after four quarters: OVERTIME. One %d-minute period. Both teams get the ball unless the first scores a touchdown, then the next score wins." % roundi(_t.ot_pro_minutes))
		"college":
			_text("Tied after four quarters: OVERTIME. Each team gets the ball at the 25. From the third overtime, two-point tries only.")
		_:
			_text("Tied after four quarters: OVERTIME. Each team gets the ball at the 10, until one leads after both have had it.")
	_text("The %s win the toss and take the ball first." % _team_word(first))


func _team_word(team: String) -> String:
	var t: Dictionary = us if team == "us" else them
	return str(t.get("mascot", t.get("name", team)))


## One overtime possession (or the end of overtime).
func _ot_step() -> void:
	if str(ot["rule"]) == "pro":
		_ot_pro_step()
	else:
		_ot_round_step()


## High school / college: rounds of one possession each.
func _ot_round_step() -> void:
	var rule := str(ot["rule"])
	if int(ot["idx"]) >= 2:
		# Both teams have had the ball this round.
		if score_us != score_them:
			_ot_end()
			return
		var max_rounds := _t.ot_hs_rounds if rule == "hs" else 99
		if int(ot["round"]) >= max_rounds:
			_ot_end()  # high school: still tied after the last round
			return
		ot["round"] = int(ot["round"]) + 1
		ot["idx"] = 0
		ot["order"] = [ot["order"][1], ot["order"][0]]
		ot["start_us"] = score_us
		ot["start_them"] = score_them
		if rule == "college" and int(ot["round"]) >= 3 and not ot["two_point"]:
			ot["two_point"] = true
			_text("Still tied. From the third overtime it's two-point tries only: no kicks. You watch from the sideline.")
		else:
			_text("Still tied: overtime round %d." % int(ot["round"]))
	var team: String = ot["order"][int(ot["idx"])]
	var second := int(ot["idx"]) == 1
	ot["idx"] = int(ot["idx"]) + 1
	possession = team
	if bool(ot["two_point"]):
		var good := _rng.randf() < _t.ot_two_point_chance
		if team == "us":
			score_us += 2 if good else 0
		else:
			score_them += 2 if good else 0
		_text("Two-point try by the %s: %s. %d-%d." % [_team_word(team), "GOOD" if good else "no good", score_us, score_them])
		return
	var spot := 10 if rule == "hs" else 25
	var fg_yards := _t.ot_hs_fg_yards if rule == "hs" else _t.ot_college_fg_yards
	var td_base := _t.ot_hs_td_chance if rule == "hs" else _t.ot_college_td_chance
	# Points this team needs this round: behind by what the other team scored.
	var mine := (score_us - int(ot["start_us"])) if team == "us" else (score_them - int(ot["start_them"]))
	var theirs := (score_them - int(ot["start_them"])) if team == "us" else (score_us - int(ot["start_us"]))
	var need := theirs - mine if second else -1  # -1: going first
	_text("The %s start at the %d." % [_team_word(team), spot])
	var adv := ((float(us.get("strength", 50)) - float(them.get("strength", 50))) / 100.0 * _t.strength_effect) \
		* (1.0 if team == "us" else -1.0)
	var td := clampf(td_base + adv, 0.1, 0.8)
	var roll := _rng.randf()
	if roll < td:
		if team == "us":
			score_us += 6
			_line("td_us", {"yards": _rng.randi_range(1, spot)})
			if second and score_us > score_them:
				return  # a touchdown going second wins it: no extra point needed
			_push_call("pat", 0, {"pressure": _t.ot_pressure, "label": "%s - PAT" % clock_text()})
		else:
			var pat_good := _rng.randf() < _t.opponent_pat_chance
			score_them += 7 if pat_good else 6
			_line("td_them")
		return
	# No touchdown: a field goal if it helps (behind by more than 3 going
	# second, only a touchdown would do).
	if need > 3 or _rng.randf() > _t.ot_fg_range_chance:
		_text("The %s can't get it done." % _team_word(team))
		return
	if team == "us":
		var wins := second and need == 0
		var ties := second and need == 3
		var label := "%s - %s" % [clock_text(), "GAME WINNER" if wins else ("TO TIE" if ties else "FIELD GOAL")]
		_push_call("fg", fg_yards + _rng.randi_range(-2, 2),
			{"pressure": _t.game_winner_pressure if wins else _t.ot_pressure, "label": label})
	else:
		if _rng.randf() < _t.opponent_fg_chance:
			score_them += 3
			_line("fg_them_good")
		else:
			_line("fg_them_miss")


## Pro: one period. Both teams get the ball unless the first scores a
## touchdown; then sudden death; a tie when the clock runs out.
func _ot_pro_step() -> void:
	var n := int(ot["poss"])
	# Over? A first-possession touchdown, a lead after both have had it, any
	# score in sudden death, or no time left.
	if n >= 1 and score_us != score_them:
		var first_td := n == 1 and absi(score_us - score_them) >= 6
		if first_td or n >= 2:
			_ot_end()
			return
	if float(ot["clock"]) <= 0.0:
		_ot_end()
		return
	var team: String = ot["order"][n % 2]
	ot["poss"] = n + 1
	possession = team
	var dur := minf(_rng.randf_range(_t.ot_pro_drive_sec_min, _t.ot_pro_drive_sec_max), float(ot["clock"]))
	ot["clock"] = float(ot["clock"]) - dur
	elapsed += dur
	var adv := ((float(us.get("strength", 50)) - float(them.get("strength", 50))) / 100.0 * _t.strength_effect) \
		* (1.0 if team == "us" else -1.0)
	var td := clampf(_t.base_td_chance + adv, 0.05, 0.75)
	var fg := clampf(_t.base_fg_chance + adv * 0.3, 0.05, 0.5) * (_fg_chance_mult if team == "us" else 1.0)
	var roll := _rng.randf()
	_line("drive_start_us" if team == "us" else "drive_start_them", {"spot": _rng.randi_range(15, 35)})
	if roll < td:
		if team == "us":
			score_us += 6
			_line("td_us", {"yards": _rng.randi_range(1, 25)})
		else:
			score_them += 6
			_line("td_them")
		return  # a touchdown ends it (first possession) or wins it: no extra point
	if roll < td + fg:
		var behind := (score_them - score_us) if team == "us" else (score_us - score_them)
		if team == "us":
			var yards := _fg_distance()
			var limit := _max_fg_yards
			var r := int(_p.get("call_random_yd", 0))
			if r > 0:
				limit = mini(limit + _rng.randi_range(-r, r), int(_p.get("call_cap_yd", limit + r)))
			if yards > limit:
				_line("coach_no_trust", {"yards": yards})
				return
			# Wins if it puts us ahead and the other team has had (or can't get) the ball.
			var wins := behind == 0 and n >= 1
			var ties := behind == 3
			var label := "%s - %s" % [clock_text(), "GAME WINNER" if wins else ("TO TIE" if ties else "FIELD GOAL")]
			_push_call("fg", yards, {"pressure": _t.game_winner_pressure if wins else _t.ot_pressure, "label": label})
		else:
			if _rng.randf() < _t.opponent_fg_chance:
				score_them += 3
				_line("fg_them_good")
			else:
				_line("fg_them_miss")
		return
	_line("punt_us" if team == "us" else "punt_them")


func _ot_end() -> void:
	ot["done"] = true
	possession = ""
	if score_us == score_them:
		_text("Overtime ends tied, %d-%d." % [score_us, score_them])
	else:
		_text("%s win it in %s, %d-%d." % [_team_word("us" if score_us > score_them else "them"),
			"overtime" if str(ot["rule"]) == "pro" or int(ot["round"]) == 1 else "%d overtimes" % int(ot["round"]),
			maxi(score_us, score_them), mini(score_us, score_them)])

