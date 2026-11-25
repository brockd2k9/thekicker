class_name VisualQuality
extends RefCounted
## Graphics options for the 3D kick scene. Saved inside GameSettings.
##
## A preset (LOW for phones, HIGH for desktop / Steam) decides how every
## feature is drawn; each feature can also be switched off (or back on) one
## at a time, so its frame-rate cost can be checked on a real device.
## Nothing here touches the kick: it is only how the scene looks.
##
##   feature   off                         LOW                      HIGH
##   shadows   no shadows                  1 map, 2048, first 60 m  4 blended splits, 4096, 150 m, soft
##   sky       flat gradient, flat ambient sun-lit sky, sky ambient same + sharper reflections
##   fog       none                        distance haze            same
##   grading   none                        filmic tonemap (free)    + contrast / saturation pass
##   bloom     none                        none                     glow on lights and white paint
##   grass     the old flat field shader   stripes, variation, wind + blade detail and sheen
##   paint     the old thin lines          full markings            same
##
## CLASSIC is not a player option: it draws the scene exactly as it was before
## the visual upgrade (the benchmark's "before" row).

const LOW := "low"
const HIGH := "high"
const CLASSIC := "classic"

const SHADOWS := &"shadows"
const SKY := &"sky"
const FOG := &"fog"
const GRADING := &"grading"
const BLOOM := &"bloom"
const GRASS := &"grass"
const PAINT := &"paint"

## Every feature, in the order the settings screen and the benchmark list them.
const FEATURES: Array[StringName] = [SHADOWS, SKY, FOG, GRADING, BLOOM, GRASS, PAINT]
const LABELS := {
	SHADOWS: "Sun Shadows",
	SKY: "Sky Lighting",
	FOG: "Distance Haze",
	GRADING: "Color Grading",
	BLOOM: "Bloom",
	GRASS: "Grass Shader",
	PAINT: "Field Paint",
}
## What each preset turns on.
const PRESET_FEATURES := {
	LOW: {SHADOWS: true, SKY: true, FOG: true, GRADING: true, BLOOM: false, GRASS: true, PAINT: true},
	HIGH: {SHADOWS: true, SKY: true, FOG: true, GRADING: true, BLOOM: true, GRASS: true, PAINT: true},
}

## Dev tools (the benchmark, the screenshot tool) set this to draw the scene
## with other options than the saved ones. null = the player's settings.
static var forced: VisualQuality

var preset := LOW
## feature -> bool, only where the player switched a feature away from the preset.
var overrides := {}
## Frame-rate readout in the corner of the screen.
var show_fps := false


func _init() -> void:
	preset = default_preset()


## The options the kick scene should draw with right now.
static func active() -> VisualQuality:
	if forced != null:
		return forced
	var loop := Engine.get_main_loop() as SceneTree
	var gs: Node = loop.root.get_node_or_null("GameState") if loop != null else null
	if gs != null and gs.get("settings") != null:
		return gs.settings.graphics
	return VisualQuality.new()


## Phones, tablets and browsers start on LOW; desktop on HIGH.
static func default_preset() -> String:
	if OS.has_feature("mobile") or OS.has_feature("web"):
		return LOW
	return HIGH


static func make(preset_id: String, feature_overrides := {}) -> VisualQuality:
	var q := VisualQuality.new()
	q.preset = preset_id
	for f in feature_overrides:
		q.overrides[StringName(f)] = bool(feature_overrides[f])
	return q


func is_classic() -> bool:
	return preset == CLASSIC


func is_high() -> bool:
	return preset == HIGH


func enabled(feature: StringName) -> bool:
	if is_classic():
		return false
	if overrides.has(feature):
		return bool(overrides[feature])
	return bool(PRESET_FEATURES[preset].get(feature, false))


## 0 = off, 1 = the LOW version, 2 = the HIGH version.
func level(feature: StringName) -> int:
	if not enabled(feature):
		return 0
	return 2 if is_high() else 1


func set_enabled(feature: StringName, on: bool) -> void:
	if on == bool(PRESET_FEATURES[preset].get(feature, false)):
		overrides.erase(feature)
	else:
		overrides[feature] = on


## Picking a preset puts every feature back to that preset's choice.
func set_preset(id: String) -> void:
	preset = id if id in [LOW, HIGH] else default_preset()
	overrides.clear()


## Short text for the benchmark and the frame-rate readout, e.g. "HIGH -bloom".
func describe() -> String:
	var s := preset.to_upper()
	for f in FEATURES:
		if overrides.has(f):
			s += " %s%s" % ["+" if overrides[f] else "-", f]
	return s


func to_dict() -> Dictionary:
	var o := {}
	for f in overrides:
		o[str(f)] = bool(overrides[f])
	return {"preset": preset, "overrides": o, "show_fps": show_fps}


func from_dict(d: Dictionary) -> void:
	var p := str(d.get("preset", preset))
	preset = p if p in [LOW, HIGH] else default_preset()
	overrides.clear()
	var o: Variant = d.get("overrides", {})
	if o is Dictionary:
		for k in o:
			if StringName(k) in FEATURES:
				set_enabled(StringName(k), bool(o[k]))
	show_fps = bool(d.get("show_fps", show_fps))
