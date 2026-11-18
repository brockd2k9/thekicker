extends MenuScreen
## Main menu. Back on the main menu quits (Android back / Esc).


func _build(col: VBoxContainer) -> void:
	col.add_child(UiKit.expanding_spacer())
	col.add_child(_logo())
	col.add_child(UiKit.expanding_spacer())

	var first := UiKit.primary("Career Mode", Screens.go.bind(Screens.CAREER), "career")
	first.custom_minimum_size.y = 108
	col.add_child(first)
	var items := [
		["Challenge Mode", Screens.CHALLENGE, "challenge"],
		["Practice", Screens.PRACTICE, "practice"],
		["My Stats", Screens.STATS, "stats"],
		["Achievements", Screens.ACHIEVEMENTS, "achievements"],
		["Settings", Screens.SETTINGS, "settings"],
	]
	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	col.add_child(buttons)
	for it in items:
		var b := UiKit.button(it[0], Screens.go.bind(it[1]), UiKit.SECONDARY, it[2])
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size.y = 92
		buttons.add_child(b)
	UiKit.stagger(buttons, 0.04)

	var s := GameState.stats
	col.add_child(UiKit.ticker("Stats", "All-time %d/%d  •  %d%%  •  Best run %d" % [
		s.makes, s.attempts, s.accuracy_percent(), s.challenge_best_makes]))
	col.add_child(UiKit.expanding_spacer())
	# Keyboard / gamepad focus for desktop (Steam later). Harmless on touch.
	if not OS.has_feature("mobile"):
		first.grab_focus.call_deferred()


## "KICKER" in the banner font with a floodlight glow, over a broadcast tag line.
func _logo() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top := UiKit.label("FIELD GOAL UNIT", 30, UiKit.ACCENT, UiTokens.FONT_DISPLAY)
	top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(top)
	var logo := UiKit.label("KICKER", 150, UiKit.TEXT, UiTokens.FONT_BANNER)
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.autowrap_mode = TextServer.AUTOWRAP_OFF
	logo.add_theme_color_override("font_shadow_color", Color(UiKit.ACCENT, 0.3))
	logo.add_theme_constant_override("shadow_outline_size", 16)
	logo.add_theme_constant_override("shadow_offset_x", 0)
	logo.add_theme_constant_override("shadow_offset_y", 0)
	v.add_child(logo)
	var tag_row := HBoxContainer.new()
	tag_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tag_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag_row.add_child(UiKit.chip("ICE IN YOUR VEINS", UiKit.ALT, true, "", 26))
	v.add_child(tag_row)
	UiKit.pop_in(logo, 0.05, 0.85)
	return v


func go_back() -> void:
	GameState.save_game()
	get_tree().quit()
