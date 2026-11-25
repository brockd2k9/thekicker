class_name StageLook
extends Node
## Lights the kick scene: the sun (or the stadium lights at night), its
## shadows, the sky, haze, color grading and bloom, each at the level the
## player's graphics options ask for (VisualQuality). A sibling of the
## scene's WorldEnvironment and Sun; it runs once when the scene is built.
##
## Every feature is independent: switched off, that part of the scene is drawn
## the cheapest way (see VisualQuality). CLASSIC leaves the scene file's own
## environment and sun untouched, exactly as before the visual upgrade.
##
## Frame-rate notes (GL Compatibility renderer):
##   shadows  the scene is drawn once more per split into the shadow map, and
##            every lit pixel samples it (more samples when soft)
##   sky      drawn once into a small cubemap; after that the cost is only
##            the sky pixels on screen (texture taps) and one cubemap lookup
##            per lit pixel
##   fog      a few instructions per pixel
##   grading  the tonemap curve runs inside each material: no extra pass.
##            HIGH adds contrast / saturation, which needs a full-screen pass
##   bloom    downsample and blur passes plus the full-screen pass

const SKY_SHADER := preload("res://shaders/sky_broadcast.gdshader")

## Direction TO the light. Day: a mid-afternoon sun behind the kicker's right
## shoulder, low enough for long shadows across the stripes. Night: the bank
## of stadium lights high behind the kicker.
const SUN_DAY := Vector3(-0.72, 0.6, 0.3)
const SUN_NIGHT := Vector3(0.22, 0.86, 0.46)

## Set before the scene enters the tree (field_goal_game.gd set_look()).
var night := false

var _q: VisualQuality


func _ready() -> void:
	_q = VisualQuality.active()
	var we := get_node_or_null("../WorldEnvironment") as WorldEnvironment
	var sun := get_node_or_null("../Sun") as DirectionalLight3D
	if we == null or sun == null:
		return
	if _q.is_classic():
		_shadow_quality(0)
		if night:
			_classic_night(we, sun)
		return
	_light(sun)
	we.environment = _environment(we.environment)


# --- the key light and its shadows ----------------------------------------------

func _light(sun: DirectionalLight3D) -> void:
	var to_light := (SUN_NIGHT if night else SUN_DAY).normalized()
	sun.global_transform = Transform3D(Basis.looking_at(-to_light, Vector3.UP), Vector3(0.0, 20.0, 0.0))
	var graded := _q.enabled(VisualQuality.GRADING)
	if night:
		sun.light_color = Color(0.93, 0.96, 1.0)
		sun.light_energy = 1.25 if graded else 1.05
	else:
		sun.light_color = Color(1.0, 0.955, 0.87)
		sun.light_energy = 1.5 if graded else 1.2
	var level := _q.level(VisualQuality.SHADOWS)
	sun.shadow_enabled = level > 0
	_shadow_quality(level)
	if level == 0:
		return
	sun.shadow_opacity = 0.8 if night else 0.88
	if level == 1:
		# One shadow map over the first 60 m: every caster is drawn once more,
		# not once per split. Covers both lines and, on most kicks, the posts.
		sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		sun.directional_shadow_max_distance = 60.0
		sun.directional_shadow_blend_splits = false
		sun.shadow_blur = 1.0
	else:
		sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
		sun.directional_shadow_max_distance = 150.0
		sun.directional_shadow_split_1 = 0.07
		sun.directional_shadow_split_2 = 0.2
		sun.directional_shadow_split_3 = 0.45
		sun.directional_shadow_blend_splits = true
		sun.shadow_blur = 1.6
	sun.directional_shadow_fade_start = 0.85


