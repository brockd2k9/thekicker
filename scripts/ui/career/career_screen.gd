class_name CareerScreen
extends MenuScreen
## Base for the career screens: needs an open career (GameState.career), and
## sends you to the right screen if the career is on a different step
## (e.g. after a quit). Back goes to the Career Hub.

## Screens you can open at any step (the rest follow the career's phase).
const FREE_SCREENS := [Screens.CAREER_HUB, Screens.CAREER_STATS]

var career: CareerManager


func _ready() -> void:
	career = GameState.career
	if career == null:
		Screens.go(Screens.CAREER)
		return
	var path := scene_file_path
	if not (path in FREE_SCREENS) and career.screen_path() != path:
		Screens.go(career.screen_path())
		return
	super._ready()


func go_back() -> void:
	Screens.go(Screens.CAREER_HUB)


## Opens the screen for the career's current step.
func go_to_current() -> void:
	Screens.go(career.screen_path())


## "Ridgeline Falcons"
static func team_name(t: Dictionary) -> String:
	return "%s %s" % [t.get("town", t.get("name", "")), t.get("mascot", "")]


static func strength_word(s: float) -> String:
	if s >= 70.0:
		return "Powerhouse"
	if s >= 57.0:
		return "Contender"
	if s >= 45.0:
		return "Average"
	return "Rebuilding"
