# Phase 1 playtest checklist

Things that are built but **untuned**. Every value named here is in `tuning/kick_tuning.tres`.

1. **Power from flick speed.** The biggest unknown. `flick_speed_for_min/max_power` were picked
   without a real phone. If kicks are always short or always maxed, change these first.
   Use the debug readout (Power %) to calibrate.
2. **Length vs speed** (`length_weight` 0.3, `power_curve` 1.2). Does a long slow drag feel
   unfairly strong or weak?
3. **Aim sensitivity** (`aim_sensitivity` 0.35). A 60-yarder has about a ±3° cone, which is
   about ±8° of swipe tilt. This may be too twitchy on a small phone.
4. **Fixed launch angle** (38°). Swipe can't change the elevation yet. You may want it to.
5. **Wind strength** (`wind_accel_per_mph` 0.05). 20 mph moves a 50-yarder about 3.4 m, more
   than half the goal width. This may be too punishing combined with wobble.
6. **Pressure.** Max wobble (4°) is bigger than the make cone at 50+ yards, so clutch long kicks
   are mostly about timing the wobble. Also check the 1.1 s minimum kick window.
7. **Snap timing.** 1.0 s delay, then 2.6 s window at zero pressure. The rushers' approach
   speed is tied to the window.
8. **Flight speed** (`flight_speed_scale` 1.3). About 2.2 s of real hang time on a 60-yarder.
9. **Slow-mo** (0.25x for 0.6 s) triggers when the ball crosses the posts or lands short.
   Check that it doesn't cut back to normal speed too abruptly.
10. **Camera follow** (0.35) and **shake** (0.12). Check for motion sickness at full follow.
11. **Ball readability.** The ball is drawn at 2x size, plus the dotted trail and shadow.
    Check whether it's still readable on a small phone at 60 yards.
12. **Not implemented:** ball hitting the uprights or crossbar (it passes through), gusts,
    headwind/tailwind, drag/spin curve, kicker character, haptics, menus.
