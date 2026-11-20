extends Node
## Career kick series in the kick scene: stage tryouts (walk-on, training camp,
## free agent), the bench audition and scenario kick challenges (showcases,
## camps, combines, kicker battles). Field goals with the target team's posts
## and your current kick profile, then (challenges only) kickoffs in a tee
## scene. Every kick is saved as it resolves (CareerManager.tryout_kick), so
## leaving continues at the next kick; a kick struck but not resolved when the
## game quit counts as a miss. Wind is seeded per kick.

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")

var career: CareerManager
var _mode: TryoutMode
var _game: Node
var _overlay: PlayOverlay
var _ended := false


func _ready() -> void:
	career = GameState.career
	if career == null:
		Screens.go(Screens.CAREER)
		return
	if career.data.phase != CareerManager.PHASE_TRYOUT:
		Screens.go(career.screen_path())
		return
	career.tryout_resume()
	_overlay = PlayOverlay.new()
	_overlay.quit_text = {"job": "Leave Audition", "challenge": "Leave Challenge"}.get(_purpose(), "Leave Tryout")
	_overlay.quit_path = Screens.CAREER_HUB
	_build_scene(TryoutMode.needs_tee(career.data.tryout))
	add_child(_overlay)
	GameState.kick_resolved.connect(_on_kick_resolved)
	if career.tryout_done():
		_end.call_deferred()


func _exit_tree() -> void:
	if GameState.kick_resolved.is_connected(_on_kick_resolved):
		GameState.kick_resolved.disconnect(_on_kick_resolved)


func _purpose() -> String:
	return str(career.data.tryout.get("purpose", ""))


## A field goal scene for the field goals, or a tee scene for one kickoff.
func _build_scene(tee: bool) -> void:
	if _game != null:
		_game.queue_free()
		remove_child(_game)
	var t := career.data.tryout
	_mode = TryoutMode.from_tryout(t, tee)
	var team := CareerContent.team_by_id(str(t.get("team", "")))
	var stage := str(t.get("stage", "pro"))
	var width := career.tuning.goal_width_pro if stage == "pro" else career.tuning.goal_width_college
	if stage == "high_school":  # high school auditions and challenges on high school posts
		width = career.tuning.goal_width_high_school
	var prof := career.profile()
	if tee:
		_mode.kickoff_rules = CareerGameMode.kickoff_rules_for(career.tuning,
			Progression.game_params(career.data, career.tuning), prof)
	_game = FIELD_GOAL.instantiate()
	_game.mode = _mode
	_game.modifiers = prof.to_kick_modifiers()
	_game.set_look(Progression.look(stage, width, team, {}))
	add_child(_game)
	if _overlay != null and _overlay.get_parent() == self:
		move_child(_overlay, -1)
	_game.attempt_finished.connect(_on_attempt_finished)
	_game.kick_struck.connect(career.tryout_struck)
	_update_scoreboard()


func _on_kick_resolved(r: KickReport) -> void:
	if r.mode != &"career" or _mode.tee:
		return
	_mode.record(r)
	career.tryout_kick(r.made)
	_update_scoreboard()


func _update_scoreboard() -> void:
	var t := career.data.tryout
	_game.hud.set_scoreboard(str(t.get("title" if _purpose() == "challenge" else "team_name", "")),
		"MADE %d  -  NEED %d" % [(t.get("results", []) as Array).count(true), int(t.get("need", 3))])


func _on_attempt_finished(_o: KickResult.Outcome) -> void:
	if _mode.tee:
		career.tryout_kick(_mode.record_kickoff(_game.tee_result))
		_update_scoreboard()
	elif _mode.wants_next_kick():
		return
	if career.tryout_done():
		_end()
	elif TryoutMode.needs_tee(career.data.tryout):
		_build_scene(true)  # next kickoff (or the first one after the field goals)


