extends Control
## Dev-only Step 1 prototype: renders the Main Menu and Career Hub in three
## candidate style directions. godot --path . res://tests_tmp/style_preview.tscn -- style=A screen=hub out=x.png

const FONT_DIR := "/tmp/fonts/"

var S: Dictionary  # style tokens
var style_id := "A"
var light := false


# --- tokens -------------------------------------------------------------------------

func tokens(id: String) -> Dictionary:
	match id:
		"A":  # Night game stadium
			return {
				"bg_top": Color("#0b1530"), "bg_bottom": Color("#03060d"),
				"panel": Color(0.07, 0.11, 0.22, 0.88), "panel_border": Color("#2a3d6b"),
				"panel_hi": Color(1, 1, 1, 0.06),
				"text": Color("#f4f7ff"), "muted": Color("#8e9bbd"),
				"accent": Color("#ffb81c"), "accent_text": Color("#1a1205"),
				"accent2": Color("#ffffff"),
				"good": Color("#3ee08f"), "bad": Color("#ff5a4e"),
				"life": Color("#35d6c4"), "football": Color("#ffb81c"), "personality": Color("#9b7bff"),
				"radius": 18, "btn_radius": 16, "skew": 0.0,
				"display": ["oswald_Oswald[wght].ttf", 700], "body": ["barlow_Barlow-SemiBold.ttf", 0],
				"upper": true, "shadow": Color(0, 0, 0, 0.55), "shadow_size": 18, "shadow_off": Vector2(0, 8),
				"glow": true,
			}
		"B":  # Broadcast
			return {
				"bg_top": Color("#14161c"), "bg_bottom": Color("#07080b"),
				"panel": Color("#1c1f27"), "panel_border": Color(0, 0, 0, 0),
				"panel_hi": Color(1, 1, 1, 0.0),
				"text": Color("#ffffff"), "muted": Color("#a3a9b8"),
				"accent": Color("#e10600"), "accent_text": Color("#ffffff"),
				"accent2": Color("#f2b632"),
				"good": Color("#22d36b"), "bad": Color("#ff3b30"),
				"life": Color("#00c2ff"), "football": Color("#f2b632"), "personality": Color("#ff3d8b"),
				"radius": 2, "btn_radius": 2, "skew": 0.22,
				"display": ["anton_Anton-Regular.ttf", 0], "body": ["barlowcondensed_BarlowCondensed-SemiBold.ttf", 0],
				"upper": true, "shadow": Color(0, 0, 0, 0.9), "shadow_size": 0, "shadow_off": Vector2(6, 6),
				"glow": false,
			}
		_:  # C: clean modern app
			if light:
				return {
					"bg_top": Color("#f4f5f8"), "bg_bottom": Color("#e8ebf1"),
					"panel": Color("#ffffff"), "panel_border": Color(0, 0, 0, 0),
					"panel_hi": Color(0, 0, 0, 0),
					"text": Color("#11141b"), "muted": Color("#6b7385"),
					"accent": Color("#ff5a1f"), "accent_text": Color("#ffffff"), "accent2": Color("#11141b"),
					"good": Color("#14b86a"), "bad": Color("#e5484d"),
					"life": Color("#14b8a6"), "football": Color("#ff5a1f"), "personality": Color("#6e56cf"),
					"radius": 28, "btn_radius": 44, "skew": 0.0,
					"display": ["outfit_Outfit[wght].ttf", 800], "body": ["manrope_Manrope[wght].ttf", 600],
					"upper": false, "shadow": Color(0.1, 0.12, 0.2, 0.10), "shadow_size": 24, "shadow_off": Vector2(0, 8),
					"glow": false, "secondary": Color("#eceef3"),
				}
			return {
				"bg_top": Color("#151821"), "bg_bottom": Color("#0c0e13"),
				"panel": Color("#1d212c"), "panel_border": Color(1, 1, 1, 0.05),
				"panel_hi": Color(0, 0, 0, 0),
				"text": Color("#f3f5f9"), "muted": Color("#8a93a6"),
				"accent": Color("#ff5a1f"), "accent_text": Color("#ffffff"), "accent2": Color("#ffffff"),
				"good": Color("#2fd286"), "bad": Color("#ff5f63"),
				"life": Color("#2dd4bf"), "football": Color("#ff7a45"), "personality": Color("#8b7cf6"),
				"radius": 28, "btn_radius": 44, "skew": 0.0,
				"display": ["outfit_Outfit[wght].ttf", 800], "body": ["manrope_Manrope[wght].ttf", 600],
				"upper": false, "shadow": Color(0, 0, 0, 0.35), "shadow_size": 24, "shadow_off": Vector2(0, 10),
				"glow": false, "secondary": Color("#2a2f3c"),
			}


var _fonts := {}

func font(kind: String) -> Font:
	if _fonts.has(kind):
		return _fonts[kind]
	var spec: Array = S[kind]
	var f := FontFile.new()
	f.load_dynamic_font(FONT_DIR + str(spec[0]))
	var out: Font = f
	if int(spec[1]) > 0:
		var v := FontVariation.new()
		v.base_font = f
		v.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): int(spec[1])}
		out = v
	_fonts[kind] = out
	return out


