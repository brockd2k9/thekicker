extends Node
## Thumb Drill (Career Debug -> Thumb Drill): measures a real thumb in the real
## kick scene, so the simulator's swipe skill levels can be fitted to it.
##
## 60 field goals: 20 each from 30, 40 and 50 yards, calm wind, pressure 0.4,
## pro posts, and a neutral kicker (no Career modifiers: the same kick for
## everyone, so only the thumb varies). The kick scene is the normal one,
## unchanged; this screen only listens to its signals (swipe released, kick
## struck, ball at the goal plane, kick resolved).
##
## Recorded per kick: the result, where the ball crossed the goal line, and the
## swipe (flick speed, length, duration, tilt, bow, finish turn, crookedness,
## power, the crooked-swipe penalty, when in the kick window it was released,
## the wobble at that moment, and the path as 8 points). At the end: a summary,
## the data as text (Copy, or select it), saved on the device too.

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")
const DISTANCES := [30, 40, 50]
const PER_DISTANCE := 20
const PRESSURE := 0.4
## Where the last runs are kept (the newest first, at most SAVE_RUNS).
const SAVE_PATH := "user://thumb_drill.json"
const SAVE_RUNS := 5
## The columns of each kick row in the results.
const COLS := ["yd", "made", "out", "cross_x", "cross_y", "speed", "len", "dur", "tilt", "bow", "finish",
	"crooked", "penalty", "power", "t_window", "window", "wobble", "path"]

var _mode := DrillMode.new()
var _game: Node
var _rows: Array = []
var _swipe: Swipe
var _swipe_frame := -1
var _struck := false
var _kick: Dictionary = {}
var _started := ""


## The drill's kicks in order: 20 from 30, then 40, then 50 yards.
class DrillMode:
	extends KickMode
	var index := 0

	func id() -> StringName:
		return &"thumb_drill"

	func total() -> int:
		return DISTANCES.size() * PER_DISTANCE

	func yards() -> int:
		return int(DISTANCES[mini(index / PER_DISTANCE, DISTANCES.size() - 1)])

	func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
		var s := KickSituation.new()
		s.distance_yards = yards()
		s.wind_mph = 0.0
		s.pressure = PRESSURE
		s.label = "Thumb Drill  %d / %d" % [index + 1, total()]
		wind.set_conditions(rng, tuning, 0.0, 0.0)
		return s

	func wants_next_kick() -> bool:
		return index < total()


func _ready() -> void:
	_started = Time.get_datetime_string_from_system()
	_game = FIELD_GOAL.instantiate()
	_game.mode = _mode
	_game.modifiers = KickModifiers.new()  # neutral: no Career effects
	var t := CareerTuning.get_default()
	_game.set_look({"posts": "pro", "width": t.goal_width_pro})
	add_child(_game)
	_game.get_node("SwipeInput").released.connect(_on_released)
	_game.kick_struck.connect(_on_struck)
	_game.get_node("Ball").reached_goal_plane.connect(_on_crossed)
	GameState.kick_resolved.connect(_on_kick_resolved)
	var overlay := PlayOverlay.new()
	overlay.quit_text = "Quit Drill"
	overlay.quit_path = back_path()
	add_child(overlay)
	_update_scoreboard()


## Career Debug in debug builds (where its button is); the Career menu otherwise.
static func back_path() -> String:
	return Screens.CAREER_DEBUG if OS.is_debug_build() else Screens.CAREER


func _exit_tree() -> void:
	if GameState.kick_resolved.is_connected(_on_kick_resolved):
		GameState.kick_resolved.disconnect(_on_kick_resolved)


## Every finished swipe. The scene hears it first (and may strike the kick
## before this runs), so either order fills the kick's swipe fields.
func _on_released(swipe: Swipe) -> void:
	_swipe = swipe
	_swipe_frame = Engine.get_process_frames()
	if _struck and not _kick.has("speed"):
		_fill_swipe(swipe)


## The kick is struck: what only the scene knows right now (penalty, timing, wobble).
func _on_struck() -> void:
	_struck = true
	var window := float(_game._window_total)
	_kick = {"yd": _mode.yards(), "made": 0, "out": "", "cross_x": null, "cross_y": null,
		"penalty": snappedf(float(_game.last_shot_penalty), 0.01),
		"t_window": snappedf(window - float(_game._window_left), 0.01), "window": snappedf(window, 0.01),
		"wobble": snappedf(float(_game.pressure.wobble_deg()), 0.01)}
	if _swipe != null and _swipe_frame == Engine.get_process_frames():
		_fill_swipe(_swipe)


