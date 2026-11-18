class_name KickController
extends Node
## Converts a swipe into a launch velocity. Pure math, no scene access, so it is
## easy to test and to swap out.
##
## World axes: the kicker looks down -Z, +X is the kicker's right, +Y is up.


class Shot:
	extends RefCounted
	var velocity: Vector3
	## 0..1 after the power curve.
	var power: float
	## Yaw from the swipe alone (degrees, + = right).
	var swipe_aim_deg: float
	## Final yaw including pressure wobble and accuracy spread.
	var final_aim_deg: float
	var wobble_deg: float


## Returns "" if the swipe can be a kick, otherwise a short hint for the player.
func validate(swipe: Swipe, tuning: KickTuning) -> String:
	if swipe.length_norm() < tuning.min_swipe_length:
		return "Swipe further!"
	if not swipe.is_upward():
		return "Swipe UP toward the posts"
	if absf(swipe.tilt_deg()) > tuning.max_swipe_tilt_deg:
		return "Too sideways - swipe up"
	return ""


func power_from_swipe(swipe: Swipe, tuning: KickTuning) -> float:
	var speed_t := clampf(
		inverse_lerp(tuning.flick_speed_for_min_power, tuning.flick_speed_for_max_power,
			swipe.flick_speed_norm()),
		0.0, 1.0)
	var length_t := clampf(swipe.length_norm() / tuning.swipe_length_for_max_power, 0.0, 1.0)
	var raw := lerpf(speed_t, length_t, tuning.length_weight)
	return pow(raw, tuning.power_curve)


func build_shot(swipe: Swipe, tuning: KickTuning, mods: KickModifiers,
		wobble_deg: float, rng: RandomNumberGenerator) -> Shot:
	var shot := Shot.new()
	shot.power = power_from_swipe(swipe, tuning)
	shot.swipe_aim_deg = clampf(swipe.tilt_deg() * tuning.aim_sensitivity,
		-tuning.max_aim_deg, tuning.max_aim_deg)
	shot.wobble_deg = wobble_deg
	var spread := 0.0
	if mods.accuracy_spread_deg > 0.0:
		spread = rng.randfn(0.0, mods.accuracy_spread_deg)
	shot.final_aim_deg = shot.swipe_aim_deg + wobble_deg + spread

	var speed := lerpf(tuning.min_launch_speed, tuning.max_launch_speed * mods.power_mult, shot.power)
	var yaw := deg_to_rad(shot.final_aim_deg)
	var elev := deg_to_rad(tuning.launch_elevation_deg)
	shot.velocity = Vector3(
		sin(yaw) * cos(elev),
		sin(elev),
		-cos(yaw) * cos(elev)) * speed
	return shot