# --- helpers ------------------------------------------------------------------------

func up(t: String) -> String:
	return t.to_upper() if S["upper"] else t


func box(color: Color, radius: int, border := Color(0, 0, 0, 0), bw := 2, shadow := false) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = color
	b.set_corner_radius_all(radius)
	b.content_margin_left = 24
	b.content_margin_right = 24
	b.content_margin_top = 14
	b.content_margin_bottom = 14
	b.anti_aliasing = true
	if border.a > 0.0:
		b.border_color = border
		b.set_border_width_all(bw)
	if shadow:
		b.shadow_color = S["shadow"]
		b.shadow_size = S["shadow_size"]
		b.shadow_offset = S["shadow_off"]
	return b


func lbl(text: String, size: int, color: Color, display := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font("display" if display else "body"))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func panel(child: Control, color: Color = Color(0, 0, 0, 0), accent_edge := Color(0, 0, 0, 0)) -> PanelContainer:
	var p := PanelContainer.new()
	var c: Color = S["panel"] if color.a == 0.0 else color
	var b := box(c, S["radius"], S["panel_border"], 2, true)
	if style_id == "B":
		b.skew = Vector2.ZERO
		if accent_edge.a > 0:
			b.border_color = accent_edge
			b.border_width_left = 8
			b.border_width_top = 0
			b.border_width_right = 0
			b.border_width_bottom = 0
	elif style_id == "A" and accent_edge.a > 0:
		b.border_color = accent_edge.darkened(0.2)
		b.border_width_top = 3
	p.add_theme_stylebox_override("panel", b)
	p.add_child(child)
	return p


## kind: primary / secondary
func btn(text: String, kind: String, icon := "", height := 96) -> PanelContainer:
	var bg: Color
	var fg: Color
	var border := Color(0, 0, 0, 0)
	match kind:
		"primary":
			bg = S["accent"]
			fg = S["accent_text"]
		_:
			bg = S["panel"] if style_id != "C" else S["secondary"]
			fg = S["text"]
			if style_id == "A":
				border = Color(1, 1, 1, 0.18)
	var b := box(bg, S["btn_radius"], border, 2, true)
	if style_id == "A" and kind == "primary":
		b.shadow_color = Color(S["accent"], 0.45)
		b.shadow_size = 26
		b.shadow_offset = Vector2.ZERO
		b.border_color = Color("#ffe08a")
		b.set_border_width_all(2)
		b.border_width_bottom = 5
		b.border_color = Color("#ffd35c")
	if style_id == "B":
		b.skew = Vector2(S["skew"], 0)
		if kind != "primary":
			b.bg_color = Color("#262a35")
			b.border_color = Color("#ffffff")
			b.border_width_left = 0
			b.border_width_bottom = 4
			b.border_color = S["accent"]
	if style_id == "C" and kind != "primary":
		b.shadow_size = 0
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", b)
	p.custom_minimum_size.y = height
	var h := HBoxContainer.new()
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_theme_constant_override("separation", 18)
	p.add_child(h)
	if icon != "":
		var ic := Icon.new(icon, fg if kind == "primary" else S["accent"], 40)
		h.add_child(ic)
	var l := lbl(up(text), 38 if style_id != "C" else 34, fg, style_id != "C")
	if style_id == "C":
		l.add_theme_font_override("font", font("display"))
	h.add_child(l)
	if style_id == "B" or (style_id == "A" and kind != "primary"):
		h.alignment = BoxContainer.ALIGNMENT_BEGIN
		var sp := Control.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(sp)
		h.add_child(lbl(">" if style_id == "B" else "›", 40, Color(fg, 0.5) if kind != "primary" else fg, true))
	return p