func _fill_swipe(sw: Swipe) -> void:
	var diff: KickDifficulty = _game.difficulty
	_kick.merge({"speed": snappedf(sw.flick_speed_norm(), 0.01), "len": snappedf(sw.length_norm(), 0.001),
		"dur": snappedf(sw.duration, 0.001), "tilt": snappedf(sw.tilt_deg(), 0.1),
		"bow": snappedf(sw.bow(), 0.001), "finish": snappedf(sw.finish_angle_deg(), 0.1),
		"crooked": snappedf(sw.crookedness(diff.crooked_angle_deg, diff.crooked_bow), 0.01),
		"power": snappedf(_game.kicker.power_from_swipe(sw, _game.tuning), 0.01), "path": _path(sw)}, true)


## Where the ball crossed the goal line. The scene judges the kick right
## there, so the kick may already be filed: fill whichever is waiting.
func _on_crossed(at: Vector3) -> void:
	var k: Dictionary = _kick if _struck else (_rows[-1] if not _rows.is_empty() else {})
	if k.has("cross_x") and k["cross_x"] == null:
		k["cross_x"] = snappedf(at.x, 0.01)
		k["cross_y"] = snappedf(at.y, 0.01)


func _on_kick_resolved(r: KickReport) -> void:
	if _kick.is_empty():
		# Blocked or never kicked (the window ran out): a miss with no swipe.
		_kick = {"yd": _mode.yards(), "out": "", "made": 0}
	_kick["made"] = 1 if r.made else 0
	_kick["out"] = str(KickResult.Outcome.keys()[r.outcome])
	_rows.append(_kick)
	_kick = {}
	_struck = false
	_swipe = null
	_mode.index += 1
	_update_scoreboard()
	if _mode.index >= _mode.total():
		_finish.call_deferred()


func _update_scoreboard() -> void:
	var made := _rows.filter(func(k): return int(k.get("made", 0)) == 1).size()
	_game.hud.set_scoreboard("THUMB DRILL %d / %d" % [mini(_mode.index + 1, _mode.total()), _mode.total()],
		"%d YD  ·  MADE %d" % [_mode.yards(), made])


## The swipe path as 8 points from the start, in screen heights (x right, y up).
static func _path(sw: Swipe) -> Array:
	var out: Array = []
	var pts := sw.points
	if pts.size() < 2:
		pts = PackedVector2Array([sw.start, sw.end])
	for i in 8:
		var p: Vector2 = pts[roundi(float(i) / 7.0 * (pts.size() - 1))]
		var d := (p - sw.start) / sw.screen_height
		out.append([snappedf(d.x, 0.001), snappedf(-d.y, 0.001)])
	return out


## Results text: a header line, then one JSON array per kick (COLS order).
func results_text() -> String:
	var head := {"drill": "thumb", "v": 1, "date": _started, "os": OS.get_name(),
		"web": OS.has_feature("web"), "screen": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y],
		"posts": "pro", "pressure": PRESSURE, "wind": 0, "kicker": "neutral", "cols": COLS}
	var lines := PackedStringArray([JSON.stringify(head)])
	for k in _rows:
		lines.append(JSON.stringify(COLS.map(func(c): return k.get(c))))
	return "\n".join(lines)


## Made / attempted by distance: {30: [made, att], ...}.
func summary() -> Dictionary:
	var out := {}
	for d in DISTANCES:
		var ks := _rows.filter(func(k): return int(k.get("yd", 0)) == d)
		out[d] = [ks.filter(func(k): return int(k.get("made", 0)) == 1).size(), ks.size()]
	return out


func _finish() -> void:
	var text := results_text()
	_save(text)
	_game.queue_free()
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	var v := UiKit.modal(layer, "Thumb Drill done")
	var sum := summary()
	var parts := PackedStringArray()
	for d in DISTANCES:
		parts.append("%d yd: %d / %d" % [d, sum[d][0], sum[d][1]])
	var l := UiKit.label("  ·  ".join(parts), 30)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(l)
	var how := UiKit.label("Tap Copy, then paste the results into the chat. If Copy doesn't work, " +
		"select the text below. Saved on this device too.", 22, UiKit.MUTED)
	how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(how)
	var box := TextEdit.new()
	box.text = text
	box.editable = false
	box.custom_minimum_size = Vector2(0, 360)
	box.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	box.add_theme_font_size_override("font_size", 16)
	v.add_child(box)
	var status := UiKit.label("", 22, UiKit.GOOD)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(status)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	v.add_child(row)
	var copy := UiKit.primary("Copy", func() -> void:
		DisplayServer.clipboard_set(text)
		box.select_all()
		status.text = "Copied (%d kicks)." % _rows.size())
	var back := UiKit.button("Back", func() -> void: Screens.go(back_path()))
	for b in [copy, back]:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)


## Keeps the last SAVE_RUNS runs on the device (user://thumb_drill.json).
func _save(text: String) -> void:
	var runs: Array = []
	if FileAccess.file_exists(SAVE_PATH):
		var old: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
		if old is Array:
			runs = old
	runs.push_front(text)
	runs.resize(mini(runs.size(), SAVE_RUNS))
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(runs))
