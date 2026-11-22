class_name BrandBanner
extends PanelContainer
## Banner: info (white stripe, info icon) or warning (red stripe and title,
## warning icon) with a title and a body that wraps. Used for thin ice,
## benched, suspended, fatigue and notices. Scene: scenes/ui/brand/banner.tscn.

@export var kind := "info"
@export var title := "Notice"
@export_multiline var body := ""


func _ready() -> void:
	var warn := kind == "warning"
	theme_type_variation = "BannerWarning" if warn else "BannerInfo"
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_3)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(h)
	var ic := BrandIcons.rect("warning" if warn else "info", Brand.RED_HOT if warn else Brand.WHITE, 44)
	ic.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	h.add_child(ic)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", Brand.SPACE_1)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(v)
	var t := BrandTheme.label(title, "Subhead", Brand.RED_HOT if warn else Brand.WHITE)
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(t)
	if body != "":
		var b := BrandTheme.label(body, "Body")
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(b)
