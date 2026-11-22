class_name BrandMotion
extends RefCounted
## Motion for the broadcast UI: short and snappy (Brand.T_*), never bouncy.
##   press(c)        a quick scale dip when a button goes down
##   swap(c)         a fast fade + slide for content changes (tabs)
##   count_up(l,..)  numbers count up to their value
##   flash(c)        a red flash over a control (record breaks, scoring)


static func press(c: Control) -> void:
	c.pivot_offset = c.size * 0.5
	var tw := c.create_tween().set_ignore_time_scale(true)
	tw.tween_property(c, "scale", Vector2.ONE * Brand.PRESS_SCALE, Brand.T_PRESS) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "scale", Vector2.ONE, Brand.T_FAST) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## New content in place: fade in with a short slide from the right.
static func swap(c: Control) -> void:
	c.modulate.a = 0.0
	var tw := c.create_tween().set_ignore_time_scale(true).set_parallel(true)
	tw.tween_property(c, "modulate:a", 1.0, Brand.T_FAST)
	c.position.x += 16.0
	tw.tween_property(c, "position:x", c.position.x - 16.0, Brand.T_BASE) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Counts `l` from `from` to `to` (fmt: a format string for one number,
## e.g. "%d" or "%d yd"; thousands get commas with "%s").
static func count_up(l: Label, from: float, to: float, fmt := "%d", seconds := Brand.T_COUNT) -> void:
	var tw := l.create_tween().set_ignore_time_scale(true)
	tw.tween_method(func(v: float) -> void: l.text = number_text(v, fmt), from, to, seconds) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)


## "%d" -> 1234, "%s" -> "1,234", "%.1f" -> 12.5.
static func number_text(v: float, fmt: String) -> String:
	if fmt.contains("%s"):
		return fmt % commas(roundi(v))
	if fmt.contains("%d"):
		return fmt % roundi(v)
	return fmt % v


static func commas(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + s + out


## A red flash over `c` (record breaks, scoring): on at once, gone in T_BASE*2.
static func flash(c: Control) -> void:
	var r := ColorRect.new()
	r.color = Brand.RED
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.modulate.a = 0.6
	c.add_child(r)
	var tw := r.create_tween().set_ignore_time_scale(true)
	tw.tween_property(r, "modulate:a", 0.0, Brand.T_BASE * 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(r.queue_free)
