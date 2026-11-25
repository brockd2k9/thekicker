class_name ScoreBugState
extends Resource
## The live numbers behind the score bug (Scoreboard, scenes/ui/scoreboard.tscn):
## both teams, the score, quarter and clock, who has the ball, and your kicking
## line this game. The career game screen owns one and sets it from the game
## sim; every Scoreboard bound to it (the bench screen's and the kick scene's)
## redraws from the signals below. Setters only emit when a value changes, so
## a flash means something really changed. Display only: never saved.

signal score_changed(side: String)  # "away" / "home"
signal clock_changed
signal possession_changed
signal stats_changed

## {abbr, color, color2} for each side. Away is the top row (TV order).
var away: Dictionary = {"abbr": "AWY", "color": Color.DIM_GRAY, "color2": Color.GRAY}
var home: Dictionary = {"abbr": "HOM", "color": Color.DIM_GRAY, "color2": Color.GRAY}
var away_score: int = 0
var home_score: int = 0
var quarter: int = 1
var seconds_left: float = 0.0
var final: bool = false
## "away" / "home" / "" (nobody: halftime, between plays).
var possession: String = ""
## True when your team is the home team.
var we_are_home: bool = true
## Your jersey number, shown on the stats strip.
var number: int = 0
## Your kicking this game: {fg_made, fg_att, pat_made, pat_att, long, points}.
var stats: Dictionary = empty_stats()


static func empty_stats() -> Dictionary:
	return {"fg_made": 0, "fg_att": 0, "pat_made": 0, "pat_att": 0, "long": 0, "points": 0}


## us / them: team dictionaries (CareerData.team / schedule opponent).
func setup(us: Dictionary, them: Dictionary, us_home: bool, jersey := 0) -> void:
	we_are_home = us_home
	number = jersey
	var u := _side(us)
	var t := _side(them)
	home = u if us_home else t
	away = t if us_home else u


static func _side(team: Dictionary) -> Dictionary:
	var cols: Array = team.get("colors", [])
	return {"abbr": abbreviation(team),
		"color": Color.from_string(str(cols[0]), Color.DIM_GRAY) if cols.size() > 0 else Color.DIM_GRAY,
		"color2": Color.from_string(str(cols[1]), Color.GRAY) if cols.size() > 1 else Color.GRAY}


## "us" / "them" -> "home" / "away".
func side_of(who: String) -> String:
	if who != "us" and who != "them":
		return ""
	return "home" if (who == "us") == we_are_home else "away"


func set_score(us_score: int, them_score: int) -> void:
	var h := us_score if we_are_home else them_score
	var a := them_score if we_are_home else us_score
	if a != away_score:
		away_score = a
		score_changed.emit("away")
	if h != home_score:
		home_score = h
		score_changed.emit("home")


## elapsed: game seconds since kickoff; quarter_sec: length of a quarter.
func set_time(elapsed: float, quarter_sec: float, quarters := 4) -> void:
	var qt := time_from(elapsed, quarter_sec, quarters)
	if int(qt[0]) != quarter or not is_equal_approx(float(qt[1]), seconds_left) or final:
		quarter = int(qt[0])
		seconds_left = float(qt[1])
		final = false
		clock_changed.emit()


func set_final() -> void:
	if not final:
		final = true
		seconds_left = 0.0
		clock_changed.emit()


## who: "us" / "them" / "" (GameSim event "poss").
func set_possession(who: String) -> void:
	var s := side_of(who)
	if s != possession:
		possession = s
		possession_changed.emit()


func set_stats(s: Dictionary) -> void:
	var n := empty_stats()
	for k in n:
		n[k] = int(s.get(k, 0))
	if n != stats:
		stats = n
		stats_changed.emit()


## A kick you just took, before the game sim hears about it (so the bug and
## strip update the moment the ball is judged). kind "fg" / "pat".
func add_kick(kind: String, yards: int, made: bool, we_scored := true) -> void:
	var s := stats.duplicate()
	s[kind + "_att"] += 1
	if made:
		s[kind + "_made"] += 1
		s["points"] += 3 if kind == "fg" else 1
		if kind == "fg":
			s["long"] = maxi(int(s["long"]), yards)
	set_stats(s)
	if made and we_scored:
		var add := 3 if kind == "fg" else 1
		var us_score := (home_score if we_are_home else away_score) + add
		set_score(us_score, away_score if we_are_home else home_score)


