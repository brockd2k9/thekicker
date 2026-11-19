extends Node
## UI check (dev tool, not part of the game): opens every screen in a real
## state, saves a screenshot of each, and checks the layout:
##   * tap targets (buttons, cards, sliders, toggles, text fields) >= 88 px
##     in the 720-wide base viewport, both ways
##   * no cut-off text: one-line labels and button text that don't fit
##     (including "..." truncation), and text pushed outside the screen
##   * nothing outside the visible screen unless it's inside a scroll list
##
## Run once per window shape (the base viewport is 720x1280; other shapes
## get extra room, see project stretch settings):
##   godot --path . --resolution 720x1280  res://tools/ui_check.tscn -- out=/tmp/shots tag=phone
##   godot --path . --resolution 1080x2400 res://tools/ui_check.tscn -- tag=tall
##   godot --path . --resolution 1536x2048 res://tools/ui_check.tscn -- tag=tablet
##   godot --path . --resolution 1920x1080 res://tools/ui_check.tscn -- tag=desktop
## Options: out=<dir> (screenshots; none = no screenshots), only=hub,results
## Needs a window (not --headless): screens are rendered.
## Prints one line per problem and "UI CHECK <tag>: N problem(s)". Exit code = problems.
##
## Your own saves are backed up first and restored at the end: the career is
## driven with the real CareerManager loop (the balance simulator's choice
## and kick stand-ins) into slot 3 of a scratch save.

const SIM := preload("res://tools/career_sim.gd")
const MIN_TAP := UiTokens.TAP_MIN
## Every screen this tool knows, in the order it captures them.
const ALL := ["main", "career_menu", "tutorial", "new", "new_web", "name_chooser", "hub", "scenario", "scenario_result",
	"outlook", "game", "hud", "hud_result", "results", "stats", "achievements", "settings",
	"career_stats", "debug", "challenge", "season", "recruiting", "college_choice", "hub_college", "draft",
	"hub_pro", "contract", "retired", "pause", "toast"]

var _out := ""
var _tag := ""
var _only: Array = []
var _problems := PackedStringArray()
var _backup := {}
var _sim: Node
var _m: CareerManager


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	get_tree().current_scene = null  # survive scene changes
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	_out = str(args.get("out", ""))
	_tag = str(args.get("tag", "%dx%d" % [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y]))
	_only = str(args.get("only", "")).split(",", false)
	if _out != "":
		DirAccess.make_dir_recursive_absolute(_out)
	_backup_saves()
	Toast.visible = false  # only the "toast" shot shows toasts
	_sim = SIM.new()
	_sim._kt = load("res://tuning/kick_tuning.tres")
	_sim._rng.seed = 11
	await _capture_all()
	_restore_saves()
	for p in _problems:
		print(p)
	print("UI CHECK %s: %d problem(s)" % [_tag, _problems.size()])
	get_tree().quit(_problems.size())


func _want(id: String) -> bool:
	return _only.is_empty() or id in _only


# --- states ---------------------------------------------------------------------------

