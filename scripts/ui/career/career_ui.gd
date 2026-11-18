class_name CareerUi
extends RefCounted
## Reusable Career Mode widgets, built on UiKit's theme (same sizes, colors
## and thumb-friendly heights). Used by the career screens and the debug screen.

const SMALL := 24
const GOOD_TEXT := Color(0.55, 1.0, 0.55)
const BAD_TEXT := Color(1.0, 0.55, 0.45)


## "Energy   70" over a full-width slider. on_change(value) fires while dragging.
static func slider_row(title: String, value: float, on_change: Callable,
		min_v: float = 0.0, max_v: float = 100.0, step: float = 1.0) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	var h := HBoxContainer.new()
	v.add_child(h)
	var name_l := UiKit.label(title, 28)
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(name_l)
	var val_l := UiKit.label(_fmt(value, step), 28, UiKit.ACCENT)
	val_l.autowrap_mode = TextServer.AUTOWRAP_OFF
	h.add_child(val_l)
	var s := HSlider.new()
	s.min_value = min_v
	s.max_value = max_v
	s.step = step
	s.value = value
	s.custom_minimum_size.y = 52
	s.focus_mode = Control.FOCUS_NONE if OS.has_feature("mobile") else Control.FOCUS_ALL
	s.value_changed.connect(func(x: float) -> void:
		val_l.text = _fmt(x, step)
		on_change.call(x))
	v.add_child(s)
	return v


## A switch row (UiKit's themed CheckButton). on_toggled(on).
static func toggle_row(text: String, on: bool, on_toggled: Callable) -> CheckButton:
	var b := CheckButton.new()
	b.text = text
	b.button_pressed = on
	b.custom_minimum_size.y = UiKit.BUTTON_HEIGHT
	b.add_theme_font_size_override("font_size", 28)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.focus_mode = Control.FOCUS_NONE if OS.has_feature("mobile") else Control.FOCUS_ALL
	b.toggled.connect(func(x: bool) -> void: on_toggled.call(x))
	return b


## One Game Day Outlook line: "Rested: +accuracy, steadier aim", green or red.
static func outlook_line(line: Dictionary, size: int = SMALL) -> Label:
	var good: bool = line.get("good", false)
	var text := "%s %s" % ["+" if good else "-", line.get("label", "")]
	var detail := str(line.get("detail", ""))
	if detail != "":
		text += ":  " + detail
	return UiKit.label(text, size, GOOD_TEXT if good else BAD_TEXT)


## Multi-line numeric readout of a profile (debug / tuning).
static func profile_text(p: KickProfile, kt: KickTuning) -> String:
	var need := PackedStringArray()
	for yd in [30, 40, 50, 60]:
		var n := p.power_needed(yd, kt)
		need.append("%d:%s" % [yd, ("%d%%" % roundi(n * 100.0)) if n <= 1.0 else "--"])
	return "\n".join([
		"Power x%.2f   Range %d yd   Needs %s" % [p.power_mult, p.max_range_yards(kt),
			"  ".join(need)],
		"Aim error %.2f deg   Wobble x%.2f   Window x%.2f" % [
			p.accuracy_spread_deg, p.wobble_mult, p.window_mult],
		"Pressure x%.2f  +%.2f   Wind x%.2f   Injury %d%%/wk" % [
			p.pressure_sensitivity, p.pressure_add, p.wind_mult, roundi(p.injury_risk * 100.0)],
	])


static func _fmt(x: float, step: float) -> String:
	return str(roundi(x)) if step >= 1.0 else "%.2f" % x


# --- stats -------------------------------------------------------------------------

## "Energy  [=====    ]  62" in one compact row.
## name_width: label column width (narrower in the two-column Hub grid).
static func stat_bar(title: String, value: float, size: int = 24, name_width: float = 150.0) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var n := UiKit.label(title, size)
	n.custom_minimum_size.x = name_width
	n.autowrap_mode = TextServer.AUTOWRAP_OFF
	n.clip_text = true
	h.add_child(n)
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(40, 16)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.45)
	bg.set_corner_radius_all(6)
	var fill := StyleBoxFlat.new()
	fill.bg_color = stat_color(value)
	fill.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)
	h.add_child(bar)
	var v := UiKit.label(str(roundi(value)), size, UiKit.ACCENT)
	v.custom_minimum_size.x = 40
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.autowrap_mode = TextServer.AUTOWRAP_OFF
	h.add_child(v)
	return h


