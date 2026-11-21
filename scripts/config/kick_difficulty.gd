class_name KickDifficulty
extends Resource
## Every number for "how hard is a field goal": crooked-swipe penalty, distance
## scaling, stronger wind and contact vibration. Edit res://tuning/kick_difficulty.tres
## in the Inspector (or the defaults here). Field goals and extra points use it;
## kickoffs, onside kicks and the warmup net don't.
##
## Stacks with Career Mode: KickModifiers (from the KickProfile and the week's
## scenario choices) still scale power, aim error, wobble, the kick window and
## wind exactly as before; everything here is applied on top.
## Set enabled = false to get the old, easier kicking back.

@export var enabled: bool = true

@export_group("Crooked Swipes")
## How crooked a swipe is, 0 = dead straight, 1 = clearly crooked, from two
## measurements (the larger wins):
##   * finish angle: how far the last part of the swipe turns away from the
##     straight start->end line (degrees; this many = fully crooked);
@export var crooked_angle_deg: float = 20.0
##   * bow: how far the path bulges off that line, as a fraction of the
##     swipe's length (this much = fully crooked).
@export var crooked_bow: float = 0.12
## Crookedness below this is forgiven completely (0..1). Normal thumb wobble
## sits around 0.1-0.3.
@export_range(0.0, 0.9) var straightness_tolerance: float = 0.2
## Shape of the penalty past the tolerance: 1 = linear, 2 = gentle at first and
## steep for clearly crooked swipes.
@export_range(1.0, 4.0) var straightness_penalty_curve: float = 2.0
## Extra aim error (degrees) at full penalty, in the direction the swipe curled.
@export var max_deviation_degrees: float = 10.0
## Power lost at full penalty (0.15 = 15% less launch power).
@export_range(0.0, 0.6) var max_power_loss: float = 0.15
## Sideways curl in flight at full penalty (m/s^2): the hook / slice.
@export var max_hook_accel: float = 1.2

@export_group("Distance")
## Kicks up to easy_yards get no extra difficulty; it ramps to full at hard_yards.
@export var easy_yards: float = 25.0
@export var hard_yards: float = 55.0
## At hard_yards the straightness tolerance is multiplied by this (smaller = less forgiving).
@export_range(0.1, 1.0) var tolerance_scale_at_hard: float = 0.5
## At hard_yards the crooked-swipe penalty is multiplied by this.
@export_range(1.0, 3.0) var penalty_scale_at_hard: float = 1.5
## Extra random aim error (std-dev, degrees) at hard_yards, on top of the
## Career accuracy spread. 0 at easy_yards.
@export var extra_spread_at_hard_deg: float = 0.6

@export_group("Wind")
## Multiplies the wind's push on the ball (crosswind and head/tailwind).
@export var wind_strength_multiplier: float = 1.4
## The push also grows the longer the ball is in the air: x(1 + this per second
## of flight), on top of drift already growing with hang time squared.
@export var hang_time_wind_growth: float = 0.15
## Field goals get a headwind / tailwind of up to this many mph (random, only on
## windy kicks). Tailwind carries the ball further, headwind holds it up.
@export var max_head_tail_mph: float = 12.0
## Head/tailwind push relative to crosswind push (along the field).
@export var head_tail_effect: float = 1.0

@export_group("Vibration")
## Pulse on contact (phones only). Clean strike: short and sharp.
@export var clean_vibration_ms: int = 28
@export_range(0.0, 1.0) var clean_vibration_amp: float = 1.0
## Mishit (full crooked-swipe penalty): longer and rougher (weaker, then a second buzz).
@export var mishit_vibration_ms: int = 110
@export_range(0.0, 1.0) var mishit_vibration_amp: float = 0.5


## 0 at easy_yards (and shorter), 1 at hard_yards (and longer).
func distance_factor(yards: float) -> float:
	return clampf(inverse_lerp(easy_yards, hard_yards, yards), 0.0, 1.0)


## Penalty 0..1 for a swipe this crooked (0..1) on a kick this long.
func penalty(crooked: float, yards: float) -> float:
	if not enabled:
		return 0.0
	var d := distance_factor(yards)
	var tol := straightness_tolerance * lerpf(1.0, tolerance_scale_at_hard, d)
	if crooked <= tol:
		return 0.0
	var excess := (crooked - tol) / maxf(1.0 - tol, 0.001)
	return clampf(pow(excess, straightness_penalty_curve) * lerpf(1.0, penalty_scale_at_hard, d), 0.0, 1.0)


## Extra random aim error (std-dev, degrees) for a kick this long.
func extra_spread_deg(yards: float) -> float:
	return extra_spread_at_hard_deg * distance_factor(yards) if enabled else 0.0
