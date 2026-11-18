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
7. **Snap timing.** 1.0 s delay, then the kick window: 1.5 s at zero pressure down to 0.9 s
   at max. The rushers' speed is set by the window.
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
18. **Snap timing.** 0.4 s snapper to holder + 0.18 s to put it down, then the kick window.
    The rush clock starts at the snap, so the snap uses ~0.6 s of the time before a block.
    Tunables: `snap_travel_time`, `hold_place_time`, `snap_spins`. The snap path and catch
    spot (`snap_spot`/`catch_spot` in `field_builder.gd`) may need nudging to line up with
    the holder's hands.
19. **Block variety.** Odds: left edge 35%, right edge 35%, middle 30%. Themes: push 20%,
    hands up 35%, leap 20%, dive 25%. Check the plays feel different, and that the dives
    don't look silly (divers slide about 1 m forward and lie flat).
20. **Players.** Jointed figures with helmets, facemasks, pads, numbered jerseys, gloves,
    cleats; they run with a stride and the holder kneels. Uniform colors in `team_kit.gd`.
    Each player is ~35 small meshes (~700 for the field). Watch the frame rate on a phone;
    if it drops, the facemask bars and decals are the first things to cut.
21. **Rush speed and run cycle.** With the shorter window, edge rushers average ~4 m/s at zero
    pressure and ~6 m/s at max. If they still look slow, lower `base_kick_window` (faster rush,
    less time to kick) or move `EDGE_FROM` in `field_builder.gd` farther out. Run cycle:
    `_run_hip`/`_run_knee` in `player_figure.gd`, cadence `STRIDE_LENGTH` (2.6 m per cycle).
22. **Tipped kicks.** Rushed kicks lose up to 16° of loft. With the defaults, kicks in the first
    ~70% of the rush clear every hand; leapers can tip from ~80%; hands-up linemen only in the
    last ~10%, and only softer kicks. If tips feel too common or too rare, change
    `rushed_elevation_drop_deg`, `rushed_from`, or `hand_block_radius` (0.3 m).

# Menus, modes and progression playtest checklist

23. **Challenge ramp.** 25 yd on kick 1, +3 yd per kick to 60 by kick ~12. Calm for 2 kicks,
    then +1.5 mph per kick; gusts from kick 7; pressure maxes on kick 13. Is the first miss
    coming too early or too late? All numbers are in `challenge_rules.gd`.
24. **3-miss rule.** Blocks and tips count as misses. Does that feel fair?
25. **Results screen** appears after the third miss's result has played out (not instantly).
    Check Play Again and Main Menu, and that "NEW BEST!" only shows on a real best.
26. **Pause** (II, top center): it must never fire a kick, even if you swipe through it.
    Also check Android back: pause in a kick, back to the menu elsewhere, quit from the main menu.
27. **Stats persist.** Kick a few, force-close the app, reopen: all-time numbers and
    streaks should survive; Session Accuracy should start at 0.
28. **Streaks carry across sessions and modes** (a Practice make + a Challenge make = 2 in a row).
    Decide if that's what you want.
29. **Achievement toasts.** Several can unlock on one kick (they queue). Check they don't
    hide anything important during the slow-mo result.
30. **Windy Day** uses the wind at the moment of the kick, gusts included. A gusty
    "8-15 MPH" kick taken in a lull won't count.
31. **Reset Stats** clears stats and best run but keeps achievements and settings. Confirm
    that's the behavior you want.
32. **Aim Assist off** hides the aim ring only. Does the game still feel readable without it?
33. **Volume sliders** work once real sounds/music are in `audio/` (`music.ogg` loops on the Music bus).
34. **Touch targets.** Buttons are 96 px in the 720-wide layout. Check on the smallest phone you have.


# Career Mode tuning notes

All numbers below are in `tuning/career_tuning.tres` unless a data file is named.
Rerun `tools/career_sim.tscn` after changing any of them and compare with
`tools/career_sim_baseline.md`.

## Decisions on record
- **High school is 4 seasons** (`high_school_seasons`, start age 14). The original Career Mode
  spec said 3; changed to 4 at the owner's later instruction. Tunable.
- **Kickoffs, onside kicks and the sideline warmup net use a 2D swipe pad**, not the 3D kick
  scene (which is built around field goals). Same swipe -> power/aim math and the same kick
  profile. Fine for now; a 3D kickoff scene could come later.
- **Warmup once per half**, the first time the offense drives into range; its result
  (Warmed Up / Loose / Cold Leg) lasts until halftime.
- **Weekly life drift**: every week each life stat moves `weekly_life_drift` (10%) back toward
  `start_life`, so streaks don't pin life stats at 0 or 100. 0 = off.
- **Personality axes**: Charisma <-> Intelligence and Ambition <-> Leadership. In the scenario
  data, a choice that raises one usually costs a little of its opposite, so random play mostly
  cancels out and consistent play climbs. Single-stat traits reward leaning one way; each
  combo trait pairs one stat from each axis.
- **Bye-week and offseason choices' game-day modifiers carry into the next game.**

