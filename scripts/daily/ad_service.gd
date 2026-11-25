class_name AdService
extends RefCounted
## Rewarded ads, behind one small interface. The game only ever calls:
##   is_ready(placement)        -> can an ad be shown right now?
##   await show_rewarded(placement) -> true if the player watched it to the end
##   (rewarded_finished(placement, success) fires too, for listeners.)
## and platform_has_ads() (false on Steam / no-ads builds).
## Ads are always optional: nothing waits on them, and a failure only means
## "no reward this time".
##
## Implementations (AdService.create picks one from DailyTuning.ad_mode):
##   ManagedAdService  the game (ad_mode "auto"): everything goes through the
##                     AdManager autoload, which picks AdMob (phones), Mock
##                     (editor / desktop debug) or None (Steam / desktop release)
##   NoAdService       ad_mode "none" or no_ads_platform: never ads
##   StubAdService     ad_mode "stub" and the tests: instant placeholder, no AdManager
##
## Placements used: "daily_retry" (one retry after a miss), "streak_saver".

signal rewarded_finished(placement: String, success: bool)

const RETRY := "daily_retry"
const SAVER := "streak_saver"


## False on platforms that never show ads (Steam). The Daily Challenge then
## uses DailyTuning.no_ads_rule instead of an ad.
func platform_has_ads() -> bool:
	return false


## An ad can be shown right now (SDK loaded, online, filled).
func is_ready(_placement: String) -> bool:
	return false


## A short, friendly line for when no ad can be shown.
func unavailable_text() -> String:
	return "No ad is available right now. Check your connection and try again in a moment."


## Shows a rewarded ad. Returns (await it) true only if it was watched to the
## end. Implementations override _show().
func show_rewarded(placement: String) -> bool:
	var ok := false
	if is_ready(placement):
		ok = await _show(placement)
	rewarded_finished.emit(placement, ok)
	return ok


func _show(_placement: String) -> bool:
	return false


static func create(t: DailyTuning) -> AdService:
	match t.ad_mode:
		"none":
			return NoAdService.new()
		"stub":
			return StubAdService.new(t)
	if t.no_ads_platform:
		return NoAdService.new()
	# Platform choice (Steam, phones, desktop) is AdManager's.
	return ManagedAdService.new()