func _capture_all() -> void:
	GameState.settings.career_tutorial_seen = true
	GameState.stats.attempts = 162
	GameState.stats.makes = 128
	GameState.stats.challenge_best_makes = 14
	var ach := GameState.achievements
	for i in mini(4, AchievementDefs.ALL.size()):
		ach.unlocked[str(AchievementDefs.ALL[i]["id"])] = int(Time.get_unix_time_from_system()) - i * 86400
	_m = CareerManager.create(3, "Jordan Reyes", 7, {"skin": 2, "hair": 1}, "ridgeline")
	_m.rng.seed = 5
	GameState.career = _m
	var c := _m.data

	await _shot("main", Screens.MAIN_MENU)
	await _shot("career_menu", Screens.CAREER)
	await _shot("tutorial", Screens.CAREER_TUTORIAL)
	await _shot("new", Screens.CAREER_NEW)
	# The web/touch name chooser (forced on: this tool runs on desktop).
	if _want("new_web") or _want("name_chooser"):
		CareerNewScreen.force_name_chooser = true
		await _shot("new_web", Screens.CAREER_NEW)
		if _want("name_chooser"):
			var scr := get_tree().current_scene
			if scr != null and scr.has_method("_open_name_chooser"):
				scr._open_name_chooser()
				await _wait(0.6)
				await _capture("name_chooser")
		CareerNewScreen.force_name_chooser = false
	await _shot("achievements", Screens.ACHIEVEMENTS)
	await _shot("settings", Screens.SETTINGS)
	await _shot("stats", Screens.STATS)

	# A few weeks in, then the weekly screens in order.
	GameState.career = _m
	_advance(func() -> bool: return c.week >= 4 and c.phase == CareerManager.PHASE_WEEK_START)
	_m.begin_week()
	_force_locked_scenario("hs_teammate_conflict")
	await _shot("hub", Screens.CAREER_HUB, func() -> void: c.phase = CareerManager.PHASE_WEEK_START,
		func() -> void: c.phase = CareerManager.PHASE_SCENARIO)
	await _shot("scenario", Screens.CAREER_SCENARIO)
	if _want("scenario_result"):
		await _open(Screens.CAREER_SCENARIO)
		var scr := get_tree().current_scene
		if scr != null and scr.has_method("_pick"):
			scr._pick(0)
			await _wait(0.7)
			await _capture("scenario_result")
	else:
		_m.choose(0)
	_advance(func() -> bool: return c.phase == CareerManager.PHASE_OUTLOOK)
	await _shot("outlook", Screens.CAREER_OUTLOOK)
	_m.start_game()
	await _shot("game", Screens.CAREER_GAME, Callable(), Callable(), 2.6)
	await _hud_shots()
	_m.finish_game(_sim._play_game(_m))
	await _shot("results", Screens.CAREER_RESULTS)
	await _shot("career_stats", Screens.CAREER_STATS)
	await _shot("debug", Screens.CAREER_DEBUG)
	await _shot("challenge", Screens.CHALLENGE, Callable(), Callable(), 2.0)
	if _want("pause"):
		await _open(Screens.PRACTICE, 2.0)
		var ov := _find(get_tree().current_scene, "PlayOverlay")
		if ov != null:
			ov.pause()
			await _wait(0.6)
			await _capture("pause")
	if _want("toast"):
		await _open(Screens.CAREER_HUB)
		Toast.visible = true
		Toast.show_message("ACHIEVEMENT UNLOCKED", "Ice in Your Veins", "achievements")
		await _wait(0.9)
		await _capture("toast")
		Toast.visible = false

	_advance(func() -> bool: return c.phase == CareerManager.PHASE_SEASON_END)
	await _shot("season", Screens.CAREER_SEASON)
	_advance(func() -> bool: return c.phase == CareerManager.PHASE_RECRUITING)
	await _shot("recruiting", Screens.CAREER_RECRUITING)
	_advance(func() -> bool: return c.phase == CareerManager.PHASE_COLLEGE_CHOICE)
	await _shot("college_choice", Screens.CAREER_RECRUITING)
	_advance(func() -> bool: return c.stage == CareerData.STAGE_COLLEGE and c.week >= 3 \
		and c.phase == CareerManager.PHASE_WEEK_START)
	await _shot("hub_college", Screens.CAREER_HUB)
	_advance(func() -> bool: return c.phase == CareerManager.PHASE_DRAFT)
	await _shot("draft", Screens.CAREER_DRAFT)
	_advance(func() -> bool: return c.stage == CareerData.STAGE_PRO and c.week >= 3 \
		and c.phase == CareerManager.PHASE_WEEK_START)
	await _shot("hub_pro", Screens.CAREER_HUB)
	_advance(func() -> bool: return c.phase == CareerManager.PHASE_CONTRACT)
	await _shot("contract", Screens.CAREER_CONTRACT)
	if c.phase == CareerManager.PHASE_CONTRACT:
		_m.retire("chose")
	await _shot("retired", Screens.CAREER_RETIRED)


## Plays the career forward with the real rules until `done` (or it retires).
func _advance(done: Callable) -> void:
	var c := _m.data
	var guard := 0
	while not done.call() and c.phase != CareerManager.PHASE_RETIRED and guard < 20000:
		guard += 1
		match c.phase:
			CareerManager.PHASE_WEEK_START:
				_m.begin_week()
			CareerManager.PHASE_SCENARIO, CareerManager.PHASE_OFFSEASON:
				_m.choose(_sim._choose(c, _m.current_scenario(), "always-train", _m.tuning))
			CareerManager.PHASE_OUTLOOK:
				_m.start_game()
			CareerManager.PHASE_GAME:
				_m.finish_game(_sim._play_game(_m))
			CareerManager.PHASE_RESULTS:
				_m.end_week()
			CareerManager.PHASE_SEASON_END:
				_m.end_season()
			CareerManager.PHASE_RECRUITING:
				_m.continue_recruiting()
			CareerManager.PHASE_COLLEGE_CHOICE:
				var opts := _m.college_options()
				if opts.is_empty():
					_m.retire("no_options")
				else:
					_m.choose_college(opts[0])
			CareerManager.PHASE_TRYOUT:
				_m.finish_tryout(int(c.tryout.get("need", 3)))  # pass, to reach the pro screens
			CareerManager.PHASE_DRAFT:
				if str(c.draft_result.get("kind", "")) == "drafted":
					_m.sign_drafted()
				else:
					_m.take_tryout()
			CareerManager.PHASE_CONTRACT:
				_m.contract_continue()
	if not done.call():
		_problems.append("[%s] state: could not reach the wanted career state (phase %s, stage %s)"
			% [_tag, c.phase, c.stage])


