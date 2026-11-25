class_name StubAdService
extends AdService
## Desktop / debug stand-in for a rewarded ad: a plain "AD PLACEHOLDER" screen
## for DailyTuning.stub_ad_seconds, then success. fill = false behaves like
## being offline (is_ready false). Tests set seconds = 0 and next_result.

var fill := true
var seconds := 1.5
## Forced result of the next ad (null = success).
var next_result: Variant = null
var shown := 0


func _init(t: DailyTuning = null) -> void:
	if t != null:
		fill = t.stub_ad_fill
		seconds = t.stub_ad_seconds


func platform_has_ads() -> bool:
	return true


func is_ready(_placement: String) -> bool:
	return fill


func _show(placement: String) -> bool:
	shown += 1
	var tree := Engine.get_main_loop() as SceneTree
	if seconds > 0.0 and tree != null and tree.root != null:
		var layer := CanvasLayer.new()
		layer.layer = 100
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
		var a := BrandTheme.label("AD PLACEHOLDER", "Title")
		a.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(a)
		var b := BrandTheme.label("Stub ad (%s). The mobile build shows a real rewarded ad here." % placement,
			"Caption", Brand.GREY)
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size.x = 520
		v.add_child(b)
		tree.root.add_child(layer)
		await tree.create_timer(seconds, true, false, true).timeout
		layer.queue_free()
	var ok: bool = true if next_result == null else bool(next_result)
	next_result = null
	return ok
