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
var _icon: TextureRect
var _extra: VBoxContainer


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = UiKit.theme()
	add_child(root)

	# Broadcast lower-third: icon tile + title strip + big name.
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.custom_minimum_size.x = 600
	root.add_child(_panel)
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_theme_constant_override("separation", 18)
	_panel.add_child(h)
	_icon = TextureRect.new()
	_icon.custom_minimum_size = Vector2(64, 64)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(_icon)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override("separation", 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	_title = UiKit.label("", 24, UiKit.ACCENT, UiTokens.FONT_DISPLAY)
	v.add_child(_title)
	_body = UiKit.label("", 36, Color.WHITE, UiTokens.FONT_BANNER)
	v.add_child(_body)
	_extra = VBoxContainer.new()
	_extra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_extra.custom_minimum_size.x = 460
	v.add_child(_extra)
	# Fixed text width so the wrapped height is right when the panel is sized.
	_title.custom_minimum_size.x = 460
	_body.custom_minimum_size.x = 460
	_panel.visible = false

	GameState.achievement_unlocked.connect(_on_achievement)


## icon: a UiIcons id ("achievements", "charisma"...).
func show_message(title: String, body: String, icon := "info") -> void:
	_queue.append([title, body, icon, null, SHOW_TIME])
	if not _busy:
		_next()


## A toast with something under the body (e.g. a minor scenario choice's
## stat chips), held for `hold` seconds. `extra` is freed when it's done.
func show_with(title: String, body: String, extra: Control, icon := "info", hold := SHOW_TIME) -> void:
	_queue.append([title, body, icon, extra, hold])
	if not _busy:
		_next()


## How many toasts are showing or waiting (tests).
func pending() -> int:
	return _queue.size() + (1 if _busy else 0)


func _on_achievement(def: Dictionary) -> void:
	UiKit.feedback(&"achievement")
	show_message("ACHIEVEMENT UNLOCKED", str(def.get("name", "")), "achievements")


func _next() -> void:
	if _queue.is_empty():
		_busy = false
		_panel.visible = false
		return
	_busy = true
	var item: Array = _queue.pop_front()
	_title.text = item[0]
	_body.text = item[1]
	_body.visible = str(item[1]) != ""
	for ch in _extra.get_children():
		ch.queue_free()
	var extra: Variant = item[3] if item.size() > 3 else null
	if extra is Control:
		_ignore_mouse(extra)
		_extra.add_child(extra)
	_extra.visible = extra is Control
	# Colors follow the current palette (Career stage or default).
	# Broadcast style: black, a red stripe, a clipped corner, white title.
	var box := ClippedBox.new()
	box.bg = Brand.INK_1
	box.stroke = Brand.LINE
	box.stroke_width = Brand.STROKE
	box.stripe = Brand.RED
	box.stripe_width = Brand.STRIPE * 2
	box.cut_br = Brand.CUT
	box.content_margin_left = 26 + Brand.STRIPE * 2
	box.content_margin_right = 30
	box.content_margin_top = 14
	box.content_margin_bottom = 14
	_panel.add_theme_stylebox_override("panel", box)
	_title.add_theme_color_override("font_color", Brand.WHITE)
	_icon.texture = UiIcons.texture(str(item[2]) if item.size() > 2 else "info", Brand.RED_HOT, 64)
	_panel.visible = true
	_panel.reset_size()
	var vw := get_viewport().get_visible_rect().size.x
	var x := (vw - _panel.size.x) * 0.5
	_panel.position = Vector2(-_panel.size.x - 40.0, 140.0)
	# Slides in from the left like a broadcast graphic, holds, slides out right.
	# Unaffected by slow motion (Engine.time_scale) and by pause.
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_property(_panel, "position:x", x, SLIDE_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(float(item[4]) if item.size() > 4 else SHOW_TIME)
	tw.tween_property(_panel, "position:x", vw + 40.0, SLIDE_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(_next)


static func _ignore_mouse(n: Node) -> void:
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for ch in n.get_children():
		_ignore_mouse(ch)
