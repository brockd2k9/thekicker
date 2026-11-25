extends Node
## Autoload "StoreManager": the ONLY place the game touches purchases. Game
## code calls
##   StoreManager.is_available()               show / hide store entry points
##   StoreManager.products()                   what to list (title, price, owned...)
##   await StoreManager.purchase(product_id)   -> StoreBackend result string
##   await StoreManager.restore_purchases()    -> ids restored ("Restore Purchases")
## and never a billing SDK. Backends (scripts/monetization/store/): Google Play
## (Android), App Store (iOS), Mock (debug builds: grants without payment),
## None (Steam / desktop release). Products, prices and pack sizes:
## MonetizationConfig.STORE_PRODUCTS.
##
## What a purchase gives:
##   remove_ads (non-consumable): AdManager.set_ads_removed(true): no forced
##       ads; rewarded ads stay optional; free redos per game.
##   skill point packs (consumable): added to the open career, else the last
##       played one (GameState.store_grant_skill_points); with no career they
##       are banked and added when one opens (GameState.store_deliver).
## Every grant is keyed by its transaction id, so a store re-delivering a
## purchase, or Restore, can never grant it twice. The store transaction is
## finished (acknowledged / consumed) only after the grant is saved.
## Saved under the main save's "monetization" > "store" (to_dict / from_dict).
## Skill points never gate the story or core progression: they're earned by
## playing (about 45 a season); a pack only skips some of that.

signal purchase_finished(product_id: String, result: String)
signal purchases_restored(product_ids: Array)
## Products, prices, ownership or availability changed: refresh store UI.
signal store_changed

const REMOVE_ADS := "remove_ads"
const LOG_PREFIX := "[StoreManager] "
const MAX_LOG := 50
const MAX_TX := 200

## "google_play" / "app_store" / "mock" / "none".
var mode := "none"
var backend: StoreBackend = NoneStoreBackend.new()
## Non-consumables owned: product id -> true.
var owned := {}
## Bought skill points waiting for a career.
var sp_banked := 0
## Transaction ids already granted (newest last, capped).
var granted_tx: Array = []
## [{"id", "tx", "time", "sp", "to"}], newest last, capped.
var purchase_log: Array = []
## Where bought skill points go: Callable(n: int) -> String (career name, ""
## = not delivered). Default: GameState.store_grant_skill_points. Tests swap it.
var sp_sink: Callable = Callable()

var _busy := false
var _prices := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var os_name := OS.get_name()
	setup(pick_mode(MonetizationConfig.STORE_BACKEND_OVERRIDE, OS.has_feature("steam") or MonetizationConfig.NO_ADS_PLATFORM,
		os_name, OS.is_debug_build()))
	_start.call_deferred()


## Picks the backend. Debug builds use the test store (no payment) when
## STORE_DEBUG_GRANTS is on; release builds never do.
static func pick_mode(override: String, steam: bool, os_name: String, debug: bool) -> String:
	if override in ["mock", "none", "google_play", "app_store"]:
		return override  # setup() still refuses "mock" in a release build
	if steam:
		return "none"  # STEAM_SKILL_POINT_STORE "steam": no Steam backend yet
	if debug and MonetizationConfig.STORE_DEBUG_GRANTS:
		return "mock"
	if os_name == "Android":
		return "google_play"
	if os_name == "iOS":
		return "app_store"
	return "none"


func setup(m: String) -> void:
	if m == "mock" and not OS.is_debug_build():
		push_error(LOG_PREFIX + "the test store is debug-only; no store in this build")
		m = "none"
	match m:
		"mock":
			backend = MockStoreBackend.new(self)
		"google_play":
			backend = GooglePlayStoreBackend.new(self)
		"app_store":
			backend = AppStoreStoreBackend.new(self)
		_:
			backend = NoneStoreBackend.new(self, "no store on this build")
			m = "none"
	mode = m
	backend.state_changed.connect(func() -> void: store_changed.emit())
	debug_log("mode %s" % mode.to_upper())


func _start() -> void:
	await _async_backend().start()
	_prices = backend.prices()
	store_changed.emit()


# --- what game code uses ----------------------------------------------------------------

## The store can be opened (a backend that can sell, and something to sell).
func is_available() -> bool:
	return backend.is_available() and not products().is_empty()


func is_test_store() -> bool:
	return backend.is_test_store()


