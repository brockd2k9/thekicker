extends Node
## Autoload "GameState": the one service every mode reports to.
##
##   kicks:    field_goal_game.gd calls report_kick(KickReport) once per attempt.
##             That emits kick_resolved, which stats, achievements and the
##             active mode (Challenge, Career later) all listen to.
##   runs:     a mode calls report_run(summary) when a run/game ends.
##   data:     stats (KickStats), achievements (AchievementTracker),
##             settings (GameSettings), saved together by SaveStore.
##
## Session stats (since the app was opened) are the attempts/makes/streak vars
## below; the HUD reads them. All-time stats live in `stats`.
## Career Mode plan: player stats (Leg Power, Accuracy, Composure, Fitness,
## Morale), schedule and season go in the save's reserved "career" section,
## and career kicks call report_kick() like every other mode.

signal session_changed
## The single kick-result event. Every system and mode listens to this.
signal kick_resolved(report: KickReport)
## A Challenge run (or, later, a Career game) ended.
signal run_finished(summary: Dictionary)
signal stats_changed
signal achievement_unlocked(def: Dictionary)
signal settings_changed

var attempts: int = 0
var makes: int = 0
var streak: int = 0
var best_streak: int = 0
## One entry per kick: {distance, pressure, outcome}. Handy for playtest stats.
var history: Array[Dictionary] = []

var stats := KickStats.new()
var achievements := AchievementTracker.new()
var settings := GameSettings.new()
var save_store := SaveStore.new()
## Reserved for Career Mode save data (null until Career exists).
var career_data: Variant = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_game()
	# Deferred: the Haptics/Sfx autoloads are added after this one.
	settings.apply.call_deferred()
	# Built-in listeners run first (connected before any scene exists), so
	# stats are already updated when a mode's own handler runs.
	kick_resolved.connect(_on_kick_resolved)
	run_finished.connect(_on_run_finished)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()


# --- reporting -----------------------------------------------------------------

## Called by the kick scene once per attempt, the moment the result is known.
func report_kick(report: KickReport) -> void:
	kick_resolved.emit(report)


## Called by a mode when a run ends. summary needs at least "mode" and "makes".
func report_run(summary: Dictionary) -> void:
	run_finished.emit(summary)


func _on_kick_resolved(r: KickReport) -> void:
	record_attempt(r.distance_yards, r.pressure, r.outcome)
	stats.record_kick(r)
	stats_changed.emit()
	_announce(achievements.check_kick(r.to_dict(), stats))
	save_game()


func _on_run_finished(summary: Dictionary) -> void:
	stats.record_run(summary)
	stats_changed.emit()
	_announce(achievements.check_run(summary, stats))
	save_game()


func _announce(defs: Array[Dictionary]) -> void:
	for def in defs:
		achievement_unlocked.emit(def)


# --- session (since app start) -------------------------------------------------

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


# --- settings / reset ----------------------------------------------------------

## Call after changing any field of `settings`. save=false while a slider is
## still being dragged.
func settings_updated(save: bool = true) -> void:
	settings.apply()
	settings_changed.emit()
	if save:
		save_game()


## "Reset Stats": clears all-time and session stats. Achievements and settings stay.
func reset_stats() -> void:
	stats.reset()
	reset_session()
	stats_changed.emit()
	save_game()


# --- save / load ---------------------------------------------------------------

func load_game() -> void:
	var d := save_store.load_data()
	stats.from_dict(d["stats"])
	achievements.from_dict(d["achievements"])
	settings.from_dict(d["settings"])
	career_data = d.get("career")


func save_game() -> void:
	save_store.save_data({
		"stats": stats.to_dict(),
		"achievements": achievements.to_dict(),
		"settings": settings.to_dict(),
		"career": career_data,
	})
