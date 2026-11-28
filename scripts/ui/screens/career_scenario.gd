extends CareerScreen
## Off-field scenario, built to be read: tags, a headline, a "Because you..."
## line when an earlier choice brought this scene, the person it features
## (portrait tile, name, role), and the setup in short beats (2 to 3 lines
## each, typed in; tap to continue, a tap mid-line finishes it) with its key
## phrase highlighted (ScenarioText). The choices come in after the last
## beat: a short label and stakes chips (ScenarioEngine.stakes: football,
## life, personality, grades, people, money, fans, conduct), exact numbers
## only on choices without a real downside ("+" / "\u2212" / "\u00b1" alone
## on risky ones).
## A major scene ("impact": "major") gets a darker screen with a red frame, a
## MAJOR MOMENT tag, a slower reveal and the major_scene sound and haptic.
## Picking: the full result only when ScenarioEngine.result_reasons says so
## (always for major, never for minor, thresholds for normal); otherwise a
## quick toast with the changes and straight on. Every choice is kept in the
## Hub's "Recent choices".
## A choice gated by an ad (MonetizationConfig.PRACTICE_50_CHOICES, e.g. "Stay
## for all 50") says so on its card ("Watch an ad to choose this"), asks
## before playing the ad, and is applied only when the reward is earned. With
## no ad available it's free (PRACTICE_50_FREE_IF_NO_AD), decided when the
## screen opens so it never flips from free to ad while you look at it.

## Characters typed per second (normal / major scenes).
const TYPE_CPS := 90.0
const TYPE_CPS_MAJOR := 45.0

## Choice index -> AdManager.choice_gate() result, fixed when the screen is built.
var _gates := {}
var _beats: Array = []
var _beat := 0
var _key := ""
var _story: RichTextLabel
var _hint: Control
var _choices: Control
var _footer: Control
var _type_tw: Tween
var _impact := "normal"