## Skill point packs are sold on this build (Steam: STEAM_SKILL_POINT_STORE).
func skill_point_store_enabled() -> bool:
	if OS.has_feature("steam") or MonetizationConfig.NO_ADS_PLATFORM:
		return false  # "steam" needs a Steam store backend first
	return true


## Products to list, in config order: [{id, kind, title, description,
## price_text, skill_points, owned, value_text}]. On a build without ads the
## ad-free product is never listed.
func products() -> Array:
	var out: Array = []
	var base_rate := _base_sp_per_dollar()
	for p in MonetizationConfig.STORE_PRODUCTS:
		if not bool(p.get("enabled", false)):
			continue
		var id := str(p["id"])
		var sp := int(p.get("skill_points", 0))
		if id == REMOVE_ADS and not AdManager.platform_has_ads():
			continue
		if sp > 0 and not skill_point_store_enabled():
			continue
		var value := ""
		var price := float(p.get("price_usd", 0.0))
		if sp > 0 and base_rate > 0.0 and price > 0.0:
			var bonus := roundi((sp / price / base_rate - 1.0) * 100.0)
			if bonus >= 5:
				value = "+%d%% more points per dollar" % bonus
		out.append({"id": id, "kind": str(p.get("kind", "consumable")), "title": str(p.get("title", id)),
			"description": str(p.get("description", "")), "skill_points": sp,
			"price_text": str(_prices.get(store_id(id), "$%.2f" % price)),
			"owned": owns(id), "value_text": value})
	return out


func owns(product_id: String) -> bool:
	return bool(owned.get(product_id, false))


## The id the store uses for a product on this platform.
func store_id(product_id: String) -> String:
	var p := product(product_id)
	var ids: Variant = p.get("store_ids", {})
	var plat := str({"google_play": "android", "app_store": "ios"}.get(mode, ""))
	if ids is Dictionary and (ids as Dictionary).has(plat):
		return str(ids[plat])
	return product_id


static func product(product_id: String) -> Dictionary:
	for p in MonetizationConfig.STORE_PRODUCTS:
		if str(p["id"]) == product_id:
			return p
	return {}


## Buys a product. Returns (await it) a StoreBackend result: "purchased",
## "cancelled", "failed", "pending", or "owned" (already have it).
func purchase(product_id: String) -> String:
	var p := product(product_id)
	if p.is_empty() or not is_available() or not _listed(product_id):
		debug_log("%s: not for sale here" % product_id)
		purchase_finished.emit(product_id, StoreBackend.FAILED)
		return StoreBackend.FAILED
	if _busy:
		return StoreBackend.FAILED
	if str(p.get("kind", "")) == "non_consumable" and owns(product_id):
		purchase_finished.emit(product_id, "owned")
		return "owned"
	_busy = true
	debug_log("%s: buying (%s)" % [product_id, mode])
	var r: Dictionary = await _async_backend().purchase(store_id(product_id), p)
	var result := str(r.get("result", StoreBackend.FAILED))
	if result == StoreBackend.PURCHASED:
		grant(product_id, str(r.get("tx", "")))
		await _async_backend().finish(store_id(product_id), str(r.get("tx", "")),
			str(p.get("kind", "")) == "consumable")
	else:
		debug_log("%s: %s %s" % [product_id, result, r.get("error", "")])
	_busy = false
	purchase_finished.emit(product_id, result)
	store_changed.emit()
	return result


## "Restore Purchases" (required on iOS): asks the store which
## non-consumables this account owns and grants any missing. Consumables are
## never restored (the stores don't). Returns the product ids restored.
func restore_purchases() -> Array:
	var restored: Array = []
	if not backend.is_available():
		purchases_restored.emit(restored)
		return restored
	var items: Array = await _async_backend().restore()
	for it in items:
		var id := _product_for_store_id(str(it.get("store_id", "")))
		if id == "" or str(product(id).get("kind", "")) != "non_consumable":
			continue
		if not owns(id):
			restored.append(id)
		grant(id, str(it.get("tx", "")))
	debug_log("restore: %d item(s) from the store, restored %s" % [items.size(), restored])
	purchases_restored.emit(restored)
	store_changed.emit()
	return restored


