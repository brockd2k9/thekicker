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
10. **Camera follow** (0.25) and **shake** (0.05). Check for motion sickness at full follow.
11. **Framing / look.** `camera_fov` 40, ball 2.8x on the tee shrinking to 1.7x downfield,
    camera height/offset in `kick_camera.gd`. Check that the ball doesn't hide the posts on
    60-yarders, and that the ball shrinking in flight doesn't look odd.
12. **Performance on a real phone.** Shaders for the crowd and field, plus one shadowed light.
    If the frame rate drops, turn off `shadow_enabled` on the Sun first.
13. **Kicker's-eye view over the line.** On 50-60 yarders the red line standing up, and the
    jumpers, can cover part of the crossbar at the end of the kick window. Decide whether that
    feels like good pressure or just annoying (raise `home_offset.y` if it's annoying).
14. **Gusts.** 50% of windy kicks, up to +10 mph. Can you read the lulls from the arrow and
    the ribbons? `gust_speed` 0.35 = a gust cycle about every 3 s.
15. **Vibration.** 40 ms on the kick (scaled by power), 120 ms on a block. Phone only.
16. **Holder pose.** The hand position on the ball is approximate. Check it looks right.
17. **Not implemented:** ball hitting the uprights or crossbar (it passes through),
    headwind/tailwind, drag/spin curve, bad snaps / fumbled holds, visible kicker
    leg/foot, menus.
19. **Block variety.** Odds: left edge 35%, right edge 35%, middle 30%. Themes: push 20%,
    hands up 35%, leap 20%, dive 25%. Check the plays feel different, and that the dives
    don't look silly (divers slide about 1 m forward and lie flat).
18. **Snap timing.** 0.4 s snapper to holder + 0.18 s to put it down, then the kick window.
    The rush clock starts at the snap, so the snap uses ~0.6 s of the time before a block.
    Tunables: `snap_travel_time`, `hold_place_time`, `snap_spins`. The snap path and catch
    spot (`snap_spot`/`catch_spot` in `field_builder.gd`) may need nudging to line up with
    the holder's hands.
