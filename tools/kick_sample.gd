extends Node
## Real-swipe check: plays the REAL field-goal scene (scenes/field_goal.tscn,
## unmodified: KickDifficulty from PR #14, Career nerves from PR #15, the
## Career KickModifiers, the rush, the wobble, the physics) with scripted,
## human-like swipes, and compares its make rates with the simulator's
## stand-in (tools/career_sim.gd _make_chance) for the same kickers.
##
##   godot --headless --fixed-fps 60 --path . res://tools/kick_sample.tscn -- [options]
##
## Options: n=40 (kicks per cell), seed=1, stages=college,pro, qualities=60,75,90,
##   skills=steady,average,sloppy, dist=20,25,30,35,40,45,50,55, extras=1 (the
##   average swipe also in a slump, and in a 10 mph crosswind), out=<file.md>.
##
## Kickers: the simulator's quality copies (_quality_copy: Accuracy and
## Resilience set so the stand-in's expected game FG% is 60 / 75 / 90%), a
## 25-year-old with Power 70, normal fitness. Pressure 0.4, as the stand-in's
## expected FG%. Calm wind unless a row says otherwise.
##
## Swipes (screen 1280 high, from (360, 1100) up the screen), per skill level:
##   tilt_sd   aim error of the swipe direction (degrees of screen tilt; the
##             game turns 1 degree of tilt into aim_sensitivity = 0.35 degrees)
##   bow_sd    sideways bulge of the path (fraction of its length; 0.12 = fully crooked)
##   hook_sd   turn at the end of the swipe (degrees; 20 = fully crooked)
##   speed     flick speed (screen heights / s; 4.5 = full power) and its sd
##   wobble    how much of the pressure wobble the player corrects for (the
##             aim marker shows it)
##   wind      how much of the wind's drift the player aims off for
## The kick happens at a random moment in the first 70% of the kick window.
## Distances past the kicker's range are skipped (the stand-in says 2%).

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")
const SIM := preload("res://tools/career_sim.gd")
## field_goal_game.gd Phase values.
const KICK_WINDOW := 2
const RESULT := 4

const SKILLS := {
	"steady": {"tilt_sd": 2.5, "bow_sd": 0.015, "hook_sd": 3.0, "speed": 4.4, "speed_sd": 0.25,
		"wobble": 0.6, "wind": 0.9},
	"average": {"tilt_sd": 4.5, "bow_sd": 0.03, "hook_sd": 5.0, "speed": 4.2, "speed_sd": 0.45,
		"wobble": 0.3, "wind": 0.7},
	"sloppy": {"tilt_sd": 7.0, "bow_sd": 0.05, "hook_sd": 8.0, "speed": 3.9, "speed_sd": 0.7,
		"wobble": 0.0, "wind": 0.4},
}

var _n := 40
## debug=N: print the first N kicks.
var _debug := 0
var _rng := RandomNumberGenerator.new()
var _sim: Node
var _t := CareerTuning.get_default()
var _report: KickReport
var _lines := PackedStringArray()
var _rows: Array = []


class SampleMode:
	extends KickMode
	var yards := 30
	var wind_mph := 0.0
	var pressure := 0.4

	func id() -> StringName:
		return &"kick_sample"

	func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
		var s := KickSituation.new()
		s.distance_yards = yards
		s.wind_mph = wind_mph
		s.pressure = pressure
		s.label = "Sample"
		wind.set_conditions(rng, tuning, wind_mph, 0.0)
		return s


func _ready() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	_n = int(args.get("n", 40))
	_debug = int(args.get("debug", 0))
	_rng.seed = int(args.get("seed", 1))
	_sim = SIM.new()
	GameState.kick_resolved.connect(func(r: KickReport) -> void: _report = r)
	var stages := str(args.get("stages", "college,pro")).split(",")
	var quals := Array(str(args.get("qualities", "60,75,90")).split(",")).map(func(x): return float(x) / 100.0)
	var skills := str(args.get("skills", "steady,average,sloppy")).split(",")
	var dists := Array(str(args.get("dist", "20,25,30,35,40,45,50,55")).split(",")).map(func(x): return int(x))
	var extras := str(args.get("extras", "1")) == "1"
	var t0 := Time.get_ticks_msec()
	for stage in stages:
		for q in quals:
			var k: Variant = _kicker(stage, q)
			if k == null:
				print("skip %s %.0f%%: no such kicker" % [stage, q * 100.0])
				continue
			var variants: Array = []
			for sk in skills:
				variants.append([sk, "calm", 0.0])
			if extras:
				variants.append(["average", "slump", 0.0])
				variants.append(["average", "wind", 10.0])
			for v in variants:
				for d in dists:
					await _cell(k, stage, q, str(v[0]), str(v[1]), float(v[2]), int(d))
	_write(str(args.get("out", "")), Time.get_ticks_msec() - t0)
	get_tree().quit()


