extends "res://tests/test_case.gd"
## Stage 3: StoreManager with the test store (MockStoreBackend, no dialogs):
## product config and pricing, purchases, grants (once per transaction),
## restore, banked skill points, the Steam rules and the saved state.

const STORE := preload("res://scripts/autoload/store_manager.gd")
const C := preload("res://scripts/monetization/monetization_config.gd")


## A fresh StoreManager on the test store. Skill points go to `sink` (a
## CareerData or null = no career: banked) instead of a real career save.
func _store(sink: CareerData = null) -> Node:
	var s: Node = STORE.new()
	s.setup("mock")
	(s.backend as MockStoreBackend).confirm = false
	s.sp_sink = func(n: int) -> String:
		if sink == null:
			return ""
		sink.skill_points += n
		return "Test Career"
	return s


func _reset_ads() -> void:
	AdManager.ads_removed = false


func test_products_and_pricing() -> void:
	var ids := {}
	var packs: Array = []
	for p in C.STORE_PRODUCTS:
		check(not ids.has(p["id"]), "unique id %s" % p["id"])
		ids[p["id"]] = true
		check(float(p.get("price_usd", 0.0)) > 0.0, "%s has a price" % p["id"])
		if int(p.get("skill_points", 0)) > 0:
			eq(p["kind"], "consumable", "%s is consumable" % p["id"])
			packs.append(p)
	var ra := STORE.product("remove_ads")
	eq(ra.get("kind"), "non_consumable", "remove_ads is a one-time purchase")
	eq(ra.get("title"), "Remove Forced Ads", "named 'Remove Forced Ads', not 'No Ads'")
	eq(float(ra.get("price_usd", 0.0)), 9.99, "remove_ads $9.99")
	var sp50 := STORE.product("skill_points_50")
	check(sp50.get("enabled", false) and int(sp50["skill_points"]) == 50 and float(sp50["price_usd"]) == 4.99,
		"50 skill points for $4.99, on sale")
	# Bigger packs never give fewer points per dollar.
	var last_rate := 0.0
	var last_size := 0
	for p in packs:
		var rate := float(p["skill_points"]) / float(p["price_usd"])
		check(int(p["skill_points"]) > last_size, "packs listed smallest first")
		check(rate >= last_rate - 0.001, "%s is at least as good a deal as the smaller pack" % p["id"])
		last_rate = rate
		last_size = int(p["skill_points"])


func test_buy_skill_points_goes_to_the_career() -> void:
	var c := CareerData.create("Buyer", CareerTuning.get_default())
	var before := c.skill_points
	var s := _store(c)
	eq(await s.purchase("skill_points_50"), StoreBackend.PURCHASED, "bought")
	eq(c.skill_points - before, 50, "+50 skill points to the career")
	eq(s.sp_banked, 0, "nothing banked")
	eq(s.purchase_log.size(), 1, "logged")
	eq(await s.purchase("skill_points_50"), StoreBackend.PURCHASED, "consumables can be bought again")
	eq(c.skill_points - before, 100, "+50 more")
	s.free()


func test_no_career_banks_then_delivers() -> void:
	var s := _store(null)
	await s.purchase("skill_points_50")
	eq(s.sp_banked, 50, "banked with no career")
	var c := CareerData.create("Later", CareerTuning.get_default())
	var before := c.skill_points
	s.sp_sink = func(n: int) -> String:
		c.skill_points += n
		return "Later"
	eq(s.deliver_banked(), 50, "delivered when a career exists")
	eq(c.skill_points - before, 50, "career got them")
	eq(s.sp_banked, 0, "bank empty")
	s.free()


func test_cancel_and_fail_grant_nothing() -> void:
	var c := CareerData.create("Buyer", CareerTuning.get_default())
	var before := c.skill_points
	var s := _store(c)
	(s.backend as MockStoreBackend).next_result = StoreBackend.CANCELLED
	eq(await s.purchase("skill_points_50"), StoreBackend.CANCELLED, "cancelled")
	(s.backend as MockStoreBackend).next_result = StoreBackend.FAILED
	eq(await s.purchase("skill_points_50"), StoreBackend.FAILED, "failed")
	(s.backend as MockStoreBackend).next_result = StoreBackend.PENDING
	eq(await s.purchase("skill_points_50"), StoreBackend.PENDING, "pending")
	eq(c.skill_points, before, "no skill points")
	check(s.purchase_log.is_empty(), "nothing logged")
	eq(await s.purchase("not_a_product"), StoreBackend.FAILED, "unknown product")
	s.free()