## Simple vector icons drawn in code.
class Icon:
	extends Control
	var id: String
	var col: Color
	func _init(i: String, c: Color, s: int) -> void:
		id = i
		col = c
		custom_minimum_size = Vector2(s, s)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
	func _draw() -> void:
		var s := size.x
		var c := size * 0.5
		var w := maxf(2.5, s * 0.09)
		match id:
			"health":  # heart
				var r := s * 0.22
				draw_circle(c + Vector2(-r * 0.95, -r * 0.4), r, col)
				draw_circle(c + Vector2(r * 0.95, -r * 0.4), r, col)
				draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 0.43, -r * 0.1),
					c + Vector2(s * 0.43, -r * 0.1), c + Vector2(0, s * 0.4)]), col)
			"energy":  # bolt
				draw_colored_polygon(PackedVector2Array([Vector2(s * 0.58, s * 0.05), Vector2(s * 0.2, s * 0.56),
					Vector2(s * 0.47, s * 0.56), Vector2(s * 0.38, s * 0.95), Vector2(s * 0.8, s * 0.42),
					Vector2(s * 0.52, s * 0.42)]), col)
			"fun":  # smile
				draw_arc(c, s * 0.42, 0, TAU, 32, col, w, true)
				draw_circle(c + Vector2(-s * 0.15, -s * 0.1), s * 0.06, col)
				draw_circle(c + Vector2(s * 0.15, -s * 0.1), s * 0.06, col)
				draw_arc(c + Vector2(0, s * 0.02), s * 0.22, 0.3, PI - 0.3, 16, col, w, true)
			"social":  # two people
				draw_circle(Vector2(s * 0.35, s * 0.32), s * 0.14, col)
				draw_circle(Vector2(s * 0.68, s * 0.36), s * 0.12, Color(col, 0.7))
				draw_arc(Vector2(s * 0.35, s * 0.95), s * 0.3, PI, TAU, 16, col, s * 0.16)
				draw_arc(Vector2(s * 0.7, s * 0.95), s * 0.24, PI, TAU, 16, Color(col, 0.7), s * 0.12)
			"power":  # ball w/ speed lines
				draw_set_transform(c + Vector2(s * 0.1, 0), -0.6, Vector2(1.0, 0.62))
				draw_circle(Vector2.ZERO, s * 0.34, col)
				draw_set_transform(Vector2.ZERO)
				for i in 3:
					draw_line(Vector2(s * 0.02, s * (0.3 + i * 0.2)), Vector2(s * 0.28, s * (0.3 + i * 0.2)), col, w, true)
			"accuracy":  # target
				draw_arc(c, s * 0.42, 0, TAU, 32, col, w, true)
				draw_arc(c, s * 0.25, 0, TAU, 24, col, w, true)
				draw_circle(c, s * 0.09, col)
			"resilience":  # shield
				draw_colored_polygon(PackedVector2Array([Vector2(s * 0.5, s * 0.05), Vector2(s * 0.88, s * 0.2),
					Vector2(s * 0.8, s * 0.62), Vector2(s * 0.5, s * 0.95), Vector2(s * 0.2, s * 0.62),
					Vector2(s * 0.12, s * 0.2)]), col)
			"toughness":  # dumbbell
				draw_line(Vector2(s * 0.2, c.y), Vector2(s * 0.8, c.y), col, w * 1.2)
				draw_rect(Rect2(s * 0.08, s * 0.28, s * 0.16, s * 0.44), col)
				draw_rect(Rect2(s * 0.76, s * 0.28, s * 0.16, s * 0.44), col)
			"charisma":  # star
				var pts := PackedVector2Array()
				for i in 10:
					var a := -PI / 2 + i * PI / 5
					var r := s * (0.46 if i % 2 == 0 else 0.2)
					pts.append(c + Vector2(cos(a), sin(a)) * r)
				draw_colored_polygon(pts, col)
			"ambition":  # flag
				draw_line(Vector2(s * 0.22, s * 0.08), Vector2(s * 0.22, s * 0.95), col, w)
				draw_colored_polygon(PackedVector2Array([Vector2(s * 0.24, s * 0.1), Vector2(s * 0.85, s * 0.28),
					Vector2(s * 0.24, s * 0.5)]), col)
			"leadership":  # crown
				draw_colored_polygon(PackedVector2Array([Vector2(s * 0.1, s * 0.78), Vector2(s * 0.1, s * 0.28),
					Vector2(s * 0.32, s * 0.5), Vector2(s * 0.5, s * 0.18), Vector2(s * 0.68, s * 0.5),
					Vector2(s * 0.9, s * 0.28), Vector2(s * 0.9, s * 0.78)]), col)
			"intelligence":  # bulb
				draw_circle(c + Vector2(0, -s * 0.1), s * 0.3, col)
				draw_rect(Rect2(s * 0.36, s * 0.62, s * 0.28, s * 0.22), col)
			"career":  # trophy
				draw_colored_polygon(PackedVector2Array([Vector2(s * 0.2, s * 0.1), Vector2(s * 0.8, s * 0.1),
					Vector2(s * 0.72, s * 0.45), Vector2(s * 0.5, s * 0.6), Vector2(s * 0.28, s * 0.45)]), col)
				draw_arc(Vector2(s * 0.2, s * 0.26), s * 0.12, PI * 0.5, PI * 1.5, 10, col, w * 0.8)
				draw_arc(Vector2(s * 0.8, s * 0.26), s * 0.12, -PI * 0.5, PI * 0.5, 10, col, w * 0.8)
				draw_rect(Rect2(s * 0.44, s * 0.58, s * 0.12, s * 0.2), col)
				draw_rect(Rect2(s * 0.28, s * 0.78, s * 0.44, s * 0.12), col)
			"challenge":  # stopwatch
				draw_arc(c + Vector2(0, s * 0.06), s * 0.38, 0, TAU, 32, col, w, true)
				draw_line(c + Vector2(0, s * 0.06), c + Vector2(s * 0.14, -s * 0.12), col, w, true)
				draw_rect(Rect2(s * 0.4, 0, s * 0.2, s * 0.1), col)
			"practice":  # goalpost
				draw_line(Vector2(s * 0.5, s * 0.95), Vector2(s * 0.5, s * 0.55), col, w)
				draw_line(Vector2(s * 0.15, s * 0.55), Vector2(s * 0.85, s * 0.55), col, w)
				draw_line(Vector2(s * 0.15, s * 0.55), Vector2(s * 0.15, s * 0.05), col, w)
				draw_line(Vector2(s * 0.85, s * 0.55), Vector2(s * 0.85, s * 0.05), col, w)
			"stats":  # bars
				for i in 3:
					var hgt := s * (0.35 + i * 0.25)
					draw_rect(Rect2(s * (0.1 + i * 0.3), s * 0.92 - hgt, s * 0.2, hgt), col)
			"achievements":  # medal
				draw_colored_polygon(PackedVector2Array([Vector2(s * 0.25, 0), Vector2(s * 0.45, 0),
					Vector2(s * 0.55, s * 0.4), Vector2(s * 0.35, s * 0.4)]), Color(col, 0.6))
				draw_colored_polygon(PackedVector2Array([Vector2(s * 0.55, 0), Vector2(s * 0.75, 0),
					Vector2(s * 0.65, s * 0.4), Vector2(s * 0.45, s * 0.4)]), Color(col, 0.6))
				draw_circle(Vector2(s * 0.5, s * 0.66), s * 0.28, col)
			"settings":  # gear
				for i in 8:
					var a := i * TAU / 8
					draw_line(c + Vector2(cos(a), sin(a)) * s * 0.25, c + Vector2(cos(a), sin(a)) * s * 0.46, col, s * 0.16)
				draw_circle(c, s * 0.3, col)
				draw_circle(c, s * 0.12, Color(0, 0, 0, 0.7))
			"home":
				draw_colored_polygon(PackedVector2Array([Vector2(s * 0.5, s * 0.08), Vector2(s * 0.92, s * 0.48),
					Vector2(s * 0.8, s * 0.48), Vector2(s * 0.8, s * 0.9), Vector2(s * 0.2, s * 0.9),
					Vector2(s * 0.2, s * 0.48), Vector2(s * 0.08, s * 0.48)]), col)
			_:
				draw_circle(c, s * 0.4, col)


