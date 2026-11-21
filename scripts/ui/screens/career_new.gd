class_name CareerNewScreen
extends MenuScreen
## New Career: name, jersey number, placeholder appearance, starting school
## (data/career/world.json). Creates the career in the chosen slot and opens
## the Hub.

## Set by the Career menu before opening this screen.
static var slot: int = 1
## Dev/testing: show the web name chooser on any platform (tools/ui_check).
static var force_name_chooser := false
## How many suggested names the chooser shows at a time.
const SUGGESTIONS := 6

var _name: LineEdit
var _number := 3
var _skin := 0
var _hair := 0
var _school := ""
var _number_label: Label
var _face: AppearancePreview
var _start: Button


## Placeholder look: a head (skin) with hair, a jersey with the number.
class AppearancePreview:
	extends Control
	var skin := Color.TAN
	var hair := Color.BLACK
	var jersey := Color(0.1, 0.2, 0.55)
	var number := 3

	func _draw() -> void:
		var c := Vector2(size.x * 0.5, size.y * 0.38)
		var r := minf(size.x, size.y) * 0.24
		draw_rect(Rect2(c.x - r * 1.5, c.y + r * 0.9, r * 3.0, size.y - c.y - r * 0.9), jersey)
		draw_circle(c, r, skin)
		draw_arc(c, r, PI * 1.05, PI * 1.95, 24, hair, r * 0.55)
		var font := get_theme_default_font()
		var s := str(number)
		var fs := int(r * 0.9)
		var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_string(font, Vector2(c.x - w * 0.5, size.y - 8), s, HORIZONTAL_ALIGNMENT_LEFT, -1,
			fs, Color.WHITE)


func _build(col: VBoxContainer) -> void:
	var look: Dictionary = CareerContent.world().get("appearance", {})
	_name = LineEdit.new()
	_name.placeholder_text = "Your name"
	_name.max_length = 20
	_name.custom_minimum_size.y = 88
	_name.add_theme_font_size_override("font_size", 34)
	_name.text_changed.connect(func(_t: String) -> void: _update_start())
	# Phones (native apps): ask for the on-screen keyboard explicitly on every
	# tap (Godot's own request can be missed), and close it on Enter / Done.
	# Phone browsers can't open it this way: they get the name chooser instead.
	if not uses_name_chooser():
		_name.virtual_keyboard_enabled = true
		_name.virtual_keyboard_show_on_focus = true
		_name.focus_mode = Control.FOCUS_ALL
		_name.gui_input.connect(_on_name_input)
		_name.text_submitted.connect(func(_t: String) -> void: _name.release_focus())
	col.add_child(_name)

	# Number + appearance.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	col.add_child(row)
	_face = AppearancePreview.new()
	_face.custom_minimum_size = Vector2(150, 200)
	row.add_child(_face)
	var opts := VBoxContainer.new()
	opts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opts.add_theme_constant_override("separation", 8)
	row.add_child(opts)
	var num_row := HBoxContainer.new()
	opts.add_child(num_row)
	_number_label = UiKit.label("", 30)
	_number_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	num_row.add_child(_number_label)
	for d in [-1, 1]:
		var b := UiKit.button("-" if d < 0 else "+", func() -> void:
			_number = wrapi(_number + d, 1, 100)
			_refresh_look())
		b.custom_minimum_size = Vector2(UiKit.BUTTON_HEIGHT, UiKit.BUTTON_HEIGHT)
		num_row.add_child(b)
	var skins: Array = look.get("skin", ["#e0ac7e"])
	var hairs: Array = look.get("hair", ["#2b1d0e"])
	var skin_b := UiKit.button("Skin Tone", func() -> void:
		_skin = (_skin + 1) % skins.size()
		_refresh_look())
	var hair_b := UiKit.button("Hair", func() -> void:
		_hair = (_hair + 1) % hairs.size()
		_refresh_look())
	for b in [skin_b, hair_b]:
		b.add_theme_font_size_override("font_size", 28)
	opts.add_child(CareerUi.button_row([skin_b, hair_b]))

	# Every career starts at Hoboken High School (TeamDatabase.start_team).
	col.add_child(UiKit.section("YOUR SCHOOL"))
	var s := TeamDatabase.start_team()
	var parts := UiKit.card(CareerUi.html_color(str(s.get("colors", ["#7d838c"])[0])), 4)
	(parts[0] as Control).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v: VBoxContainer = parts[1]
	v.add_child(UiKit.label("%s %s" % [s.get("name", ""), s.get("nickname", "")], 30))
	v.add_child(UiKit.label("%s  -  %s" % [s.get("city", ""), s.get("conference", "")], 22, UiKit.MUTED))
	v.add_child(UiKit.label("Every career starts here: freshman kicker at %s." % s.get("name", ""), 22, UiKit.MUTED))
	col.add_child(parts[0])
	_school = str(s.get("id", ""))
	_start = UiKit.button("Start Career", _create, UiKit.PRIMARY)
	col.add_child(CareerUi.button_row([UiKit.button("Back", go_back), _start]))
	if uses_name_chooser():
		_setup_name_chooser()
	_refresh_look()
	_update_start()


