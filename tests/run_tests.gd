extends Node
## Test runner (dev tool, not part of the game; excluded from exports with tests/*):
##   godot --headless --path . res://tests/run_tests.tscn
##   godot --headless --path . res://tests/run_tests.tscn -- only=test_saves
## Runs every method named test_* in every tests/test_*.gd file and prints one
## line per failure. Exit code = number of failing tests.

func _ready() -> void:
	var only := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("only="):
			only = a.substr(5)
	var files := Array(DirAccess.get_files_at("res://tests")).filter(func(f: String) -> bool:
		return f.begins_with("test_") and f.ends_with(".gd") and f != "test_case.gd" \
			and (only == "" or f.get_basename() == only))
	files.sort()
	var ran := 0
	var failed := 0
	for f in files:
		var script: GDScript = load("res://tests/" + f)
		var names: Array = []
		for m in script.get_script_method_list():
			if str(m["name"]).begins_with("test_") and not (m["name"] in names):
				names.append(m["name"])
		for n in names:
			var t: Object = script.new()
			t.set("_current", "%s.%s" % [f.get_basename(), n])
			t.call(n)
			ran += 1
			var fails: PackedStringArray = t.get("failures")
			if not fails.is_empty():
				failed += 1
				for msg in fails:
					print("FAIL ", msg)
	print("TESTS: %d run, %d failed" % [ran, failed])
	get_tree().quit(failed)
