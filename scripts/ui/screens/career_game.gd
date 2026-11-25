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
## Ads (opt-in, through AdManager; rules and numbers in MonetizationConfig):
##   missed field goal / extra point -> "Watch an Ad to Retry This Kick": the
##       same call again in the kick scene (the miss is taken back from the
##       score bug and never reaches the game sim; it still counts in My Stats);
##   lost game -> "Watch an Ad to Replay This Game": the game starts over from
##       the same checkpoint. The loss is saved as pending first, so closing
##       the app on the offer brings the offer back, not a free replay.
##   Redo counters are saved with the game (CareerManager.game_redos()).
##   Leaving the result screen counts the game for the forced post-game ad
##   (AdManager.after_career_game).
## Score bug: one ScoreBugState, set from every sim event, drives the
## BrandScoreBug (scenes/ui/brand/score_bug.tscn) on this bench screen and the
## compact one over the kick scene, so both always show the same score and clock.

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")
const SCORE_BUG := preload("res://scenes/ui/brand/score_bug.tscn")
const FIELD_STRIP := preload("res://scenes/ui/brand/field_strip.tscn")
const STAT_STRIP := preload("res://scenes/ui/brand/stat_strip.tscn")
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
var _strip: BrandStatStrip
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
## The coach call being kicked (a retry kicks it again) and its last result.
var _last_call: Dictionary = {}
var _last_penalty := 0.0
var _leaving := false
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
	# A loss left on its replay offer: show that offer again (no replay).
	var pending := career.pending_final()
	if not pending.is_empty():
		_busy = true
		_set_score(int(pending.get("us", 0)), int(pending.get("them", 0)),
			4.0 * career.tuning.quarter_minutes * 60.0)
		bug.set_final()
		_add_line("Final.")
		_show_final(pending)


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
	var col := BrandUi.frame(_root, "")
	var c := career.data
	var opp: Dictionary = career.entry().get("opponent", {})

	# The score bug, with the matchup beside it.
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", Brand.SPACE_3)
	col.add_child(top)
	var board: BrandScoreBug = SCORE_BUG.instantiate()
	board.bind(bug)
	top.add_child(board)
	var match_l := BrandUi.text("%s %s %s" % [CareerScreen.team_name(c.team), "vs" if sim.home else "at",
		CareerScreen.team_name(opp)], "Eyebrow")
	match_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	match_l.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	top.add_child(match_l)
	# Your game so far: the kicker stats strip.
	_strip = STAT_STRIP.instantiate()
	col.add_child(_strip)
	# The field strip: ball, drive, down & distance, last play.
	var tracker: BrandFieldStrip = FIELD_STRIP.instantiate()
	tracker.bind(field.state)
	col.add_child(tracker)

	_status = BrandTheme.label("", "Eyebrow")
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_status)
	_feed = BrandUi.scroll_list(col, Brand.SPACE_2)
	_scroll = _feed.get_parent().get_parent() as ScrollContainer

	var pause := BrandUi.button("", _pause, "secondary", "pause")
	pause.custom_minimum_size.x = Brand.TAP + Brand.SPACE_3
	_fast_b = BrandUi.button("Normal", func() -> void:
		_fast = not _fast
		_fast_b.text = ("Fast" if _fast else "Normal").to_upper(), "secondary")
	var skip := BrandUi.button("To My Kick", func() -> void: _skip = true, "secondary")
	var row := BrandUi.button_row([pause, _fast_b, skip])
	pause.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.add_child(row)
	_update_status()


func _set_score(us: int, them: int, at: float) -> void:
	bug.set_score(us, them)
	bug.set_time(at, sim.quarter_seconds())


func _update_status() -> void:
	var line := ScoreBugState.kicker_line(sim.kicks)
	_strip.set_cells([["FG", "%d/%d" % [int(line["fg_made"]), int(line["fg_att"])]],
		["XP", "%d/%d" % [int(line["pat_made"]), int(line["pat_att"])]],
		["Long", str(int(line["long"])) if int(line["long"]) > 0 else "-"], ["Pts", str(int(line["points"]))]])
	var warm := ""
	if sim.warm_modifier != "":
		warm = "  ·  " + str(CareerContent.modifier(sim.warm_modifier).get("label", ""))
	_status.text = "On the bench%s" % warm
	bug.set_stats(line)