func _end() -> void:
	if _ended:
		return
	_ended = true
	_overlay.set_pause_enabled(false)
	Sfx.play(&"run_over")
	var t := career.data.tryout
	var need := int(t.get("need", 3))
	var made := (t.get("results", []) as Array).count(true)
	var kicks := TryoutMode.total_kicks(t)
	if _purpose() == "challenge":
		_challenge_end()
		return
	var passed := made >= need
	var aud := _purpose() == "job"
	var v := UiKit.modal(_overlay.root, ("JOB WON BACK" if passed else "NOT ENOUGH") if aud else ("YOU MADE IT!" if passed else "CUT"))
	v.add_child(CareerUi.centered("%d of %d made (needed %d)" % [made, kicks, need], 34,
		UiKit.GOOD if passed else UiKit.BAD))
	if aud:
		var fails := int(career.data.bench.get("auditions_failed", 0)) + (0 if passed else 1)
		v.add_child(CareerUi.centered("The field goals are yours again." if passed else
			("The coach gives you the job back anyway. Make it count." if fails >= career.tuning.audition_max_fails
			else "%s keeps the field goals one more week." % Bench.backup_name(career.data)), 28))
	else:
		v.add_child(CareerUi.centered(("Welcome to the %s." if passed else "The %s went another way.")
			% t.get("team_name", ""), 28))
	var b := UiKit.button("Continue", func() -> void:
		career.finish_tryout(made)
		Screens.go(career.screen_path()), UiKit.PRIMARY)
	v.add_child(b)
	if not OS.has_feature("mobile"):
		b.grab_focus.call_deferred()


## A kick challenge: the outcome is applied right away (finish_tryout), then shown.
func _challenge_end() -> void:
	career.finish_tryout(0)
	var res := career.data.last_challenge
	var out: Dictionary = res.get("out", {})
	var passed: bool = res.get("passed", false)
	var vars := Relationships.text_vars(career.data)
	var v := UiKit.modal(_overlay.root, "%s: %s" % [str(res.get("title", "CHALLENGE")),
		"PERFECT" if res.get("perfect", false) else ("PASSED" if passed else "NOT THIS TIME")])
	v.add_child(CareerUi.centered("%d of %d made (needed %d)" % [int(res.get("made", 0)), int(res.get("kicks", 0)),
		int(res.get("need", 3))], 34, UiKit.GOOD if passed else UiKit.BAD))
	var r := UiKit.label(CareerContent.fill(str(out.get("result", "")), vars), 28)
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(r)
	v.add_child(CareerUi.change_chips(out.get("applied", {})))
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", 8)
	f.add_theme_constant_override("v_separation", 6)
	var sp := int(out.get("skill_points", 0))
	if sp != 0:
		f.add_child(UiKit.chip("%+d Skill Points" % sp, UiKit.ACCENT if sp > 0 else UiKit.BAD, false, "skill", 22))
	var fans := int(out.get("followers", 0))
	if fans != 0:
		f.add_child(UiKit.chip(Followers.change_text(fans), UiKit.group_color("personality") if fans > 0 else UiKit.BAD,
			false, "social", 22))
	var prog: Dictionary = out.get("progress", {})
	for k in prog:
		if k in ["recruiting", "draft", "retention"]:
			f.add_child(CareerUi.chip("%+d %s" % [roundi(float(prog[k])), {"recruiting": "Recruiting",
				"draft": "Draft stock", "retention": "Standing"}[k]], float(prog[k]) > 0.0))
	if f.get_child_count() > 0:
		v.add_child(f)
	if not (out.get("relationships", {}) as Dictionary).is_empty():
		v.add_child(CareerUi.rel_chips(career.data, out["relationships"]))
	if not (out.get("modifiers", []) as Array).is_empty():
		v.add_child(CareerUi.modifier_chips(out["modifiers"]))
	var b := UiKit.button("Continue", func() -> void: Screens.go(career.screen_path()), UiKit.PRIMARY)
	v.add_child(b)
	if not OS.has_feature("mobile"):
		b.grab_focus.call_deferred()
