class_name BrandBar
extends VBoxContainer
## Progress / stat bar: name and value over a thin clipped bar with tick
## marks every 10%. The fill is white (red when `highlight`); a preview shows
## a gain as a hatched white extension and a loss as a red cut.
## Scene: scenes/ui/brand/progress_bar.tscn.

@export var title := "Stat"
@export var value := 50.0
@export var max_value := 100.0
## Preview of a change (+ gain, - loss), drawn on the bar and next to the value.
@export var delta := 0.0
@export var highlight := false
@export var disabled := false

var _track: _Track
var _value_l: Label
var _delta_l: Label


class _Track:
	extends Control
	var ratio := 0.5
	var delta_ratio := 0.0
	var fill := Brand.WHITE
	var off := false

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var cut := h * 0.6
		_poly(Rect2(0, 0, w, h), Brand.INK_3, cut)
		var base := ratio if delta_ratio >= 0.0 else ratio + delta_ratio
		var fw := w * clampf(base, 0.0, 1.0)
		if fw > 1.0:
			_poly(Rect2(0, 0, fw, h), Brand.GREY_DIM if off else fill, cut if fw >= w - 0.5 else 0.0)
		if absf(delta_ratio) > 0.0001:
			var x1 := w * clampf(ratio + delta_ratio if delta_ratio > 0.0 else ratio, 0.0, 1.0)
			var seg := Rect2(fw, 0, maxf(x1 - fw, 3.0), h)
			if delta_ratio > 0.0:
				draw_rect(seg, Color(Brand.WHITE, 0.35))
				var x := seg.position.x - h
				while x < seg.end.x:
					var a := Vector2(maxf(x, seg.position.x), h)
					var b := Vector2(minf(x + h, seg.end.x), 0)
					draw_line(a, b, Brand.WHITE, 2.0)
					x += 6.0
			else:
				draw_rect(seg, Brand.RED)
		# Tick marks every 10%.
		for i in range(1, 10):
			var tx := roundf(w * i / 10.0)
			draw_line(Vector2(tx, 0), Vector2(tx, h), Brand.INK_1, 2.0)

	func _poly(r: Rect2, c: Color, cut: float) -> void:
		var pts := PackedVector2Array([r.position, Vector2(r.end.x - cut, r.position.y), Vector2(r.end.x, r.end.y),
			Vector2(r.position.x, r.end.y)])
		draw_colored_polygon(pts, c)


func _ready() -> void:
	add_theme_constant_override("separation", Brand.SPACE_2)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_2)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	var name_l := BrandTheme.label(title, "BodyStrong", Brand.GREY_DIM if disabled else Color(0, 0, 0, 0))
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_l.clip_text = true
	name_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(name_l)
	_delta_l = BrandTheme.label("", "Caption")
	row.add_child(_delta_l)
	_value_l = BrandTheme.label("", "Subhead", Brand.GREY_DIM if disabled else Color(0, 0, 0, 0))
	row.add_child(_value_l)
	_track = _Track.new()
	_track.custom_minimum_size.y = Brand.BAR_H
	_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_track.fill = Brand.RED if highlight else Brand.WHITE
	_track.off = disabled
	add_child(_track)
	_refresh()


func _refresh() -> void:
	_track.ratio = value / maxf(max_value, 0.001)
	_track.delta_ratio = delta / maxf(max_value, 0.001)
	_track.queue_redraw()
	_value_l.text = "%d" % roundi(value)
	if absf(delta) >= 0.05:
		_delta_l.text = "%+d" % roundi(delta) if absf(delta) >= 1.0 else "%+.1f" % delta
		_delta_l.add_theme_color_override("font_color", Brand.WHITE if delta > 0.0 else Brand.RED_HOT)
	else:
		_delta_l.text = ""


## The bar and number glide to `v` (Brand.T_BASE; the number counts).
func animate_to(v: float) -> void:
	var from := value
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_method(func(x: float) -> void:
		value = x
		_refresh(), from, v, Brand.T_BASE * 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func preview(d: float) -> void:
	delta = d
	_refresh()
