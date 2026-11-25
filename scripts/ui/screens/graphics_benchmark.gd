extends MenuScreen
## Settings > Graphics Benchmark: measures what each visual feature costs on
## THIS device. It builds the real kick scene (a full stadium, both lines,
## wind blowing) once per row, lets it settle, and times a couple of seconds
## of frames:
##   Before the upgrade     the scene as it was drawn before the visual upgrade
##   Everything off         the new look with every feature switched off
##   + <feature>            everything off, plus that one feature (LOW, then
##                          HIGH where the two differ)
##   LOW / HIGH preset      the presets as shipped
## The cost column is each row's frame time minus "Everything off".
##
## Phones lock the frame rate to the screen (60 or 120 fps), which hides any
## cost that still fits in a frame. When the first pass comes back locked, a
## second pass draws the 3D scene at four times the pixels so the differences
## show; those numbers rank the features, they are not real frame times.
##
## Results are shown, saved to user://graphics_benchmark.txt and can be copied.
## Command line (prints the table and quits):
##   godot --path . res://scenes/screens/graphics_benchmark.tscn -- auto=1 seconds=3

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")
const REPORT_PATH := "user://graphics_benchmark.txt"
const SETTLE_SEC := 0.9
## A row is "locked to the screen" within this share of the refresh rate.
const LOCKED_SHARE := 0.96

var _measure_sec := 2.2
var _auto := false
## stress=1 on the command line: always run the 4x-pixels pass (to test it).
var _force_second_pass := false
var _running := false
var _col: VBoxContainer
var _body: VBoxContainer
var _scene: Node
var _progress: CanvasLayer
var _progress_label: Label
var _saved_vsync := DisplayServer.VSYNC_ENABLED
var _saved_max_fps := 0
var _report := ""


class BenchMode:
	extends KickMode

	func id() -> StringName:
		return &"benchmark"

	func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
		var s := KickSituation.new()
		s.distance_yards = 42
		s.wind_mph = 9.0
		s.label = "Benchmark"
		wind.set_conditions(rng, tuning, 9.0, 0.0)
		return s


func _build(col: VBoxContainer) -> void:
	_col = col
	for a in OS.get_cmdline_user_args():
		if a == "auto=1":
			_auto = true
		elif a == "stress=1":
			_force_second_pass = true
		elif a.begins_with("seconds="):
			_measure_sec = maxf(float(a.substr(8)), 0.3)
	_body = UiKit.scroll_list(col)
	_body.add_child(UiKit.label("Times every graphics feature on this device: the kick scene is "
		+ "drawn %d times, a few seconds each. It takes about a minute. " % _rows().size()
		+ "Close other apps and leave the screen alone while it runs.", 28))
	_body.add_child(UiKit.primary("Start", _run))
	add_back_button(col)
	if _auto:
		_run.call_deferred()


func go_back() -> void:
	Screens.go(Screens.SETTINGS)


func _exit_tree() -> void:
	_restore()


## [label, VisualQuality] per row.
func _rows() -> Array:
	var none := {}
	for f in VisualQuality.FEATURES:
		none[f] = false
	var rows: Array = [
		["Before the upgrade", VisualQuality.make(VisualQuality.CLASSIC)],
		["Everything off", VisualQuality.make(VisualQuality.LOW, none)],
	]
	for preset in [VisualQuality.LOW, VisualQuality.HIGH]:
		for f in VisualQuality.FEATURES:
			# Only HIGH has bloom; fog and paint are the same on both.
			if preset == VisualQuality.LOW and f == VisualQuality.BLOOM:
				continue
			if preset == VisualQuality.HIGH and f in [VisualQuality.FOG, VisualQuality.PAINT]:
				continue
			var one := none.duplicate()
			one[f] = true
			var tag := "" if f in [VisualQuality.FOG, VisualQuality.PAINT, VisualQuality.BLOOM] \
				else " (%s)" % preset.capitalize()
			rows.append(["+ %s%s" % [VisualQuality.LABELS[f], tag], VisualQuality.make(preset, one)])
		rows.append(["%s preset" % preset.to_upper(), VisualQuality.make(preset)])
	return rows


func _run() -> void:
	if _running:
		return
	_running = true
	_saved_vsync = DisplayServer.window_get_vsync_mode()
	_saved_max_fps = Engine.max_fps
	# Uncapped where the platform allows it (most phones ignore this).
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	visible = false
	_show_progress()
	var rows := _rows()
	var refresh := DisplayServer.screen_get_refresh_rate()
	if not is_finite(refresh) or refresh < 1.0:
		refresh = 60.0
	var passes: Array = [await _pass(rows, 1.0, "")]
	if not is_inside_tree():
		return
	# Locked to the screen: measure again with four times the pixels.
	var off_ms: float = passes[0][1]
	if 1000.0 / off_ms >= refresh * LOCKED_SHARE or _force_second_pass:
		passes.append(await _pass(rows, 2.0, "4x pixels: "))
		if not is_inside_tree():
			return
	_restore()
	_running = false
	visible = true
	_show_results(rows, passes, refresh)


