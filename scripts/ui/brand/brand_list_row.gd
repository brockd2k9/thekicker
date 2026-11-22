class_name BrandListRow
extends Button
## A tappable list row: icon, title (one line, cut off with "..." when long),
## an optional subtitle, a value on the right and a chevron. A divider under
## each row; pressed adds a red stripe. Scene: scenes/ui/brand/list_row.tscn.

@export var title := "Row"
@export var subtitle := ""
@export var value := ""
@export var icon_name := ""
@export var chevron := true

var _title: Label
var _sub: Label
var _value: Label
var _margin: MarginContainer


func _ready() -> void:
	theme_type_variation = "ListRow"
	text = ""
	custom_minimum_size.y = Brand.ROW_H
	var m := MarginContainer.new()
	_margin = m
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.add_theme_constant_override("margin_left", Brand.PAD_X)
	m.add_theme_constant_override("margin_right", Brand.SPACE_3)
	add_child(m)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_3)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.add_child(h)
	if icon_name != "":
		var ic := BrandIcons.rect(icon_name, Brand.GREY, 40)
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(ic)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(v)
	# Long names wrap (never cut off); the row grows to fit.
	_title = BrandTheme.label(title, "BodyStrong")
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_title)
	if subtitle != "":
		_sub = BrandTheme.label(subtitle, "Caption")
		_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(_sub)
	if value != "":
		_value = BrandTheme.label(value, "Subhead")
		_value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(_value)
	if chevron:
		var ch := BrandIcons.rect("next", Brand.GREY, 40)
		ch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(ch)
	_tint()
	# A Button doesn't size to its children: grow with the content (wrapped titles).
	m.minimum_size_changed.connect(_fit)
	_fit.call_deferred()


func _fit() -> void:
	var need := _margin.get_combined_minimum_size().y + Brand.SPACE_3 * 2
	custom_minimum_size.y = maxf(Brand.ROW_H, need)


func _notification(what: int) -> void:
	if what == NOTIFICATION_DISABLED or what == NOTIFICATION_ENABLED:
		_tint()


func _tint() -> void:
	if _title == null:
		return
	var off := disabled
	_title.add_theme_color_override("font_color", Brand.GREY_DIM if off else Brand.WHITE)
	if _value != null:
		_value.add_theme_color_override("font_color", Brand.GREY_DIM if off else Brand.WHITE)


## Gallery: shows a state without interaction.
func preview_state(state: String) -> void:
	disabled = state == "disabled"
	_tint()
	match state:
		"hover", "pressed":
			add_theme_stylebox_override("normal", get_theme_stylebox(state))
		"focus":
			var b := get_theme_stylebox("normal") as ClippedBox
			add_theme_stylebox_override("normal", b.with({"stroke": Brand.WHITE}))
