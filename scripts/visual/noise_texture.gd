class_name NoiseTexture
extends RefCounted
## One small tiling noise texture (256x256, one channel, mipmapped) shared by
## the grass and sky shaders. They sample it at different scales instead of
## computing noise per pixel: cheaper on phone GPUs, and the mipmaps fade the
## detail out with distance so it never shimmers.
## Made once at run time (no texture file in the project).

const SIZE := 256

static var _tex: Texture2D


static func get_texture() -> Texture2D:
	if _tex != null:
		return _tex
	var img: Image
	if ClassDB.class_exists(&"FastNoiseLite"):
		var n := FastNoiseLite.new()
		n.seed = 7
		n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		n.frequency = 0.022
		n.fractal_type = FastNoiseLite.FRACTAL_FBM
		n.fractal_octaves = 5
		n.fractal_gain = 0.55
		img = n.get_seamless_image(SIZE, SIZE, false, false, 0.25)
	if img == null or img.is_empty():
		img = _fallback()
	if img.get_format() != Image.FORMAT_L8:
		img.convert(Image.FORMAT_L8)
	img.generate_mipmaps()
	_tex = ImageTexture.create_from_image(img)
	return _tex


## Engine builds without the noise module: plain random grain, blurred by
## resizing. Rougher than the real thing but it tiles and never fails.
static func _fallback() -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var small := 64
	var bytes := PackedByteArray()
	bytes.resize(small * small)
	for i in bytes.size():
		bytes[i] = rng.randi_range(40, 215)
	var img := Image.create_from_data(small, small, false, Image.FORMAT_L8, bytes)
	img.resize(SIZE, SIZE, Image.INTERPOLATE_CUBIC)
	return img