## Static backdrop drawn once (no per-frame cost).
class Backdrop:
	extends Control
	var S: Dictionary
	var sid: String
	var team := Color.TRANSPARENT
	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(w, 0), Vector2(w, h), Vector2(0, h)]),
			PackedColorArray([S["bg_top"], S["bg_top"], S["bg_bottom"], S["bg_bottom"]]))
		match sid:
			"A":
				# Floodlight glows top corners + beams.
				for corner in [Vector2(-40, -60), Vector2(w + 40, -60)]:
					for i in 14:
						var r := 520.0 - i * 34.0
						draw_circle(corner, r, Color(0.75, 0.82, 1.0, 0.018))
					draw_circle(corner, 60, Color(1, 1, 1, 0.5))
				for corner in [Vector2(-40, -60), Vector2(w + 40, -60)]:
					var dir := 1.0 if corner.x < 0 else -1.0
					draw_colored_polygon(PackedVector2Array([corner, corner + Vector2(dir * 520, 900),
						corner + Vector2(dir * 300, 1000)]), Color(0.8, 0.86, 1.0, 0.035))
				# Field + yard lines in perspective at the bottom.
				var top_y := h * 0.78
				draw_colored_polygon(PackedVector2Array([Vector2(0, top_y), Vector2(w, top_y), Vector2(w, h), Vector2(0, h)]),
					Color(0.05, 0.16, 0.1, 0.55))
				for i in 9:
					var t := float(i) / 8.0
					var x_top := lerpf(w * 0.3, w * 0.7, t)
					var x_bot := lerpf(-w * 0.4, w * 1.4, t)
					draw_line(Vector2(x_top, top_y), Vector2(x_bot, h), Color(1, 1, 1, 0.08), 2.0, true)
				draw_line(Vector2(0, top_y), Vector2(w, top_y), Color(1, 1, 1, 0.1), 2.0)
			"B":
				# Diagonal pinstripes + a red slash.
				var i := -h
				while i < w:
					draw_line(Vector2(i, h), Vector2(i + h * 0.6, 0), Color(1, 1, 1, 0.025), 10.0)
					i += 36
				draw_colored_polygon(PackedVector2Array([Vector2(w * 0.55, 0), Vector2(w, 0), Vector2(w, h * 0.3),
					Vector2(w * 0.85, h * 0.3)]), Color(S["accent"], 0.10))
				if team.a > 0:
					draw_colored_polygon(PackedVector2Array([Vector2(0, h * 0.62), Vector2(w * 0.2, h * 0.5),
						Vector2(w * 0.2, h * 0.55), Vector2(0, h * 0.67)]), Color(team, 0.25))
			"C":
				# Soft accent blob, top right.
				for k in 16:
					draw_circle(Vector2(w * 0.95, h * 0.02), 460.0 - k * 26.0, Color(S["accent"], 0.012 if not S["text"].v < 0.5 else 0.01))
				if team.a > 0:
					for k in 14:
						draw_circle(Vector2(w * 0.0, h * 0.38), 380.0 - k * 24.0, Color(team, 0.018))


# --- frame --------------------------------------------------------------------------

func frame() -> VBoxContainer:
	var bd := Backdrop.new()
	bd.S = S
	bd.sid = style_id
	bd.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bd)
	var m := MarginContainer.new()
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, 32)
	add_child(m)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	m.add_child(col)
	return col