## Frame time (ms) of every row with the 3D scene drawn at `scale` times the
## resolution each way.
func _pass(rows: Array, scale: float, tag: String) -> Array:
	var out: Array = []
	get_viewport().scaling_3d_scale = scale
	for i in rows.size():
		_progress_label.text = "%s%d / %d\n%s" % [tag, i + 1, rows.size(), rows[i][0]]
		out.append(await _measure(rows[i][1]))
		if not is_inside_tree():
			return out
	get_viewport().scaling_3d_scale = 1.0
	return out


func _measure(q: VisualQuality) -> float:
	VisualQuality.forced = q
	var scene := FIELD_GOAL.instantiate()
	scene.mode = BenchMode.new()
	# Hold the pre-snap picture: nothing is kicked, so no stats, sounds or buzzes.
	scene.tuning = scene.tuning.duplicate()
	scene.tuning.snap_delay = 100000.0
	scene.set_look({"stadium": StadiumSpec.preset("pro_2")})
	add_child(scene)
	_scene = scene
	scene.swipe_input.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(SETTLE_SEC, true, false, true).timeout
	var frames := 0
	var start := Time.get_ticks_usec()
	while is_inside_tree() and Time.get_ticks_usec() - start < int(_measure_sec * 1000000.0):
		await get_tree().process_frame
		frames += 1
	var ms := float(Time.get_ticks_usec() - start) / 1000.0 / maxf(frames, 1)
	if is_instance_valid(scene):
		scene.queue_free()
	_scene = null
	if is_inside_tree():
		await get_tree().process_frame
	return ms


func _show_progress() -> void:
	_progress = CanvasLayer.new()
	_progress.layer = 50
	var block := Control.new()  # swallows touches while it runs
	block.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	block.theme = UiKit.theme()
	_progress.add_child(block)
	_progress_label = UiKit.label("", 32, Brand.WHITE, UiTokens.FONT_DISPLAY)
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_progress_label.add_theme_constant_override("outline_size", 10)
	_progress_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_progress_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_progress_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_progress_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_progress_label.custom_minimum_size.x = 640
	_progress_label.position.y -= 220
	block.add_child(_progress_label)
	add_child(_progress)


func _restore() -> void:
	VisualQuality.forced = null
	if is_instance_valid(_scene):
		_scene.queue_free()
	if is_instance_valid(_progress):
		_progress.queue_free()
	if _running:
		DisplayServer.window_set_vsync_mode(_saved_vsync)
		Engine.max_fps = _saved_max_fps
		if get_viewport() != null:
			get_viewport().scaling_3d_scale = 1.0


func _show_results(rows: Array, passes: Array, refresh: float) -> void:
	for c in _body.get_children():
		c.queue_free()
	var size := DisplayServer.window_get_size()
	var lines := PackedStringArray()
	lines.append("Kicker %s graphics benchmark" % ProjectSettings.get_setting("application/config/version", "dev"))
	lines.append("%s %s | %s | %dx%d @ %d Hz" % [OS.get_name(), OS.get_model_name(),
		RenderingServer.get_video_adapter_name(), size.x, size.y, roundi(refresh)])
	var locked: bool = passes.size() > 1 and not _force_second_pass
	for pi in passes.size():
		var ms: Array = passes[pi]
		var title := "FRAME TIME" if pi == 0 else "AT 4X PIXELS (RANKING ONLY)"
		_body.add_child(UiKit.section(title))
		lines.append("")
		lines.append(title)
		lines.append("%-28s %7s %8s %8s" % ["", "fps", "ms", "cost ms"])
		var base: float = ms[1]
		for i in rows.size():
			var cost: float = ms[i] - base
			var cost_text := "" if i == 1 else "%+.1f ms" % cost
			var value := "%d fps  %.1f ms" % [roundi(1000.0 / ms[i]), ms[i]]
			_body.add_child(_row(str(rows[i][0]), value, cost_text))
			lines.append("%-28s %7d %8.2f %8s" % [rows[i][0], roundi(1000.0 / ms[i]), ms[i],
				"" if i == 1 else "%+.2f" % cost])
		if pi == 0 and locked:
			var note := ("This device locks the frame rate to its %d Hz screen, and the scene fits in a "
				+ "frame with everything off, so costs under the lock don't show here. Any row "
				+ "below %d fps is a setting this device can't hold. The second table ranks the features.") \
				% [roundi(refresh), roundi(refresh * LOCKED_SHARE)]
			_body.add_child(UiKit.label(note, 24, UiKit.MUTED))
			lines.append(note)
	_report = "\n".join(lines)
	var f := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(_report + "\n")
	print(_report)
	_body.add_child(UiKit.button("Copy Results", func() -> void:
		DisplayServer.clipboard_set(_report)
		Toast.show_message("BENCHMARK", "Results copied")))
	_body.add_child(UiKit.button("Run Again", _run))
	if _auto:
		get_tree().quit()


## Name on the left; frame rate and its cost on the right.
func _row(text: String, value: String, cost: String) -> Control:
	var p := PanelContainer.new()
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	p.add_child(h)
	var n := UiKit.label(text, 26)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(n)
	var v := VBoxContainer.new()
	h.add_child(v)
	var a := UiKit.line(value, 26, Brand.WHITE)
	a.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(a)
	if cost != "":
		var b := UiKit.line(cost, 22, UiKit.MUTED)
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		v.add_child(b)
	return p
