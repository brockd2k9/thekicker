class_name UiKit
extends RefCounted
## Shared look and building blocks for menu screens and overlays, so every
## screen scales and looks the same. Sizes are in the 720x1280 base viewport
## (project stretch mode canvas_items + aspect expand), which Godot scales to
## any phone. Buttons are >= 88 px tall (about 9 mm on a phone) for thumbs.
## Landscape / Steam: content sits in a centered column of COLUMN_WIDTH, so a
## wide window just gets more side margin.
##
## Look: tokens (colors, spacing, radii, fonts) live in UiTokens; fonts and
## base font sizes live in the Theme resource assets/ui/kicker_theme.tres
## (also the project's default theme). theme() adds the palette's styleboxes.
## Career Mode switches the palette per stage with set_stage().
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

## event -> haptic pulse in ms (0 = sound only). Sfx event names are the same.
const FEEDBACK := {
	&"ui_tap": 8, &"ui_confirm": 14, &"ui_back": 6, &"ui_locked": 30,
	&"ui_open": 0, &"ui_transition": 0,
	&"stat_up": 10, &"stat_down": 16, &"trait_unlock": 45, &"achievement": 50,
	&"result_good": 30, &"result_miss": 60, &"game_winner": 140, &"week_result": 20,
}

# Palette colors. Static vars (not consts) so Career Mode can switch them by
# stage; they keep the old names so screens can use UiKit.ACCENT etc.
static var palette: Dictionary = UiTokens.NIGHT
static var BG_TOP: Color = UiTokens.NIGHT["bg_top"]
static var BG_BOTTOM: Color = UiTokens.NIGHT["bg_bottom"]
static var TEXT: Color = UiTokens.NIGHT["text"]
static var ACCENT: Color = UiTokens.NIGHT["accent"]
static var ACCENT_TEXT: Color = UiTokens.NIGHT["accent_text"]
static var ALT: Color = UiTokens.NIGHT["alt"]
static var GOOD: Color = UiTokens.NIGHT["good"]
static var BAD: Color = UiTokens.NIGHT["bad"]
static var WARN: Color = UiTokens.NIGHT["warn"]
static var MUTED: Color = UiTokens.NIGHT["muted"]
static var PANEL: Color = UiTokens.NIGHT["panel"]
static var BUTTON: Color = UiTokens.NIGHT["button"]
static var BUTTON_HOVER: Color = (UiTokens.NIGHT["button"] as Color).lightened(0.1)
static var BUTTON_PRESSED: Color = (UiTokens.NIGHT["button"] as Color).darkened(0.25)
static var DANGER: Color = UiTokens.NIGHT["danger"]
## Player's team colors in Career Mode: [primary, secondary], or empty.
static var team: Array = []

static var _theme: Theme


# --- palette ----------------------------------------------------------------------------

static func use_palette(p: Dictionary) -> void:
	if p == palette and _theme != null:
		return
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
	BUTTON_HOVER = BUTTON.lightened(0.1)
	BUTTON_PRESSED = BUTTON.darkened(0.25)
	DANGER = p["danger"]
	_theme = null


## Career Mode: palette for the stage, plus the team's colors as accents.
static func set_stage(stage: String, team_colors: Array = []) -> void:
	use_palette(UiTokens.for_stage(stage))
	team = []
	for c in team_colors:
		team.append(Color.from_string(str(c), ACCENT) if not (c is Color) else c)


## Back to the default (menus outside Career Mode).
static func reset_palette() -> void:
	use_palette(UiTokens.NIGHT)
	team = []


## Team primary color, readable on the dark panels (or the accent).
static func team_color(i: int = 0) -> Color:
	if team.size() <= i:
		return ACCENT
	return team[i]


static func group_color(group: String) -> Color:
	return palette.get(group, ACCENT)


# --- theme -----------------------------------------------------------------------------

