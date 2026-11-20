extends CareerScreen
## Stats & Traits: every stat with what it does (data/career/stats_info.json),
## and every trait, unlocked or locked, with its requirement, your progress
## toward it, its passive bonus and the scenarios it opens.


func _build(col: VBoxContainer) -> void:
	var c := career.data
	var info := CareerContent.stats_info()
	col.add_child(UiKit.title_block("STATS & TRAITS"))
	var list := UiKit.scroll_list(col)
	list.add_child(UiKit.section("RANGE"))
	list.add_child(CareerUi.range_strip(c, career.tuning, Callable(), false))
	list.add_child(UiKit.label("Field goal range: the longest kick a full-strength flick clears (no wind). "
		+ "Kickoff range: how far a full kickoff carries. Both grow with Power; rest and health add a "
		+ "few yards on game day.", 22, UiKit.MUTED))
	list.add_child(UiKit.stat_row("Skill points", "%d to spend  ·  %d earned this season" % [c.skill_points, c.sp_season],
		UiKit.ACCENT, "skill"))
	_followers(list)
	for g in CareerData.GROUP_KEYS:
		list.add_child(UiKit.section(str(CareerData.GROUP_NAMES[g]), UiKit.group_color(g)))
		list.add_child(UiKit.label(str(info.get("groups", {}).get(g, "")), 22, UiKit.MUTED))
		var parts := UiKit.card(UiKit.group_color(g), 6)
		var p: PanelContainer = parts[0]
		list.add_child(p)
		var v: VBoxContainer = parts[1]
		for k in CareerData.GROUP_KEYS[g]:
			v.add_child(CareerUi.stat_bar(CareerData.STAT_NAMES[k], c.stat(k), 26, 230.0))
			v.add_child(UiKit.label(str(info.get("stats", {}).get(k, "")), 22, UiKit.MUTED))

	list.add_child(UiKit.section("TRAITS  (%d of %d unlocked)" % [c.traits.size(), CareerContent.traits().size()]))
	for t in CareerContent.traits():
		list.add_child(_trait_panel(c, t))
	col.add_child(UiKit.button("Back", go_back, UiKit.SECONDARY, "back"))


func _trait_panel(c: CareerData, t: Dictionary) -> PanelContainer:
	var unlocked := c.has_trait(str(t["id"]))
	var parts := UiKit.card(UiKit.GOOD if unlocked else Color(1, 1, 1, 0.15), 6)
	var p: PanelContainer = parts[0]
	if unlocked:
		var box := UiKit.panel_box(UiKit.GOOD, Color(UiKit.GOOD.darkened(0.6), 0.9))
		box.shadow_color = Color(UiKit.GOOD, 0.25)
		p.add_theme_stylebox_override("panel", box)
	var v: VBoxContainer = parts[1]
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	v.add_child(head)
	head.add_child(UiIcons.rect(UiIcons.for_trait(str(t["id"])) if unlocked else "lock",
		UiKit.GOOD if unlocked else Color(UiKit.TEXT, 0.4), 40))
	var name := UiKit.label(str(t.get("name", "")).to_upper(), 32, UiKit.TEXT if unlocked else Color(UiKit.TEXT, 0.7),
		UiTokens.FONT_DISPLAY)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name)
	head.add_child(UiKit.chip("UNLOCKED" if unlocked else "LOCKED", UiKit.GOOD if unlocked else UiKit.MUTED,
		unlocked, "", 22))
	v.add_child(UiKit.label(str(t.get("description", "")), 24))
	# Requirement with progress, e.g. "Ambition 48 / 60".
	var req := PackedStringArray()
	for cond in t.get("unlock", []):
		var k := str(cond.get("stat", ""))
		req.append("%s %d / %d" % [CareerData.STAT_NAMES.get(k, k), roundi(c.stat(k)), int(cond.get("min", 0))])
	v.add_child(UiKit.label("Needs: " + "  +  ".join(req), 24, UiKit.GOOD if unlocked else UiKit.WARN))
	if not unlocked:
		# Progress toward each requirement.
		for cond in t.get("unlock", []):
			var k := str(cond.get("stat", ""))
			var need := maxf(float(cond.get("min", 1)), 1.0)
			var bar := ProgressBar.new()
			bar.show_percentage = false
			bar.max_value = need
			bar.value = minf(c.stat(k), need)
			bar.custom_minimum_size.y = 10
			bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var fill := StyleBoxFlat.new()
			fill.bg_color = UiKit.group_color(CareerData.group_of(k))
			fill.set_corner_radius_all(5)
			bar.add_theme_stylebox_override("fill", fill)
			v.add_child(bar)
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


## Followers: count and tier, the next tier, this season's sources, brand deals
## and what your following does.
func _followers(list: VBoxContainer) -> void:
	var c := career.data
	var t := career.tuning
	var col := UiKit.group_color("personality")
	list.add_child(UiKit.section("FOLLOWERS", col))
	var tier := Followers.tier(c, t)
	list.add_child(UiKit.stat_row("Followers", "%s  ·  %s" % [Followers.short(c.followers), Followers.tier_name(tier)],
		col, "social"))
	if tier + 1 < Followers.TIER_IDS.size():
		list.add_child(UiKit.stat_row("Next", Followers.tier_label(tier + 1, t), UiKit.MUTED))
	var gain := int(c.social.get("season_gain", 0))
	list.add_child(UiKit.stat_row("This season", ("+" if gain >= 0 else "") + Followers.short(gain), UiKit.MUTED))
	list.add_child(UiKit.stat_row("Most ever", Followers.short(maxi(int(c.social.get("peak", 0)), c.followers)),
		UiKit.MUTED))
	var src: Dictionary = c.social.get("season_sources", {})
	if not src.is_empty():
		var keys := src.keys()
		keys.sort_custom(func(a: Variant, b: Variant) -> bool: return absi(int(src[a])) > absi(int(src[b])))
		var parts := PackedStringArray()
		for k in keys.slice(0, 5):
			parts.append("%s %s%s" % [k, "+" if int(src[k]) >= 0 else "-", Followers.short(absi(int(src[k])))])
		list.add_child(UiKit.label("This season: " + ", ".join(parts), 22, UiKit.MUTED))
	for d in Followers.deals(c):
		var what: String = {"sp": "+%d skill point a week", "range": "+%.1f yd field goal range",
			"fun": "+%d Fun a week"}.get(str(d.get("kind", "")), "%s")
		list.add_child(UiKit.stat_row("Deal: %s" % d.get("name", ""), what % (float(d.get("value", 1.0))
			if str(d.get("kind")) == "range" else int(d.get("value", 1))), UiKit.GOOD, "money"))
	var fx := PackedStringArray(["Followers open new opportunities (deals, interviews, appearances)."])
	var bonus := Followers.progress_bonus(c, t)
	if bonus > 0.0:
		fx.append("End of season: +%d %s." % [roundi(bonus), {CareerData.STAGE_COLLEGE: "draft stock",
			CareerData.STAGE_PRO: "standing"}.get(c.stage, "recruiting")])
	if c.stage == CareerData.STAGE_PRO and Followers.salary_bonus(c, t) > 0.0:
		fx.append("New contracts pay %d%% more." % roundi(Followers.salary_bonus(c, t) * 100.0))
	if Followers.fan_pressure(c, t) > 0.0:
		fx.append("Fans are watching: a little more pressure in close 4th quarters.")
	list.add_child(UiKit.label(" ".join(fx), 22, UiKit.MUTED))
