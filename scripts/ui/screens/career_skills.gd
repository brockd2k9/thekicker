extends CareerScreen
## Skills: spend skill points. Two tabs:
##   Attributes  the four football attributes (SkillPoints): level, cost of the
##               next point (rising with the level), what it changes, Upgrade
##               (confirmed with the same preview). From age 30 a Maintenance
##               section: each attribute's decline this season and the cost to
##               preserve it (Aging).
##   Perks       on-field abilities (Perks, data/career/perks.json): cost,
##               prerequisites ticked or crossed, owned / available / locked.

## The open tab (kept while you buy, so the screen reloads on the same tab).
static var tab := "attributes"

const STATS := ["power", "accuracy", "resilience", "toughness"]
const ICONS := {"power": "power", "accuracy": "accuracy", "resilience": "resilience", "toughness": "toughness"}


func _build(col: VBoxContainer) -> void:
	var c := career.data
	var t := career.tuning
	col.add_child(UiKit.title_block("SKILLS", "Spend skill points"))
	col.add_child(CareerUi.range_strip(c, t))
	var owned := c.perks.size()
	var tabs := CareerUi.button_row([
		UiKit.button("Attributes", _show.bind("attributes"), UiKit.PRIMARY if tab == "attributes" else UiKit.SECONDARY),
		UiKit.button("Perks (%d/%d)" % [owned, Perks.defs().size()], _show.bind("perks"),
			UiKit.PRIMARY if tab == "perks" else UiKit.SECONDARY)])
	col.add_child(tabs)
	var list := UiKit.scroll_list(col)
	list.add_theme_constant_override("separation", 12)
	if tab == "perks":
		_perks(list)
	else:
		_attributes(list)
	UiKit.stagger(list, 0.04)
	col.add_child(UiKit.button("Back", go_back, UiKit.SECONDARY, "back"))


func _show(which: String) -> void:
	if which != tab:
		tab = which
		Screens.go(Screens.CAREER_SKILLS)


func _attributes(list: VBoxContainer) -> void:
	var c := career.data
	var t := career.tuning
	if Aging.active(c, t):
		_maintenance(list)
	elif c.age + 1 >= t.aging_start_age and c.stage != CareerData.STAGE_RETIRED:
		list.add_child(UiKit.label("From age %d your attributes decline a little every season. "
			% t.aging_start_age + "You'll be able to preserve them here (Maintenance).", 22, UiKit.WARN))
	list.add_child(UiKit.section("ATTRIBUTES"))
	for s in STATS:
		list.add_child(_card(s))
	list.add_child(UiKit.label("Earn skill points by making kicks (long, clutch and game-winning ones "
		+ "earn more), practicing every week, training in the offseason, good seasons, and choices "
		+ "that work on your game. Each point costs more as an attribute climbs.", 22, UiKit.MUTED))


## Aging: what each attribute loses at the end of this season, and preserving it.
func _maintenance(list: VBoxContainer) -> void:
	var c := career.data
	var t := career.tuning
	list.add_child(UiKit.section("MAINTENANCE (AGE %d)" % c.age, UiKit.WARN))
	list.add_child(UiKit.label("At the end of every season your attributes slip a little, more each year. "
		+ "Preserve one to keep it where it is this season.", 22, UiKit.MUTED))
	for s in STATS:
		var name := str(CareerData.STAT_NAMES[s]).replace("Kicking ", "")
		var d := Aging.decline(c, s, t)
		var parts := UiKit.card(UiKit.WARN, 6)
		var v: VBoxContainer = parts[1]
		var row := UiKit.stat_row(name, "Preserved this season" if Aging.maintained(c, s)
			else "-%.1f at season end" % d, UiKit.GOOD if Aging.maintained(c, s) else UiKit.BAD, s)
		v.add_child(row)
		if not Aging.maintained(c, s) and d > 0.0:
			var cost := Aging.maintain_cost(c, s, t)
			var can := Aging.can_maintain(c, s, t)
			var b := UiKit.button("Preserve  (%d SP)" % cost if can else "Preserve: %d SP (you have %d)"
				% [cost, c.skill_points], _ask_maintain.bind(s), UiKit.PRIMARY if can else UiKit.SECONDARY, "check")
			b.disabled = not can
			v.add_child(b)
		list.add_child(parts[0])


