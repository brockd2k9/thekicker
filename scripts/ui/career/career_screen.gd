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


## "Top-program interest" etc. from the recruiting score and the tier minimums.
static func recruit_word(c: CareerData) -> String:
	for tier_id in Progression.TIERS:
		if Progression.offer_type(c.recruiting_score, tier_id) in [Progression.OFFER_FULL, Progression.OFFER_PARTIAL]:
			return "%s level" % Progression.tier(tier_id).get("name", "")
	if Progression.offer_type(c.recruiting_score, "small") == Progression.OFFER_WALK_ON:
		return "Walk-on interest"
	return "Not on radars yet"


static func draft_word(c: CareerData) -> String:
	var d: Dictionary = Progression.rules().get("draft", {})
	for r in d.get("rounds", []):
		if c.draft_score >= float(r["min"]):
			return "Round %d projection" % int(r["round"])
	if c.draft_score >= float(d.get("udfa_min", 45)):
		return "Camp invite projection"
	return "Off the board"


static func standing_word(score: float, t: CareerTuning) -> String:
	if score < t.release_below:
		return "On thin ice"
	if score < t.resign_min:
		return "Shaky"
	if score < 70.0:
		return "Solid"
	return "Franchise kicker"


static func strength_word(s: float) -> String:
	if s >= 70.0:
		return "Powerhouse"
	if s >= 57.0:
		return "Contender"
	if s >= 45.0:
		return "Average"
	return "Rebuilding"
