extends Node
## Career game day, from the bench. The game plays out as play-by-play
## (GameSim) while you watch. The coach calls you in:
##   field goal / extra point -> the real kick scene (field_goal.tscn) with a
##       CareerGameMode and this week's KickProfile; reported as mode "career".
##   kickoff / onside kick    -> the sideline KickPad (same swipe math).
## When your offense drives into range you're offered a warmup on the sideline
## net: good strikes help your next kick, skipping it leaves your leg cold.
## Quitting (pause -> Leave Game) goes back to the Hub; the game then restarts
## from its first kick. Kicks already taken still count in My Stats.

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")
const KICK_TUNING := "res://tuning/kick_tuning.tres"
## Seconds between play-by-play lines (normal / fast).
const PLAY_DELAY := 1.1
const FAST_DELAY := 0.3
const MAX_FEED_LINES := 80

var career: CareerManager
var sim: GameSim
var _kt: KickTuning
var _rng := RandomNumberGenerator.new()

var _layer: CanvasLayer
var _root: Control
var _us_score: Label
var _them_score: Label
var _clock: Label
var _status: Label
var _feed: VBoxContainer
var _scroll: ScrollContainer
var _fast_b: Button

var _timer := 0.0
var _busy := false
var _fast := false
var _skip := false
var _kick_scene: Node
var _kick_overlay: PlayOverlay
var _kick_made := false


func _ready() -> void:
	career = GameState.career
	if career == null:
		Screens.go(Screens.CAREER)
		return
	if career.data.phase != CareerManager.PHASE_GAME:
		Screens.go(career.screen_path())
		return
	_rng.randomize()
	var kt: Variant = load(KICK_TUNING)
	_kt = kt if kt is KickTuning else KickTuning.new()
	sim = career.new_game_sim(_kt)
	_build_ui()
	_set_score(0, 0, 0.0)
	_timer = 0.6


func _exit_tree() -> void:
	if GameState.kick_resolved.is_connected(_on_kick_resolved):
		GameState.kick_resolved.disconnect(_on_kick_resolved)


func _process(delta: float) -> void:
	if sim == null or _busy:
		return
	if _skip:
		# Fast-forward to the next moment that needs you.
		for i in 400:
			if _busy or not _skip:
				break
			_step()
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = FAST_DELAY if _fast else PLAY_DELAY
		_step()


func _step() -> void:
	var e := sim.next()
	match str(e.get("type", "")):
		"play":
			_add_line(str(e["text"]))
			_set_score(int(e.get("us", 0)), int(e.get("them", 0)), float(e.get("elapsed", 0.0)))
		"warmup":
			_skip = false
			_set_score(int(e.get("us", 0)), int(e.get("them", 0)), float(e.get("elapsed", 0.0)))
			_offer_warmup(e)
		"call":
			_skip = false
			_set_score(int(e.get("us", 0)), int(e.get("them", 0)), float(e.get("elapsed", 0.0)))
			_coach_call(e)
		"end":
			_skip = false
			_end_game()


# --- layout -------------------------------------------------------------------------

func _build_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 5
	add_child(_layer)
	_root = Control.new()
	_layer.add_child(_root)
	var col := UiKit.build_frame(_root, "")
	var c := career.data
	var opp: Dictionary = career.entry().get("opponent", {})

	var board := PanelContainer.new()
	col.add_child(board)
	var bh := HBoxContainer.new()
	bh.add_theme_constant_override("separation", 8)
	board.add_child(bh)
	_us_score = _team_block(bh, c.team)
	_clock = CareerUi.centered("Q1 12:00", 30, UiKit.ACCENT)
	_clock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_clock.autowrap_mode = TextServer.AUTOWRAP_OFF
	bh.add_child(_clock)
	_them_score = _team_block(bh, opp)

	_status = UiKit.label("", 24, UiKit.MUTED)
	col.add_child(_status)
	_feed = UiKit.scroll_list(col)
	_scroll = _feed.get_parent().get_parent() as ScrollContainer

	var pause := UiKit.button("II", _pause)
	pause.custom_minimum_size.x = 96
	pause.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_fast_b = UiKit.button("Speed: Normal", func() -> void:
		_fast = not _fast
		_fast_b.text = "Speed: Fast" if _fast else "Speed: Normal")
	var skip := UiKit.button("Skip to My Kick", func() -> void: _skip = true)
	for b in [_fast_b, skip]:
		b.add_theme_font_size_override("font_size", 28)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(pause)
	row.add_child(_fast_b)
	row.add_child(skip)
	col.add_child(row)
	_update_status()


