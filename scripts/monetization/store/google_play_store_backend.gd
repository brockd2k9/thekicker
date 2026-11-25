class_name GooglePlayStoreBackend
extends StoreBackend
## Android: Google Play Billing. NOT WIRED YET: reports unavailable, so a
## release build hides the store. (Debug builds use MockStoreBackend while
## MonetizationConfig.STORE_DEBUG_GRANTS is on.)
##
## Recommended plugin: GodotGooglePlayBilling 3.3.0 (official, MIT),
## github.com/godot-sdk-integrations/godot-google-play-billing. Play Billing
## Library 9.1.0 (Google supports v9 until Aug 31 2028; v7 is no longer
## accepted). One Android v2 plugin build for Godot 4.2+; needs Use Gradle
## Build. API below read from its export_scripts/BillingClient.gd at 3.3.0.
## It also needs the products created in Play Console (ids = MonetizationConfig
## STORE_PRODUCTS "id", or "store_ids": {"android": ...}).

# TODO(billing): var _bc  (BillingClient.new(), kept for the app's lifetime)
var _prices := {}


func kind() -> String:
	return "google_play"


func is_available() -> bool:
	# TODO(billing): return true once connected (BillingClient signal `connected`).
	return false


func start() -> void:
	_log("Google Play Billing is not wired yet (TODO in google_play_store_backend.gd)")
	# TODO(billing):
	#   _bc = BillingClient.new()
	#   _bc.connected.connect(...)                      -> query products + owned purchases
	#   _bc.connect_error.connect(func(code: int, msg: String): ...)
	#   _bc.query_product_details_response.connect(...) # Dictionary: product_details[i]
	#       .one_time_purchase_offer_details_list[0].formatted_price -> _prices[product_id]
	#   _bc.on_purchase_updated.connect(...)            # Dictionary: response_code, purchases[]
	#       each purchase: product_ids, purchase_token, purchase_state, is_acknowledged,
	#       original_json, signature. purchase_state == BillingClient.PurchaseState.PURCHASED
	#       -> manager.grant(product_id, purchase_token) for purchases that arrive outside
	#       a purchase() call (pending payments completing, app restarted mid-purchase).
	#   _bc.query_purchases_response.connect(...)       # owned items (restore / startup)
	#   _bc.consume_purchase_response.connect(...); _bc.acknowledge_purchase_response.connect(...)
	#   _bc.start_connection()
	#   then: _bc.query_product_details(PackedStringArray(ids), BillingClient.ProductType.INAPP)
	#   Server-side check (recommended): send original_json + signature / purchase_token
	#   to your server before granting; never ship keys in the app.


func prices() -> Dictionary:
	return _prices


func purchase(_store_id: String, _product: Dictionary) -> Dictionary:
	# TODO(billing): var r: Dictionary = _bc.purchase(store_id)  (details must be queried first)
	#   r.response_code != OK -> FAILED. Then await on_purchase_updated for this product:
	#   PURCHASED -> {"result": PURCHASED, "tx": purchase_token}; PENDING state -> PENDING;
	#   user cancelled (response_code USER_CANCELED) -> CANCELLED.
	return {"result": FAILED, "tx": "", "error": "Google Play Billing not wired yet"}


func finish(_store_id: String, _tx: String, _consumable: bool) -> void:
	# TODO(billing): only after StoreManager granted + saved:
	#   consumable     -> _bc.consume_purchase(tx)       (consuming also acknowledges)
	#   non-consumable -> _bc.acknowledge_purchase(tx)   if not is_acknowledged
	#   Google refunds purchases not acknowledged within 3 days.
	pass


func restore() -> Array:
	# TODO(billing): _bc.query_purchases(BillingClient.ProductType.INAPP), await
	#   query_purchases_response; return [{"store_id": product_ids[0], "tx": purchase_token}]
	#   for each PURCHASED item (and acknowledge any not yet acknowledged).
	return []


func status_text() -> String:
	return "Google Play Billing: not wired yet (TODO)"
