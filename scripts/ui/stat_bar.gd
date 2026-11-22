class_name StatBar
extends VBoxContainer
## One Career stat: icon, name, optional +/- preview, value, and a white bar
## (broadcast system: tick marks every 10%).
##   preview(delta): shows the change on the bar (hatched white extension for a
##       gain, red cut for a loss) and as "+3" next to the value.
##   animate_to(v): the bar and number glide to the new value (StatBar.TWEEN).
## Display only; drawing is a few styleboxes, redrawn only when values change.

var value := 0.0
var delta := 0.0
var color := Brand.WHITE

var _icon: TextureRect
var _name: Label
var _delta: Label
var _num: Label
var _bar: _Track


class _Track:
	extends Control
	var value := 0.0     # 0..100
	var delta := 0.0
	var color := Brand.WHITE
	var glow := 0.0

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_rect(Rect2(Vector2.ZERO, size), Brand.INK_3)
		var base := value if delta >= 0.0 else value + delta
		var fw := w * clampf(base / 100.0, 0.0, 1.0)
		if fw > 0.5:
			draw_rect(Rect2(0, 0, fw, h), color)
		if absf(delta) > 0.01:
			var x1 := w * clampf((value + delta) / 100.0 if delta > 0.0 else value / 100.0, 0.0, 1.0)
			var seg := Rect2(fw, 0, maxf(x1 - fw, 3.0), h)
			if delta > 0.0:
				draw_rect(seg, Color(Brand.WHITE, 0.35))
				var x := seg.position.x - h
				while x < seg.end.x:
					draw_line(Vector2(maxf(x, seg.position.x), h), Vector2(minf(x + h, seg.end.x), 0), Brand.WHITE, 2.0)
					x += 6.0
			else:
				draw_rect(seg, Brand.RED)
		for i in range(1, 10):
			var tx := roundf(w * i / 10.0)
			draw_line(Vector2(tx, 0), Vector2(tx, h), Brand.INK_1, 2.0)


## key: stat key (CareerData.STAT_NAMES), for the icon. compact: smaller text.
func _init(key: String = "", title: String = "", v: float = 0.0, group_color := Brand.WHITE,
		fs: int = 24) -> void:
	value = v
	color = group_color
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 3)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(h)
	if key != "" and UiIcons.has(key):
		_icon = UiIcons.rect(key, Brand.GREY, fs)
		h.add_child(_icon)
	_name = UiKit.label(title, fs)
	_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name.autowrap_mode = TextServer.AUTOWRAP_OFF
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	h.add_child(_name)
	_delta = UiKit.label("", fs - 2, UiKit.GOOD, UiTokens.FONT_DISPLAY)
	_delta.autowrap_mode = TextServer.AUTOWRAP_OFF
	_delta.visible = false
	h.add_child(_delta)
	_num = UiKit.label(str(roundi(v)), fs + 2, UiKit.TEXT, UiTokens.FONT_DISPLAY)
	_num.autowrap_mode = TextServer.AUTOWRAP_OFF
	_num.custom_minimum_size.x = fs * 1.4
	_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(_num)
	_bar = _Track.new()
	_bar.value = v
	_bar.color = group_color
	_bar.custom_minimum_size.y = Brand.BAR_H
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bar)


## Shows a pending change on the bar and as "+3"/"-8" (0 hides it).
func preview(d: float) -> void:
	delta = d
	_bar.delta = d
	_delta.visible = absf(d) >= 0.5
	_delta.text = ("+%d" if d > 0.0 else "%d") % roundi(d)
	_delta.add_theme_color_override("font_color", UiKit.GOOD if d > 0.0 else UiKit.BAD)
	_bar.queue_redraw()


## Glides from `from` to the current value (e.g. after a week), with a
## brief flash of the change.
func animate_from(from: float, delay := 0.15) -> void:
	var to := value
	if absf(to - from) < 0.5:
		return
	set_shown(from)
	_delta.visible = true
	_delta.text = ("+%d" if to > from else "%d") % roundi(to - from)
	_delta.add_theme_color_override("font_color", UiKit.GOOD if to > from else UiKit.BAD)
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_interval(delay)
	tw.tween_method(set_shown, from, to, UiTokens.BAR_TWEEN).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.4)
	tw.tween_property(_delta, "modulate:a", 0.0, 0.4)


func animate_to(v: float) -> void:
	var from := value
	value = v
	animate_from(from, 0.0)


func set_shown(v: float) -> void:
	_bar.value = v
	_num.text = str(roundi(v))
	_bar.queue_redraw()
