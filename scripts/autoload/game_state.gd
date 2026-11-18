extends Node
## Autoload "GameState": persistent game data that outlives a scene.
##
## Phase 1: kicking-session stats only.
## Phase 2 plan: player stats (Leg Power, Accuracy, Composure, Fitness, Morale),
## money, relationships, week/season progress live here (or in sibling
## autoloads). Save/load = serialize this node's data to user://.

signal session_changed

var attempts: int = 0
var makes: int = 0
var streak: int = 0
var best_streak: int = 0
## One entry per kick: {distance, pressure, outcome}. Handy for playtest stats.
var history: Array[Dictionary] = []


## outcome is a KickResult.Outcome value.
func record_attempt(distance_yards: int, pressure: float, outcome: int) -> void:
	attempts += 1
	if outcome == KickResult.Outcome.GOOD:
		makes += 1
		streak += 1
		best_streak = maxi(best_streak, streak)
	else:
		streak = 0
	history.append({"distance": distance_yards, "pressure": pressure, "outcome": outcome})
	session_changed.emit()


func make_percent() -> int:
	if attempts == 0:
		return 0
	return roundi(100.0 * makes / attempts)


func reset_session() -> void:
	attempts = 0
	makes = 0
	streak = 0
	best_streak = 0
	history.clear()
	session_changed.emit()