func _build(col: VBoxContainer) -> void:
	var s := career.current_scenario()
	if s.is_empty():
		go_to_current.call_deferred()
		return
	var c := career.data
	var vars := Relationships.text_vars(c)
	_impact = ScenarioEngine.impact(s)
	var major := _impact == "major"
	if major:
		_major_frame()
	var where := "Offseason" if c.phase == CareerManager.PHASE_OFFSEASON else \
		("Bye week %d" % c.week if career.is_bye() else "Week %d  \u00b7  Off the field" % c.week)
	if c.phase == CareerManager.PHASE_EPILOGUE:
		where = "After the game"
	# Tags: major moment, category (with its icon), any trait/stat gate, when.
	var tags := HFlowContainer.new()
	tags.add_theme_constant_override("h_separation", 8)
	tags.add_theme_constant_override("v_separation", 6)
	tags.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if major:
		tags.add_child(UiKit.chip("MAJOR MOMENT", UiKit.ACCENT, true, "flame", 24))
	var cat := str(s.get("category", ""))
	if cat != "":
		tags.add_child(UiKit.chip(cat.to_upper(), UiKit.ACCENT, not major, UiIcons.for_category(cat), 24))
	var gate := _gate_text(s)
	if gate != "":
		tags.add_child(UiKit.chip(gate, UiKit.GOOD, false, "charisma", 24))
	tags.add_child(UiKit.chip(where.to_upper(), UiKit.MUTED, false, "calendar", 24))
	col.add_child(tags)
	var title := UiKit.label(CareerContent.fill(str(s.get("title", "")), vars).to_upper(), 50, UiKit.TEXT,
		UiTokens.FONT_DISPLAY)
	col.add_child(title)
	var because := ScenarioEngine.because(c, s)
	if because != "":
		col.add_child(_because_line(because))
	var who := ScenarioText.speaker(s)
	if who != "" and Relationships.in_cast(c, who):
		col.add_child(_speaker_strip(c, who))
	else:
		col.add_child(UiKit.rule())
	# The setup, in beats.
	var text := CareerContent.fill(str(s.get("text", "")), vars)
	_beats = ScenarioText.beats(text)
	_key = ScenarioText.key_phrase(s, text)
	if str(s.get("key", "")) != "":
		_key = CareerContent.fill(str(s["key"]), vars)
	var story := PanelContainer.new()
	story.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := UiKit.panel_box(Brand.RED if major else Color(0, 0, 0, 0), Brand.INK_0 if major else Color(0, 0, 0, 0))
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	story.add_theme_stylebox_override("panel", sb)
	_story = RichTextLabel.new()
	_story.name = "Story"
	_story.bbcode_enabled = true
	_story.fit_content = true
	_story.scroll_active = false
	_story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_story.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story.add_theme_font_size_override("normal_font_size", UiKit.type_size(30))
	_story.add_theme_font_size_override("bold_font_size", UiKit.type_size(30))
	_story.add_theme_font_override("bold_font", BrandTheme.font(Brand.FONT_BODY_STRONG))
	_story.add_theme_color_override("default_color", UiKit.TEXT)
	story.add_child(_story)
	col.add_child(story)
	_hint = _continue_hint()
	col.add_child(_hint)

	var list := UiKit.scroll_list(col)
	list.add_theme_constant_override("separation", 14)
	_choices = list.get_parent().get_parent()
	var choices: Array = s.get("choices", [])
	var sid := str(s.get("id", ""))
	for i in choices.size():
		var ch: Dictionary = choices[i]
		var lock := ScenarioEngine.choice_lock(c, ch)
		var ad_gate := AdManager.choice_gate(sid, i)
		_gates[i] = ad_gate
		if lock == "" and ad_gate == "unavailable":
			lock = "No ad available right now"
		var parts := CareerUi.card(_pick_gated.bind(i) if ad_gate == "ad" else _pick.bind(i), lock == "")
		var v: VBoxContainer = parts[1]
		v.add_child(UiKit.label(CareerContent.fill(str(ch.get("label", "")), vars), 32,
			UiKit.TEXT if lock == "" else UiKit.MUTED, UiTokens.FONT_DISPLAY))
		if lock != "":
			var req := UiKit.chip(CareerContent.fill(lock, vars), UiKit.WARN, false, "lock", 22)
			v.add_child(req)
		if ad_gate == "ad":
			v.add_child(UiKit.chip("WATCH AN AD TO CHOOSE THIS", UiKit.ACCENT, true, "play", 22))
			v.add_child(UiKit.label("Optional: the other choices are free.", 22, UiKit.MUTED))
		elif ad_gate == "free" and AdManager.platform_has_ads() and not AdManager.ads_removed:
			v.add_child(UiKit.chip("FREE TODAY: NO AD AVAILABLE", UiKit.GOOD, false, "check", 22))
		if ch.get("kick_challenge") is Dictionary:
			v.add_child(_challenge_preview(c, ch))
		v.add_child(stake_chips(ScenarioEngine.stakes(c, ch, _impact, career.tuning)))
		list.add_child(parts[0])
	var left := c.pending_scenarios.size()
	_footer = CareerUi.centered("%d more this week" % (left - 1) if left > 1 else "Tap a choice", 24, UiKit.MUTED)
	col.add_child(_footer)
	_choices.visible = false
	_footer.visible = false
	if major:
		UiKit.feedback(&"major_scene")
	_show_beat.call_deferred(0)


# --- reading -------------------------------------------------------------------------

func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		if advance():
			accept_event()


func _unhandled_input(e: InputEvent) -> void:
	if _story != null and e.is_action_pressed(&"ui_accept") and advance():
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(e)


## A tap on the story: finish the line being typed, else the next beat. True
## if it did something (false once the choices are showing).
func advance() -> bool:
	if _type_tw != null and _type_tw.is_valid() and _type_tw.is_running():
		_type_tw.kill()
		_story.visible_characters = -1
		_after_typed()
		return true
	if _beat < _beats.size() - 1:
		_show_beat(_beat + 1)
		return true
	return false


## True once every beat is shown and the choices are up.
func reading_done() -> bool:
	return _choices != null and _choices.visible


