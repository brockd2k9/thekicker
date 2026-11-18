extends MenuScreen
## Career Mode placeholder. The real mode will add: player stats (Leg Power,
## Accuracy, Composure, Fitness, Morale), a weekly schedule, a season of games
## and save/load. Its kicks go through GameState.report_kick like every mode.


func _build(col: VBoxContainer) -> void:
	col.add_child(UiKit.expanding_spacer())
	var soon := UiKit.label("Coming soon", 56)
	soon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(soon)
	var body := UiKit.label(
		"Sign with a fictional club, train your Leg Power, Accuracy, Composure, "
		+ "Fitness and Morale through the week, and kick your way through a full season.",
		30, UiKit.MUTED)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(body)
	col.add_child(UiKit.expanding_spacer())
	add_back_button(col)
