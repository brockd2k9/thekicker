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
	s.custom_minimum_size.y = UiTokens.TAP_MIN
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


## One Game Day Outlook line as a colored chip row: icon, label, detail.
static func outlook_line(line: Dictionary, size: int = SMALL) -> Control:
	var good: bool = line.get("good", false)
	var c: Color = UiKit.GOOD if good else UiKit.BAD
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := UiKit.panel_box(Color(0, 0, 0, 0), Color(c, 0.12))
	box.border_color = c
	box.border_width_top = 0
	box.border_width_right = 0
	box.border_width_bottom = 0
	box.border_width_left = 6
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	box.shadow_size = 0
	p.add_theme_stylebox_override("panel", box)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(h)
	h.add_child(UiIcons.rect("check" if good else "cross", c, 26))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(v)
	v.add_child(UiKit.label(str(line.get("label", "")), size + 2, c.lightened(0.2), UiTokens.FONT_DISPLAY))
	var detail := str(line.get("detail", ""))
	if detail != "":
		v.add_child(UiKit.label(detail, size - 2, UiKit.TEXT))
	return p


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

## Stat values the Hub showed last time (UI only, never saved), so bars glide
## to their new values after a week.
static var last_seen: Dictionary = {}


## One stat with icon and bar in its group's color (StatBar).
## name_width is kept for older callers; the bar now fills the row.
static func stat_bar(title: String, value: float, size: int = 24, _name_width: float = 150.0,
		key: String = "") -> StatBar:
	var k := key
	if k == "":
		for sk in CareerData.STAT_NAMES:
			if CareerData.STAT_NAMES[sk] == title:
				k = sk
	var g := CareerData.group_of(k) if k != "" else ""
	return StatBar.new(k, title, value, UiKit.group_color(g) if g != "" else stat_color(value), size)


static func stat_color(v: float) -> Color:
	if v < 30.0:
		return UiKit.BAD
	if v < 55.0:
		return UiKit.WARN
	return UiKit.GOOD


static func group_icon(group: String) -> String:
	return {CareerData.LIFE: "health", CareerData.FOOTBALL: "ball", CareerData.PERSONALITY: "charisma"}.get(group, "info")


## A card with a group title (in the group's color) and a bar per stat.
## short_names: for narrow columns. bars (optional): filled with key -> StatBar.
static func group_panel(c: CareerData, group: String, short_names := false, bars: Dictionary = {}) -> PanelContainer:
	var gc := UiKit.group_color(group)
	var parts := UiKit.card(gc, 10)
	var p: PanelContainer = parts[0]
	var v: VBoxContainer = parts[1]
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := UiKit.label(str(CareerData.GROUP_NAMES[group]).to_upper(), 24, gc, UiTokens.FONT_DISPLAY)
	v.add_child(title)
	for k in CareerData.GROUP_KEYS[group]:
		var name: String = CareerData.STAT_NAMES[k]
		if short_names:
			name = name.replace("Kicking ", "")
		var b := StatBar.new(k, name, c.stat(k), gc, 24 if short_names else 28)
		bars[k] = b
		v.add_child(b)
	return p


## Chips for a set of applied/projected changes ({"life": {"energy": -8}, ...}):
## the stat's icon, +/- and name, green for gains and red for losses.
static func change_chips(changes: Dictionary, size: int = 24) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", 8)
	f.add_theme_constant_override("v_separation", 8)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for g in CareerData.GROUP_KEYS:
		var grp: Dictionary = changes.get(g, {})
		for k in CareerData.GROUP_KEYS[g]:
			if not grp.has(k):
				continue
			var d := float(grp[k])
			var name := str(CareerData.STAT_NAMES[k]).replace("Kicking ", "")
			f.add_child(UiKit.chip("%s%s %s" % ["+" if d > 0 else "", _num(d), name],
				UiKit.GOOD if d > 0 else UiKit.BAD, false, k, size))
	return f


