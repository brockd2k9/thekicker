@tool
class_name BrandTheme
extends RefCounted
## Builds the broadcast UI Theme from Brand (the one source of every color,
## size and shape). get() is what screens use; it is built in code, so editing
## Brand changes the whole look. assets/ui/brand_theme.tres is a generated copy
## for the editor (tools/build_brand_theme.tscn; a test keeps it in sync).
##
## Theme type variations:
##   Labels      Hero, Display, Title, Heading, Subhead, Body, BodyStrong,
##               Caption, Eyebrow (the type scale; Brand.TYPE)
##   Buttons     PrimaryButton, SecondaryButton, TabButton, SegmentButton, ListRow
##   Panels      Card, CardRaised, CardAccent, Tile, TileHighlight, BannerInfo,
##               BannerWarning, ChipNeutral, ChipOutline, ChipRed, ChipTeam,
##               SegmentTrack, PopupCard, HeaderRule
## Every button kind has normal, hover, pressed, focus and disabled styles.

const PATH := "res://assets/ui/brand_theme.tres"
const LABELS := ["Hero", "Display", "Title", "Heading", "Subhead", "Body", "BodyStrong", "Caption", "Eyebrow"]
const BUTTONS := ["PrimaryButton", "SecondaryButton", "TabButton", "SegmentButton", "ListRow"]
const PANELS := ["Card", "CardRaised", "CardAccent", "Tile", "TileHighlight", "BannerInfo", "BannerWarning",
	"ChipNeutral", "ChipOutline", "ChipRed", "ChipTeam", "SegmentTrack", "PopupCard", "HeaderRule"]

static var _theme: Theme
static var _fonts := {}


static func get_theme() -> Theme:
	if _theme == null:
		_theme = build()
	return _theme


## A font from Brand (cached). tracked: with Brand.TRACKING letter spacing.
static func font(path: String, tracked := false) -> Font:
	var key := path + ("|t" if tracked else "")
	if not _fonts.has(key):
		var f: Font = load(path)
		if tracked:
			var v := FontVariation.new()
			v.base_font = f
			v.spacing_glyph = Brand.TRACKING
			f = v
		_fonts[key] = f
	return _fonts[key]


## The type scale entry for a Label variation: {font, size, upper}.
static func type_of(variation: String) -> Dictionary:
	var t: Array = Brand.TYPE.get(variation, Brand.TYPE["Body"])
	return {"font": str(t[0]), "size": int(t[1]), "upper": bool(t[2])}


static func build() -> Theme:
	var t := Theme.new()
	t.default_font = font(Brand.FONT_BODY)
	t.default_font_size = int(Brand.TYPE["Body"][1])
	t.set_color("font_color", "Label", Brand.WHITE)
	for name in LABELS:
		var ty := type_of(name)
		t.set_type_variation(name, "Label")
		t.set_font("font", name, font(ty["font"], ty["upper"]))
		t.set_font_size("font_size", name, ty["size"])
		t.set_color("font_color", name, Brand.GREY if name in ["Caption", "Eyebrow"] else Brand.WHITE)
	_buttons(t)
	_panels(t)
	_scroll(t)
	return t


# --- buttons --------------------------------------------------------------------------

