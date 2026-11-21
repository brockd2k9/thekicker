class_name Swipe
extends RefCounted
## One finished swipe. All "norm" values are in screen heights, so the same
## gesture produces the same kick on a phone, tablet, or desktop window.

var start: Vector2
var end: Vector2
## Real seconds from press to release (unaffected by slow motion).
var duration: float = 0.0
## Speed (pixels / second) over the last part of the swipe: the "flick".
var flick_speed_px: float = 0.0
## Visible screen height in pixels when the swipe happened.
var screen_height: float = 1.0
## The whole path, press to release (empty = unknown: treated as straight).
var points: PackedVector2Array = PackedVector2Array()


func delta() -> Vector2:
	return end - start


func length_norm() -> float:
	return delta().length() / screen_height


func flick_speed_norm() -> float:
	return flick_speed_px / screen_height


func is_upward() -> bool:
	return delta().y < 0.0


## 0 = straight up the screen, positive = tilted right, negative = tilted left.
func tilt_deg() -> float:
	var d := delta()
	return rad_to_deg(atan2(d.x, -d.y))


## Signed degrees the last part of the swipe turns away from the straight
## start->end line (+ = finishes turning right). 0 if the path is unknown.
func finish_angle_deg() -> float:
	if points.size() < 3:
		return 0.0
	var chord := delta()
	if chord.length() < 1.0:
		return 0.0
	# Direction over the last ~30% of the path's length.
	var total := 0.0
	for i in range(1, points.size()):
		total += points[i].distance_to(points[i - 1])
	var want := total * 0.3
	var j := points.size() - 1
	var acc := 0.0
	while j > 0 and acc < want:
		acc += points[j].distance_to(points[j - 1])
		j -= 1
	var tail := points[points.size() - 1] - points[j]
	if tail.length() < 1.0:
		return 0.0
	# Screen y points down; angle_to gives + for a clockwise (rightward) turn.
	return rad_to_deg(chord.angle_to(tail))


## Signed bulge of the path off the straight start->end line, as a fraction of
## its length (+ = bulges to the right). 0 if the path is unknown.
func bow() -> float:
	if points.size() < 3:
		return 0.0
	var chord := delta()
	var len := chord.length()
	if len < 1.0:
		return 0.0
	var n := Vector2(-chord.y, chord.x) / len  # chord rotated 90°: points right of an upward swipe
	var most := 0.0
	for p in points:
		var off := (p - start).dot(n)
		if absf(off) > absf(most):
			most = off
	return most / len


## How crooked the swipe is: 0 = straight, 1 = clearly crooked (either measure
## at its limit). angle_limit_deg / bow_limit: KickDifficulty.crooked_angle_deg / crooked_bow.
func crookedness(angle_limit_deg: float, bow_limit: float) -> float:
	var a := absf(finish_angle_deg()) / maxf(angle_limit_deg, 0.001)
	var b := absf(bow()) / maxf(bow_limit, 0.001)
	return clampf(maxf(a, b), 0.0, 1.0)


## Which way a crooked swipe sends the ball: the way it finished turning, else
## away from its bulge (a path bowed right finishes heading left). +1 right, -1 left.
func curl_side() -> float:
	var a := finish_angle_deg()
	if absf(a) >= 2.0:
		return signf(a)
	var b := bow()
	return -signf(b) if absf(b) > 0.0 else 0.0
