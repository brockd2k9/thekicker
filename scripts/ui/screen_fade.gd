extends CanvasLayer
## Autoload "ScreenFade": short fade-to-dark between screens. Screens.go()
## calls ScreenFade.go(path): fade out (UiTokens.FADE_OUT), change scene,
## then the new screen fades in (UiKit.build_frame slides its content up).
## Unaffected by pause and slow motion. Blocks taps only while fading.

var _rect: ColorRect
var _busy := false
## Target of the fade in progress (a second go() before the switch replaces it).
var _path := ""
var _switched := false


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Brand.INK_0
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.modulate.a = 0.0
	add_child(_rect)


func go(path: String) -> void:
	if _busy:
		if _switched:
			# A screen redirected while fading in (e.g. a career screen sending
			# you to the current step): switch right away.
			get_tree().change_scene_to_file.call_deferred(path)
		else:
			_path = path
		return
	_busy = true
	_switched = false
	_path = path
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	UiKit.feedback(&"ui_transition")
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_property(_rect, "modulate:a", 1.0, UiTokens.FADE_OUT)
	tw.tween_callback(func() -> void:
		_switched = true
		get_tree().change_scene_to_file(_path))
	tw.tween_interval(0.02)
	tw.tween_property(_rect, "modulate:a", 0.0, UiTokens.FADE_IN)
	tw.tween_callback(func() -> void:
		_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_busy = false)
