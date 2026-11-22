class_name UiKit
extends RefCounted
## Shared building blocks for screens and overlays (the older API the screens
## use), drawn in the broadcast design system: every color, size and shape
## comes from Brand / BrandTheme. Sizes are in the 720x1280 base viewport;
## buttons are at least 88 px tall for thumbs. Landscape / Steam: content
## sits in a centered column of COLUMN_WIDTH.
##
## Labels snap to the type scale (Brand.TYPE; nothing under Brand.MIN_TEXT).
## Panels, buttons and chips are ClippedBoxes (clipped corners, thin strokes).
##
## Sound / haptics: every button and key moment calls UiKit.feedback(event),
## which plays Sfx event `event` (if an audio file exists) and pulses
## Haptics. See FEEDBACK for the events.

const COLUMN_WIDTH := UiTokens.COLUMN_WIDTH
const BUTTON_HEIGHT := UiTokens.BUTTON_HEIGHT
const MARGIN := UiTokens.MARGIN

## Button kinds (theme type variations).
const PRIMARY := &"PrimaryButton"
const SECONDARY := &"Button"
const DANGER_KIND := &"DangerButton"
## Button text longer than this uses the body size (Brand "Body") so it fits.
const LONG_BUTTON := 20

## event -> haptic pulse in ms (0 = sound only). Sfx event names are the same.
const FEEDBACK := {
	&"ui_tap": 8, &"ui_confirm": 14, &"ui_back": 6, &"ui_locked": 30,
	&"ui_open": 0, &"ui_transition": 0,
	&"stat_up": 10, &"stat_down": 16, &"trait_unlock": 45, &"achievement": 50,
	&"result_good": 30, &"result_miss": 60, &"game_winner": 140, &"week_result": 20,
}

# Palette colors (the broadcast palette; static so older code keeps reading
# UiKit.ACCENT etc.).
static var palette: Dictionary = UiTokens.BROADCAST
static var BG_TOP: Color = Brand.INK_0
static var BG_BOTTOM: Color = Brand.INK_0
static var TEXT: Color = Brand.WHITE
static var ACCENT: Color = Brand.RED_HOT
static var ACCENT_TEXT: Color = Brand.WHITE
static var ALT: Color = Brand.WHITE
static var GOOD: Color = Brand.WHITE
static var BAD: Color = Brand.RED_HOT
static var WARN: Color = Brand.RED_HOT
static var MUTED: Color = Brand.GREY
static var PANEL: Color = Brand.INK_1
static var BUTTON: Color = Brand.INK_2
static var BUTTON_HOVER: Color = Brand.INK_3
static var BUTTON_PRESSED: Color = Brand.INK_1
static var DANGER: Color = Brand.RED_DEEP
## Player's team colors in Career Mode: [primary, secondary], or empty.
static var team: Array = []

static var _theme: Theme


# --- palette ----------------------------------------------------------------------------

static func use_palette(p: Dictionary) -> void:
	palette = p
	BG_TOP = p["bg_top"]
	BG_BOTTOM = p["bg_bottom"]
	TEXT = p["text"]
	ACCENT = p["accent"]
	ACCENT_TEXT = p["accent_text"]
	ALT = p["alt"]
	GOOD = p["good"]
	BAD = p["bad"]
	WARN = p["warn"]
	MUTED = p["muted"]
	PANEL = p["panel"]
	BUTTON = p["button"]
	DANGER = p["danger"]


## Career Mode: the team's colors, used only as small accents (stripes).
static func set_stage(stage: String, team_colors: Array = []) -> void:
	use_palette(UiTokens.for_stage(stage))
	team = []
	for c in team_colors:
		team.append(Brand.team_accent(Color.from_string(str(c), Brand.GREY) if not (c is Color) else c))


## Back to the default (menus outside Career Mode).
static func reset_palette() -> void:
	use_palette(UiTokens.BROADCAST)
	team = []


## A team color as a small accent (or white when there's no team).
static func team_color(i: int = 0) -> Color:
	if team.size() <= i:
		return Brand.WHITE
	return team[i]


