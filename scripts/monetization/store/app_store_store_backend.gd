class_name AppStoreStoreBackend
extends StoreBackend
## iOS: Apple In-App Purchase (StoreKit). NOT WIRED YET: reports unavailable,
## so a release build hides the store. (Debug builds use MockStoreBackend
## while MonetizationConfig.STORE_DEBUG_GRANTS is on.) Apple requires its own
## In-App Purchase for digital goods: no external payment links on iOS.
##
## Recommended plugin: hrk4649/godot_ios_plugin_iap 0.4.0+ (MIT, StoreKit 2),
## github.com/hrk4649/godot_ios_plugin_iap: README confirms Godot 4.7; built
## against the engine's headers, so rebuild it for each Godot version
## (script/build.sh -G 4.7). Alternative for both stores in one API:
## godot-iap (OpenIAP, StoreKit 2, iOS 17+). API below read from hrk4649's
## godot_plugin/SwiftClass.swift. Products must exist in App Store Connect
## (ids = STORE_PRODUCTS "id", or "store_ids": {"ios": ...}).

# TODO(billing): var _iap  (Engine.get_singleton("IOSInAppPurchase"))
var _prices := {}


func kind() -> String:
	return "app_store"


func is_available() -> bool:
	# TODO(billing): return true once the singleton exists and products loaded.
	return false


func start() -> void:
	_log("App Store purchases are not wired yet (TODO in app_store_store_backend.gd)")
	# TODO(billing):
	#   if Engine.has_singleton("IOSInAppPurchase"): _iap = Engine.get_singleton("IOSInAppPurchase")
	#   _iap.response.connect(_on_response)      # signal response(name: String, data: Dictionary)
	#   _iap.request("setAutoFinish", {"autoFinish": false})   # finish only after the grant is saved
	#   _iap.request("startUpdateTask", {})      # Transaction.updates: purchases completing later
	#       -> manager.grant(product_id, transaction id) then finish()
	#   _iap.request("products", {"productIDs": ids})  -> displayPrice -> _prices[id]
	#   Server-side check (recommended): verify the transaction's jwsRepresentation on your server.


func prices() -> Dictionary:
	return _prices


func purchase(_store_id: String, _product: Dictionary) -> Dictionary:
	# TODO(billing): _iap.request("purchase", {"productID": store_id}); await the "purchase"
	#   response: success -> {"result": PURCHASED, "tx": transaction id}; userCancelled ->
	#   CANCELLED; pending (Ask to Buy) -> PENDING; else FAILED.
	return {"result": FAILED, "tx": "", "error": "App Store purchases not wired yet"}


func finish(_store_id: String, _tx: String, _consumable: bool) -> void:
	# TODO(billing): _iap.request("finishTransaction", {"transactionID": tx})
	pass


func restore() -> Array:
	# TODO(billing): Restore Purchases (required by App Review):
	#   _iap.request("appStoreSync", {}) then _iap.request("transactionCurrentEntitlements", {});
	#   return [{"store_id": productID, "tx": transaction id}] for each entitlement.
	return []


func status_text() -> String:
	return "App Store: not wired yet (TODO)"
