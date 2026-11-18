class_name KickTuning
extends Resource
## Every tunable number for the kick lives here.
##
## Two ways to tweak:
##   1. Open res://tuning/kick_tuning.tres in the Inspector (values saved there
##      override the defaults below).
##   2. Change the defaults in this file.
##
## Units: meters, seconds, degrees, mph. "Screen heights" means a fraction of the
## visible screen height, so swipes feel the same on every resolution/device.

@export_group("Ball Physics")
## Downward acceleration (m/s^2). Real = 9.8. Higher = flatter, snappier arcs.
@export var gravity: float = 9.8
## Simulation speed multiplier for the flight only. >1 = faster flights (less waiting).
@export var flight_speed_scale: float = 1.3
## Fixed launch angle above the ground. Real kicks are ~35-45 degrees.
@export_range(15.0, 60.0) var launch_elevation_deg: float = 38.0
## Launch speed (m/s) at 0% power. 12 m/s ~= 15 yards of carry.
@export var min_launch_speed: float = 12.0
## Launch speed (m/s) at 100% power. 30 m/s clears the bar from ~70 yards.
@export var max_launch_speed: float = 30.0

@export_group("Swipe -> Power")
## Swipes shorter than this (screen heights) are ignored.
@export var min_swipe_length: float = 0.06
## Flick speed (screen heights / second) that maps to 0% power.
@export var flick_speed_for_min_power: float = 0.8
## Flick speed (screen heights / second) that maps to 100% power.
@export var flick_speed_for_max_power: float = 4.5
## Swipe length (screen heights) that counts as "full length".
@export var swipe_length_for_max_power: float = 0.55
## How much swipe LENGTH matters vs flick SPEED. 0 = speed only, 1 = length only.
@export_range(0.0, 1.0) var length_weight: float = 0.3
## Power curve exponent. 1 = linear, >1 = full power is harder to reach, <1 = easier.
@export_range(0.3, 3.0) var power_curve: float = 1.2

@export_group("Swipe -> Aim")
## Degrees of kick yaw per degree of swipe tilt from vertical.
@export var aim_sensitivity: float = 0.35
## Clamp on swipe-driven yaw (degrees).
@export var max_aim_deg: float = 20.0
## Swipes tilted more than this from vertical are rejected (degrees).
@export var max_swipe_tilt_deg: float = 70.0

@export_group("Wind")
## Strongest possible crosswind (mph).
@export var max_wind_mph: float = 20.0
## Sideways acceleration (m/s^2) per mph of wind.
@export var wind_accel_per_mph: float = 0.05
## Chance (0-1) that an attempt has no wind at all.
@export_range(0.0, 1.0) var calm_chance: float = 0.15
## Chance (0-1) that a windy attempt is gusty.
@export_range(0.0, 1.0) var gust_chance: float = 0.5
## Strongest extra mph a gust can add on top of the base wind.
@export var max_gust_mph: float = 10.0
## Gust cycles per second (how quickly gusts come and go).
@export var gust_speed: float = 0.35

@export_group("Pressure")
## Aim wobble (degrees) at maximum pressure.
@export var max_wobble_deg: float = 4.0
## Wobble cycles per second.
@export var wobble_speed: float = 0.6
## Seconds to kick after the snap at zero pressure (then BLOCKED).
@export var base_kick_window: float = 2.6
## Seconds to kick after the snap at maximum pressure.
@export var min_kick_window: float = 1.1
## How much pressure drives wobble (0 = never wobbles).
@export_range(0.0, 1.0) var pressure_wobble_effect: float = 1.0
## How much pressure shrinks the kick window (0 = never shrinks).
@export_range(0.0, 1.0) var pressure_window_effect: float = 1.0

@export_group("Attempt")
@export var min_distance_yards: int = 20
@export var max_distance_yards: int = 60
## Seconds between the attempt appearing and the snap.
@export var snap_delay: float = 1.0
## Seconds for the snap to travel from the snapper to the holder's hands.
@export var snap_travel_time: float = 0.4
## Seconds for the holder to put the ball down. The kick window starts after this,
## but the defense starts rushing at the snap.
@export var hold_place_time: float = 0.18
## Spiral turns on the snap.
@export var snap_spins: int = 3
## Real seconds the result shows before a tap can start the next kick.
@export var result_min_display: float = 0.8

@export_group("Feel")
## Engine time scale during the result slow-motion beat.
@export_range(0.05, 1.0) var slowmo_scale: float = 0.25
## Real seconds the slow-motion beat lasts.
@export var slowmo_duration: float = 0.6
## Horizontal field of view (degrees). Lower = longer lens = bigger posts.
@export_range(20.0, 80.0) var camera_fov: float = 46.0
## How much the kicker's head turns to watch the ball. 0 = fixed stare at the posts.
## The camera never moves position.
@export_range(0.0, 1.0) var camera_follow_strength: float = 0.15
## How quickly the camera catches up (higher = tighter).
@export var camera_follow_speed: float = 3.0
## Camera shake on contact (meters, scaled by power).
@export var kick_shake: float = 0.05
## Ball end-over-end spin (radians / second).
@export var ball_spin_speed: float = 14.0
## Visual-only ball size on the tee (1 = real size). Big = reads like a hero object.
@export var ball_visual_scale: float = 2.5
## Visual-only ball size once it's ~15 m downfield, so it doesn't dwarf the posts.
@export var ball_visual_scale_far: float = 1.7
## Phone vibration on contact (ms, scaled up a little by power). 0 = off.
@export var kick_vibration_ms: int = 40
## Phone vibration when the kick is blocked (ms). 0 = off.
@export var block_vibration_ms: int = 120
## Show power / aim / wobble numbers after each kick (handy while tuning).
@export var show_debug_readout: bool = true