static func theme() -> Theme:
	if _theme != null:
		return _theme
	var base: Theme = load(UiTokens.THEME_PATH)
	var t: Theme = base.duplicate() if base != null else Theme.new()
	t.default_font_size = UiTokens.FONT_SIZE

	t.set_color("font_color", "Label", TEXT)
	t.set_constant("outline_size", "Label", 0)

	_button_type(t, SECONDARY, BUTTON, TEXT, ACCENT)
	t.set_type_variation(PRIMARY, "Button")
	_button_type(t, PRIMARY, ACCENT, ACCENT_TEXT, Color(0, 0, 0, 0))
	t.set_type_variation(DANGER_KIND, "Button")
	_button_type(t, DANGER_KIND, DANGER, Color.WHITE, Color(0, 0, 0, 0))
	for type in [SECONDARY, PRIMARY, DANGER_KIND]:
		t.set_font_size("font_size", type, UiTokens.FONT_BUTTON)
		t.set_constant("h_separation", type, 14)
		t.set_constant("icon_max_width", type, 40)

	# Toggle rows are panels with a switch.
	var row := _box(PANEL, UiTokens.RADIUS)
	for s in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		t.set_stylebox(s, "CheckButton", row)
	t.set_stylebox("focus", "CheckButton", _box(Color(0, 0, 0, 0), UiTokens.RADIUS, ACCENT))
	t.set_constant("h_separation", "CheckButton", 16)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color",
			"font_hover_pressed_color"]:
		t.set_color(c, "CheckButton", TEXT)
	t.set_icon("checked", "CheckButton", _switch_texture(true))
	t.set_icon("unchecked", "CheckButton", _switch_texture(false))

	t.set_stylebox("panel", "PanelContainer", panel_box())

	var track := _box(Color(0, 0, 0, 0.5), 8)
	track.content_margin_top = 8
	track.content_margin_bottom = 8
	t.set_stylebox("slider", "HSlider", track)
	var fill := _box(ACCENT, 8)
	t.set_stylebox("grabber_area", "HSlider", fill)
	t.set_stylebox("grabber_area_highlight", "HSlider", fill)
	var knob := _circle_texture(44, Color.WHITE)
	t.set_icon("grabber", "HSlider", knob)
	t.set_icon("grabber_highlight", "HSlider", knob)

	var le := _box(Color(0, 0, 0, 0.45), UiTokens.RADIUS_BUTTON, palette["panel_edge"])
	t.set_stylebox("normal", "LineEdit", le)
	t.set_stylebox("focus", "LineEdit", _box(Color(0, 0, 0, 0), UiTokens.RADIUS_BUTTON, ACCENT))
	t.set_color("font_color", "LineEdit", TEXT)
	t.set_color("font_placeholder_color", "LineEdit", MUTED)
	t.set_color("caret_color", "LineEdit", ACCENT)

	var bar_bg := _box(Color(TEXT, 0.1), 6)
	bar_bg.set_content_margin_all(0)
	t.set_stylebox("background", "ProgressBar", bar_bg)
	var bar_fill := _box(ACCENT, 6)
	bar_fill.set_content_margin_all(0)
	t.set_stylebox("fill", "ProgressBar", bar_fill)

	# Thin scroll bar that doesn't fight the content.
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(TEXT, 0.06)
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 3
	sb.content_margin_right = 3
	t.set_stylebox("scroll", "VScrollBar", sb)
	var grab := StyleBoxFlat.new()
	grab.bg_color = Color(TEXT, 0.3)
	grab.set_corner_radius_all(4)
	grab.content_margin_left = 3
	grab.content_margin_right = 3
	t.set_stylebox("grabber", "VScrollBar", grab)
	t.set_stylebox("grabber_highlight", "VScrollBar", grab)
	t.set_stylebox("grabber_pressed", "VScrollBar", grab)

	t.set_constant("separation", "VBoxContainer", UiTokens.GAP)
	_theme = t
	return t


