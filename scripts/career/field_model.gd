class_name FieldModel
extends RefCounted
## A light field picture for the game sim (which plays out drives, not single
## plays): reads GameSim's events in order and keeps a FieldState up to date.
## Ball spot, drive start, down & distance, first-down line, timeouts and the
## last play. Display only: it never feeds back into the sim, so scores and
## results stay exactly the sim's.
##
## Where the numbers come from:
##   drive start  the sim's spot ("take over at their own 27")
##   gains        the sim's yards; past the first-down line = new 1st & 10
##   in range     the warmup event's "opponent 32"
##   field goal   your kick's distance: line of scrimmage = distance - 17, 4th down
##   extra point  the PAT distance - 17 (the 3-yard line in high school)
##   kickoff      from your kickoff spot; the receiving team's start = the
##                kick's start_spot, else the next drive's spot
##   TD / punt / turnover / their field goals  from the sim's lines
## Timeouts: 3 per team per half. The defense uses one to ice your clutch kick
## (GAME WINNER / TO TIE) and a trailing offense uses them in the last two
## minutes of a half. Nothing here touches the sim's random numbers.

var state := FieldState.new()
var _quarter_sec := 720.0
var _kickoff_spot := 35
var _pat_yards := 20
## Their typical make-able field goal (their range on the field).
var _their_range := 50.0


## us / them: team dictionaries. us_range: your field goal range (yards).
func setup(us: Dictionary, them: Dictionary, us_home: bool, quarter_sec: float, us_range: float,
		their_range: float, kickoff_spot := 35, pat_yards := 20) -> void:
	_quarter_sec = quarter_sec
	_kickoff_spot = kickoff_spot
	_pat_yards = pat_yards
	_their_range = their_range
	state.us_side = "home" if us_home else "away"
	var u := _side(us)
	var t := _side(them)
	state.home = u if us_home else t
	state.away = t if us_home else u
	state.fg_range = {state.us_side: us_range, FieldState.other(state.us_side): their_range}
	state.emit_changed()


static func _side(team: Dictionary) -> Dictionary:
	var cols: Array = team.get("colors", [])
	var n := str(team.get("mascot", ""))
	if n == "":
		n = str(team.get("town", team.get("name", "")))
	return {"abbr": ScoreBugState.abbreviation(team), "name": n if n != "" else ScoreBugState.abbreviation(team),
		"color": Color.from_string(str(cols[0]), Color.DIM_GRAY) if cols.size() > 0 else Color.DIM_GRAY,
		"color2": Color.from_string(str(cols[1]), Color.WHITE) if cols.size() > 1 else Color.WHITE}


func _who(us_or_them: String) -> String:
	return state.us_side if us_or_them == "us" else FieldState.other(state.us_side)


## One GameSim event (play / call / warmup / end).
func apply(e: Dictionary) -> void:
	var s := state
	match str(e.get("type", "")):
		"call":
			_call(e)
		"warmup":
			# Your offense is in range: "opponent 32".
			var spot := str(e.get("spot", "")).get_slice(" ", 1).to_int()
			if spot > 0:
				var side := _who("us")
				_set_possession(side, false)
				s.move_ball(FieldState.own_to_abs(side, 100 - spot))
				_first_down(side)
		"play":
			_play(e)
		"end":
			s.possession = ""
			s.kick = {}
			s.down = 0
	s.emit_changed()


func _play(e: Dictionary) -> void:
	var s := state
	var key := str(e.get("key", ""))
	var v: Dictionary = e.get("vars", {})
	var text := str(e.get("text", ""))
	var type := ""
	match key:
		"drive_start_us", "drive_start_them":
			var side := _who("us" if key.ends_with("_us") else "them")
			_set_possession(side, true)
			s.move_ball(FieldState.own_to_abs(side, float(v.get("spot", 25))))
			s.drive_start = s.ball
			_first_down(side)
		"gain_us", "gain_them":
			var side := _who("us" if key.ends_with("_us") else "them")
			_set_possession(side, false)
			_gain(side, int(v.get("yards", 0)))
			type = "PASS" if _is_pass(text) else "RUSH"
			_late_timeout(e, side)
		"td_us", "td_them":
			var side := _who("us" if key.ends_with("_us") else "them")
			_set_possession(side, false)
			s.move_ball(FieldState.goal_of(side))
			s.down = 0
			type = "TD"
		"punt_us", "punt_them", "coach_no_trust":
			var side := _who("them" if key == "punt_them" else "us")
			_set_possession(side, false)
			s.down = 4
			s.kick = {}
			type = "PUNT"
		"turnover_us", "turnover_them":
			# The other team takes over where the ball is.
			var lost := _who("us" if key == "turnover_us" else "them")
			_set_possession(FieldState.other(lost), true)
			s.drive_start = s.ball
			_first_down(s.possession)
			type = "TURNOVER"
		"fg_them_good", "fg_them_miss":
			var side := _who("them")
			_set_possession(side, false)
			# Their kick: from where the drive stalled, at least inside their range.
			var d := minf(FieldState.to_goal(side, s.ball), maxf(_their_range - 17.0 - 5.0, 10.0))
			s.move_ball(FieldState.goal_of(side) - FieldState.attack_dir(side) * d)
			s.down = 4
			type = "FG"
		"pat_them_miss":
			type = "XP"
		"fg_us_good", "fg_us_miss", "fg_backup":
			type = "FG"
			if key != "fg_backup":
				s.kick = {}
		"pat_us_good", "pat_us_miss":
			type = "XP"
			s.kick = {}
		"kickoff_result":
			type = "KICKOFF"
			s.kick = {}
			var recv := _who("them")
			_set_possession(recv, true)
			var spot := int(v.get("spot", 0))
			if spot > 0:
				s.move_ball(FieldState.own_to_abs(recv, spot))
			s.down = 0
		"onside_recovered", "onside_lost":
			type = "KICKOFF"
			s.kick = {}
			_set_possession(_who("us" if key == "onside_recovered" else "them"), true)
			s.down = 0
		"half":
			s.possession = ""
			s.kick = {}
			s.down = 0
			s.drive_start = -1.0
			s.timeouts = {"home": 3, "away": 3}
			s.move_ball(50.0)
		"final":
			s.possession = ""
			s.kick = {}
			s.down = 0
		"kickoff_start":
			s.possession = ""
			s.down = 0
			s.move_ball(50.0)
	if text != "":
		s.play_text = text
		s.play_type = type


