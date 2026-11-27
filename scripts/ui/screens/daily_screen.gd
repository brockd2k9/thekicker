class_name DailyScreen
extends MenuScreen
## Daily Challenge: today's kick (play / retry / done), the streak saver,
## current and longest streak, the week track (7 days in a row pay the
## week's skill points on day 7), and the challenge stats.
## Debug builds add day controls (advance a day, step the clock back, reset).
## Back returns to where it was opened from (main menu or Career hub).

## Where Back goes (set by whoever opens the screen).
static var return_to := Screens.MAIN_MENU

var daily: DailyChallenge
var _busy := false


func _uses_brand() -> bool:
	return true


func _build(col: VBoxContainer) -> void:
	GameState.daily_refresh()
	daily = GameState.daily
	col.add_child(BrandUi.header("Daily Challenge", DailyClock.label(daily.current_day())))
	var list := BrandUi.scroll_list(col)

	if daily.clock_back or daily.is_locked():
		list.add_child(BrandUi.banner("warning", "Device clock changed",
			"Your clock is earlier than the last time you played. The Daily Challenge comes back when the date catches up." \
			if daily.is_locked() else "Your clock moved backward. Claims stay locked to days you haven't played."))
	if daily.saver_offered():
		list.add_child(_saver_card())

	if not daily.is_locked():
		list.add_child(DailyUi.scenario_card(daily, daily.status() == "retry"))
		list.add_child(_today_box())

	list.add_child(BrandUi.section("Streak"))
	list.add_child(DailyUi.streak_tiles(daily))
	list.add_child(BrandUi.section("This week"))
	list.add_child(DailyUi.track(daily))
	list.add_child(BrandUi.text(DailyUi.week_line(daily), "BodyStrong"))
	list.add_child(BrandUi.text("Make %d days in a row to earn the week's skill points. Miss a day and the week starts over." %
		daily.tuning.week_days, "Caption", Brand.GREY))
	list.add_child(BrandUi.text(_where_text(), "Caption", Brand.GREY))

	list.add_child(BrandUi.section("Your challenges"))
	var strip: BrandStatStrip = load("res://scenes/ui/brand/stat_strip.tscn").instantiate()
	list.add_child(strip)
	strip.set_cells([["Done", str(int(daily.stats.get("completed", 0)))],
		["Success", "%d%%" % daily.success_rate() if int(daily.stats.get("played", 0)) > 0 else "-"],
		["Longest", str(daily.longest)], ["Weeks", str(int(daily.stats.get("weeks", 0)))]])
	list.add_child(BrandUi.text("Daily kicks never count in My Stats, career stats or records.", "Caption", Brand.GREY_DIM))

	if OS.is_debug_build():
		list.add_child(BrandUi.section("Debug: day controls"))
		list.add_child(BrandUi.text("Clock shift: %+d day(s). Rewards still pay out; use a test career." % daily.debug_shift_days,
			"Caption", Brand.GREY))
		list.add_child(BrandUi.button_row([BrandUi.button("Prev Day", _debug_shift.bind(-1), "secondary", "back"),
			BrandUi.button("Next Day", _debug_shift.bind(1), "secondary", "next")]))
		list.add_child(BrandUi.button("Reset Daily Data", _debug_reset, "secondary", "trash"))
	add_back_button(col)


## Today's action: Play / Retry (ad) / Claimed / out of kicks, with the
## reward and the countdown to the next challenge.
func _today_box() -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", Brand.SPACE_3)
	var st := daily.status()
	var wait := "New challenge in %s." % DailyClock.countdown_text(daily.seconds_to_reset())
	match st:
		"ready", "retry":
			v.add_child(BrandUi.text(DailyUi.reward_line(daily), "BodyStrong"))
			v.add_child(BrandUi.text(DailyUi.attempts_line(daily), "Caption", Brand.GREY))
			var play := BrandUi.button("Take the Kick" if st == "ready" else "Take Your Retry", _play, "primary", "play")
			v.add_child(play)
			if not OS.has_feature("mobile"):
				play.grab_focus.call_deferred()
		"missed":
			v.add_child(BrandUi.text("Missed. " + _streak_risk_text(), "BodyStrong"))
			v.add_child(_retry_controls())
		"failed":
			v.add_child(BrandUi.banner("info", "Out of kicks today", "%s %s" % [_streak_risk_text(), wait]))
		"done":
			if daily.week_paid_today():
				var row := HBoxContainer.new()
				row.add_theme_constant_override("separation", Brand.SPACE_3)
				row.mouse_filter = Control.MOUSE_FILTER_IGNORE
				row.add_child(BrandUi.chip("Claimed", "outline", "check"))
				var l := BrandUi.text("+%d skill points" % int(daily.today.get("reward", 0)), "Subhead")
				l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				row.add_child(l)
				v.add_child(row)
			else:
				v.add_child(BrandUi.text("Day %d of %d complete" % [daily.week_day_today(), daily.tuning.week_days], "Subhead"))
			v.add_child(BrandUi.text("Done for today. " + wait, "Caption", Brand.GREY))
	return v