## Stat group color: white for every group (groups are told apart by name and icon).
static func group_color(group: String) -> Color:
	return palette.get(group, Brand.WHITE)


# --- theme -----------------------------------------------------------------------------

static func theme() -> Theme:
	if _theme != null:
		return _theme
	var t: Theme = BrandTheme.build()
	# The plain Button type is the secondary button; DangerButton is a
	# secondary button with a red stroke and red text (destructive actions).
	for state in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		t.set_stylebox(state, "Button", t.get_stylebox(state, "SecondaryButton"))
	t.set_font("font", "Button", t.get_font("font", "SecondaryButton"))
	t.set_font_size("font_size", "Button", t.get_font_size("font_size", "SecondaryButton"))
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color",
			"font_disabled_color", "icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color",
			"icon_hover_pressed_color", "icon_disabled_color"]:
		t.set_color(c, "Button", t.get_color(c, "SecondaryButton"))
	t.set_constant("h_separation", "Button", Brand.SPACE_3)
	t.set_constant("icon_max_width", "Button", 40)
	t.set_type_variation(DANGER_KIND, "Button")
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var b := (t.get_stylebox(state, "SecondaryButton") as ClippedBox).with({"stroke": Brand.RED_DEEP})
		t.set_stylebox(state, DANGER_KIND, b)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color",
			"icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color", "icon_hover_pressed_color"]:
		t.set_color(c, DANGER_KIND, Brand.RED_HOT)

	# Toggle rows are panels with a switch.
	var row := _box(Brand.INK_1, 0)
	row.stroke = Brand.LINE
	for st in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		t.set_stylebox(st, "CheckButton", row)
	t.set_stylebox("focus", "CheckButton", _box(Color(0, 0, 0, 0), 0, Brand.WHITE))
	t.set_constant("h_separation", "CheckButton", Brand.SPACE_3)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		t.set_color(c, "CheckButton", Brand.WHITE)
	t.set_icon("checked", "CheckButton", _switch_texture(true))
	t.set_icon("unchecked", "CheckButton", _switch_texture(false))

	t.set_stylebox("panel", "PanelContainer", panel_box())

	var track := _box(Brand.INK_3, 0)
	track.content_margin_top = 8
	track.content_margin_bottom = 8
	t.set_stylebox("slider", "HSlider", track)
	var fill := _box(Brand.WHITE, 0)
	t.set_stylebox("grabber_area", "HSlider", fill)
	t.set_stylebox("grabber_area_highlight", "HSlider", fill)
	var knob := _square_texture(40, Brand.RED)
	t.set_icon("grabber", "HSlider", knob)
	t.set_icon("grabber_highlight", "HSlider", knob)

	var le := _box(Brand.INK_2, 0, Brand.LINE)
	t.set_stylebox("normal", "LineEdit", le)
	t.set_stylebox("focus", "LineEdit", _box(Color(0, 0, 0, 0), 0, Brand.WHITE))
	t.set_color("font_color", "LineEdit", Brand.WHITE)
	t.set_color("font_placeholder_color", "LineEdit", Brand.GREY)
	t.set_color("caret_color", "LineEdit", Brand.RED_HOT)

	var bar_bg := _box(Brand.INK_3, 0)
	bar_bg.set_content_margin_all(0)
	t.set_stylebox("background", "ProgressBar", bar_bg)
	var bar_fill := _box(Brand.WHITE, 0)
	bar_fill.set_content_margin_all(0)
	t.set_stylebox("fill", "ProgressBar", bar_fill)

	t.set_constant("separation", "VBoxContainer", UiTokens.GAP)
	_theme = t
	return t


## No slant in the broadcast system (kept for older callers).
static func _skewed(b: StyleBox) -> StyleBox:
	return b


