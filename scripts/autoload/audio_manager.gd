extends Node
## Autoload "AudioManager": situation-based music on the "Music" bus
## (Settings > Music volume).
##
##   AudioManager.play_music(&"training")
##
## Each cue is a file in res://audio/music/ named after the cue:
## audio/music/<cue>.ogg (or .mp3 / .wav), e.g. audio/music/hs_game.ogg.
##
## Loop cues loop until another cue is asked for. One-shot cues
## (championship_win and the stingers) play once, then the music that was
## playing comes back, from where it left off. A loop cue asked for while a
## one-shot plays waits for the one-shot to finish, then comes in.
##
## play_music() crossfades from the current track. Asking for the cue that's
## already playing does nothing (no restart). A cue with no file logs one
## warning and the current music keeps going: nothing breaks.
##
## Layered stems (optional, clutch_kick only for now): any of
## audio/music/clutch_kick_<stem>.ogg for the stems in CUES play in sync with
## clutch_kick.ogg (which is optional once a stem exists). Bring a layer
## in or out with set_stem_level(&"drums", 0.0 .. 1.0).

## Where the music files go.
const MUSIC_DIR := "res://audio/music/"
const EXTENSIONS := ["ogg", "mp3", "wav"]
## Seconds; a cue's own "fade" wins.
const DEFAULT_FADE := 1.2
const SILENT_DB := -80.0

## Every cue: loop (true = loops, false = one-shot), fade (crossfade in, s),
## stems (optional layer names: <cue>_<stem>.<ext>), fallback (another path
## without extension, tried when the cue's own file is missing), resume (a
## loop that picks up where it left off, e.g. the game track after a clutch
## kick, instead of starting over).
const CUES := {
	&"menu": {"loop": true, "fallback": "res://audio/music"},  # the old single music file
	&"training": {"loop": true},
	&"hs_game": {"loop": true, "resume": true},
	&"college_game": {"loop": true, "resume": true},
	&"pro_game": {"loop": true, "resume": true},
	&"playoffs": {"loop": true, "resume": true},
	&"clutch_kick": {"loop": true, "fade": 0.6, "stems": [&"drums", &"bass", &"lead", &"choir"]},
	&"benched": {"loop": true, "resume": true},
	&"draft_day": {"loop": true},
	&"championship_win": {"loop": false, "fade": 0.4},
	&"win": {"loop": false, "fade": 0.3},
	&"loss": {"loop": false, "fade": 0.3},
	&"season_end": {"loop": false, "fade": 0.5},
}

signal cue_changed(cue: StringName)

## The cue on the active player (&"" = none).
var current: StringName = &""

var _players: Array[AudioStreamPlayer] = []
var _tweens: Array = [null, null]
var _active := 0
## The loop cue to come back to when a one-shot ends, and where it was.
var _return_cue: StringName = &""
var _return_pos := 0.0
## cue -> AudioStream (null = no file). Missing cues are looked up again
## each time (cheap), so a file added later is found.
var _cache: Dictionary = {}
## cue -> {stem: index in its AudioStreamSynchronized}
var _stems: Dictionary = {}
var _warned: Dictionary = {}
var _stem_tweens: Dictionary = {}
## "resume" cues: where each was when it faded out.
var _positions: Dictionary = {}


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.bus = &"Music"  # created by GameSettings
		p.volume_db = SILENT_DB
		p.finished.connect(_on_finished.bind(i))
		add_child(p)
		_players.append(p)


func _ready() -> void:
	if OS.is_debug_build():
		var missing := missing_cues()
		if not missing.is_empty():
			print("[AudioManager] no music file yet for: ", ", ".join(missing))