static func stat_color(v: float) -> Color:
	if v < 30.0:
		return UiKit.BAD
	if v < 55.0:
		return Color(1.0, 0.78, 0.3)
	return UiKit.GOOD


## A panel with a group title and a bar per stat. short_names: for narrow columns.
static func group_panel(c: CareerData, group: String, short_names := false) -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	p.add_child(v)
	v.add_child(UiKit.label(str(CareerData.GROUP_NAMES[group]).to_upper(), 22, UiKit.MUTED))
	for k in CareerData.GROUP_KEYS[group]:
		var name: String = CareerData.STAT_NAMES[k]
		if short_names:
			name = name.replace("Kicking ", "")
		v.add_child(stat_bar(name, c.stat(k), 22, 124.0 if short_names else 150.0))
	return p


## Chips for a set of applied/projected changes ({"life": {"energy": -8}, ...}).
static func change_chips(changes: Dictionary, size: int = 24) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", 8)
	f.add_theme_constant_override("v_separation", 6)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for g in CareerData.GROUP_KEYS:
		var grp: Dictionary = changes.get(g, {})
		for k in CareerData.GROUP_KEYS[g]:
			if not grp.has(k):
				continue
			var d := float(grp[k])
			var name := str(CareerData.STAT_NAMES[k]).replace("Kicking ", "")
			f.add_child(chip("%s%s %s" % ["+" if d > 0 else "", _num(d), name], d > 0))
	return f


static func chip(text: String, good: bool, size: int = 22) -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.1, 0.35, 0.15, 0.9) if good else Color(0.4, 0.12, 0.1, 0.9)
	box.set_corner_radius_all(10)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	p.add_theme_stylebox_override("panel", box)
	var l := UiKit.label(text, size)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	p.add_child(l)
	return p


static func _num(d: float) -> String:
	return str(roundi(d)) if absf(d - roundf(d)) < 0.05 else "%.1f" % d


## Game-day modifier chips: "Game day: Rested (+accuracy)".
static func modifier_chips(ids: Array, size: int = 22) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", 8)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for id in ids:
		var m := CareerContent.modifier(str(id))
		var fx: Dictionary = m.get("effects", {})
		f.add_child(chip("Game day: %s (%s)" % [m.get("label", id), KickProfile.describe(fx)],
			KickProfile.net_good(fx), size))
	return f


## A tappable card (title + any content). Drags still scroll the list it is in;
## only a short tap picks it. enabled=false: a dimmed card that can't be picked.
static func card(on_pick: Callable, enabled := true) -> Array:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_PASS
	var normal := UiKit._box(UiKit.BUTTON if enabled else Color(0.15, 0.18, 0.16, 0.85), 14)
	if not enabled:
		p.add_theme_stylebox_override("panel", normal)
		p.modulate = Color(1, 1, 1, 0.75)
		var dv := VBoxContainer.new()
		dv.add_theme_constant_override("separation", 8)
		dv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.add_child(dv)
		return [p, dv]
	var pressed := UiKit._box(UiKit.BUTTON_PRESSED, 14)
	p.add_theme_stylebox_override("panel", normal)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(v)
	var state := {"down": Vector2.INF}
	p.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed:
				state["down"] = e.position
				p.add_theme_stylebox_override("panel", pressed)
			else:
				p.add_theme_stylebox_override("panel", normal)
				var down: Vector2 = state["down"]
				state["down"] = Vector2.INF
				if down != Vector2.INF and down.distance_to(e.position) < 24.0 \
						and Rect2(Vector2.ZERO, p.size).has_point(e.position):
					Sfx.play(&"ui_tap")
					on_pick.call()
		elif e is InputEventMouseMotion and state["down"] != Vector2.INF:
			if (state["down"] as Vector2).distance_to(e.position) >= 24.0:
				state["down"] = Vector2.INF
				p.add_theme_stylebox_override("panel", normal))
	return [p, v]


## Two buttons side by side, each half the width.
static func button_row(buttons: Array) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	for b in buttons:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(b)
	return h


static func centered(text: String, size: int, color := Color.WHITE) -> Label:
	var l := UiKit.label(text, size, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


static func html_color(s: String, fallback := Color.WHITE) -> Color:
	return Color.from_string(s, fallback)
