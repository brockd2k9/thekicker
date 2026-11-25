class_name NoneAdBackend
extends AdBackend
## Steam / desktop release builds: no SDK calls, no ad UI, forced ads never
## trigger, rewarded ads are never ready.
## Also stands in when ads are blocked on a phone (real mode with missing IDs):
## then platform_has_ads() stays true, so the game says "no ad available right
## now" instead of switching to the no-ads rules.

var reason := ""
var _has_ads := false


func _init(m: Node = null, why: String = "", has_ads: bool = false) -> void:
	super(m)
	reason = why
	_has_ads = has_ads


func platform_has_ads() -> bool:
	return _has_ads


func status_text() -> String:
	return "no ads" + (" (%s)" % reason if reason != "" else "")
