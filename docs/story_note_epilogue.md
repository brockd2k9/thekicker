# The retirement epilogue and the Hall of Fame (R10, for the story session)

Gameplay side is on main. Rules: `scripts/career/hall_of_fame.gd`, `CareerManager.retire()` /
`_next_epilogue()`. No save version change.

## The flow after the last snap
1. `retire()` decides everything at once: the retirement-reason flags and the Hall of Fame vote
   (score, tier, flags). The stage becomes `retired`.
2. **The closing scenes**: every scenario with `"when": ["epilogue"]` and `"stages": ["retired"]`,
   in `order` (a number, default 0) then id order (PRO_E01 ... PRO_E12 sort as written). Each plays
   once, and the list is re-checked after every choice, so a choice in E02 can open E11 (set a
   flag; require it). Requirements work as everywhere (`flags`, `not_flags`, `any_flags`, `min` /
   `max` stats, traits, followers, savings...). Follow-ups and kick challenges are not used here.
   The scene card's tag reads "After the game".
3. **The Hall of Fame vote** screen (pro careers only): each part of the case with its points,
   the tiers and the result.
4. **The career summary** (also shows the Hall of Fame result).

The validator requires epilogue scenes to have exactly `"when": ["epilogue"]` and
`"stages": ["retired"]`. Your importer needs to accept `"epilogue"` as a `when` value and
`"retired"` as a stage (and the optional `"order"` number).

## Signals (CareerData.flags, set at retirement, before the first closing scene)
| Flag | Value |
|---|---|
| `hall_of_fame_earned` | true for first ballot or inducted |
| `hall_of_fame_tier` | `first_ballot`, `inducted`, `finalist`, `ring_of_honor` or `none` (a string; use the tier flags below in `requires`) |
| `hof_first_ballot`, `hof_inducted`, `hof_finalist`, `hof_ring_of_honor` | exactly one true when there's a tier |
| `retired_by_choice` | the player retired (or an old save's age cap) |
| `retired_out_of_football` | no team called / no roster spot |
| `retired_released` | forced out, and the last club released you |
| `retired_unsigned` | forced out, and the last club didn't re-sign you |
| `was_dismissed` (existing) | dismissed at some point |

A career that never reached the pros gets the reason flags but no vote (all `hof_*` false,
`hall_of_fame_tier` "none").

## The formula (approved; thresholds provisional until the kick retune)
Pro seasons only. Longevity 2.5 a season (max 50); accuracy +2.5 per point of pro FG% over 75
(150+ attempts; -1 a point under, at most -15); volume 0.1 per field goal made; clutch 3 per game
winner (max 30); distance 1 per make of 50+ (max 15) and +5 for a 60+ long; fame up to 5 by the best
followers tier; character -8 per suspension, -10 for character concerns at retirement, -25 if ever
dismissed. Tiers: Ring of Honor 60+, Finalist 80+, Hall of Fame 100+, First ballot 125+. The Ring of
Honor is from the club you played the most pro seasons for.

## Mapping to your drafted scenes
- E01 Retirement Day: versions by `retired_by_choice` / `retired_out_of_football` / `was_dismissed`.
- E03 Hall of Fame Eligibility: `requires {"any_flags": ["hof_finalist", "hof_inducted", "hof_first_ballot"]}`.
- E04 The Nomination, E05 The Call: `hall_of_fame_earned`. E06 The Call That Doesn't Come:
  `not_flags ["hall_of_fame_earned"]` (and `hof_finalist` for "a finalist, not elected").
- E11 Coach, Now / E12 In the Booth: a flag you set in an earlier closing scene's choice.
