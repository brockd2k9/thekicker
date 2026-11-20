class_name CareerDebugScreen
extends MenuScreen
## Career tuning screen (debug builds only; reached from the Career Mode screen).
## Drag any stat, toggle traits / game-day modifiers / injury / miss streak, and
## the KickProfile readout and Game Day Outlook update live. "Try Kicks" plays
## practice kicks with exactly this profile. Load/Save use the real career
## slots, so this also tests save/load.
## Balance numbers themselves live in res://tuning/career_tuning.tres.

const KICK_TUNING := "res://tuning/kick_tuning.tres"

## Survives the trip to "Try Kicks" and back.
static var scratch: CareerData
static var miss_streak: int = 0
static var slot: int = 1

var _tuning := CareerTuning.get_default()
var _kick_tuning: KickTuning
var _readout: Label
var _outlook: VBoxContainer
var _status: Label
var _list: VBoxContainer


func _build(col: VBoxContainer) -> void:
	var kt: Variant = load(KICK_TUNING)
	_kick_tuning = kt if kt is KickTuning else KickTuning.new()
	if scratch == null:
		scratch = CareerData.create("Debug Kicker", _tuning)
	CareerContent.validate()

	# Live readout (stays on screen while the list below scrolls).
	var panel := PanelContainer.new()
	col.add_child(panel)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 6)
	panel.add_child(pv)
	_readout = UiKit.label("", CareerUi.SMALL, Color.WHITE)
	pv.add_child(_readout)
	_outlook = VBoxContainer.new()
	_outlook.add_theme_constant_override("separation", 2)
	pv.add_child(_outlook)

	# Slot row.
	var slots := HBoxContainer.new()
	slots.add_theme_constant_override("separation", 12)
	col.add_child(slots)
	var slot_b := UiKit.button("Slot %d" % slot, func() -> void: pass)
	slot_b.pressed.connect(func() -> void:
		slot = slot % CareerSave.SLOT_COUNT + 1
		slot_b.text = "Slot %d" % slot)
	for b in [slot_b, UiKit.button("Load", _load_slot), UiKit.button("Save", _save_slot)]:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slots.add_child(b)
	_status = UiKit.label("", 22, UiKit.MUTED)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_status)

	_list = UiKit.scroll_list(col)
	_fill_list()

	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 12)
	col.add_child(bottom)
	for b in [UiKit.button("Try Kicks", Screens.go.bind(Screens.CAREER_DEBUG_KICKS)),
			UiKit.button("Back", go_back)]:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bottom.add_child(b)
	_refresh()


func go_back() -> void:
	Screens.go(Screens.CAREER)


## The profile this screen describes (also used by "Try Kicks").
static func current_profile(streak: int) -> KickProfile:
	return KickProfile.build(scratch, CareerTuning.get_default(), {"miss_streak": streak})


func _fill_list() -> void:
	for c in _list.get_children():
		c.queue_free()
	for g in CareerData.GROUP_KEYS:
		_list.add_child(UiKit.section(str(CareerData.GROUP_NAMES[g]).to_upper()))
		for key in CareerData.GROUP_KEYS[g]:
			_list.add_child(CareerUi.slider_row(CareerData.STAT_NAMES[key], scratch.stat(key),
				func(x: float) -> void:
					scratch.set_stat(key, x)
					_refresh()))

	_list.add_child(UiKit.section("RANGE PHYSICS"))
	_list.add_child(CareerUi.toggle_row("Full flick reaches the FG range (Load a slot, flip, Save to keep it)",
		scratch.range_physics, func(on: bool) -> void:
			scratch.range_physics = on
			_refresh()))

	_list.add_child(UiKit.section("GAME CONTEXT"))
	_list.add_child(CareerUi.slider_row("Misses in a row", miss_streak, func(x: float) -> void:
		miss_streak = int(x)
		_refresh(), 0, 5, 1))
	_list.add_child(CareerUi.toggle_row("Injured", scratch.is_injured(), func(on: bool) -> void:
		scratch.injury["weeks_left"] = 1 if on else 0
		_refresh()))
	_list.add_child(CareerUi.slider_row("Injury severity", float(scratch.injury["severity"]),
		func(x: float) -> void:
			scratch.injury["severity"] = x
			_refresh(), 0.0, 1.0, 0.05))

	_list.add_child(UiKit.section("TRAITS (on = unlocked)"))
	for t in CareerContent.traits():
		var id := str(t["id"])
		var text := "%s  (%s)" % [t.get("name", id), CareerStats.trait_requirement_text(t)]
		_list.add_child(CareerUi.toggle_row(text, scratch.has_trait(id), func(on: bool) -> void:
			scratch.traits.erase(id)
			if on:
				scratch.traits.append(id)
			_refresh()))
	_list.add_child(UiKit.button("Unlock Traits From Stats", func() -> void:
		var fresh := CareerStats.check_traits(scratch)
		_status.text = "Unlocked: %s" % (", ".join(fresh) if not fresh.is_empty() else "none")
		_fill_list()
		_refresh()))

	_list.add_child(UiKit.section("GAME-DAY MODIFIERS (this week)"))
	for m in CareerContent.modifiers():
		var id := str(m["id"])
		var text := "%s  (%s)" % [m.get("label", id), KickProfile.describe(m.get("effects", {}))]
		_list.add_child(CareerUi.toggle_row(text, id in scratch.week_modifiers,
			func(on: bool) -> void:
				scratch.week_modifiers.erase(id)
				if on:
					scratch.week_modifiers.append(id)
				_refresh()))

	_list.add_child(UiKit.button("Reset To New Career", func() -> void:
		scratch = CareerData.create("Debug Kicker", _tuning)
		miss_streak = 0
		_status.text = "Reset"
		_fill_list()
		_refresh()))


func _refresh() -> void:
	var p := current_profile(miss_streak)
	_readout.text = CareerUi.profile_text(p, _kick_tuning)
	for c in _outlook.get_children():
		c.queue_free()
	if p.outlook.is_empty():
		_outlook.add_child(UiKit.label("Outlook: nothing special", CareerUi.SMALL, UiKit.MUTED))
	for line in p.outlook:
		_outlook.add_child(CareerUi.outlook_line(line))


func _load_slot() -> void:
	var c := CareerSave.load_slot(slot)
	if c == null:
		_status.text = "Slot %d is empty" % slot
		return
	scratch = c
	_status.text = "Loaded slot %d: %s" % [slot, c.display_name()]
	_fill_list()
	_refresh()


func _save_slot() -> void:
	scratch.slot = slot
	var ok := CareerSave.save(scratch)
	_status.text = ("Saved to slot %d" % slot) if ok else "Save FAILED"
