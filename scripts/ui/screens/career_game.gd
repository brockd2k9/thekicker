extends Node
## Career game day, from the bench. The game plays out as play-by-play
## (GameSim) while you watch. The coach calls you in:
##   field goal / extra point -> the 3D kick scene (field_goal.tscn) with a
##       CareerGameMode and this week's KickProfile; reported as mode "career".
##   kickoff / onside kick    -> the same 3D kick scene in kickoff / onside
##       formation (same swipe, wind and KickProfile; judged by KickoffJudge).
##       Not counted in the field-goal stats.
## When your offense drives into range you're offered a warmup on the sideline
## net (the same 3D kick scene, on the sideline: WarmupMode): good strikes help
## your next kick, skipping it leaves your leg cold.
## Quitting (pause -> Leave Game) goes back to the Hub; the game then restarts
## from its first kick. Kicks already taken still count in My Stats.
## Score bug: one ScoreBugState, set from every sim event, drives the
## Scoreboard (scenes/ui/scoreboard.tscn) on this bench screen and the one in
## the kick scene, so both always show the same score, clock and your line.

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")
const SCOREBOARD := preload("res://scenes/ui/scoreboard.tscn")
const FIELD_TRACKER := preload("res://scenes/ui/field_tracker.tscn")
## Room the HUD keeps clear at the top of the kick scene for the score bug.
const SCORE_BUG_ROOM := 150.0
const KICK_TUNING := "res://tuning/kick_tuning.tres"
## Seconds between play-by-play lines (normal / fast).
const PLAY_DELAY := 1.1
const FAST_DELAY := 0.3
const MAX_FEED_LINES := 80

var career: CareerManager
var sim: GameSim
var _kt: KickTuning

var _layer: CanvasLayer
var _root: Control
## The live score bug's numbers (both Scoreboards bind to it).
var bug := ScoreBugState.new()
## The field tracker's picture of the game (FieldModel.state), from the same events.
var field := FieldModel.new()
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
var _kick_kind := ""
var _kick_yards := 0
## KickTrust working copy: each kick's Coach / Team change, shown as it
## happens (finish_game applies the same steps to the save).
var _trust_view: Dictionary = {}
var _fg_range := 40.0


func _ready() -> void:
	career = GameState.career
	if career == null:
		Screens.go(Screens.CAREER)
		return
	if career.data.phase != CareerManager.PHASE_GAME:
		Screens.go(career.screen_path())
		return
	var kt: Variant = load(KICK_TUNING)
	_kt = kt if kt is KickTuning else KickTuning.new()
	sim = career.new_game_sim(_kt)
	_trust_view = KickTrust.view(career.data)
	_fg_range = career.profile().fg_range
	bug.setup(career.data.team, career.entry().get("opponent", {}), sim.home,
		int(career.data.player.get("number", 0)))
	var gp := Progression.game_params(career.data, career.tuning)
	field.setup(career.data.team, career.entry().get("opponent", {}), sim.home, sim.quarter_seconds(),
		_fg_range, float(gp.get("fg_max", 50)), int(gp.get("kickoff_spot", career.tuning.kickoff_spot_yards)),
		int(gp.get("pat", career.tuning.hs_pat_yards)))
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
	if e.has("poss"):
		bug.set_possession(str(e["poss"]))
	field.apply(e)
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
	CareerScreen.apply_career_look(career)
	var col := UiKit.build_frame(_root, "")
	var c := career.data
	var opp: Dictionary = career.entry().get("opponent", {})

	# The score bug, top left (the column already keeps clear of notches).
	var board: Scoreboard = SCOREBOARD.instantiate()
	board.bind(bug)
	col.add_child(board)
	col.add_child(UiKit.label("%s %s %s" % [CareerScreen.team_name(c.team), "vs" if sim.home else "at",
		CareerScreen.team_name(opp)], 24, UiKit.TEXT, UiTokens.FONT_DISPLAY))
	# The field tracker: ball, drive, down & distance, last play.
	var tracker: FieldTracker = FIELD_TRACKER.instantiate()
	tracker.bind(field.state)
	col.add_child(tracker)

	_status = UiKit.label("", 24, UiKit.MUTED, UiTokens.FONT_CONDENSED)
	col.add_child(_status)
	_feed = UiKit.scroll_list(col)
	_feed.add_theme_constant_override("separation", 6)
	_scroll = _feed.get_parent().get_parent() as ScrollContainer

	var pause := UiKit.button("", _pause, UiKit.SECONDARY, "pause")
	pause.custom_minimum_size.x = 96
	pause.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_fast_b = UiKit.button("Normal", func() -> void:
		_fast = not _fast
		_fast_b.text = "Fast" if _fast else "Normal", UiKit.SECONDARY, "fast")
	var skip := UiKit.button("To My Kick", func() -> void: _skip = true, UiKit.SECONDARY, "next")
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


