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
	b.custom_minimum_size.y = 72
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
