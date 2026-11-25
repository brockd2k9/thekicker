extends "res://tests/test_case.gd"
## Graphics options: what each preset turns on, the per-feature switches,
## saving, and the kick scene building under every preset (the old look
## untouched when a feature is off).

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")
const OLD_FIELD_SHADER := preload("res://shaders/field.gdshader")


## A node in the tree to build scenes under (the test runner; the root itself
## is still setting up its children while tests run).
func _host() -> Node:
	var root := (Engine.get_main_loop() as SceneTree).root
	return root.get_child(root.get_child_count() - 1)


func test_presets() -> void:
	var low := VisualQuality.make(VisualQuality.LOW)
	var high := VisualQuality.make(VisualQuality.HIGH)
	for f in VisualQuality.FEATURES:
		check(VisualQuality.LABELS.has(f), "%s has a settings label" % f)
		check(high.enabled(f), "HIGH turns %s on" % f)
		eq(high.level(f), 2, "HIGH draws %s at level 2" % f)
		eq(low.level(f), 1 if low.enabled(f) else 0, "LOW draws %s at level 1 or not at all" % f)
	check(not low.enabled(VisualQuality.BLOOM), "LOW has no bloom (it needs full-screen passes)")
	check(low.enabled(VisualQuality.GRASS) and low.enabled(VisualQuality.PAINT), "LOW keeps the new field")


func test_classic_is_everything_off() -> void:
	var q := VisualQuality.make(VisualQuality.CLASSIC)
	check(q.is_classic(), "classic")
	for f in VisualQuality.FEATURES:
		check(not q.enabled(f), "classic draws no new %s" % f)


func test_feature_switches() -> void:
	var q := VisualQuality.make(VisualQuality.HIGH)
	q.set_enabled(VisualQuality.BLOOM, false)
	check(not q.enabled(VisualQuality.BLOOM), "bloom switched off")
	check(q.enabled(VisualQuality.SHADOWS), "the others stay on")
	eq(q.describe(), "HIGH -bloom", "describe")
	q.set_enabled(VisualQuality.BLOOM, true)
	check(q.overrides.is_empty(), "back to the preset's choice: no override kept")
	q.set_enabled(VisualQuality.FOG, false)
	q.set_preset(VisualQuality.LOW)
	check(q.enabled(VisualQuality.FOG), "picking a preset resets the switches")
	q.set_preset("ultra")
	check(q.preset in [VisualQuality.LOW, VisualQuality.HIGH], "an unknown preset falls back")


func test_saved_with_settings() -> void:
	var s := GameSettings.new()
	s.graphics.set_preset(VisualQuality.LOW)
	s.graphics.set_enabled(VisualQuality.BLOOM, true)
	s.graphics.set_enabled(VisualQuality.SHADOWS, false)
	s.graphics.show_fps = true
	var back := GameSettings.new()
	back.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())))
	eq(back.graphics.preset, VisualQuality.LOW, "preset saved")
	check(back.graphics.enabled(VisualQuality.BLOOM), "a feature switched on is saved")
	check(not back.graphics.enabled(VisualQuality.SHADOWS), "a feature switched off is saved")
	check(back.graphics.show_fps, "frame-rate readout saved")
	# A save from before graphics options: defaults, nothing lost.
	var old := GameSettings.new()
	old.from_dict({"sound_volume": 0.3, "haptics": false})
	eq(old.sound_volume, 0.3, "old settings still load")
	eq(old.graphics.preset, VisualQuality.default_preset(), "graphics start on the device's default")
	# Junk in the save is ignored. CLASSIC is a dev-only look, never a saved one.
	var junk := VisualQuality.new()
	junk.from_dict({"preset": "classic", "overrides": {"lens_flare": true, "fog": false}})
	check(junk.preset != VisualQuality.CLASSIC, "classic can't be loaded from a save")
	check(not junk.overrides.has(&"lens_flare"), "unknown features dropped")
	check(not junk.enabled(VisualQuality.FOG), "known ones kept")