## A flat clipped box: fill, optional stroke. radius: ignored (square,
## Brand shapes), kept for older callers.
static func _box(color: Color, _radius: int = 0, border := Color(0, 0, 0, 0)) -> ClippedBox:
	var b := ClippedBox.new()
	b.bg = color
	b.stroke_width = Brand.STROKE
	b.texture_step = Brand.TEXTURE_STEP
	b.content_margin_left = Brand.PAD_X
	b.content_margin_right = Brand.PAD_X
	b.content_margin_top = 14
	b.content_margin_bottom = 14
	if border.a > 0.0:
		b.stroke = border
	return b


## Standard panel: black, a clipped corner, a hairline stroke and the faint
## texture. bar: a rule along the top (red for the accent, else white).
## bg: a different fill (raised panels).
static func panel_box(bar := Color(0, 0, 0, 0), bg := Color(0, 0, 0, 0)) -> ClippedBox:
	var b := _box(Brand.INK_1 if bg.a == 0.0 else Brand.INK_2, 0, Brand.LINE)
	b.cut_tr = Brand.CUT
	b.texture_color = Brand.TEXTURE
	b.content_margin_top = Brand.PAD_Y
	b.content_margin_bottom = Brand.PAD_Y
	if bar.a > 0.0:
		b.rule_top = Brand.RED if bar.is_equal_approx(ACCENT) or bar.is_equal_approx(Brand.RED) \
			or bar.is_equal_approx(BAD) else Brand.WHITE
		b.rule_width = Brand.RULE
		b.content_margin_top = Brand.PAD_Y + 2
	return b


static func badge_texture(unlocked: bool) -> Texture2D:
	return UiIcons.texture("achievements", Brand.WHITE if unlocked else Brand.GREY_DIM, 56)


## A square on/off switch: red block right when on, grey block left when off.
static func _switch_texture(on: bool) -> ImageTexture:
	var w := 92
	var h := 52
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Brand.INK_3)
	var knob := Rect2i(w - h + 6 if on else 6, 6, h - 12, h - 12)
	if on:
		img.fill_rect(Rect2i(0, 0, w, h), Brand.RED_DEEP)
	img.fill_rect(knob, Brand.WHITE if on else Brand.GREY)
	return ImageTexture.create_from_image(img)


static func _square_texture(size: int, color: Color) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)


# --- feedback (sound + haptics hooks) ----------------------------------------------------

## Plays Sfx `event` (silent until an audio file exists, see audio/README.txt)
## and pulses the phone for the event's FEEDBACK duration.
static func feedback(event: StringName) -> void:
	var main := Engine.get_main_loop() as SceneTree
	if main == null or main.root == null:
		return
	var sfx := main.root.get_node_or_null("Sfx")
	if sfx != null:
		sfx.play(event)
	var ms: int = FEEDBACK.get(event, 0)
	var hap := main.root.get_node_or_null("Haptics")
	if ms > 0 and hap != null:
		hap.pulse(ms)


# --- screen frame ----------------------------------------------------------------------

## Fills `root` (a full-screen Control) with the background and a
## safe-area-aware centered column, and returns that column (BrandUi.frame).
static func build_frame(root: Control, title: String) -> VBoxContainer:
	root.theme = theme()
	var col := BrandUi.frame(root, title)
	root.theme = theme()
	return col


## Screen content arriving: a quick fade (Brand.T_BASE).
static func enter(c: Control) -> void:
	BrandUi.enter(c)


## Same safe-area logic as the HUD: keep content clear of notches/rounded corners.
static func apply_safe_area(m: MarginContainer, base: int) -> void:
	var left := base
	var top := base
	var right := base
	var bottom := base
	if OS.has_feature("mobile"):
		var safe := DisplayServer.get_display_safe_area()
		var screen := DisplayServer.screen_get_size()
		if screen.x > 0 and screen.y > 0:
			var vp := m.get_viewport().get_visible_rect().size
			var sx := vp.x / screen.x
			var sy := vp.y / screen.y
			left += int(safe.position.x * sx)
			top += int(safe.position.y * sy)
			right += int((screen.x - safe.end.x) * sx)
			bottom += int((screen.y - safe.end.y) * sy)
	m.add_theme_constant_override("margin_left", left)
	m.add_theme_constant_override("margin_top", top)
	m.add_theme_constant_override("margin_right", right)
	m.add_theme_constant_override("margin_bottom", bottom)