## Normal / hover / pressed / disabled / focus boxes for one button kind.
## stripe: the left broadcast stripe color (secondary buttons).
static func _button_type(t: Theme, type: StringName, bg: Color, fg: Color, stripe: Color) -> void:
	var r := UiTokens.RADIUS_BUTTON
	var normal := _skewed(_box(bg, r))
	var hover := _skewed(_box(bg.lightened(0.1), r))
	var pressed := _skewed(_box(bg.darkened(0.18), r))
	var disabled := _skewed(_box(Color(BUTTON, 0.55), r))
	for b in [normal, hover, pressed]:
		if stripe.a > 0.0:
			b.border_color = stripe
			b.border_width_left = UiTokens.BUTTON_STRIPE
		else:
			# Solid buttons: a darker bottom lip, like a pressed key.
			b.border_color = bg.darkened(0.35)
			b.border_width_bottom = 5
		b.shadow_color = Color(0, 0, 0, 0.45)
		b.shadow_size = 10
		b.shadow_offset = Vector2(0, 5)
	if type == PRIMARY:
		# Floodlight glow around the main action.
		for b in [normal, hover]:
			b.shadow_color = Color(bg, float(palette.get("glow", 0.4)))
			b.shadow_size = 20
			b.shadow_offset = Vector2.ZERO
	pressed.border_width_bottom = 2
	pressed.shadow_size = 4
	t.set_stylebox("normal", type, normal)
	t.set_stylebox("hover", type, hover)
	t.set_stylebox("pressed", type, pressed)
	t.set_stylebox("hover_pressed", type, pressed)
	t.set_stylebox("disabled", type, disabled)
	var focus := _skewed(_box(Color(0, 0, 0, 0), r, Color.WHITE if type == PRIMARY else ACCENT))
	t.set_stylebox("focus", type, focus)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color",
			"font_hover_pressed_color"]:
		t.set_color(c, type, fg)
	t.set_color("font_disabled_color", type, Color(TEXT, 0.4))
	for c in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color",
			"icon_hover_pressed_color"]:
		t.set_color(c, type, Color.WHITE)
	t.set_color("icon_disabled_color", type, Color(1, 1, 1, 0.4))


static func _skewed(b: StyleBoxFlat) -> StyleBoxFlat:
	b.skew = Vector2(UiTokens.SKEW, 0)
	return b


