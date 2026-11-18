extends MenuScreen
## Achievements list: every entry in AchievementDefs, locked or unlocked with date.

const MONTHS := ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


func _build(col: VBoxContainer) -> void:
	var tracker := GameState.achievements
	var count := UiKit.label("%d / %d unlocked" % [tracker.unlocked_count(), AchievementDefs.ALL.size()],
		28, UiKit.MUTED)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(count)

	var list := UiKit.scroll_list(col)
	for def in AchievementDefs.ALL:
		list.add_child(_row(def, tracker))
	add_back_button(col)


func _row(def: Dictionary, tracker: AchievementTracker) -> Control:
	var id: String = def["id"]
	var unlocked := tracker.is_unlocked(id)
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not unlocked:
		p.modulate = Color(1, 1, 1, 0.55)
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_theme_constant_override("separation", 18)
	p.add_child(h)

	var badge := TextureRect.new()
	badge.texture = UiKit.badge_texture(unlocked)
	badge.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	badge.custom_minimum_size = Vector2(56, 56)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(badge)

	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	h.add_child(v)
	v.add_child(UiKit.label(def["name"], 34, Color.WHITE if unlocked else UiKit.MUTED))
	v.add_child(UiKit.label(def["description"], 26, UiKit.MUTED))
	var status := "Unlocked %s" % _date(tracker.unlocked_at(id)) if unlocked else "LOCKED"
	v.add_child(UiKit.label(status, 24, UiKit.GOOD if unlocked else UiKit.MUTED))
	return p


## Local calendar date, e.g. "Nov 18, 2026".
static func _date(unix_utc: int) -> String:
	var bias_min := int(Time.get_time_zone_from_system().get("bias", 0))
	var d := Time.get_date_dict_from_unix_time(unix_utc + bias_min * 60)
	return "%s %d, %d" % [MONTHS[int(d["month"]) - 1], d["day"], d["year"]]
