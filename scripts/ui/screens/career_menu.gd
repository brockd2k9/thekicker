extends MenuScreen
## Career Mode menu: Continue Career + three save slots (Play / New / Delete).
## Debug builds also get the Career Debug (tuning) screen.


func _build(col: VBoxContainer) -> void:
	GameState.career = null
	if not GameState.settings.career_tutorial_seen:
		Screens.go(Screens.CAREER_TUTORIAL)
		return
	var list := UiKit.scroll_list(col)
	var last := CareerSave.last_slot()
	if last > 0:
		var s := CareerSave.summary(last)
		var cont := UiKit.button("Continue: %s" % s.get("name", ""), _play.bind(last), UiKit.PRIMARY, "play")
		list.add_child(cont)
		if not OS.has_feature("mobile"):
			cont.grab_focus.call_deferred()
	for slot in range(1, CareerSave.SLOT_COUNT + 1):
		list.add_child(_slot_panel(slot))
	list.add_child(UiKit.button("How Career Mode Works", Screens.go.bind(Screens.CAREER_TUTORIAL),
		UiKit.SECONDARY, "info"))
	# The thumb-measuring drill (calibration): in every build, so it works in
	# the web build and a release APK too. Remove once the swipe model is fitted.
	list.add_child(UiKit.button("Thumb Drill (calibration)", Screens.go.bind(Screens.CAREER_DRILL),
		UiKit.SECONDARY, "accuracy"))
	if OS.is_debug_build():
		list.add_child(UiKit.button("Debug: Career Tuning", Screens.go.bind(Screens.CAREER_DEBUG),
			UiKit.SECONDARY, "settings"))
	add_back_button(col)


func _slot_panel(slot: int) -> PanelContainer:
	var s := CareerSave.summary(slot)
	# Each slot wears its stage's color (Friday / Saturday / Sunday).
	var stage_col: Color = UiTokens.for_stage(str(s.get("stage", "")))["accent"] if not s.get("empty", true) \
		else Color(UiKit.TEXT, 0.2)
	var parts := UiKit.card(stage_col, 10)
	var p: PanelContainer = parts[0]
	var v: VBoxContainer = parts[1]
	v.add_child(UiKit.label("SLOT %d" % slot, 22, UiKit.MUTED, UiTokens.FONT_CONDENSED))
	if s.get("empty", true):
		v.add_child(UiKit.label("Empty", 30, UiKit.MUTED))
		v.add_child(UiKit.button("New Career", _new.bind(slot), UiKit.SECONDARY, "plus"))
		return p
	v.add_child(UiKit.label(str(s["name"]).to_upper(), 38, UiKit.TEXT, UiTokens.FONT_DISPLAY))
	v.add_child(UiKit.label(_line(s), 26, stage_col.lightened(0.2)))
	v.add_child(CareerUi.button_row([
		UiKit.button("Play", _play.bind(slot), UiKit.SECONDARY, "play"),
		UiKit.button("Delete", _delete.bind(slot, str(s["name"])), UiKit.DANGER_KIND, "trash")]))
	return p


static func _line(s: Dictionary) -> String:
	var stage := str(s.get("stage", "")).replace("_", " ").capitalize()
	var when := "Offseason" if int(s.get("week", 0)) == 0 else "Week %d" % int(s.get("week", 1))
	return "%s  -  Season %d, %s  -  %s" % [stage, int(s.get("season", 1)), when, s.get("record", "0-0")]


func _play(slot: int) -> void:
	var m := CareerManager.load_slot(slot)
	if m == null:
		Toast.show_message("Can't open slot %d" % slot, "The save file could not be read.")
		return
	GameState.career = m
	Screens.go(Screens.CAREER_HUB)


func _new(slot: int) -> void:
	CareerNewScreen.slot = slot
	Screens.go(Screens.CAREER_NEW)


func _delete(slot: int, who: String) -> void:
	UiKit.confirm(self, "DELETE CAREER?", "%s in slot %d will be gone for good." % [who, slot],
		"Delete", func() -> void:
			CareerSave.delete_slot(slot)
			Screens.go(Screens.CAREER))
