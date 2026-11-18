extends Node
## Autoload "Music": loops res://audio/music.ogg (or .mp3/.wav) on the "Music"
## bus if the file exists. Volume comes from Settings > Music volume.
## No file = silence, nothing breaks.

const PATHS := ["res://audio/music.ogg", "res://audio/music.mp3", "res://audio/music.wav"]

var _player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for path in PATHS:
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path)
			if "loop" in stream:
				stream.set("loop", true)
			_player = AudioStreamPlayer.new()
			_player.stream = stream
			_player.bus = &"Music"
			add_child(_player)
			_player.play()
			return