## Your kick (the coach's call).
func _call(e: Dictionary) -> void:
	var s := state
	var side := _who("us")
	var kind := str(e.get("kind", ""))
	_set_possession(side, false)
	match kind:
		"fg":
			var yards := int(e.get("yards", 0))
			var dir := FieldState.attack_dir(side)
			s.move_ball(FieldState.goal_of(side) - dir * clampf(yards - 17.0, 1.0, 99.0))
			var short_of := s.first_down >= 0.0 and (s.first_down - s.ball) * dir > 0.0
			if short_of and absf(s.first_down - s.ball) <= 10.0:
				s.to_go = maxi(roundi(absf(s.first_down - s.ball)), 1)
			else:
				# The drive moved the chains on the way here: the last set of
				# downs stalled a few yards short (goal to go inside the 10).
				_first_down(side)
				if s.first_down >= 0.0:
					s.to_go = 2 + yards % 7
					s.first_down = s.ball + dir * s.to_go
			s.down = 4
			s.kick = {"kind": "fg", "yards": yards}
			# Icing: the defense calls time before a clutch kick.
			var lbl := str(e.get("label", ""))
			if "GAME WINNER" in lbl or "TO TIE" in lbl:
				var d := FieldState.other(side)
				if int(s.timeouts.get(d, 0)) > 0:
					s.timeouts[d] -= 1
					s.play_text = "Timeout %s, trying to ice the kicker." % s.team(d)["abbr"]
					s.play_type = "TIMEOUT"
		"pat":
			var yards := int(e.get("yards", _pat_yards))
			s.move_ball(FieldState.goal_of(side) - FieldState.attack_dir(side) * clampf(yards - 17.0, 1.0, 10.0))
			s.down = 0
			s.first_down = -1.0
			s.kick = {"kind": "pat", "yards": yards}
		"kickoff", "onside":
			s.move_ball(FieldState.own_to_abs(side, _kickoff_spot))
			s.down = 0
			s.first_down = -1.0
			s.drive_start = -1.0
			s.kick = {"kind": kind, "yards": 0}


## A new team with the ball (or new_drive) starts the drive bar at the ball.
func _set_possession(side: String, new_drive: bool) -> void:
	var s := state
	if side != s.possession or new_drive:
		s.drive_start = s.ball
	s.possession = side


## 1st & 10 from the ball (or 1st & Goal inside the 10).
func _first_down(side: String) -> void:
	var s := state
	s.down = 1
	if FieldState.to_goal(side, s.ball) <= 10.0:
		s.first_down = -1.0
		s.to_go = roundi(FieldState.to_goal(side, s.ball))
	else:
		s.first_down = s.ball + FieldState.attack_dir(side) * 10.0
		s.to_go = 10


func _gain(side: String, yards: int) -> void:
	var s := state
	var dir := FieldState.attack_dir(side)
	# Stop at the 1-yard line: touchdowns come from the sim's own line.
	var room := FieldState.to_goal(side, s.ball) - 1.0
	var g := clampf(float(yards), 0.0, maxf(room, 0.0))
	s.move_ball(s.ball + dir * g)
	if s.down <= 0:
		_first_down(side)
		return
	var past := s.first_down >= 0.0 and (s.ball - s.first_down) * dir >= 0.0
	if past:
		_first_down(side)
	else:
		s.down = mini(s.down + 1, 4)
		s.to_go = maxi(roundi(absf(s.first_down - s.ball)) if s.first_down >= 0.0
			else roundi(FieldState.to_goal(side, s.ball)), 1)


## A trailing offense stops the clock in the last two minutes of a half.
func _late_timeout(e: Dictionary, side: String) -> void:
	var s := state
	var t := float(e.get("elapsed", 0.0))
	var half_end := _quarter_sec * (2.0 if t < _quarter_sec * 2.0 else 4.0)
	if half_end - t > 120.0 or int(s.timeouts.get(side, 0)) <= 0:
		return
	var us_score := int(e.get("us", 0))
	var them_score := int(e.get("them", 0))
	var trailing := (them_score > us_score) if side == s.us_side else (us_score > them_score)
	if trailing:
		s.timeouts[side] -= 1


static func _is_pass(text: String) -> bool:
	var t := text.to_lower()
	for w in ["pass", "catch", "throw", "hits ", "complete", "grab"]:
		if w in t:
			return true
	return false
