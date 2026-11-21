class_name Wind
extends Node
## Wind for the current attempt: a crosswind with a steady base plus optional
## gusts, and (field goals, set_along()) a headwind / tailwind component that
## gusts along with it.
## Gusts only ever strengthen the wind in its own direction, from the base
## speed up to base + gust_mph, and spend most of their time in lulls.
## So timing your kick (watch the flags/arrow) matters.

signal changed(mph: float)

## Signed steady wind. Positive pushes the ball to the kicker's RIGHT (+X).
var base_mph: float = 0.0
## Extra mph at the peak of a gust (0 = steady wind).
var gust_mph: float = 0.0
## Signed wind right now (base + current gust).
var mph: float = 0.0
## Head / tailwind (signed mph, + = tailwind: pushes the ball downfield).
## 0 unless a mode or the kick scene sets it with set_along().
var along_base_mph: float = 0.0
## Head / tailwind right now (gusts scale it with the crosswind).
var along_mph: float = 0.0

var _t := 0.0
var _freq := 0.35
var _phase_a := 0.0
var _phase_b := 0.0


func roll(rng: RandomNumberGenerator, tuning: KickTuning) -> float:
	gust_mph = 0.0
	along_base_mph = 0.0
	along_mph = 0.0
	if rng.randf() < tuning.calm_chance:
		base_mph = 0.0
	else:
		var side := 1.0 if rng.randf() < 0.5 else -1.0
		base_mph = roundf(rng.randf_range(1.0, tuning.max_wind_mph)) * side
		if rng.randf() < tuning.gust_chance:
			gust_mph = roundf(rng.randf_range(0.3, 1.0) * tuning.max_gust_mph)
	_freq = tuning.gust_speed
	_t = 0.0
	_phase_a = rng.randf() * TAU
	_phase_b = rng.randf() * TAU
	mph = _current()
	changed.emit(mph)
	return base_mph


## Set the wind directly instead of rolling it (game modes, e.g. Challenge).
## base: signed steady mph. gust: extra mph at peak (0 = steady).
func set_conditions(rng: RandomNumberGenerator, tuning: KickTuning, base: float, gust: float) -> void:
	base_mph = base
	along_base_mph = 0.0
	along_mph = 0.0
	gust_mph = gust if absf(base) > 0.0 else 0.0
	_freq = tuning.gust_speed
	_t = 0.0
	_phase_a = rng.randf() * TAU
	_phase_b = rng.randf() * TAU
	mph = _current()
	changed.emit(mph)


## Add a headwind / tailwind (signed mph, + = tailwind). Call after roll() /
## set_conditions(), which reset it to 0.
func set_along(mph_along: float) -> void:
	along_base_mph = mph_along
	along_mph = _current_along()


func is_gusty() -> bool:
	return gust_mph > 0.0


func _physics_process(delta: float) -> void:
	_t += delta
	mph = _current()
	along_mph = _current_along()


## 0 = lull, 1 = peak gust.
func gust_amount() -> float:
	var w := _freq * TAU
	var s := 0.6 * sin(_t * w + _phase_a) + 0.4 * sin(_t * w * 2.3 + _phase_b)
	return pow(0.5 + 0.5 * s, 2.0)


func _current() -> float:
	if gust_mph <= 0.0:
		return base_mph
	return signf(base_mph) * (absf(base_mph) + gust_mph * gust_amount())


## Head / tailwind right now: gusts strengthen it in step with the crosswind.
func _current_along() -> float:
	if gust_mph <= 0.0 or absf(base_mph) < 0.01:
		return along_base_mph
	return along_base_mph * absf(_current()) / absf(base_mph)


## Acceleration applied to the ball right now (tailwind pushes toward -Z,
## downfield).
func acceleration(tuning: KickTuning) -> Vector3:
	return Vector3(mph * tuning.wind_accel_per_mph, 0.0, -along_mph * tuning.wind_accel_per_mph)
