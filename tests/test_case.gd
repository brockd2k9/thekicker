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
