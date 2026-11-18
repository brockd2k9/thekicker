class_name KickModifiers
extends RefCounted
## PHASE 2 SEAM. The kick code only ever reads these multipliers, never raw
## player stats. In Phase 2 a function like
##     KickModifiers.from_stats(player_stats)
## will map Leg Power / Accuracy / Composure / Fitness / Morale onto them.
## Phase 1 uses the neutral defaults below (1.0 = no effect).

## Leg Power -> scales the top launch speed.
var power_mult: float = 1.0
## Accuracy -> random aim error (std-dev, degrees) added at release.
var accuracy_spread_deg: float = 0.0
## Composure -> scales how hard situation pressure hits (wobble + window).
var pressure_sensitivity: float = 1.0
## Fitness / Morale -> scales the time you get to kick after the snap.
var window_mult: float = 1.0