func test_remove_forced_ads_and_restore() -> void:
	_reset_ads()
	var s := _store()
	eq(await s.purchase("remove_ads"), StoreBackend.PURCHASED, "bought")
	check(s.owns("remove_ads") and AdManager.ads_removed, "owned, forced ads off")
	eq(await s.purchase("remove_ads"), "owned", "can't buy it twice")
	# A reinstall: local state gone, the store account still has it.
	var ledger: Array = (s.backend as MockStoreBackend).ledger.duplicate()
	s.free()
	_reset_ads()
	var s2 := _store()
	(s2.backend as MockStoreBackend).ledger = ledger
	check(not s2.owns("remove_ads"), "fresh install: not owned yet")
	var restored: Array = await s2.restore_purchases()
	eq(restored, ["remove_ads"], "restored")
	check(AdManager.ads_removed, "forced ads off again")
	eq((await s2.restore_purchases()).size(), 0, "restoring again restores nothing new")
	s2.free()
	_reset_ads()


func test_a_transaction_is_granted_once() -> void:
	var c := CareerData.create("Buyer", CareerTuning.get_default())
	var before := c.skill_points
	var s := _store(c)
	s.grant("skill_points_50", "tx-1")
	s.grant("skill_points_50", "tx-1")  # the store re-delivers the same purchase
	eq(c.skill_points - before, 50, "granted once")
	s.free()


func test_restore_never_restores_consumables() -> void:
	var s := _store(null)
	(s.backend as MockStoreBackend).ledger = ["skill_points_50"]
	eq((await s.restore_purchases()).size(), 0, "consumables are not restored")
	eq(s.sp_banked, 0, "no free skill points")
	s.free()


func test_value_text_on_bigger_packs() -> void:
	var s := _store()
	for p in s.products():
		if p["id"] == "skill_points_50":
			eq(p["value_text"], "", "the base pack has no bonus line")
		check(str(p["price_text"]).begins_with("$"), "%s shows a price" % p["id"])
	s.free()


func test_pick_mode() -> void:
	eq(STORE.pick_mode("", true, "Windows", true), "none", "Steam: no store (skill point store 'off')")
	eq(STORE.pick_mode("", false, "Android", false), "google_play", "Android release: Google Play")
	eq(STORE.pick_mode("", false, "iOS", false), "app_store", "iOS release: App Store")
	eq(STORE.pick_mode("", false, "Linux", false), "none", "desktop release: none")
	eq(STORE.pick_mode("", false, "Android", true), "mock" if C.STORE_DEBUG_GRANTS else "google_play",
		"debug build: test store")


func test_real_backends_are_unavailable_until_wired() -> void:
	for m in ["google_play", "app_store"]:
		var s: Node = STORE.new()
		s.setup(m)
		check(not s.is_available(), "%s: store hidden until billing is wired" % m)
		eq(await s.purchase("skill_points_50"), StoreBackend.FAILED, "%s: nothing sold" % m)
		s.free()


func test_save_round_trip() -> void:
	_reset_ads()
	var s := _store(null)
	await s.purchase("remove_ads")
	await s.purchase("skill_points_50")
	var d: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	s.free()
	_reset_ads()
	var s2 := _store()
	s2.from_dict(d)
	check(s2.owns("remove_ads"), "owned kept")
	check(AdManager.ads_removed, "ads_removed follows ownership on load")
	eq(s2.sp_banked, 50, "banked kept (JSON float -> int)")
	eq(s2.granted_tx.size(), 2, "transactions kept")
	s2.from_dict({"owned": "bad", "sp_banked": "x", "granted_tx": 3})
	check(s2.owned.is_empty() and s2.sp_banked == 0 and s2.granted_tx.is_empty(), "bad data falls back")
	s2.free()
	_reset_ads()


func test_store_screen_compiles() -> void:
	var sc: Variant = load("res://scripts/ui/screens/store_screen.gd")
	check(sc is GDScript and (sc as GDScript).can_instantiate(), "store screen compiles")
