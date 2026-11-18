class_name UiKit
extends RefCounted
## Shared look and building blocks for menu screens and overlays, so every
## screen scales the same way. Sizes are in the 720x1280 base viewport
## (project stretch mode canvas_items + aspect expand), which Godot scales to
## any phone. Buttons are >= 88 px tall (about 9 mm on a phone) for thumbs.
## Landscape / Steam: content sits in a centered column of COLUMN_WIDTH, so a
## wide window just gets more side margin.

const BG_TOP := Color(0.07, 0.24, 0.14)
const BG_BOTTOM := Color(0.02, 0.07, 0.05)
const ACCENT := Color(1.0, 0.8, 0.25)
const GOOD := Color(0.45, 1.0, 0.45)
const BAD := Color(1.0, 0.4, 0.3)
const MUTED := Color(1.0, 1.0, 1.0, 0.6)
const PANEL := Color(0.0, 0.0, 0.0, 0.42)
const BUTTON := Color(0.12, 0.42, 0.24)
const BUTTON_HOVER := Color(0.16, 0.52, 0.3)
const BUTTON_PRESSED := Color(0.08, 0.3, 0.17)
const DANGER := Color(0.62, 0.16, 0.12)

const COLUMN_WIDTH := 640.0
const BUTTON_HEIGHT := 96.0
const MARGIN := 28

static var _theme: Theme


static func theme() -> Theme:
	if _theme != null:
		return _theme
	var t := Theme.new()
	t.default_font_size = 32

	t.set_color("font_color", "Label", Color.WHITE)
	t.set_color("font_outline_color", "Label", Color(0.0, 0.0, 0.0, 0.8))
	t.set_constant("outline_size", "Label", 6)

	for type in ["Button", "CheckButton"]:
		t.set_stylebox("normal", type, _box(BUTTON, 14))
		t.set_stylebox("hover", type, _box(BUTTON_HOVER, 14))
		t.set_stylebox("pressed", type, _box(BUTTON_PRESSED, 14))
		t.set_stylebox("hover_pressed", type, _box(BUTTON_PRESSED, 14))
		t.set_stylebox("disabled", type, _box(Color(0.2, 0.2, 0.2, 0.6), 14))
		t.set_stylebox("focus", type, _box(Color(0, 0, 0, 0), 14, ACCENT))
		t.set_font_size("font_size", type, 36)
		for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color",
				"font_hover_pressed_color"]:
			t.set_color(c, type, Color.WHITE)
		t.set_color("font_disabled_color", type, MUTED)
	# Toggle rows are panels, not green buttons.
	for s in ["normal", "hover", "pressed", "hover_pressed"]:
		t.set_stylebox(s, "CheckButton", _box(PANEL, 14))
	t.set_constant("h_separation", "CheckButton", 16)
	t.set_icon("checked", "CheckButton", _switch_texture(true))
	t.set_icon("unchecked", "CheckButton", _switch_texture(false))

	t.set_stylebox("panel", "PanelContainer", _box(PANEL, 16))

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

	t.set_constant("separation", "VBoxContainer", 16)
	_theme = t
	return t


static func _box(color: Color, radius: int, border := Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = color
	b.set_corner_radius_all(radius)
	b.content_margin_left = 24
	b.content_margin_right = 24
	b.content_margin_top = 14
	b.content_margin_bottom = 14
	if border.a > 0.0:
		b.border_color = border
		b.set_border_width_all(4)
	return b


## Round medal: gold when unlocked, a dim grey ring when locked.
static func badge_texture(unlocked: bool) -> ImageTexture:
	var size := 48
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var r := size * 0.5
	for y in size:
		for x in size:
			var d := Vector2(x + 0.5 - r, y + 0.5 - r).length()
			var c: Color
			if unlocked:
				c = ACCENT.darkened(0.25) if d > r - 6.0 else ACCENT
			else:
				c = MUTED if d > r - 5.0 else Color(0, 0, 0, 0.35)
			c.a *= clampf(r - d, 0.0, 1.0)
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


## Pill-shaped on/off switch, big enough for a thumb.
static func _switch_texture(on: bool) -> ImageTexture:
	var w := 92
	var h := 52
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var r := h * 0.5
	var knob_x := w - r if on else r
	var track := ACCENT if on else Color(1, 1, 1, 0.25)
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


# --- screen frame --------------------------------------------------------------

## Fills `root` (a full-screen Control) with the standard background and a
## safe-area-aware centered column, and returns that column.
static func build_frame(root: Control, title: String) -> VBoxContainer:
	root.theme = theme()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := TextureRect.new()
	bg.texture = _gradient(BG_TOP, BG_BOTTOM)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)

	var safe := MarginContainer.new()
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
		var l := label(title, 60, ACCENT)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(l)
	return col


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


static func _gradient(top: Color, bottom: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, top)
	g.set_color(1, bottom)
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	tex.width = 8
	tex.height = 256
	return tex


# --- widgets -------------------------------------------------------------------

static func label(text: String, size: int = 32, color := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func button(text: String, on_pressed: Callable, color := Color(0, 0, 0, 0)) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size.y = BUTTON_HEIGHT
	# Long text (e.g. a player's name) ends in "..." instead of widening the column.
	b.clip_text = true
	b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	# Keyboard/gamepad focus on desktop (Steam); no lingering focus ring after taps on phones.
	b.focus_mode = Control.FOCUS_NONE if OS.has_feature("mobile") else Control.FOCUS_ALL
	if color.a > 0.0:
		b.add_theme_stylebox_override("normal", _box(color, 14))
		b.add_theme_stylebox_override("hover", _box(color.lightened(0.12), 14))
		b.add_theme_stylebox_override("pressed", _box(color.darkened(0.2), 14))
	b.pressed.connect(func() -> void:
		Sfx.play(&"ui_tap")
		on_pressed.call())
	return b


## A row with a name on the left and a value on the right. A long value
## (Career Mode, e.g. "Pro, 6 seasons (Metro Monarchs)") wraps on the right
## instead of squeezing the name; short values look exactly as before.
static func stat_row(name: String, value: String, value_color := Color.WHITE) -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(h)
	var n := label(name, 30)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(n)
	var v := label(value, 34, value_color)
	v.autowrap_mode = TextServer.AUTOWRAP_OFF
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if value.length() > 16:
		n.autowrap_mode = TextServer.AUTOWRAP_OFF
		n.size_flags_horizontal = Control.SIZE_FILL
		v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	return p


static func section(text: String) -> Label:
	var l := label(text, 26, MUTED)
	return l


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
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(sc)
	var pad := MarginContainer.new()  # keeps rows clear of the scrollbar
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_right", 16)
	sc.add_child(pad)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	pad.add_child(list)
	return list


# --- modal ---------------------------------------------------------------------

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
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _box(Color(0.05, 0.13, 0.09, 0.97), 20, ACCENT))
	panel.custom_minimum_size.x = minf(COLUMN_WIDTH - 40.0, 600.0)
	center.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 18)
	panel.add_child(v)
	if title != "":
		var l := label(title, 48, ACCENT)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(l)
	host.add_child(root)
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
		on_yes.call(), DANGER)
	var no := button("Cancel", root.queue_free)
	v.add_child(yes)
	v.add_child(no)
	no.grab_focus.call_deferred()
