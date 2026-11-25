class_name TurfShader
extends RefCounted
## The field's shader, built in variants from shaders/turf.gdshaderinc: only
## the parts the graphics options ask for are compiled in, so a feature that
## is switched off costs nothing at all.

const INCLUDE := "res://shaders/turf.gdshaderinc"

static var _cache := {}


## grass_level: 0 = the old flat grass, 1 = LOW, 2 = HIGH. paint: full markings.
static func variant(grass_level: int, paint: bool) -> Shader:
	var key := "%d|%s" % [grass_level, paint]
	if _cache.has(key):
		return _cache[key]
	var code := "shader_type spatial;\n"
	if grass_level >= 1:
		code += "#define TURF_GRASS\n"
	if grass_level >= 2:
		code += "#define TURF_GRASS_HIGH\n"
	if paint:
		code += "#define TURF_PAINT\n"
	code += "#include \"%s\"\n" % INCLUDE
	var shader := Shader.new()
	shader.code = code
	_cache[key] = shader
	return shader