func go_back() -> void:
	Screens.go(Screens.CAREER)


func _on_name_input(e: InputEvent) -> void:
	var released: bool = (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT \
			and not e.pressed) or (e is InputEventScreenTouch and not e.pressed)
	if released:
		_show_keyboard.call_deferred()


func _show_keyboard() -> void:
	if not is_instance_valid(_name) or not _name.is_inside_tree():
		return
	if not _name.has_focus():
		_name.grab_focus()
	_name.edit()
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		DisplayServer.virtual_keyboard_show(_name.text, _name.get_global_rect(),
			DisplayServer.KEYBOARD_TYPE_DEFAULT, _name.max_length, _name.caret_column)


## Leaving the screen closes the keyboard.
func _exit_tree() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		DisplayServer.virtual_keyboard_hide()


func _refresh_look() -> void:
	var look: Dictionary = CareerContent.world().get("appearance", {})
	_face.skin = CareerUi.html_color(str(look.get("skin", ["#e0ac7e"])[_skin]))
	_face.hair = CareerUi.html_color(str(look.get("hair", ["#2b1d0e"])[_hair]))
	_face.number = _number
	var s := TeamDatabase.team(_school)
	if not s.is_empty():
		_face.jersey = CareerUi.html_color(str(s["colors"][0]))
	_face.queue_redraw()
	_number_label.text = "Jersey  #%d" % _number


# --- name chooser (web build on touch devices) -----------------------------------------
# Phone browsers often don't open their keyboard for a Godot text field (the
# page can only raise the keyboard from inside the tap itself, and Godot reads
# taps a frame later). So on the web on touch devices the name field becomes
# a button: it opens a list of suggested names (data/career/world.json
# "names") with a Shuffle button. Desktop, Android and iOS apps type as before.

## True on the web build when the device has a touch screen (phones, tablets).
static func uses_name_chooser() -> bool:
	if force_name_chooser:
		return true
	return OS.has_feature("web") and (OS.has_feature("web_android") or OS.has_feature("web_ios")
		or DisplayServer.is_touchscreen_available())


func _setup_name_chooser() -> void:
	_name.editable = false
	_name.focus_mode = Control.FOCUS_NONE
	_name.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_name.placeholder_text = "Tap to pick a name"
	_name.add_theme_color_override("font_uneditable_color", UiKit.TEXT)
	_name.right_icon = UiIcons.texture("pencil", UiKit.ACCENT, 32)
	_name.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			UiKit.feedback(&"ui_tap")
			_open_name_chooser())
	# Start with a name filled in, so nothing blocks the first career.
	_set_name(_random_names(1)[0])


func _set_name(n: String) -> void:
	_name.text = n.left(_name.max_length)
	_update_start()


## n different "First Last" names from the world's name lists.
func _random_names(n: int) -> Array:
	var names: Dictionary = CareerContent.world().get("names", {})
	var firsts: Array = names.get("first", ["Sam"])
	var lasts: Array = names.get("last", ["Kicker"])
	var out: Array = []
	var guard := 0
	while out.size() < n and guard < 200:
		guard += 1
		var full := "%s %s" % [firsts.pick_random(), lasts.pick_random()]
		if not full in out and full != _name.text:
			out.append(full)
	return out


func _open_name_chooser() -> void:
	if get_node_or_null("Modal") != null:
		return
	var v := UiKit.modal(self, "Pick a Name")
	var root := UiKit.modal_root(v)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	v.add_child(grid)
	var fill := func() -> void:
		for ch in grid.get_children():
			ch.queue_free()
		for n in _random_names(SUGGESTIONS):
			var b := UiKit.button(n, func() -> void:
				_set_name(n)
				root.queue_free())
			b.add_theme_font_size_override("font_size", 28)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(b)
	fill.call()
	v.add_child(UiKit.button("Shuffle", fill, UiKit.PRIMARY, "fast"))
	v.add_child(UiKit.button("Cancel", root.queue_free, UiKit.SECONDARY, "back"))


func _update_start() -> void:
	_start.disabled = _school == "" or _name.text.strip_edges() == ""
	_start.text = "Start Career" if not _start.disabled else \
		("Pick a Name" if uses_name_chooser() else "Enter a Name")


func _create() -> void:
	var m := CareerManager.create(slot, _name.text.strip_edges(), _number,
		{"skin": _skin, "hair": _hair})
	GameState.career = m
	Screens.go(Screens.CAREER_HUB)