## Shows beats 0..i (earlier ones dimmed) and types beat i in.
func _show_beat(i: int) -> void:
	if _story == null:
		return
	_beat = i
	var parts := PackedStringArray()
	var before := 0
	for j in i + 1:
		var b := str(_beats[j])
		if j < i:
			parts.append("[color=#%s]%s[/color]" % [UiKit.MUTED.to_html(false), ScenarioText.escape(b)])
			before += b.length() + 1
		else:
			parts.append(ScenarioText.bbcode(b, _key, UiKit.ACCENT))
	_story.text = " ".join(parts)
	var total := _story.get_total_character_count()
	_story.visible_characters = before
	var cps := TYPE_CPS_MAJOR if _impact == "major" else TYPE_CPS
	_type_tw = _story.create_tween().set_ignore_time_scale(true)
	_type_tw.tween_property(_story, "visible_characters", total, maxf(float(total - before) / cps, 0.05))
	_type_tw.tween_callback(func() -> void:
		_story.visible_characters = -1
		_after_typed())
	_hint.visible = false


func _after_typed() -> void:
	if _beat < _beats.size() - 1:
		_hint.visible = true
		UiKit.pop_in(_hint)
	elif not _choices.visible:
		# All read: the whole setup at full brightness for a second look.
		_story.text = ScenarioText.bbcode(" ".join(PackedStringArray(_beats)), _key, UiKit.ACCENT)
		_hint.visible = false
		_choices.visible = true
		_footer.visible = true
		var list := _choices.get_child(0).get_child(0) as Control
		UiKit.stagger(list, 0.06)


func _continue_hint() -> Control:
	var h := HBoxContainer.new()
	h.name = "ContinueHint"
	h.alignment = BoxContainer.ALIGNMENT_END
	h.add_theme_constant_override("separation", 6)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(UiKit.line("TAP TO CONTINUE", 24, UiKit.ACCENT, UiTokens.FONT_CONDENSED))
	h.add_child(UiIcons.rect("next", UiKit.ACCENT, 28))
	h.visible = false
	return h


## "Because you skipped the party." under the headline.
func _because_line(text: String) -> Control:
	var h := HBoxContainer.new()
	h.name = "Because"
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(UiIcons.rect("practice", UiKit.ACCENT, 30))
	var l := UiKit.label(text, 24, UiKit.MUTED, UiTokens.FONT_BODY)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(l)
	return h


## The person the scene features: a portrait tile (their icon on the team
## color), the name, and their role as a tag.
func _speaker_strip(c: CareerData, id: String) -> Control:
	var p := PanelContainer.new()
	p.name = "Speaker"
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := UiKit.panel_box(Color(0, 0, 0, 0), Brand.INK_1)
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	box.content_margin_left = 8
	box.content_margin_right = 16
	p.add_theme_stylebox_override("panel", box)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 16)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(h)
	var tile := PanelContainer.new()
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.custom_minimum_size = Vector2(72, 72)
	var tb := UiKit.panel_box(Color(0, 0, 0, 0), UiKit.team_color(0).darkened(0.25))
	tb.content_margin_left = 8
	tb.content_margin_right = 8
	tb.content_margin_top = 8
	tb.content_margin_bottom = 8
	tile.add_theme_stylebox_override("panel", tb)
	tile.add_child(UiIcons.rect(str(Relationships.def(id).get("icon", "social")), Brand.WHITE, 52))
	h.add_child(tile)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(v)
	v.add_child(UiKit.label(Relationships.name_of(c, id).to_upper(), 32, UiKit.TEXT, UiTokens.FONT_DISPLAY))
	var role := HBoxContainer.new()
	role.mouse_filter = Control.MOUSE_FILTER_IGNORE
	role.add_child(UiKit.chip(Relationships.role(c, id).to_upper(), UiKit.MUTED, false, "", 22))
	v.add_child(role)
	return p


## Major moment: the screen goes darker with a red frame.
func _major_frame() -> void:
	var bg := get_child(0) as Panel
	if bg == null:
		return
	var b := ClippedBox.new()
	b.bg = Color("#020203")
	b.texture_color = Color(Brand.RED_DEEP, 0.10)
	b.texture_step = Brand.TEXTURE_STEP * 2
	b.stroke = Brand.RED_DEEP
	b.stroke_width = 6
	bg.add_theme_stylebox_override("panel", b)


