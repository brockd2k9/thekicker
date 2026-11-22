class_name BrandStatTile
extends PanelContainer
## A number with a label: the eyebrow caption, a big white numeral (counts up
## when shown), an optional unit and a delta. highlight: a red rule on top
## (the key number of a screen). Scene: scenes/ui/brand/stat_tile.tscn.

@export var caption := "Stat"
@export var value := 0.0
## Number format: "%d", "%s" (with commas), "%.1f".
@export var number_format := "%d"
@export var unit := ""
## "+3" / "-2": shown under the number (white gain, red loss).
@export var delta := ""
@export var highlight := false
@export var count_up := true

var _num: Label
var _row: HBoxContainer


func _ready() -> void:
	theme_type_variation = "TileHighlight" if highlight else "Tile"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)
	var cap := BrandTheme.label(caption, "Eyebrow")
	cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(cap)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_2)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(row)
	_num = BrandTheme.label(BrandMotion.number_text(value, number_format), "Display")
	row.add_child(_num)
	_row = row
	if unit != "":
		var u := BrandTheme.label(unit, "Subhead", Brand.GREY)
		u.size_flags_vertical = Control.SIZE_SHRINK_END
		row.add_child(u)
	if delta != "":
		v.add_child(BrandTheme.label(delta, "Caption", Brand.RED_HOT if delta.begins_with("-") else Brand.WHITE))
	if count_up and value != 0.0:
		BrandMotion.count_up(_num, 0.0, value, number_format)
	resized.connect(_fit)
	_fit.call_deferred()


## Big numbers shrink (from Display down to Heading size) until the final
## value fits the tile: long numbers are never cut off.
func _fit() -> void:
	if _num == null:
		return
	var final_text := BrandMotion.number_text(value, number_format)
	var font := _num.get_theme_font("font")
	var room := size.x - Brand.PAD_X * 2 - (_row.get_combined_minimum_size().x - _num.get_combined_minimum_size().x)
	var px := int(Brand.TYPE["Display"][1])
	var floor_px := int(Brand.TYPE["Heading"][1])
	while px > floor_px and font.get_string_size(final_text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x > room:
		px -= 4
	_num.add_theme_font_size_override("font_size", px)
	_num.custom_minimum_size.x = font.get_string_size(final_text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x


## Sets the number (counting up from the old one).
func set_value(v: float) -> void:
	var old := value
	value = v
	if _num != null:
		BrandMotion.count_up(_num, old, v, number_format)
