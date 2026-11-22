class_name BrandCard
extends PanelContainer
## Panel / card: black with a clipped top-right corner, a thin inner stroke and
## the faint diagonal texture. variant: "card" (base), "raised", "accent" (a
## red rule on top: the card that matters most on a screen). team_color: a
## small stripe of the team's color on the left. Content goes in `content`.
## Scene: scenes/ui/brand/card.tscn.

@export var variant := "card"
@export var team_color := Color(0, 0, 0, 0)

var content: VBoxContainer


## The content box exists from the start, so a card can be filled before it
## is added to the tree.
func _init() -> void:
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", Brand.SPACE_2)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)


func _ready() -> void:
	theme_type_variation = {"raised": "CardRaised", "accent": "CardAccent"}.get(variant, "Card")
	if team_color.a > 0.0:
		var b := (get_theme_stylebox("panel") as ClippedBox).with({"stripe": Brand.team_accent(team_color)})
		b.content_margin_left += Brand.STRIPE
		add_theme_stylebox_override("panel", b)
