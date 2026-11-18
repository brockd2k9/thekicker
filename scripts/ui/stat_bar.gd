class_name StatBar
extends VBoxContainer
## One Career stat: icon, name, optional +/- preview, value, and a bar in the
## stat group's color.
##   preview(delta): shows the change on the bar (green extension for a gain,
##       red cut-out for a loss) and as "+3" next to the value.
##   animate_to(v): the bar and number glide to the new value (StatBar.TWEEN).
## Display only; drawing is a few styleboxes, redrawn only when values change.

var value := 0.0
var delta := 0.0
var color := Color.WHITE

var _icon: TextureRect
var _name: Label
var _delta: Label
var _num: Label
var _bar: _Track


class _Track:
	extends Control
	var value := 0.0     # 0..100
	var delta := 0.0
	var color := Color.WHITE
	var track := Color(1, 1, 1, 0.1)
	var good := Color.GREEN
	var bad := Color.RED
	var glow := 0.3

	func _draw() -> void:
		var h := size.y
		var r := int(h * 0.5)
		_box(Rect2(Vector2.ZERO, size), track, r)
		var base := value if delta >= 0.0 else value + delta
		var fw := size.x * clampf(base / 100.0, 0.0, 1.0)
		if fw > 0.5:
			if glow > 0.0:
				_box(Rect2(-2, -2, fw + 4, h + 4), Color(color, glow * 0.45), r + 2)
			_box(Rect2(0, 0, fw, h), color, r)
			# Top shine.
			_box(Rect2(2, 1, maxf(fw - 4, 0.0), h * 0.35), Color(1, 1, 1, 0.22), r)
		if absf(delta) > 0.01:
			var x0 := fw
			var x1 := size.x * clampf((value + delta) / 100.0 if delta > 0.0 else value / 100.0, 0.0, 1.0)
			_box(Rect2(x0, 0, maxf(x1 - x0, 3.0), h), Color(good if delta > 0.0 else bad, 0.9), r)

	func _box(rect: Rect2, c: Color, r: int) -> void:
		var s := StyleBoxFlat.new()
		s.bg_color = c
		s.set_corner_radius_all(r)
		s.anti_aliasing = true
		draw_style_box(s, rect)


## key: stat key (CareerData.STAT_NAMES), for the icon. compact: smaller text.
func _init(key: String = "", title: String = "", v: float = 0.0, group_color := Color.WHITE,
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
		_icon = UiIcons.rect(key, group_color, fs)
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
	_bar.track = Color(UiKit.TEXT, 0.1)
	_bar.good = UiKit.GOOD
	_bar.bad = UiKit.BAD
	_bar.glow = float(UiKit.palette.get("glow", 0.3))
	_bar.custom_minimum_size.y = maxf(8.0, fs * 0.42)
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