func _add_line(text: String, color := Color(0, 0, 0, 0)) -> void:
	# Older lines step back (grey); the newest reads white with a red tick.
	for ch in _feed.get_children():
		(ch as Control).modulate.a = maxf((ch as Control).modulate.a - 0.12, 0.5)
		var old_tick := ch.get_child(0) as ColorRect
		if old_tick != null:
			old_tick.color = Brand.LINE
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", Brand.SPACE_3)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tick := ColorRect.new()
	tick.color = Brand.RED
	tick.custom_minimum_size = Vector2(Brand.RULE, 30)
	tick.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(tick)
	var l := BrandUi.text(text, "Body", color)
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
	var v := BrandUi.modal(_root, "Get loose")
	v.add_child(BrandUi.text(CareerContent.fill(str(w.get("offer", "")), {"us": career.data.team.get("mascot", ""),
		"spot": e.get("spot", "")})))
	v.add_child(BrandUi.text(str(w.get("offer_hint", "")), "Caption"))
	var modal := UiKit.modal_root(v)
	v.add_child(BrandUi.button(str(w.get("go", "Warm Up")), func() -> void:
		modal.queue_free()
		_warmup_session(e), "primary", "energy"))
	v.add_child(BrandUi.button(str(w.get("skip", "Stay on the Bench")), func() -> void:
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
	var v := BrandUi.modal(_root, {"fg": "Field goal", "pat": "Extra point", "kickoff": "Kickoff",
		"onside": "Onside kick"}.get(kind, "You're up"))
	v.add_child(BrandUi.text(CareerContent.fill(str(calls.get(kind, "")), {"yards": e.get("yards", 0)})))
	if kind in ["fg", "pat"] and str(e.get("label", "")) != "":
		v.add_child(BrandUi.chip(str(e.get("label", "")), "red" if "WINNER" in str(e.get("label", "")) else "outline"))
	if sim.warm_modifier != "":
		var f := BrandUi.chip_flow()
		for m in _warm():
			f.add_child(BrandUi.chip(str(CareerContent.modifier(str(m)).get("label", m)), "neutral", "energy"))
		v.add_child(f)
	var modal := UiKit.modal_root(v)
	var go := BrandUi.button("Run On", func() -> void:
		modal.queue_free()
		_launch_kick(e), "primary", "play")
	v.add_child(go)
	if not OS.has_feature("mobile"):
		go.grab_focus.call_deferred()


## Any coach call: the 3D kick scene, one attempt.
func _launch_kick(e: Dictionary) -> void:
	var prof := career.profile({"miss_streak": sim.miss_streak, "extra_modifiers": _warm()})
	_kick_kind = str(e.get("kind", "fg"))
	_kick_yards = int(e.get("yards", 0))
	_last_call = e
	var rules: KickoffRules = null
	if _kick_kind in ["kickoff", "onside"]:
		rules = CareerGameMode.kickoff_rules_for(career.tuning, Progression.game_params(career.data, career.tuning), prof)
	var gm := CareerGameMode.from_call(CareerGameMode.adjust_call(e, prof), prof.pressure_add, rules)
	# Nerves status on the kick's situation line ("... - SHAKY"), field goals / extra points.
	var status := str(prof.nerves.get("status", ""))
	if status != "" and _kick_kind in ["fg", "pat"]:
		gm.situation.label += "  -  " + status.to_upper()
	_open_kick_scene(gm, prof, e)


## The kick scene over the bench screen, with this week's profile, the stage's
## look and the live score. e: the sim event (us, them, elapsed).
func _open_kick_scene(mode: KickMode, prof: KickProfile, e: Dictionary) -> void:
	_kick_scene = FIELD_GOAL.instantiate()
	_kick_scene.mode = mode
	_kick_scene.modifiers = prof.to_kick_modifiers()
	if not prof.nerves.is_empty():
		_kick_scene.nerves_debug = KickNerves.debug_text(prof.nerves, career.tuning)
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


## A CanvasLayer with the compact score bug bound to `bug`, in the safe
## area's top-left (the HUD keeps SCORE_BUG_ROOM clear for it).
func _score_bug_layer() -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = 8  # over the HUD, under the pause overlay (10)
	var m := MarginContainer.new()
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(m)
	UiKit.apply_safe_area(m, 18)
	var board: BrandScoreBug = SCORE_BUG.instantiate()
	board.compact = true
	board.bind(bug)
	board.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	board.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
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
	_last_penalty = _kick_scene.last_shot_penalty
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
		_resume_play()
		return
	if not _kick_made and _kick_kind in MonetizationConfig.REDO_KICK_KINDS \
			and AdManager.redo_offer("kick", career.game_redos())["show"]:
		_offer_kick_retry()
		return
	_resolve_kick()


## A field goal / extra point result goes to the game sim (the same as before ads).
func _resolve_kick() -> void:
	sim.resolve_call({"made": _kick_made,
		"straight": _last_penalty <= career.tuning.nerves_straight_penalty})
	_show_trust(sim.kicks[sim.kicks.size() - 1] if not sim.kicks.is_empty() else {})
	_resume_play()


func _resume_play() -> void:
	_update_status()
	_busy = false
	_timer = 0.3


# --- ad offers (redos) ------------------------------------------------------------------

## After a missed field goal / extra point: retry the same kick (opt-in ad).
func _offer_kick_retry() -> void:
	var used := career.game_redos()
	var what := "%d-yard field goal" % _kick_yards if _kick_kind == "fg" else "extra point"
	var v := BrandUi.modal(_root, "No good")
	v.add_child(BrandUi.text("Want another shot at the %s? Same kick, same situation." % what))
	var modal := UiKit.modal_root(v)
	_redo_controls(v, "kick", func() -> void:
		modal.queue_free()
		bug.undo_missed_kick(_kick_kind)
		_add_line("Second chance: lining up the %s again." % what)
		_launch_kick(_last_call),
		func() -> void:
			modal.queue_free()
			AdManager.decline_redo("kick", used)
			_resolve_kick(),
		"Accept the Miss")


## The redo button (opt-in ad, or free for ad-free buyers), its note, and the
## decline button. The ad button follows AdManager's readiness while shown.
## on_take runs only after the redo was granted (and saved).
func _redo_controls(v: VBoxContainer, kind: String, on_take: Callable, on_decline: Callable,
		decline_text: String) -> void:
	var used := career.game_redos()
	var offer := AdManager.redo_offer(kind, used)
	var take := BrandUi.button(str(offer["button"]), func() -> void: pass, "primary",
		"play" if not offer["free"] else "next")
	var note := BrandUi.text(str(offer["note"]), "Caption", Brand.GREY)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var decline := BrandUi.button(decline_text, on_decline, "secondary", "close")
	var refresh := func() -> void:
		var o := AdManager.redo_offer(kind, used)
		take.disabled = not o["enabled"]
		note.text = str(o["note"])
	refresh.call()
	AdManager.ads_changed.connect(refresh)
	take.tree_exiting.connect(func() -> void:
		if AdManager.ads_changed.is_connected(refresh):
			AdManager.ads_changed.disconnect(refresh))
	take.pressed.connect(func() -> void:
		take.disabled = true
		decline.disabled = true
		var ok: bool = await AdManager.claim_redo(kind, used)
		if ok:
			career.save()
			on_take.call()
			return
		decline.disabled = false
		refresh.call()
		note.text = "No reward this time (the ad was closed early or couldn't play). " + note.text)
	v.add_child(take)
	v.add_child(note)
	v.add_child(decline)


## "Coach -4, Team -3 · Missed a go-ahead kick." under the kick's line.
func _show_trust(k: Dictionary) -> void:
	var r := KickTrust.step(_trust_view, k, _fg_range, career.tuning)
	var txt := KickTrust.change_text(float(r["coach"]), float(r["team"]))
	if txt == "" and str(r["reason"]) == "":
		return
	var good := float(r["coach"]) + float(r["team"]) >= 0.0
	_add_line("%s  ·  %s" % [txt, r["reason"]] if txt != "" else str(r["reason"]),
		Brand.WHITE if good else Brand.RED_HOT)
	if r["slump"]:
		_add_line("%s has lost faith in your kicking." % Relationships.name_of(career.data, "coach"), Brand.RED_HOT)


## This half's warmup modifier, as a list for KickProfile ctx.
func _warm() -> Array:
	return [sim.warm_modifier] if sim.warm_modifier != "" else []


# --- end / pause ---------------------------------------------------------------------

func _end_game() -> void:
	_busy = true
	_set_score(sim.score_us, sim.score_them, 4.0 * career.tuning.quarter_minutes * 60.0)
	bug.set_possession("")
	bug.set_final()
	_show_final(sim.summary())


## The Final card. A loss with a replay offer is saved as pending (not
## finished) until the player replays it or accepts it.
func _show_final(summary: Dictionary) -> void:
	var o := str(summary["outcome"])
	var used := career.game_redos()
	var replay := false
	if o == "L" or (o == "T" and MonetizationConfig.REDO_GAME_ON_TIE):
		replay = AdManager.redo_offer("game", used)["show"]
	if replay:
		career.set_pending_final(summary)
	else:
		career.finish_game(summary)
	var v := BrandUi.modal(_root, "Final")
	var res := BrandTheme.label({"W": "Win", "L": "Loss", "T": "Tie"}[o], "Display", Brand.RED_HOT if o == "L" else Brand.WHITE)
	res.uppercase = true
	v.add_child(res)
	var opp: Dictionary = career.entry().get("opponent", {})
	var score := HBoxContainer.new()
	score.add_theme_constant_override("separation", Brand.SPACE_3)
	v.add_child(score)
	for side in [[career.data.team, int(summary.get("us", 0))], [opp, int(summary.get("them", 0))]]:
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_child(BrandUi.text(CareerScreen.team_name(side[0]), "Eyebrow"))
		var n := BrandTheme.label(str(side[1]), "Display")
		cell.add_child(n)
		score.add_child(cell)
	UiKit.feedback(&"week_result")
	if replay:
		var t := BrandUi.text("Replay this game from the opening kickoff? If you replay, this %s doesn't count."
			% ("loss" if o == "L" else "tie"))
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(t)
		_redo_controls(v, "game", _replay_game, func() -> void:
			if _leaving:
				return  # a second tap must not record the loss twice
			AdManager.decline_redo("game", used)
			career.finish_game(summary)
			_to_results(used), "Accept the Loss" if o == "L" else "Accept the Tie")
		return
	var b := BrandUi.button("Week Results", func() -> void: _to_results(used), "primary", "next")
	v.add_child(b)
	if not OS.has_feature("mobile"):
		b.grab_focus.call_deferred()


## Leaving the result: count the game for the forced ad (shown here when due
## and allowed), then this week's results.
func _to_results(used: Dictionary) -> void:
	if _leaving:
		return
	_leaving = true
	await AdManager.after_career_game(used)
	Screens.go(Screens.CAREER_RESULTS)


func _replay_game() -> void:
	career.replay_game()
	Screens.go(Screens.CAREER_GAME)


func _pause() -> void:
	if _busy or _root.get_node_or_null("Modal") != null:
		return
	_busy = true
	var v := BrandUi.modal(_root, "Paused")
	var modal := UiKit.modal_root(v)
	v.add_child(BrandUi.button("Resume", func() -> void:
		modal.queue_free()
		_busy = false, "primary", "play"))
	v.add_child(BrandUi.text("Leaving restarts this game from its first kick next time.", "Caption"))
	v.add_child(BrandUi.button("Leave Game", Screens.go.bind(Screens.CAREER_HUB), "secondary", "close"))


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
