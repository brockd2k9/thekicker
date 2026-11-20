class_name GoalMarker
extends Node3D
## Result feedback at the posts for field goals and extra points, so the player
## can see whether the ball got there: from the kicker's view a ball high in the
## air short of the posts looks just like one over the bar.
##   reached the posts: a ring flashes where the ball crossed their plane and the
##     crossbar lights up (green = good, red = under the bar or wide);
##   landed short: a red stake standing where it came down (in front of the
##     posts), a red strip on the grass from there to the goal plane, and the
##     crossbar lights up red. (Flat ground marks alone are almost edge-on from
##     the kicker's eye height, so the stake is what reads at 50 yards.)
## Display only; drawn on top of players (no depth test) and unshaded, a few
## meshes, animated only for a moment after the result.

const GOOD := Color(0.35, 1.0, 0.45)
const BAD := Color(1.0, 0.3, 0.22)
const POP_TIME := 0.25

var _ring: MeshInstance3D
var _bar: MeshInstance3D
var _stake: MeshInstance3D
var _strip: MeshInstance3D


func _ready() -> void:
	_ring = _make(_torus(0.26, 0.5))
	_ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)  # face the kicker
	_bar = _make(_box())
	_stake = _make(_box())
	_strip = _make(_box())
	clear()


func clear() -> void:
	for m in [_ring, _bar, _stake, _strip]:
		(m as MeshInstance3D).visible = false


## The ball crossed the plane of the posts at `crossing` (world). goal_z: that
## plane; half_width: half the gap between the uprights; bar_y: crossbar height.
func show_crossing(crossing: Vector3, good: bool, goal_z: float, half_width: float, bar_y: float) -> void:
	var c := GOOD if good else BAD
	var dist := absf(goal_z)
	_ring.position = Vector3(crossing.x, crossing.y, goal_z + 0.05)
	_pop(_ring, c, clampf(dist / 16.0, 1.0, 4.0))
	_show_bar(c, goal_z, half_width, bar_y)


## The ball came down at `landing` (world) before reaching the plane at goal_z.
func show_short(landing: Vector3, goal_z: float, half_width: float, bar_y: float) -> void:
	var dist := absf(landing.z)
	# A stake from the grass up to crossbar height where the ball landed.
	var w := 0.12 + dist * 0.006
	_stake.position = Vector3(landing.x, bar_y * 0.5, landing.z)
	_stake.scale = Vector3(w, bar_y, w)
	_set_color(_stake, BAD)
	_stake.visible = true
	_stake.scale.y = 0.01
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_property(_stake, "scale:y", bar_y, POP_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_show_bar(BAD, goal_z, half_width, bar_y)
	var length := maxf(landing.z - goal_z, 0.05)  # goal_z is further away (more negative)
	_strip.position = Vector3(landing.x, 0.025, (landing.z + goal_z) * 0.5)
	_strip.scale = Vector3(0.35 + dist * 0.008, 0.01, length)
	_set_color(_strip, Color(BAD, 0.75))
	_strip.visible = true


## Crossbar glow, fatter than the bar so it reads from 60 yards.
func _show_bar(c: Color, goal_z: float, half_width: float, bar_y: float) -> void:
	var dist := absf(goal_z)
	var thick := 0.2 + dist * 0.007
	_bar.position = Vector3(0.0, bar_y, goal_z + 0.02)
	_bar.scale = Vector3(half_width * 2.0 + 0.3, thick, thick)
	_set_color(_bar, c)
	_bar.visible = true


func _pop(m: MeshInstance3D, c: Color, s: float) -> void:
	_set_color(m, c)
	m.visible = true
	m.scale = Vector3.ONE * s * 0.2
	# Ignores slow motion so it lands crisply during the result beat.
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_property(m, "scale", Vector3.ONE * s, POP_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _make(mesh: Mesh) -> MeshInstance3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	mat.render_priority = 2
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


static func _set_color(m: MeshInstance3D, c: Color) -> void:
	(m.material_override as StandardMaterial3D).albedo_color = c


static func _torus(inner: float, outer: float) -> TorusMesh:
	var t := TorusMesh.new()
	t.inner_radius = inner
	t.outer_radius = outer
	t.rings = 24
	t.ring_segments = 8
	return t


static func _box() -> BoxMesh:
	var b := BoxMesh.new()
	b.size = Vector3.ONE
	return b
