class_name PostseasonConfig
extends Resource
## Every number for Career Mode's postseason. Edit res://tuning/postseason.tres
## in the Inspector (or the defaults here). Read through Postseason.config().
##
## After the regular season (the schedule from CareerManager.build_schedule),
## the regular-season record decides: win share = (W + T/2) / games.
##   High school:    >= hs_playoff_min  -> playoffs, ending in the state final.
##   Junior college: >= juco_playoff_min -> a short playoff.
##   College:        >= college_playoff_min -> playoff bracket;
##                   else >= college_bowl_min -> one bowl game; else done.
##   Pro:            >= pro_playoff_min -> playoffs, ending in the title game.
## Each postseason game is one more week of the normal weekly loop (scenarios,
## Outlook, the game, Results). Win and you advance; lose and the season ends.
## Postseason games can't end tied (overtime goes on until someone wins).

@export_group("Qualifying (win share of regular-season games)")
@export_range(0.0, 1.0) var hs_playoff_min: float = 0.6
@export_range(0.0, 1.0) var juco_playoff_min: float = 0.6
@export_range(0.0, 1.0) var college_playoff_min: float = 0.7
@export_range(0.0, 1.0) var college_bowl_min: float = 0.5
@export_range(0.0, 1.0) var pro_playoff_min: float = 0.6

@export_group("Rounds (the last one is the final)")
@export var hs_rounds: PackedStringArray = PackedStringArray(["Playoffs: First Round",
	"Playoffs: Quarterfinal", "Playoffs: Semifinal", "State Championship"])
@export var juco_rounds: PackedStringArray = PackedStringArray(["Region Playoff",
	"Junior College Championship"])
@export var college_rounds: PackedStringArray = PackedStringArray(["Playoff: First Round",
	"Playoff: Quarterfinal", "Playoff: Semifinal", "National Championship"])
@export var pro_rounds: PackedStringArray = PackedStringArray(["Wild Card Round",
	"Divisional Round", "Conference Championship", "Gridiron Championship"])
## College bowl games (fictional names): one is picked at random.
@export var bowl_names: PackedStringArray = PackedStringArray(["Harvest Moon Bowl",
	"Copper Canyon Bowl", "Lakeshore Bowl", "Pinecrest Bowl", "Prairie Wind Bowl",
	"Bayou Lights Bowl"])

@export_group("Opponents")
## Opponents come from the strongest teams of the stage: one of the top
## opponent_pool teams by strength.
@export var opponent_pool: int = 10
## Added to the opponent's strength in every postseason game, plus per round.
@export var opponent_strength_bonus: float = 0.0
@export var opponent_strength_per_round: float = 2.0
## Chance you're the home team in each postseason game (finals included).
@export_range(0.0, 1.0) var home_chance: float = 0.6

@export_group("Pressure")
## Added to every kick's pressure in postseason games (on top of the stage's),
## plus per round after the first, plus more in the final.
@export_range(0.0, 1.0) var pressure_bonus: float = 0.12
@export_range(0.0, 1.0) var pressure_per_round: float = 0.04
@export_range(0.0, 1.0) var final_pressure_bonus: float = 0.1

@export_group("Rewards")
## Each postseason win / a title adds this much to the season's recruiting
## gain (HS, JUCO), draft gain (college) or pro retention.
@export var recruiting_per_win: float = 1.0
@export var recruiting_title: float = 3.0
@export var draft_per_win: float = 1.0
@export var draft_title: float = 3.0
@export var retention_per_win: float = 1.0
@export var retention_title: float = 4.0
## Skill points for winning a title (granted through SkillPoints.earn).
@export var title_skill_points: int = 6
