class_name Backdrop
extends Control
## Full-screen screen background, drawn from code (no image assets), once per
## resize: it is static, so it costs nothing per frame on low-end phones.
## Moods (UiTokens palettes):
##   night      Friday night: navy sky, two floodlights, field and yard lines
##   saturday   College: warm crimson sky, floodlights, crowd bowl and pennant stripe
##   broadcast  Pro: charcoal with broadcast pinstripes and a red slash
## `team` (optional) tints a slash with the player's team color.

var palette: Dictionary = UiTokens.NIGHT
var team: Color = Color.TRANSPARENT


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return
	var top: Color = palette["bg_top"]
	var bottom: Color = palette["bg_bottom"]
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(w, 0), Vector2(w, h), Vector2(0, h)]),
		PackedColorArray([top, top, bottom, bottom]))
	match str(palette.get("mood", "night")):
		"night":
			_floodlights(w, h, Color(0.75, 0.83, 1.0))
			_field(w, h, Color(0.04, 0.16, 0.09, 0.6))
		"saturday":
			_floodlights(w, h, Color(1.0, 0.85, 0.7))
			_crowd(w, h)
			_field(w, h, Color(0.06, 0.15, 0.07, 0.55))
		"broadcast":
			_pinstripes(w, h)
	if team.a > 0.0:
		draw_colored_polygon(PackedVector2Array([Vector2(0, h * 0.64), Vector2(w * 0.22, h * 0.52),
			Vector2(w * 0.22, h * 0.56), Vector2(0, h * 0.68)]), Color(team, 0.28))


func _floodlights(w: float, h: float, tint: Color) -> void:
	var s := minf(w, h * 0.6)
	for corner in [Vector2(-0.06 * s, -0.08 * s), Vector2(w + 0.06 * s, -0.08 * s)]:
		# Soft glow: layered translucent circles (cheap, drawn once).
		for i in 12:
			draw_circle(corner, s * (0.72 - i * 0.05), Color(tint, 0.02))
		# Light bank.
		draw_circle(corner, s * 0.08, Color(1, 1, 1, 0.45))
		# Beam toward the field.
		var dir := 1.0 if corner.x < w * 0.5 else -1.0
		draw_colored_polygon(PackedVector2Array([corner, corner + Vector2(dir * s * 0.75, h * 0.72),
			corner + Vector2(dir * s * 0.4, h * 0.8)]), Color(tint, 0.035))


func _field(w: float, h: float, grass: Color) -> void:
	var top_y := h * 0.8
	draw_colored_polygon(PackedVector2Array([Vector2(0, top_y), Vector2(w, top_y), Vector2(w, h),
		Vector2(0, h)]), grass)
	var lines := 9
	for i in lines:
		var t := float(i) / float(lines - 1)
		var x_top := lerpf(w * 0.3, w * 0.7, t)
		var x_bot := lerpf(-w * 0.45, w * 1.45, t)
		draw_line(Vector2(x_top, top_y), Vector2(x_bot, h), Color(1, 1, 1, 0.07), 2.0, true)
	draw_line(Vector2(0, top_y), Vector2(w, top_y), Color(1, 1, 1, 0.1), 2.0)


func _crowd(w: float, h: float) -> void:
	# Stadium bowl: a darker band of stands with faint "crowd" specks.
	var y0 := h * 0.66
	var y1 := h * 0.8
	draw_colored_polygon(PackedVector2Array([Vector2(0, y0), Vector2(w, y0 - h * 0.03), Vector2(w, y1),
		Vector2(0, y1)]), Color(0, 0, 0, 0.3))
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 160:
		var p := Vector2(rng.randf() * w, lerpf(y0, y1, rng.randf()))
		draw_rect(Rect2(p, Vector2(3, 3)), Color(1, 0.9, 0.8, rng.randf_range(0.03, 0.1)))
	# Pennant stripe.
	draw_colored_polygon(PackedVector2Array([Vector2(w * 0.6, 0), Vector2(w, 0), Vector2(w, h * 0.12),
		Vector2(w * 0.86, h * 0.12)]), Color(palette["accent"], 0.08))


func _pinstripes(w: float, h: float) -> void:
	var x := -h
	while x < w:
		draw_line(Vector2(x, h), Vector2(x + h * 0.6, 0), Color(1, 1, 1, 0.022), 10.0)
		x += 36.0
	draw_colored_polygon(PackedVector2Array([Vector2(w * 0.55, 0), Vector2(w, 0), Vector2(w, h * 0.3),
		Vector2(w * 0.85, h * 0.3)]), Color(palette["accent"], 0.1))
	draw_colored_polygon(PackedVector2Array([Vector2(0, h * 0.9), Vector2(w * 0.4, h * 0.82),
		Vector2(w * 0.4, h * 0.84), Vector2(0, h * 0.92)]), Color(palette["accent"], 0.12))
