extends CareerScreen
## Skills: spend skill points on the four football attributes (SkillPoints).
## Each attribute card shows its level, the cost of the next point (rising
## with the level) and what that point changes (FG / kickoff range, aim,
## pressure, wind); Upgrade asks for confirmation with the same preview.
## Perks and aging maintenance get their own sections in Step 3.

const STATS := ["power", "accuracy", "resilience", "toughness"]
const ICONS := {"power": "power", "accuracy": "accuracy", "resilience": "resilience", "toughness": "toughness"}


func _build(col: VBoxContainer) -> void:
	var c := career.data
	var t := career.tuning
	col.add_child(UiKit.title_block("SKILLS", "Spend skill points"))
	col.add_child(CareerUi.range_strip(c, t))
	var list := UiKit.scroll_list(col)
	list.add_theme_constant_override("separation", 12)
	list.add_child(UiKit.section("ATTRIBUTES"))
	for s in STATS:
		list.add_child(_card(s))
	list.add_child(UiKit.label("Earn skill points by making kicks (long, clutch and game-winning ones "
		+ "earn more), practicing every week, training in the offseason, good seasons, and choices "
		+ "that work on your game. Each point costs more as an attribute climbs.", 22, UiKit.MUTED))
	UiKit.stagger(list, 0.04)
	col.add_child(UiKit.button("Back", go_back, UiKit.SECONDARY, "back"))


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
