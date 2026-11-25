class_name AdBackend
extends RefCounted
## One ad network implementation behind AdManager. Game code never sees this:
## it calls AdManager, which picks a backend and applies the rules (ad-free,
## no back-to-back ads, opt-in placements only for rewarded).
##
## Implementations:
##   NoneAdBackend   Steam / desktop release: no SDK, nothing ever shows
##   MockAdBackend   editor / desktop debug: a fake "Ad playing..." screen
##   AdMobAdBackend  Android + iOS through the Poing Studios AdMob plugin
## Adding another network = one more subclass + one line in AdManager.pick_mode().

## show_rewarded() results.
const REWARDED := "rewarded"
const DISMISSED := "dismissed"
const FAILED := "failed"

## Fired when readiness or consent state changes (AdManager refreshes UI).
signal state_changed

## The AdManager node: debug_log(), tree access for timers and overlays.
var manager: Node


func _init(m: Node = null) -> void:
	manager = m


## "none" / "mock" / "admob".
func kind() -> String:
	return "none"


## False when ads never show on this build (Steam). UI then hides ad offers.
func platform_has_ads() -> bool:
	return false


## Start up (consent, SDK init, first loads). May await.
func start() -> void:
	pass


func is_rewarded_ready() -> bool:
	return false


func is_interstitial_ready() -> bool:
	return false


## Shows a loaded rewarded ad. Returns REWARDED only if the SDK reported the
## reward was earned. Preloads the next one afterwards.
func show_rewarded(_placement: String) -> String:
	return FAILED


## Shows a loaded interstitial. Returns true if it was shown.
func show_interstitial(_placement: String) -> bool:
	return false


## The app came back to the foreground (retry consent / loads that failed).
func on_resume() -> void:
	pass


## Google's privacy options entry point must be reachable in Settings when
## this is true (EEA / UK users).
func privacy_options_required() -> bool:
	return false


func show_privacy_options() -> void:
	pass


## Debug: forget the consent choice (to see the form again).
func reset_consent() -> void:
	pass


## One line for logs and the debug panel.
func status_text() -> String:
	return "no ads"


func _log(msg: String) -> void:
	if manager != null and manager.has_method("debug_log"):
		manager.debug_log(msg)
