class_name KickModifiers
extends RefCounted
## The kick code only ever reads these multipliers, never raw player stats.
## Career Mode builds them with KickProfile.build(...).to_kick_modifiers()
## (scripts/career/kick_profile.gd). Practice and Challenge use the neutral
## defaults below (1.0 / 0.0 = no effect).

## Power -> scales the top launch speed.
var power_mult: float = 1.0
## Accuracy -> random aim error (std-dev, degrees) added at release.
var accuracy_spread_deg: float = 0.0
## Resilience -> scales how hard situation pressure hits (wobble + window).
var pressure_sensitivity: float = 1.0
## Accuracy -> scales the time you get to kick after the snap.
var window_mult: float = 1.0
## Accuracy / Energy -> scales the pressure aim wobble.
var wobble_mult: float = 1.0
## Toughness -> scales how hard the wind pushes the ball.
var wind_mult: float = 1.0
## Career kickoff range: yards of carry a full-strength kickoff flick reaches
## (0 = not set: Practice / Challenge). kickoff_mult = kickoff_range_yd /
## KickoffRules' default max_carry_yards, for kickoff code that scales carry
## directly. (The current kickoff reads KickoffRules.max_carry_yards * power_mult;
## CareerGameMode.kickoff_rules_for() sets max_carry so that also lands here.)
var kickoff_range_yd: float = 0.0
var kickoff_mult: float = 1.0