## Takes back a missed kick's attempt (the player retries the same kick).
func undo_missed_kick(kind: String) -> void:
	var s := stats.duplicate()
	s[kind + "_att"] = maxi(int(s[kind + "_att"]) - 1, 0)
	set_stats(s)


# --- text --------------------------------------------------------------------------------

## "1ST 13:56", "4TH 0:09", "FINAL".
func header_text() -> String:
	if final:
		return "FINAL"
	return "%s %s" % [quarter_label(quarter), clock_label(seconds_left)]


func stats_text() -> String:
	return format_stats(stats)


## 1 -> "1ST" ... 4 -> "4TH", 5 -> "OT", 6 -> "2OT".
static func quarter_label(q: int) -> String:
	match q:
		1:
			return "1ST"
		2:
			return "2ND"
		3:
			return "3RD"
		4:
			return "4TH"
	if q <= 0:
		return "1ST"
	return "OT" if q == 5 else "%dOT" % (q - 4)


## Seconds left in the quarter -> "13:56" / "0:09" (never negative). Whole
## seconds round down, like GameSim.clock_text.
static func clock_label(seconds: float) -> String:
	var s := maxi(int(seconds), 0)
	return "%d:%02d" % [s / 60, s % 60]


## [quarter, seconds left in it] for a game time. The last quarter holds at
## 0:00 when time runs out.
static func time_from(elapsed: float, quarter_sec: float, quarters := 4) -> Array:
	if quarter_sec <= 0.0:
		return [1, 0.0]
	var q := mini(int(maxf(elapsed, 0.0) / quarter_sec) + 1, quarters)
	return [q, maxf(quarter_sec * q - elapsed, 0.0)]


## "FG 2/3 · XP 4/4 · LNG 44 · 10 PTS" ("-" for no long yet).
static func format_stats(s: Dictionary) -> String:
	return "FG %d/%d · XP %d/%d · LNG %s · %d PTS" % [int(s.get("fg_made", 0)), int(s.get("fg_att", 0)),
		int(s.get("pat_made", 0)), int(s.get("pat_att", 0)),
		str(int(s["long"])) if int(s.get("long", 0)) > 0 else "-", int(s.get("points", 0))]


## Your line from a game's kicks (GameSim.kicks): field goals and extra points
## you took (the backup's are skipped), longest made field goal, points.
static func kicker_line(kicks: Array) -> Dictionary:
	var s := empty_stats()
	for k in kicks:
		var kind := str(k.get("kind", ""))
		if not (kind in ["fg", "pat"]) or k.get("backup", false):
			continue
		s[kind + "_att"] += 1
		if k.get("made", false):
			s[kind + "_made"] += 1
			s["points"] += 3 if kind == "fg" else 1
			if kind == "fg":
				s["long"] = maxi(int(s["long"]), int(k.get("yards", 0)))
	return s


## A team's 2-4 letter abbreviation: its "short" field (every team in
## world.json has one), or one made from the name for teams without it
## (e.g. an older save's "???"): initials of a multi-word town/name, or the
## first three letters.
static func abbreviation(team: Dictionary) -> String:
	var s := str(team.get("short", "")).strip_edges().to_upper()
	if s != "" and s != "???" and s.length() <= 4:
		return s
	var src := str(team.get("town", "")).strip_edges()
	if src == "":
		src = str(team.get("name", "")).strip_edges()
	var words := PackedStringArray()
	for w in src.split(" ", false):
		var clean := ""
		for ch in w:
			if ch.to_upper() != ch.to_lower():
				clean += ch
		if clean != "":
			words.append(clean)
	if words.is_empty():
		return "TM"
	if words.size() >= 2:
		var init := ""
		for w in words.slice(0, 4):
			init += w.left(1)
		return init.to_upper()
	return words[0].left(3).to_upper()
