class_name RushPlan
extends RefCounted
## The defense's block call for one attempt, rolled fresh every snap so plays
## look different. Pure data: FieldBuilder turns it into motion.
##
## Fairness rule: exactly ONE defender (the "blocker") reaches the ball when
## the kick window runs out, so BLOCKED always has someone to show for it.
## Everyone else does their own thing and never gets there.

enum Blocker { LEFT_EDGE, RIGHT_EDGE, MIDDLE }
## What a lineman does at the line.
enum Action { PUSH, HANDS_UP, LEAP, DIVE }

const EDGE_LEFT := 0
const EDGE_RIGHT := 1

var blocker: Blocker = Blocker.LEFT_EDGE
## The play's overall flavor (most linemen do this).
var theme: Action = Action.PUSH

## Per edge rusher [left, right]. reach: fraction of the path to the ball they
## cover (1 = gets there, 0 = stays home to contain).
var edge_reach: Array[float] = [0.0, 0.0]
## true = dive at the ball at the end, false = leap with arms up.
var edge_dives: Array[bool] = [true, true]
## Path timing exponent: higher = slow start, late burst.
var edge_burst: Array[float] = [1.6, 1.6]

## Per block-unit lineman (same order as FieldBuilder.DL_SPOTS).
var dl_action: Array[int] = []
## When (0..1 of the play) their move peaks.
var dl_timing: Array[float] = []
## Small alignment shift (x, z) so the front never looks identical.
var dl_shift: Array[Vector2] = []
## Lineman index who breaks through the middle (only when blocker == MIDDLE).
var penetrator: int = -1

var leaper_action: Action = Action.LEAP
var leaper_timing: float = 0.8
## How much ground the protection unit gives up (m).
var ol_give: float = 0.4


## dl_x: x position of each block-unit lineman, used to tell inside from outside.
static func roll(rng: RandomNumberGenerator, dl_x: PackedFloat32Array) -> RushPlan:
	var p := RushPlan.new()
	var r := rng.randf()
	if r < 0.35:
		p.blocker = Blocker.LEFT_EDGE
	elif r < 0.7:
		p.blocker = Blocker.RIGHT_EDGE
	else:
		p.blocker = Blocker.MIDDLE

	p.theme = _weighted_action(rng, [0.2, 0.35, 0.2, 0.25])

	for e in 2:
		var designated := (e == EDGE_LEFT and p.blocker == Blocker.LEFT_EDGE) \
			or (e == EDGE_RIGHT and p.blocker == Blocker.RIGHT_EDGE)
		if designated:
			p.edge_reach[e] = 1.0
		elif rng.randf() < 0.35:
			p.edge_reach[e] = 0.0  # stays home
		else:
			p.edge_reach[e] = rng.randf_range(0.3, 0.7)  # picked up by the wing
		p.edge_dives[e] = rng.randf() < 0.6
		p.edge_burst[e] = rng.randf_range(1.2, 2.2)

	var inside: Array[int] = []
	for i in dl_x.size():
		var x := absf(dl_x[i])
		var action: Action
		if x < 2.5:
			action = p.theme if rng.randf() < 0.7 else _weighted_action(rng, [0.5, 0.3, 0.1, 0.1])
		else:
			action = Action.HANDS_UP if rng.randf() < 0.4 else Action.PUSH
		p.dl_action.append(action)
		p.dl_timing.append(rng.randf_range(0.55, 0.9))
		p.dl_shift.append(Vector2(rng.randf_range(-0.15, 0.15), rng.randf_range(-0.1, 0.1)))
		if x < 1.0:
			inside.append(i)
	if p.blocker == Blocker.MIDDLE and not inside.is_empty():
		p.penetrator = inside[rng.randi_range(0, inside.size() - 1)]

	p.leaper_action = Action.LEAP if p.theme == Action.LEAP or rng.randf() < 0.4 \
		else _weighted_action(rng, [0.5, 0.5, 0.0, 0.0])
	p.leaper_timing = rng.randf_range(0.65, 0.9)
	p.ol_give = rng.randf_range(0.2, 0.6)
	return p


## weights: [PUSH, HANDS_UP, LEAP, DIVE]
static func _weighted_action(rng: RandomNumberGenerator, weights: Array) -> Action:
	var total := 0.0
	for w in weights:
		total += float(w)
	var pick := rng.randf() * total
	for i in weights.size():
		pick -= float(weights[i])
		if pick <= 0.0:
			return i as Action
	return Action.PUSH
