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


## The week in one line for the intro card: "Day 3 of 7  ·  10 skill points
## on day 7" / "Day 7 of 7: make it for 10 skill points".
static func reward_line(d: DailyChallenge) -> String:
	var n := d.week_day_today()
	var w := d.tuning.week_days
	if n == w:
		return "Day %d of %d: make it for %d skill points." % [n, w, d.next_payout()]
	return "Day %d of %d  ·  %d skill points on day %d" % [n, w, d.next_payout(), w]


## Progress toward the payout: "3 more days to earn 10 skill points." (or
## the week just paid).
static func week_line(d: DailyChallenge) -> String:
	if d.week_paid_today():
		return "Week complete: %d skill points claimed. A new week starts tomorrow." % int(d.today.get("reward", 0))
	var left := d.days_to_payout()
	if left == 1 and d.can_kick_today():
		return "Make today's kick to earn %d skill points." % d.next_payout()
	return "%d more day%s to earn %d skill points." % [left, "" if left == 1 else "s", d.next_payout()]


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


## The week track: one slot per day, the prize slot (wider) at the end.
## Made days are filled red with a check, today's slot is outlined in red.
static func track(d: DailyChallenge) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Brand.SPACE_2)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for cell in d.track():
		row.add_child(_day_cell(cell))
	return row


static func _day_cell(cell: Dictionary) -> PanelContainer:
	var state := str(cell["state"])
	var prize := bool(cell["prize"])
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.size_flags_stretch_ratio = 1.9 if prize else 1.0
	p.custom_minimum_size.y = 96
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := ClippedBox.new()
	box.bg = Brand.RED if state == "done" else (Brand.INK_3 if prize else Brand.INK_2)
	box.stroke = Brand.RED_HOT if state == "today" or prize else Brand.LINE
	box.stroke_width = Brand.STROKE * (2 if state == "today" else 1)
	box.cut_br = Brand.CUT_SMALL
	box.set_content_margin_all(Brand.SPACE_1)
	p.add_theme_stylebox_override("panel", box)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(v)
	var text := ("+%d SP" % int(cell["sp"])) if prize else str(int(cell["n"]))
	var top := BrandTheme.label(text, "Subhead",
		Brand.GREY_DIM if state == "next" and not prize else Brand.WHITE)
	top.add_theme_font_override("font", BrandTheme.font(Brand.FONT_NUMBER))
	top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(top)
	var icon := TextureRect.new()
	var name := "check" if state == "done" else ("trophy" if prize else ("play" if state == "today" else "lock"))
	icon.texture = BrandIcons.texture(name, Brand.GREY_DIM if state == "next" and not prize else Brand.WHITE, 28)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon.custom_minimum_size = Vector2(28, 28)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(icon)
	return p


## "NEW" when today's kick hasn't been tried (main menu, Career hub).
static func new_badge() -> BrandChip:
	return BrandUi.chip("New", "red")


## The once-a-day popup ("Today's challenge is up"): the scenario, the
## day of the week, Play / Later. Marks the day as shown (the caller saves).
static func popup(host: Node, d: DailyChallenge, on_play: Callable) -> void:
	d.mark_popup()
	GameState.save_game()
	var v := BrandUi.modal(host, "Today's Daily Challenge")
	var modal := UiKit.modal_root(v)
	var sc := d.scenario()
	v.add_child(BrandUi.text(str(sc.get("label", "")).to_upper(), "Eyebrow", Brand.GREY))
	v.add_child(BrandUi.text(DailyScenario.headline(sc), "Subhead"))
	v.add_child(BrandUi.text("%s  ·  %s" % [DailyScenario.wind_text(sc), DailyScenario.weather_text(sc)], "Body"))
	v.add_child(BrandUi.text("Day %d of %d.  %s" % [d.week_day_today(), d.tuning.week_days, week_line(d)],
		"Caption", Brand.GREY))
	var later := BrandUi.button("Later", func() -> void: modal.queue_free(), "secondary")
	var play := BrandUi.button("Play", func() -> void:
		modal.queue_free()
		on_play.call(), "primary", "play")
	v.add_child(BrandUi.button_row([later, play]))
	play.size_flags_stretch_ratio = 2.0
	if not OS.has_feature("mobile"):
		play.grab_focus.call_deferred()