## Screen title: the broadcast header bar (eyebrow, title, red rule).
static func title_block(text: String, kicker := "") -> Control:
	return BrandUi.header(text, kicker)


## A short red rule on a hairline (under titles).
static func rule(_color := Color(0, 0, 0, 0)) -> Control:
	var c := Control.new()
	c.custom_minimum_size.y = Brand.RULE
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hair := ColorRect.new()
	hair.color = Brand.LINE
	hair.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hair.offset_top = -1
	hair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(hair)
	var red := ColorRect.new()
	red.color = Brand.RED
	red.size = Vector2(96, Brand.RULE)
	red.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(red)
	return c


# --- widgets ---------------------------------------------------------------------------

## The nearest size in the type scale (never under Brand.MIN_TEXT).
static func type_size(px: int) -> int:
	var sizes: Array = []
	for k in Brand.TYPE:
		if not (int(Brand.TYPE[k][1]) in sizes):
			sizes.append(int(Brand.TYPE[k][1]))
	sizes.sort()
	var best: int = sizes[0]
	for sz in sizes:
		if absi(sz - px) < absi(best - px) or (absi(sz - px) == absi(best - px) and sz > best):
			best = sz
	return maxi(best, Brand.MIN_TEXT)


## font: UiTokens.FONT_BODY (default), FONT_DISPLAY, FONT_BANNER, FONT_CONDENSED.
## size snaps to the type scale.
static func label(text: String, size: int = 32, color := Color(0, 0, 0, 0),
		font: StringName = UiTokens.FONT_BODY) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", type_size(size))
	l.add_theme_color_override("font_color", TEXT if color.a == 0.0 else color)
	if font != &"":
		l.theme_type_variation = font
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## A one-line label for rows (HBox): no wrapping, keeps its full width.
static func line(text: String, size: int = 32, color := Color(0, 0, 0, 0),
		font: StringName = UiTokens.FONT_BODY) -> Label:
	var l := label(text, size, color, font)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	return l


## kind: PRIMARY (red), SECONDARY (default), DANGER_KIND; or a Color (a red
## or white fill). icon: a UiIcons id.
static func button(text: String, on_pressed: Callable, kind: Variant = SECONDARY,
		icon := "") -> Button:
	var b := Button.new()
	b.text = text.to_upper()
	b.custom_minimum_size.y = BUTTON_HEIGHT
	if text.length() > LONG_BUTTON:
		b.add_theme_font_size_override("font_size", int(Brand.TYPE["Body"][1]))
	b.clip_text = true
	b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	# Keyboard/gamepad focus on desktop (Steam); no lingering focus ring after taps on phones.
	b.focus_mode = Control.FOCUS_NONE if OS.has_feature("mobile") else Control.FOCUS_ALL
	var event := &"ui_tap"
	if kind is StringName or kind is String:
		b.theme_type_variation = StringName(kind)
		if StringName(kind) == PRIMARY:
			event = &"ui_confirm"
	elif kind is Color and (kind as Color).a > 0.0:
		b.theme_type_variation = DANGER_KIND if (kind as Color).is_equal_approx(DANGER) else PRIMARY
	if icon != "":
		var ic_col := Brand.RED_HOT if b.theme_type_variation == DANGER_KIND else Brand.WHITE
		b.icon = UiIcons.texture(icon, ic_col, 40)
	add_press_feedback(b)
	b.pressed.connect(func() -> void:
		feedback(event)
		on_pressed.call())
	return b


static func primary(text: String, on_pressed: Callable, icon := "") -> Button:
	return button(text, on_pressed, PRIMARY, icon)


static func danger(text: String, on_pressed: Callable, icon := "") -> Button:
	return button(text, on_pressed, DANGER_KIND, icon)


## A quick dip on press (any Button), Brand.T_PRESS; no bounce.
static func add_press_feedback(b: BaseButton) -> void:
	b.button_down.connect(func() -> void:
		if not b.disabled:
			BrandMotion.press(b))


