class_name MockAdBackend
extends AdBackend
## Editor / desktop debug builds: a fake full-screen "Ad playing..." screen
## for MonetizationConfig.MOCK_AD_SECONDS, then the reward. No SDK, no network.
## The rewarded mock has a "Skip (No Reward)" button so the
## no-reward path can be tested too. After each ad the next one "loads" for
## MOCK_LOAD_SECONDS (buttons go disabled, like on a phone).
## Tests set seconds = 0 and load_seconds = 0 (everything runs synchronously)
## and next_result to force an outcome.

var fill := MonetizationConfig.MOCK_FILL
var seconds := MonetizationConfig.MOCK_AD_SECONDS
var load_seconds := MonetizationConfig.MOCK_LOAD_SECONDS
## Forced result of the next rewarded ad: "" (normal), REWARDED, DISMISSED, FAILED.
var next_result := ""
var shown := 0

var _rewarded_loaded := false
var _interstitial_loaded := false


func kind() -> String:
	return "mock"


func platform_has_ads() -> bool:
	return true


func start() -> void:
	_log("mock ads: no SDK, no network. Rewarded ads pay out after %.0f s." % seconds)
	_load("rewarded")
	_load("interstitial")


func is_rewarded_ready() -> bool:
	return fill and _rewarded_loaded


func is_interstitial_ready() -> bool:
	return fill and _interstitial_loaded


func show_rewarded(placement: String) -> String:
	if not is_rewarded_ready():
		return FAILED
	_rewarded_loaded = false
	shown += 1
	var result := next_result
	next_result = ""
	if result == FAILED:
		_load("rewarded")
		return FAILED
	var closed_early := false
	if seconds > 0.0:
		closed_early = await _play("REWARDED", placement, true)
	_load("rewarded")
	if result != "":
		return result
	return DISMISSED if closed_early else REWARDED


func show_interstitial(placement: String) -> bool:
	if not is_interstitial_ready():
		return false
	_interstitial_loaded = false
	shown += 1
	if seconds > 0.0:
		await _play("FORCED (INTERSTITIAL)", placement, false)
	_load("interstitial")
	return true


func status_text() -> String:
	return "mock: rewarded %s, interstitial %s%s" % [
		"ready" if is_rewarded_ready() else "loading",
		"ready" if is_interstitial_ready() else "loading",
		"" if fill else " (fill off)"]


func _load(which: String) -> void:
	if load_seconds <= 0.0 or manager == null or not manager.is_inside_tree():
		_set_loaded(which)
		return
	manager.get_tree().create_timer(load_seconds, true, false, true).timeout.connect(
		_set_loaded.bind(which))


func _set_loaded(which: String) -> void:
	if which == "rewarded":
		_rewarded_loaded = true
	else:
		_interstitial_loaded = true
	state_changed.emit()


## The fake ad screen. Returns true if the player closed it early.
func _play(kind_text: String, placement: String, can_close: bool) -> bool:
	if manager == null or not manager.is_inside_tree():
		return false
	var tree := manager.get_tree()
	var layer := CanvasLayer.new()
	layer.layer = 120
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.theme = BrandTheme.get_theme()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(root)
	var bg := ColorRect.new()
	bg.color = Brand.INK_1
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", Brand.SPACE_3)
	center.add_child(v)
	var title := BrandTheme.label("Ad playing...", "Title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var info := BrandTheme.label("MOCK %s AD  ·  %s" % [kind_text, placement], "Caption", Brand.GREY)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(info)
	var count := BrandTheme.label("", "Heading")
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(count)
	var state := {"early": false, "done": false}
	if can_close:
		var close_early := func() -> void:
			if not state["done"]:
				state["early"] = true
				state["done"] = true
		v.add_child(BrandUi.button("Skip (No Reward)", close_early, "secondary", "close"))
	tree.root.add_child(layer)
	var left := seconds
	while left > 0.0 and not state["done"]:
		count.text = "%d" % ceili(left)
		await tree.create_timer(minf(left, 0.25), true, false, true).timeout
		left -= 0.25
	state["done"] = true
	layer.queue_free()
	return bool(state["early"])