## Crossfade to `cue`. Returns false (and keeps the current music) when the
## cue is unknown or has no file. fade < 0 = the cue's fade.
func play_music(cue: StringName, fade: float = -1.0) -> bool:
	if not CUES.has(cue):
		_warn(cue, "unknown music cue")
		return false
	var info: Dictionary = CUES[cue]
	var fade_s := fade if fade >= 0.0 else float(info.get("fade", DEFAULT_FADE))
	if cue == current and _players[_active].playing:
		return true
	var one_shot := not bool(info.get("loop", true))
	if not one_shot and _one_shot_playing():
		# Let the stinger finish; this cue comes in after it.
		if cue != _return_cue:
			if _stream(cue) == null:
				_warn(cue, "no file in %s" % MUSIC_DIR)
				return false
			_return_cue = cue
			_return_pos = 0.0
		return true
	var stream := _stream(cue)
	if stream == null:
		_warn(cue, "no file in %s" % MUSIC_DIR)
		return false
	if one_shot and not _one_shot_playing():
		_return_cue = current if _players[_active].playing else &""
		_return_pos = _players[_active].get_playback_position() if _return_cue != &"" else 0.0
	var from := float(_positions.get(cue, 0.0)) if bool(info.get("resume", false)) else 0.0
	_crossfade(cue, stream, from, fade_s)
	return true


## Fade the music out (and forget what a one-shot would return to).
func stop_music(fade: float = DEFAULT_FADE) -> void:
	_return_cue = &""
	current = &""
	_fade(_active, 0.0, fade, true)
	cue_changed.emit(current)


## True when `cue` has a file (or, for a stem cue, at least one stem).
func has_cue(cue: StringName) -> bool:
	return CUES.has(cue) and _stream(cue) != null


## Every cue with no file yet (stems don't count: they're optional).
func missing_cues() -> PackedStringArray:
	var out := PackedStringArray()
	for cue in CUES:
		if _stream(cue) == null:
			out.append(String(cue))
	return out


## The stems found for `cue` (empty = none, or a plain file).
func stems_loaded(cue: StringName) -> Array:
	_stream(cue)
	return (_stems.get(cue, {}) as Dictionary).keys()


## A stem layer's level (0 = silent, 1 = full) for the playing cue (or
## `cue`). Returns false if that stem isn't loaded. Stems start at full.
func set_stem_level(stem: StringName, level: float, fade: float = 0.5, cue: StringName = &"") -> bool:
	var c := current if cue == &"" else cue
	var idx: Dictionary = _stems.get(c, {})
	if not idx.has(stem):
		return false
	var sync := _cache.get(c) as AudioStreamSynchronized
	if sync == null:
		return false
	var i: int = idx[stem]
	var key := "%s/%s" % [c, stem]
	var old: Variant = _stem_tweens.get(key)
	if old is Tween and (old as Tween).is_valid():
		(old as Tween).kill()
	var to := clampf(level, 0.0, 1.0)
	var from := db_to_linear(sync.get_sync_stream_volume(i))
	if fade <= 0.0:
		sync.set_sync_stream_volume(i, _db(to))
		return true
	var t := create_tween().set_ignore_time_scale(true)
	t.tween_method(func(v: float) -> void: sync.set_sync_stream_volume(i, _db(v)), from, to, fade)
	_stem_tweens[key] = t
	return true


# --- picking the game cue -------------------------------------------------------------

## The game track for a level: hs_game / college_game / pro_game, or
## playoffs for any postseason game. (Junior college plays college_game,
## a free agent pro_game.)
static func game_cue(stage: String, postseason: bool) -> StringName:
	if postseason:
		return &"playoffs"
	match stage:
		CareerData.STAGE_HIGH_SCHOOL:
			return &"hs_game"
		CareerData.STAGE_COLLEGE, CareerData.STAGE_JUCO:
			return &"college_game"
	return &"pro_game"


## This week's game track for a career (its stage, this week's game).
static func career_game_cue(m: CareerManager) -> StringName:
	return game_cue(m.data.stage, m.is_postseason())


## Is this coach call a clutch kick? Field goals and extra points tagged
## GAME WINNER or TO TIE (GameSim: last two minutes / overtime).
static func is_clutch_call(e: Dictionary) -> bool:
	if not (str(e.get("kind", "")) in ["fg", "pat"]):
		return false
	var label := str(e.get("label", ""))
	return "GAME WINNER" in label or "TO TIE" in label


# --- internals ------------------------------------------------------------------------

func _one_shot_playing() -> bool:
	return current != &"" and not bool(CUES[current].get("loop", true)) and _players[_active].playing


