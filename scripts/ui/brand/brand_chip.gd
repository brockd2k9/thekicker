class_name BrandChip
extends PanelContainer
## Chip / tag: a small clipped label with an optional icon.
## kind: "neutral" (grey block), "outline", "red" (one key highlight), "team"
## (a stripe of team_color). disabled: dimmed. Scene: scenes/ui/brand/chip.tscn.

@export var text := "Tag"
@export var kind := "neutral"
@export var icon_name := ""
@export var team_color := Color(0, 0, 0, 0)
@export var disabled := false

## Text longer than this wraps in a wide chip (WIDE px) instead of running
## off the screen.
const LONG := 30
const WIDE := 460.0


func _ready() -> void:
	theme_type_variation = {"outline": "ChipOutline", "red": "ChipRed", "team": "ChipTeam"}.get(kind, "ChipNeutral")
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if kind == "team" and team_color.a > 0.0:
		add_theme_stylebox_override("panel", (get_theme_stylebox("panel") as ClippedBox).with(
			{"stripe": Brand.team_accent(team_color)}))
	var fg := Brand.GREY_DIM if disabled else Brand.WHITE
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_2)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(h)
	if icon_name != "":
		var ic := BrandIcons.rect(icon_name, fg, 30)
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(ic)
	var l := BrandTheme.label(text, "Eyebrow", fg)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	if text.length() > LONG:
		# A sentence, not a tag: a full-width block that wraps.
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		custom_minimum_size.x = WIDE
	h.add_child(l)
