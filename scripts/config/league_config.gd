class_name LeagueConfig
extends Resource
## Every number for Career Mode's leagues (League). Edit
## res://tuning/league.tres in the Inspector (or the defaults here). Read
## through League.config().
##
## The teams are the team database's (data/teams, TeamDatabase), nothing else:
##   High school     every high school; its conferences (one today: the
##                   21-school South Georgia Coastal-Pine Division)
##   Junior college  every junior college
##   College         the colleges of the player's level (FBS, FCS or D2), in
##                   their conferences
##   Pro             all 32 clubs: AFC / NFC, four divisions each
## High school and college conferences have no divisions inside them: the
## conference is the division (standings, "division" games and records).
## Pro: the conference is AFC / NFC, the division is "AFC East".
##
## Schedule (every team, every season): CareerTuning.games_for(stage) games
## and byes_per_season byes. division_games against the own division (with
## rematches only where division_rematches is on), conference_games against
## the conference's other divisions (pro), the rest against everyone else.
## Odd team counts mean some teams sit each week: they get the extra byes.
## Byes are placed between bye_week_earliest and bye_week_latest
## (CareerTuning) where the schedule allows.
##
## Qualifying (after the regular season, from the standings):
##   qualifiers_per_division  the top N of every division (winners first)
##   wildcards_per_conference then the best N others in each conference
##   bracket_by_conference    one bracket per conference, the champions meet
##                            in the final (pro: AFC / NFC)
## College: each conference's top two play a title game (conferences with at
## least college_title_game_min_teams teams; an independents group has no
## champion), then a playoff field per level (FBS 24, FCS 8, D2 8: the best
## college_auto_bids_* conference champions are guaranteed a spot, the rest by
## ranking), then bowls for the next college_bowl_slots teams with at least
## college_bowl_min_win_share. The postseason rounds themselves are
## PostseasonConfig's; the top seeds get byes when the bracket isn't full.

@export_group("High school")
@export var hs_division_games: int = 10
@export var hs_division_rematches: bool = false
@export var hs_conference_games: int = 0
## The state playoffs: the top 8 of the conference (rounds: the last 3 of
## PostseasonConfig.hs_rounds: quarterfinal, semifinal, State Championship).
@export var hs_qualifiers_per_division: int = 8
@export var hs_wildcards_per_conference: int = 0
@export var hs_bracket_by_conference: bool = false

@export_group("Junior college")
@export var juco_division_games: int = 10
@export var juco_division_rematches: bool = true
@export var juco_conference_games: int = 0
@export var juco_qualifiers_per_division: int = 4
@export var juco_wildcards_per_conference: int = 0
@export var juco_bracket_by_conference: bool = false

@export_group("College")
## Conference games (the conference is the division); the rest are outside it.
@export var college_division_games: int = 8
@export var college_division_rematches: bool = false
## The top two of each conference play for its title.
@export var college_conference_title_game: bool = true
@export var college_title_game_min_teams: int = 6
## A conference whose name ends with this has no champion or title game.
@export var college_independent_suffix: String = "Independents"
## Teams in each level's national playoff (the top seeds get byes if it isn't
## 2, 4, 8, 16, 32...). FBS 24: the top 8 seeds skip the first round.
@export var college_playoff_field_fbs: int = 24
@export var college_playoff_field_fcs: int = 8
@export var college_playoff_field_d2: int = 8
## The best this many conference champions get a playoff spot whatever their rank.
@export var college_auto_bids_fbs: int = 5
@export var college_auto_bids_fcs: int = 3
@export var college_auto_bids_d2: int = 3
## Bowl games: the next this many ranked teams (outside the playoff) with at
## least this win share.
@export var college_bowl_slots: int = 32
@export_range(0.0, 1.0) var college_bowl_min_win_share: float = 0.5
## College ranking ("the poll"): win share x 100, plus this much per point of
## average opponent strength above 50, plus a bonus for conference champions.
@export var college_poll_schedule_weight: float = 0.6
@export var college_poll_champion_bonus: float = 5.0

@export_group("Pro")
@export var pro_division_games: int = 6
@export var pro_division_rematches: bool = true
@export var pro_conference_games: int = 6
## Division winners plus this many wild cards per conference (7 = top seed bye).
@export var pro_qualifiers_per_division: int = 1
@export var pro_wildcards_per_conference: int = 3
@export var pro_bracket_by_conference: bool = true

@export_group("Simulated games (everyone but you)")
## Expected points for an even matchup.
@export var sim_mean_points: float = 22.0
## Each point of strength difference moves the expected score by this much
## (for one team, against the other): 10 points of strength is about 7 points of margin.
@export var sim_points_per_strength: float = 0.35
## Spread of each team's score (standard deviation, points).
@export var sim_points_sd: float = 9.0
## Home field, in strength points.
@export var sim_home_edge: float = 2.0
## A regular-season game that ends level stays a tie this often (stages
## whose overtime can end tied); otherwise someone wins in overtime.
@export_range(0.0, 1.0) var sim_tie_keep: float = 0.3

@export_group("Team strength")
## Between seasons every team's strength moves by up to this much (random),
## and this share of the way back toward the league's average.
@export var strength_drift: float = 4.0
@export_range(0.0, 1.0) var strength_regression: float = 0.1
@export var strength_min: float = 25.0
@export var strength_max: float = 92.0

@export_group("Screens")
## The live playoff picture shows from this week of the regular season (and
## always once the regular season is over).
@export var playoff_picture_from_week: int = 6
## Teams shown just below the playoff line in the playoff picture.
@export var playoff_picture_bubble: int = 3


## One stage's rules as a dictionary (League reads this); {} = no league.
## scope: the college level ("FBS", "FCS", "D2") for the playoff field.
func structure(stage: String, scope := "") -> Dictionary:
	var p := _prefix(stage)
	if p == "":
		return {}
	var s := {
		"division_games": maxi(int(get(p + "_division_games")), 0),
		"rematches": bool(get(p + "_division_rematches")),
		"conference_games": maxi(int(get(p + "_conference_games")), 0) if p != "college" else 0,
		"by_conference": bool(get(p + "_bracket_by_conference")) if p != "college" else false,
		"qualifiers_per_division": maxi(int(get(p + "_qualifiers_per_division")), 0) if p != "college" else 0,
		"wildcards": maxi(int(get(p + "_wildcards_per_conference")), 0) if p != "college" else 0,
	}
	if p == "college":
		s["title_game"] = college_conference_title_game
		s["title_min"] = maxi(college_title_game_min_teams, 2)
		s["independent"] = college_independent_suffix
		var lvl := scope.to_lower() if scope.to_lower() in ["fbs", "fcs", "d2"] else "fbs"
		s["field"] = maxi(int(get("college_playoff_field_" + lvl)), 2)
		s["auto_bids"] = maxi(int(get("college_auto_bids_" + lvl)), 0)
		s["bowl_slots"] = maxi(college_bowl_slots, 0)
		s["bowl_min"] = college_bowl_min_win_share
	return s


static func _prefix(stage: String) -> String:
	match stage:
		CareerData.STAGE_HIGH_SCHOOL:
			return "hs"
		CareerData.STAGE_JUCO:
			return "juco"
		CareerData.STAGE_COLLEGE:
			return "college"
		CareerData.STAGE_PRO:
			return "pro"
	return ""
