extends MenuScreen
## First-time Career Mode tutorial: a few skippable pages (text in
## data/career/tutorial.json), each with a small illustration built from the
## real career widgets. Finishing or skipping sets settings.career_tutorial_seen
## and opens the Career menu. Replay: "How Career Mode Works" on that menu.

var _page := 0
var _pages: Array = []
var _body: VBoxContainer
var _dots: Label
var _next: Button


func _build(col: VBoxContainer) -> void:
	_pages = CareerContent.file("tutorial.json").get("pages", [])
	_body = VBoxContainer.new()
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 22)
	col.add_child(_body)
	_dots = CareerUi.centered("", 30, UiKit.MUTED)
	col.add_child(_dots)
	_next = UiKit.button("Next", _advance, UiKit.PRIMARY)
	col.add_child(CareerUi.button_row([UiKit.button("Skip", _finish), _next]))
	_show()


func go_back() -> void:
	_finish()


func _show() -> void:
	for c in _body.get_children():
		c.queue_free()
	if _pages.is_empty():
		_finish.call_deferred()
		return
	var p: Dictionary = _pages[_page]
	_body.add_child(UiKit.title_block(str(p.get("title", "")), "Career Mode  ·  How it works"))
	var art := PanelContainer.new()
	art.add_child(_visual(str(p.get("visual", ""))))
	_body.add_child(art)
	_body.add_child(UiKit.label(str(p.get("body", "")), 30))
	var dots := ""
	for i in _pages.size():
		dots += ("o " if i == _page else ". ")
	_dots.text = "%s  %d / %d" % [dots.strip_edges(), _page + 1, _pages.size()]
	_next.text = "Let's Go" if _page == _pages.size() - 1 else "Next"


func _advance() -> void:
	if _page >= _pages.size() - 1:
		_finish()
		return
	_page += 1
	_show()


func _finish() -> void:
	GameState.settings.career_tutorial_seen = true
	GameState.settings_updated()
	Screens.go(Screens.CAREER)


func _visual(kind: String) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	match kind:
		"loop":
			for step in ["Hub: your week at a glance", "Off the field: 1-2 choices", "Game Day Outlook",
					"Game: watch, warm up, kick", "Results, then next week"]:
				v.add_child(UiKit.label(step, 28))
		"choice":
			var parts := CareerUi.card(func() -> void: pass)
			var cv: VBoxContainer = parts[1]
			cv.add_child(UiKit.label("Stay home and sleep", 30))
			cv.add_child(CareerUi.change_chips({"life": {"energy": 8, "social": -4}, "personality": {"ambition": 0.9}}))
			cv.add_child(CareerUi.modifier_chips(["rested"]))
			v.add_child(parts[0])
		"stats":
			var info: Dictionary = CareerContent.stats_info().get("groups", {})
			for g in [CareerData.LIFE, CareerData.FOOTBALL, CareerData.PERSONALITY]:
				v.add_child(UiKit.label(str(CareerData.GROUP_NAMES[g]).to_upper(), 26, UiKit.ACCENT))
				v.add_child(UiKit.label(str(info.get(g, "")), 22, UiKit.MUTED))
			v.add_child(UiKit.label("TRAITS", 26, UiKit.ACCENT))
			v.add_child(UiKit.label("Driven, Fan Favorite, Team Captain, Film Student and more.", 22, UiKit.MUTED))
		"kick":
			v.add_child(CareerUi.outlook_line({"label": "Rested", "detail": "+accuracy, steadier aim", "good": true}, 28))
			v.add_child(CareerUi.outlook_line({"label": "Warmed Up", "detail": "+power, +accuracy", "good": true}, 28))
			v.add_child(CareerUi.outlook_line({"label": "Exhausted", "detail": "-power, +aim wobble", "good": false}, 28))
			v.add_child(CareerUi.outlook_line({"label": "Stressed", "detail": "+pressure", "good": false}, 28))
		"road":
			for step in ["High school: get recruited", "Signing day: pick a college (or walk on / junior college)",
					"College: build draft stock", "Draft day (or a tryout)", "Pro: earn every contract",
					"Retire on your own terms"]:
				v.add_child(UiKit.label(step, 26))
	return v