## Relationship changes {person id: change} as chips: "Coach Vance +5".
static func rel_chips(c: CareerData, rel: Dictionary, size: int = 24) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", 8)
	f.add_theme_constant_override("v_separation", 8)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for id in rel:
		var d := float(rel[id])
		if absf(d) < 0.5:
			continue
		f.add_child(UiKit.chip("%s %s%s" % [Relationships.name_of(c, str(id)), "+" if d > 0 else "", _num(d)],
			UiKit.GOOD if d > 0 else UiKit.BAD, false, str(Relationships.def(str(id)).get("icon", "social")), size))
	return f


static func chip(text: String, good: bool, size: int = 22) -> PanelContainer:
	return UiKit.chip(text, UiKit.GOOD if good else UiKit.BAD, false, "", size)


static func _num(d: float) -> String:
	return str(roundi(d)) if absf(d - roundf(d)) < 0.05 else "%.1f" % d


## Game-day modifier chips: "Game day: Rested (+accuracy)".
static func modifier_chips(ids: Array, size: int = 22) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", 8)
	f.add_theme_constant_override("v_separation", 8)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for id in ids:
		var m := CareerContent.modifier(str(id))
		var fx: Dictionary = m.get("effects", {})
		var good := KickProfile.net_good(fx)
		f.add_child(UiKit.chip("Game day: %s (%s)" % [m.get("label", id), KickProfile.describe(fx)],
			UiKit.GOOD if good else UiKit.BAD, false, "calendar", size))
	return f


## A tappable card (title + any content). Drags still scroll the list it is in;
## only a short tap picks it. enabled=false: a greyed-out card with a lock
## that can't be picked (tapping it just buzzes).
static func card(on_pick: Callable, enabled := true) -> Array:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_PASS
	p.custom_minimum_size.y = UiTokens.TAP_MIN
	var normal := UiKit.panel_box(Color(0, 0, 0, 0), UiKit.BUTTON)
	normal.border_color = UiKit.ACCENT
	normal.border_width_left = UiTokens.BUTTON_STRIPE + 2
	normal.border_width_top = 0
	normal.border_width_right = 0
	normal.border_width_bottom = 0
	normal.content_margin_top = 18
	normal.content_margin_bottom = 18
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not enabled:
		var locked := UiKit.panel_box(Color(0, 0, 0, 0), Color(0.5, 0.5, 0.55, 0.12))
		locked.border_color = Color(1, 1, 1, 0.12)
		locked.set_border_width_all(2)
		locked.shadow_size = 0
		locked.content_margin_top = 18
		locked.content_margin_bottom = 18
		p.add_theme_stylebox_override("panel", locked)
		p.modulate = Color(0.85, 0.85, 0.88, 0.8)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 14)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.add_child(h)
		h.add_child(UiIcons.rect("lock", Color(1, 1, 1, 0.5), 34))
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(v)
		p.gui_input.connect(func(e: InputEvent) -> void:
			if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
				UiKit.feedback(&"ui_locked")
				var tw := p.create_tween()
				for dx in [-8.0, 8.0, -5.0, 0.0]:
					tw.tween_property(p, "position:x", p.position.x + dx, 0.04))
		return [p, v]
	var pressed := normal.duplicate()
	pressed.bg_color = UiKit.BUTTON_PRESSED
	pressed.shadow_size = 3
	p.add_theme_stylebox_override("panel", normal)
	var h2 := HBoxContainer.new()
	h2.add_theme_constant_override("separation", 12)
	h2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(h2)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h2.add_child(v)
	h2.add_child(UiIcons.rect("next", Color(UiKit.ACCENT, 0.8), 30))
	var state := {"down": Vector2.INF}
	var release := func() -> void:
		p.add_theme_stylebox_override("panel", normal)
		var tw := p.create_tween()
		tw.tween_property(p, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	p.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed:
				state["down"] = e.position
				p.add_theme_stylebox_override("panel", pressed)
				p.pivot_offset = p.size * 0.5
				p.create_tween().tween_property(p, "scale", Vector2.ONE * 0.97, 0.06)
			else:
				release.call()
				var down: Vector2 = state["down"]
				state["down"] = Vector2.INF
				if down != Vector2.INF and down.distance_to(e.position) < 24.0 \
						and Rect2(Vector2.ZERO, p.size).has_point(e.position):
					UiKit.feedback(&"ui_confirm")
					on_pick.call()
		elif e is InputEventMouseMotion and state["down"] != Vector2.INF:
			if (state["down"] as Vector2).distance_to(e.position) >= 24.0:
				state["down"] = Vector2.INF
				release.call())
	return [p, v]


