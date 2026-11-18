class_name TeamKit
extends RefCounted
## A team's uniform colors, plus a cache so every player on the team shares
## the same materials (cheaper to draw on phones). Fictional teams only.

const JERSEY_SHADER := preload("res://shaders/jersey.gdshader")

var jersey := Color.WHITE
var number_color := Color.WHITE
var trim := Color.BLACK
var pants := Color.WHITE
var pants_stripe := Color.BLACK
var helmet := Color.WHITE
var helmet_stripe := Color.BLACK
var facemask := Color(0.6, 0.6, 0.62)
var socks := Color.WHITE
var gloves := Color.WHITE

var _cache: Dictionary = {}


## Kicking team: navy and gold.
static func home() -> TeamKit:
	var k := TeamKit.new()
	k.jersey = Color(0.1, 0.2, 0.55)
	k.number_color = Color(0.97, 0.97, 0.95)
	k.trim = Color(0.95, 0.72, 0.15)
	k.pants = Color(0.93, 0.9, 0.82)
	k.pants_stripe = Color(0.1, 0.2, 0.55)
	k.helmet = Color(0.08, 0.15, 0.42)
	k.helmet_stripe = Color(0.95, 0.72, 0.15)
	k.facemask = Color(0.75, 0.76, 0.78)
	k.socks = Color(0.1, 0.2, 0.55)
	k.gloves = Color(0.95, 0.95, 0.95)
	return k


## Block team: red and black.
static func away() -> TeamKit:
	var k := TeamKit.new()
	k.jersey = Color(0.72, 0.1, 0.1)
	k.number_color = Color(0.98, 0.98, 0.98)
	k.trim = Color(0.08, 0.08, 0.1)
	k.pants = Color(0.15, 0.15, 0.17)
	k.pants_stripe = Color(0.72, 0.1, 0.1)
	k.helmet = Color(0.95, 0.95, 0.96)
	k.helmet_stripe = Color(0.72, 0.1, 0.1)
	k.facemask = Color(0.1, 0.1, 0.12)
	k.socks = Color(0.08, 0.08, 0.1)
	k.gloves = Color(0.1, 0.1, 0.12)
	return k


## Shared standard material for one part of the uniform.
func mat(key: String, color: Color, roughness: float = 0.8,
		metallic: float = 0.0) -> StandardMaterial3D:
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	_cache[key] = m
	return m


## Each player gets their own jersey material because the number differs.
func jersey_material(number: int) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = JERSEY_SHADER
	m.set_shader_parameter("jersey_color", jersey)
	m.set_shader_parameter("number_color", number_color)
	m.set_shader_parameter("trim_color", trim)
	m.set_shader_parameter("number", number)
	return m
