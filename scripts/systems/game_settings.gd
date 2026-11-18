class_name GameSettings
extends RefCounted
## Player options. Saved with everything else by SaveStore.
## apply() pushes them into the engine (audio buses, Haptics).

const SFX_BUS := &"SFX"
const MUSIC_BUS := &"Music"

## 0..1 linear.
var sound_volume: float = 0.8
var music_volume: float = 0.6
var haptics: bool = true
## Shows the aim ring above the crossbar (where a straight swipe would go).
## Visual help only: it never changes the physics of the kick.
var aim_assist: bool = true


func apply() -> void:
	ensure_buses()
	_set_bus_volume(SFX_BUS, sound_volume)
	_set_bus_volume(MUSIC_BUS, music_volume)
	Haptics.enabled = haptics


## Creates the SFX and Music buses (sending to Master) if the project has no
## bus layout for them yet.
static func ensure_buses() -> void:
	for bus_name in [SFX_BUS, MUSIC_BUS]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var i := AudioServer.bus_count - 1
			AudioServer.set_bus_name(i, bus_name)
			AudioServer.set_bus_send(i, &"Master")


static func _set_bus_volume(bus_name: StringName, linear: float) -> void:
	var i := AudioServer.get_bus_index(bus_name)
	if i == -1:
		return
	AudioServer.set_bus_mute(i, linear <= 0.001)
	AudioServer.set_bus_volume_db(i, linear_to_db(maxf(linear, 0.001)))


func to_dict() -> Dictionary:
	return {
		"sound_volume": sound_volume,
		"music_volume": music_volume,
		"haptics": haptics,
		"aim_assist": aim_assist,
	}


func from_dict(d: Dictionary) -> void:
	sound_volume = clampf(float(d.get("sound_volume", sound_volume)), 0.0, 1.0)
	music_volume = clampf(float(d.get("music_volume", music_volume)), 0.0, 1.0)
	haptics = bool(d.get("haptics", haptics))
	aim_assist = bool(d.get("aim_assist", aim_assist))