## A row with a name on the left and a value on the right; a hairline under
## it. A long value wraps on the right instead of squeezing the name.
static func stat_row(name: String, value: String, value_color := Color(0, 0, 0, 0),
		icon := "") -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := _box(Brand.INK_1, 0)
	box.rule_bottom = Brand.LINE
	box.rule_width = 1
	box.content_margin_top = Brand.SPACE_3
	box.content_margin_bottom = Brand.SPACE_3
	p.add_theme_stylebox_override("panel", box)
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_theme_constant_override("separation", Brand.SPACE_3)
	p.add_child(h)
	if icon != "":
		h.add_child(UiIcons.rect(icon, Brand.GREY, 32))
	var n := label(name, 32, Brand.WHITE)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(n)
	var v := label(value, 40, Brand.WHITE if value_color.a == 0.0 else _text_color(value_color), UiTokens.FONT_DISPLAY)
	v.autowrap_mode = TextServer.AUTOWRAP_OFF
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if value.length() > 12:
		n.size_flags_stretch_ratio = 0.6
		v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_theme_font_size_override("font_size", type_size(32))
	h.add_child(v)
	return p


## Any color as text in the palette: red stays red (warnings, losses), grey
## stays grey, everything else is white.
static func _text_color(c: Color) -> Color:
	if c.r > 0.6 and c.g < 0.35 and c.b < 0.35:
		return Brand.RED_HOT
	if absf(c.r - c.g) < 0.06 and absf(c.g - c.b) < 0.06 and c.v < 0.75:
		return Brand.GREY
	return Brand.WHITE


## Section head: a short red tick and condensed caps.
static func section(text: String, _color := Color(0, 0, 0, 0)) -> Control:
	return BrandUi.section(text)


## Small tag ("HOME", "+3 Accuracy"). filled: a solid block (red for red
## colors, else black); otherwise outlined. Text stays readable either way.
static func chip(text: String, color: Color, filled := false, icon := "", size := 22) -> PanelContainer:
	var red := _text_color(color) == Brand.RED_HOT
	var kind := ("red" if red else "neutral") if filled else "outline"
	var c := BrandUi.chip(text, kind, icon)
	if not filled and red:
		c.ready.connect(func() -> void:
			for l in c.find_children("*", "Label", true, false):
				(l as Label).add_theme_color_override("font_color", Brand.RED_HOT)
			for r in c.find_children("*", "TextureRect", true, false):
				(r as TextureRect).texture = UiIcons.texture(icon, Brand.RED_HOT, 30), CONNECT_ONE_SHOT)
	return c


## Black or white text, whichever reads on `bg`.
static func readable_on(bg: Color) -> Color:
	return Brand.INK_0 if bg.get_luminance() > 0.55 else Brand.WHITE


## Panel with an optional top rule; returns [panel, vbox].
static func card(bar := Color(0, 0, 0, 0), separation := 8) -> Array:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", panel_box(bar))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", separation)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(v)
	return [p, v]


## Big number over a small caption ("97 / 128" over "FIELD GOALS").
static func stat_tile(value: String, caption: String, _color := Color(0, 0, 0, 0)) -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.theme_type_variation = "Tile"
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(v)
	var c := BrandTheme.label(caption, "Eyebrow")
	c.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(c)
	var n := BrandTheme.label(value, "Heading")
	n.add_theme_font_override("font", BrandTheme.font(Brand.FONT_NUMBER))
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(n)
	return p


