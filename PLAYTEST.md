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
- **Kickoffs and onside kicks are in the 3D kick scene** (kickoff / onside formation, ball on a
  tee, stage posts at the far end). They keep the old sideline carry curve so career balance
  doesn't move, are judged where the ball lands (out of bounds now from the landing point, wind
  included, instead of "aim beyond 12°"), and don't count in the field-goal stats.
- **The sideline warmup is in the 3D scene too**: tee on the sideline grass by the bench, a
  kicking net 6.5 m ahead, the field-goal camera, no wind. Same rules as the old pad (3 strikes,
  2 pure = Warmed Up). The field is empty during the warmup (kept light on purpose).
- **Kickoff spots**: high school from the 40, college and pro from the 35 (was the 40 for all
  stages, so college/pro touchbacks need 5 more yards). Touchback 20 / 25 / 30, out of bounds
  35 / 35 / 40. Conventional kickoff alignment at every level.
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

## Skill points, range and kick trust (Step 2)

Built: skill points (earned on the field and in practice, spent on the Skills screen), field goal
range and kickoff range from Power (a full flick reaches your range and no further), game-day range
from life stats, the coach's longest call from your range, Team standing, Coach / Team changes from
every kick, and coach doubt after too many misses. Numbers: `career_tuning.tres` groups "Power ->
Range", "Game Day Range", "Skill Points", "Relationships". Save version 4.

**Simulator check (careers=6, seed=1, balanced spending; full report in Step 4):** the economy is
richer than planned. Skill points per season: HS 46-68, college 53-70, pro 61-77 (planned ~45 /
60 / 70). Attribute points bought by the end of HS: 64-84 (all four summed), plus 13-48 more
directly from scenario choices. FG range at the end of HS 53-58 (target 48-50) and of college
59-65 (target 52-55). More careers reach the pros (85%, baseline 68%) and the draft (69%, baseline
25%). Step 4 levers: skill point income (`sp_*`), the cost curve (`upgrade_cost_*`), the range
curve (`range_curve`, `range_at_100`), `scenario_football_scale`, and the draft / recruiting
range terms.

**One-time pass: `skill_points` added to the scenarios already in the game** (choices that already
gave football gains; +1 to +3, training +2 to +4; the template files were not touched):

| File | Scenario | Category | skill_points per choice | Existing football changes per choice |
|---|---|---|---|---|
| hs | `hs_exam_vs_film` Exam or Film? | school | - / 1 / - / - | - / toughness +1 / - / - |
| hs | `hs_extra_practice` Coach Wants Extra Reps | training | 4 / 2 / - | accuracy +3 / accuracy +1 / - |
| hs | `hs_tweaked_hamstring` Tight Hamstring | health | - / 2 / - | - / toughness +2 / - |
| hs | `hs_viral_followup` The Comments Section | media | 2 / - / 1 | resilience +2 / - / resilience +1 |
| hs | `hs_kicker_battle` Kicker Battle | training | 4 / - / - | power +2, accuracy +1 / - / - |
| hs | `hs_family_dinner` Grandparents in Town | family | - / - / 1 | - / - / accuracy +1 |
| hs | `hs_scholarship_camp` Scholarship Camp | career | 3 / 3 / - | power +2, accuracy +2 / accuracy +3 / - |
| hs | `hs_recruiting_visit` A Coach in the Stands | career | 1 / 1 / - | power +1 / accuracy +1 / - |
| hs | `hs_showcase` Regional Showcase | career | 2 / - / - | power +1, accuracy +1 / - / - |
| college | `col_class_load` Heavy Class Load | school | - / 3 / - | - / accuracy +2, power +1 / - |
| college | `col_media_day` Media Day | media | - / - / 1 / - | - / - / accuracy +1 / - |
| college | `col_new_technique` New Coordinator, New Technique | training | 4 / 2 / 2 | accuracy +3, power -1 / power +1 / accuracy +1 |
| college | `col_internship` Internship or Training? | career | - / 3 / 1 | power -1 / power +3, accuracy +2 / accuracy +1 |
| college | `col_pro_scouts` Scouts at Practice | career | 2 / 2 / - | power +2 / accuracy +2 / - |
| college | `col_walkon_battle` Earn Your Spot | training | 3 / - / - | power +1, accuracy +1 / - / - |
| college | `col_combine_invite` Combine Invite | career | 2 / - / 1 | power +2 / - / resilience +1 |
| pro | `pro_contract_talks` Contract Talks | money | - / - / 1 / - | - / - / resilience +1 / - |
| pro | `pro_media_interview` Postgame Questions | media | 1 / - / - / 2 | resilience +1 / - / - / resilience +2 |
| pro | `pro_holder_chemistry` Holder Chemistry | training | 4 / - / 2 | accuracy +3 / - / toughness +1 |
| pro | `pro_cold_snap` Cold Snap | health | 3 / 1 / 1 | toughness +3 / accuracy +1 / toughness +1 |
| pro | `pro_trade_rumors` Trade Rumors | career | 1 / - / - | resilience +1 / - / - |
| shared | `bye_weekend` Bye Week | health | - / 3 / - | - / power +2, accuracy +2 / - |
| shared | `offseason_focus` Offseason Training | training | 4 / 4 / 4 / 4 | power +5 / accuracy +5 / resilience +5 / toughness +5 |
| traits | `trait_community_service` Community Service Day | community | 1 / - / - | toughness +1 / - / - |
| traits | `trait_youth_camp` Youth Kicking Camp | community | 1 / - / - | accuracy +1 / - / - |
| traits | `trait_charity_event` Charity Kick-a-Thon | community | 1 / - / - | power +1 / - / - |
| traits | `trait_mentoring` Mentoring a Younger Kicker | team | 1 / - / - | accuracy +1 / - / - |
| traits | `trait_film_room` Coaches' Film Room | training | 2 / - / - | toughness +1 / - / - |
| traits | `trait_private_coach` Private Kicking Coach | training | 4 / 3 / - | accuracy +2, power +1 / resilience +2 / - |

