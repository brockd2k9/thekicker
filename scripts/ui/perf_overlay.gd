extends CanvasLayer
## Autoload "PerfOverlay": a small frame-rate readout in the bottom-left
## corner, on every screen, when Settings > Show Frame Rate is on.
## "58 fps  17.2 ms (worst 24.0)": the average over the last half second and
## the slowest frame in it. Never takes input.

const WINDOW_SEC := 0.5

var _label: Label
var _frames := 0
var _elapsed := 0.0
var _worst := 0.0
var _last_usec := 0


func _ready() -> void:
	layer = 110
	process_mode = Node.PROCESS_MODE_ALWAYS
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 20)
	_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("outline_size", 6)
	_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_label.position += Vector2(10, -6)
	add_child(_label)
	GameState.settings_changed.connect(_refresh)
	_refresh.call_deferred()


func _refresh() -> void:
	visible = GameState.settings.graphics.show_fps
	set_process(visible)
	_frames = 0
	_elapsed = 0.0
	_worst = 0.0
	_last_usec = 0


func _process(_delta: float) -> void:
	# Real time, not the engine's (the result beat runs in slow motion).
	var now := Time.get_ticks_usec()
	if _last_usec == 0:
		_last_usec = now
		return
	var dt := float(now - _last_usec) / 1000000.0
	_last_usec = now
	_frames += 1
	_elapsed += dt
	_worst = maxf(_worst, dt)
	if _elapsed < WINDOW_SEC:
		return
	_label.text = "%d fps  %.1f ms (worst %.1f)" % [roundi(_frames / _elapsed),
		_elapsed / _frames * 1000.0, _worst * 1000.0]
	_frames = 0
	_elapsed = 0.0
	_worst = 0.0
