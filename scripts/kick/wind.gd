class_name Wind
extends Node
## Crosswind for the current attempt. Steady per kick (no gusts yet).

signal changed(mph: float)

## Signed mph. Positive pushes the ball to the kicker's RIGHT (+X).
var mph: float = 0.0


func roll(rng: RandomNumberGenerator, tuning: KickTuning) -> float:
	if rng.randf() < tuning.calm_chance:
		mph = 0.0
	else:
		var side := 1.0 if rng.randf() < 0.5 else -1.0
		mph = roundf(rng.randf_range(1.0, tuning.max_wind_mph)) * side
	changed.emit(mph)
	return mph


## Constant acceleration applied to the ball while airborne.
func acceleration(tuning: KickTuning) -> Vector3:
	return Vector3(mph * tuning.wind_accel_per_mph, 0.0, 0.0)