static func _box(color: Color, radius: int, border := Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = color
	b.set_corner_radius_all(radius)
	b.content_margin_left = UiTokens.PAD
	b.content_margin_right = UiTokens.PAD
	b.content_margin_top = 14
	b.content_margin_bottom = 14
	b.anti_aliasing = true
	if border.a > 0.0:
		b.border_color = border
		b.set_border_width_all(3)
	return b


## Standard panel: palette panel color, thin edge, soft shadow. bar: optional
## colored broadcast bar along the top.
static func panel_box(bar := Color(0, 0, 0, 0), bg := Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var b := _box(PANEL if bg.a == 0.0 else bg, UiTokens.RADIUS)
	b.content_margin_top = UiTokens.PAD_V
	b.content_margin_bottom = UiTokens.PAD_V
	b.border_color = palette["panel_edge"]
	b.set_border_width_all(1)
	if bar.a > 0.0:
		b.border_color = bar
		b.border_width_left = 0
		b.border_width_right = 0
		b.border_width_bottom = 0
		b.border_width_top = UiTokens.CARD_BAR
		b.content_margin_top = UiTokens.PAD_V + 2
	b.shadow_color = Color(0, 0, 0, 0.4)
	b.shadow_size = 12
	b.shadow_offset = Vector2(0, 6)
	return b


## Round medal: gold when unlocked, a dim grey ring when locked.
static func badge_texture(unlocked: bool) -> Texture2D:
	return UiIcons.texture("achievements", ACCENT if unlocked else Color(MUTED, 0.6), 56)


## Pill-shaped on/off switch, big enough for a thumb.
static func _switch_texture(on: bool) -> ImageTexture:
	var w := 92
	var h := 52
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var r := h * 0.5
	var knob_x := w - r if on else r
	var track := ACCENT if on else Color(1, 1, 1, 0.22)
	for y in h:
		for x in w:
			var px := Vector2(x + 0.5, y + 0.5)
			var cx := clampf(px.x, r, w - r)
			var d_track := px.distance_to(Vector2(cx, r))
			var c := track
			c.a *= clampf(r - d_track, 0.0, 1.0)
			var d_knob := px.distance_to(Vector2(knob_x, r))
			var k := clampf(r - 5.0 - d_knob, 0.0, 1.0)
			c = c.blend(Color(1, 1, 1, k))
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


static func _circle_texture(size: int, color: Color) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var r := size * 0.5
	for y in size:
		for x in size:
			var d := Vector2(x + 0.5 - r, y + 0.5 - r).length()
			var c := color
			c.a = clampf(r - d, 0.0, 1.0)
			img.set_pixel(x, y, c)
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

## Fills `root` (a full-screen Control) with the backdrop and a
## safe-area-aware centered column, and returns that column.
static func build_frame(root: Control, title: String) -> VBoxContainer:
	root.theme = theme()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := Backdrop.new()
	bg.palette = palette
	if not team.is_empty():
		bg.team = team[0]
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	var safe := MarginContainer.new()
	safe.name = "Safe"
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(safe)
	apply_safe_area(safe, MARGIN)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe.add_child(row)
	row.add_child(_spacer(true))
	var col := VBoxContainer.new()
	col.custom_minimum_size.x = COLUMN_WIDTH
	col.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 18)
	row.add_child(col)
	row.add_child(_spacer(true))

	if title != "":
		col.add_child(title_block(title))
	enter(safe)
	return col


## Short slide-up + fade-in for a screen's content (screen transitions).
static func enter(c: Control) -> void:
	c.modulate.a = 0.0
	var tw := c.create_tween().set_ignore_time_scale(true)
	tw.set_parallel(true)
	tw.tween_property(c, "modulate:a", 1.0, UiTokens.FADE_IN)
	c.position.y = 26.0
	tw.tween_property(c, "position:y", 0.0, UiTokens.FADE_IN + 0.08) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


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


## Broadcast lower-third screen title: big display text, a slanted accent
## tag on the left and a rule underneath. kicker: small line above it.
static func title_block(text: String, kicker := "") -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if kicker != "":
		var k := label(kicker.to_upper(), UiTokens.FONT_SECTION, ACCENT, UiTokens.FONT_CONDENSED)
		k.autowrap_mode = TextServer.AUTOWRAP_OFF
		k.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		v.add_child(k)
	var t := label(text.to_upper(), UiTokens.FONT_TITLE, TEXT, UiTokens.FONT_DISPLAY)
	v.add_child(t)
	v.add_child(rule())
	return v


## Accent tag + thin line (under titles and section heads).
static func rule(color := Color(0, 0, 0, 0)) -> Control:
	var c: Color = ACCENT if color.a == 0.0 else color
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tag := Panel.new()
	var tb := StyleBoxFlat.new()
	tb.bg_color = c
	tb.skew = Vector2(UiTokens.SKEW * 2.0, 0)
	tag.add_theme_stylebox_override("panel", tb)
	tag.custom_minimum_size = Vector2(110, 6)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(tag)
	var line := ColorRect.new()
	line.color = Color(TEXT, 0.14)
	line.custom_minimum_size.y = 2
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.size_flags_vertical = Control.SIZE_SHRINK_END
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(line)
	return h


# --- widgets ---------------------------------------------------------------------------

## font: UiTokens.FONT_BODY (default), FONT_DISPLAY, FONT_BANNER, FONT_CONDENSED.
static func label(text: String, size: int = 32, color := Color(0, 0, 0, 0),
		font: StringName = UiTokens.FONT_BODY) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
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


## kind: PRIMARY (main action, accent + glow), SECONDARY (default), DANGER_KIND;
## or a Color for a one-off custom color. icon: a UiIcons id.
static func button(text: String, on_pressed: Callable, kind: Variant = SECONDARY,
		icon := "") -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size.y = BUTTON_HEIGHT
	# Long text (e.g. a player's name) ends in "..." instead of widening the column.
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
		var c: Color = kind
		if c.is_equal_approx(DANGER):
			b.theme_type_variation = DANGER_KIND
		else:
			b.add_theme_stylebox_override("normal", _skewed(_box(c, UiTokens.RADIUS_BUTTON)))
			b.add_theme_stylebox_override("hover", _skewed(_box(c.lightened(0.12), UiTokens.RADIUS_BUTTON)))
			b.add_theme_stylebox_override("pressed", _skewed(_box(c.darkened(0.2), UiTokens.RADIUS_BUTTON)))
	if icon != "":
		var ic_col := ACCENT_TEXT if b.theme_type_variation == PRIMARY else \
			(Color.WHITE if b.theme_type_variation == DANGER_KIND else ACCENT)
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


## Squeeze on press, spring back on release (any Button).
static func add_press_feedback(b: BaseButton) -> void:
	b.resized.connect(func() -> void: b.pivot_offset = b.size * 0.5)
	b.button_down.connect(func() -> void:
		if b.disabled:
			return
		var tw := b.create_tween().set_ignore_time_scale(true)
		tw.tween_property(b, "scale", Vector2.ONE * UiTokens.PRESS_SCALE, 0.06))
	b.button_up.connect(func() -> void:
		var tw := b.create_tween().set_ignore_time_scale(true)
		tw.tween_property(b, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))


## A row with a name on the left and a value on the right. A long value
## (Career Mode, e.g. "Pro, 6 seasons (Metro Monarchs)") wraps on the right
## instead of squeezing the name; short values look exactly as before.
static func stat_row(name: String, value: String, value_color := Color(0, 0, 0, 0),
		icon := "") -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := panel_box()
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	box.shadow_size = 6
	box.shadow_offset = Vector2(0, 3)
	p.add_theme_stylebox_override("panel", box)
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_theme_constant_override("separation", 12)
	p.add_child(h)
	if icon != "":
		h.add_child(UiIcons.rect(icon, ACCENT, 30))
	var n := label(name, 28, TEXT)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(n)
	var v := label(value, 34, TEXT if value_color.a == 0.0 else value_color, UiTokens.FONT_DISPLAY)
	v.autowrap_mode = TextServer.AUTOWRAP_OFF
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if value.length() > 16:
		n.autowrap_mode = TextServer.AUTOWRAP_OFF
		n.size_flags_horizontal = Control.SIZE_FILL
		v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_theme_font_size_override("font_size", 30)
	h.add_child(v)
	return p


## Section head: small accent tag + condensed caps.
static func section(text: String, color := Color(0, 0, 0, 0)) -> Control:
	var c: Color = ACCENT if color.a == 0.0 else color
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tag := Panel.new()
	var tb := StyleBoxFlat.new()
	tb.bg_color = c
	tb.skew = Vector2(UiTokens.SKEW * 2.0, 0)
	tag.add_theme_stylebox_override("panel", tb)
	tag.custom_minimum_size = Vector2(8, 24)
	tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(tag)
	var l := label(text.to_upper(), UiTokens.FONT_SECTION + 2, Color(TEXT, 0.8), UiTokens.FONT_DISPLAY)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(l)
	return h


## Small tag ("HOME", "+3 Accuracy", "SOCIAL"). filled: solid color, white text.
static func chip(text: String, color: Color, filled := false, icon := "", size := 22) -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var b := _skewed(_box(color if filled else Color(color, 0.18), UiTokens.RADIUS_CHIP))
	b.content_margin_top = 3
	b.content_margin_bottom = 3
	b.content_margin_left = 14
	b.content_margin_right = 14
	if not filled:
		b.border_color = Color(color, 0.45)
		b.set_border_width_all(1)
	p.add_theme_stylebox_override("panel", b)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(h)
	var fg := readable_on(color) if filled else color.lightened(0.25)
	if icon != "":
		h.add_child(UiIcons.rect(icon, fg, size))
	var l := label(text, size, fg, UiTokens.FONT_CONDENSED)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	h.add_child(l)
	return p


## Black or white text, whichever reads on `bg`.
static func readable_on(bg: Color) -> Color:
	return Color(0.06, 0.05, 0.03) if bg.get_luminance() > 0.55 else Color.WHITE


## Panel with an optional top color bar; returns [panel, vbox].
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
static func stat_tile(value: String, caption: String, color := Color(0, 0, 0, 0)) -> PanelContainer:
	var parts := card(ACCENT if color.a == 0.0 else color, 0)
	var p: PanelContainer = parts[0]
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v: VBoxContainer = parts[1]
	var n := line(value, 44, TEXT, UiTokens.FONT_BANNER)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(n)
	var c := line(caption.to_upper(), 20, MUTED, UiTokens.FONT_CONDENSED)
	c.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(c)
	return p


## Broadcast ticker: red tag + white strip. Scrolls slowly only if it doesn't fit.
static func ticker(tag_text: String, text: String) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tag := PanelContainer.new()
	var tb := _box(ALT if ALT.get_luminance() < 0.8 else ACCENT, 0)
	tb.content_margin_top = 4
	tb.content_margin_bottom = 4
	tb.content_margin_left = 14
	tb.content_margin_right = 14
	tag.add_theme_stylebox_override("panel", tb)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tl := label(tag_text.to_upper(), 26, readable_on(tb.bg_color), UiTokens.FONT_DISPLAY)
	tl.autowrap_mode = TextServer.AUTOWRAP_OFF
	tag.add_child(tl)
	h.add_child(tag)
	var strip := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.96, 0.97)
	strip.add_theme_stylebox_override("panel", sb)
	strip.clip_contents = true
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(strip)
	var l := label(text.to_upper(), 26, Color(0.08, 0.09, 0.12), UiTokens.FONT_CONDENSED)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	strip.add_child(l)
	strip.resized.connect(func() -> void:
		strip.custom_minimum_size.y = l.get_minimum_size().y + 6
		l.position = Vector2(14, 3)
		var w := l.get_minimum_size().x
		if w + 28 > strip.size.x and not strip.has_meta("tw"):
			var tw := strip.create_tween().set_loops()
			strip.set_meta("tw", tw)
			tw.tween_interval(1.5)
			tw.tween_property(l, "position:x", strip.size.x - w - 14, (w - strip.size.x) / 40.0 + 1.0)
			tw.tween_interval(1.5)
			tw.tween_property(l, "position:x", 14.0, 0.6))
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

