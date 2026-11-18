extends MenuScreen
## Settings: volumes, haptics, aim assist, reset stats. Changes apply at once
## and are saved (sliders save when you let go).


func _build(col: VBoxContainer) -> void:
	var list := UiKit.scroll_list(col)
	var s := GameState.settings

	list.add_child(UiKit.section("AUDIO"))
	list.add_child(_slider("Sound Volume", s.sound_volume, func(v: float) -> void:
		GameState.settings.sound_volume = v))
	list.add_child(_slider("Music Volume", s.music_volume, func(v: float) -> void:
		GameState.settings.music_volume = v))

	list.add_child(UiKit.section("GAMEPLAY"))
	list.add_child(_toggle("Haptics", s.haptics, func(on: bool) -> void:
		GameState.settings.haptics = on
		if on:
			Haptics.pulse(40)))
	list.add_child(_toggle("Aim Assist", s.aim_assist, func(on: bool) -> void:
		GameState.settings.aim_assist = on))
	list.add_child(UiKit.label("Aim Assist shows the ring above the crossbar where a straight "
		+ "swipe would go. It doesn't change the kick.", 24, UiKit.MUTED))

	list.add_child(UiKit.section("DATA"))
	list.add_child(UiKit.button("Reset Stats", _confirm_reset, UiKit.DANGER))

	var ver := UiKit.label("Version %s" % ProjectSettings.get_setting("application/config/version", "dev"),
		22, UiKit.MUTED)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(ver)
	add_back_button(col)


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
	slider.custom_minimum_size.y = 56  # big touch target
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
		"This clears your session and all-time stats, streaks and best run. "
		+ "Achievements and settings are kept. This can't be undone.",
		"Reset", func() -> void:
			GameState.reset_stats()
			Toast.show_message("STATS", "All stats reset"))
