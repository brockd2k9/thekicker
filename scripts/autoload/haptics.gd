extends Node
## Autoload "Haptics": phone vibration. Does nothing on desktop / Steam (and
## in a desktop browser); works in Android browsers too.
## Turned off by Settings > Vibration (GameSettings.haptics).
## Android needs the VIBRATE permission ticked in the export preset
## (Project > Export > Android > Permissions > Vibrate). iOS needs nothing.

@export var enabled: bool = true


## duration_ms: pulse length. amplitude 0..1 (Android only; -1 = device default).
func pulse(duration_ms: int, amplitude: float = -1.0) -> void:
	if not enabled or duration_ms <= 0 or not can_vibrate():
		return
	Input.vibrate_handheld(duration_ms, amplitude)


## A pulse after `delay` real seconds (for a two-part "rough" buzz).
func pulse_after(delay: float, duration_ms: int, amplitude: float = -1.0) -> void:
	if not enabled or duration_ms <= 0 or not can_vibrate():
		return
	await get_tree().create_timer(delay, true, false, true).timeout
	pulse(duration_ms, amplitude)


## True on phones (and Android browsers). False on desktop / Steam.
static func can_vibrate() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("web_android")
