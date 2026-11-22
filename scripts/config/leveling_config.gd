class_name LevelingConfig
extends Resource
## Every number for how football attributes level up in Career Mode: the skill
## point cost curve and the per-stage caps. Edit res://tuning/leveling.tres in
## the Inspector (or the defaults here). Read through Leveling.config().
##
## Overall rating = the average of the four football attributes (Power,
## Accuracy, Resilience, Toughness), see Leveling.overall().
## The caps are hard limits, enforced everywhere attributes rise (skill point
## upgrades and every CareerStats change) and again when a stage ends.
## Skill point costs are computed ONLY by SkillPoints.cost_at() from this file.

@export_group("Upgrade Cost")
## Cost (skill points) to raise an attribute from level L to L + 1:
##   ceil(cost_base + cost_scale * (L / 100) ^ cost_exponent)
## Defaults: 4 SP at 30, 8 at 50, 17 at 70, 23 at 80, 30 at 90
## (2-3x the old prices, most of all at the top).
## (The old curve was 1 + 14 * (L/100)^3: 2 at 30, 3 at 50, 6 at 70, 12 at 90.)
@export var cost_base: float = 2.0
@export var cost_scale: float = 36.0
@export_range(1.0, 5.0) var cost_exponent: float = 2.6
## No attribute goes past this in any stage.
@export var attribute_max: float = 100.0

@export_group("Stage Caps")
## Highest overall rating (average of the four football attributes) and highest
## single attribute allowed in each stage. Leaving high school above
## hs_overall_cap is impossible (the guarantee the tests check).
@export var hs_overall_cap: float = 55.0
@export var hs_attribute_cap: float = 65.0
## Junior college is a short college detour: it uses the college caps.
@export var college_overall_cap: float = 78.0
@export var college_attribute_cap: float = 88.0
@export var pro_overall_cap: float = 100.0
@export var pro_attribute_cap: float = 100.0

@export_group("Old Saves")
## When a loaded career is over its stage's caps (saves from before these caps),
## attributes are lowered to fit and the skill points those points would cost
## now are refunded, times this (1 = full refund, 0 = none).
@export_range(0.0, 1.0) var clamp_refund_mult: float = 1.0
