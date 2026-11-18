class_name KickReport
extends RefCounted
## The one result event. Built once per attempt by field_goal_game.gd at the
## moment the kick is judged, then sent to GameState.report_kick(), which emits
## GameState.kick_resolved. Stats, achievements and every mode (Practice,
## Challenge, Career later) read this and nothing else.

var outcome: KickResult.Outcome = KickResult.Outcome.GOOD
var made: bool = false
## &"" when made, else &"wide_left", &"wide_right", &"short" or &"blocked".
var miss_type: StringName = &""
var distance_yards: int = 0
## Situation pressure 0..1 (before any Composure modifier).
var pressure: float = 0.0
## Signed steady crosswind for the attempt (+ = toward the kicker's right).
var wind_mph: float = 0.0
## Extra mph at peak gust (0 = steady).
var wind_gust_mph: float = 0.0
## Signed wind at the moment the ball was kicked (or blocked), gust included.
var wind_at_kick_mph: float = 0.0
var situation_label: String = ""
## Which mode produced the kick: &"practice", &"challenge", later &"career".
var mode: StringName = &"practice"
## Extra detail, e.g. "Tipped at the line!".
var note: String = ""
## Unix time (UTC seconds).
var timestamp: int = 0


static func create(o: KickResult.Outcome, s: KickSituation, wind_now: float,
		mode_id: StringName, note_text: String = "") -> KickReport:
	var r := KickReport.new()
	r.outcome = o
	r.made = KickResult.is_good(o)
	r.miss_type = miss_type_of(o)
	r.distance_yards = s.distance_yards
	r.pressure = s.pressure
	r.wind_mph = s.wind_mph
	r.wind_gust_mph = s.wind_gust_mph
	r.wind_at_kick_mph = wind_now
	r.situation_label = s.label
	r.mode = mode_id
	r.note = note_text
	r.timestamp = int(Time.get_unix_time_from_system())
	return r


static func miss_type_of(o: KickResult.Outcome) -> StringName:
	match o:
		KickResult.Outcome.WIDE_LEFT:
			return &"wide_left"
		KickResult.Outcome.WIDE_RIGHT:
			return &"wide_right"
		KickResult.Outcome.SHORT:
			return &"short"
		KickResult.Outcome.BLOCKED:
			return &"blocked"
	return &""


## Plain data, used by achievement conditions (and handy for logging).
func to_dict() -> Dictionary:
	return {
		"made": made,
		"miss_type": String(miss_type),
		"distance_yards": distance_yards,
		"pressure": pressure,
		"wind_mph": wind_mph,
		"wind_gust_mph": wind_gust_mph,
		"wind_at_kick_mph": wind_at_kick_mph,
		"mode": String(mode),
		"timestamp": timestamp,
	}
