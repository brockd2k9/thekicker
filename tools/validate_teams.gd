extends Node
## Team data validator (dev tool): checks data/teams/*.json (TeamDatabase.validate)
## and prints every problem.
##   godot --headless --path . res://tools/validate_teams.tscn
##   godot --headless --path . res://tools/validate_teams.tscn -- warnings=0   (errors only)
## Exit code: the number of errors (0 = the data is fine to use).


func _ready() -> void:
	var show_warnings := not ("warnings=0" in OS.get_cmdline_user_args())
	TeamDatabase.load_files()
	var r: Dictionary = TeamDatabase.validate()
	for lv in TeamDatabase.LEVELS:
		var ts: Array = TeamDatabase.teams(lv)
		var divs := {}
		for t in ts:
			divs[str(t.get("division", ""))] = int(divs.get(str(t.get("division", "")), 0)) + 1
		print("%s: %d teams %s" % [lv, ts.size(), divs])
	print("start team: %s" % TeamDatabase.start_team().get("name", "(missing)"))
	for e in r["errors"]:
		print("ERROR   " + e)
	if show_warnings:
		for w in r["warnings"]:
			print("warning " + w)
	print("TEAM DATA: %d error(s), %d warning(s)" % [r["errors"].size(), r["warnings"].size()])
	get_tree().quit(r["errors"].size())
