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