static func _buttons(t: Theme) -> void:
	var head := font(Brand.BUTTON_TYPE[0], true)
	var cut := {"cut_tl": Brand.CUT, "cut_br": Brand.CUT}
	var primary := _box(Brand.RED, cut)
	_button(t, "PrimaryButton", {
		"normal": primary,
		"hover": primary.with({"bg": Brand.RED_HOT}),
		"pressed": primary.with({"bg": Brand.RED_DEEP}),
		"focus": _box(Color(0, 0, 0, 0), cut.merged({"stroke": Brand.WHITE, "stroke_width": 3})),
		"disabled": _box(Brand.INK_3, cut),
	}, Brand.WHITE, Brand.GREY_DIM, head, Brand.BUTTON_TYPE[1])
	var secondary := _box(Brand.INK_2, cut.merged({"stroke": Brand.LINE, "texture_color": Brand.TEXTURE}))
	_button(t, "SecondaryButton", {
		"normal": secondary,
		"hover": secondary.with({"bg": Brand.INK_3, "stroke": Brand.LINE_STRONG}),
		"pressed": secondary.with({"bg": Brand.INK_1, "rule_bottom": Brand.RED}),
		"focus": _box(Color(0, 0, 0, 0), cut.merged({"stroke": Brand.WHITE, "stroke_width": 3})),
		"disabled": secondary.with({"bg": Brand.INK_1, "texture_color": Color(0, 0, 0, 0)}),
	}, Brand.WHITE, Brand.GREY_DIM, head, Brand.BUTTON_TYPE[1])
	# Tabs: text on the bar; the selected tab's red underline is drawn by BrandTabs.
	var tab := _box(Color(0, 0, 0, 0), {})
	_button(t, "TabButton", {
		"normal": tab, "hover": tab.with({"bg": Brand.INK_2}), "pressed": tab.with({"bg": Brand.INK_1}),
		"focus": tab.with({"stroke": Brand.WHITE}), "disabled": tab,
	}, Brand.GREY, Brand.GREY_DIM, font(Brand.FONT_HEAD, true), int(Brand.TYPE["Subhead"][1]))
	t.set_color("font_hover_color", "TabButton", Brand.WHITE)
	t.set_color("font_pressed_color", "TabButton", Brand.WHITE)
	# Segments: the selected one turns white (pressed = toggled on).
	var seg := _box(Color(0, 0, 0, 0), {"cut_tl": Brand.CUT_SMALL, "cut_br": Brand.CUT_SMALL})
	_button(t, "SegmentButton", {
		"normal": seg, "hover": seg.with({"bg": Brand.INK_3}), "pressed": seg.with({"bg": Brand.WHITE}),
		"focus": seg.with({"stroke": Brand.WHITE}), "disabled": seg,
	}, Brand.GREY, Brand.GREY_DIM, font(Brand.FONT_HEAD, true), int(Brand.TYPE["Subhead"][1]))
	t.set_color("font_pressed_color", "SegmentButton", Brand.INK_0)
	t.set_color("font_hover_pressed_color", "SegmentButton", Brand.INK_0)
	t.set_color("font_hover_color", "SegmentButton", Brand.WHITE)
	# List rows: flat, a divider under each, a red stripe while pressed.
	var row := _box(Brand.INK_1, {"rule_bottom": Brand.LINE, "rule_width": 1})
	_button(t, "ListRow", {
		"normal": row, "hover": row.with({"bg": Brand.INK_2}),
		"pressed": row.with({"bg": Brand.INK_3, "stripe": Brand.RED, "stripe_width": Brand.STRIPE}),
		"focus": _box(Color(0, 0, 0, 0), {"stroke": Brand.WHITE}), "disabled": row,
	}, Brand.WHITE, Brand.GREY_DIM, font(Brand.FONT_BODY_STRONG), int(Brand.TYPE["BodyStrong"][1]))


static func _button(t: Theme, type: String, boxes: Dictionary, fg: Color, fg_off: Color, f: Font, size: int) -> void:
	t.set_type_variation(type, "Button")
	for state in boxes:
		var b: ClippedBox = boxes[state]
		t.set_stylebox(state, type, b)
	t.set_stylebox("hover_pressed", type, boxes["pressed"])
	t.set_font("font", type, f)
	t.set_font_size("font_size", type, size)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		t.set_color(c, type, fg)
	t.set_color("font_disabled_color", type, fg_off)
	for c in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color",
			"icon_hover_pressed_color"]:
		t.set_color(c, type, fg)
	t.set_color("icon_disabled_color", type, fg_off)
	t.set_constant("h_separation", type, Brand.SPACE_3)
	t.set_constant("icon_max_width", type, 40)


# --- panels ---------------------------------------------------------------------------