func _team_block(parent: HBoxContainer, t: Dictionary) -> Label:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.custom_minimum_size.x = 170
	parent.add_child(v)
	var stripe := ColorRect.new()
	stripe.color = CareerUi.html_color(str(t.get("colors", ["#888888"])[0]))
	stripe.custom_minimum_size.y = 8
	v.add_child(stripe)
	v.add_child(CareerUi.centered(str(t.get("short", "???")), 28))
	var score := CareerUi.centered("0", 56, Color.WHITE)
	v.add_child(score)
	return score


func _set_score(us: int, them: int, at: float) -> void:
	_us_score.text = str(us)
	_them_score.text = str(them)
	_clock.text = sim.clock_text(at)


func _update_status() -> void:
	var fg := [0, 0]
	var xp := [0, 0]
	for k in sim.kicks:
		var pair: Array = fg if k["kind"] == "fg" else (xp if k["kind"] == "pat" else [])
		if pair.is_empty():
			continue
		pair[1] += 1
		if k.get("made", false):
			pair[0] += 1
	var warm := ""
	if sim.warm_modifier != "":
		warm = "  -  " + str(CareerContent.modifier(sim.warm_modifier).get("label", ""))
	_status.text = "On the bench  -  FG %d/%d  XP %d/%d%s" % [fg[0], fg[1], xp[0], xp[1], warm]


func _add_line(text: String, color := Color.WHITE) -> void:
	_feed.add_child(UiKit.label(text, 26, color))
	while _feed.get_child_count() > MAX_FEED_LINES:
		_feed.get_child(0).free()
	_scroll_down.call_deferred()


func _scroll_down() -> void:
	await get_tree().process_frame
	if is_instance_valid(_scroll):
		_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)


# --- warmup --------------------------------------------------------------------------

func _offer_warmup(e: Dictionary) -> void:
	_busy = true
	var w: Dictionary = CareerContent.game_day().get("warmup", {})
	var v := UiKit.modal(_root, "GET LOOSE")
	var msg := UiKit.label(CareerContent.fill(str(w.get("offer", "")), {"us": career.data.team.get("mascot", ""),
		"spot": e.get("spot", "")}), 30)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(msg)
	v.add_child(CareerUi.centered(str(w.get("offer_hint", "")), 24, UiKit.MUTED))
	var modal := UiKit.modal_root(v)
	v.add_child(UiKit.button(str(w.get("go", "Warm Up")), func() -> void:
		modal.queue_free()
		_net_session(), UiKit.ACCENT.darkened(0.45)))
	v.add_child(UiKit.button(str(w.get("skip", "Stay on the Bench")), func() -> void:
		modal.queue_free()
		_finish_warmup("skipped")))


func _net_session() -> void:
	var t := career.tuning
	var state := {"n": 0, "pure": 0}
	var pad_ui := _open_pad(KickPad.Kind.NET, "SIDELINE NET")
	var pad: KickPad = pad_ui["pad"]
	var hint: Label = pad_ui["hint"]
	var result: Label = pad_ui["result"]
	var hint_text := str(CareerContent.game_day().get("pad", {}).get("net", ""))
	hint.text = CareerContent.fill(hint_text, {"n": 1, "total": t.net_kicks})
	var prof := career.profile({"miss_streak": sim.miss_streak})
	pad.swiped.connect(func(s: Swipe) -> void:
		var k := SidelineKick.read_swipe(s, _kt, prof, _rng)
		if not k["ok"]:
			result.text = str(k["hint"])
			return
		var r := SidelineKick.net(k, t)
		state["n"] += 1
		if r["pure"]:
			state["pure"] += 1
		result.text = str(r["text"])
		pad.fly(1.0 if r["pure"] else 0.75, float(k["aim_deg"])))
	pad.flight_done.connect(func() -> void:
		if int(state["n"]) >= t.net_kicks:
			await get_tree().create_timer(0.6).timeout
			pad_ui["root"].queue_free()
			_finish_warmup(SidelineKick.net_result(int(state["pure"]), t))
			return
		hint.text = CareerContent.fill(hint_text, {"n": int(state["n"]) + 1, "total": t.net_kicks})
		pad.reset())


