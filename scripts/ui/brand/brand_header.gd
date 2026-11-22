class_name BrandHeader
extends VBoxContainer
## Screen header bar: a small eyebrow line, the big condensed title, then a
## short red rule on a full-width hairline. A slot on the right of the title
## (`side`) holds a chip or a score. Scene: scenes/ui/brand/header_bar.tscn.

@export var eyebrow := ""
@export var title := "Title"

var side: HBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if eyebrow != "":
		add_child(BrandTheme.label(eyebrow, "Eyebrow"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_3)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	var t := BrandTheme.label(title, "Title")
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # long titles wrap, never cut off
	row.add_child(t)
	side = HBoxContainer.new()
	side.add_theme_constant_override("separation", Brand.SPACE_2)
	side.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	side.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(side)
	# The rule: a short red bar sitting on a hairline.
	var rule := Control.new()
	rule.custom_minimum_size.y = Brand.RULE
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rule)
	var hair := ColorRect.new()
	hair.color = Brand.LINE
	hair.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hair.offset_top = -1
	hair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.add_child(hair)
	var red := ColorRect.new()
	red.color = Brand.RED
	red.size = Vector2(96, Brand.RULE)
	red.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.add_child(red)