## Stakes chips for a choice card ({kind, label, icon, dir, value} from
## ScenarioEngine.stakes): "Coach Vance +5" when exact, "Money \u2212" (direction
## only) on a risky choice, "Life \u00b1" when it goes both ways.
static func stake_chips(stakes: Array, size := 22) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.name = "Stakes"
	f.add_theme_constant_override("h_separation", 8)
	f.add_theme_constant_override("v_separation", 8)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for st in stakes:
		var dir := int(st.get("dir", 0))
		var v := str(st.get("value", ""))
		var sign: String = {1: "+", -1: "\u2212", 0: "\u00b1"}[dir]
		var text := "%s %s" % [st.get("label", ""), v if v != "" else sign]
		f.add_child(UiKit.chip(text, UiKit.BAD if dir < 0 else (UiKit.GOOD if dir > 0 else UiKit.MUTED), false,
			str(st.get("icon", "")), size))
	return f


## An ad-gated choice: ask first, play the rewarded ad, and apply the choice
## only if the reward was earned. If the ad can't play and the free fallback
## is on, the choice is applied anyway (a failed ad never blocks progress).
func _pick_gated(index: int) -> void:
	if get_node_or_null("Modal") != null:
		return
	var choice: Dictionary = career.current_scenario().get("choices", [])[index]
	var label := CareerContent.fill(str(choice.get("label", "")), Relationships.text_vars(career.data))
	var v := UiKit.modal(self, "Watch an ad?")
	var t := UiKit.label("Watch a short ad to choose \"%s\". The other choices are free." % label, 30)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var modal := UiKit.modal_root(v)
	var note := UiKit.label("", 24, UiKit.MUTED)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var watch := UiKit.primary("Watch an Ad to Choose This", func() -> void: pass, "play")
	var back := UiKit.button("Not Now", func() -> void:
		if modal != null:
			modal.queue_free())
	watch.pressed.connect(func() -> void:
		watch.disabled = true
		back.disabled = true
		var ok: bool = await AdManager.show_rewarded(AdManager.PRACTICE_50)
		# Closed early = no reward, no choice. Couldn't play = free fallback.
		var failed := AdManager.last_rewarded_result == AdBackend.FAILED
		if ok or (failed and MonetizationConfig.PRACTICE_50_FREE_IF_NO_AD):
			if modal != null:
				modal.name = "ClosingModal"  # _pick opens a new "Modal"
				modal.queue_free()
			_pick(index)
			return
		back.disabled = false
		watch.disabled = not AdManager.is_rewarded_ready()
		note.text = "No reward this time, so nothing was chosen. Pick again when you're ready.")
	v.add_child(watch)
	v.add_child(note)
	v.add_child(back)


func _pick(index: int) -> void:
	if get_node_or_null("Modal") != null:
		return
	var c := career.data
	var before := {}
	for k in CareerData.STAT_NAMES:
		before[k] = c.stat(k)
	var s := career.current_scenario()
	var choice: Dictionary = s.get("choices", [])[index]
	var vars := Relationships.text_vars(c)
	var out := career.choose(index)
	if out.get("challenge", false):
		_challenge_intro(choice, out)
		return
	if (out.get("reasons", []) as Array).is_empty():
		_toast(CareerContent.fill(str(s.get("title", "")), vars), CareerContent.fill(str(choice.get("label", "")), vars), out)
		go_to_current()
		return
	var v := UiKit.modal(self, CareerContent.fill(str(choice.get("label", "")), vars))
	var r := UiKit.label(CareerContent.fill(str(out.get("result", "")), vars), 30)
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
	if int(out.get("followers", 0)) != 0:
		v.add_child(_followers_chip(int(out["followers"])))
	if int(out.get("money", 0)) != 0:
		v.add_child(CareerUi.money_chip(int(out["money"])))
	if not (out.get("relationships", {}) as Dictionary).is_empty():
		v.add_child(CareerUi.rel_chips(c, out["relationships"]))
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


## A choice with no full result: a toast with what moved, on the next screen.
## (The result text stays readable in the Hub's "Recent choices".)
func _toast(title: String, label: String, out: Dictionary) -> void:
	var toast := get_node_or_null("/root/Toast")
	if toast == null:
		return
	toast.show_with(title.to_upper(), label, change_flow(career.data, out), "check", 1.8)


