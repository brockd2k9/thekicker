extends MenuScreen
## Achievements list: every entry in AchievementDefs, locked or unlocked with date.

const MONTHS := ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


func _build(col: VBoxContainer) -> void:
	var tracker := GameState.achievements
	# Progress: "5 / 18 unlocked" over a bar.
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	col.add_child(head)
	head.add_child(UiIcons.rect("achievements", UiKit.ACCENT, 44))
	var count := UiKit.label("%d / %d UNLOCKED" % [tracker.unlocked_count(), AchievementDefs.ALL.size()],
		30, UiKit.TEXT, UiTokens.FONT_DISPLAY)
	count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(count)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = AchievementDefs.ALL.size()
	bar.value = tracker.unlocked_count()
	bar.custom_minimum_size.y = 12
	col.add_child(bar)

	var list := UiKit.scroll_list(col)
	for def in AchievementDefs.ALL:
		list.add_child(_row(def, tracker))
	add_back_button(col)


func _row(def: Dictionary, tracker: AchievementTracker) -> Control:
	var id: String = def["id"]
	var unlocked := tracker.is_unlocked(id)
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := UiKit.panel_box()
	if unlocked:
		box.stripe = Brand.RED
		box.content_margin_left += Brand.STRIPE
	else:
		box.texture_color = Color(0, 0, 0, 0)
		p.modulate = Color(1, 1, 1, 0.6)
	p.add_theme_stylebox_override("panel", box)
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_theme_constant_override("separation", 18)
	p.add_child(h)

	var badge := TextureRect.new()
	badge.texture = UiKit.badge_texture(unlocked) if unlocked else UiIcons.texture("lock", Color(UiKit.MUTED, 0.7), 44)
	badge.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	badge.custom_minimum_size = Vector2(56, 56)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(badge)

	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	h.add_child(v)
	v.add_child(UiKit.label(str(def["name"]).to_upper(), 32, UiKit.TEXT if unlocked else UiKit.MUTED, UiTokens.FONT_DISPLAY))
	v.add_child(UiKit.label(def["description"], 26, UiKit.MUTED))
	var status := "Unlocked %s" % _date(tracker.unlocked_at(id)) if unlocked else "LOCKED"
	v.add_child(UiKit.label(status, 22, UiKit.ACCENT if unlocked else UiKit.MUTED, UiTokens.FONT_CONDENSED))
	return p


## Local calendar date, e.g. "Nov 18, 2026".
static func _date(unix_utc: int) -> String:
	var bias_min := int(Time.get_time_zone_from_system().get("bias", 0))
	var d := Time.get_date_dict_from_unix_time(unix_utc + bias_min * 60)
	return "%s %d, %d" % [MONTHS[int(d["month"]) - 1], d["day"], d["year"]]
