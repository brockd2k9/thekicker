class_name MockStoreBackend
extends StoreBackend
## Debug builds: the "debug mode that grants items without payment". A
## confirmation card ("TEST PURCHASE, no payment"), then the item. Keeps a
## ledger of non-consumables bought, like a real store account, so Restore
## Purchases can be tested (StoreManager saves the ledger, debug only).
## Tests set confirm = false (no card) and next_result.

var confirm := true
## Forced result of the next purchase: "" (normal) or a StoreBackend result.
var next_result := ""
## store ids of non-consumables "bought" in the test store.
var ledger: Array = []
var bought := 0
var _n := 0


func kind() -> String:
	return "mock"


func is_available() -> bool:
	return true


func is_test_store() -> bool:
	return true


func start() -> void:
	_log("test store: purchases are free (debug build)")


func prices() -> Dictionary:
	var out := {}
	for p in MonetizationConfig.STORE_PRODUCTS:
		out[str(p["id"])] = "$%.2f" % float(p.get("price_usd", 0.0))
	return out


func purchase(store_id: String, product: Dictionary) -> Dictionary:
	var result := next_result
	next_result = ""
	if result == "" and confirm and manager != null and manager.is_inside_tree():
		result = PURCHASED if await _confirm(product) else CANCELLED
	if result == "":
		result = PURCHASED
	if result != PURCHASED:
		return {"result": result, "tx": "", "error": "test store: " + result}
	_n += 1
	bought += 1
	if str(product.get("kind", "")) == "non_consumable" and not store_id in ledger:
		ledger.append(store_id)
	return {"result": PURCHASED, "tx": "test-%d-%d" % [Time.get_unix_time_from_system(), _n], "error": ""}


func restore() -> Array:
	var out: Array = []
	for id in ledger:
		out.append({"store_id": str(id), "tx": "test-restore-" + str(id)})
	return out


func status_text() -> String:
	return "test store (no payment), %d bought this session" % bought


## The test purchase card. Returns true for Buy.
func _confirm(product: Dictionary) -> bool:
	var tree := manager.get_tree()
	var layer := CanvasLayer.new()
	layer.layer = 120
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.theme = BrandTheme.get_theme()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(root)
	tree.root.add_child(layer)
	var v := BrandUi.modal(root, "Test purchase")
	v.add_child(BrandUi.text("%s  ·  $%.2f" % [product.get("title", ""), float(product.get("price_usd", 0.0))], "BodyStrong"))
	var t := BrandUi.text("TEST STORE: no payment is taken. On a store build this is Google Play's or the App Store's purchase sheet.",
		"Caption", Brand.GREY)
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(t)
	var state := {"done": false, "buy": false}
	var buy := func() -> void:
		state["buy"] = true
		state["done"] = true
	var cancel := func() -> void:
		state["done"] = true
	v.add_child(BrandUi.button("Buy (Test, No Charge)", buy, "primary", "check"))
	v.add_child(BrandUi.button("Cancel", cancel, "secondary", "close"))
	while not state["done"]:
		await tree.process_frame
	layer.queue_free()
	return bool(state["buy"])