func _set_score(us: int, them: int, at: float) -> void:
	bug.set_score(us, them)
	bug.set_time(at, sim.quarter_seconds())


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
	_status.text = "ON THE BENCH  ·  FG %d/%d  ·  XP %d/%d%s" % [fg[0], fg[1], xp[0], xp[1], warm.to_upper()]
	bug.set_stats(ScoreBugState.kicker_line(sim.kicks))


func _add_line(text: String, color := Color(0, 0, 0, 0)) -> void:
	# Older lines fade back; the newest reads brightest.
	for ch in _feed.get_children():
		(ch as Control).modulate.a = maxf((ch as Control).modulate.a - 0.12, 0.45)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dot := Panel.new()
	var db := StyleBoxFlat.new()
	db.bg_color = UiKit.ACCENT
	db.skew = Vector2(UiTokens.SKEW * 2.0, 0)
	dot.add_theme_stylebox_override("panel", db)
	dot.custom_minimum_size = Vector2(6, 26)
	dot.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(dot)
	var l := UiKit.label(text, 26, color)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(l)
	_feed.add_child(h)
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
		_warmup_session(e), UiKit.PRIMARY, "toughness"))
	v.add_child(UiKit.button(str(w.get("skip", "Stay on the Bench")), func() -> void:
		modal.queue_free()
		_finish_warmup("skipped")))


## The sideline net in the 3D kick scene: net_kicks strikes, then the result
## ("pure" / "loose") goes to the game sim exactly as before.
func _warmup_session(e: Dictionary) -> void:
	_kick_kind = "warmup"
	var prof := career.profile({"miss_streak": sim.miss_streak})
	_open_kick_scene(WarmupMode.from_tuning(career.tuning), prof, e)


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
		_launch_kick(e), UiKit.PRIMARY, "play")
	v.add_child(go)
	if not OS.has_feature("mobile"):
		go.grab_focus.call_deferred()


## Any coach call: the 3D kick scene, one attempt.
func _launch_kick(e: Dictionary) -> void:
	var prof := career.profile({"miss_streak": sim.miss_streak, "extra_modifiers": _warm()})
	_kick_kind = str(e.get("kind", "fg"))
	_kick_yards = int(e.get("yards", 0))
	var rules: KickoffRules = null
	if _kick_kind in ["kickoff", "onside"]:
		rules = CareerGameMode.kickoff_rules_for(career.tuning, Progression.game_params(career.data, career.tuning), prof)
	_open_kick_scene(CareerGameMode.from_call(CareerGameMode.adjust_call(e, prof), prof.pressure_add, rules), prof, e)


## The kick scene over the bench screen, with this week's profile, the stage's
## look and the live score. e: the sim event (us, them, elapsed).
func _open_kick_scene(mode: KickMode, prof: KickProfile, e: Dictionary) -> void:
	_kick_scene = FIELD_GOAL.instantiate()
	_kick_scene.mode = mode
	_kick_scene.modifiers = prof.to_kick_modifiers()
	_kick_scene.set_look(career.kick_look())
	_layer.visible = false
	_kick_made = false
	GameState.kick_resolved.connect(_on_kick_resolved)
	add_child(_kick_scene)
	# The same score bug, top left over the field (the HUD keeps room for it).
	bug.set_possession("us")
	_kick_scene.hud.make_room_for_score_bug(SCORE_BUG_ROOM)
	_kick_scene.add_child(_score_bug_layer())
	_kick_scene.attempt_finished.connect(_on_attempt_finished)
	_kick_overlay = PlayOverlay.new()
	_kick_overlay.quit_text = "Leave Game"
	_kick_overlay.quit_path = Screens.CAREER_HUB
	add_child(_kick_overlay)


