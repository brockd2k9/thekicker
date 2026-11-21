extends RefCounted
## Base for test files (tests/test_*.gd). Every method named test_* runs once
## on a fresh instance. Use check() / eq(); a failing check records a message
## and the test keeps going, so one run shows every failure.

var failures: PackedStringArray = []
var _current := ""


func check(cond: bool, msg: String) -> void:
	if not cond:
		failures.append("%s: %s" % [_current, msg])


func eq(actual: Variant, expected: Variant, msg: String) -> void:
	if typeof(actual) in [TYPE_FLOAT, TYPE_INT] and typeof(expected) in [TYPE_FLOAT, TYPE_INT]:
		check(is_equal_approx(float(actual), float(expected)),
			"%s (got %s, expected %s)" % [msg, actual, expected])
	else:
		check(actual == expected, "%s (got %s, expected %s)" % [msg, actual, expected])


## A JSON file under res://tests/fixtures/ as a fresh Dictionary.
static func fixture(name: String) -> Dictionary:
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/" + name))
	return d if d is Dictionary else {}


## `people` as JSON without Tyler's team: save version 8 moves old team ids to
## the team database (test_team_database.gd checks that part), so frozen-save
## tests compare the rest of the cast exactly.
static func people_json(people: Dictionary) -> String:
	var p := people.duplicate(true)
	for k in p:
		if p[k] is Dictionary:
			(p[k] as Dictionary).erase("team")
	return JSON.stringify(p)


## `history` as JSON without each season's team_id (added by save version 10).
static func history_json(history: Array) -> String:
	var h := history.duplicate(true)
	for row in h:
		if row is Dictionary:
			(row as Dictionary).erase("team_id")
	return JSON.stringify(h)
