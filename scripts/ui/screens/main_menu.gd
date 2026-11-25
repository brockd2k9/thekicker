extends MenuScreen
## Main menu. Back on the main menu quits (Android back / Esc).
## The Daily Challenge has its own entry (with a NEW badge until today's kick
## is tried) and a popup the first time the menu opens each day.


func _build(col: VBoxContainer) -> void:
	col.add_child(UiKit.expanding_spacer())
	col.add_child(_logo())
	col.add_child(UiKit.expanding_spacer())

	var first := UiKit.primary("Career Mode", Screens.go.bind(Screens.CAREER), "career")
	first.custom_minimum_size.y = 108
	col.add_child(first)
	GameState.daily_refresh()
	col.add_child(_daily_button())
	var items := [
		["Challenge Mode", Screens.CHALLENGE, "challenge"],
		["Practice", Screens.PRACTICE, "practice"],
		["My Stats", Screens.STATS, "stats"],
		["Achievements", Screens.ACHIEVEMENTS, "achievements"],
		["Settings", Screens.SETTINGS, "settings"],
	]
	if OS.is_debug_build():
		items.append(["UI Gallery", Screens.UI_GALLERY, "settings"])  # the design system, for review
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
	col.add_child(UiKit.ticker("Stats", "All-time %d/%d  •  %d%%  •  Best streak %d" % [
		s.makes, s.attempts, s.accuracy_percent(), s.challenge_best_makes]))
	col.add_child(UiKit.expanding_spacer())
	# Keyboard / gamepad focus for desktop (Steam later). Harmless on touch.
	if not OS.has_feature("mobile"):
		first.grab_focus.call_deferred()
	if GameState.daily.wants_popup():
		DailyUi.popup.call_deferred(self, GameState.daily, _open_daily.bind(Screens.DAILY_KICK))


## Daily Challenge: the button, with a NEW badge (today's kick not tried yet)
## or the current streak on its right.
func _daily_button() -> Button:
	var d := GameState.daily
	var b := UiKit.button("Daily Challenge", _open_daily.bind(Screens.DAILY), UiKit.SECONDARY, "calendar")
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size.y = 96
	var tag := ""
	if d.is_new():
		tag = "New"
	elif d.status() == "done":
		tag = "Done"
	if d.streak > 0:
		tag = ("%s  ·  " % tag if tag != "" else "") + "Streak %d" % d.streak
	if tag != "":
		var chip := DailyUi.new_badge() if d.is_new() else BrandUi.chip(tag, "outline", "flame")
		chip.text = tag
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT, Control.PRESET_MODE_MINSIZE, Brand.SPACE_3)
		chip.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		chip.grow_vertical = Control.GROW_DIRECTION_BOTH
		b.add_child(chip)
	return b


func _open_daily(path: String) -> void:
	DailyScreen.return_to = Screens.MAIN_MENU
	Screens.go(path)


## "KICKER" in the banner font with a floodlight glow, over a broadcast tag line.
func _logo() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top := UiKit.label("FIELD GOAL UNIT", 28, Brand.GREY, UiTokens.FONT_CONDENSED)
	top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(top)
	var logo := UiKit.label("KICKER", 150, UiKit.TEXT, UiTokens.FONT_BANNER)
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.autowrap_mode = TextServer.AUTOWRAP_OFF
	v.add_child(logo)
	v.add_child(UiKit.rule())
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
