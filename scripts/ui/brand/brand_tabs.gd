class_name BrandTabs
extends VBoxContainer
## Tab bar: condensed uppercase tabs over a hairline; a red underline slides
## to the selected tab (Brand.T_FAST). Scene: scenes/ui/brand/tab_bar.tscn.

signal tab_selected(index: int)

@export var tabs: PackedStringArray = ["Tab"]:
	set(v):
		tabs = v
		if is_inside_tree():
			_build()
@export var selected := 0

var _row: HBoxContainer
var _track: Control
var _marker: ColorRect
var _buttons: Array[Button] = []


func _ready() -> void:
	add_theme_constant_override("separation", 0)
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", 0)
	add_child(_row)
	_track = Control.new()
	_track.custom_minimum_size.y = Brand.RULE
	_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_track)
	var hair := ColorRect.new()
	hair.color = Brand.LINE
	hair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hair.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hair.offset_top = -1
	_track.add_child(hair)
	_marker = ColorRect.new()
	_marker.color = Brand.RED
	_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_track.add_child(_marker)
	_build()
	_row.resized.connect(func() -> void: _place_marker(false))


func _build() -> void:
	for b in _buttons:
		b.queue_free()
	_buttons.clear()
	for i in tabs.size():
		var b := Button.new()
		b.theme_type_variation = "TabButton"
		b.text = tabs[i].to_upper()
		b.toggle_mode = true
		b.custom_minimum_size.y = Brand.TAP
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.clip_text = true
		b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		b.pressed.connect(select.bind(i, true))
		_row.add_child(b)
		_buttons.append(b)
	select(clampi(selected, 0, maxi(tabs.size() - 1, 0)), false)


## Selects tab `i` (emit: tell listeners, as a tap does).
func select(i: int, emit := false) -> void:
	selected = i
	for j in _buttons.size():
		_buttons[j].set_pressed_no_signal(j == i)
		_buttons[j].add_theme_color_override("font_color", Brand.WHITE if j == i else Brand.GREY)
	_place_marker(true)
	if emit:
		tab_selected.emit(i)


## Gallery: one tab as hovered / focused / disabled.
func preview_state(i: int, state: String) -> void:
	if i >= _buttons.size():
		return
	var b := _buttons[i]
	match state:
		"disabled":
			b.disabled = true
		"hover", "focus":
			b.add_theme_stylebox_override("normal", b.get_theme_stylebox(state))
			b.add_theme_color_override("font_color", Brand.WHITE)


func _place_marker(animate: bool) -> void:
	if _buttons.is_empty() or _marker == null:
		return
	var b := _buttons[clampi(selected, 0, _buttons.size() - 1)]
	var x := b.position.x
	var w := b.size.x
	if not animate or not is_visible_in_tree():
		_marker.position = Vector2(x, 0)
		_marker.size = Vector2(w, Brand.RULE)
		return
	var tw := _marker.create_tween().set_ignore_time_scale(true).set_parallel(true)
	tw.tween_property(_marker, "position:x", x, Brand.T_FAST).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(_marker, "size", Vector2(w, Brand.RULE), Brand.T_FAST).set_trans(Tween.TRANS_CUBIC)