func test_turf_shader_variants() -> void:
	var plain := TurfShader.variant(0, true)
	var low := TurfShader.variant(1, true)
	var high := TurfShader.variant(2, false)
	check(TurfShader.variant(1, true) == low, "variants are built once")
	check(not plain.code.contains("#define TURF_GRASS"), "old grass: no grass code compiled")
	check(low.code.contains("#define TURF_GRASS\n") and not low.code.contains("TURF_GRASS_HIGH"), "LOW grass")
	check(high.code.contains("TURF_GRASS_HIGH") and not high.code.contains("TURF_PAINT"), "HIGH grass, old lines")
	for u in ["goal_z", "hash_x", "endzone_color"]:
		check(FileAccess.get_file_as_string(TurfShader.INCLUDE).contains("uniform") \
			and FileAccess.get_file_as_string(TurfShader.INCLUDE).contains(u), "turf shader keeps '%s'" % u)


## The kick scene builds under every look, by day and by night.
func test_scene_builds_under_every_look() -> void:
	var root := _host()
	for id in [VisualQuality.CLASSIC, VisualQuality.LOW, VisualQuality.HIGH]:
		for night in [false, true]:
			VisualQuality.forced = VisualQuality.make(id)
			var game := FIELD_GOAL.instantiate()
			var st := StadiumSpec.preset("pro_2")
			st.night = night
			game.set_look({"stadium": st})
			root.add_child(game)
			var what := "%s%s" % [id, " night" if night else ""]
			var env := (game.get_node("WorldEnvironment") as WorldEnvironment).environment
			var sun := game.get_node("Sun") as DirectionalLight3D
			var mat := (game.get_node("Field") as FieldBuilder)._field_mat
			check(env != null and env.sky != null, "%s: has a sky" % what)
			if id == VisualQuality.CLASSIC:
				check(mat.shader == OLD_FIELD_SHADER, "%s: the old field shader" % what)
				check(sun.shadow_enabled and not env.glow_enabled, "%s: lighting as before" % what)
				eq(env.tonemap_mode, Environment.TONE_MAPPER_LINEAR, "%s: no grading" % what)
			else:
				check(mat.shader != OLD_FIELD_SHADER, "%s: the turf shader" % what)
				check(sun.shadow_enabled and env.fog_enabled, "%s: shadows and haze" % what)
				eq(env.glow_enabled, id == VisualQuality.HIGH, "%s: bloom only on HIGH" % what)
				eq(env.adjustment_enabled, id == VisualQuality.HIGH, "%s: grading pass only on HIGH" % what)
				eq(env.ambient_light_source, Environment.AMBIENT_SOURCE_SKY, "%s: lit by the sky" % what)
			game.free()
	VisualQuality.forced = null


## Each switch changes only its own part of the scene.
func test_switches_reach_the_scene() -> void:
	var root := _host()
	var off := {}
	for f in VisualQuality.FEATURES:
		off[f] = false
	VisualQuality.forced = VisualQuality.make(VisualQuality.HIGH, off)
	var game := FIELD_GOAL.instantiate()
	root.add_child(game)
	var env := (game.get_node("WorldEnvironment") as WorldEnvironment).environment
	var sun := game.get_node("Sun") as DirectionalLight3D
	check(not sun.shadow_enabled, "shadows off")
	check(not env.fog_enabled and not env.glow_enabled and not env.adjustment_enabled, "haze, bloom, grading off")
	eq(env.ambient_light_source, Environment.AMBIENT_SOURCE_COLOR, "sky lighting off: flat ambient")
	check((game.get_node("Field") as FieldBuilder)._field_mat.shader == OLD_FIELD_SHADER,
		"grass and paint off: the old field")
	game.free()
	# Full paint puts the yard numbers in the shader, so the kickoff adds none of its own.
	for paint in [true, false]:
		VisualQuality.forced = VisualQuality.make(VisualQuality.LOW, {VisualQuality.PAINT: paint})
		var kf := KickoffFormation.new()
		kf.paint_numbers = not VisualQuality.active().enabled(VisualQuality.PAINT)
		var rng := RandomNumberGenerator.new()
		kf.build(KickSituation.KickType.KICKOFF, TeamKit.home(), TeamKit.away(), rng, 0.05, 2.5)
		kf.set_spot(35)
		eq(kf._numbers.size(), 0 if paint else 18, "kickoff number labels with paint %s" % paint)
		kf.free()
	VisualQuality.forced = null


func test_end_zone_lettering_from_the_host() -> void:
	var st := StadiumSpec.new()
	eq(st.endzone_text, "KICKER", "default lettering")
	Stadiums._dress(st, {"mascot": "Falcons", "colors": ["#1f3a8a", "#f2b632"]})
	eq(st.endzone_text, "Falcons", "the host's nickname")