## Shows a scenario that has a locked choice (for the locked-card look).
func _force_locked_scenario(id: String) -> void:
	var c := _m.data
	if c.phase == CareerManager.PHASE_SCENARIO and not CareerContent.scenario(id).is_empty():
		c.pending_scenarios[0] = id


func _hud_shots() -> void:
	if not (_want("hud") or _want("hud_result")):
		return
	await _open(Screens.PRACTICE, 2.5)
	await _capture("hud")
	if _want("hud_result"):
		var hud := _find(get_tree().current_scene, "Hud") as Hud
		if hud != null:
			hud.get_node("%SituationLabel").text = "4th quarter, down 2: GAME WINNER"
			hud.show_result(KickResult.Outcome.GOOD, "47 yards")
			await _wait(0.9)
			await _capture("hud_result")


# --- capture + checks -----------------------------------------------------------------

## before/after: run around the capture (e.g. to show a phase, then restore it).
func _shot(id: String, path: String, before := Callable(), after := Callable(), wait := 0.9) -> void:
	if not _want(id):
		return
	if before.is_valid():
		before.call()
	await _open(path, wait)
	await _capture(id)
	if after.is_valid():
		after.call()


func _open(path: String, wait := 0.9) -> void:
	GameState.career = _m
	Screens.go(path)
	# Slow renderers (big windows, software GL) can take a while to switch.
	var t := 0.0
	while t < 8.0:
		await _wait(0.1)
		t += 0.1
		var cur := get_tree().current_scene
		if cur != null and cur.scene_file_path != "" and not ScreenFade._busy:
			break
	await _wait(wait)


func _wait(t: float) -> void:
	await get_tree().create_timer(t, true, false, true).timeout


func _capture(id: String) -> void:
	await RenderingServer.frame_post_draw
	if _out != "":
		var img := get_viewport().get_texture().get_image()
		img.save_png("%s/%s_%s.png" % [_out, _tag, id])
	var scene := get_tree().current_scene
	if scene == null:
		_problems.append("[%s] %s: no screen open" % [_tag, id])
		return
	_check(id, scene)
	var toast_root := Toast.get_child(0) if Toast.get_child_count() > 0 else null
	if id == "toast" and toast_root != null:
		_check(id, toast_root)


func _check(id: String, root: Node) -> void:
	var vp := get_viewport().get_visible_rect()
	for n in _all(root):
		if not (n is Control):
			continue
		var c := n as Control
		if not c.is_visible_in_tree() or c.modulate.a < 0.05:
			continue
		var r := c.get_global_rect()
		var in_scroll := _in_scroll(c)
		var where := "%s %s" % [c.get_class(), _short_path(c)]
		# Tap targets.
		if _is_tappable(c):
			if r.size.y < MIN_TAP - 0.5 or r.size.x < MIN_TAP - 0.5:
				_add(id, "tap target %dx%d < %d: %s %s" % [roundi(r.size.x), roundi(r.size.y), MIN_TAP,
					where, _text_of(c)])
		# Off screen (unless it scrolls).
		if not in_scroll and r.size.x > 1.0 and r.size.y > 1.0 and not (c is Backdrop) \
				and not c.get_parent() is CanvasLayer and _is_content(c):
			if r.position.x < vp.position.x - 1.0 or r.end.x > vp.end.x + 1.0 \
					or r.position.y < vp.position.y - 1.0 or r.end.y > vp.end.y + 1.0:
				_add(id, "outside the screen (%d,%d %dx%d): %s %s" % [roundi(r.position.x),
					roundi(r.position.y), roundi(r.size.x), roundi(r.size.y), where, _text_of(c)])
		# Cut-off text.
		if c is Label:
			_check_label(id, c as Label, where)
		elif c is Button:
			_check_button(id, c as Button, where)


