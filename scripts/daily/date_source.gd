class_name DateSource
extends RefCounted
## Where the Daily Challenge gets "now" from. The one seam for time: the
## device clock today; a server clock later (subclass it, override both
## methods, and hand it to DailyChallenge.clock). Tests use ManualDateSource.


## Seconds since the Unix epoch (UTC).
func now_unix() -> int:
	return int(Time.get_unix_time_from_system())


## The local time zone's offset from UTC in minutes (+ = east of UTC).
func utc_offset_minutes() -> int:
	return int(Time.get_time_zone_from_system().get("bias", 0))


## True when the time comes from somewhere the player can't change (a
## server). The device clock can be changed, so it's guarded (DailyChallenge).
func is_trusted() -> bool:
	return false
