class_name KickLaunch
extends RefCounted
## Launch velocity for a tee kick that should travel a given distance.
## Kickoffs keep the old sideline carry curve (carry = max_carry * power *
## power_mult) so career balance doesn't move; this finds the launch speed that
## makes the 3D ball actually land there. Wind only pushes sideways, so it
## changes where the ball lands left/right, never how far.
##
## It steps the exact integrator Ball uses (same time step, gravity, bounce and
## ground height), so the flight matches to within a frame.

const PHYSICS_DT := 1.0 / 60.0


## carry_m: distance downfield to the first landing (until_rest = false) or to
## where the ball stops rolling (until_rest = true, onside kicks).
## start: the ball's launch position (its center on the tee).
static func velocity(carry_m: float, aim_deg: float, elevation_deg: float, gravity: float,
		sim_scale: float, start: Vector3, near_scale: float, far_scale: float,
		until_rest: bool) -> Vector3:
	var lo := 1.0
	var hi := 80.0
	for i in 32:
		var mid := (lo + hi) * 0.5
		if _distance(mid, elevation_deg, gravity, sim_scale, start, near_scale, far_scale, until_rest) < carry_m:
			lo = mid
		else:
			hi = mid
	return direction(aim_deg, elevation_deg) * ((lo + hi) * 0.5)


static func direction(aim_deg: float, elevation_deg: float) -> Vector3:
	var yaw := deg_to_rad(aim_deg)
	var elev := deg_to_rad(elevation_deg)
	return Vector3(sin(yaw) * cos(elev), sin(elev), -cos(yaw) * cos(elev))


## Downfield distance for a straight kick at this speed (mirrors Ball._physics_process).
static func _distance(speed: float, elevation_deg: float, gravity: float, sim_scale: float,
		start: Vector3, near_scale: float, far_scale: float, until_rest: bool) -> float:
	var elev := deg_to_rad(elevation_deg)
	var v := Vector2(cos(elev), sin(elev)) * speed  # x = downfield, y = up
	var p := Vector2(0.0, start.y)
	var dt := PHYSICS_DT * sim_scale
	for step in 3000:
		v.y -= gravity * dt
		var nxt := p + v * dt
		var s := lerpf(near_scale, far_scale, clampf(nxt.x / Ball.SCALE_BLEND_DISTANCE, 0.0, 1.0))
		var ground := Ball.BASE_RADIUS * s
		if nxt.y <= ground:
			if not until_rest:
				return nxt.x
			nxt.y = ground
			v.y = -v.y * 0.35
			v.x *= 0.6
			if Vector2(v.x, v.y).length() < 0.6:
				return nxt.x
		p = nxt
	return p.x
