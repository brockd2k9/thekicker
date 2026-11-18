extends CareerScreen
## Off-field scenario: title, story, and 2-4 choice cards. Each card shows the
## projected stat changes (CareerStats.preview: the same rules that apply them)
## and the game-day modifiers it sets. Picking applies it, saves a checkpoint,
## and shows what happened.


func _build(col: VBoxContainer) -> void:
	var s := career.current_scenario()
	if s.is_empty():
		go_to_current.call_deferred()
		return
	var c := career.data
	var where := "OFFSEASON" if c.phase == CareerManager.PHASE_OFFSEASON else \
		("BYE WEEK %d" % c.week if career.is_bye() else "WEEK %d  -  OFF THE FIELD" % c.week)
	col.add_child(CareerUi.centered(where, 24, UiKit.MUTED))
	col.add_child(CareerUi.centered(str(s.get("title", "")), 52, UiKit.ACCENT))
	var gate := _gate_text(s)
	if gate != "":
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(CareerUi.chip(gate, true, 24))
		col.add_child(row)
	var text := UiKit.label(str(s.get("text", "")), 30)
	col.add_child(text)

	var list := UiKit.scroll_list(col)
	var choices: Array = s.get("choices", [])
	for i in choices.size():
		var ch: Dictionary = choices[i]
		var lock := ScenarioEngine.choice_lock(c, ch)
		var parts := CareerUi.card(_pick.bind(i), lock == "")
		var v: VBoxContainer = parts[1]
		v.add_child(UiKit.label(str(ch.get("label", "")), 32, Color.WHITE if lock == "" else UiKit.MUTED))
		if lock != "":
			v.add_child(UiKit.label(lock, 24, Color(1.0, 0.8, 0.4)))
		var preview := CareerStats.preview(c, ch.get("stats", {}), career.tuning)
		v.add_child(CareerUi.change_chips(preview))
		var mods: Array = ch.get("modifiers", [])
		if not mods.is_empty():
			v.add_child(CareerUi.modifier_chips(mods))
		list.add_child(parts[0])
	var left := c.pending_scenarios.size()
	col.add_child(CareerUi.centered("%d more this week" % (left - 1) if left > 1 else "Tap a choice", 22,
		UiKit.MUTED))


func _pick(index: int) -> void:
	if get_node_or_null("Modal") != null:
		return
	var s := career.current_scenario()
	var choice: Dictionary = s.get("choices", [])[index]
	var out := career.choose(index)
	var v := UiKit.modal(self, str(choice.get("label", "")))
	var r := UiKit.label(str(out.get("result", "")), 30)
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(r)
	v.add_child(CareerUi.change_chips(out.get("applied", {})))
	if not out.get("modifiers", []).is_empty():
		v.add_child(CareerUi.modifier_chips(out["modifiers"]))
	for t in out.get("new_traits", []):
		var def := CareerContent.trait_def(str(t))
		v.add_child(CareerUi.centered("NEW TRAIT: %s" % def.get("name", t), 32, UiKit.GOOD))
		v.add_child(CareerUi.centered(str(def.get("description", "")), 24, UiKit.MUTED))
	if str(out.get("follow_up", "")) != "":
		v.add_child(CareerUi.centered("This isn't over...", 24, UiKit.MUTED))
	var b := UiKit.button("Continue", go_to_current)
	v.add_child(b)
	if not OS.has_feature("mobile"):
		b.grab_focus.call_deferred()


## "Fan Favorite scenario", "Leadership 55+ scenario", "Story beat" or "".
static func _gate_text(s: Dictionary) -> String:
	if s.has("gate"):
		return str(s["gate"])
	var t := ScenarioEngine.requirement_text(s.get("requires", {}))
	return (t + " scenario") if t != "" else ""