## Broadcast ticker: a red tag and a dark strip. Scrolls slowly only if it doesn't fit.
static func ticker(tag_text: String, text: String) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tag := PanelContainer.new()
	var tb := _box(Brand.RED, 0)
	tb.content_margin_top = 4
	tb.content_margin_bottom = 4
	tb.content_margin_left = Brand.SPACE_3
	tb.content_margin_right = Brand.SPACE_3
	tag.add_theme_stylebox_override("panel", tb)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.add_child(BrandTheme.label(tag_text, "Eyebrow", Brand.WHITE))
	h.add_child(tag)
	var strip := Panel.new()
	strip.add_theme_stylebox_override("panel", _box(Brand.INK_2, 0, Brand.LINE))
	strip.clip_contents = true
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(strip)
	var l := BrandTheme.label(text, "Eyebrow", Brand.WHITE)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	strip.add_child(l)
	strip.resized.connect(func() -> void:
		strip.custom_minimum_size.y = l.get_minimum_size().y + 8
		l.position = Vector2(Brand.SPACE_3, 4)
		var w := l.get_minimum_size().x
		if w + 32 > strip.size.x and not strip.has_meta("tw"):
			var tw := strip.create_tween().set_loops()
			strip.set_meta("tw", tw)
			tw.tween_interval(1.5)
			tw.tween_property(l, "position:x", strip.size.x - w - Brand.SPACE_3, (w - strip.size.x) / 40.0 + 1.0)
			tw.tween_interval(1.5)
			tw.tween_property(l, "position:x", float(Brand.SPACE_3), Brand.T_BASE * 4.0))
	return h


static func expanding_spacer() -> Control:
	var c := Control.new()
	c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


static func _spacer(horizontal: bool) -> Control:
	var c := Control.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if horizontal:
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	else:
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return c


## Vertical scroll area that fills the remaining column height. Add rows to
## the returned VBox. Touch drag-scrolls on phones.
static func scroll_list(parent: Control) -> VBoxContainer:
	var sc := TouchScroll.new()  # drag-scrolls over buttons on touch screens
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(sc)
	var pad := MarginContainer.new()  # keeps rows clear of the scrollbar (and shadows)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_right", 16)
	pad.add_theme_constant_override("margin_left", 4)
	pad.add_theme_constant_override("margin_top", 4)
	pad.add_theme_constant_override("margin_bottom", 12)
	sc.add_child(pad)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	pad.add_child(list)
	return list


# --- motion ----------------------------------------------------------------------------

## Brings a control in (fade + a small scale), e.g. trait unlocks: snappy, no bounce.
static func pop_in(c: Control, delay := 0.0, _from_scale := 0.6) -> void:
	c.modulate.a = 0.0
	var tw := c.create_tween().set_ignore_time_scale(true)
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_callback(func() -> void:
		c.pivot_offset = c.size * 0.5
		c.scale = Vector2.ONE * 0.96)
	tw.set_parallel(true)
	tw.tween_property(c, "modulate:a", 1.0, Brand.T_FAST)
	tw.tween_property(c, "scale", Vector2.ONE, Brand.T_BASE).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Staggered fade-in for a list of children (quick).
static func stagger(parent: Control, step := 0.03) -> void:
	var i := 0
	for ch in parent.get_children():
		if ch is Control:
			var c: Control = ch
			c.modulate.a = 0.0
			var tw := c.create_tween().set_ignore_time_scale(true)
			tw.tween_interval(minf(i * minf(step, 0.03), 0.24))
			tw.tween_property(c, "modulate:a", 1.0, Brand.T_FAST)
			i += 1


# --- modal -----------------------------------------------------------------------------

## Full-screen dimmed modal with a centered panel. It swallows every touch, so
## nothing behind it (like a swipe-to-kick) reacts. Returns the panel's VBox;
## free the returned modal root with modal_root(vbox).queue_free().
static func modal(host: Node, title: String) -> VBoxContainer:
	return BrandUi.modal(host, title)


static func modal_root(content: Control) -> Control:
	var n: Node = content
	while n != null and n.name != "Modal":
		n = n.get_parent()
	return n as Control


## Yes/No confirmation. on_yes runs only if confirmed.
static func confirm(host: Node, title: String, message: String, yes_text: String,
		on_yes: Callable) -> void:
	var v := modal(host, title)
	v.add_child(BrandUi.text(message))
	var root := modal_root(v)
	var yes := button(yes_text, func() -> void:
		root.queue_free()
		on_yes.call(), DANGER_KIND)
	var no := button("Cancel", root.queue_free)
	v.add_child(yes)
	v.add_child(no)
	no.grab_focus.call_deferred()