## Pacing cut, perks, aging and weather (Step 3)

**Quick pacing cut (before Step 4):** `scenario_football_scale` 1.0 -> 0.5; skill point income
trimmed: weekly practice 2 -> 1 (tired 1 -> 0), offseason 10 -> 6, perfect game 2 -> 1, good /
great season 8 / 12 -> 6 / 9. Per-kick points unchanged; cost and range curves unchanged.
Simulator (20 careers per strategy, seed 1, balanced spender that preserves from 30):

| | Target | Step 2 | After the cut |
|---|---|---|---|
| FG range, end of HS | 48-50 | 53-58 | 51-55 |
| FG range, end of college | 52-55 | 59-65 | 56-61 |
| Skill points per HS season | ~45 | 46-68 | 37-57 |
| Careers reaching the pros | ~68% | 85% | 68% |
| Careers drafted | (25% before) | 69% | 43% |

Still 1-6 yd long: Step 4.

**Perks** (`data/career/perks.json`, 15): Ice in the Veins, Short Memory, Clutch, Wind Reader,
Film Junkie, Big Leg, Cannon, Laser, Smooth Swing, Hang Time, Onside Specialist, Cold Weather
Kicker, Quick Recovery, Captain's Calm, Iron Leg; costs and effects as approved in the Step 1
proposal. **Aging** (`career_tuning.tres` "Aging"): decline (1.0 + 0.5 x (age - 30)) x rate
(Power, Toughness 1.0; Accuracy 0.6; Resilience 0.3) at each season end; preserving costs
decline x next-point cost x 0.6. **Weather** ("Weather"): from 60% of the season, 25% cold,
10% snow.

To playtest: do perk costs feel worth it; is maintenance affordable but not free in the early 30s;
how often do cold and snow games show up.

## Simulator report and retune (Step 4)

Simulator: `tools/career_sim.tscn` (spending styles, slumps by kicker quality, skill point
economy, aging, perk usage, a wind model, and an aging probe), baseline `tools/career_sim_baseline.md`.
Two retunes were combined on main: the scenario session's (generated field goal maximums back to
48 / 55 / 58, Cannon 60 SP at Power 95, range terms in recruiting / draft / retention halved, warmup
skill points capped per season) and this one.

**Values changed (this session):**

| Setting | Before | After | Why |
|---|---|---|---|
| `range_curve` | 0.75 | 1.0 | Linear: less range from cheap early Power points |
| `upgrade_cost_base` / `_scale` / `_exp` | 1 / 9 / 2 | 1 / 14 / 3 | Points 30 -> 2 SP, 50 -> 3, 70 -> 6, 90 -> 12, 99 -> 15 (was 2/4/6/9/10): the top is dear |
| `kick_window` / `kick_window_misses` | 6 / 4 (main) | 10 / 6 | Slumps rare for good kickers, common for poor ones |
| `kick_season_pct` / `kick_season_min_att` | 55% / 8 (main) | 50% / 12 | The season rule fired on small samples |
| `doubt_clear_misses` | 1 | 2 | Same idea for the longer window |
| `draft_leg_from` (new; was fixed 55) | 55 | 50 | Draft scoring recalibrated to the new attribute levels |
| `draft_range_from` | 52 | 50 | Same |
| `draft_base` | 2.5 | 9.5 | Draft scores averaged 29 (camp invite 52, rounds 66+) |
| Tryout distances (`progression.json`) | walk-on 28-44, camp 36-52, free agent 40-55 | 25-41, 32-48, 34-50 | Old distances were past a typical college range |
| `aging_base` / `aging_per_year` | 1.0 / 0.5 | 1.5 / 1.0 | Power -1.5 at 30, -4.5 at 33, -7.5 at 36 (was 1.0 / 2.5 / 4.0) |
| `maintain_cost_mult` | 0.6 | 0.4 | Preserving clearly cheaper than buying lost points back |