- **Stage 5 progression**: recruiting score (season performance + scenario "recruiting" values +
  traits) and GPA decide college offers (top / mid-major / small; full, partial or preferred
  walk-on). No offers: walk-on tryout or junior college. College builds a draft score (times the
  school's exposure); undrafted -> camp invite or open tryouts. Pro: standing (retention) each
  season decides re-sign / release; Retire after any pro season; age cap 38. Three poor marks in a
  row (poor seasons, releases, failed tryouts) with nothing on the table end the career.
- **Life stats** drift toward `life_baseline` (60), Fun/Social gains are scaled by
  `fun_social_gain_mult` (0.7), and the low-stat penalties start at 40.

## Trait balance (targets and current result)
Target: a player leaning into one personality direction unlocks 1-2 traits by the end of high
school and 3-4 by the end of college; random/mixed players unlock fewer.
Current (Stage 5 baseline, 40 careers per strategy): every leaning strategy 3.0-4.2 by the end
of college (ambition and intelligence leaners now 100% reach 3); random 0.0 -> 2.0, mixed 0.8 -> 2.5.
Stage 6: leadership leaners 1.1 by the end of high school (3% have none, was 28%), charisma leaners 2.1 (was 2.4).
Knobs: `personality_change_scale` (0.30), trait thresholds in `data/career/traits.json`,
personality numbers in the scenario files.

## To playtest (final list)
Most important first. Simulator numbers are from `tools/career_sim_baseline.md`; the sim's kicks
are a stand-in for real swipes, so everything involving kicking quality needs a real-phone check.

**Kick difficulty (career_tuning.tres "Power", "Accuracy", "Resilience", "Toughness", "Profile Caps")**
1. Power curve 0.82 -> 1.08: a power-30 freshman needs ~83% swipe power for 50 yd. Too punishing?
2. Aim error 2.2 deg -> 0.2 deg and wobble 1.35 -> 0.75 by Accuracy. Does a 30-accuracy freshman
   feel shaky but playable?
3. Low-stat penalties start at 40 (`low_*_threshold`); Energy is the one that bites most.

**Progression (career_tuning.tres "Recruiting", "Draft", "Pro Contracts"; progression.json)**
4. Recruiting: tier minimums 78 / 58 / 42, walk-on margin -8, GPA minimums 2.8 / 2.5 / 2.2.
   Sim: 5-35% of weak recruits get no offer; fallbacks (walk-on 6%, junior college 1%) are rare.
5. Tryouts (progression.json): walk-on 3 of 5 at 28-44 yd, camp 3 of 5 at 36-52, free agent
   4 of 5 at 40-55. With real swipes these decide how often the fallback routes succeed.
6. Draft: rounds at 90 / 84 / 78 / 72 / 66, camp invite from 52. Sim: 20% drafted, 62% reach pro.
7. Pro standing: release below 35, re-sign from 50, -5 per year past 32; 4.9 pro seasons on
   average, 8% reach the age cap of 38. `free_agent_attempts` 2.
8. Career end: `career_end_poor_streak` 3, `poor_fg_pct` 60%.

**Stats over a career**
9. Personality: `personality_change_scale` 0.30; thresholds 56-60 single, 55-60 combo. Leaning
   players get 1-2 traits by the end of high school and 3-4 by the end of college; random 0 -> 2.
10. Life (weekly averages): Health 64-70, Energy 48-68, Fun 49-73, Social 61-84. Low-stat weeks
    3-25% by style. Knobs: `life_baseline` 60, `fun_social_gain_mult` 0.7, `weekly_energy_recovery`
    10, `game_energy_cost` -12, `weekly_life_drift` 0.1.
11. Accuracy at the end of college 68-93: `make_accuracy_gain` 0.06, `weekly_football_growth` 0.1,
    `offseason_football_growth` 1.5, `football_diminishing` 0.85.
12. GPA: intelligence-heavy players reach 4.0, others 2.6-3.4 (`gpa_intelligence_drift` 0.12);
    college ineligibility below 2.0.

**Game day**
13. Game sim: ~1.6 FG + 2 XP + 4 kickoffs per game (`drives_per_half` 4, `base_td_chance`).
14. Sideline pad: kickoff carry 75 yd at full power (touchback needs a strong straight flick);
    warmup net window `net_power_min/max` 0.5-0.92, `net_aim_deg` 6; onside window 10-18 yd.
15. Pressure: quarter ramp 0.1-0.45, close game +0.25, game winner 1.0; college +0.05 (+ tier),
    pro +0.12. Game-winning kicks are rare (close game, final 2 minutes).
16. Goalpost widths: high school 7.11 m, college 5.64 m, pro 5.3 m.

**Pacing**
17. Scenario repetition: `max_scenario_repeats_per_season` 2, `category_repeat_decay` 0.5,
    1-2 scenarios per week (`second_scenario_chance` 0.4), 2 in bye weeks and offseasons.

## Known gaps
- No full signed Android build yet: a pack-only export was verified (all data included, boots and
  runs Career Mode screens). Build the .apk on your own machine (README → Export for Android).
- Cleanup: the personal cloud environment **thekicker** (allows `dl.google.com`) was created for an
  SDK download that was dropped. Nothing depends on it; delete it in claude.ai if unneeded.
- Kickoffs, onside kicks and the warmup net are on a 2D pad, not the 3D scene.
- The simulator's kick model is a stand-in; fallback-route frequency and pro career length need
  real-play checks.
- Game-winning kicks (and the Walk-Off achievement) are rare by design of the game sim.
- Junior college counts as one season; there is no redshirt, no playoffs, no injuries that skip
  games (injuries only make you play hurt), and pro free agency is tryout-only (no bidding).
- Placeholder art throughout; no sound files (the Sfx hooks print in debug builds).
