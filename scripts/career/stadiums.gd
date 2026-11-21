class_name Stadiums
extends RefCounted
## Which stadium a Career kick happens in (StadiumSpec presets).
##
## A game is at the home team's stadium (an away game is at the opponent's):
##   high school: strength bands (stadium_hs_strength) -> hs_1 / hs_2 / hs_3;
##                always at night
##   junior college: bleachers (juco)
##   college:     the team's tier (small / mid / top); night for a share of
##                games (college_night_share), prime time
##   pro:         strength bands (stadium_pro_strength) -> pro_1 / pro_2 / pro_3;
##                night for pro_night_share of games
## A team with "capacity" in world.json is placed by capacity instead
## (stadium_*_capacity bands). The night pick is a hash of the season, week
## and teams, so it never changes on resume.
## Kick challenges are at a neutral site: high school showcases and camps at a
## small college stadium, a college combine at a pro stadium, a college
## showcase or camp at a mid-size college, anything in the pros at a pro_2.
## Kicker battles, auditions and tryouts are at the team's own stadium, in the
## daytime. Practice mode keeps the original stadium (no spec).
## Numbers: CareerTuning "Stadiums".

## The preset id for a team at a stage ("high_school", "juco", "college",
## "pro"; "free_agent" counts as pro).
static func tier_for(team: Dictionary, stage: String, t: CareerTuning) -> String:
	var cap := _capacity(team)
	var strength := float(team.get("strength", 50.0))
	match stage:
		CareerData.STAGE_JUCO:
			return "juco"
		CareerData.STAGE_COLLEGE:
			if cap > 0:
				return "college_" + ["small", "mid", "top"][_band(cap, t.stadium_college_capacity)]
			var tier := str(team.get("tier", "mid"))
			if tier == "juco":
				return "juco"
			return "college_" + (tier if tier in ["small", "mid", "top"] else "mid")
		CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT:
			var b := _band(cap, t.stadium_pro_capacity) if cap > 0 else _band(strength, t.stadium_pro_strength)
			return "pro_%d" % (b + 1)
	var hb := _band(cap, t.stadium_hs_capacity) if cap > 0 else _band(strength, t.stadium_hs_strength)
	return "hs_%d" % (hb + 1)


## The stadium for this week's game (CareerManager.entry()).
static func for_game(c: CareerData, e: Dictionary, t: CareerTuning) -> StadiumSpec:
	var opp: Dictionary = e.get("opponent", {})
	var home := bool(e.get("home", true)) or opp.is_empty()
	var host: Dictionary = c.team if home else opp
	var st := StadiumSpec.preset(tier_for(host, c.stage, t))
	st.night = night_game(c.stage, c.season, int(e.get("week", c.week)),
		str(c.team.get("id", "")) + "|" + str(opp.get("id", "")), t)
	_dress(st, host)
	return st


## The stadium for a tryout record (an audition, a tryout, a kick challenge).
static func for_tryout(c: CareerData, tr: Dictionary, t: CareerTuning) -> StadiumSpec:
	var stage := str(tr.get("stage", "pro"))
	var id := ""
	if str(tr.get("purpose", "")) == "challenge":
		id = neutral_site(str(tr.get("kind", "")), stage)
	if id != "":
		return StadiumSpec.preset(id)
	var team := CareerContent.team_by_id(str(tr.get("team", "")))
	var as_stage := CareerData.STAGE_PRO
	if stage == "high_school":
		as_stage = CareerData.STAGE_HIGH_SCHOOL
	elif stage == "college":
		as_stage = CareerData.STAGE_JUCO if c.stage == CareerData.STAGE_JUCO else CareerData.STAGE_COLLEGE
	var st := StadiumSpec.preset(tier_for(team, as_stage, t))
	_dress(st, team)
	return st


## Where a kick challenge is held ("" = the team's own stadium).
static func neutral_site(kind: String, stage: String) -> String:
	if kind in ["battle", "tryout"]:
		return ""
	match stage:
		"high_school":
			return "college_small"
		"college":
			return "pro_1" if kind == "combine" else "college_mid"
	return "pro_2"


## Night game? High school always; college and pro a share of games, picked
## from the season, week and teams (stable on resume).
static func night_game(stage: String, season: int, week: int, key: String, t: CareerTuning) -> bool:
	match stage:
		CareerData.STAGE_HIGH_SCHOOL:
			return true
		CareerData.STAGE_COLLEGE:
			return _roll(season, week, key) < t.college_night_share
		CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT:
			return _roll(season, week, key) < t.pro_night_share
	return false


## The host's crowd colors and end zone color.
static func _dress(st: StadiumSpec, host: Dictionary) -> void:
	var colors: Array = host.get("colors", [])
	if colors.size() < 2:
		return
	var a := Color.from_string(str(colors[0]), Color.NAVY_BLUE)
	var b := Color.from_string(str(colors[1]), Color.GOLD)
	st.crowd_colors = [a, b]
	st.endzone = a.darkened(0.25)


static func _capacity(team: Dictionary) -> int:
	if team.has("capacity"):
		return int(team["capacity"])
	var id := str(team.get("id", ""))
	if id == "":
		return 0
	return int(CareerContent.team_by_id(id).get("capacity", 0))


## 0, 1 or 2: below bands.x, below bands.y, or above.
static func _band(v: float, bands: Vector2) -> int:
	if v < bands.x:
		return 0
	return 1 if v < bands.y else 2


static func _roll(season: int, week: int, key: String) -> float:
	return float(absi(hash("%d|%d|%s" % [season, week, key])) % 1000) / 1000.0
