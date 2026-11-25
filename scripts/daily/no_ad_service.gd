class_name NoAdService
extends AdService
## Platforms without ads (the Steam build, DailyTuning.ad_mode "none").
## The Daily Challenge reads DailyTuning.no_ads_rule for what to offer instead.


func platform_has_ads() -> bool:
	return false


func unavailable_text() -> String:
	return "Retries aren't available in this version."
