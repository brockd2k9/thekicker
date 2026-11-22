class_name BrandUi
extends RefCounted
## Building blocks for screens in the broadcast system (the component scenes,
## made from code): the screen frame, buttons, rows of buttons, sections,
## cards, chips, banners, a scrolling list and modals. Screens use these
## instead of styling anything themselves.

const PRIMARY := preload("res://scenes/ui/brand/primary_button.tscn")
const SECONDARY := preload("res://scenes/ui/brand/secondary_button.tscn")
const CARD := preload("res://scenes/ui/brand/card.tscn")
const CHIP := preload("res://scenes/ui/brand/chip.tscn")
const BANNER := preload("res://scenes/ui/brand/banner.tscn")
const HEADER := preload("res://scenes/ui/brand/header_bar.tscn")


## The screen frame: the theme, a black background, safe-area margins and a
## centered column (Brand.COLUMN wide; wider windows get side margins).
## Returns the column. title: an optional header bar on top.
static func frame(root: Control, title := "", eyebrow := "") -> VBoxContainer:
	root.theme = BrandTheme.get_theme()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := Panel.new()
	var b := ClippedBox.new()
	b.bg = Brand.INK_0
	b.texture_color = Brand.TEXTURE
	b.texture_step = Brand.TEXTURE_STEP * 2
	bg.add_theme_stylebox_override("panel", b)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)
	var safe := MarginContainer.new()
	safe.name = "Safe"
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(safe)
	UiKit.apply_safe_area(safe, Brand.MARGIN)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe.add_child(row)
	var col := VBoxContainer.new()
	col.custom_minimum_size.x = Brand.COLUMN
	col.add_theme_constant_override("separation", Brand.SPACE_3)
	row.add_child(col)
	if title != "":
		col.add_child(header(title, eyebrow))
	enter(safe)
	return col


## Screen content arriving: a quick fade (Brand.T_BASE), no bounce.
static func enter(c: Control) -> void:
	c.modulate.a = 0.0
	c.create_tween().set_ignore_time_scale(true).tween_property(c, "modulate:a", 1.0, Brand.T_BASE)


static func header(title: String, eyebrow := "") -> BrandHeader:
	var h: BrandHeader = HEADER.instantiate()
	h.title = title
	h.eyebrow = eyebrow
	return h


## A button: kind "primary" (red) or "secondary"; icon: a BrandIcons name.
static func button(text: String, on_pressed: Callable, kind := "secondary", icon := "") -> BrandButton:
	var b: BrandButton = (PRIMARY if kind == "primary" else SECONDARY).instantiate()
	b.text = text
	b.icon_name = icon
	if on_pressed.is_valid():
		b.pressed.connect(on_pressed)
	return b


## Buttons side by side, sharing the width (stretch ratios kept).
static func button_row(buttons: Array) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_3)
	for b in buttons:
		(b as Control).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(b)
	return h


## A section title: a short red tick and condensed caps.
static func section(text: String) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_2)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tick := ColorRect.new()
	tick.color = Brand.RED
	tick.custom_minimum_size = Vector2(Brand.RULE, 26)
	tick.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(tick)
	var l := BrandTheme.label(text, "Eyebrow", Brand.WHITE)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(l)
	return h


## A card: variant "card" / "raised" / "accent"; team: a team-color stripe.
## Returns the card; put content in card.content.
static func card(variant := "card", team := Color(0, 0, 0, 0)) -> BrandCard:
	var c: BrandCard = CARD.instantiate()
	c.variant = variant
	c.team_color = team
	return c


## kind: "neutral", "outline", "red", "team".
static func chip(text: String, kind := "neutral", icon := "", team := Color(0, 0, 0, 0)) -> BrandChip:
	var c: BrandChip = CHIP.instantiate()
	c.text = text
	c.kind = kind
	c.icon_name = icon
	c.team_color = team
	return c


## kind: "info" / "warning".
static func banner(kind: String, title: String, body: String) -> BrandBanner:
	var b: BrandBanner = BANNER.instantiate()
	b.kind = kind
	b.title = title
	b.body = body
	return b


## A flow of chips (wraps to new lines).
static func chip_flow() -> HFlowContainer:
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", Brand.SPACE_2)
	f.add_theme_constant_override("v_separation", Brand.SPACE_2)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return f


## A vertical scrolling list filling the rest of `parent` (drag-scrolls over
## buttons on touch screens). Returns the list to fill.
static func scroll_list(parent: Control, separation := Brand.SPACE_3) -> VBoxContainer:
	var sc := TouchScroll.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(sc)
	var pad := MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_right", Brand.SPACE_3)
	pad.add_theme_constant_override("margin_bottom", Brand.SPACE_3)
	sc.add_child(pad)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", separation)
	pad.add_child(list)
	return list


## A modal popup over `host`: the scrim, a card with a red top rule and the
## title. Returns the content box (add text and buttons; free the modal with
## UiKit.modal_root(content).queue_free()). Named "Modal", so Back closes it.
static func modal(host: Node, title: String) -> VBoxContainer:
	var root := Control.new()
	root.name = "Modal"
	root.theme = BrandTheme.get_theme()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.process_mode = Node.PROCESS_MODE_ALWAYS
	var scrim := ColorRect.new()
	scrim.color = Brand.SCRIM
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(scrim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	var card := PanelContainer.new()
	card.theme_type_variation = "PopupCard"
	card.custom_minimum_size.x = Brand.COLUMN - Brand.SPACE_5 * 2
	center.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", Brand.SPACE_4)
	card.add_child(v)
	if title != "":
		var t := BrandTheme.label(title, "Heading")
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(t)
	host.add_child(root)
	root.modulate.a = 0.0
	root.create_tween().set_ignore_time_scale(true).tween_property(root, "modulate:a", 1.0, Brand.T_FAST)
	return v


## Wrapping body text in the type scale.
static func text(t: String, variation := "Body", color := Color(0, 0, 0, 0)) -> Label:
	var l := BrandTheme.label(t, variation, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l