## A CanvasLayer with a Scoreboard bound to `bug`, in the safe area's top-left.
func _score_bug_layer() -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = 8  # over the HUD, under the pause overlay (10)
	var m := MarginContainer.new()
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(m)
	UiKit.apply_safe_area(m, 18)
	var board: Scoreboard = SCOREBOARD.instantiate()
	board.bind(bug)
	m.add_child(board)
	return layer


func _on_kick_resolved(r: KickReport) -> void:
	if r.mode == &"career":
		_kick_made = r.made
		# Score and your line move the moment the kick is judged (the sim
		# hears about it when the kick scene closes; same numbers).
		if _kick_kind in ["fg", "pat"]:
			bug.add_kick(_kick_kind, _kick_yards, r.made)


func _on_attempt_finished(_outcome: KickResult.Outcome) -> void:
	if _kick_kind == "warmup" and _kick_scene.mode.wants_next_kick():
		return  # more strikes to come
	await get_tree().create_timer(1.0).timeout
	if GameState.kick_resolved.is_connected(_on_kick_resolved):
		GameState.kick_resolved.disconnect(_on_kick_resolved)
	var tee_result: Dictionary = _kick_scene.tee_result
	_kick_overlay.queue_free()
	_kick_scene.queue_free()
	_kick_scene = null
	Engine.time_scale = 1.0
	_layer.visible = true
	if _kick_kind == "warmup":
		_finish_warmup(str(tee_result.get("result", "loose")))
		return
	if _kick_kind in ["kickoff", "onside"]:
		sim.resolve_call(tee_result)
	else:
		sim.resolve_call({"made": _kick_made})
		_show_trust(sim.kicks[sim.kicks.size() - 1] if not sim.kicks.is_empty() else {})
	_update_status()
	_busy = false
	_timer = 0.3


## "Coach -4, Team -3 · Missed a go-ahead kick." under the kick's line.
func _show_trust(k: Dictionary) -> void:
	var r := KickTrust.step(_trust_view, k, _fg_range, career.tuning)
	var txt := KickTrust.change_text(float(r["coach"]), float(r["team"]))
	if txt == "" and str(r["reason"]) == "":
		return
	var good := float(r["coach"]) + float(r["team"]) >= 0.0
	_add_line("%s  ·  %s" % [txt, r["reason"]] if txt != "" else str(r["reason"]),
		CareerUi.GOOD_TEXT if good else CareerUi.BAD_TEXT)
	if r["slump"]:
		_add_line("%s has lost faith in your kicking." % Relationships.name_of(career.data, "coach"), CareerUi.BAD_TEXT)


## This half's warmup modifier, as a list for KickProfile ctx.
func _warm() -> Array:
	return [sim.warm_modifier] if sim.warm_modifier != "" else []


# --- end / pause ---------------------------------------------------------------------

func _end_game() -> void:
	_busy = true
	_set_score(sim.score_us, sim.score_them, 4.0 * career.tuning.quarter_minutes * 60.0)
	bug.set_possession("")
	bug.set_final()
	var summary := sim.summary()
	career.finish_game(summary)
	var o := str(summary["outcome"])
	var v := UiKit.modal(_root, "Final")
	v.add_child(CareerUi.result_banner({"W": "WIN!", "L": "LOSS", "T": "TIE"}[o],
		UiKit.GOOD if o == "W" else (UiKit.BAD if o == "L" else UiKit.MUTED), 84))
	var fb := CareerUi.scoreboard(career.data.team, career.entry().get("opponent", {}), str(sim.score_us),
		str(sim.score_them), "FINAL")
	v.add_child(fb["root"])
	UiKit.feedback(&"week_result")
	var b := UiKit.button("Week Results", Screens.go.bind(Screens.CAREER_RESULTS), UiKit.PRIMARY, "next")
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
		_busy = false, UiKit.PRIMARY, "play"))
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
	if modal == null:
		_pause()
