extends Node
## "Try Kicks" from the Career Debug screen: random practice kicks played with
## the debug screen's KickProfile. The miss streak is live: each miss in a row
## rebuilds the profile (Rattled), each make resets it. Kicks are reported as
## practice kicks. Pause -> "Back to Debug".

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")

var _mode := DebugProfileMode.new()
var _game: Node
var _streak := 0


## Random kicks (like Practice) with the profile's extra pressure added.
class DebugProfileMode:
	extends KickMode
	var pressure_add := 0.0

	func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
		var s := KickSituation.roll(rng, tuning, wind.roll(rng, tuning))
		s.pressure = clampf(s.pressure + pressure_add, 0.0, 1.0)
		if pressure_add > 0.0:
			s.label += "  (+%d%% rattled)" % roundi(pressure_add * 100.0)
		return s


func _ready() -> void:
	if CareerDebugScreen.scratch == null:
		CareerDebugScreen.scratch = CareerData.create("Debug Kicker", CareerTuning.get_default())
	_streak = CareerDebugScreen.miss_streak
	_game = FIELD_GOAL.instantiate()
	_game.mode = _mode
	_apply_profile()  # before the scene enters the tree: kick 1 uses it
	add_child(_game)
	var overlay := PlayOverlay.new()
	overlay.quit_text = "Back to Debug"
	overlay.quit_path = Screens.CAREER_DEBUG
	add_child(overlay)
	GameState.kick_resolved.connect(_on_kick_resolved)
	_update_scoreboard()


func _exit_tree() -> void:
	if GameState.kick_resolved.is_connected(_on_kick_resolved):
		GameState.kick_resolved.disconnect(_on_kick_resolved)


func _apply_profile() -> void:
	var p := CareerDebugScreen.current_profile(_streak)
	_game.modifiers = p.to_kick_modifiers()
	_mode.pressure_add = p.pressure_add


func _on_kick_resolved(r: KickReport) -> void:
	_streak = 0 if r.made else _streak + 1
	_apply_profile()  # the next attempt reads the new modifiers
	_update_scoreboard()


func _update_scoreboard() -> void:
	_game.hud.set_scoreboard("DEBUG PROFILE", "MISS STREAK %d" % _streak)