func _finish_warmup(result: String) -> void:
	sim.set_warmup(result)
	_busy = false
	_timer = 0.0
	_update_status()


# --- coach calls ---------------------------------------------------------------------

func _coach_call(e: Dictionary) -> void:
	_busy = true
	var kind := str(e["kind"])
	var calls: Dictionary = CareerContent.game_day().get("calls", {})
	var v := UiKit.modal(_root, {"fg": "FIELD GOAL", "pat": "EXTRA POINT", "kickoff": "KICKOFF",
		"onside": "ONSIDE KICK"}.get(kind, "YOU'RE UP"))
	var line := UiKit.label(CareerContent.fill(str(calls.get(kind, "")), {"yards": e.get("yards", 0)}), 32)
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(line)
	if kind in ["fg", "pat"]:
		v.add_child(CareerUi.centered(str(e.get("label", "")), 24, UiKit.MUTED))
	if sim.warm_modifier != "":
		v.add_child(CareerUi.modifier_chips(_warm()))
	var modal := UiKit.modal_root(v)
	var go := UiKit.button("Run On", func() -> void:
		modal.queue_free()
		if kind in ["fg", "pat"]:
			_launch_kick(e)
		else:
			_sideline_kick(e), UiKit.ACCENT.darkened(0.45))
	v.add_child(go)
	if not OS.has_feature("mobile"):
		go.grab_focus.call_deferred()


## Field goal / extra point: the real kick scene, one attempt.
func _launch_kick(e: Dictionary) -> void:
	var prof := career.profile({"miss_streak": sim.miss_streak, "extra_modifiers": _warm()})
	_kick_scene = FIELD_GOAL.instantiate()
	_kick_scene.mode = CareerGameMode.from_call(e, prof.pressure_add)
	_kick_scene.modifiers = prof.to_kick_modifiers()
	_kick_scene.set_look(career.kick_look())
	_layer.visible = false
	_kick_made = false
	GameState.kick_resolved.connect(_on_kick_resolved)
	add_child(_kick_scene)
	_kick_scene.hud.set_scoreboard("%s %d  -  %s %d" % [career.data.team.get("short", ""), int(e.get("us", 0)),
		career.entry().get("opponent", {}).get("short", ""), int(e.get("them", 0))], sim.clock_text(float(e.get("elapsed", 0.0))))
	_kick_scene.attempt_finished.connect(_on_attempt_finished)
	_kick_overlay = PlayOverlay.new()
	_kick_overlay.quit_text = "Leave Game"
	_kick_overlay.quit_path = Screens.CAREER_HUB
	add_child(_kick_overlay)


func _on_kick_resolved(r: KickReport) -> void:
	if r.mode == &"career":
		_kick_made = r.made


func _on_attempt_finished(_outcome: KickResult.Outcome) -> void:
	await get_tree().create_timer(1.0).timeout
	if GameState.kick_resolved.is_connected(_on_kick_resolved):
		GameState.kick_resolved.disconnect(_on_kick_resolved)
	_kick_overlay.queue_free()
	_kick_scene.queue_free()
	_kick_scene = null
	Engine.time_scale = 1.0
	_layer.visible = true
	sim.resolve_call({"made": _kick_made})
	_update_status()
	_busy = false
	_timer = 0.3


## This half's warmup modifier, as a list for KickProfile ctx.
func _warm() -> Array:
	return [sim.warm_modifier] if sim.warm_modifier != "" else []


