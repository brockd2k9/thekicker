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
	var where := "Offseason" if c.phase == CareerManager.PHASE_OFFSEASON else \
		("Bye week %d" % c.week if career.is_bye() else "Week %d  ·  Off the field" % c.week)
	# Tags: category (with its icon) and any trait/stat gate.
	var tags := HFlowContainer.new()
	tags.add_theme_constant_override("h_separation", 8)
	tags.add_theme_constant_override("v_separation", 6)
	tags.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cat := str(s.get("category", ""))
	if cat != "":
		tags.add_child(UiKit.chip(cat.to_upper(), UiKit.ACCENT, true, UiIcons.for_category(cat), 24))
	var gate := _gate_text(s)
	if gate != "":
		tags.add_child(UiKit.chip(gate, UiKit.GOOD, false, "charisma", 24))
	tags.add_child(UiKit.chip(where.to_upper(), UiKit.MUTED, false, "calendar", 24))
	col.add_child(tags)
	var title := UiKit.label(str(s.get("title", "")).to_upper(), 50, UiKit.TEXT, UiTokens.FONT_DISPLAY)
	col.add_child(title)
	col.add_child(UiKit.rule())
	var story := UiKit.card(Color(0, 0, 0, 0), 0)
	(story[1] as VBoxContainer).add_child(UiKit.label(str(s.get("text", "")), 30))
	col.add_child(story[0])

	var list := UiKit.scroll_list(col)
	list.add_theme_constant_override("separation", 14)
	var choices: Array = s.get("choices", [])
	for i in choices.size():
		var ch: Dictionary = choices[i]
		var lock := ScenarioEngine.choice_lock(c, ch)
		var parts := CareerUi.card(_pick.bind(i), lock == "")
		var v: VBoxContainer = parts[1]
		v.add_child(UiKit.label(str(ch.get("label", "")), 32, UiKit.TEXT if lock == "" else UiKit.MUTED,
			UiTokens.FONT_DISPLAY))
		if lock != "":
			var req := UiKit.chip(lock, UiKit.WARN, false, "lock", 22)
			v.add_child(req)
		var preview := CareerStats.preview(c, ch.get("stats", {}), career.tuning)
		v.add_child(CareerUi.change_chips(preview))
		var mods: Array = ch.get("modifiers", [])
		if not mods.is_empty():
			v.add_child(CareerUi.modifier_chips(mods))
		list.add_child(parts[0])
	UiKit.stagger(list, 0.06)
	var left := c.pending_scenarios.size()
	col.add_child(CareerUi.centered("%d more this week" % (left - 1) if left > 1 else "Tap a choice", 24,
		UiKit.MUTED))


func _pick(index: int) -> void:
	if get_node_or_null("Modal") != null:
		return
	var c := career.data
	var before := {}
	for k in CareerData.STAT_NAMES:
		before[k] = c.stat(k)
	var s := career.current_scenario()
	var choice: Dictionary = s.get("choices", [])[index]
	var out := career.choose(index)
	var v := UiKit.modal(self, str(choice.get("label", "")))
	var r := UiKit.label(str(out.get("result", "")), 30)
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(r)
	# The stats that moved, gliding from old to new.
	var applied: Dictionary = out.get("applied", {})
	var bars := VBoxContainer.new()
	bars.add_theme_constant_override("separation", 8)
	var n := 0
	for g in CareerData.GROUP_KEYS:
		for k in CareerData.GROUP_KEYS[g]:
			if not applied.get(g, {}).has(k):
				continue
			var name := str(CareerData.STAT_NAMES[k]).replace("Kicking ", "")
			var b := StatBar.new(k, name, c.stat(k), UiKit.group_color(g), 24)
			bars.add_child(b)
			b.animate_from(float(before[k]), 0.3 + n * 0.05)
			n += 1
	if n > 0:
		v.add_child(bars)
		UiKit.feedback(&"stat_up")
	if not out.get("modifiers", []).is_empty():
		v.add_child(CareerUi.modifier_chips(out["modifiers"]))
	for t in out.get("new_traits", []):
		v.add_child(trait_unlock_card(str(t)))
	if str(out.get("follow_up", "")) != "":
		v.add_child(CareerUi.centered("This isn't over...", 24, UiKit.MUTED))
	var b2 := UiKit.primary("Continue", go_to_current, "next")
	v.add_child(b2)
	if not OS.has_feature("mobile"):
		b2.grab_focus.call_deferred()


## "NEW TRAIT" card that pops in with a glow (also used by Results).
static func trait_unlock_card(id: String) -> PanelContainer:
	var def := CareerContent.trait_def(id)
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := UiKit.panel_box(UiKit.GOOD, Color(UiKit.GOOD, 0.14))
	box.shadow_color = Color(UiKit.GOOD, 0.45)
	box.shadow_size = 22
	box.shadow_offset = Vector2.ZERO
	p.add_theme_stylebox_override("panel", box)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 16)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(h)
	h.add_child(UiIcons.rect(UiIcons.for_trait(id), UiKit.GOOD, 56))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(v)
	v.add_child(UiKit.label("NEW TRAIT UNLOCKED", 22, UiKit.GOOD, UiTokens.FONT_DISPLAY))
	v.add_child(UiKit.label(str(def.get("name", id)).to_upper(), 36, UiKit.TEXT, UiTokens.FONT_BANNER))
	v.add_child(UiKit.label(str(def.get("description", "")), 22, UiKit.MUTED))
	UiKit.pop_in(p, 0.45, 0.5)
	var tw := p.create_tween().set_ignore_time_scale(true)
	tw.tween_interval(0.45)
	tw.tween_callback(func() -> void: UiKit.feedback(&"trait_unlock"))
	return p


## "Fan Favorite scenario", "Leadership 55+ scenario", "Story beat" or "".
static func _gate_text(s: Dictionary) -> String:
	if s.has("gate"):
		return str(s["gate"])
	var t := ScenarioEngine.requirement_text(s.get("requires", {}))
	return (t + " scenario") if t != "" else ""