## Pops a control in (scale + fade), e.g. trait unlocks and banners.
static func pop_in(c: Control, delay := 0.0, from_scale := 0.6) -> void:
	c.modulate.a = 0.0
	var start := func() -> void:
		c.pivot_offset = c.size * 0.5
		c.scale = Vector2.ONE * from_scale
	if c.is_inside_tree():
		start.call()
	else:
		c.ready.connect(start, CONNECT_ONE_SHOT)
	var tw := c.create_tween().set_ignore_time_scale(true)
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_callback(func() -> void: c.pivot_offset = c.size * 0.5)
	tw.set_parallel(true)
	tw.tween_property(c, "modulate:a", 1.0, 0.15)
	tw.tween_property(c, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Staggered fade-up for a list of children (cards appearing one after another).
static func stagger(parent: Control, step := 0.05) -> void:
	var i := 0
	for ch in parent.get_children():
		if ch is Control:
			var c: Control = ch
			c.modulate.a = 0.0
			var tw := c.create_tween().set_ignore_time_scale(true)
			tw.tween_interval(0.08 + i * step)
			tw.tween_property(c, "modulate:a", 1.0, 0.2)
			i += 1


# --- modal -----------------------------------------------------------------------------

## Full-screen dimmed modal with a centered panel. It swallows every touch, so
## nothing behind it (like a swipe-to-kick) reacts. Returns the panel's VBox;
## free the returned modal root with modal_root(vbox).queue_free().
static func modal(host: Node, title: String) -> VBoxContainer:
	var root := Control.new()
	root.name = "Modal"
	root.theme = theme()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.process_mode = Node.PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.66)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	var panel := PanelContainer.new()
	var box := panel_box(ACCENT, Color(BG_TOP.darkened(0.25), 0.98))
	box.content_margin_left = 28
	box.content_margin_right = 28
	box.content_margin_top = 26
	box.content_margin_bottom = 26
	box.shadow_size = 30
	box.shadow_color = Color(0, 0, 0, 0.6)
	panel.add_theme_stylebox_override("panel", box)
	panel.custom_minimum_size.x = minf(COLUMN_WIDTH - 40.0, 600.0)
	center.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 18)
	panel.add_child(v)
	if title != "":
		var l := label(title.to_upper(), 48, TEXT, UiTokens.FONT_DISPLAY)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(l)
	host.add_child(root)
	# Fade the dim in and pop the panel.
	dim.modulate.a = 0.0
	var tw := root.create_tween().set_ignore_time_scale(true)
	tw.tween_property(dim, "modulate:a", 1.0, 0.15)
	panel.modulate.a = 0.0
	var tw2 := root.create_tween().set_ignore_time_scale(true)
	tw2.tween_callback(func() -> void:
		panel.pivot_offset = panel.size * 0.5
		panel.scale = Vector2.ONE * 0.9)
	tw2.set_parallel(true)
	tw2.tween_property(panel, "modulate:a", 1.0, 0.14)
	tw2.tween_property(panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return v


static func modal_root(content: Control) -> Control:
	var n: Node = content
	while n != null and n.name != "Modal":
		n = n.get_parent()
	return n as Control


## Yes/No confirmation. on_yes runs only if confirmed.
static func confirm(host: Node, title: String, message: String, yes_text: String,
		on_yes: Callable) -> void:
	var v := modal(host, title)
	var msg := label(message, 30)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(msg)
	var root := modal_root(v)
	var yes := button(yes_text, func() -> void:
		root.queue_free()
		on_yes.call(), DANGER_KIND)
	var no := button("Cancel", root.queue_free)
	v.add_child(yes)
	v.add_child(no)
	no.grab_focus.call_deferred()
