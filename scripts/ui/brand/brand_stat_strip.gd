class_name BrandStatStrip
extends PanelContainer
## A strip of small stats in one row (a kicker's game or season line): each
## cell a caption over a number, hairlines between. set_cells([[caption,
## value], ...]); a changed value flashes its cell red (scoring).
## Scene: scenes/ui/brand/stat_strip.tscn.

var _row: HBoxContainer
var _cells: Array = []  # [{caption: Label, value: Label, box: Control}]


## The row exists from the start, so cells can be set before the strip is
## added to the tree.
func _init() -> void:
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", Brand.SPACE_2)
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_row)


func _ready() -> void:
	theme_type_variation = "CardRaised"
	add_theme_stylebox_override("panel", (get_theme_stylebox("panel", "CardRaised") as ClippedBox).with(
		{"content_margin_top": Brand.SPACE_2, "content_margin_bottom": Brand.SPACE_2,
		"content_margin_left": Brand.SPACE_3, "content_margin_right": Brand.SPACE_3}))
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## cells: [[caption, value text], ...]. Same captions: values update in place
## (and flash when they change).
func set_cells(cells: Array) -> void:
	if _row == null:
		return
	if cells.size() != _cells.size():
		for ch in _row.get_children():
			ch.queue_free()
		_cells.clear()
		for i in cells.size():
			if i > 0:
				var div := ColorRect.new()
				div.color = Brand.LINE
				div.custom_minimum_size.x = 1
				div.mouse_filter = Control.MOUSE_FILTER_IGNORE
				_row.add_child(div)
			var v := VBoxContainer.new()
			v.add_theme_constant_override("separation", 0)
			v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			v.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_row.add_child(v)
			var cap := BrandTheme.label("", "Eyebrow")
			cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			v.add_child(cap)
			var val := BrandTheme.label("", "Subhead", Brand.WHITE)
			val.add_theme_font_override("font", BrandTheme.font(Brand.FONT_NUMBER))
			val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			v.add_child(val)
			_cells.append({"caption": cap, "value": val, "box": v})
	for i in cells.size():
		var c: Dictionary = _cells[i]
		(c["caption"] as Label).text = str(cells[i][0])
		var val: Label = c["value"]
		var changed := val.text != "" and val.text != str(cells[i][1])
		val.text = str(cells[i][1])
		if changed:
			BrandMotion.flash(c["box"])