## Buttons side by side, sharing the width.
static func button_row(buttons: Array) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	for b in buttons:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(b)
	return h


static func centered(text: String, size: int, color := Color(0, 0, 0, 0)) -> Label:
	# Big centered lines are headings: use the display font.
	var l := UiKit.label(text, size, color, UiTokens.FONT_DISPLAY if size >= 40 else UiTokens.FONT_BODY)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


static func html_color(s: String, fallback := Color.WHITE) -> Color:
	return Color.from_string(s, fallback)


## Team color stripe (school colors) as a skewed broadcast bar.
static func team_stripe(t: Dictionary, width := 60.0, height := 8.0) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 4)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for col in t.get("colors", []):
		var r := Panel.new()
		var b := StyleBoxFlat.new()
		b.bg_color = Color.from_string(str(col), Color.GRAY)
		b.skew = Vector2(UiTokens.SKEW * 2.0, 0)
		r.add_theme_stylebox_override("panel", b)
		r.custom_minimum_size = Vector2(width, height)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(r)
	return h


# --- scoreboard ------------------------------------------------------------------------

## Broadcast scoreboard: two team blocks in their colors with a big number
## each, and a center box (clock / FINAL / VS). Returns
## {"root": Control, "us": Label, "them": Label, "mid": Label, "sub": Label}.
static func scoreboard(us: Dictionary, them: Dictionary, us_text: String, them_text: String,
		mid_text: String, sub_text := "", value_size := 64) -> Dictionary:
	var root := HBoxContainer.new()
	root.add_theme_constant_override("separation", 0)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var out := {"root": root}
	out["us"] = _score_block(root, us, us_text, value_size)
	var mid := PanelContainer.new()
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mb := UiKit._box(Color(0.02, 0.03, 0.06, 0.95), 0)
	mb.content_margin_left = 10
	mb.content_margin_right = 10
	mb.content_margin_top = 6
	mb.content_margin_bottom = 6
	mb.border_color = UiKit.ACCENT
	mb.border_width_bottom = 5
	mid.add_theme_stylebox_override("panel", mb)
	mid.custom_minimum_size.x = 150
	var mv := VBoxContainer.new()
	mv.alignment = BoxContainer.ALIGNMENT_CENTER
	mv.add_theme_constant_override("separation", 0)
	mv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mid.add_child(mv)
	var m := UiKit.line(mid_text, 32, UiKit.ACCENT, UiTokens.FONT_DISPLAY)
	m.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mv.add_child(m)
	var s := UiKit.line(sub_text, 20, UiKit.MUTED, UiTokens.FONT_CONDENSED)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.visible = sub_text != ""
	mv.add_child(s)
	root.add_child(mid)
	out["mid"] = m
	out["sub"] = s
	out["them"] = _score_block(root, them, them_text, value_size)
	return out


static func _score_block(parent: HBoxContainer, t: Dictionary, text: String, value_size := 64) -> Label:
	var cols: Array = t.get("colors", ["#444444", "#888888"])
	var c1 := html_color(str(cols[0]), Color.DIM_GRAY)
	var c2 := html_color(str(cols[1] if cols.size() > 1 else cols[0]), Color.GRAY)
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var b := UiKit._box(c1.darkened(0.25), 0)
	b.border_color = c2
	b.border_width_bottom = 5
	b.content_margin_top = 6
	b.content_margin_bottom = 4
	b.content_margin_left = 12
	b.content_margin_right = 12
	p.add_theme_stylebox_override("panel", b)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", -6)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(v)
	var name := UiKit.line(str(t.get("short", t.get("mascot", "???"))).to_upper(), 28, Color.WHITE,
		UiTokens.FONT_DISPLAY)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(name)
	var score := UiKit.line(text, value_size, Color.WHITE, UiTokens.FONT_BANNER)
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(score)
	parent.add_child(p)
	return score


