class_name TryoutMode
extends KickMode
## A Career tryout (walk-on, training camp, free agent): a fixed series of
## field goals at the distances in progression.json "tryouts". Kicks are
## reported as career kicks (they count in My Stats). The screen ends the run
## when every kick is taken.

var distances: Array = []
var pressure: float = 0.3
var wind_max: float = 8.0
var title: String = "TRYOUT"
var kicks: int = 0
var makes: int = 0


static func from_tryout(t: Dictionary) -> TryoutMode:
	var m := TryoutMode.new()
	m.distances = t.get("distances", [30, 35, 40, 45, 50])
	m.pressure = float(t.get("pressure", 0.3))
	m.wind_max = float(t.get("wind_max", 8.0))
	m.title = str(t.get("title", "TRYOUT"))
	return m


func id() -> StringName:
	return &"career"


func next_situation(rng: RandomNumberGenerator, tuning: KickTuning, wind: Wind) -> KickSituation:
	var s := KickSituation.new()
	s.distance_yards = int(distances[mini(kicks, distances.size() - 1)])
	var mph := roundf(rng.randf_range(0.0, wind_max)) * (1.0 if rng.randf() < 0.5 else -1.0)
	wind.set_conditions(rng, tuning, mph, 0.0)
	s.wind_mph = mph
	# Pressure builds through the tryout.
	s.pressure = clampf(pressure + 0.08 * kicks, 0.0, 1.0)
	s.label = "%s  -  KICK %d OF %d" % [title, kicks + 1, distances.size()]
	return s


func wants_next_kick() -> bool:
	return kicks < distances.size()


func record(r: KickReport) -> void:
	kicks += 1
	if r.made:
		makes += 1
