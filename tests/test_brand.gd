extends "res://tests/test_case.gd"
## The broadcast design system: contrast, the type scale, theme states, the
## component scenes, the icons, the generated .tres, and that colors live in
## Brand only.

const COMPONENTS := ["primary_button", "secondary_button", "tab_bar", "segmented_toggle", "list_row",
	"stat_tile", "progress_bar", "card", "header_bar", "banner", "popup", "chip"]


func test_text_contrast_meets_wcag() -> void:
	for p in Brand.TEXT_PAIRS:
		var r := Brand.contrast(Brand.PALETTE[p[0]], Brand.PALETTE[p[1]])
		check(r >= float(p[2]), "%s on %s: %.2f (needs %.1f)" % [p[0], p[1], r, p[2]])


func test_palette_is_red_black_white() -> void:
	for name in Brand.PALETTE:
		var c: Color = Brand.PALETTE[name]
		var grey := absf(c.r - c.g) < 0.03 and absf(c.g - c.b) < 0.03
		var red := c.r > 0.5 and c.g < 0.25 and c.b < 0.25
		check(grey or red, "%s is grey or red (%s)" % [name, c.to_html(false)])


func test_type_scale() -> void:
	for name in Brand.TYPE:
		check(int(Brand.TYPE[name][1]) >= Brand.MIN_TEXT, "%s is at least %d px" % [name, Brand.MIN_TEXT])
		check(ResourceLoader.exists(str(Brand.TYPE[name][0])), "%s font is bundled" % name)
	check(int(Brand.BUTTON_TYPE[1]) >= Brand.MIN_TEXT, "button text")


func test_every_button_kind_has_every_state() -> void:
	var t := BrandTheme.build()
	for kind in BrandTheme.BUTTONS:
		for state in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
			check(t.has_stylebox(state, kind), "%s %s" % [kind, state])
		check(t.has_font("font", kind), "%s font" % kind)
	for v in BrandTheme.LABELS:
		check(t.get_font_size("font_size", v) >= Brand.MIN_TEXT, "%s size" % v)
	for p in BrandTheme.PANELS:
		check(t.has_stylebox("panel", p), "panel %s" % p)


func test_component_scenes_build() -> void:
	for name in COMPONENTS:
		var path := "res://scenes/ui/brand/%s.tscn" % name
		check(ResourceLoader.exists(path), "%s scene" % name)
		var n: Node = load(path).instantiate()
		check(n != null, "%s instantiates" % name)
		n.free()


func test_icons_render() -> void:
	for n in BrandIcons.names():
		var tex := BrandIcons.texture(str(n), Brand.WHITE, 40)
		check(tex != null and tex.get_width() == 40, "icon %s" % n)


func test_clipped_box_outline() -> void:
	var b := ClippedBox.new()
	b.cut_tl = 18
	b.cut_br = 18
	var p := b.outline(Rect2(0, 0, 200, 100))
	eq(p.size(), 6, "two clipped corners: six points")
	check(not Geometry2D.is_point_in_polygon(Vector2(2, 2), p), "the top-left corner is cut")
	check(Geometry2D.is_point_in_polygon(Vector2(198, 2), p), "the top-right is square")


func test_generated_theme_is_in_sync() -> void:
	check(ResourceLoader.exists(BrandTheme.PATH), "assets/ui/brand_theme.tres exists")
	var saved: Theme = load(BrandTheme.PATH)
	var fresh := BrandTheme.build()
	for kind in BrandTheme.BUTTONS:
		for state in ["normal", "hover", "pressed", "disabled"]:
			var a := saved.get_stylebox(state, kind) as ClippedBox
			var b := fresh.get_stylebox(state, kind) as ClippedBox
			check(a != null and b != null and a.bg == b.bg and a.stroke == b.stroke,
				"%s %s matches Brand (re-run tools/build_brand_theme.tscn after editing Brand)" % [kind, state])


func test_no_raw_colors_outside_brand() -> void:
	var re := RegEx.create_from_string("Color\\(\"#|Color\\.(RED|WHITE|BLACK|GRAY|GREY)|Color\\((?!0, 0, 0, 0\\))[0-9.]")
	var files := ["res://scripts/ui/brand/brand_theme.gd", "res://scripts/ui/brand/brand_button.gd",
		"res://scripts/ui/brand/brand_tabs.gd", "res://scripts/ui/brand/brand_segmented.gd",
		"res://scripts/ui/brand/brand_list_row.gd", "res://scripts/ui/brand/brand_stat_tile.gd",
		"res://scripts/ui/brand/brand_bar.gd", "res://scripts/ui/brand/brand_card.gd",
		"res://scripts/ui/brand/brand_header.gd", "res://scripts/ui/brand/brand_banner.gd",
		"res://scripts/ui/brand/brand_popup.gd", "res://scripts/ui/brand/brand_chip.gd",
		"res://scripts/ui/brand/brand_motion.gd", "res://scripts/ui/brand/clipped_box.gd"]
	for f in files:
		var src := FileAccess.get_file_as_string(f)
		var m := re.search(src)
		check(m == null, "%s: colors come from Brand (found '%s')" % [f, m.get_string() if m != null else ""])


func test_count_up_text() -> void:
	eq(BrandMotion.number_text(1234567.0, "%s"), "1,234,567", "commas")
	eq(BrandMotion.number_text(52.4, "%d yd"), "52 yd", "rounded")
	eq(BrandMotion.commas(-1200), "-1,200", "negative")