## The simulator's quality copy for a stage: a 25-year-old, Power 70.
func _kicker(stage: String, q: float) -> Variant:
	var c := CareerData.create("Sample Kicker", _t)
	c.slot = 0
	c.age = 25 if stage == "pro" else 20
	c.stage = CareerData.STAGE_PRO if stage == "pro" else CareerData.STAGE_COLLEGE
	var pool := CareerContent.pro_clubs() if stage == "pro" else CareerContent.colleges()
	c.team = Progression.team_from(pool[0], c.stage)
	c.set_stat("power", 70.0)
	return _sim._quality_copy(c, _t, q)


## One cell: n kicks at one distance with one kicker, skill and condition.
func _cell(k: CareerData, stage: String, q: float, skill: String, cond: String, wind: float, yards: int) -> void:
	var kk := CareerData.from_dict(k.to_dict())
	if cond == "slump":
		kk.nerves = {"slump": true, "clean_run": 0}
	var prof := KickProfile.build(kk, _t)
	var stand := float(_sim._make_chance(kk, yards, 0.4, stage, prof, wind))
	if yards > prof.fg_range:
		return
	var mode := SampleMode.new()
	mode.yards = yards
	mode.wind_mph = wind
	var gp := Progression.game_params(kk, _t)
	var game: Node = FIELD_GOAL.instantiate()
	game.mode = mode
	game.modifiers = prof.to_kick_modifiers()
	game.set_look({"posts": str(gp["posts"]), "width": float(gp["width"])})
	add_child(game)
	var sk: Dictionary = SKILLS[skill]
	# Wind: where an unaimed straight kick drifts to (a few calibration kicks),
	# so the player can aim off for a share of it.
	var wind_aim := 0.0
	if absf(wind) > 0.0:
		var drift := 0.0
		for i in 4:
			drift += await _kick(game, 0.0, {"tilt_sd": 0.0, "bow_sd": 0.0, "hook_sd": 0.0, "speed": 4.4,
				"speed_sd": 0.0, "wobble": 0.0}, true)
		wind_aim = -rad_to_deg(atan2(drift / 4.0, mode.yards * KickSituation.YARD_TO_M))
	var made := 0
	var crooked := 0.0
	for i in _n:
		var ok: float = await _kick(game, wind_aim * float(sk.get("wind", 0.0)), sk, false)
		made += int(ok)
		crooked += float(game.last_shot_penalty)
	game.queue_free()
	await get_tree().process_frame
	_rows.append({"stage": stage, "q": q, "skill": skill, "cond": cond, "yards": yards,
		"real": float(made) / _n, "stand": stand, "penalty": crooked / _n,
		"nerves": float(prof.straightness_penalty_mult)})


## One kick: waits for the kick window, swipes, waits for the result. Returns
## 1.0 / 0.0 (made), or with `drift` the ball's x at the goal plane.
func _kick(game: Node, aim_deg: float, sk: Dictionary, drift: bool) -> float:
	if game.phase == RESULT:
		game._start_attempt()
	while game.phase != KICK_WINDOW:
		await get_tree().physics_frame
	# Kick at a random moment in the first 70% of the window.
	var wait := _rng.randf_range(0.05, 0.7) * float(game._window_total)
	var waited := 0.0
	while waited < wait and game.phase == KICK_WINDOW:
		await get_tree().physics_frame
		waited += 1.0 / 60.0
	if game.phase != KICK_WINDOW:
		await _result(game)
		return 0.0
	var aim := aim_deg - float(game.pressure.wobble_deg()) * float(sk.get("wobble", 0.0))
	var tilt := aim / float(game.tuning.aim_sensitivity) + _rng.randfn(0.0, float(sk["tilt_sd"]))
	var sw := _swipe(tilt, _rng.randfn(0.0, float(sk["bow_sd"])), _rng.randfn(0.0, float(sk["hook_sd"])),
		maxf(_rng.randfn(float(sk["speed"]), float(sk["speed_sd"])), 1.0))
	var cross := [INF]
	var ball: Node = game.get_node("Ball")
	var on_cross := func(at: Vector3) -> void: cross[0] = at.x
	ball.reached_goal_plane.connect(on_cross)
	_report = null
	game._try_kick(sw)
	await _result(game)
	ball.reached_goal_plane.disconnect(on_cross)
	if _debug > 0:
		_debug -= 1
		print("kick %d yd: %s  made=%s  tilt %.1f  wobble %.2f  cross x %s  penalty %.2f  t=%.1fs" % [
			game.situation.distance_yards, KickResult.Outcome.keys()[_report.outcome] if _report != null else "none",
			_report.made if _report != null else false, tilt, float(game.pressure.wobble_deg()),
			str(cross[0]), float(game.last_shot_penalty), Time.get_ticks_msec() / 1000.0])
	if drift:
		return 0.0 if cross[0] == INF else float(cross[0])
	return 1.0 if _report != null and _report.made else 0.0


