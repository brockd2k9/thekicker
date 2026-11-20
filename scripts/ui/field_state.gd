class_name FieldState
extends Resource
## What the field tracker (FieldTracker, scenes/ui/field_tracker.tscn) shows:
## who has the ball, where it is, the drive, down & distance, the first-down
## line, timeouts, the last play, and your kick when you're on the field.
## FieldModel fills it from the game sim's events; every FieldTracker bound to
## it redraws from `changed` (Resource signal) and tweens the ball from
## `ball_moved`. Display only: never saved.
##
## Field coordinates ("abs"): yards from the LEFT goal line, 0..100. The away
## team defends the left end zone and the home team the right one, all game,
## so the away offense attacks right (+1) and the home offense left (-1).

signal ball_moved(from: float)

## Play type tags (play line under the field) and their colors.
const PLAY_COLORS := {
	"RUSH": Color("#3f9d5a"), "PASS": Color("#3b7dd8"), "PUNT": Color("#8a909c"),
	"FG": Color("#d4a017"), "XP": Color("#d4a017"), "KICKOFF": Color("#8e5cd9"),
	"TURNOVER": Color("#d7261e"), "TD": Color("#e07b00"), "TIMEOUT": Color("#5a6273"),
}

## {abbr, name, color, color2} for each side.
var home: Dictionary = {"abbr": "HOM", "name": "Home", "color": Color.DIM_GRAY, "color2": Color.WHITE}
var away: Dictionary = {"abbr": "AWY", "name": "Away", "color": Color.DIM_GRAY, "color2": Color.WHITE}
## Which side your team is ("home" / "away").
var us_side: String = "home"
## "home" / "away" / "" (kickoff, halftime, game over).
var possession: String = ""
var ball: float = 50.0
var drive_start: float = -1.0
## First-down line (abs), or -1 when there is none (kicks, goal to go shown as "Goal").
var first_down: float = -1.0
## 1..4, 0 = no down (kickoffs, extra points, between drives).
var down: int = 0
var to_go: int = 10
var timeouts: Dictionary = {"home": 3, "away": 3}
var play_text: String = ""
## A PLAY_COLORS key or "".
var play_type: String = ""
## Your kick right now: {} or {"kind": "fg"/"pat"/"kickoff"/"onside", "yards"}.
var kick: Dictionary = {}
## Field goal range in yards (kick distance) for each side.
var fg_range: Dictionary = {"home": 0.0, "away": 0.0}


func team(side: String) -> Dictionary:
	return home if side == "home" else away


static func other(side: String) -> String:
	return "away" if side == "home" else ("home" if side == "away" else "")


## +1 = attacks right (away), -1 = attacks left (home).
static func attack_dir(side: String) -> int:
	return 1 if side == "away" else -1


## A team's own yard line (1..99 from its own goal line) -> abs.
static func own_to_abs(side: String, own_yd: float) -> float:
	return own_yd if side == "away" else 100.0 - own_yd


## abs -> that team's own yard line.
static func abs_to_own(side: String, abs_yd: float) -> float:
	return abs_yd if side == "away" else 100.0 - abs_yd


## The goal line a side attacks (abs).
static func goal_of(side: String) -> float:
	return 100.0 if side == "away" else 0.0


## Yards from the ball to the goal `side` attacks.
static func to_goal(side: String, abs_yd: float) -> float:
	return absf(goal_of(side) - abs_yd)


## Horizontal position (px) of an abs yard line on a strip `width` px wide:
## 10-yard end zones on both sides, so 120 yards across.
static func x_of(abs_yd: float, width: float) -> float:
	return (abs_yd + 10.0) / 120.0 * width


## "OWN 37" (your side of the field), "OAK 37" (theirs), "50" (midfield).
func spot_text(side: String, abs_yd: float) -> String:
	var own := roundi(abs_to_own(side, abs_yd))
	if own == 50:
		return "50"
	if own < 50:
		return "OWN %d" % own
	return "%s %d" % [str(team(other(side)).get("abbr", "OPP")), 100 - own]


## "1st & 10", "3rd & 4", "1st & Goal", or "" with no down.
func down_text() -> String:
	if down <= 0:
		return ""
	var nth: String = ["1st", "2nd", "3rd", "4th"][clampi(down, 1, 4) - 1]
	if first_down < 0.0:
		return "%s & Goal" % nth
	return "%s & %d" % [nth, maxi(to_go, 1)]


## "1st & 10 ball on OAK 37" / "KICKOFF" / "" (the info bar's center line).
func info_text() -> String:
	if not kick.is_empty() and str(kick.get("kind", "")) in ["kickoff", "onside"]:
		return "ONSIDE KICK" if kick["kind"] == "onside" else "KICKOFF"
	if possession == "":
		return ""
	var spot := "ball on %s" % spot_text(possession, ball)
	var d := down_text()
	if not kick.is_empty() and str(kick.get("kind", "")) == "pat":
		return "Extra point  %s" % spot
	if d == "":
		return "Ball on %s" % spot_text(possession, ball)
	return "%s %s" % [d, spot]


## True when the team with the ball is in its field goal range.
func in_fg_range() -> bool:
	if possession == "":
		return false
	var r := float(fg_range.get(possession, 0.0))
	return r > 0.0 and to_goal(possession, ball) + 17.0 <= r


## abs line where `side`'s field goal range starts (kick distance = range).
func fg_range_line(side: String) -> float:
	var d := maxf(float(fg_range.get(side, 0.0)) - 17.0, 0.0)
	return goal_of(side) - attack_dir(side) * d


## Sets the ball and tells trackers to tween from where it was.
func move_ball(to: float) -> void:
	var from := ball
	ball = clampf(to, 0.0, 100.0)
	if not is_equal_approx(from, ball):
		ball_moved.emit(from)
