class_name KickoffRules
extends RefCounted
## The numbers that judge a kickoff or onside kick. Career Mode builds one per
## game from CareerTuning and the stage (CareerGameMode.kickoff_rules_for());
## the defaults below are used when nothing sets them.

## Carry (yards) at 100% swipe power and power_mult 1.0. Same curve as the old
## sideline pad, so career balance is unchanged.
var max_carry_yards: float = 75.0
## The kicking team's own yard line where the ball is teed up.
var spot_yards: int = 35
## Where the receiving team starts after a touchback / a kickoff out of bounds.
var touchback_spot: int = 25
var oob_spot: int = 35
## Return yards from where the ball is fielded: a random roll in this range,
## minus return_hang_cut for every second of hang time over 3 s.
var return_min_yards: float = 15.0
var return_max_yards: float = 30.0
var return_hang_cut: float = 4.0
## Onside: "good" if it rests this far downfield and the aim is within onside_aim_deg.
var onside_min_yards: float = 10.0
var onside_max_yards: float = 18.0
var onside_aim_deg: float = 15.0
## Recovery chance for a good / poor onside kick.
var onside_good_chance: float = 0.45
var onside_poor_chance: float = 0.08


## Yards from the tee to the receiving team's goal line.
func to_goal_yards() -> int:
	return 100 - spot_yards
