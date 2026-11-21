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
	## Launch angle after any rushed-kick drop.
	var elevation_deg: float
	var wobble_deg: float
	## Crooked-swipe result (KickDifficulty): how crooked 0..1, the penalty 0..1
	## it earned at this distance, and the sideways curl in flight (m/s^2, + = right).
	var crooked: float = 0.0
	var penalty: float = 0.0
	var hook_accel: float = 0.0


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


## rush: play progress at the moment of the kick (0 = snap, 1 = blocker at the
## ball). Late, hurried kicks come off lower (see KickTuning "Blocks").
## diff / yards (optional): KickDifficulty and the kick's distance. A crooked
## swipe then costs aim, power and adds a hook/slice, more so on long kicks,
## and long kicks get a little extra aim error. Without them: the old math.
func build_shot(swipe: Swipe, tuning: KickTuning, mods: KickModifiers,
		wobble_deg: float, rng: RandomNumberGenerator, rush: float = 0.0,
		diff: KickDifficulty = null, yards: float = 0.0) -> Shot:
	var shot := Shot.new()
	shot.power = power_from_swipe(swipe, tuning)
	shot.swipe_aim_deg = clampf(swipe.tilt_deg() * tuning.aim_sensitivity,
		-tuning.max_aim_deg, tuning.max_aim_deg)
	shot.wobble_deg = wobble_deg
	var curl := 0.0
	var spread_sd := mods.accuracy_spread_deg  # Career aim error (KickProfile)
	if diff != null and diff.enabled:
		shot.crooked = swipe.crookedness(diff.crooked_angle_deg, diff.crooked_bow)
		shot.penalty = diff.penalty(shot.crooked, yards)
		var side := swipe.curl_side()
		curl = side * shot.penalty * diff.max_deviation_degrees
		shot.hook_accel = side * shot.penalty * diff.max_hook_accel
		shot.power *= 1.0 - shot.penalty * diff.max_power_loss
		# Long-kick aim error stacks with the Career spread (independent errors).
		var extra := diff.extra_spread_deg(yards)
		spread_sd = sqrt(spread_sd * spread_sd + extra * extra)
	var spread := 0.0
	if spread_sd > 0.0:
		spread = rng.randfn(0.0, spread_sd)
	shot.final_aim_deg = shot.swipe_aim_deg + wobble_deg + spread + curl

	var speed := lerpf(tuning.min_launch_speed, tuning.max_launch_speed * mods.power_mult, shot.power)
	var yaw := deg_to_rad(shot.final_aim_deg)
	var hurried := smoothstep(tuning.rushed_from, 1.0, rush)
	shot.elevation_deg = tuning.launch_elevation_deg - tuning.rushed_elevation_drop_deg * hurried
	var elev := deg_to_rad(shot.elevation_deg)
	shot.velocity = Vector3(
		sin(yaw) * cos(elev),
		sin(elev),
		-cos(yaw) * cos(elev)) * speed
	return shot