## Gives a purchased item (once per transaction id) and saves. Called for new
## purchases, restores and purchases the store delivers later (pending ones).
func grant(product_id: String, tx: String) -> void:
	if tx != "" and tx in granted_tx:
		debug_log("%s: transaction %s already granted" % [product_id, tx])
		if product_id == REMOVE_ADS:
			AdManager.set_ads_removed(true)
		return
	var p := product(product_id)
	var entry := {"id": product_id, "tx": tx, "time": int(Time.get_unix_time_from_system()), "sp": 0, "to": ""}
	if str(p.get("kind", "")) == "non_consumable":
		owned[product_id] = true
		if product_id == REMOVE_ADS:
			AdManager.set_ads_removed(true)
	var sp := int(p.get("skill_points", 0))
	if sp > 0:
		var to := _deliver_sp(sp)
		entry["sp"] = sp
		entry["to"] = to if to != "" else "banked"
		if to == "":
			sp_banked += sp
	if tx != "":
		granted_tx.append(tx)
		while granted_tx.size() > MAX_TX:
			granted_tx.pop_front()
	purchase_log.append(entry)
	while purchase_log.size() > MAX_LOG:
		purchase_log.pop_front()
	debug_log("granted %s%s" % [product_id, " (%d SP -> %s)" % [sp, entry["to"]] if sp > 0 else ""])
	_save()
	store_changed.emit()


## Banked skill points go to a career once one exists. Returns the points
## delivered (0 = still banked).
func deliver_banked() -> int:
	if sp_banked <= 0:
		return 0
	var n := sp_banked
	if _deliver_sp(n) == "":
		return 0
	sp_banked = 0
	debug_log("delivered %d banked skill points" % n)
	_save()
	store_changed.emit()
	return n


## Where the next skill points would go ("" = banked: no career).
func skill_points_target() -> String:
	var gs := get_node_or_null("/root/GameState") if is_inside_tree() else null
	return gs.daily_reward_target() if gs != null else ""


# --- save ---------------------------------------------------------------------------------

func to_dict() -> Dictionary:
	var d := {"owned": owned.duplicate(), "sp_banked": sp_banked, "granted_tx": granted_tx.duplicate(),
		"log": purchase_log.duplicate(true)}
	if backend is MockStoreBackend:
		d["test_ledger"] = (backend as MockStoreBackend).ledger.duplicate()
	return d


func from_dict(d: Dictionary) -> void:
	owned = {}
	var o: Variant = d.get("owned", {})
	if o is Dictionary:
		for k in o:
			if o[k] == true:
				owned[str(k)] = true
	var b: Variant = d.get("sp_banked", 0)
	sp_banked = maxi(int(b), 0) if (b is int or b is float) else 0
	granted_tx = (d.get("granted_tx") as Array).duplicate() if d.get("granted_tx") is Array else []
	purchase_log = (d.get("log") as Array).duplicate(true) if d.get("log") is Array else []
	if backend is MockStoreBackend and d.get("test_ledger") is Array:
		(backend as MockStoreBackend).ledger = (d["test_ledger"] as Array).duplicate()
	if owns(REMOVE_ADS):
		AdManager.ads_removed = true
	store_changed.emit()


# --- internals -----------------------------------------------------------------------------

func debug_log(msg: String) -> void:
	if MonetizationConfig.DEBUG_LOGGING or OS.is_debug_build():
		print(LOG_PREFIX + msg)


func status_text() -> String:
	return "%s · %s · owned %s · banked %d SP" % [mode.to_upper(), backend.status_text(),
		owned.keys(), sp_banked]


## See AdManager._async_backend(): coroutines through an untyped reference.
func _async_backend() -> Object:
	return backend


func _listed(product_id: String) -> bool:
	for p in products():
		if p["id"] == product_id:
			return true
	return false


func _product_for_store_id(sid: String) -> String:
	for p in MonetizationConfig.STORE_PRODUCTS:
		if store_id(str(p["id"])) == sid:
			return str(p["id"])
	return ""


## Skill points per dollar of the smallest enabled pack (the value baseline).
func _base_sp_per_dollar() -> float:
	var best := 0.0
	var smallest := 1 << 30
	for p in MonetizationConfig.STORE_PRODUCTS:
		var sp := int(p.get("skill_points", 0))
		var price := float(p.get("price_usd", 0.0))
		if bool(p.get("enabled", false)) and sp > 0 and price > 0.0 and sp < smallest:
			smallest = sp
			best = sp / price
	return best


func _deliver_sp(n: int) -> String:
	if sp_sink.is_valid():
		return str(sp_sink.call(n))
	var gs := get_node_or_null("/root/GameState") if is_inside_tree() else null
	return str(gs.store_grant_skill_points(n)) if gs != null else ""


func _save() -> void:
	var gs := get_node_or_null("/root/GameState") if is_inside_tree() else null
	if gs != null:
		gs.save_game()
