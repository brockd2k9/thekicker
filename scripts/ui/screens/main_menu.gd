extends MenuScreen
## Main menu. Back on the main menu quits (Android back / Esc).


func _build(col: VBoxContainer) -> void:
	col.add_child(UiKit.expanding_spacer())
	var logo := UiKit.label("KICKER", 110, UiKit.ACCENT)
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_constant_override("outline_size", 14)
	col.add_child(logo)
	var tag := UiKit.label("Field goal unit. Ice in your veins.", 28, UiKit.MUTED)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(tag)
	col.add_child(UiKit.expanding_spacer())

	var first := UiKit.button("Career Mode", Screens.go.bind(Screens.CAREER))
	col.add_child(first)
	col.add_child(UiKit.button("Challenge Mode", Screens.go.bind(Screens.CHALLENGE)))
	col.add_child(UiKit.button("Practice", Screens.go.bind(Screens.PRACTICE)))
	col.add_child(UiKit.button("My Stats", Screens.go.bind(Screens.STATS)))
	col.add_child(UiKit.button("Achievements", Screens.go.bind(Screens.ACHIEVEMENTS)))
	col.add_child(UiKit.button("Settings", Screens.go.bind(Screens.SETTINGS)))

	var s := GameState.stats
	var footer := UiKit.label("All-time  %d / %d  (%d%%)    Best run  %d" % [
		s.makes, s.attempts, s.accuracy_percent(), s.challenge_best_makes], 24, UiKit.MUTED)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(footer)
	col.add_child(UiKit.expanding_spacer())
	# Keyboard / gamepad focus for desktop (Steam later). Harmless on touch.
	if not OS.has_feature("mobile"):
		first.grab_focus.call_deferred()


func go_back() -> void:
	GameState.save_game()
	get_tree().quit()
