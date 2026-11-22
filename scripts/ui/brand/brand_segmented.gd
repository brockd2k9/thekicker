class_name BrandSegmented
extends PanelContainer
## Segmented toggle (one of a few options, e.g. Light / Normal / Hard): a dark
## track, the selected segment white with black text.
## Scene: scenes/ui/brand/segmented_toggle.tscn.

signal option_selected(index: int)

@export var options: PackedStringArray = ["One", "Two"]
@export var selected := 0
## Options that can't be picked right now.
@export var disabled_options: PackedInt32Array = []

var _buttons: Array[Button] = []


func _ready() -> void:
	theme_type_variation = "SegmentTrack"
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_1)
	add_child(row)
	var group := ButtonGroup.new()
	for i in options.size():
		var b := Button.new()
		b.theme_type_variation = "SegmentButton"
		b.text = options[i].to_upper()
		b.toggle_mode = true
		b.button_group = group
		b.custom_minimum_size.y = Brand.TAP
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.clip_text = true
		b.disabled = i in disabled_options
		b.set_pressed_no_signal(i == selected)
		b.pressed.connect(func() -> void:
			selected = i
			BrandMotion.press(b)
			option_selected.emit(i))
		row.add_child(b)
		_buttons.append(b)


## Gallery: one segment as hovered / focused.
func preview_state(i: int, state: String) -> void:
	if i >= _buttons.size():
		return
	var b := _buttons[i]
	if state in ["hover", "focus"]:
		b.add_theme_stylebox_override("normal", b.get_theme_stylebox(state))
		b.add_theme_color_override("font_color", Brand.WHITE)