**Targets** (main's simulator, 20 careers per choice strategy, seed 1; all careers):

| | Target | Main before this session's retune | After |
|---|---|---|---|
| Careers reaching the pros | 60-70% | 44% (with only the ported values) | 67% |
| Careers drafted | 25-35% | 2% (same) | 33% |
| FG range, end of HS | 48-50 | 47.2 | 48.7 (balanced style 47.8) |
| FG range, end of college | 52-55 | 52.4 | 54.2 (balanced style 52.9) |
| Careers reaching 70 yd | under 2% | 0% | 0% |

**Aging: preserving vs not** (aging probe: the same pro from 30, Power 85 / Accuracy 85, the run's
average pro income of ~51 skill points a season; the non-preserving pro spends it all on buying
points back):

| Age | Range gap before | Range gap after |
|---|---|---|
| 32 | +0.2 yd | +0.9 yd |
| 34 | +0.7 yd | +2.4 yd |
| 36 | +1.7 yd | +5.0 yd |
| 37 | +1.9 yd | +6.7 yd |

The preserving pro holds 61.5 yd through 37 but starts losing Accuracy at 36 (88 -> 84 -> 79):
careful play holds the mid-30s, not forever. In simulated careers past 30, players who preserve
lose 1.8 Power a season, those who don't lose 4.1.

## Benching

Rules: `scripts/career/bench.gd`; numbers: `career_tuning.tres` "Benching"; save version 5.

- **On thin ice (the warning):** at the start of a week, the coach doubts you (a slump) or a bad
  stretch is still fresh, and trust (0.7 x Coach + 0.3 x Team) is 40 or less. The Hub and the Game
  Day Outlook show a big ON THIN ICE banner with the reason and exactly what gets you benched.
- **Benched:** only at the end of a week that started on thin ice, if you missed 2 field goals in
  that game (1 when this season is under 50% after 8+ attempts) and trust is 35 or less. Never in
  weeks 1-2, one bench a season, 1 week (2 at trust 25 or less).
- **While benched:** the backup (Tyler Brooks when he's your teammate, otherwise the stage's backup
  kicker, `people.json` "backup") kicks your field goals; you keep extra points and kickoffs. No game
  skill points (practice and choices still count). -1.5 progress score per benched week, Team -2
  (-1 if Tyler is the backup and a friend), Fun -4 (-6 if Tyler is a rival).
- **Audition:** 3 of 5 from 30-40 yd (high school) or 35-45 yd, clamped to range - 1. Pass: the job
  back, Coach +5, Team +3, coach doubt cleared, half the progress back. Fail: one more week, then
  another audition; a second fail reinstates you anyway.
- **Flags for scenario writers:** `benched`, `benched_for_tyler`, `won_job_back`, `lost_audition`.

**Tuning (fixed kicker quality, simulator `make=P`, 90 careers each):**

| Kicker quality | Target | First try (1 miss, trust 40/35) | Final |
|---|---|---|---|
| 60% | over 60% benched at least once | 86% | 63% |
| 70% | 15-35% | 78% | 36% |
| 75% | 15-35% | 31% | 24% |
| 80% | under 5% | 18% | 4% |
| 85% | under 5% | 2% | 1% |

Values changed while tuning: `bench_week_misses` 2 (new; was 1), `bench_poor_season_pct` 0.5 and
`bench_poor_season_min_att` 8 (new: the one-miss route in a bad season); `bench_warn_trust` /
`bench_trust` stay 40 / 35.

**A bench doesn't end careers** (same qualities, benching off -> on): reaching the pros 42 -> 36%
(60%), 70 -> 81% (70%), 92 -> 96% (75%), 98 -> 100% (80%); pro seasons 1.1 -> 1.1, 5.2 -> 6.5,
11.1 -> 11.3, 14.3 -> 15.1 (differences within run-to-run noise). Auditions pass about 85-90%.

**Targets still hold** (normal kick model, 20 careers per choice strategy): pros 67% -> 69%, drafted
33% -> 32%, FG range end of HS 48.7 -> 48.9, end of college 54.2 -> 54.1, 70 yd 0% -> 0%.

To playtest: does the thin-ice warning read clearly enough; is two misses the right "bad week";
does the audition feel fair at your range.


## Followers

Rules: `scripts/career/followers.gd`; numbers: `career_tuning.tres` "Followers"; save version 7.

Players only see real follower counts ("+120 followers", "2.4K followers", "Hometown Hero").
Internally each event is worth some **buzz**, and the stage turns buzz into followers: 15 a buzz in
high school, 60 at junior college, 200 at college, 750 as a free agent, 1,500 in the pros. Gains get
up to +20% from Charisma. Followers never go below 0.

| Event | Buzz | Event | Buzz |
|---|---|---|---|
| Field goal made | +1 | Missed game-winning kick | -6 |
| Long make (45+ or near your range) | +2 | Benched (when it starts) | -8 |
| Clutch make | +2 | Each benched week | -2 |
| Game winner | +8 | Choice `conduct: "bad"` | -4 |
| Perfect game (2+ kicks) | +3 | Choice `conduct: "scandal"` (also ends deals) | -15 |
| Good / great season (FG% 80 / 90) | +10 / +20 | | |
| Won the job back (audition) | +5 | | |
| Choice `conduct: "good"` | +3 | | |
| Choice `followers: n` | n | Choice `followers_exact: n` | n followers (not scaled) |

- **Viral moments:** a made game winner (25%) or a 55+ yard make (20%) can go viral: that kick's
  buzz x4, with a VIRAL notice on the Hub. A missed game winner becomes a viral blooper 6% of the
  time (its loss x2). At most one viral moment a game.
- **Tiers:** Local Name 0, Hometown Hero 500, Rising Star 5K, Campus Celebrity 25K, Verified 100K,
  Fan Favorite 500K, Household Name 2M. Scenarios: `requires.followers_tier` (this tier or higher),
  `requires.max_followers_tier` (this tier or lower), `min/max.followers` (a count).
- **What followers give (small and capped):** the first time at a tier, +2 skill points (gear
  sponsors) and Team +1; a week with 12+ buzz gained (a game winner, a viral moment): Fun +1, Social
  +1 (8+ lost: Fun -2); at the end of a pro season, standing +0.5 per tier above Hometown Hero (at
  most +1; the recruiting / draft bonus is off, see below); new pro
  contracts +2% salary per tier (at most +10%); "Fans are watching": +0.015 pressure per tier above
  Rising Star in a close 4th quarter (at most +0.06, shown on the Outlook). Followers' skill points
  (tiers and deals) are capped at 5 a season.
- **Brand deals** (a choice's `deal`): +1 skill point a week, +0.5-1 yd range, or +1-2 Fun a week;
  each costs 1 Energy a week; at most 2; they end at season end (after `seasons`), at a new stage, or
  with a scandal.
- **Old saves** start with: high school 100 + 150 per season played, junior college 1,000, college
  2,500 + 4,000 per season, pros 30,000 + 40,000 per pro season (no milestone rewards for that).

**Simulator (stage 3; 360 careers, seed 11, `tools/career_sim_baseline.md`).** Field only: no
scenario choice has follower tags yet, so these come from kicks, seasons, viral moments, benching and
the audition. "+1 tag" adds 1 buzz to every choice taken, an estimate of the story session's tags.
Median (p10-p90):

| | End of high school | End of college | Pro season 3 | Pro season 6 | Pro season 10 |
|---|---|---|---|---|---|
| Target | 2-5K | 30-100K | | 300K-2M+ | 300K-2M+ |
| Field only (now) | 2,055 (1,440-2,579) | 26.3K (19.8K-34.8K) | 163K | 359K (275K-545K) | 599K |
| +1 tag (estimate) | 3,116 (2,554-3,704) | 39.3K (32.5K-46.9K) | 259K | 533K (432K-782K) | 898K |
| +2 tags (estimate) | 4,155 | 52.4K | 350K | 735K | 1.1M |

Field-only college (26K) is under the 30K target **only because no choices carry followers yet**;
with tags at about +1 a choice it sits mid-target.

**After merging the college story graph** (main, later the same day: 150 college scenes, 115 of them
with followers / conduct tags; high school has no tags yet). 360 careers, seeds 11 and 12:

| | End of HS | End of college | Pro season 3 | Pro season 6 | Pro season 10 | Pro / drafted |
|---|---|---|---|---|---|---|
| Followers on | 1,940 | 29.5K (17.5K-37.2K) | 167K | 360K | 590K | 74.5% / 45.5% |
| Followers off | 1,960 | 29.1K | 175K | 376K | 614K | 76.5% / 43.5% |

College now sits at the bottom of the 30-100K target with its own tags (some are bad conduct, so
they net out small); high school stays low (about 2K) **only because the high school scenarios
have no tags yet**. Effects on vs off: pro -2, drafted +2 (within the 3-point limit). Challenge pass
chances are unchanged. `tools/career_sim_baseline.md` is this run (seed 11). Household Name (2M) comes from long careers and
virals: kickers at 90% reach 1.7M at their peak (median), 2M+ at the top.

By kicker quality (simulator `make=P`, field only; 180 careers each):

| Make chance | End of HS | End of college | Pro season 6 | Peak | Viral moments / career |
|---|---|---|---|---|---|
| 60% | 848 | 13.7K | 245K | 17.3K | 0.1 |
| 70% | 1,440 | 21.5K | 375K | 286K | 0.4 |
| 80% | 2,132 | 33.4K | 467K | 1.2M | 1.0 |
| 90% | 3,064 | 49.3K | 636K | 1.7M | 1.3 |

By spending style the medians differ by under 10% (end of college 25.3K-26.9K).

Tiers (share of careers at or above the tier at the end of a season; how often a scenario gated at
that tier can appear): Hometown Hero 38% after HS season 1, 97% after season 2; Rising Star 0% in
high school, 90% after college season 1; Campus Celebrity 16% after college season 3, 59% after
season 4, 99% after pro season 1; Verified 68% after pro season 2, 96% after season 3; Fan Favorite
16% after pro season 5, 42% after season 8, all who reach season 10; Household Name 0% field only
(it needs tags or virals). So: high school scenarios gated above Hometown Hero won't appear until
tags exist; college Campus Celebrity scenarios fit seasons 3-4.

**Effects on vs off** (`fans=0`; the per-run noise is about +/-3 points, so these pool several seeds):

| Setting (followers on unless noted) | Careers | Pro | Drafted | vs off |
|---|---|---|---|---|
| Followers off (seeds 11-14) | 1,440 | 74.5% | 43.5% | |
| Bonus +0.5 / tier cap 1, weekly Fun at 5 buzz (seeds 1-4, off: 76.5 / 43.5) | 720 | 79.8% | 50.0% | +3.3 / +6.5 |
| Bonus cap 0.5, weekly Fun at 12 buzz (seeds 11-14) | 1,440 | 79.0% | 47.3% | +4.5 / +3.8 |
| **No recruiting / draft bonus, weekly Fun at 12 buzz: final** (seeds 11-14) | 1,440 | 75.0% | 45.0% | **+0.5 / +1.5** |

Turning off one effect at a time (seed 11) showed the recruiting / draft bonus is the whole
difference; tier skill points, Team and the weekly Fun / Social barely move it. Even +0.5 recruiting / draft a season moved the draft rate 4-5 points (draft stock sits near the
cut-off for many kickers), so that bonus is off before the pros; the pro standing bonus stays
(+0.5 a tier, at most +1) because it doesn't change who reaches the pros.

**Not from followers:** even with followers off, the game now reaches the pros about 75% of the time
and the draft about 44% (the benching stage measured 69% / 32%). The simulator at the commit before
PR #11 shows the same (72% / 42%), so it came with content imported since (the story graph
batches add recruiting and skill points). Worth a separate retune of the pro / draft targets.

**Values changed (Followers):**

| Value | Before | After | Why |
|---|---|---|---|
| `followers_per_buzz_hs` | 10 | 15 | end of HS 1.3K -> 2.1K field only (3.1K with tags) |
| `followers_per_buzz_juco` | 40 | 60 | in step with high school / college |
| `followers_per_buzz_college` | 120 | 200 | end of college 15K -> 26K field only (39K with tags) |
| `followers_per_buzz_free_agent` | 600 | 750 | half the pro rate |
| `followers_per_buzz_pro` | 1,200 | 1,500 | pro season 6: 280K -> 360K field only (530K with tags) |
| `buzz_week_good` / `buzz_week_bad` | 5 / -5 | 12 / -8 | ordinary games were reaching 5 nearly every week: now only a big week |
| `followers_progress_per_tier` | 1.0 | 0.5 | |
| `followers_progress_cap` | 3.0 | 0.0 | the draft rate (see above) |
| `followers_standing_cap` (new) | - | 1.0 | pros only |

## Kick challenge tuning

The simulator plays each proposed conversion (`tests/fixtures/kick_challenge_conversions.json`) for
every kicker it meets at that point in a career, copied at 60/70/80/90% expected field goals
(Accuracy and Resilience set; same age, Power, range and stage). The make model is the simulator's
stand-in for real swipes; kickoffs carry 80-100% of the kickoff range; fitness also costs aim (an
estimate). 60% kickers can't be built in high school (the model's floor is higher) and 90% rarely.

