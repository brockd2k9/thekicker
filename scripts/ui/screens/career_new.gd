class_name CareerNewScreen
extends MenuScreen
## New Career: name, jersey number, placeholder appearance, starting school
## (data/career/world.json). Creates the career in the chosen slot and opens
## the Hub.

## Set by the Career menu before opening this screen.
static var slot: int = 1

var _name: LineEdit
var _number := 3
var _skin := 0
var _hair := 0
var _school := ""
var _number_label: Label
var _face: AppearancePreview
var _school_buttons: Dictionary = {}
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

	col.add_child(UiKit.section("STARTING SCHOOL"))
	var list := UiKit.scroll_list(col)
	var confs: Array = CareerContent.world().get("high_school", {}).get("conferences", [])
	for s in CareerContent.high_schools():
		var id := str(s["id"])
		var conf := str(confs[int(s.get("conference", 0))]) if confs.size() > int(s.get("conference", 0)) else ""
		var b := UiKit.button("%s %s\n%s  -  %s" % [s["name"], s.get("mascot", ""),
			CareerScreen.strength_word(float(s.get("strength", 50))), conf], _pick_school.bind(id))
		b.add_theme_font_size_override("font_size", 26)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		list.add_child(b)
		_school_buttons[id] = b
	_start = UiKit.button("Start Career", _create, UiKit.ACCENT.darkened(0.45))
	col.add_child(CareerUi.button_row([UiKit.button("Back", go_back), _start]))
	_refresh_look()
	_update_start()


func go_back() -> void:
	Screens.go(Screens.CAREER)


func _refresh_look() -> void:
	var look: Dictionary = CareerContent.world().get("appearance", {})
	_face.skin = CareerUi.html_color(str(look.get("skin", ["#e0ac7e"])[_skin]))
	_face.hair = CareerUi.html_color(str(look.get("hair", ["#2b1d0e"])[_hair]))
	_face.number = _number
	var s := CareerContent.school(_school)
	if not s.is_empty():
		_face.jersey = CareerUi.html_color(str(s["colors"][0]))
	_face.queue_redraw()
	_number_label.text = "Jersey  #%d" % _number


func _pick_school(id: String) -> void:
	_school = id
	for k in _school_buttons:
		var b: Button = _school_buttons[k]
		if k == id:
			b.add_theme_stylebox_override("normal", UiKit._box(UiKit.BUTTON_PRESSED, 14, UiKit.ACCENT))
		else:
			b.remove_theme_stylebox_override("normal")
	_refresh_look()
	_update_start()


func _update_start() -> void:
	_start.disabled = _school == "" or _name.text.strip_edges() == ""
	_start.text = "Start Career" if not _start.disabled else \
		("Pick a School" if _name.text.strip_edges() != "" else "Enter a Name")


func _create() -> void:
	var m := CareerManager.create(slot, _name.text.strip_edges(), _number,
		{"skin": _skin, "hair": _hair}, _school)
	GameState.career = m
	Screens.go(Screens.CAREER_HUB)
