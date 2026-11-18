extends MenuScreen
## Career Mode menu: Continue Career + three save slots (Play / New / Delete).
## Debug builds also get the Career Debug (tuning) screen.


func _build(col: VBoxContainer) -> void:
	GameState.career = null
	var list := UiKit.scroll_list(col)
	var last := CareerSave.last_slot()
	if last > 0:
		var s := CareerSave.summary(last)
		var cont := UiKit.button("Continue: %s" % s.get("name", ""), _play.bind(last))
		list.add_child(cont)
		if not OS.has_feature("mobile"):
			cont.grab_focus.call_deferred()
	for slot in range(1, CareerSave.SLOT_COUNT + 1):
		list.add_child(_slot_panel(slot))
	if OS.is_debug_build():
		list.add_child(UiKit.button("Debug: Career Tuning", Screens.go.bind(Screens.CAREER_DEBUG),
			Color(0.35, 0.25, 0.5)))
	add_back_button(col)


func _slot_panel(slot: int) -> PanelContainer:
	var p := PanelContainer.new()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	var s := CareerSave.summary(slot)
	v.add_child(UiKit.label("SLOT %d" % slot, 24, UiKit.MUTED))
	if s.get("empty", true):
		v.add_child(UiKit.label("Empty", 32))
		v.add_child(UiKit.button("New Career", _new.bind(slot)))
		return p
	v.add_child(UiKit.label(str(s["name"]), 36, UiKit.ACCENT))
	v.add_child(UiKit.label(_line(s), 26))
	v.add_child(CareerUi.button_row([
		UiKit.button("Play", _play.bind(slot)),
		UiKit.button("Delete", _delete.bind(slot, str(s["name"])), UiKit.DANGER)]))
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