| Challenge | Before (stage 2 proposal) | After | 70% kicker before -> after | 80% before -> after | 75%: tired / heavy legs / injured |
|---|---|---|---|---|---|
| hs_showcase | 30-45, need 3, medium | 25-36, need 3, medium | 60% -> 85% | 83% -> 95% | 87 / 89 / 87% (normal 90%) |
| hs_scholarship_camp (big) | 35-50, need 3, high | 26-39, need 3, medium | 40% -> 81% | 72% -> 93% | 84 / 86 / 84% (87%) |
| hs_scholarship_camp (regional) | 28-38, need 2 of 4, low | 25-34, need 2 of 4, low | 92% -> 96% | 98% -> 99% | 97% |
| HS_040 (always heavy legs) | 30-43, need 3, medium | 25-35, need 3, medium | 64% -> 85%* | 85% -> 95%* | 87 / 89 / 87% |
| HS_121 | 33-47, need 3, medium | 25-38, need 3, medium | 56% -> 83% | 81% -> 94% | 86 / 88 / 86% (89%) |
| HS_016 | 25-34, need 2 of 4, low | 22-31, need 2 of 4, low | 95% -> 98% | 98% -> 99% | 98% |
| hs_kicker_battle | 30-45, need 3, medium | 24-36, need 3, medium | 59% -> 85% | 82% -> 95% | 87 / 89 / 87% (90%) |
| col_walkon_battle | 35-47, need 3, high | 28-41, need 3, medium | 63% -> 82% | 86% -> 94% | 85 / 87 / 85% (88%) |
| col_combine_invite | 38-52 + 2 kickoffs 65+, need 4 of 7, high | 33-46 + 2 kickoffs 58+, need 4 of 7, medium | 45% -> 82% | 68% -> 93% | 82 / 82 / 81% (88%) |

