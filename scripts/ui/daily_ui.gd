class_name DailyUi
extends RefCounted
## Daily Challenge pieces shared by its screens, the main menu and the Career
## hub: the broadcast-style scenario card, the reward track (login calendar),
## the streak tiles, the "NEW" badge and the once-a-day popup. Built from the
## broadcast design system (BrandUi / BrandTheme); no colors of its own.


## The day's kick as a broadcast graphic: chips (DAILY, date, BOSS, tier),
## the situation, the kick in big type, then wind / weather / field / pressure.
static func scenario_card(d: DailyChallenge, retry := false) -> BrandCard:
	var sc := d.scenario()
	var card := BrandUi.card("accent")
	card.content.add_theme_constant_override("separation", Brand.SPACE_3)
	var chips := BrandUi.chip_flow()
	chips.add_child(BrandUi.chip("Daily challenge", "red", "calendar"))
	chips.add_child(BrandUi.chip(DailyClock.label(int(sc["day"])), "outline"))
	if bool(sc.get("boss", false)):
		chips.add_child(BrandUi.chip("Boss kick", "red", "flame"))
	if retry:
		chips.add_child(BrandUi.chip("Retry", "red", "repeat"))
	chips.add_child(BrandUi.chip("%s tier" % DailyScenario.TIERS[int(sc.get("tier", 0))], "neutral"))
	card.content.add_child(chips)
	card.content.add_child(BrandUi.text(str(sc.get("label", "")).to_upper(), "Eyebrow", Brand.GREY))
	var head := BrandUi.text(DailyScenario.headline(sc), "Title")
	card.content.add_child(head)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", Brand.SPACE_3)
	grid.add_theme_constant_override("v_separation", Brand.SPACE_2)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for cell in [["Wind", DailyScenario.wind_text(sc)], ["Weather", DailyScenario.weather_text(sc)],
			["Field", DailyScenario.field_text(sc)], ["Pressure", DailyScenario.pressure_text(sc)]]:
		grid.add_child(_fact(cell[0], cell[1]))
	card.content.add_child(grid)
	card.content.add_child(BrandUi.text("Goal: " + DailyScenario.goal_text(sc), "BodyStrong"))
	return card


static func _fact(caption: String, value: String) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(BrandTheme.label(caption, "Eyebrow", Brand.GREY))
	v.add_child(BrandUi.text(value, "BodyStrong"))
	return v


## "Make it: +4 skill points  ·  streak 6 -> 7"
static func reward_line(d: DailyChallenge) -> String:
	var n := d.streak + 1
	var sp := d.tuning.reward_for(n)
	var bonus := d.tuning.bonus_for(n)
	var s := "Success: +%d skill points" % sp
	if bonus > 0:
		s += " (day %d bonus +%d)" % [n, bonus]
	s += "  ·  streak %d -> %d" % [d.streak, n]
	return s


## What today's kicks allow, in one line.
static func attempts_line(d: DailyChallenge) -> String:
	match d.status():
		"retry":
			return "Your retry: the last kick of the day."
		"ready":
			if d.tuning.ad_retries_per_day > 0 and (d.ads.platform_has_ads() or d.tuning.no_ads_rule == "free"):
				return "One kick. Miss it and you can %s for one retry." % (
					"watch an optional ad" if d.retry_needs_ad() else "take")
			return "One kick. Make it count."
	return ""


## Current and longest streak, and today's state.
static func streak_tiles(d: DailyChallenge) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_3)
	row.add_child(_tile("Streak", d.streak, "days" if d.streak != 1 else "day", true))
	row.add_child(_tile("Longest", d.longest, "days" if d.longest != 1 else "day"))
	return row


static func _tile(caption: String, value: int, unit: String, highlight := false) -> BrandStatTile:
	var tile: BrandStatTile = load("res://scenes/ui/brand/stat_tile.tscn").instantiate()
	tile.caption = caption
	tile.value = float(value)
	tile.unit = unit
	tile.highlight = highlight
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return tile


## The login-calendar track: track_days cells (4 per row), each "DAY n" and
## its skill points; claimed days checked, today outlined in red, bonus days
## starred.
static func track(d: DailyChallenge) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", Brand.SPACE_2)
	grid.add_theme_constant_override("v_separation", Brand.SPACE_2)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for cell in d.track():
		grid.add_child(_day_cell(cell))
	return grid


static func _day_cell(cell: Dictionary) -> PanelContainer:
	var state := str(cell["state"])
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := ClippedBox.new()
	box.bg = Brand.INK_3 if state == "claimed" else Brand.INK_2
	box.stroke = Brand.RED if state == "today" else Brand.LINE
	box.stroke_width = Brand.STROKE * (2 if state == "today" else 1)
	box.cut_br = Brand.CUT_SMALL
	box.set_content_margin_all(Brand.SPACE_2)
	if int(cell["bonus"]) > 0:
		box.stripe = Brand.RED
		box.stripe_width = Brand.STRIPE
	p.add_theme_stylebox_override("panel", box)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(v)
	var top := BrandTheme.label("Day %d" % int(cell["n"]), "Eyebrow",
		Brand.WHITE if state == "today" else Brand.GREY)
	top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(top)
	var amt := BrandTheme.label("+%d" % int(cell["sp"]), "Subhead",
		Brand.GREY_DIM if state == "claimed" else (Brand.RED_HOT if int(cell["bonus"]) > 0 else Brand.WHITE))
	amt.add_theme_font_override("font", BrandTheme.font(Brand.FONT_NUMBER))
	amt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(amt)
	var icon := TextureRect.new()
	icon.texture = BrandIcons.texture("check" if state == "claimed" else ("star" if int(cell["bonus"]) > 0
		else ("play" if state == "today" else "lock")), Brand.WHITE if state != "next" else Brand.GREY_DIM, 28)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon.custom_minimum_size = Vector2(28, 28)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(icon)
	return p


## "NEW" when today's kick hasn't been tried (main menu, Career hub).
static func new_badge() -> BrandChip:
	return BrandUi.chip("New", "red")


## The once-a-day popup ("Today's challenge is up"): the scenario, the
## streak, Play / Later. Marks the day as shown (the caller saves).
static func popup(host: Node, d: DailyChallenge, on_play: Callable) -> void:
	d.mark_popup()
	GameState.save_game()
	var v := BrandUi.modal(host, "Today's Daily Challenge")
	var modal := UiKit.modal_root(v)
	var sc := d.scenario()
	v.add_child(BrandUi.text(str(sc.get("label", "")).to_upper(), "Eyebrow", Brand.GREY))
	v.add_child(BrandUi.text(DailyScenario.headline(sc), "Subhead"))
	v.add_child(BrandUi.text("%s  ·  %s" % [DailyScenario.wind_text(sc), DailyScenario.weather_text(sc)], "Body"))
	var streak := "Streak: %d day%s." % [d.streak, "" if d.streak == 1 else "s"] if d.streak > 0 else "Start a streak today."
	v.add_child(BrandUi.text(streak + "  " + reward_line(d).split("  ·  ")[0] + ".", "Caption", Brand.GREY))
	var later := BrandUi.button("Later", func() -> void: modal.queue_free(), "secondary")
	var play := BrandUi.button("Play", func() -> void:
		modal.queue_free()
		on_play.call(), "primary", "play")
	v.add_child(BrandUi.button_row([later, play]))
	play.size_flags_stretch_ratio = 2.0
	if not OS.has_feature("mobile"):
		play.grab_focus.call_deferred()