## The shadow map's size and filter are engine-wide: 0 puts the project's own
## values back.
func _shadow_quality(level: int) -> void:
	match level:
		1:
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		2:
			RenderingServer.directional_shadow_atlas_set_size(4096, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		_:
			RenderingServer.directional_shadow_atlas_set_size(
				int(ProjectSettings.get_setting_with_override("rendering/lights_and_shadows/directional_shadow/size")), true)
			RenderingServer.directional_soft_shadow_filter_set_quality(
				int(ProjectSettings.get_setting_with_override(
					"rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality")) as RenderingServer.ShadowQuality)


# --- sky, haze, grading, bloom ----------------------------------------------------

func _environment(old: Environment) -> Environment:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky_level := _q.level(VisualQuality.SKY)
	if sky_level > 0:
		env.sky = _sky(sky_level)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		env.ambient_light_sky_contribution = 1.0
		if night:
			# A night sky gives almost no light: most of the fill is the
			# stadium lights bouncing around the bowl.
			env.ambient_light_sky_contribution = 0.25
			env.ambient_light_color = Color(0.7, 0.76, 0.95)
			env.ambient_light_energy = 0.5
		env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	else:
		# The old flat sky and a flat ambient color.
		env.sky = old.sky.duplicate(true) as Sky
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.85, 0.9, 1.0)
		env.ambient_light_energy = 0.55
		if night:
			_classic_night_sky(env)

	if _q.enabled(VisualQuality.FOG):
		env.fog_enabled = true
		env.fog_light_color = Color(0.07, 0.09, 0.16) if night else Color(0.66, 0.76, 0.9)
		env.fog_light_energy = 1.0
		env.fog_density = 0.0024 if night else 0.0019
		env.fog_sun_scatter = 0.0 if night else 0.12
		env.fog_sky_affect = 0.0

	match _q.level(VisualQuality.GRADING):
		1:
			env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
			env.tonemap_white = 5.0
		2:
			env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
			env.tonemap_white = 5.0
			env.adjustment_enabled = true
			env.adjustment_brightness = 1.0
			env.adjustment_contrast = 1.07
			env.adjustment_saturation = 1.12

	if _q.enabled(VisualQuality.BLOOM):
		env.glow_enabled = true
		env.glow_intensity = 0.55
		env.glow_strength = 1.0
		env.glow_bloom = 0.0
		env.glow_hdr_threshold = 1.0
		env.glow_hdr_scale = 1.6
		env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	return env


func _sky(level: int) -> Sky:
	var mat := ShaderMaterial.new()
	mat.shader = SKY_SHADER
	mat.set_shader_parameter("noise_tex", NoiseTexture.get_texture())
	mat.set_shader_parameter("cloud_detail", 1.0 if level > 1 else 0.0)
	if night:
		mat.set_shader_parameter("top_color", Color(0.008, 0.014, 0.045))
		mat.set_shader_parameter("horizon_color", Color(0.035, 0.05, 0.11))
		mat.set_shader_parameter("haze_color", Color(0.07, 0.085, 0.15))
		mat.set_shader_parameter("ground_color", Color(0.02, 0.03, 0.03))
		mat.set_shader_parameter("cloud_color", Color(0.12, 0.13, 0.19))
		mat.set_shader_parameter("cloud_shade", Color(0.04, 0.05, 0.09))
		mat.set_shader_parameter("cloud_cover", 0.3)
		mat.set_shader_parameter("sun_amount", 0.0)
		mat.set_shader_parameter("stars", 1.0)
		mat.set_shader_parameter("light_dome", Color(0.16, 0.18, 0.26))
	var sky := Sky.new()
	sky.sky_material = mat
	# The sky never changes, so the lighting cubemap is made once.
	sky.process_mode = Sky.PROCESS_MODE_QUALITY
	sky.radiance_size = Sky.RADIANCE_SIZE_256 if level > 1 else Sky.RADIANCE_SIZE_64
	return sky


# --- the look before the visual upgrade -------------------------------------------

## Night games as they were: a dark sky with stars, less ambient light, a
## cooler key light.
func _classic_night(we: WorldEnvironment, sun: DirectionalLight3D) -> void:
	var env := we.environment.duplicate(true) as Environment
	_classic_night_sky(env)
	we.environment = env
	sun.light_color = Color(0.96, 0.97, 1.0)
	sun.light_energy = 1.05


func _classic_night_sky(env: Environment) -> void:
	var sky_mat := env.sky.sky_material as ShaderMaterial
	sky_mat.set_shader_parameter("top_color", Color(0.01, 0.02, 0.06))
	sky_mat.set_shader_parameter("horizon_color", Color(0.09, 0.11, 0.2))
	sky_mat.set_shader_parameter("cloud_color", Color(0.1, 0.11, 0.16))
	sky_mat.set_shader_parameter("cloud_cover", 0.25)
	sky_mat.set_shader_parameter("stars", 1.0)
	env.ambient_light_color = Color(0.7, 0.76, 0.95)
	env.ambient_light_energy = 0.42
	env.fog_light_color = Color(0.08, 0.1, 0.17)