func spacer() -> Control:
	var c := Control.new()
	c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return c


# --- main menu ----------------------------------------------------------------------

func build_main() -> void:
	var col := frame()
	col.add_child(spacer())
	match style_id:
		"A":
			var sub := lbl("FRIDAY NIGHT", 30, S["accent"], true)
			sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			sub.add_theme_constant_override("line_spacing", 0)
			col.add_child(sub)
			var logo := lbl("KICKER", 150, S["text"], true)
			logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			logo.add_theme_color_override("font_shadow_color", Color(S["accent"], 0.55))
			logo.add_theme_constant_override("shadow_outline_size", 22)
			logo.add_theme_constant_override("shadow_offset_x", 0)
			logo.add_theme_constant_override("shadow_offset_y", 0)
			col.add_child(logo)
			var tag := lbl("Field goal unit. Ice in your veins.", 28, S["muted"])
			tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			col.add_child(tag)
		"B":
			var hold := Control.new()
			hold.custom_minimum_size.y = 250
			col.add_child(hold)
			var bar := ColorRect.new()
			bar.color = S["accent"]
			bar.position = Vector2(-32, 40)
			bar.size = Vector2(520, 150)
			hold.add_child(bar)
			var logo := lbl("KICKER", 150, Color.WHITE, true)
			logo.position = Vector2(10, 6)
			logo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
			logo.add_theme_constant_override("shadow_offset_x", 8)
			logo.add_theme_constant_override("shadow_offset_y", 8)
			hold.add_child(logo)
			var strip := ColorRect.new()
			strip.color = Color.WHITE
			strip.position = Vector2(-32, 196)
			strip.size = Vector2(600, 46)
			hold.add_child(strip)
			var tag := lbl("FIELD GOAL UNIT  //  ICE IN YOUR VEINS", 30, Color("#14161c"))
			tag.position = Vector2(4, 198)
			hold.add_child(tag)
		"C":
			var row := HBoxContainer.new()
			row.alignment = BoxContainer.ALIGNMENT_CENTER
			row.add_theme_constant_override("separation", 16)
			var dot := Icon.new("practice", S["accent"], 84)
			row.add_child(dot)
			var logo := lbl("kicker", 120, S["text"], true)
			row.add_child(logo)
			col.add_child(row)
			var tag := lbl("Field goal unit. Ice in your veins.", 30, S["muted"])
			tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			col.add_child(tag)
	col.add_child(spacer())
	var items := [["Career Mode", "career"], ["Challenge Mode", "challenge"], ["Practice", "practice"],
		["My Stats", "stats"], ["Achievements", "achievements"], ["Settings", "settings"]]
	if style_id == "C":
		col.add_child(btn("Career Mode", "primary", "career", 112))
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 16)
		grid.add_theme_constant_override("v_separation", 16)
		col.add_child(grid)
		for it in items.slice(1, 5):
			var v := VBoxContainer.new()
			v.add_theme_constant_override("separation", 10)
			var ic_bg := PanelContainer.new()
			var icb := box(Color(S["accent"], 0.14), 18)
			icb.set_content_margin_all(12)
			ic_bg.add_theme_stylebox_override("panel", icb)
			ic_bg.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			ic_bg.add_child(Icon.new(it[1], S["accent"], 36))
			v.add_child(ic_bg)
			v.add_child(lbl(it[0], 30, S["text"], true))
			var p := panel(v)
			p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			p.custom_minimum_size.y = 150
			if it[0] == "Settings":
				pass
			grid.add_child(p)
		col.add_child(btn("Settings", "secondary", "settings", 92))
		var f := panel(_footer_row())
		col.add_child(f)
	else:
		col.add_child(btn("Career Mode", "primary", "career", 108))
		for it in items.slice(1):
			col.add_child(btn(it[0], "secondary", it[1], 92))
		if style_id == "B":
			col.add_child(_ticker())
		else:
			var footer := lbl("ALL-TIME  128 / 162  (79%)     BEST RUN  14", 24, S["muted"])
			footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			col.add_child(footer)
	col.add_child(spacer())


func _footer_row() -> HBoxContainer:
	var h := HBoxContainer.new()
	for pair in [["All-time", "128/162"], ["Accuracy", "79%"], ["Best run", "14"]]:
		var v := VBoxContainer.new()
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_theme_constant_override("separation", 0)
		var a := lbl(pair[1], 36, S["text"], true)
		a.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var b := lbl(pair[0], 22, S["muted"])
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(a)
		v.add_child(b)
		h.add_child(v)
	return h


func _ticker() -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	var tag := PanelContainer.new()
	var tb := box(S["accent"], 0)
	tb.content_margin_top = 6
	tb.content_margin_bottom = 6
	tb.content_margin_left = 14
	tb.content_margin_right = 14
	tag.add_theme_stylebox_override("panel", tb)
	tag.add_child(lbl("STATS", 28, Color.WHITE, true))
	h.add_child(tag)
	var rest := PanelContainer.new()
	var rb := box(Color.WHITE, 0)
	rb.content_margin_top = 6
	rb.content_margin_bottom = 6
	rb.content_margin_left = 16
	rest.add_theme_stylebox_override("panel", rb)
	rest.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rest.clip_contents = true
	rest.add_child(lbl("ALL-TIME 128/162   •   79%   •   BEST RUN 14   •   LONG 52 YD", 28, Color("#14161c")))
	h.add_child(rest)
	return h