func _result(game: Node) -> void:
	var guard := 0
	while game.phase != RESULT and guard < 1200:
		await get_tree().physics_frame
		guard += 1


## An upward swipe 0.5 screen heights long, tilted `tilt` degrees, bowed by
## `bow` (fraction of its length) and turning `hook` degrees at the end.
func _swipe(tilt: float, bow: float, hook: float, speed: float) -> Swipe:
	var s := Swipe.new()
	s.screen_height = 1280.0
	s.start = Vector2(360, 1100)
	var len := 640.0
	var dir := Vector2(sin(deg_to_rad(tilt)), -cos(deg_to_rad(tilt)))
	var n := Vector2(-dir.y, dir.x)  # right of the swipe
	var pts := PackedVector2Array()
	for i in 21:
		var u := i / 20.0
		var p := s.start + dir * len * u + n * bow * len * sin(PI * u)
		if u > 0.7:
			p += n * len * (u - 0.7) * tan(deg_to_rad(hook))
		pts.append(p)
	s.points = pts
	s.end = pts[20]
	s.duration = 0.2
	s.flick_speed_px = speed * 1280.0
	return s


func _write(path: String, ms: int) -> void:
	var L := PackedStringArray()
	L.append("# Real-swipe check: the real kick scene vs the simulator's stand-in")
	L.append("")
	L.append("%d kicks per cell, %d cells, %.0f s. Real = made in the real scene with scripted swipes; " % [
		_n, _rows.size(), ms / 1000.0] + "stand-in = tools/career_sim.gd _make_chance for the same kicker.")
	L.append("")
	# Summary: by stage, quality and skill (calm), averaged over distances in range.
	L.append("## By kicker quality and swipe skill (calm, all distances in range)")
	L.append("")
	L.append("| Stage | Kicker (stand-in FG%) | Swipes | Real | Stand-in | Gap | Crooked penalty (avg) |")
	L.append("|---|---|---|---|---|---|---|")
	for key in _groups(["stage", "q", "skill", "cond"]):
		var rs: Array = key[1]
		var real := _mean(rs, "real")
		var st := _mean(rs, "stand")
		L.append("| %s | %d%% | %s%s | %d%% | %d%% | %+d | %.2f |" % [rs[0]["stage"], roundi(rs[0]["q"] * 100.0),
			rs[0]["skill"], "" if rs[0]["cond"] == "calm" else " (%s%s)" % [rs[0]["cond"],
			", nerves x%.2f" % rs[0]["nerves"] if rs[0]["cond"] == "slump" else ""],
			roundi(real * 100.0), roundi(st * 100.0), roundi((real - st) * 100.0), _mean(rs, "penalty")])
	L.append("")
	L.append("## By distance (calm; real / stand-in)")
	L.append("")
	var dists: Array = []
	for r in _rows:
		if not (r["yards"] in dists):
			dists.append(r["yards"])
	dists.sort()
	var head := "| Stage | Kicker | Swipes |"
	var sep := "|---|---|---|"
	for d in dists:
		head += " %d yd |" % d
		sep += "---|"
	L.append(head)
	L.append(sep)
	for key in _groups(["stage", "q", "skill", "cond"]):
		var rs: Array = key[1]
		var line := "| %s | %d%% | %s%s |" % [rs[0]["stage"], roundi(rs[0]["q"] * 100.0), rs[0]["skill"],
			"" if rs[0]["cond"] == "calm" else " (%s)" % rs[0]["cond"]]
		for d in dists:
			var hit := rs.filter(func(r): return r["yards"] == d)
			line += (" %d / %d |" % [roundi(hit[0]["real"] * 100.0), roundi(hit[0]["stand"] * 100.0)]) \
				if not hit.is_empty() else " - |"
		L.append(line)
	L.append("")
	var text := "\n".join(L)
	print(text)
	if path != "":
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f != null:
			f.store_string(text)


## Rows grouped by the given keys, in first-seen order: [[key, rows], ...].
func _groups(keys: Array) -> Array:
	var order: Array = []
	var by := {}
	for r in _rows:
		var k := ",".join(PackedStringArray(keys.map(func(x): return str(r[x]))))
		if not by.has(k):
			by[k] = []
			order.append(k)
		by[k].append(r)
	return order.map(func(k): return [k, by[k]])


static func _mean(rs: Array, key: String) -> float:
	var s := 0.0
	for r in rs:
		s += float(r[key])
	return s / maxi(rs.size(), 1)