## Everything a choice changed as one flow of chips (toast, Recent choices).
static func change_flow(c: CareerData, out: Dictionary, size := 22) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", 8)
	f.add_theme_constant_override("v_separation", 8)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var applied: Dictionary = (out.get("applied", {}) as Dictionary).duplicate()
	applied.erase("new_traits")
	var tmp := CareerUi.change_chips(applied, size)
	for ch in tmp.get_children():
		ch.reparent(f)
	tmp.free()
	var sp := int(out.get("skill_points", 0))
	if sp != 0:
		f.add_child(UiKit.chip("%+d Skill Points" % sp, UiKit.ACCENT if sp > 0 else UiKit.BAD, false, "skill", size))
	if int(out.get("money", 0)) != 0:
		f.add_child(CareerUi.money_chip(int(out["money"])))
	if int(out.get("followers", 0)) != 0:
		f.add_child(_followers_chip(int(out["followers"])))
	var rel: Dictionary = out.get("relationships", out.get("rel", {}))
	if not rel.is_empty():
		var tmp2 := CareerUi.rel_chips(c, rel, size)
		for ch in tmp2.get_children():
			ch.reparent(f)
		tmp2.free()
	return f


## "NEW TRAIT" card that pops in with a glow (also used by Results).
## A kick challenge on a choice card: what you'll kick, and pass / miss.
func _challenge_preview(c: CareerData, ch: Dictionary) -> Control:
	var t := career.tuning
	var kc := KickChallenge.of(ch)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(UiKit.chip(KickChallenge.summary(kc, career.profile().fg_range, t), UiKit.ACCENT, true, "range", 22))
	var pass_text := KickChallenge.block_text(c, kc.get("on_pass", {}), t,
		KickChallenge.default_buzz(str(kc.get("kind", "")), t))
	v.add_child(UiKit.label("Pass: " + pass_text, 22, UiKit.GOOD))
	v.add_child(UiKit.label("Miss: " + KickChallenge.block_text(c, kc.get("on_fail", {}), t), 22, UiKit.MUTED))
	return v


## Picked a kick challenge: what happens now, then the kick scene.
func _challenge_intro(choice: Dictionary, out: Dictionary) -> void:
	var c := career.data
	var vars := Relationships.text_vars(c)
	var kc := KickChallenge.of(choice)
	var v := UiKit.modal(self, str(kc.get("title", "KICK CHALLENGE")))
	if str(out.get("result", "")) != "":
		var r := UiKit.label(CareerContent.fill(str(out["result"]), vars), 30)
		r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(r)
	var tr := c.tryout
	var d: Array = tr.get("distances", [])
	var text := "Make %d of %d" % [int(tr.get("need", 3)), TryoutMode.total_kicks(tr)]
	if not d.is_empty():
		text += ": field goals from %s yards" % ", ".join(PackedStringArray(d.map(func(x: Variant) -> String: return str(int(x)))))
	var ko: Dictionary = tr.get("kickoffs", {})
	if not ko.is_empty():
		text += ", then %d kickoff%s (%d+ yards)" % [int(ko["count"]), "" if int(ko["count"]) == 1 else "s",
			roundi(float(ko["min_yards"]))]
	v.add_child(CareerUi.centered(text + ".", 28))
	if not (out.get("applied", {}) as Dictionary).is_empty():
		v.add_child(CareerUi.change_chips(out["applied"]))
	if not (out.get("modifiers", []) as Array).is_empty():
		v.add_child(CareerUi.modifier_chips(out["modifiers"]))
	var b := UiKit.primary("Kick", go_to_current, "next")
	v.add_child(b)
	if not OS.has_feature("mobile"):
		b.grab_focus.call_deferred()


static func _followers_chip(n: int) -> PanelContainer:
	return UiKit.chip(Followers.change_text(n), UiKit.group_color("personality") if n > 0 else UiKit.BAD, false,
		"social", 22)


static func trait_unlock_card(id: String) -> PanelContainer:
	var def := CareerContent.trait_def(id)
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", UiKit.panel_box(Brand.RED, Brand.INK_2))
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
