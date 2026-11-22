class_name BrandButton
extends Button
## Primary (red) or secondary (black) action button: condensed uppercase text,
## clipped corners, an optional icon, a quick press (scale + darker fill).
## Scenes: scenes/ui/brand/primary_button.tscn, secondary_button.tscn.
## States come from the theme: normal, hover, focus, pressed, disabled.

## "primary" or "secondary".
@export var kind := "primary":
	set(v):
		kind = v
		theme_type_variation = "PrimaryButton" if v == "primary" else "SecondaryButton"
## A BrandIcons name ("" = none).
@export var icon_name := "":
	set(v):
		icon_name = v
		_refresh_icon()


func _ready() -> void:
	theme_type_variation = "PrimaryButton" if kind == "primary" else "SecondaryButton"
	custom_minimum_size.y = maxf(custom_minimum_size.y, Brand.BUTTON_H)
	text = text.to_upper()
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	clip_text = true
	_refresh_icon()
	button_down.connect(func() -> void: BrandMotion.press(self))
	resized.connect(func() -> void: pivot_offset = size * 0.5)


func _refresh_icon() -> void:
	icon = BrandIcons.texture(icon_name, Brand.WHITE, 40) if icon_name != "" else null


## Gallery: shows a state without interaction ("normal", "hover", "pressed",
## "focus", "disabled").
func preview_state(state: String) -> void:
	disabled = state == "disabled"
	match state:
		"hover", "pressed":
			add_theme_stylebox_override("normal", get_theme_stylebox(state))
		"focus":
			var b := get_theme_stylebox("normal") as ClippedBox
			add_theme_stylebox_override("normal", b.with({"stroke": Brand.WHITE, "stroke_width": 3}))
