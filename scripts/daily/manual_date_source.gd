class_name ManualDateSource
extends DateSource
## A clock you set by hand: tests, and anything that needs a fixed "now".

var unix: int = 0
var offset_minutes: int = 0


func _init(at_unix: int = 0, offset_min: int = 0) -> void:
	unix = at_unix
	offset_minutes = offset_min


func now_unix() -> int:
	return unix


func utc_offset_minutes() -> int:
	return offset_minutes


## Unix time of a local wall-clock time in this source's time zone.
func at_local(year: int, month: int, day: int, hour := 12, minute := 0) -> int:
	var t := Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": day,
		"hour": hour, "minute": minute, "second": 0})
	return int(t) - offset_minutes * 60


func set_local(year: int, month: int, day: int, hour := 12, minute := 0) -> void:
	unix = at_local(year, month, day, hour, minute)