func _crossfade(cue: StringName, stream: AudioStream, from_pos: float, fade_s: float) -> void:
	var old := _active
	if current != &"" and _players[old].playing and bool(CUES[current].get("resume", false)):
		_positions[current] = _players[old].get_playback_position()
	_active = 1 - _active
	var p := _players[_active]
	_kill(_active)
	p.stop()
	p.stream = stream
	p.volume_db = SILENT_DB if fade_s > 0.0 else 0.0
	p.play(from_pos)
	current = cue
	_fade(_active, 1.0, fade_s, false)
	_fade(old, 0.0, fade_s, true)
	cue_changed.emit(cue)


func _fade(i: int, to: float, fade_s: float, stop_after: bool) -> void:
	_kill(i)
	var p := _players[i]
	if not p.playing:
		return
	if fade_s <= 0.0:
		p.volume_db = _db(to)
		if stop_after:
			p.stop()
		return
	var t := create_tween().set_ignore_time_scale(true)
	t.tween_method(func(v: float) -> void: p.volume_db = _db(v), db_to_linear(p.volume_db), to, fade_s)
	if stop_after:
		t.tween_callback(p.stop)
	_tweens[i] = t


func _kill(i: int) -> void:
	var t: Variant = _tweens[i]
	if t is Tween and (t as Tween).is_valid():
		(t as Tween).kill()
	_tweens[i] = null


func _on_finished(i: int) -> void:
	if i != _active or current == &"":
		return
	if bool(CUES[current].get("loop", true)):
		_players[i].play()  # formats without a loop flag (e.g. .wav)
		return
	# A one-shot ended: back to the music before it.
	var back := _return_cue
	var pos := _return_pos
	_return_cue = &""
	_return_pos = 0.0
	var stream := _stream(back) if back != &"" else null
	if stream == null:
		current = &""
		cue_changed.emit(current)
		return
	_crossfade(back, stream, pos, float(CUES[back].get("fade", DEFAULT_FADE)))


static func _db(linear: float) -> float:
	return SILENT_DB if linear <= 0.0001 else maxf(linear_to_db(linear), SILENT_DB)


func _stream(cue: StringName) -> AudioStream:
	if _cache.get(cue) != null:
		return _cache[cue]
	if not CUES.has(cue):
		return null
	var info: Dictionary = CUES[cue]
	var loop := bool(info.get("loop", true))
	var base := _load(MUSIC_DIR + String(cue))
	if base == null and info.has("fallback"):
		base = _load(str(info["fallback"]))
	var parts: Array[AudioStream] = []
	var names: Array = []
	for s in info.get("stems", []):
		var st := _load("%s%s_%s" % [MUSIC_DIR, cue, s])
		if st != null:
			parts.append(st)
			names.append(s)
	var stream: AudioStream = base
	if not parts.is_empty():
		var sync := AudioStreamSynchronized.new()
		var all: Array[AudioStream] = []
		if base != null:
			all.append(base)
		all.append_array(parts)
		sync.stream_count = all.size()
		var idx := {}
		for i in all.size():
			_set_loop(all[i], loop)
			sync.set_sync_stream(i, all[i])
			sync.set_sync_stream_volume(i, 0.0)
			var off := 1 if base != null else 0
			if i >= off:
				idx[names[i - off]] = i
		_stems[cue] = idx
		stream = sync
	elif stream != null:
		_set_loop(stream, loop)
	_cache[cue] = stream
	return stream


## The first of path.ogg / .mp3 / .wav that exists.
static func _load(path_no_ext: String) -> AudioStream:
	for ext in EXTENSIONS:
		var path := "%s.%s" % [path_no_ext, ext]
		if ResourceLoader.exists(path):
			var s := load(path) as AudioStream
			if s != null:
				return s
	return null


static func _set_loop(s: AudioStream, loop: bool) -> void:
	if s is AudioStreamWAV:
		if not loop:
			(s as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_DISABLED
		return  # a looping .wav replays from _on_finished
	if "loop" in s:
		s.set("loop", loop)


func _warn(cue: StringName, why: String) -> void:
	if _warned.has(cue):
		return
	_warned[cue] = true
	push_warning("[AudioManager] music cue '%s': %s; keeping the current music." % [cue, why])
