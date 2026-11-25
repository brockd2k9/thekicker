class_name MobileAdService
extends AdService
## Phones: the real rewarded-ad SDK goes HERE. No SDK is integrated yet, so
## this reports "not ready" and the Daily Challenge hides the ad buttons
## behind a friendly message.
##
## To plug one in (AdMob, AppLovin MAX, Unity Ads... through its Godot
## Android / iOS plugin):
##   1. _init(): grab the plugin singleton, e.g.
##        if Engine.has_singleton("YourAdPlugin"): _sdk = Engine.get_singleton("YourAdPlugin")
##      and start loading a rewarded ad for each placement (AdService.RETRY,
##      AdService.SAVER), reloading after each one is shown.
##   2. is_ready(): true when the SDK has a loaded rewarded ad.
##   3. _show(): show it and `await` the SDK's "earned reward" / "closed"
##      callbacks; return true ONLY when the reward was earned.
## Nothing else in the game changes.

var _sdk: Object = null


func platform_has_ads() -> bool:
	return true


func is_ready(_placement: String) -> bool:
	return _sdk != null


func _show(_placement: String) -> bool:
	return false
