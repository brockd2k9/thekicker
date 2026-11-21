# Real-swipe check: the real kick scene vs the simulator's stand-in

100 kicks per cell, 140 cells, 556 s. Real = made in the real scene with scripted swipes; stand-in = tools/career_sim.gd _make_chance for the same kicker.

## By kicker quality and swipe skill (calm, all distances in range)

| Stage | Kicker (stand-in FG%) | Swipes | Real | Stand-in | Gap | Crooked penalty (avg) |
|---|---|---|---|---|---|---|
| college | 60% | steady | 94% | 64% | +30 | 0.01 |
| college | 60% | average | 83% | 64% | +18 | 0.06 |
| college | 60% | sloppy | 64% | 64% | +0 | 0.21 |
| college | 60% | average (slump, nerves x1.25) | 83% | 64% | +18 | 0.06 |
| college | 60% | average (wind) | 83% | 61% | +22 | 0.06 |
| college | 75% | steady | 97% | 78% | +19 | 0.01 |
| college | 75% | average | 89% | 78% | +11 | 0.06 |
| college | 75% | sloppy | 72% | 78% | -6 | 0.20 |
| college | 75% | average (slump, nerves x1.25) | 89% | 78% | +11 | 0.07 |
| college | 75% | average (wind) | 90% | 74% | +16 | 0.05 |
| pro | 60% | steady | 95% | 66% | +29 | 0.01 |
| pro | 60% | average | 86% | 66% | +20 | 0.05 |
| pro | 60% | sloppy | 65% | 66% | -1 | 0.21 |
| pro | 60% | average (slump, nerves x1.25) | 85% | 66% | +19 | 0.06 |
| pro | 60% | average (wind) | 85% | 63% | +22 | 0.05 |
| pro | 75% | steady | 96% | 78% | +18 | 0.01 |
| pro | 75% | average | 90% | 78% | +12 | 0.06 |
| pro | 75% | sloppy | 72% | 78% | -7 | 0.17 |
| pro | 75% | average (slump, nerves x1.25) | 90% | 78% | +12 | 0.05 |
| pro | 75% | average (wind) | 88% | 75% | +13 | 0.07 |

## By distance (calm; real / stand-in)

| Stage | Kicker | Swipes | 20 yd | 25 yd | 30 yd | 35 yd | 40 yd | 45 yd | 50 yd |
|---|---|---|---|---|---|---|---|---|---|
| college | 60% | steady | 98 / 89 | 93 / 81 | 96 / 73 | 96 / 65 | 93 / 57 | 93 / 49 | 90 / 38 |
| college | 60% | average | 93 / 89 | 92 / 81 | 92 / 73 | 84 / 65 | 80 / 57 | 66 / 49 | 72 / 38 |
| college | 60% | sloppy | 88 / 89 | 87 / 81 | 60 / 73 | 66 / 65 | 59 / 57 | 46 / 49 | 44 / 38 |
| college | 60% | average (slump) | 93 / 89 | 92 / 81 | 87 / 73 | 82 / 65 | 85 / 57 | 74 / 49 | 65 / 38 |
| college | 60% | average (wind) | 96 / 85 | 96 / 77 | 93 / 69 | 88 / 61 | 82 / 54 | 64 / 46 | 65 / 34 |
| college | 75% | steady | 96 / 92 | 98 / 87 | 97 / 83 | 95 / 78 | 96 / 74 | 96 / 69 | 98 / 61 |
| college | 75% | average | 98 / 92 | 95 / 87 | 94 / 83 | 93 / 78 | 87 / 74 | 79 / 69 | 77 / 61 |
| college | 75% | sloppy | 93 / 92 | 85 / 87 | 75 / 83 | 68 / 78 | 74 / 74 | 58 / 69 | 48 / 61 |
| college | 75% | average (slump) | 97 / 92 | 98 / 87 | 96 / 83 | 86 / 78 | 86 / 74 | 80 / 69 | 79 / 61 |
| college | 75% | average (wind) | 98 / 88 | 99 / 84 | 95 / 79 | 91 / 75 | 89 / 70 | 80 / 66 | 77 / 58 |
| pro | 60% | steady | 99 / 87 | 96 / 80 | 93 / 73 | 96 / 66 | 96 / 60 | 94 / 53 | 91 / 43 |
| pro | 60% | average | 93 / 87 | 94 / 80 | 90 / 73 | 90 / 66 | 82 / 60 | 80 / 53 | 76 / 43 |
| pro | 60% | sloppy | 83 / 87 | 81 / 80 | 71 / 73 | 62 / 66 | 55 / 60 | 56 / 53 | 45 / 43 |
| pro | 60% | average (slump) | 95 / 87 | 93 / 80 | 91 / 73 | 88 / 66 | 86 / 60 | 79 / 53 | 62 / 43 |
| pro | 60% | average (wind) | 98 / 83 | 96 / 76 | 88 / 70 | 89 / 63 | 81 / 56 | 70 / 50 | 70 / 39 |
| pro | 75% | steady | 96 / 89 | 98 / 86 | 97 / 82 | 97 / 79 | 92 / 75 | 97 / 72 | 97 / 65 |
| pro | 75% | average | 98 / 89 | 98 / 86 | 96 / 82 | 92 / 79 | 92 / 75 | 80 / 72 | 76 / 65 |
| pro | 75% | sloppy | 91 / 89 | 81 / 86 | 84 / 82 | 70 / 79 | 72 / 75 | 54 / 72 | 50 / 65 |
| pro | 75% | average (slump) | 97 / 89 | 96 / 86 | 96 / 82 | 91 / 79 | 92 / 75 | 82 / 72 | 79 / 65 |
| pro | 75% | average (wind) | 99 / 86 | 96 / 82 | 97 / 79 | 85 / 75 | 82 / 72 | 78 / 68 | 80 / 62 |

## Notes

- Run: `godot --headless --fixed-fps 60 --path . res://tools/kick_sample.tscn -- n=100 out=report.md`
  (about 9 minutes). The real scene is unmodified: PR #14's KickDifficulty, PR #15's nerves
  (via KickProfile), the rush, the pressure wobble, the ball physics.
- Swipe skills (tools/kick_sample.gd SKILLS): steady = tilt sd 2.5 deg, bow sd 0.015, hook sd 3 deg,
  flick 4.4 +- 0.25; average = 4.5 / 0.03 / 5 / 4.2 +- 0.45; sloppy = 7 / 0.05 / 8 / 3.9 +- 0.7.
  These are assumptions, not measured thumbs: the gap's size depends on them.
- Missing: the 90% kicker (the simulator's quality copy can't reach it at Power 70) and 55 yards
  (past every sampled kicker's range).
- Slump row: nerves x1.25 (a slump with no low life stats). The cap is x2.0; not sampled.
