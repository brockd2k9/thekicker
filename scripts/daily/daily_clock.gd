class_name DailyClock
extends RefCounted
## THE definition of a Daily Challenge "day". Every day decision (which
## scenario, streaks, claims, the reset) goes through day_number(), so moving
## the reset (another hour, UTC, server days) is a one-line change here.
##
## A day number counts local days since 1970-01-01: the day starts at local
## midnight (or day_start_hour) in the player's time zone.

const SECONDS_PER_DAY := 86400


## The day number of `unix` (UTC seconds) for a player `offset_min` minutes
## east of UTC, with the day starting at local `start_hour`.
static func day_number(unix: int, offset_min: int, start_hour := 0) -> int:
	var local := unix + offset_min * 60 - start_hour * 3600
	return floori(float(local) / SECONDS_PER_DAY)


## Seconds until the next day starts (for "New challenge in 5h 12m").
static func seconds_to_next_day(unix: int, offset_min: int, start_hour := 0) -> int:
	var local := unix + offset_min * 60 - start_hour * 3600
	return (day_number(unix, offset_min, start_hour) + 1) * SECONDS_PER_DAY - local


## {year, month, day, weekday} of a day number. weekday: 0 = Monday .. 6 = Sunday.
static func date_of(day: int) -> Dictionary:
	var d := Time.get_date_dict_from_unix_time(day * SECONDS_PER_DAY)
	return {"year": int(d["year"]), "month": int(d["month"]), "day": int(d["day"]),
		"weekday": (int(d["weekday"]) + 6) % 7}


static func weekday(day: int) -> int:
	return int(date_of(day)["weekday"])


const DAY_NAMES := ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
const MONTH_NAMES := ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]


## "WED NOV 25"
static func label(day: int) -> String:
	var d := date_of(day)
	return "%s %s %d" % [DAY_NAMES[int(d["weekday"])], MONTH_NAMES[int(d["month"]) - 1], int(d["day"])]


## "5h 12m" / "12m"
static func countdown_text(seconds: int) -> String:
	var s := maxi(seconds, 0)
	var h := s / 3600
	var m := (s % 3600) / 60
	if h > 0:
		return "%dh %02dm" % [h, m]
	return "%dm" % maxi(m, 1)