\* HS_040 applies heavy legs when chosen, so its "heavy legs" column is the real number (89%).

Targets: average kicker (70-80%) at least 80% on every challenge: met (the 70% kicker 81-98%).
Weak kickers (60%, college only) 68%, above the 50% floor. Tired / injured: 2-7 points lower.
**Strong kickers: 93-99% at 80%, 98-100% at 90%.** The 80% kicker reaching 98% everywhere would
need distances short enough that the 70% kicker passes 92%+, which makes the challenges close to
automatic; I kept a little risk instead. Exact edits for the story session:
`docs/kick_challenge_tuning_edits.json` (also: two pass results that named a distance).

## Kick challenges

Rules: `scripts/career/kick_challenge.gd`, `scripts/career/tryout_mode.gd`; numbers:
`career_tuning.tres` "Kick Challenges". Format for writers:
`docs/story_handoff_followers_challenges.md`.

- A scenario choice with a `kick_challenge` block is played as real kicks: picking it applies the
  choice's own fields (costs, story flags, modifiers that affect the kicks), then the kick scene runs
  the field goals (clamped to range - 1) and, for combines, kickoffs. `need` counts both.
- Pass: `on_pass` (plus the kind's default followers if it has none). Fail: `on_fail` (milder).
  Every kick made: +1 skill point (source "Challenge") and a few followers. No game skill points,
  no season stats, no Coach / Team change unless the block says so.
- Afterwards the week (or offseason) continues where it was.
- **Resume after a reload** (challenges, the bench audition and stage tryouts): every kick is saved
  as it resolves; reopening continues at the next kick with the same seeded wind; a kick that was
  struck but not resolved when the game quit counts as a miss. (Before, the audition and tryouts
  restarted from kick 1, so quitting could retry a bad run.)
- Proposed conversions (for the story session to apply):
  `tests/fixtures/kick_challenge_conversions.json`. The engine tests play each one's pass and fail.

To playtest: does picking a challenge feel like a real choice (risk vs. the safe option); are the
distances fair at each stage; is the result screen clear about what you got.

## To playtest (final list)
Most important first. Simulator numbers are from `tools/career_sim_baseline.md`; the sim's kicks
are a stand-in for real swipes, so everything involving kicking quality needs a real-phone check.

**Kick difficulty (career_tuning.tres "Power", "Accuracy", "Resilience", "Toughness", "Profile Caps")**
1. Field goal range 40 yd (new freshman) -> 66 yd (Power 100), a full flick reaching exactly your
   range (Step 2). Does a 40-yd freshman feel right, and is a full-range kick reachable with a real
   flick (the swipe needs 100% power)? Kickoff range 52 -> 75 yd.
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
11. Football attributes grow only through skill points (Skills screen) and scenario choices; the
    automatic weekly, per-game and offseason growth settings are gone.
12. GPA: intelligence-heavy players reach 4.0, others 2.6-3.4 (`gpa_intelligence_drift` 0.12);
    college ineligibility below 2.0.

**Game day**
13. Game sim: ~1.6 FG + 2 XP + 4 kickoffs per game (`drives_per_half` 4, `base_td_chance`).
13a. Warmup net: launch angle `warmup_elevation_deg` 22, tee `warmup_sideline_x` 29 m from the
    middle of the field (sideline at 24.4 m), `warmup_next_delay` 0.5 s between strikes. Check the
    feedback reads well: PURE! / PUSHED IT / PULLED IT / SOFT CONTACT / OVER-SWUNG.
14. Kickoff carry 75 yd at full power (from the 35 a touchback needs ~87% power with Power
    stat neutral); onside window 10-18 yd; warmup net window `net_power_min/max` 0.5-0.92,
    `net_aim_deg` 6.
14a. 3D kickoff: **out of bounds is much rarer than the old 12° rule**: with `max_aim_deg` 20 a calm
    kickoff can't quite reach the sideline; it takes a strong crosswind with the aim. If kickoffs
    should go out more often, raise `max_aim_deg` (affects field goals too) or say so and we add a
    kickoff-only aim scale.
14b. 3D kickoff feel: camera `kickoff_camera_offset` (0, 3.6, 6.5), `kickoff_camera_fov` 56 (field
    goals: 2.4 m back, fov 46): the ball is smaller on the tee than in a field goal. Launch angle
    45° (kickoff) / 14° (onside), coverage speed 7.5 m/s, returns 15-30 yards.
15. Pressure: quarter ramp 0.1-0.45, close game +0.25, game winner 1.0; college +0.05 (+ tier),
    pro +0.12. Game-winning kicks are rare (close game, final 2 minutes).
16. Goalpost widths: high school 7.11 m, college 5.64 m, pro 5.3 m.

**Pacing**
17. Scenario repetition: `max_scenario_repeats_per_season` 2, `category_repeat_decay` 0.5,
    1-2 scenarios per week (`second_scenario_chance` 0.4), 2 in bye weeks and offseasons.

**Relationships and story timing** (high school scenarios now move all eight cast relationships; Team
standing and the backup kicker move only through play; these need real-play checks; values in `career_tuning.tres` "Relationships" and "Scenario Picks")
18. Effects at 100 (half that at 75, reversed at 0): coach -0.12 pressure sensitivity and 5% longer
    tries, holder -0.25 deg aim spread, Dad / brother +1.5 energy a week each, best friend /
    someone special +1 fun and +1 social a week each, teacher +0.08 GPA a season. Tyler: friend
    -0.06 pressure sensitivity; rival +0.08 football growth a week; facing his team 0.06 pressure.
19. Values drift 2% a week back toward 50: is a relationship you built still felt a season later?
20. Recruiting: coach 70+ recommends (+6 points), 25 or below costs 4; teacher 70+ eases college
    GPA minimums by 0.1.
21. Story scenarios: x4 weight while their window is open, forced in its last week; at most 2
    forced scenarios a week.

## College story runs (verify in the game)
The college story graph is `data/career/scenarios_college.json` (COL_*, all 154 written).
**Guaranteed** scenes are story events (x4 weight while their window is open, forced in the window's
last week if the player qualifies and hasn't seen it) and beats. Everything else is a weighted random
pick (1-2 a week, 2 in byes and offseasons) once its requirements are met. A missing random scene is
not a bug by itself. A scene that shows up when its requirements are *not* met is. Note each choice
you make, because the next steps depend on it.

**Run 1: clean player** (never pick a choice with bad conduct; say no at every party)
- Year 1: COL_001 Move-In Day (week 1), COL_011 Freshman Traditions (weeks 1-3). Walk-ons also get
  col_walkon_battle Earn Your Spot (week 1).
- Year 2 offseason: COL_066 The Head Coach Is Fired.
- Year 3: COL_070 The New Head Coach (weeks 1-4).
- Year 4: COL_104 Senior Year Starts (week 1), col_pro_scouts Scouts at Practice (week 4),
  COL_105 The Background Check (weeks 3-9), col_combine_invite Combine Invite (week 9, only with
  draft score 40+), COL_150 The Next Level (week 10).
- **Should never appear** (the wrong-path steps are story events but only open on a strike):
  COL_036 The Coach's Office, COL_071 The Second Strike, COL_017 The Pattern,
  COL_086 The Final Warning, COL_078 The Long Way Back, COL_106 The Red Flag Interview, and in the
  pros The Folder Follows You, The Old Crowd, The Rookie Symposium and The Reporter's Question.
- **Finale check:** "Say you're ready for the pros" is open only if you took a good choice in COL_108
  Combine Prep or COL_109 The Scouts' Workout. "Say you'll be okay either way" is open only after
  "Finish the degree" in COL_111 The Degree Question. The other two choices are always open.

**Run 2: wrong path, ending on The Long Way Back.** Take the strikes in this order. The four
wrong-path steps are **story events**: x4 weight while their window is open, and **forced** in the
last week of the window if you qualify and haven't seen them. Every step except The Long Way Back
clears every strike (all 24, including `balcony_jump`, `street_race` and `gave_keys_back`), so the
next step needs a new one. The strike scenes themselves (steps 1, 3 and 5) are random picks. If one
doesn't come up, take any other choice with bad or scandal conduct: the steps read every strike.

| Step | Window (eligible in weeks...) | Forced in |
|---|---|---|
| COL_036 The Coach's Office | years 1-3, weeks 1-11 | year 3, week 11 |
| COL_017 The Pattern (COL_071 The Second Strike on the other branch) | years 2-4, weeks 1-6 | year 4, week 6 |
| COL_086 The Final Warning | years 2-4, weeks 1-7 | year 4, week 7 |
| COL_078 The Long Way Back | years 2-4, weeks 1-8 | year 4, week 8 |

1. Year 1, COL_030 The Online Comment: "Reply with exactly what you think" (strike `online_incident`).
2. **COL_036 The Coach's Office**: "Tell the whole truth" (`owned_mistake`). Usually within a few
   weeks; at the latest year 3 week 11.
3. Year 2, COL_039 The Big House Party (weeks 2-8): "Stay for the chaos" (strike `party_trouble`).
4. **COL_017 The Pattern**: "Own it again, and change something" (`second_chance_used`). Year 2 or 3
   weeks 1-6 (x4 weight); at the latest year 4 week 6.
5. Year 3, COL_087 The Twenty-First Birthday: "Stay out until close" (strike `stayed_out_late`).
6. **COL_086 The Final Warning**: "Push back on the conditions" (`character_concerns`; scandal
   conduct, which ends brand deals). At the latest year 4 week 7.
7. **COL_078 The Long Way Back**: "Take every hour of it" (`rebuilt_reputation`, clears
   `character_concerns`). At the latest year 4 week 8.
8. Year 4: COL_104 Senior Year Starts (week 1), col_pro_scouts (week 4) and COL_105 The Background Check
   (weeks 3-9) as in run 1. In COL_105 the locked choice "Point them to the people who saw you change"
   should be **open**. If they come up, COL_113 The Last Rivalry Week and COL_127 Giving Back should
   also have their `rebuilt_reputation` choice open. Then COL_150 (week 10).
9. Pro season 1-2: The Rookie Symposium can appear (reads `rebuilt_reputation` / `owned_mistake`).

**Run 2 checks:**
- Each step appears no later than its forced week once you qualify. A step that appears **without** its
  flags (The Pattern without `owned_mistake` plus a new strike, The Final Warning without
  `second_chance_used` plus a new strike, The Long Way Back without `character_concerns`) is a bug.
- A step's window can close before you qualify. For example, a strike in year 4 after week 6 can't
  open The Pattern, and The Final Warning can't open after year 4 week 7. That's by design.
- COL_071 The Second Strike never appears (this path never sets `college_warning`).
- COL_106 The Red Flag Interview and the pro scenes The Folder Follows You and The Reporter's
  Question don't appear after step 7, because `character_concerns` is cleared.
- Draft score drops at every strike and at steps 2, 4 and 6 (-1 to -8), then rises at step 7 (+3).
- At most 2 scenes are forced in one week. Year 4 forced weeks: 1 Senior Year Starts, 4 Scouts at
  Practice, 6 The Pattern / The Second Strike, 7 The Final Warning, 8 The Long Way Back, 9 The
  Background Check and Combine Invite, 10 The Next Level. The graph check warns if a week ever holds
  more than 2.

## Known gaps
- No full signed Android build yet: a pack-only export was verified (all data included, boots and
  runs Career Mode screens). Build the .apk on your own machine (README → Export for Android).
- Cleanup: the personal cloud environment **thekicker** (allows `dl.google.com`) was created for an
  SDK download that was dropped. Nothing depends on it; delete it in claude.ai if unneeded.
- Kickoff returns are a number, not an animated return (the returner moves under the ball; no tackle).
- The warmup net's ripple is a simple shader bulge; the ball doesn't wrap into the mesh.
- The simulator's kick model is a stand-in; fallback-route frequency and pro career length need
  real-play checks.
- Game-winning kicks (and the Walk-Off achievement) are rare by design of the game sim.
- Junior college counts as one season; there is no redshirt, no playoffs, no injuries that skip
  games (injuries only make you play hurt), and pro free agency is tryout-only (no bidding).
- Placeholder art throughout; no sound files (the Sfx hooks print in debug builds).
