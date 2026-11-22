extends Node
## Challenge Mode: reuses the field-goal scene with ChallengeRules plugged in.
## Listens to GameState.kick_resolved for results (like every system) and shows
## the results screen when the third miss has played out.

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")

var rules := ChallengeRules.new()
var _game: Node
var _overlay: PlayOverlay


func _ready() -> void:
	_game = FIELD_GOAL.instantiate()
	_game.mode = rules  # must be set before it enters the tree (its _ready starts kick 1)
	add_child(_game)
	_overlay = PlayOverlay.new()
	_overlay.quit_text = "Quit Run"
	add_child(_overlay)

	GameState.kick_resolved.connect(_on_kick_resolved)
	_game.attempt_finished.connect(_on_attempt_finished)
	_update_scoreboard()


func _exit_tree() -> void:
	if GameState.kick_resolved.is_connected(_on_kick_resolved):
		GameState.kick_resolved.disconnect(_on_kick_resolved)


func _on_kick_resolved(r: KickReport) -> void:
	if r.mode != rules.id():
		return
	rules.record(r)
	_update_scoreboard()


func _update_scoreboard() -> void:
	var left := "KICK %d  MADE %d" % [mini(rules.kicks + 1, 999), rules.makes]
	if rules.is_over():
		left = "KICKS %d  MADE %d" % [rules.kicks, rules.makes]
	var lives := ""
	for i in ChallengeRules.MAX_MISSES:
		lives += ("X " if i < rules.misses else "O ")
	_game.hud.set_scoreboard(left, "MISSES " + lives.strip_edges())


func _on_attempt_finished(_outcome: KickResult.Outcome) -> void:
	if rules.is_over():
		_show_results()


func _show_results() -> void:
	var previous_best := GameState.stats.challenge_best_makes
	var summary := rules.summary()
	GameState.report_run(summary)
	_overlay.set_pause_enabled(false)
	Sfx.play(&"run_over")

	var v := UiKit.modal(_overlay.root, "RUN OVER")
	var new_best := rules.makes > previous_best and rules.makes > 0
	if new_best:
		var nb := UiKit.label("NEW BEST!", 40, UiKit.GOOD)
		nb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(nb)
	v.add_child(UiKit.stat_row("Kicks Made", "%d of %d" % [rules.makes, rules.kicks], UiKit.ACCENT))
	v.add_child(UiKit.stat_row("Streak This Run", str(rules.best_streak)))
	v.add_child(UiKit.stat_row("Longest Make",
		("%d yd" % rules.longest_make) if rules.longest_make > 0 else "-"))
	v.add_child(UiKit.stat_row("Total Yards", str(rules.total_yards)))
	v.add_child(UiKit.stat_row("Best Streak", "%d makes" % GameState.stats.challenge_best_makes))
	var again := UiKit.button("Play Again", Screens.go.bind(Screens.CHALLENGE))
	v.add_child(again)
	v.add_child(UiKit.button("Main Menu", Screens.go.bind(Screens.MAIN_MENU)))
	if not OS.has_feature("mobile"):
		again.grab_focus.call_deferred()
