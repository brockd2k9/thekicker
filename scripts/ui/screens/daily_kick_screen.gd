extends Node
## The Daily Challenge kick: a broadcast-style intro card (situation, kick,
## wind, weather, field, pressure, reward), then the kick scene with DailyMode,
## then the result card: success (red flash, the reward counting up, CLAIMED)
## or a miss (Watch Ad to Retry once a day, or done for today).
## The kick counts the moment it's struck (DailyChallenge.begin_kick, saved),
## so closing the game mid-flight is a miss, not a free retry. Its result is
## judged here and claimed and saved in one write. Daily kicks report with
## mode &"daily", which never touches My Stats, career stats or records.

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")

var daily: DailyChallenge
var _sc: Dictionary
var _game: Node
var _overlay: PlayOverlay
var _intro: Control
var _made := false
var _judged := false
var _busy := false


func _ready() -> void:
	GameState.daily_refresh()
	daily = GameState.daily
	if not daily.can_kick():
		Screens.go(Screens.DAILY)
		return
	_sc = daily.scenario()
	_show_intro()


func _exit_tree() -> void:
	if GameState.kick_resolved.is_connected(_on_kick_resolved):
		GameState.kick_resolved.disconnect(_on_kick_resolved)


# --- intro card ----------------------------------------------------------------------------

func _show_intro() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	_intro = Control.new()
	_intro.name = "Intro"
	layer.add_child(_intro)
	var col := BrandUi.frame(_intro)
	col.add_child(UiKit.expanding_spacer())
	var card := DailyUi.scenario_card(daily, daily.status() == "retry")
	col.add_child(card)
	col.add_child(BrandUi.text(DailyUi.reward_line(daily), "BodyStrong"))
	col.add_child(BrandUi.text(DailyUi.attempts_line(daily), "Caption", Brand.GREY))
	col.add_child(UiKit.expanding_spacer())
	var back := BrandUi.button("Back", func() -> void: Screens.go(Screens.DAILY), "secondary", "back")
	var kick := BrandUi.button("Kick", _start_kick, "primary", "football")
	col.add_child(BrandUi.button_row([back, kick]))
	kick.size_flags_stretch_ratio = 2.0
	BrandMotion.swap(card)
	if not OS.has_feature("mobile"):
		kick.grab_focus.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if _intro != null and is_instance_valid(_intro) and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		Screens.go(Screens.DAILY)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and _intro != null and is_instance_valid(_intro):
		Screens.go(Screens.DAILY)


# --- the kick ------------------------------------------------------------------------------

func _start_kick() -> void:
	if _game != null:
		return
	(_intro.get_parent() as CanvasLayer).queue_free()
	_intro = null
	_game = FIELD_GOAL.instantiate()
	_game.mode = DailyMode.new(_sc)
	_game.modifiers = DailyScenario.modifiers(_sc)
	add_child(_game)
	_overlay = PlayOverlay.new()
	_overlay.quit_text = "Leave Challenge"
	_overlay.quit_path = Screens.DAILY
	add_child(_overlay)
	_game.hud.set_scoreboard("DAILY  ·  %s" % DailyClock.label(int(_sc["day"])),
		"STREAK %d" % daily.streak)
	GameState.kick_resolved.connect(_on_kick_resolved)
	_game.kick_struck.connect(_on_struck)
	_game.attempt_finished.connect(_on_attempt_finished)


## The kick counts from here (saved), whatever happens next.
func _on_struck() -> void:
	if daily.begin_kick():
		GameState.save_game()


func _on_kick_resolved(r: KickReport) -> void:
	if r.mode == DailyChallenge.MODE:
		_made = r.made


func _on_attempt_finished(_o: KickResult.Outcome) -> void:
	if _judged:
		return
	_judged = true
	var tee: Dictionary = _game.tee_result
	var success := DailyScenario.success(_sc, _made, tee)
	# A block before the kick (the clock ran out) is a struck kick too.
	if bool(daily.today.get("struck", false)) == false and daily.can_kick():
		daily.begin_kick()
	var sp := daily.finish_kick(success)
	GameState.save_game()  # the result and the claim, one write
	var delivered := GameState.daily_deliver() if sp > 0 else {}
	_overlay.set_pause_enabled(false)
	if success:
		_success_card(sp, delivered)
	else:
		_miss_card(tee)


# --- result cards --------------------------------------------------------------------------