## Big result banner ("WIN", "LOSS", "TIE"...) on a slanted color block that
## punches in. color: the block color.
static func result_banner(text: String, color: Color, size := 96) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := UiKit.line(text, size, UiKit.readable_on(color), UiTokens.FONT_BANNER)
	var b := UiKit._skewed(UiKit._box(color, UiTokens.RADIUS_BUTTON))
	b.content_margin_left = 44
	b.content_margin_right = 44
	b.content_margin_top = 0
	b.content_margin_bottom = 2
	b.shadow_color = Color(color, 0.45)
	b.shadow_size = 24
	l.add_theme_stylebox_override("normal", b)
	row.add_child(l)
	var tw := l.create_tween().set_ignore_time_scale(true)
	tw.tween_callback(func() -> void:
		l.pivot_offset = l.size * 0.5
		l.scale = Vector2(1.6, 0.2)
		l.rotation = -0.06)
	tw.set_parallel(true)
	tw.tween_property(l, "scale", Vector2.ONE, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.12)
	tw.tween_property(l, "rotation", 0.0, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.12)
	return row


# --- range and skill points ------------------------------------------------------------

## FG range, kickoff range and skill points in one strip (Hub, Skills, Stats).
## on_tap: makes the whole strip a tappable card (opens Skills); empty = display.
static func range_strip(c: CareerData, t: CareerTuning, on_tap := Callable(), show_sp := true) -> PanelContainer:
	var parts: Array = card(on_tap) if on_tap.is_valid() else UiKit.card(UiKit.ACCENT, 0)
	var p: PanelContainer = parts[0]
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parts[1] as VBoxContainer).add_child(h)
	var params := Progression.game_params(c, t)
	var ko := KickRange.kickoff_range(c, t)
	_range_tile(h, "FG RANGE", "%d yd" % floori(KickRange.fg_range(c, t) + 0.001), "range", UiKit.ACCENT)
	_range_tile(h, "KICKOFF", "%d yd" % floori(ko + 0.001), "power", UiKit.TEXT,
		"touchback" if KickRange.touchback_possible(ko, params, t) else "")
	if show_sp:
		_range_tile(h, "SKILL PTS", str(c.skill_points), "skill",
			UiKit.GOOD if c.skill_points > 0 else UiKit.MUTED, "SKILLS  ›" if on_tap.is_valid() else "")
	return p


static func _range_tile(parent: HBoxContainer, caption: String, value: String, icon: String, color: Color,
		note := "") -> void:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", -4)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(v)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 6)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(UiIcons.rect(icon, UiKit.MUTED, 20))
	var cap := UiKit.label(caption, 20, UiKit.MUTED, UiTokens.FONT_CONDENSED)
	cap.autowrap_mode = TextServer.AUTOWRAP_OFF
	top.add_child(cap)
	v.add_child(top)
	var val := UiKit.label(value, 44, color, UiTokens.FONT_DISPLAY)
	val.autowrap_mode = TextServer.AUTOWRAP_OFF
	v.add_child(val)
	if note != "":
		var n := UiKit.label(note, 18, UiKit.MUTED, UiTokens.FONT_CONDENSED)
		n.autowrap_mode = TextServer.AUTOWRAP_OFF
		v.add_child(n)


## "+6 skill points (12 to spend)" with each source on a line, for Results.
static func sp_lines(c: CareerData) -> Array:
	var out: Array = []
	var total := 0
	for e in c.sp_week:
		total += int(e.get("sp", 0))
	if total > 0:
		out.append("+%d skill points  (%d to spend)" % [total, c.skill_points])
		var parts := PackedStringArray()
		for e in c.sp_week:
			parts.append("%s +%d" % [e.get("text", ""), int(e.get("sp", 0))])
		out.append(", ".join(parts))
	elif c.skill_points > 0:
		out.append("%d skill points to spend" % c.skill_points)
	return out