## Kickoff / onside kick on the sideline pad.
func _sideline_kick(e: Dictionary) -> void:
	var t := career.tuning
	var onside := str(e["kind"]) == "onside"
	var pad_ui := _open_pad(KickPad.Kind.ONSIDE if onside else KickPad.Kind.KICKOFF,
		"ONSIDE KICK" if onside else "KICKOFF")
	var pad: KickPad = pad_ui["pad"]
	var result: Label = pad_ui["result"]
	pad.yards_shown = 40.0 if onside else 75.0
	if onside:
		pad.target_min_yards = t.onside_min_yards
		pad.target_max_yards = t.onside_max_yards
	else:
		pad.goal_line_yards = 100.0 - t.kickoff_spot_yards
	var pads: Dictionary = CareerContent.game_day().get("pad", {})
	pad_ui["hint"].text = CareerContent.fill(str(pads.get("onside" if onside else "kickoff", "")),
		{"min": roundi(t.onside_min_yards), "max": roundi(t.onside_max_yards)})
	var prof := career.profile({"miss_streak": sim.miss_streak, "extra_modifiers": _warm()})
	var outcome := {}
	pad.swiped.connect(func(s: Swipe) -> void:
		var k := SidelineKick.read_swipe(s, _kt, prof, _rng)
		if not k["ok"]:
			result.text = str(k["hint"])
			return
		if onside:
			var r := SidelineKick.onside(k, prof, t, _rng)
			outcome.merge({"recovered": r["recovered"], "text": r["text"]})
			result.text = str(r["text"])
			pad.fly(float(r["carry"]), float(k["aim_deg"]))
		else:
			var r := SidelineKick.kickoff(k, prof, t)
			outcome.merge({"quality": r["quality"], "carry": r["carry"], "text": r["text"]})
			result.text = str(r["text"])
			pad.fly(float(r["carry"]), float(k["aim_deg"])))
	pad.flight_done.connect(func() -> void:
		await get_tree().create_timer(0.9).timeout
		pad_ui["root"].queue_free()
		sim.resolve_call(outcome)
		_update_status()
		_busy = false
		_timer = 0.2)


## Full-screen pad overlay: {"root", "pad", "hint", "result"}.
func _open_pad(kind: KickPad.Kind, title: String) -> Dictionary:
	var root := Control.new()
	root.name = "Pad"
	root.theme = UiKit.theme()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.08, 0.05, 0.97)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var safe := MarginContainer.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UiKit.apply_safe_area(safe, UiKit.MARGIN)
	root.add_child(safe)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	safe.add_child(v)
	v.add_child(CareerUi.centered(title, 48, UiKit.ACCENT))
	var hint := CareerUi.centered("", 26)
	v.add_child(hint)
	var pad := KickPad.new()
	pad.kind = kind
	pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(pad)
	var result := CareerUi.centered(" ", 32, UiKit.ACCENT)
	v.add_child(result)
	_root.add_child(root)
	return {"root": root, "pad": pad, "hint": hint, "result": result}


# --- end / pause ---------------------------------------------------------------------

func _end_game() -> void:
	_busy = true
	_set_score(sim.score_us, sim.score_them, 4.0 * career.tuning.quarter_minutes * 60.0)
	_clock.text = "FINAL"
	var summary := sim.summary()
	career.finish_game(summary)
	var o := str(summary["outcome"])
	var v := UiKit.modal(_root, {"W": "WIN!", "L": "LOSS", "T": "TIE"}[o])
	v.add_child(CareerUi.centered("%s %d  -  %s %d" % [career.data.team.get("short", ""), sim.score_us,
		career.entry().get("opponent", {}).get("short", ""), sim.score_them], 44,
		UiKit.GOOD if o == "W" else (UiKit.BAD if o == "L" else Color.WHITE)))
	var b := UiKit.button("Week Results", Screens.go.bind(Screens.CAREER_RESULTS), UiKit.ACCENT.darkened(0.45))
	v.add_child(b)
	if not OS.has_feature("mobile"):
		b.grab_focus.call_deferred()


func _pause() -> void:
	if _busy or _root.get_node_or_null("Modal") != null:
		return
	_busy = true
	var v := UiKit.modal(_root, "PAUSED")
	var modal := UiKit.modal_root(v)
	v.add_child(UiKit.button("Resume", func() -> void:
		modal.queue_free()
		_busy = false))
	v.add_child(UiKit.label("Leaving restarts this game from its first kick next time.", 24, UiKit.MUTED))
	v.add_child(UiKit.button("Leave Game", Screens.go.bind(Screens.CAREER_HUB), UiKit.DANGER))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and _kick_scene == null:
		_back()


func _unhandled_input(event: InputEvent) -> void:
	if _kick_scene == null and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_back()


func _back() -> void:
	var modal := _root.get_node_or_null("Modal")
	if modal == null and _root.get_node_or_null("Pad") == null:
		_pause()
