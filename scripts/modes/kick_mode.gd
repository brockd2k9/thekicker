class_name KickMode
extends RefCounted
## Rules a game mode plugs into the field-goal scene (field_goal_game.gd `mode`).
## null mode = free practice (the original Phase 1 behavior: random kicks forever).
##
## A mode only decides WHAT the next kick is and WHETHER there is a next kick.
## It never touches the kicking mechanic. It learns results by listening to
## GameState.kick_resolved, like every other system.
## Career Mode later: a CareerGameMode that builds situations from the game sim
## and returns false from wants_next_kick() when the game is over.


func id() -> StringName:
	return &"practice"


## The next attempt. May call wind.set_conditions(); if it doesn't, the wind
## is rolled randomly. Return null to roll a random situation.
func next_situation(_rng: RandomNumberGenerator, _tuning: KickTuning, _wind: Wind) -> KickSituation:
	return null


## Asked after each result has been shown. false = no "tap for next kick";
## the mode shows its own end screen instead.
func wants_next_kick() -> bool:
	return true
