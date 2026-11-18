class_name PressureModel
extends Node
## Situation pressure does two things (each can be dialed in KickTuning):
##   1. Aim wobble: the aim drifts before/while you swipe. Whatever the wobble is
##      at the moment you release gets added to your aim.
##   2. Kick window: less time between the snap and the block.

## Raw situation pressure 0..1.
var level: float = 0.0
## Pressure after the player's Composure modifier (Phase 2).
var effective: float = 0.0

var _tuning: KickTuning
var _mods: KickModifiers
var _t := 0.0
var _phase_a := 0.0
var _phase_b := 0.0


func setup(situation_pressure: float, tuning: KickTuning, mods: KickModifiers) -> void:
	level = situation_pressure
	_tuning = tuning
	_mods = mods
	effective = clampf(level * mods.pressure_sensitivity, 0.0, 1.0)
	_t = 0.0
	_phase_a = randf() * TAU
	_phase_b = randf() * TAU


func _process(delta: float) -> void:
	_t += delta


## Current aim offset in degrees (+ = right). Two sine waves = organic drift.
func wobble_deg() -> float:
	if _tuning == null:
		return 0.0
	var amp := _tuning.max_wobble_deg * effective * _tuning.pressure_wobble_effect
	var w := _tuning.wobble_speed * TAU
	return amp * (0.65 * sin(_t * w + _phase_a) + 0.35 * sin(_t * w * 2.7 + _phase_b))


## Seconds the player has to kick after the snap.
func kick_window_sec() -> float:
	if _tuning == null:
		return 2.0
	var t := effective * _tuning.pressure_window_effect
	return lerpf(_tuning.base_kick_window, _tuning.min_kick_window, t) * _mods.window_mult
