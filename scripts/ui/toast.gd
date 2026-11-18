extends CanvasLayer
## Autoload "Toast": slides a banner in from the top. Shows achievement unlocks
## automatically (from GameState.achievement_unlocked), on any screen.
## Call Toast.show_message("Title", "Body") for anything else.
## Never blocks input: every control ignores the mouse.

const SHOW_TIME := 2.6
const SLIDE_TIME := 0.3

var _queue: Array[Array] = []
var _busy := false
var _panel: PanelContainer
var _title: Label
var _body: Label


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = UiKit.theme()
	add_child(root)

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.05, 0.13, 0.09, 0.95)
	box.border_color = UiKit.ACCENT
	box.set_border_width_all(4)
	box.set_corner_radius_all(16)
	box.content_margin_left = 28
	box.content_margin_right = 28
	box.content_margin_top = 16
	box.content_margin_bottom = 16
	_panel.add_theme_stylebox_override("panel", box)
	_panel.custom_minimum_size.x = 560
	root.add_child(_panel)

	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override("separation", 2)
	_panel.add_child(v)
	_title = UiKit.label("", 24, UiKit.ACCENT)
	_title.autowrap_mode = TextServer.AUTOWRAP_OFF
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_title)
	_body = UiKit.label("", 34)
	_body.autowrap_mode = TextServer.AUTOWRAP_OFF
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_body)
	_panel.visible = false

	GameState.achievement_unlocked.connect(_on_achievement)


func show_message(title: String, body: String) -> void:
	_queue.append([title, body])
	if not _busy:
		_next()


func _on_achievement(def: Dictionary) -> void:
	Sfx.play(&"achievement")
	show_message("ACHIEVEMENT UNLOCKED", str(def.get("name", "")))


func _next() -> void:
	if _queue.is_empty():
		_busy = false
		_panel.visible = false
		return
	_busy = true
	var item: Array = _queue.pop_front()
	_title.text = item[0]
	_body.text = item[1]
	_panel.visible = true
	_panel.reset_size()
	_panel.position.x = (get_viewport().get_visible_rect().size.x - _panel.size.x) * 0.5
	var top := 150.0
	var hidden_y := -_panel.size.y - 20.0
	_panel.position.y = hidden_y
	# Unaffected by slow motion (Engine.time_scale) and by pause.
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_property(_panel, "position:y", top, SLIDE_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(SHOW_TIME)
	tw.tween_property(_panel, "position:y", hidden_y, SLIDE_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(_next)