# --- hub ----------------------------------------------------------------------------

const TEAM := [Color("#1f3a8a"), Color("#f2b632")]

func build_hub() -> void:
	var col := frame()
	(get_child(0) as Backdrop).team = TEAM[0]
	col.add_child(_hub_header())
	col.add_child(_next_game())
	# Stats
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	col.add_child(grid)
	var vals := {"health": 82, "energy": 84, "fun": 84, "social": 28, "power": 44, "accuracy": 44,
		"resilience": 30, "toughness": 30, "charisma": 49, "ambition": 49, "leadership": 35, "intelligence": 35}
	var preview := {"energy": -8, "accuracy": 3}
	col.add_theme_constant_override("separation", 14 if style_id != "B" else 10)
	for g in [["Life", "life", ["health", "energy", "fun", "social"]],
			["Football", "football", ["power", "accuracy", "resilience", "toughness"]],
			["Personality", "personality", ["charisma", "ambition", "leadership", "intelligence"]]]:
		grid.add_child(_group(g[0], S[g[1]], g[2], vals, preview))
	grid.add_child(_traits())
	col.add_child(_recent())
	col.add_child(spacer())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var m := btn("Menu", "secondary", "home", 100)
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var p := btn("Play Week", "primary", "", 100)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.size_flags_stretch_ratio = 2.0
	row.add_child(m)
	row.add_child(p)
	col.add_child(row)


func _hub_header() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	var top := lbl(up("Season 1  ·  Freshman  ·  Week 5 of 11"), 22, S["muted"] if style_id != "B" else Color.WHITE)
	var name_l := lbl(up("Jordan Reyes"), 56 if style_id == "A" else (46 if style_id == "B" else 50), S["text"], true)
	var team_l := lbl(up("Ridgeline Falcons"), 28, S["text"])
	var rec := lbl("3-1", 64, S["text"], true)
	match style_id:
		"A":
			var h := HBoxContainer.new()
			var left := VBoxContainer.new()
			left.add_theme_constant_override("separation", -4)
			left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			top.add_theme_color_override("font_color", S["accent"])
			left.add_child(top)
			left.add_child(name_l)
			var tr := HBoxContainer.new()
			tr.add_theme_constant_override("separation", 10)
			var sw := ColorRect.new()
			sw.color = TEAM[0]
			sw.custom_minimum_size = Vector2(18, 18)
			sw.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var sw2 := ColorRect.new()
			sw2.color = TEAM[1]
			sw2.custom_minimum_size = Vector2(18, 18)
			sw2.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			tr.add_child(sw)
			tr.add_child(sw2)
			tr.add_child(team_l)
			left.add_child(tr)
			h.add_child(left)
			var rv := VBoxContainer.new()
			rv.add_theme_constant_override("separation", -8)
			var n := lbl("#7", 30, S["accent"], true)
			n.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			rv.add_child(n)
			rec.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			rec.add_theme_color_override("font_shadow_color", Color(S["accent"], 0.4))
			rec.add_theme_constant_override("shadow_outline_size", 14)
			rec.add_theme_constant_override("shadow_offset_x", 0)
			rec.add_theme_constant_override("shadow_offset_y", 0)
			rv.add_child(rec)
			h.add_child(rv)
			return panel(h, Color(TEAM[0].darkened(0.55), 0.92), TEAM[1])
		"B":
			var out := VBoxContainer.new()
			out.add_theme_constant_override("separation", 0)
			var bar := PanelContainer.new()
			var bb := box(TEAM[0], 0)
			bb.content_margin_top = 10
			bb.content_margin_bottom = 6
			bb.border_color = TEAM[1]
			bb.border_width_bottom = 6
			bar.add_theme_stylebox_override("panel", bb)
			var h := HBoxContainer.new()
			bar.add_child(h)
			var left := VBoxContainer.new()
			left.add_theme_constant_override("separation", -6)
			left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			left.add_child(name_l)
			left.add_child(team_l)
			h.add_child(left)
			var num := lbl("7", 76, Color(TEAM[1], 0.95), true)
			h.add_child(num)
			out.add_child(bar)
			var strip := PanelContainer.new()
			var sb := box(Color.WHITE, 0)
			sb.content_margin_top = 4
			sb.content_margin_bottom = 4
			strip.add_theme_stylebox_override("panel", sb)
			var sh := HBoxContainer.new()
			strip.add_child(sh)
			var wk := lbl("SEASON 1  •  FRESHMAN  •  WEEK 5/11", 26, Color("#14161c"))
			wk.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			sh.add_child(wk)
			var r2 := PanelContainer.new()
			var r2b := box(S["accent"], 0)
			r2b.content_margin_top = 0
			r2b.content_margin_bottom = 0
			r2.add_theme_stylebox_override("panel", r2b)
			r2.add_child(lbl("3-1", 30, Color.WHITE, true))
			sh.add_child(r2)
			out.add_child(strip)
			return out
		_:
			var p := PanelContainer.new()
			var b := box(TEAM[0], S["radius"], Color(0, 0, 0, 0), 0, true)
			b.content_margin_top = 22
			b.content_margin_bottom = 22
			p.add_theme_stylebox_override("panel", b)
			var h := HBoxContainer.new()
			h.add_theme_constant_override("separation", 18)
			p.add_child(h)
			var av := PanelContainer.new()
			var ab := box(TEAM[1], 60)
			ab.set_content_margin_all(0)
			av.add_theme_stylebox_override("panel", ab)
			av.custom_minimum_size = Vector2(96, 96)
			av.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var nl := lbl("7", 48, TEAM[0], true)
			nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			nl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			av.add_child(nl)
			h.add_child(av)
			var left := VBoxContainer.new()
			left.add_theme_constant_override("separation", 0)
			left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			top.text = "Freshman · Week 5 of 11"
			top.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
			name_l.add_theme_color_override("font_color", Color.WHITE)
			team_l.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
			team_l.add_theme_font_size_override("font_size", 26)
			left.add_child(top)
			left.add_child(name_l)
			left.add_child(team_l)
			h.add_child(left)
			var rv := VBoxContainer.new()
			rv.add_theme_constant_override("separation", -6)
			rec.add_theme_color_override("font_color", Color.WHITE)
			rec.add_theme_font_size_override("font_size", 52)
			rec.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			rv.add_child(rec)
			var rl := lbl("Record", 22, Color(1, 1, 1, 0.7))
			rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			rv.add_child(rl)
			h.add_child(rv)
			return p


