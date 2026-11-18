class_name KickResult
extends RefCounted
## Outcome types and the rules for judging them.

enum Outcome { GOOD, WIDE_LEFT, WIDE_RIGHT, SHORT, BLOCKED }


## Called with the exact point where the ball crossed the plane of the uprights.
static func judge_at_goal_plane(crossing: Vector3) -> Outcome:
	var half := GoalPosts.INNER_WIDTH * 0.5
	if crossing.x < -half:
		return Outcome.WIDE_LEFT
	if crossing.x > half:
		return Outcome.WIDE_RIGHT
	if crossing.y < GoalPosts.CROSSBAR_HEIGHT:
		return Outcome.SHORT
	return Outcome.GOOD


static func is_good(o: Outcome) -> bool:
	return o == Outcome.GOOD


static func text(o: Outcome) -> String:
	match o:
		Outcome.GOOD:
			return "GOOD!"
		Outcome.WIDE_LEFT:
			return "WIDE LEFT"
		Outcome.WIDE_RIGHT:
			return "WIDE RIGHT"
		Outcome.SHORT:
			return "SHORT"
		Outcome.BLOCKED:
			return "BLOCKED"
	return "?"
