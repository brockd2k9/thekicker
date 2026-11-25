extends MenuScreen
## Settings: volumes, haptics, aim assist, graphics, privacy, reset stats.
## Changes apply at once and are saved (sliders save when you let go). Graphics
## options are used the next time a kick scene opens.
## PRIVACY appears only when Google's consent SDK says the player must be able
## to change their ad choices (EEA / UK). ADS (DEBUG) is debug builds only.

var _feature_toggles := {}


func _build(col: VBoxContainer) -> void:
	var list := UiKit.scroll_list(col)
	var s := GameState.settings

	list.add_child(UiKit.section("AUDIO"))
	list.add_child(_slider("Sound Volume", s.sound_volume, func(v: float) -> void:
		GameState.settings.sound_volume = v))
	list.add_child(_slider("Music Volume", s.music_volume, func(v: float) -> void:
		GameState.settings.music_volume = v))

	list.add_child(UiKit.section("GAMEPLAY"))
	# "Vibration": the contact pulse and UI buzzes (saved as "haptics"). Phones only.
	list.add_child(_toggle("Vibration", s.haptics, func(on: bool) -> void:
		GameState.settings.haptics = on
		if on:
			Haptics.pulse.call_deferred(40)))  # after the setting is applied
	list.add_child(_toggle("Aim Assist", s.aim_assist, func(on: bool) -> void:
		GameState.settings.aim_assist = on))
	list.add_child(UiKit.label("Aim Assist shows the ring above the crossbar where a straight "
		+ "swipe would go. It doesn't change the kick.", 24, UiKit.MUTED))

	_build_graphics(list)

	if AdManager.privacy_options_required():
		list.add_child(UiKit.section("PRIVACY"))
		list.add_child(UiKit.button("Privacy Options", AdManager.show_privacy_options))
		list.add_child(UiKit.label("Change how ads may use your data.", 24, UiKit.MUTED))

	if OS.is_debug_build():
		_build_ads_debug(list)

	list.add_child(UiKit.section("DATA"))
	list.add_child(UiKit.button("Reset Stats", _confirm_reset, UiKit.DANGER))

	var ver := UiKit.label("Version %s" % ProjectSettings.get_setting("application/config/version", "dev"),
		22, UiKit.MUTED)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(ver)
	add_back_button(col)