func _chip(text: String, color: Color, filled := false) -> PanelContainer:
	var p := PanelContainer.new()
	var b := box(color if filled else Color(color, 0.18), 30 if style_id == "C" else (2 if style_id == "B" else 12))
	b.content_margin_top = 4
	b.content_margin_bottom = 4
	b.content_margin_left = 14
	b.content_margin_right = 14
	if style_id == "B":
		b.skew = Vector2(S["skew"], 0)
	p.add_theme_stylebox_override("panel", b)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.add_child(lbl(text, 22, Color.WHITE if filled else color.lightened(0.25) if S["text"].v > 0.5 else color.darkened(0.2)))
	return p


func _next_game() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	h.add_child(lbl(up("This week"), 22, S["muted"]))
	h.add_child(_chip(up("Home"), S["good"]))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(sp)
	h.add_child(_chip(up("Recruiting 41"), S["accent"] if style_id != "B" else S["accent2"]))
	v.add_child(h)
	var vs := HBoxContainer.new()
	vs.add_theme_constant_override("separation", 12)
	vs.add_child(lbl("vs", 30, S["muted"], true))
	vs.add_child(lbl(up("Lakeview Lakers"), 40, S["text"], true))
	v.add_child(vs)
	var sub := lbl("Average opponent  ·  GPA 2.90  ·  Walk-on interest", 24, S["muted"])
	v.add_child(sub)
	return panel(v, Color(0, 0, 0, 0), S["accent"])


func _group(title: String, gcol: Color, keys: Array, vals: Dictionary, preview: Dictionary) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	var th := HBoxContainer.new()
	th.add_theme_constant_override("separation", 8)
	var dot := ColorRect.new()
	dot.color = gcol
	dot.custom_minimum_size = Vector2(6 if style_id != "C" else 10, 22)
	if style_id != "B":
		th.add_child(dot)
	th.add_child(lbl(up(title), 22, gcol if style_id != "C" else S["muted"], style_id == "B"))
	v.add_child(th)
	for k in keys:
		v.add_child(_bar(k, vals[k], gcol, float(preview.get(k, 0))))
	var p := panel(v)
	if style_id == "B":
		var b: StyleBoxFlat = p.get_theme_stylebox("panel").duplicate()
		b.border_color = gcol
		b.border_width_top = 5
		p.add_theme_stylebox_override("panel", b)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return p


func _bar(key: String, value: float, gcol: Color, delta: float) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	h.add_child(Icon.new(key, gcol, 22))
	var names := {"power": "Power", "accuracy": "Accuracy"}
	var n := lbl(str(names.get(key, key.capitalize())), 22, S["text"])
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(n)
	if delta != 0:
		h.add_child(lbl(("+%d" if delta > 0 else "%d") % int(delta), 20, S["good"] if delta > 0 else S["bad"]))
	var num := lbl(str(int(value)), 24, S["text"], true)
	h.add_child(num)
	v.add_child(h)
	var bar := Bar.new()
	bar.value = value / 100.0
	bar.delta = delta / 100.0
	bar.col = gcol
	bar.track = Color(S["text"], 0.1)
	bar.radius = 0 if style_id == "B" else 5
	bar.good = S["good"]
	bar.bad = S["bad"]
	bar.glow = S["glow"]
	bar.custom_minimum_size.y = 10 if style_id != "B" else 8
	v.add_child(bar)
	return v


