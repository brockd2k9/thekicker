extends Node
## Autoload "Haptics": phone vibration. Does nothing on desktop.
## Android needs the VIBRATE permission ticked in the export preset
## (Project > Export > Android > Permissions > Vibrate). iOS needs nothing.

@export var enabled: bool = true


## duration_ms: pulse length. amplitude 0..1 (Android only; -1 = device default).
func pulse(duration_ms: int, amplitude: float = -1.0) -> void:
	if not enabled or duration_ms <= 0 or not OS.has_feature("mobile"):
		return
	Input.vibrate_handheld(duration_ms, amplitude)