func _ask_maintain(stat: String) -> void:
	var c := career.data
	var t := career.tuning
	var name := str(CareerData.STAT_NAMES[stat])
	UiKit.confirm(self, "PRESERVE %s?" % name.to_upper(), "%s stays at %d this season instead of dropping %.1f. Costs %d skill points."
		% [name, roundi(c.stat(stat)), Aging.decline(c, stat, t), Aging.maintain_cost(c, stat, t)], "Preserve", func() -> void:
			Aging.maintain(c, stat, t)
			career.save()
			Screens.go(Screens.CAREER_SKILLS))


# --- perks --------------------------------------------------------------------------

func _perks(list: VBoxContainer) -> void:
	var c := career.data
	list.add_child(UiKit.label("Perks are small on-field edges bought with skill points. Each needs its "
		+ "prerequisites first: attributes, other perks, a personality trait or a stage.", 22, UiKit.MUTED))
	var groups := {"owned": [], "available": [], "locked": []}
	for d in Perks.defs():
		var id := str(d.get("id", ""))
		var key := "owned" if Perks.owned(c, id) else ("available" if Perks.requirements_met(c, d) else "locked")
		groups[key].append(d)
	for key in ["available", "owned", "locked"]:
		if groups[key].is_empty():
			continue
		list.add_child(UiKit.section({"available": "AVAILABLE", "owned": "YOUR PERKS", "locked": "LOCKED"}[key]))
		for d in groups[key]:
			list.add_child(_perk_card(d, key))


func _perk_card(d: Dictionary, state: String) -> PanelContainer:
	var c := career.data
	var id := str(d.get("id", ""))
	var col: Color = UiKit.GOOD if state == "owned" else (UiKit.ACCENT if state == "available" else Color(1, 1, 1, 0.15))
	var parts := UiKit.card(col, 6)
	var v: VBoxContainer = parts[1]
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(UiIcons.rect(str(d.get("icon", "skill")), col if state != "locked" else UiKit.MUTED, 40))
	var name := UiKit.label(str(d.get("name", id)), 32, UiKit.TEXT if state != "locked" else UiKit.MUTED, UiTokens.FONT_DISPLAY)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name)
	head.add_child(UiKit.chip("OWNED" if state == "owned" else "%d SP" % int(d.get("cost", 0)),
		UiKit.GOOD if state == "owned" else col, state == "owned", "", 22))
	v.add_child(head)
	v.add_child(UiKit.label(str(d.get("description", "")), 24))
	v.add_child(UiKit.label(_cap(Perks.effect_text(d)), 22, UiKit.GOOD))
	if state != "owned":
		var reqs := HFlowContainer.new()
		reqs.add_theme_constant_override("h_separation", 8)
		reqs.add_theme_constant_override("v_separation", 6)
		reqs.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for r in Perks.requirements(c, d):
			reqs.add_child(UiKit.chip(str(r["text"]), UiKit.GOOD if r["met"] else UiKit.BAD, false,
				"check" if r["met"] else "lock", 20))
		v.add_child(reqs)
	if state == "available":
		var can := Perks.can_buy(c, id)
		var b := UiKit.button("Get %s  (%d SP)" % [d.get("name", id), int(d.get("cost", 0))] if can
			else "Needs %d SP (you have %d)" % [int(d.get("cost", 0)), c.skill_points], _ask_perk.bind(id),
			UiKit.PRIMARY if can else UiKit.SECONDARY, "skill")
		b.disabled = not can
		v.add_child(b)
	return parts[0]


