extends Node
## Career tryout in the kick scene (walk-on, training camp, free agent): a fixed
## series of field goals with the target team's goalposts and colors and your
## current kick profile. Make enough and you're on the roster. Leaving
## restarts the tryout from its first kick (like a game).

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")

var career: CareerManager
var _mode: TryoutMode
var _game: Node
var _overlay: PlayOverlay


func _ready() -> void:
	career = GameState.career
	if career == null:
		Screens.go(Screens.CAREER)
		return
	if career.data.phase != CareerManager.PHASE_TRYOUT:
		Screens.go(career.screen_path())
		return
	var t := career.data.tryout
	_mode = TryoutMode.from_tryout(t)
	var team := CareerContent.team_by_id(str(t.get("team", "")))
	var stage := str(t.get("stage", "pro"))
	var width := career.tuning.goal_width_pro if stage == "pro" else career.tuning.goal_width_college
	_game = FIELD_GOAL.instantiate()
	_game.mode = _mode
	_game.modifiers = career.profile().to_kick_modifiers()
	_game.set_look(Progression.look(stage, width, team, {}))
	add_child(_game)
	_overlay = PlayOverlay.new()
	_overlay.quit_text = "Leave Tryout"
	_overlay.quit_path = Screens.CAREER_HUB
	add_child(_overlay)
	GameState.kick_resolved.connect(_on_kick_resolved)
	_game.attempt_finished.connect(_on_attempt_finished)
	_update_scoreboard()


func _exit_tree() -> void:
	if GameState.kick_resolved.is_connected(_on_kick_resolved):
		GameState.kick_resolved.disconnect(_on_kick_resolved)


func _on_kick_resolved(r: KickReport) -> void:
	if r.mode != &"career":
		return
	_mode.record(r)
	_update_scoreboard()


func _update_scoreboard() -> void:
	var need := int(career.data.tryout.get("need", 3))
	_game.hud.set_scoreboard("%s" % career.data.tryout.get("team_name", ""),
		"MADE %d  -  NEED %d" % [_mode.makes, need])


func _on_attempt_finished(_o: KickResult.Outcome) -> void:
	if _mode.wants_next_kick():
		return
	_overlay.set_pause_enabled(false)
	var need := int(career.data.tryout.get("need", 3))
	var passed := _mode.makes >= need
	Sfx.play(&"run_over")
	var v := UiKit.modal(_overlay.root, "YOU MADE IT!" if passed else "CUT")
	v.add_child(CareerUi.centered("%d of %d made (needed %d)" % [_mode.makes, _mode.kicks, need], 34,
		UiKit.GOOD if passed else UiKit.BAD))
	v.add_child(CareerUi.centered(("Welcome to the %s." if passed else "The %s went another way.")
		% career.data.tryout.get("team_name", ""), 28))
	var b := UiKit.button("Continue", func() -> void:
		career.finish_tryout(_mode.makes)
		Screens.go(career.screen_path()), UiKit.PRIMARY)
	v.add_child(b)
	if not OS.has_feature("mobile"):
		b.grab_focus.call_deferred()
