extends Node
## Screenshot of the 3D kick scene with chosen graphics options (dev tool, not
## part of the game). Needs a window (not --headless):
##   godot --path . --resolution 720x1280 res://tools/visual_shot.tscn -- out=/tmp/high.png preset=high
## Options:
##   preset=classic|low|high   (classic: the scene as it was before the visual upgrade)
##   off=bloom,fog  on=bloom   switch single features
##   yards=35  wind=8  night=1  tier=pro_3  kind=fg|kickoff  hud=0  wait=1.5 (seconds)
##   cam=x,y,z,pitch_deg       a free camera instead of the kicker's view (look down the field)

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")


class ShotMode:
	extends KickMode
	var yards := 35
	var wind_mph := 0.0
	var type := KickSituation.KickType.FIELD_GOAL

	func kick_type() -> int:
		return type

	func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
		var s := KickSituation.new()
		s.kick_type = type as KickSituation.KickType
		s.distance_yards = yards
		s.wind_mph = wind_mph
		s.label = "Screenshot"
		wind.set_conditions(rng, tuning, wind_mph, 0.0)
		return s


func _ready() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	var q := VisualQuality.make(str(args.get("preset", "high")))
	for f in str(args.get("off", "")).split(",", false):
		q.set_enabled(StringName(f), false)
	for f in str(args.get("on", "")).split(",", false):
		q.set_enabled(StringName(f), true)
	VisualQuality.forced = q
	var mode := ShotMode.new()
	mode.yards = int(args.get("yards", 35))
	mode.wind_mph = float(args.get("wind", 0.0))
	if str(args.get("kind", "fg")) == "kickoff":
		mode.type = KickSituation.KickType.KICKOFF
	var scene := FIELD_GOAL.instantiate()
	scene.mode = mode
	var st := StadiumSpec.preset(str(args.get("tier", "")))
	st.night = str(args.get("night", "0")) == "1"
	scene.set_look({"stadium": st})
	add_child(scene)
	scene.hud.visible = str(args.get("hud", "1")) == "1"
	if args.has("cam"):
		var c := str(args["cam"]).split_floats(",")
		var cam := Camera3D.new()
		cam.fov = 46.0
		cam.far = 400.0
		cam.keep_aspect = Camera3D.KEEP_WIDTH
		add_child(cam)
		cam.global_position = Vector3(c[0], c[1], c[2])
		cam.rotation_degrees = Vector3(-c[3], c[4] if c.size() > 4 else 0.0, 0.0)
		cam.make_current()
	await get_tree().create_timer(float(args.get("wait", 1.5))).timeout
	await RenderingServer.frame_post_draw
	var out := str(args.get("out", "user://visual_shot.png"))
	get_viewport().get_texture().get_image().save_png(out)
	print("saved ", out, "  ", q.describe())
	get_tree().quit()