## The retry after a miss: the ad button (optional), or why there isn't one.
func _retry_controls() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", Brand.SPACE_2)
	if not daily.retry_offered():
		v.add_child(BrandUi.text("No retries on this platform. New challenge in %s." %
			DailyClock.countdown_text(daily.seconds_to_reset()), "Caption", Brand.GREY))
		return v
	if daily.retry_needs_ad() and not daily.ads.is_ready(AdService.RETRY):
		v.add_child(BrandUi.banner("info", "Retry not available yet", daily.ads.unavailable_text()))
		v.add_child(BrandUi.button("Check Again", func() -> void: Screens.go(Screens.DAILY), "secondary", "repeat"))
		return v
	v.add_child(BrandUi.button("Watch Ad to Retry" if daily.retry_needs_ad() else "Retry", _retry,
		"primary", "play"))
	v.add_child(BrandUi.text("Optional. One retry a day.", "Caption", Brand.GREY))
	return v


func _streak_risk_text() -> String:
	if daily.streak <= 0 or daily.last_completed_day >= daily.current_day():
		return ""
	if daily.status() == "failed":
		return "Your %d-day streak resets at midnight.%s" % [daily.streak,
			"" if daily.saver_used or not daily.tuning.streak_saver_enabled else " Tomorrow you may be able to save it."]
	return "Your %d-day streak ends at midnight unless you make today's kick." % daily.streak


func _saver_card() -> BrandCard:
	var card := BrandUi.card("accent")
	card.content.add_child(BrandUi.text("Streak saver", "Subhead"))
	card.content.add_child(BrandUi.text("You missed a day. %s to bring back your %d-day streak. Once per streak; optional." % [
		"Watch an ad" if daily.ads.platform_has_ads() else "Tap Restore", daily.saver_streak()], "Body"))
	var ready := not daily.ads.platform_has_ads() or daily.ads.is_ready(AdService.SAVER)
	if not ready:
		card.content.add_child(BrandUi.text(daily.ads.unavailable_text(), "Caption", Brand.GREY))
	var restore := BrandUi.button("Watch Ad to Restore" if daily.ads.platform_has_ads() else "Restore Streak", _restore,
		"primary", "repeat")
	restore.disabled = not ready
	var no := BrandUi.button("No Thanks", func() -> void:
		daily.decline_saver()
		GameState.save_game()
		Screens.go(Screens.DAILY), "secondary")
	card.content.add_child(restore)
	card.content.add_child(no)
	return card


func _where_text() -> String:
	var who := GameState.daily_reward_target()
	var banked := daily.pending_sp()
	if who != "":
		return "Weekly skill points go straight to your career: %s." % who
	if banked > 0:
		return "%d skill points banked. They go to your next career (not a retired one)." % banked
	return "Weekly skill points go to your Career Mode player. No career yet? They wait for your next one."


func _play() -> void:
	if daily.can_kick():
		Screens.go(Screens.DAILY_KICK)


func _retry() -> void:
	if _busy:
		return
	_busy = true
	if await DailyScreen.watch_for_retry(daily):
		Screens.go(Screens.DAILY_KICK)
	else:
		_busy = false
		Toast.show_message("NO RETRY", "The ad didn't finish, so no retry this time.", "info")


func _restore() -> void:
	if _busy:
		return
	_busy = true
	var ok := true
	if daily.ads.platform_has_ads():
		ok = await daily.ads.show_rewarded(AdService.SAVER)
	if ok and daily.restore_streak() > 0:
		GameState.save_game()
		Toast.show_message("STREAK RESTORED", "%d days and counting." % daily.streak, "flame")
	Screens.go(Screens.DAILY)


## The retry: a rewarded ad (or free on a no-ads platform with the "free"
## rule). Grants and saves the retry only if the ad finished. Shared with the
## kick screen's result card.
static func watch_for_retry(d: DailyChallenge) -> bool:
	if not d.retry_offered():
		return false
	if d.retry_needs_ad():
		if not await d.ads.show_rewarded(AdService.RETRY):
			return false
	if not d.grant_retry():
		return false
	GameState.save_game()
	return true


func _debug_shift(days: int) -> void:
	daily.debug_shift_days += days
	GameState.daily_refresh()
	GameState.save_game()
	Screens.go(Screens.DAILY)


func _debug_reset() -> void:
	daily.from_dict({})
	GameState.daily_refresh()
	GameState.save_game()
	Screens.go(Screens.DAILY)


func go_back() -> void:
	Screens.go(return_to)
