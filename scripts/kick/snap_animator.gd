class_name SnapAnimator
extends Node
## The snap: the ball sits on the line of scrimmage in the long snapper's
## hands, spirals back to the holder, and the holder spots it for the kick.
## Pure animation: it only moves the ball and reports when each step is done.

## The holder has the ball in their hands.
signal caught
## The ball is down on the spot; it can be kicked.
signal placed

## Peak height (m) added to the straight line from snapper to holder.
@export var arc_height: float = 0.25

var _tween: Tween


## Put the ball in the snapper's hands, lying flat and pointing back at us.
func set_ready(ball: Ball, snap_spot: Vector3) -> void:
	stop()
	ball.set_pose(snap_spot, Vector3.ZERO)


## Run the whole snap. travel_time: snapper to holder's hands.
## place_time: hands to the ground. spins: whole spiral turns in the air.
func play(ball: Ball, snap_spot: Vector3, catch_pos: Vector3,
		travel_time: float, place_time: float, spins: int) -> void:
	stop()
	_tween = create_tween()
	_tween.tween_method(_travel_step.bind(ball, snap_spot, catch_pos, spins),
		0.0, 1.0, travel_time)
	_tween.tween_callback(caught.emit)
	_tween.tween_method(_place_step.bind(ball, catch_pos, ball.hold_position(), ball.hold_rotation()),
		0.0, 1.0, place_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_callback(placed.emit)


func stop() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null


func _travel_step(t: float, ball: Ball, from: Vector3, to: Vector3, spins: int) -> void:
	var p := from.lerp(to, t)
	p.y += sin(t * PI) * arc_height
	# Nose-first spiral around the long axis. Whole turns, so it lands at 0.
	ball.set_pose(p, Vector3(0.0, 0.0, t * spins * TAU))


func _place_step(t: float, ball: Ball, from: Vector3, to: Vector3, rot: Vector3) -> void:
	ball.set_pose(from.lerp(to, t), Vector3.ZERO.lerp(rot, t))