func _check_label(id: String, l: Label, where: String) -> void:
	if l.text.strip_edges() == "" or l.get_parent() is Panel:
		return  # tickers scroll their text inside a clipped strip
	var font := l.get_theme_font("font")
	var fs := l.get_theme_font_size("font_size")
	var w := l.size.x
	if l.autowrap_mode == TextServer.AUTOWRAP_OFF:
		var need := 0.0
		for line in l.text.split("\n"):
			need = maxf(need, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
		if need > w + 1.5:
			_add(id, "text cut off (%d > %d px): %s \"%s\"" % [roundi(need), roundi(w), where, l.text])
	else:
		var min_h := l.get_minimum_size().y
		if l.size.y + 1.5 < min_h:
			_add(id, "wrapped text clipped (%d < %d px): %s \"%s\"" % [roundi(l.size.y), roundi(min_h), where, l.text])
		# A word longer than the label is wide breaks mid-word.
		for word in l.text.split(" ", false):
			if font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > w + 1.5:
				_add(id, "word doesn't fit (%d px wide): %s \"%s\"" % [roundi(w), where, word])
				break


func _check_button(id: String, b: Button, where: String) -> void:
	if b.text == "" or b.autowrap_mode != TextServer.AUTOWRAP_OFF:
		return  # wrapping buttons grow instead of cutting text
	var font := b.get_theme_font("font")
	var fs := b.get_theme_font_size("font_size")
	var sb := b.get_theme_stylebox("normal")
	var avail := b.size.x - (sb.get_margin(SIDE_LEFT) + sb.get_margin(SIDE_RIGHT) if sb else 0.0)
	if b.icon != null:
		avail -= minf(b.icon.get_width(), float(b.get_theme_constant("icon_max_width"))) \
			+ b.get_theme_constant("h_separation")
	var need := 0.0
	for line in b.text.split("\n"):
		need = maxf(need, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
	if need > avail + 1.5:
		_add(id, "button text cut off (%d > %d px): %s \"%s\"" % [roundi(need), roundi(avail), where, b.text])


func _is_tappable(c: Control) -> bool:
	if c is BaseButton or c is Slider or c is LineEdit:
		return true
	# Career cards: panels that pass input and react to taps.
	return c is PanelContainer and c.mouse_filter == Control.MOUSE_FILTER_PASS \
		and not c.gui_input.get_connections().is_empty()


## Containers and decorations that may legitimately hang off the edge.
func _is_content(c: Control) -> bool:
	return c is Label or c is BaseButton or c is PanelContainer or c is TextureRect or c is Slider


func _in_scroll(c: Node) -> bool:
	var n := c.get_parent()
	while n != null:
		if n is ScrollContainer:
			return true
		n = n.get_parent()
	return false


func _all(n: Node) -> Array:
	var out := [n]
	for ch in n.get_children():
		out.append_array(_all(ch))
	return out


func _find(root: Node, cls: String) -> Node:
	if root == null:
		return null
	for n in _all(root):
		if n.get_class() == cls or (n.get_script() != null and n.get_script().get_global_name() == cls):
			return n
	return null


func _short_path(c: Node) -> String:
	var parts := PackedStringArray()
	var n := c
	for i in 3:
		if n == null:
			break
		parts.insert(0, str(n.name))
		n = n.get_parent()
	return "/".join(parts)


func _text_of(c: Control) -> String:
	if c is Button and (c as Button).text != "":
		return "\"%s\"" % (c as Button).text
	if c is Label:
		return "\"%s\"" % (c as Label).text
	return ""


func _add(id: String, msg: String) -> void:
	var line := "[%s] %s: %s" % [_tag, id, msg]
	if not line in _problems:
		_problems.append(line)


# --- saves ----------------------------------------------------------------------------

func _backup_saves() -> void:
	var d := DirAccess.open("user://")
	if d == null:
		return
	for f in d.get_files():
		if f.ends_with(".json") or f.ends_with(".bak") or f.ends_with(".bad") or f.ends_with(".tmp"):
			_backup[f] = FileAccess.get_file_as_bytes("user://" + f)


func _restore_saves() -> void:
	GameState.career = null
	var d := DirAccess.open("user://")
	if d == null:
		return
	for f in d.get_files():
		if (f.ends_with(".json") or f.ends_with(".bak") or f.ends_with(".bad") or f.ends_with(".tmp")) \
				and not _backup.has(f):
			d.remove(f)
	for f in _backup:
		var fa := FileAccess.open("user://" + f, FileAccess.WRITE)
		if fa != null:
			fa.store_buffer(_backup[f])
			fa.close()
