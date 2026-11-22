@tool
class_name ClippedBox
extends StyleBox
## The broadcast panel shape: a flat fill with clipped (angled) corners, a thin
## inner stroke, an optional faint diagonal texture, an optional accent stripe
## on the left and an optional rule along the top or bottom. Drawn from
## polygons (no textures), so it is crisp at any size and cheap: it only
## redraws when its control does. Colors are set from Brand by BrandTheme.

## Fill (transparent = no fill).
@export var bg := Color(0, 0, 0, 0)
## Inner stroke (transparent = none) and its width.
@export var stroke := Color(0, 0, 0, 0)
@export var stroke_width := 2
## Corner clips in px: top-left, top-right, bottom-right, bottom-left.
@export var cut_tl := 0
@export var cut_tr := 0
@export var cut_br := 0
@export var cut_bl := 0
## Faint diagonal lines over the fill (transparent = none).
@export var texture_color := Color(0, 0, 0, 0)
@export var texture_step := 7
## Accent stripe along the left edge (transparent = none) and its width.
@export var stripe := Color(0, 0, 0, 0)
@export var stripe_width := 6
## A rule along the top or bottom edge (transparent = none) and its width.
@export var rule_top := Color(0, 0, 0, 0)
@export var rule_bottom := Color(0, 0, 0, 0)
@export var rule_width := 4


func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	var poly := outline(rect)
	if poly.size() < 3:
		return
	if bg.a > 0.0:
		RenderingServer.canvas_item_add_polygon(to_canvas_item, poly, PackedColorArray([bg]))
	if texture_color.a > 0.0 and texture_step > 1:
		var x := rect.position.x - rect.size.y
		while x < rect.end.x:
			var line := PackedVector2Array([Vector2(x, rect.end.y), Vector2(x + rect.size.y, rect.position.y)])
			for seg in Geometry2D.clip_polyline_with_polygon(line, poly):
				if seg.size() >= 2:
					RenderingServer.canvas_item_add_line(to_canvas_item, seg[0], seg[seg.size() - 1], texture_color, 1.0)
			x += texture_step
	if stripe.a > 0.0:
		_band(to_canvas_item, poly, Rect2(rect.position, Vector2(stripe_width, rect.size.y)), stripe)
	if rule_top.a > 0.0:
		_band(to_canvas_item, poly, Rect2(rect.position, Vector2(rect.size.x, rule_width)), rule_top)
	if rule_bottom.a > 0.0:
		_band(to_canvas_item, poly, Rect2(Vector2(rect.position.x, rect.end.y - rule_width),
			Vector2(rect.size.x, rule_width)), rule_bottom)
	if stroke.a > 0.0 and stroke_width > 0:
		var inner := Geometry2D.offset_polygon(poly, -stroke_width * 0.5, Geometry2D.JOIN_MITER)
		if not inner.is_empty():
			var ring: PackedVector2Array = inner[0]
			ring.append(ring[0])
			RenderingServer.canvas_item_add_polyline(to_canvas_item, ring, PackedColorArray([stroke]),
				stroke_width, true)


## The clipped outline of `rect`.
func outline(rect: Rect2) -> PackedVector2Array:
	var a := rect.position
	var b := rect.end
	var lim := minf(rect.size.x, rect.size.y) * 0.5
	var tl := minf(cut_tl, lim)
	var tr := minf(cut_tr, lim)
	var br := minf(cut_br, lim)
	var bl := minf(cut_bl, lim)
	var p := PackedVector2Array()
	p.append(Vector2(a.x + tl, a.y))
	p.append(Vector2(b.x - tr, a.y))
	if tr > 0:
		p.append(Vector2(b.x, a.y + tr))
	p.append(Vector2(b.x, b.y - br))
	if br > 0:
		p.append(Vector2(b.x - br, b.y))
	p.append(Vector2(a.x + bl, b.y))
	if bl > 0:
		p.append(Vector2(a.x, b.y - bl))
	p.append(Vector2(a.x, a.y + tl))
	return p


## Fills the part of `band` inside the outline.
func _band(ci: RID, poly: PackedVector2Array, band: Rect2, color: Color) -> void:
	var r := PackedVector2Array([band.position, Vector2(band.end.x, band.position.y), band.end,
		Vector2(band.position.x, band.end.y)])
	for piece in Geometry2D.intersect_polygons(r, poly):
		if piece.size() >= 3:
			RenderingServer.canvas_item_add_polygon(ci, piece, PackedColorArray([color]))


## A copy with some fields changed: {"bg": ..., "stroke": ...}.
func with(changes: Dictionary) -> ClippedBox:
	var b: ClippedBox = duplicate()
	for k in changes:
		b.set(k, changes[k])
	return b