## Graphics: the quality preset, one switch per visual feature (so each one's
## frame-rate cost can be checked on this device), the FPS readout and the
## benchmark.
func _build_graphics(list: VBoxContainer) -> void:
	var g := GameState.settings.graphics
	list.add_child(UiKit.section("GRAPHICS"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	list.add_child(row)
	var group := ButtonGroup.new()
	for id in [VisualQuality.LOW, VisualQuality.HIGH]:
		var b := UiKit.button("%s Quality" % id.capitalize(), func() -> void: _set_preset(id))
		b.toggle_mode = true
		b.button_group = group
		b.set_pressed_no_signal(g.preset == id)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	list.add_child(UiKit.label("Low is made for phones, High for desktop. Each effect below can be "
		+ "switched on its own to see what it costs. Changes show on the next kick.", 24, UiKit.MUTED))
	for f in VisualQuality.FEATURES:
		var t := _toggle(str(VisualQuality.LABELS[f]), g.enabled(f), func(on: bool) -> void:
			GameState.settings.graphics.set_enabled(f, on))
		_feature_toggles[f] = t
		list.add_child(t)
	list.add_child(_toggle("Show Frame Rate", g.show_fps, func(on: bool) -> void:
		GameState.settings.graphics.show_fps = on))
	list.add_child(UiKit.button("Graphics Benchmark", func() -> void:
		GameState.settings_updated(true)
		Screens.go(Screens.GRAPHICS_BENCHMARK)))


func _set_preset(id: String) -> void:
	var g := GameState.settings.graphics
	g.set_preset(id)
	for f in _feature_toggles:
		(_feature_toggles[f] as CheckButton).set_pressed_no_signal(g.enabled(f))
	GameState.settings_updated(true)


## Debug builds: the ad mode and state, and buttons to try each kind of ad
## (Stage 1 testing on a device, before the game has ad offers).
func _build_ads_debug(list: VBoxContainer) -> void:
	list.add_child(UiKit.section("ADS (DEBUG)"))
	var status := UiKit.label("", 24, UiKit.MUTED)
	list.add_child(status)
	var refresh := func() -> void:
		status.text = "%s\nRewarded ready: %s\nForced ad: %s" % [AdManager.status_text(),
			"yes" if AdManager.is_rewarded_ready() else "no",
			AdManager.forced_skip_reason() if AdManager.forced_skip_reason() != "" else "would show"]
	refresh.call()
	AdManager.ads_changed.connect(refresh)
	tree_exiting.connect(func() -> void:
		if AdManager.ads_changed.is_connected(refresh):
			AdManager.ads_changed.disconnect(refresh))
	list.add_child(UiKit.button("Test Rewarded Ad", func() -> void:
		var ok: bool = await AdManager.show_rewarded(AdManager.REDO_KICK)
		Toast.show_message("ADS", "Reward earned" if ok else "No reward")))
	list.add_child(UiKit.button("Test Forced Ad (ignores the gap)", func() -> void:
		AdManager.last_ad_end_msec = -1
		var shown: bool = await AdManager.show_interstitial(AdManager.POST_GAME_FORCED)
		Toast.show_message("ADS", "Forced ad shown" if shown else "Forced ad skipped: see log")))
	list.add_child(_toggle_plain("Ads Removed (debug)", AdManager.ads_removed, AdManager.set_ads_removed))
	list.add_child(UiKit.button("Reset Ad Consent", func() -> void:
		AdManager.backend.reset_consent()
		Toast.show_message("ADS", "Consent reset. Restart the app to see the form.")))


## A switch that isn't a GameSettings field (no settings save).
func _toggle_plain(text: String, on: bool, set_value: Callable) -> CheckButton:
	var b := CheckButton.new()
	b.text = text
	b.button_pressed = on
	b.custom_minimum_size.y = UiKit.BUTTON_HEIGHT
	b.add_theme_font_size_override("font_size", 32)
	b.toggled.connect(set_value)
	return b


func go_back() -> void:
	GameState.settings_updated(true)
	super.go_back()


func _slider(text: String, value: float, set_value: Callable) -> Control:
	var p := PanelContainer.new()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	p.add_child(v)
	var h := HBoxContainer.new()
	v.add_child(h)
	var name_label := UiKit.label(text, 30)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(name_label)
	var pct := UiKit.label("%d%%" % roundi(value * 100.0), 30, UiKit.ACCENT)
	pct.autowrap_mode = TextServer.AUTOWRAP_OFF
	h.add_child(pct)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.custom_minimum_size.y = UiTokens.TAP_MIN  # thumb-sized touch target
	v.add_child(slider)
	slider.value_changed.connect(func(x: float) -> void:
		set_value.call(x)
		pct.text = "%d%%" % roundi(x * 100.0)
		GameState.settings_updated(false))
	slider.drag_ended.connect(func(_changed: bool) -> void:
		GameState.settings_updated(true)
		Sfx.play(&"ui_tap"))
	return p


func _toggle(text: String, on: bool, set_value: Callable) -> CheckButton:
	var b := CheckButton.new()
	b.text = text
	b.button_pressed = on
	b.custom_minimum_size.y = UiKit.BUTTON_HEIGHT
	b.add_theme_font_size_override("font_size", 32)
	b.toggled.connect(func(x: bool) -> void:
		set_value.call(x)
		GameState.settings_updated(true))
	return b


func _confirm_reset() -> void:
	UiKit.confirm(self, "Reset Stats?",
		"This clears your session and all-time stats, streaks and best streak. "
		+ "Achievements and settings are kept. This can't be undone.",
		"Reset", func() -> void:
			GameState.reset_stats()
			Toast.show_message("STATS", "All stats reset"))
