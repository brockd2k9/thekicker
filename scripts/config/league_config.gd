class_name LeagueConfig
extends Resource
## Every number for Career Mode's leagues (League). Edit
## res://tuning/league.tres in the Inspector (or the defaults here). Read
## through League.config(). Team names, conference and division names live in
## res://data/career/league_teams.json.
##
## Each stage has its own league: conferences, each split into divisions of
## the same size (teams per division must be even). The player's team and every
## team from world.json for that stage are always in it; the rest are filled
## from league_teams.json. Total teams = conferences x divisions x teams.
##
## Schedule (every team, every season): games_per_season games and
## byes_per_season byes (CareerTuning). Of the games, division_games are inside
## the division, conference_games against the conference's other divisions,
## and the rest (nonconference) against the other conferences. Byes fall
## between bye_week_earliest and bye_week_latest (CareerTuning), one division
## at a time.
##
## Qualifying (after the regular season, from the standings):
##   qualifiers_per_division  the top N of every division get in (division
##                            winners first, seeded by record)
##   wildcards_per_conference then the best N others in each conference
##   bracket_by_conference    true: one bracket per conference, the conference
##                            champions meet in the final; false: one field
## College adds conference title games (the two division winners), a playoff
## field of college_playoff_field (the best college_auto_bids conference
## champions are guaranteed a spot, the rest by ranking) and bowl games for the
## next college_bowl_slots teams with at least college_bowl_min_win_share.
## Seeds come from the standings; the top seeds get first-round byes when the
## bracket isn't full. The postseason rounds themselves are PostseasonConfig's.

@export_group("High school (regions and districts)")
@export_range(1, 8) var hs_conferences: int = 2
@export_range(1, 8) var hs_divisions_per_conference: int = 4
@export_range(2, 16, 2) var hs_teams_per_division: int = 6
@export var hs_division_games: int = 5
@export var hs_conference_games: int = 3
@export var hs_qualifiers_per_division: int = 2
@export var hs_wildcards_per_conference: int = 0
@export var hs_bracket_by_conference: bool = true

@export_group("Junior college")
@export_range(1, 8) var juco_conferences: int = 2
@export_range(1, 8) var juco_divisions_per_conference: int = 2
@export_range(2, 16, 2) var juco_teams_per_division: int = 4
@export var juco_division_games: int = 3
@export var juco_conference_games: int = 4
@export var juco_qualifiers_per_division: int = 1
@export var juco_wildcards_per_conference: int = 0
@export var juco_bracket_by_conference: bool = true

@export_group("College (conferences and divisions)")
@export_range(1, 8) var college_conferences: int = 4
@export_range(1, 8) var college_divisions_per_conference: int = 2
@export_range(2, 16, 2) var college_teams_per_division: int = 6
@export var college_division_games: int = 5
@export var college_conference_games: int = 3
## The two division winners of each conference play for the conference title.
@export var college_conference_title_game: bool = true
## Teams in the national playoff (the top seeds get byes if it isn't 2, 4, 8, 16...).
@export var college_playoff_field: int = 12
## The best this many conference champions get a playoff spot whatever their rank.
@export var college_auto_bids: int = 4
## Bowl games: the next this many ranked teams (outside the playoff) with at
## least this win share.
@export var college_bowl_slots: int = 16
@export_range(0.0, 1.0) var college_bowl_min_win_share: float = 0.5
## College ranking ("the poll"): win share x 100, plus this much per point of
## average opponent strength above 50, plus a bonus for conference champions.
@export var college_poll_schedule_weight: float = 0.6
@export var college_poll_champion_bonus: float = 5.0

@export_group("Pro (two conferences, four divisions)")
@export_range(1, 8) var pro_conferences: int = 2
@export_range(1, 8) var pro_divisions_per_conference: int = 4
@export_range(2, 16, 2) var pro_teams_per_division: int = 4
@export var pro_division_games: int = 6
@export var pro_conference_games: int = 2
## Division winners plus this many wild cards per conference (7 = top seed bye).
@export var pro_qualifiers_per_division: int = 1
@export var pro_wildcards_per_conference: int = 3
@export var pro_bracket_by_conference: bool = true

@export_group("Simulated games (everyone but you)")
## Expected points for an even matchup.
@export var sim_mean_points: float = 22.0
## Each point of strength difference moves the expected score by this much
## (for one team, against the other), so 10 points of strength is about 7 points of margin.
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
## and this share of the way back toward the stage's average.
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


## One stage's structure as a dictionary (League reads this).
func structure(stage: String) -> Dictionary:
	var p := _prefix(stage)
	if p == "":
		return {}
	var s := {
		"conferences": maxi(int(get(p + "_conferences")), 1),
		"divisions": maxi(int(get(p + "_divisions_per_conference")), 1),
		"teams": maxi(int(get(p + "_teams_per_division")), 2),
		"division_games": maxi(int(get(p + "_division_games")), 0),
		"conference_games": maxi(int(get(p + "_conference_games")), 0),
		"by_conference": bool(get(p + "_bracket_by_conference")) if p != "college" else false,
		"qualifiers_per_division": maxi(int(get(p + "_qualifiers_per_division")), 0) if p != "college" else 0,
		"wildcards": maxi(int(get(p + "_wildcards_per_conference")), 0) if p != "college" else 0,
	}
	# Divisions play a round robin: an even number of teams.
	s["teams"] = int(s["teams"]) + int(s["teams"]) % 2
	if p == "college":
		s["title_game"] = college_conference_title_game
		s["field"] = maxi(college_playoff_field, 2)
		s["auto_bids"] = maxi(college_auto_bids, 0)
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
