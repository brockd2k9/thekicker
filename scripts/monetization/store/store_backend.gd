class_name StoreBackend
extends RefCounted
## One billing implementation behind StoreManager. Game code never sees this.
##   NoneStoreBackend         Steam / desktop release: no store
##   MockStoreBackend         debug builds (all platforms): test purchases, no payment
##   GooglePlayStoreBackend   Android: Google Play Billing (TODO: plugin not wired yet)
##   AppStoreStoreBackend     iOS: StoreKit / Apple In-App Purchase (TODO: plugin not wired yet)
## Methods that wait for the store are coroutines: StoreManager calls them
## through an untyped reference (the Godot 4.7.2 crash noted in AdManager).

## purchase() results.
const PURCHASED := "purchased"
const CANCELLED := "cancelled"
const FAILED := "failed"
## Paid later (cash, parental approval): granted when the store confirms it.
const PENDING := "pending"

signal state_changed

var manager: Node


func _init(m: Node = null) -> void:
	manager = m


func kind() -> String:
	return "none"


## Purchases can be made right now.
func is_available() -> bool:
	return false


## Connect to the store and read prices. May await.
func start() -> void:
	pass


## store product id -> localized price text ("$4.99", "4,99 €"), once known.
func prices() -> Dictionary:
	return {}


## Buys one product. Returns {"result": PURCHASED / CANCELLED / FAILED /
## PENDING, "tx": transaction id, "error": text}.
func purchase(_store_id: String, _product: Dictionary) -> Dictionary:
	return {"result": FAILED, "tx": "", "error": "no store on this build"}


## After the item was granted AND saved: Android acknowledge (non-consumable)
## or consume (consumable); iOS finishTransaction. Until then the store keeps
## the purchase pending and re-delivers it (so nothing paid is ever lost).
func finish(_store_id: String, _tx: String, _consumable: bool) -> void:
	pass


## Non-consumables the player owns, from the store: [{"store_id", "tx"}].
func restore() -> Array:
	return []


## True when purchases only simulate payment (debug).
func is_test_store() -> bool:
	return false


func status_text() -> String:
	return "no store"


func _log(msg: String) -> void:
	if manager != null and manager.has_method("debug_log"):
		manager.debug_log(msg)
