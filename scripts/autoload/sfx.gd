extends Node
## Autoload "Sfx": the sound hook.
##
## Call  Sfx.play(&"kick")  from anywhere. If res://audio/kick.ogg (or .wav/.mp3)
## exists it plays; otherwise nothing breaks (debug builds just print the event).
## Events used in Phase 1: snap, kick, good, miss, block.
## Other systems (haptics, crowd, music) can listen to the `played` signal.

signal played(event_name: StringName)

const AUDIO_DIR := "res://audio/"
const EXTENSIONS := ["ogg", "wav", "mp3"]
const POOL_SIZE := 6

@export var log_missing: bool = true

var _cache: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)


func play(event_name: StringName, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	played.emit(event_name)
	var stream := _find(event_name)
	if stream == null:
		if log_missing and OS.is_debug_build():
			print("[Sfx] ", event_name)
		return
	var p := _pool[_next]
	_next = (_next + 1) % _pool.size()
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.play()


func _find(event_name: StringName) -> AudioStream:
	if _cache.has(event_name):
		return _cache[event_name]
	var stream: AudioStream = null
	for ext in EXTENSIONS:
		var path: String = AUDIO_DIR + String(event_name) + "." + str(ext)
		if ResourceLoader.exists(path):
			stream = load(path)
			break
	_cache[event_name] = stream
	return stream