class Bar:
	extends Control
	var value := 0.5
	var delta := 0.0
	var col := Color.WHITE
	var track := Color(1, 1, 1, 0.1)
	var radius := 5
	var good := Color.GREEN
	var bad := Color.RED
	var glow := false
	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		_rr(r, track)
		var base := value if delta >= 0 else value + delta
		var fw := size.x * clampf(base, 0, 1)
		if glow:
			_rr(Rect2(-2, -2, fw + 4, size.y + 4), Color(col, 0.25))
		var fill := StyleBoxFlat.new()
		fill.set_corner_radius_all(radius)
		fill.bg_color = col
		fill.anti_aliasing = true
		draw_style_box(fill, Rect2(0, 0, fw, size.y))
		if delta != 0:
			var x0 := fw
			var x1 := size.x * clampf(value + delta, 0, 1) if delta > 0 else size.x * value
			var s := StyleBoxFlat.new()
			s.bg_color = Color(good if delta > 0 else bad, 0.85)
			s.set_corner_radius_all(radius)
			draw_style_box(s, Rect2(x0, 0, x1 - x0, size.y))
	func _rr(r: Rect2, c: Color) -> void:
		var s := StyleBoxFlat.new()
		s.bg_color = c
		s.set_corner_radius_all(radius + 2)
		s.anti_aliasing = true
		draw_style_box(s, r)


func _traits() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	var th := HBoxContainer.new()
	th.add_theme_constant_override("separation", 8)
	var dot := ColorRect.new()
	dot.color = S["accent"] if style_id != "B" else S["accent2"]
	dot.custom_minimum_size = Vector2(6 if style_id != "C" else 10, 22)
	if style_id != "B":
		th.add_child(dot)
	th.add_child(lbl(up("Traits"), 22, (S["accent"] if style_id == "A" else (S["accent2"] if style_id == "B" else S["muted"])), style_id == "B"))
	v.add_child(th)
	for t in [["Driven", "ambition"], ["Film Student", "intelligence"]]:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 10)
		var ib := PanelContainer.new()
		var b := box(Color(S["accent"] if style_id != "B" else S["accent2"], 0.18), 40 if style_id == "C" else (2 if style_id == "B" else 10))
		b.set_content_margin_all(8)
		ib.add_theme_stylebox_override("panel", b)
		ib.add_child(Icon.new(t[1], S["accent"] if style_id != "B" else S["accent2"], 26))
		h.add_child(ib)
		h.add_child(lbl(up(t[0]) if style_id == "B" else t[0], 24, S["text"], style_id != "A"))
		v.add_child(h)
	var lock := HBoxContainer.new()
	lock.add_theme_constant_override("separation", 10)
	var lb := PanelContainer.new()
	var b2 := box(Color(S["text"], 0.06), 40 if style_id == "C" else (2 if style_id == "B" else 10), Color(S["text"], 0.2), 2)
	b2.set_content_margin_all(8)
	lb.add_theme_stylebox_override("panel", b2)
	lb.add_child(Icon.new("leadership", Color(S["text"], 0.3), 26))
	lock.add_child(lb)
	lock.add_child(lbl("Captain at 60", 22, Color(S["text"], 0.4)))
	v.add_child(lock)
	var p := panel(v)
	if style_id == "B":
		var bx: StyleBoxFlat = p.get_theme_stylebox("panel").duplicate()
		bx.border_color = S["accent2"]
		bx.border_width_top = 5
		p.add_theme_stylebox_override("panel", bx)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return p


func _recent() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	v.add_child(lbl(up("Recent results"), 22, S["muted"], style_id == "B"))
	for r in [["W", "Wk 4", "Pine Bluff", "24-17", "FG 3/3 · Long 41"]]:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 14)
		var res := PanelContainer.new()
		var c: Color = S["good"] if r[0] == "W" else S["bad"]
		var b := box(c, 30 if style_id == "C" else (2 if style_id == "B" else 8))
		b.set_content_margin_all(0)
		if style_id == "B":
			b.skew = Vector2(S["skew"], 0)
		res.add_theme_stylebox_override("panel", b)
		res.custom_minimum_size = Vector2(48, 48)
		var rl := lbl(r[0], 28, Color.WHITE if style_id != "A" else Color("#08101f"), true)
		rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		res.add_child(rl)
		h.add_child(res)
		var mid := VBoxContainer.new()
		mid.add_theme_constant_override("separation", -2)
		mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mid.add_child(lbl("%s  %s" % [r[1], up(r[2]) if style_id == "B" else r[2]], 26, S["text"], style_id == "B"))
		mid.add_child(lbl(r[4], 20, S["muted"]))
		h.add_child(mid)
		h.add_child(lbl(r[3], 34, S["text"], true))
		v.add_child(h)
	return panel(v)


# --- entry --------------------------------------------------------------------------

func _ready() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	style_id = args.get("style", "A")
	light = args.get("light", "0") == "1"
	S = tokens(style_id)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var th := Theme.new()
	th.default_font = font("body")
	theme = th
	if args.get("screen", "main") == "hub":
		build_hub()
	else:
		build_main()
	await get_tree().create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(args.get("out", "user://p.png"))
	get_tree().quit()
