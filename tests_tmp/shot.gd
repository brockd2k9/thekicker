extends Node
## Dev-only: open a screen with a seeded career and save a PNG.
## godot --path . res://tests_tmp/shot.tscn -- screen=hub out=/path.png

func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	get_tree().current_scene = null
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2: args[kv[0]] = kv[1]
	var screen: String = args.get("screen", "main")
	if screen != "main":
		var m := CareerManager.create(3, "Jordan Reyes", 7, {"skin": 2, "hair": 1}, "ridgeline")
		var c := m.data
		c.week = 5; c.week_index = 4
		c.record = {"w": 3, "l": 1, "t": 0}
		for k in ["power", "accuracy", "energy", "fun", "charisma", "ambition"]:
			c.set_stat(k, c.stat(k) + 14)
		c.set_stat("health", 82); c.set_stat("social", 28)
		c.traits = ["driven", "film_student"]
		c.recruiting_score = 41
		c.recent_results = [
			{"week": 3, "outcome": "W", "opponent": "Cedar Hollow", "us": 24, "them": 17, "line": "FG 3/3, long 41"},
			{"week": 4, "outcome": "L", "opponent": "Pine Bluff", "us": 13, "them": 20, "line": "FG 1/2, XP 1/1"}]
		GameState.career = m
	var path: String = {"main": Screens.MAIN_MENU, "hub": Screens.CAREER_HUB, "career": Screens.CAREER}[screen]
	Screens.go(path)
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(args.get("out", "user://shot.png"))
	get_tree().quit()
