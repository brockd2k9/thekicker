class_name FieldPaint
extends Node
## The lettering painted on the field: the yard-number digits and the end zone
## wordmark, drawn once with the game's display font into two small textures
## (white on black, mipmapped) for the turf shader. No texture files.
## Add one as a child of the field; it fills the material's `digits_tex` and
## `wordmark_tex` a frame or two later (until then the field has no lettering),
## and keeps what it drew for the next kick scene.

const FONT := preload("res://assets/fonts/BarlowCondensed-ExtraBold.ttf")
const DIGIT_CELL := Vector2i(128, 192)
const DIGITS := "012345"
const WORDMARK_SIZE := Vector2i(1024, 152)
## Barlow Condensed capitals and digits are this tall, as a share of the font size.
const CAP_HEIGHT := 0.7

static var _digits: Texture2D
static var _wordmarks := {}

var material: ShaderMaterial
var text := ""


static func attach(host: Node, mat: ShaderMaterial, wordmark: String) -> FieldPaint:
	var fp := FieldPaint.new()
	fp.material = mat
	fp.text = wordmark.strip_edges().to_upper()
	host.add_child(fp)
	return fp


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return  # nothing is drawn (tests, the simulators)
	if _digits == null:
		var canvas := _Lettering.new()
		for i in DIGITS.length():
			canvas.items.append({"text": DIGITS[i], "rect": Rect2(Vector2(i * DIGIT_CELL.x, 0), DIGIT_CELL),
				"fill": Vector2(0.8, 0.9), "max_stretch": 2.4})
		_digits = await _render(canvas, Vector2i(DIGIT_CELL.x * DIGITS.length(), DIGIT_CELL.y))
	if not is_instance_valid(self):
		return
	material.set_shader_parameter("digits_tex", _digits)
	if text == "":
		return
	if not _wordmarks.has(text):
		var canvas := _Lettering.new()
		canvas.items.append({"text": text, "rect": Rect2(Vector2.ZERO, WORDMARK_SIZE),
			"fill": Vector2(0.96, 0.88), "max_stretch": 1.5, "spacing": 10})
		var tex := await _render(canvas, WORDMARK_SIZE)
		if tex != null:
			_wordmarks[text] = tex
	if is_instance_valid(self) and _wordmarks.has(text):
		material.set_shader_parameter("wordmark_tex", _wordmarks[text])


func _render(canvas: _Lettering, size: Vector2i) -> Texture2D:
	var vp := SubViewport.new()
	vp.size = size
	vp.disable_3d = true
	vp.transparent_bg = false
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.size = size
	vp.add_child(bg)
	canvas.size = size
	vp.add_child(canvas)
	add_child(vp)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	if not is_instance_valid(self):
		return null
	var img := vp.get_texture().get_image()
	vp.queue_free()
	if img == null or img.is_empty():
		return null
	img.convert(Image.FORMAT_L8)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


## Draws each item's text scaled to fill its rect (block lettering).
class _Lettering:
	extends Control
	var items: Array = []

	func _draw() -> void:
		var fs := 160
		for it in items:
			var rect: Rect2 = it["rect"]
			var fill: Vector2 = it["fill"]
			var s := str(it["text"])
			var font := FontVariation.new()
			font.base_font = FieldPaint.FONT
			font.spacing_glyph = int(it.get("spacing", 0))
			var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			var cap := fs * FieldPaint.CAP_HEIGHT
			var sy := rect.size.y * fill.y / cap
			var sx := minf(rect.size.x * fill.x / w, sy * float(it.get("max_stretch", 1.0)))
			var origin := rect.position + Vector2((rect.size.x - w * sx) * 0.5, (rect.size.y + cap * sy) * 0.5)
			draw_set_transform(origin, 0.0, Vector2(sx, sy))
			draw_string(font, Vector2.ZERO, s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
