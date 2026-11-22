class_name BrandPopup
extends Control
## Popup: a dark scrim and a centered card with a red top rule, a title, a
## body and up to two buttons (secondary left, primary right). Opens in
## Brand.T_FAST (fade + a slight scale), closes in Brand.T_PRESS.
## open(host, title, body, primary, on_primary, secondary): the usual call.
## inline = true: just the card, in the flow (the gallery).
## Scene: scenes/ui/brand/popup.tscn.

signal closed(choice: String)

@export var title := "Title"
@export_multiline var body := ""
@export var primary_text := "OK"
@export var secondary_text := ""
@export var inline := false

var card: PanelContainer


static func open(host: Node, t: String, b: String, primary: String, on_primary: Callable,
		secondary := "") -> BrandPopup:
	var p: BrandPopup = load("res://scenes/ui/brand/popup.tscn").instantiate()
	p.title = t
	p.body = b
	p.primary_text = primary
	p.secondary_text = secondary
	p.closed.connect(func(choice: String) -> void:
		if choice == "primary" and on_primary.is_valid():
			on_primary.call())
	host.add_child(p)
	return p


func _ready() -> void:
	if not inline:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_STOP
		var scrim := ColorRect.new()
		scrim.color = Brand.SCRIM
		scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(scrim)
	var center := CenterContainer.new() if not inline else null
	card = PanelContainer.new()
	card.theme_type_variation = "PopupCard"
	card.custom_minimum_size.x = Brand.COLUMN - Brand.SPACE_5 * 2 if not inline else 0.0
	if inline:
		card.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		add_child(card)
		card.resized.connect(func() -> void: custom_minimum_size.y = card.size.y)
	else:
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(center)
		center.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", Brand.SPACE_4)
	card.add_child(v)
	var t := BrandTheme.label(title, "Heading")
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(t)
	if body != "":
		var b := BrandTheme.label(body, "Body")
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(b)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_3)
	v.add_child(row)
	if secondary_text != "":
		row.add_child(_button(secondary_text, "secondary", "secondary"))
	row.add_child(_button(primary_text, "primary", "primary"))
	if not inline:
		modulate.a = 0.0
		card.pivot_offset = card.size * 0.5
		card.scale = Vector2.ONE * 0.98
		var tw := create_tween().set_ignore_time_scale(true).set_parallel(true)
		tw.tween_property(self, "modulate:a", 1.0, Brand.T_FAST)
		tw.tween_property(card, "scale", Vector2.ONE, Brand.T_FAST).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _button(text: String, kind: String, choice: String) -> BrandButton:
	var b: BrandButton = load("res://scenes/ui/brand/%s_button.tscn" % kind).instantiate()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(close.bind(choice))
	return b


func close(choice := "") -> void:
	if inline:
		closed.emit(choice)
		return
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_property(self, "modulate:a", 0.0, Brand.T_PRESS)
	tw.tween_callback(func() -> void:
		closed.emit(choice)
		queue_free())