static func _panels(t: Theme) -> void:
	var card := _box(Brand.INK_1, {"cut_tr": Brand.CUT, "stroke": Brand.LINE, "texture_color": Brand.TEXTURE})
	var panels := {
		"Card": card,
		"CardRaised": card.with({"bg": Brand.INK_2}),
		"CardAccent": card.with({"rule_top": Brand.RED, "rule_width": Brand.RULE}),
		"Tile": card.with({"bg": Brand.INK_2, "cut_tr": Brand.CUT_SMALL}),
		"TileHighlight": card.with({"bg": Brand.INK_2, "cut_tr": Brand.CUT_SMALL, "rule_top": Brand.RED,
			"rule_width": Brand.RULE}),
		"BannerInfo": card.with({"bg": Brand.INK_2, "stripe": Brand.WHITE, "stripe_width": Brand.STRIPE}),
		"BannerWarning": card.with({"bg": Brand.INK_2, "stripe": Brand.RED, "stripe_width": Brand.STRIPE,
			"stroke": Brand.RED_DEEP}),
		"ChipNeutral": _box(Brand.INK_3, {"cut_br": Brand.CUT_SMALL}, true),
		"ChipOutline": _box(Color(0, 0, 0, 0), {"cut_br": Brand.CUT_SMALL, "stroke": Brand.LINE_STRONG}, true),
		"ChipRed": _box(Brand.RED, {"cut_br": Brand.CUT_SMALL}, true),
		"ChipTeam": _box(Brand.INK_3, {"cut_br": Brand.CUT_SMALL, "stripe": Brand.WHITE, "stripe_width": Brand.STRIPE}, true),
		"SegmentTrack": _box(Brand.INK_2, {"cut_tl": Brand.CUT_SMALL, "cut_br": Brand.CUT_SMALL, "stroke": Brand.LINE}),
		"PopupCard": card.with({"rule_top": Brand.RED, "rule_width": Brand.RULE}),
		"HeaderRule": _box(Color(0, 0, 0, 0), {"rule_bottom": Brand.LINE, "rule_width": 1}),
	}
	for name in panels:
		t.set_type_variation(name, "PanelContainer")
		t.set_stylebox("panel", name, panels[name])
	t.get_stylebox("panel", "SegmentTrack").set_content_margin_all(Brand.SPACE_1)


static func _scroll(t: Theme) -> void:
	var grab := _box(Brand.LINE_STRONG, {})
	grab.set_content_margin_all(3)
	var track := _box(Color(0, 0, 0, 0), {})
	track.set_content_margin_all(3)
	for s in ["grabber", "grabber_highlight", "grabber_pressed"]:
		t.set_stylebox(s, "VScrollBar", grab if s == "grabber" else grab.with({"bg": Brand.GREY}))
	t.set_stylebox("scroll", "VScrollBar", track)


## A ClippedBox from Brand: fill, then fields ({"cut_tl": 18, "stroke": ...}).
## chip: tighter content margins.
static func _box(bg: Color, fields: Dictionary, chip := false) -> ClippedBox:
	var b := ClippedBox.new()
	b.bg = bg
	b.stroke_width = Brand.STROKE
	b.texture_step = Brand.TEXTURE_STEP
	b.stripe_width = Brand.STRIPE
	b.rule_width = Brand.RULE
	for k in fields:
		b.set(k, fields[k])
	if chip:
		b.content_margin_left = Brand.SPACE_3
		b.content_margin_right = Brand.SPACE_3 + 2
		b.content_margin_top = Brand.SPACE_1
		b.content_margin_bottom = Brand.SPACE_1
	else:
		b.content_margin_left = Brand.PAD_X
		b.content_margin_right = Brand.PAD_X
		b.content_margin_top = Brand.PAD_Y
		b.content_margin_bottom = Brand.PAD_Y
	if b.stripe.a > 0.0:
		b.content_margin_left += b.stripe_width
	return b


## A Label in the type scale: variation (Brand.TYPE name), color (default: the
## variation's), uppercase as the scale says.
static func label(text: String, variation := "Body", color := Color(0, 0, 0, 0)) -> Label:
	var l := Label.new()
	l.theme_type_variation = variation
	l.text = text
	l.uppercase = type_of(variation)["upper"]
	if color.a > 0.0:
		l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
