extends CareerScreen
## Stats & Traits: every stat with what it does (data/career/stats_info.json),
## and every trait, unlocked or locked, with its requirement, your progress
## toward it, its passive bonus and the scenarios it opens.


func _build(col: VBoxContainer) -> void:
	var c := career.data
	var info := CareerContent.stats_info()
	col.add_child(CareerUi.centered("STATS & TRAITS", 52, UiKit.ACCENT))
	var list := UiKit.scroll_list(col)
	for g in CareerData.GROUP_KEYS:
		list.add_child(UiKit.section(str(CareerData.GROUP_NAMES[g]).to_upper()))
		list.add_child(UiKit.label(str(info.get("groups", {}).get(g, "")), 22, UiKit.MUTED))
		var p := PanelContainer.new()
		list.add_child(p)
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 4)
		p.add_child(v)
		for k in CareerData.GROUP_KEYS[g]:
			v.add_child(CareerUi.stat_bar(CareerData.STAT_NAMES[k], c.stat(k), 26, 230.0))
			v.add_child(UiKit.label(str(info.get("stats", {}).get(k, "")), 22, UiKit.MUTED))

	list.add_child(UiKit.section("TRAITS  (%d of %d unlocked)" % [c.traits.size(), CareerContent.traits().size()]))
	for t in CareerContent.traits():
		list.add_child(_trait_panel(c, t))
	col.add_child(UiKit.button("Back", go_back))


func _trait_panel(c: CareerData, t: Dictionary) -> PanelContainer:
	var unlocked := c.has_trait(str(t["id"]))
	var p := PanelContainer.new()
	if unlocked:
		p.add_theme_stylebox_override("panel", UiKit._box(Color(0.06, 0.25, 0.12, 0.85), 16, UiKit.GOOD))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	p.add_child(v)
	var head := HBoxContainer.new()
	v.add_child(head)
	var name := UiKit.label(str(t.get("name", "")), 32, UiKit.ACCENT if unlocked else Color.WHITE)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name)
	var tag := UiKit.label("UNLOCKED" if unlocked else "LOCKED", 22, UiKit.GOOD if unlocked else UiKit.MUTED)
	tag.autowrap_mode = TextServer.AUTOWRAP_OFF
	head.add_child(tag)
	v.add_child(UiKit.label(str(t.get("description", "")), 24))
	# Requirement with progress, e.g. "Ambition 48 / 60".
	var req := PackedStringArray()
	for cond in t.get("unlock", []):
		var k := str(cond.get("stat", ""))
		req.append("%s %d / %d" % [CareerData.STAT_NAMES.get(k, k), roundi(c.stat(k)), int(cond.get("min", 0))])
	v.add_child(UiKit.label("Needs: " + "  +  ".join(req), 24, UiKit.GOOD if unlocked else Color(1.0, 0.8, 0.4)))
	v.add_child(UiKit.label("Bonus: " + passive_text(t.get("passive", {})), 24))
	if str(t.get("unlocks", "")) != "":
		v.add_child(UiKit.label("Opens: " + str(t["unlocks"]), 22, UiKit.MUTED))
	return p


## "-wind effect", "+15% Football gains", "Misses rattle you 30% less".
static func passive_text(passive: Dictionary) -> String:
	var parts := PackedStringArray()
	var fx: Dictionary = passive.get("profile", {})
	if not fx.is_empty():
		parts.append(KickProfile.describe(fx))
	var gains: Dictionary = passive.get("gains", {})
	for k in gains:
		var name := str(CareerData.GROUP_NAMES.get(k, CareerData.STAT_NAMES.get(k, k))).replace("Kicking ", "")
		parts.append("%+d%% %s gains" % [roundi(float(gains[k]) * 100.0), name])
	var ms := float(passive.get("miss_streak", 0.0))
	if ms != 0.0:
		parts.append("Misses rattle you %d%% %s" % [roundi(absf(ms) * 100.0), "less" if ms < 0.0 else "more"])
	return ", ".join(parts) if not parts.is_empty() else "-"