func _success_card(sp: int, delivered: Dictionary) -> void:
	Sfx.play(&"good")
	UiKit.feedback(&"achievement")
	var v := BrandUi.modal(_overlay.root, "Challenge Complete")
	var modal := UiKit.modal_root(v)
	BrandMotion.flash(modal)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_3)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var big := BrandTheme.label("+0", "Hero", Brand.RED_HOT)
	row.add_child(big)
	var cap := VBoxContainer.new()
	cap.alignment = BoxContainer.ALIGNMENT_CENTER
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap.add_child(BrandTheme.label("Skill", "Subhead"))
	cap.add_child(BrandTheme.label("points", "Subhead"))
	row.add_child(cap)
	v.add_child(row)
	BrandMotion.count_up(big, 0.0, float(sp), "+%d", 0.7)
	var chips := BrandUi.chip_flow()
	chips.alignment = FlowContainer.ALIGNMENT_CENTER
	chips.add_child(BrandUi.chip("Claimed", "outline", "check"))
	var bonus := daily.tuning.bonus_for(daily.streak)
	if bonus > 0:
		chips.add_child(BrandUi.chip("Day %d bonus +%d" % [daily.streak, bonus], "red", "star"))
	v.add_child(chips)
	v.add_child(UiKit.stat_row("Streak", "%d day%s" % [daily.streak, "" if daily.streak == 1 else "s"], UiKit.ACCENT))
	v.add_child(UiKit.stat_row("Longest", "%d day%s" % [daily.longest, "" if daily.longest == 1 else "s"]))
	var where := "Added to %s's skill points." % str(delivered["name"]) if not delivered.is_empty() \
		else "Banked: they go to your next career."
	v.add_child(BrandUi.text(where, "Caption", Brand.GREY))
	var menu := BrandUi.button("Menu", Screens.go.bind(Screens.MAIN_MENU), "secondary", "home")
	var track := BrandUi.button("Streak", Screens.go.bind(Screens.DAILY), "primary", "flame")
	v.add_child(BrandUi.button_row([menu, track]))
	track.size_flags_stretch_ratio = 1.5
	if not OS.has_feature("mobile"):
		track.grab_focus.call_deferred()


func _miss_card(tee: Dictionary) -> void:
	Sfx.play(&"run_over")
	var st := daily.status()
	var v := BrandUi.modal(_overlay.root, "Missed" if st == "missed" else "Out of Kicks")
	var why := str(tee.get("banner", "")) if not tee.is_empty() else ""
	if why != "":
		v.add_child(BrandUi.text(why, "Subhead", Brand.RED_HOT))
	if DailyScenario.is_tee(_sc):
		v.add_child(BrandUi.text("Goal: " + DailyScenario.goal_text(_sc), "Caption", Brand.GREY))
	var risk := ""
	if daily.streak > 0 and daily.last_completed_day < daily.current_day():
		risk = ("Your %d-day streak ends at midnight unless you make it today." if daily.can_kick() or daily.retry_offered()
			else "Your %d-day streak resets at midnight.") % daily.streak
	var buttons: Array = []
	if st == "missed" and daily.retry_offered():
		if not daily.retry_needs_ad() or daily.ads.is_ready(AdService.RETRY):
			v.add_child(BrandUi.text(("One retry left today. Watching the ad is optional. " if daily.retry_needs_ad()
				else "One retry left today. ") + risk, "Body"))
			# Stacked full width: the ad button's text needs the room.
			var retry := BrandUi.button("Watch Ad to Retry" if daily.retry_needs_ad() else "Retry", _retry,
				"primary", "play")
			v.add_child(retry)
			v.add_child(BrandUi.button("Done for Now", Screens.go.bind(Screens.DAILY), "secondary"))
			if not OS.has_feature("mobile"):
				retry.grab_focus.call_deferred()
			return
		else:
			v.add_child(BrandUi.text(daily.ads.unavailable_text() + " Your retry waits on the Daily Challenge screen until midnight.", "Body"))
			buttons.append(BrandUi.button("OK", Screens.go.bind(Screens.DAILY), "primary"))
	else:
		v.add_child(BrandUi.text(("That's it for today. " + risk).strip_edges() + " New challenge in %s." %
			DailyClock.countdown_text(daily.seconds_to_reset()), "Body"))
		buttons.append(BrandUi.button("Menu", Screens.go.bind(Screens.MAIN_MENU), "secondary", "home"))
		buttons.append(BrandUi.button("Streak", Screens.go.bind(Screens.DAILY), "primary", "flame"))
	var row := BrandUi.button_row(buttons)
	v.add_child(row)
	if buttons.size() == 2:
		(buttons[1] as Control).size_flags_stretch_ratio = 1.6
	if not OS.has_feature("mobile"):
		(buttons.back() as Control).grab_focus.call_deferred()


func _retry() -> void:
	if _busy:
		return
	_busy = true
	if await DailyScreen.watch_for_retry(daily):
		Screens.go(Screens.DAILY_KICK)
	else:
		_busy = false
		Toast.show_message("NO RETRY", "The ad didn't finish, so no retry this time.", "info")
