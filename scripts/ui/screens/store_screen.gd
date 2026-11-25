class_name StoreScreen
extends MenuScreen
## Store: skill point packs and "Remove Forced Ads", plus Restore Purchases
## (required on iOS). Everything goes through the StoreManager autoload;
## products, prices and pack sizes are in MonetizationConfig.STORE_PRODUCTS.
## Open it with StoreScreen.open(from): Back returns there.
## Purchases are optional and say so: skill points are earned by playing too,
## and nothing in the story needs them. No links to outside payment (Apple
## requires its own In-App Purchase for digital goods).

static var return_to := Screens.MAIN_MENU

var _list: VBoxContainer
var _busy := false


static func open(from: String) -> void:
	return_to = from
	Screens.go(Screens.STORE)


func _build(col: VBoxContainer) -> void:
	GameState.store_deliver()
	_list = UiKit.scroll_list(col)
	_list.add_theme_constant_override("separation", 14)
	_fill()
	StoreManager.store_changed.connect(_refill)
	add_back_button(col)


func _exit_tree() -> void:
	if StoreManager.store_changed.is_connected(_refill):
		StoreManager.store_changed.disconnect(_refill)


func go_back() -> void:
	Screens.go(return_to)


func _refill() -> void:
	if _busy or _list == null:
		return
	for n in _list.get_children():
		n.queue_free()
	_fill()


func _fill() -> void:
	if not StoreManager.is_available():
		_list.add_child(UiKit.label("The store isn't available in this version.", 30, UiKit.MUTED))
		return
	if StoreManager.is_test_store():
		_list.add_child(BrandUi.banner("info", "Test store",
			"Debug build: purchases are free and only for testing. No payment is taken."))
	var sp_items: Array = []
	var other: Array = []
	for p in StoreManager.products():
		(sp_items if int(p["skill_points"]) > 0 else other).append(p)
	if not sp_items.is_empty():
		_list.add_child(UiKit.section("SKILL POINTS"))
		_list.add_child(UiKit.label("Skill points upgrade your attributes and buy perks. You earn them by "
			+ "playing too (about 45 a season); the story never needs bought ones.", 24, UiKit.MUTED))
		var to := StoreManager.skill_points_target()
		_list.add_child(UiKit.label("Bought skill points go to: %s" % to if to != ""
			else "No career yet: bought skill points wait and go to your next career.", 24, UiKit.TEXT))
		for p in sp_items:
			_list.add_child(_card(p))
	for p in other:
		_list.add_child(UiKit.section("ADS"))
		_list.add_child(_card(p))
	_list.add_child(UiKit.section("PURCHASES"))
	if OS.get_name() == "iOS" or MonetizationConfig.RESTORE_BUTTON_ON_ANDROID or StoreManager.is_test_store():
		_list.add_child(UiKit.button("Restore Purchases", _restore, UiKit.SECONDARY, "next"))
		_list.add_child(UiKit.label("Already bought Remove Forced Ads on this account? Restore it here.",
			22, UiKit.MUTED))


func _card(p: Dictionary) -> Control:
	var parts := UiKit.card()
	var v: VBoxContainer = parts[1]
	v.add_child(UiKit.label(str(p["title"]).to_upper(), 36, UiKit.TEXT, UiTokens.FONT_DISPLAY))
	if str(p["value_text"]) != "":
		v.add_child(UiKit.chip(str(p["value_text"]).to_upper(), UiKit.ACCENT, true, "star", 22))
	var d := UiKit.label(str(p["description"]), 24, UiKit.MUTED)
	v.add_child(d)
	if p["owned"]:
		v.add_child(UiKit.chip("OWNED", UiKit.GOOD, false, "check", 24))
	else:
		v.add_child(UiKit.primary("Buy  ·  %s" % p["price_text"], _buy.bind(str(p["id"])), "skill" if int(p["skill_points"]) > 0 else "check"))
	return parts[0]


func _buy(id: String) -> void:
	if _busy:
		return
	_busy = true
	var result: String = await StoreManager.purchase(id)
	_busy = false
	match result:
		StoreBackend.PURCHASED:
			var p := StoreManager.product(id)
			var sp := int(p.get("skill_points", 0))
			var to := StoreManager.skill_points_target()
			Toast.show_message("STORE", ("+%d skill points%s" % [sp, " for " + to if to != "" else " (banked)"])
				if sp > 0 else "%s: thank you!" % p.get("title", id), "check")
		StoreBackend.PENDING:
			Toast.show_message("STORE", "Payment pending. You'll get it once the store confirms it.")
		StoreBackend.CANCELLED:
			pass
		"owned":
			Toast.show_message("STORE", "You already own this.")
		_:
			Toast.show_message("STORE", "The purchase didn't go through. You were not charged.")
	_refill()


func _restore() -> void:
	if _busy:
		return
	_busy = true
	var restored: Array = await StoreManager.restore_purchases()
	_busy = false
	Toast.show_message("STORE", "Restored: %s" % ", ".join(restored.map(func(i): return StoreManager.product(i).get("title", i)))
		if not restored.is_empty() else "Nothing new to restore.")
	_refill()