static func _cap(s: String) -> String:
	return s.substr(0, 1).to_upper() + s.substr(1) if s != "" else s


func _ask_perk(id: String) -> void:
	var d := Perks.def(id)
	UiKit.confirm(self, "GET %s?" % str(d.get("name", id)).to_upper(), "%s\n%s\nCosts %d skill points."
		% [d.get("description", ""), _cap(Perks.effect_text(d)), int(d.get("cost", 0))], "Get Perk", func() -> void:
			Perks.buy(career.data, id)
			career.save()
			Screens.go(Screens.CAREER_SKILLS))


func _card(stat: String) -> PanelContainer:
	var c := career.data
	var t := career.tuning
	var gc := UiKit.group_color(CareerData.FOOTBALL)
	var parts := UiKit.card(gc, 8)
	var v: VBoxContainer = parts[1]
	var bar := StatBar.new(stat, str(CareerData.STAT_NAMES[stat]), c.stat(stat), gc, 28)
	v.add_child(bar)
	var cost := SkillPoints.cost(c, stat, t)
	if cost == 0:
		v.add_child(UiKit.label("Maxed out.", 24, UiKit.MUTED))
		return parts[0]
	for line in SkillPoints.preview(c, stat, t):
		v.add_child(_preview_row(line))
	var can := SkillPoints.affordable(c, stat, t)
	var b := UiKit.button("Upgrade  (%d SP)" % cost, _ask.bind(stat),
		UiKit.PRIMARY if can else UiKit.SECONDARY, "skill")
	b.disabled = not can
	if not can:
		b.text = "Next point: %d SP  (you have %d)" % [cost, c.skill_points]
	v.add_child(b)
	bar.preview(1.0 if can else 0.0)
	return parts[0]


## "FG range   46.0 yd  ->  46.6 yd"
func _preview_row(line: Dictionary) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var n := UiKit.label(str(line["label"]), 24, UiKit.MUTED)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(n)
	var val := UiKit.label("%s  →  %s" % [line["now"], line["next"]], 24, UiKit.GOOD, UiTokens.FONT_CONDENSED)
	val.autowrap_mode = TextServer.AUTOWRAP_OFF
	h.add_child(val)
	return h


## Confirm: the preview again, +1, and +5 when affordable.
func _ask(stat: String) -> void:
	if get_node_or_null("Modal") != null:
		return
	var c := career.data
	var t := career.tuning
	var name := str(CareerData.STAT_NAMES[stat])
	var v := UiKit.modal(self, "UPGRADE %s?" % name.to_upper())
	for line in SkillPoints.preview(c, stat, t):
		v.add_child(_preview_row(line))
	var root := UiKit.modal_root(v)
	var one := SkillPoints.cost(c, stat, t)
	v.add_child(UiKit.primary("+1 %s  (%d SP)" % [name.replace("Kicking ", ""), one], func() -> void:
		root.queue_free()
		_buy(stat, 1), "skill"))
	var five := _cost_of(stat, 5)
	if five > 0 and five <= c.skill_points:
		v.add_child(UiKit.button("+5  (%d SP)" % five, func() -> void:
			root.queue_free()
			_buy(stat, 5)))
	v.add_child(UiKit.button("Cancel", root.queue_free))


## SP for the next n points (0 if it would pass the max).
func _cost_of(stat: String, n: int) -> int:
	var t := career.tuning
	var lvl := career.data.stat(stat)
	if lvl + n > t.attribute_max + 0.001:
		return 0
	var total := 0
	for i in n:
		total += SkillPoints.cost_at(lvl + i, t)
	return total


func _buy(stat: String, n: int) -> void:
	for i in n:
		if not SkillPoints.upgrade(career.data, stat, career.tuning):
			break
	career.save()
	Screens.go(Screens.CAREER_SKILLS)
