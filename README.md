# Kicker (working title)

Mobile-first football kicker game. Godot 4 / GDScript, portrait, touch + mouse.
All teams, players and situations are fictional.

**Built so far:** the flick-to-kick field goal (Phase 1), plus a main menu,
Challenge Mode, Practice, My Stats, Achievements and Settings, all saved between
sessions. Career Mode is being built in stages (high school seasons are playable).

## Run it

1. Install **Godot 4.7** (4.3+ should work) (standard build, not .NET): https://godotengine.org/download
2. Open Godot → **Import** → pick this folder's `project.godot` → **Import & Edit**.
   (The first open builds Godot's class cache. Run from the editor at least once
   before using the command line.)
3. Press **F5** / **⌘B** (Run Project). The game opens on the **main menu**.
   To jump straight into the kick scene, open `scenes/field_goal.tscn` and press **F6**
   (Run Current Scene). That runs free practice with no menu.

The desktop window opens at 450×800 (portrait phone shape). You can resize it freely;
the HUD uses anchors/containers and the camera keeps the field width fixed, so any
aspect ratio works.

**Controls:** mouse drag or finger swipe, upward toward the posts.
- The ball is snapped back to the holder, who spots it. Wait for **SWIPE UP TO KICK!**;
  swiping before the ball is down doesn't count. The defense starts rushing at the snap.
- **Tilt** of the swipe = aim. **Speed** of the flick (plus some length) = power.
- The kick clock bar drains and the red rushers close in. If you're too late, the kick is **BLOCKED**.
- The white ring above the crossbar shows where a perfectly straight swipe would go.
  Under pressure it wobbles. Wind is *not* included; read the arrow and the
  red ribbons on the uprights.
- Tap after the result for the next kick.
- **II** (top center) pauses. Android back button / Esc also pauses in a kick
  scene, and goes back to the main menu from any other screen.

## Menu and modes

| Menu item | What it does |
|---|---|
| Career Mode | Freshman year to retirement: 3 save slots, a skippable first-time tutorial, week-by-week seasons (off-field scenarios, Game Day Outlook, games from the bench), recruiting and signing day, college, the draft and tryouts, pro contracts, and a career summary. See "Career Mode" below |
| Challenge Mode | A run of kicks that get longer (25 yd → 60), windier (calm → 20 mph + gusts) and more pressured (none → clutch). **3 misses and the run ends** (blocks count). Results screen: Play Again / Main Menu |
| Practice | The original Phase 1 loop: random kicks forever (not in the original menu spec, added so the existing mode is still reachable) |
| My Stats | Session accuracy, all-time accuracy, longest make/miss streaks, longest field goal, misses by type, best Challenge run, and a CAREER section (careers started / completed, best career, longest career, career kicks) |
| Achievements | Locked/unlocked list with unlock dates. A toast slides in when one unlocks |
| Settings | Sound volume, music volume, haptics, aim assist, Reset Stats (with confirmation) |

Challenge difficulty numbers are constants at the top of `scripts/modes/challenge_rules.gd`.
**Aim assist** = the white aim ring above the crossbar. It is visual only and never
changes the physics, so stats stay comparable with it on or off.

## How kick results flow (one event)

The kick result is decided in exactly one place: `field_goal_game.gd` `_resolve()`
(reached from the goal-plane crossing → `KickResult.judge_at_goal_plane()`, the ball
landing short, a tip at the line, or the kick clock running out). `_resolve()` builds a
`KickReport` and calls `GameState.report_kick()`, which emits **`GameState.kick_resolved`**:

```
field_goal_game._resolve()
  └─ GameState.report_kick(KickReport)      made?, miss_type, distance_yards,
       └─ signal kick_resolved                pressure, wind (base, gust, at kick), mode
            ├─ GameState: session stats + KickStats (all-time) → achievements → save
            ├─ ChallengeScreen: run rules (misses, score)
            └─ (Career later: game sim, player progression)
```

Runs (Challenge now, Career games later) end with `GameState.report_run(summary)` →
`run_finished` → stats + run achievements + save.

A game mode plugs into the kick scene through `KickMode` (`scripts/modes/kick_mode.gd`):
it picks the next `KickSituation` (distance, wind, pressure) and says whether there is a
next kick. It never touches the kicking mechanic. `mode = null` is free practice.

**Kick types.** The same scene plays five kicks (`KickSituation.KickType`, from
`KickMode.kick_type()`, read before the scene enters the tree):
- `FIELD_GOAL`, `EXTRA_POINT`: everything above, unchanged.
- `KICKOFF`, `ONSIDE`: ball on a tee, kickoff / onside formation (`kickoff_formation.gd`), no snap,
  hold, kick clock or block rush. The same swipe reading (`KickController.validate` /
  `power_from_swipe`, aim + pressure wobble + the profile's aim error), wind (× `wind_mult`) and
  KickProfile apply. Distance follows the old sideline curve (`KickoffRules.max_carry_yards` ×
  power × `power_mult`); `KickLaunch` finds the launch speed that makes the 3D ball land (kickoff) or
  stop (onside) there. `KickoffJudge` judges where it came down:
  - kickoff: TOUCHBACK (reached the goal line), DEEP KICK (fielded inside the 10), RETURNED,
    SHORT KICK (fielded at the 25 or beyond), OUT OF BOUNDS (landed past a sideline, wind included).
    Fielded kicks get a simple return (15-30 yards, less for long hang time, capped at midfield),
    which sets where the opponent's next drive starts in the play-by-play.
  - onside: RECOVERED! / THEIR BALL / OUT OF BOUNDS. Same risk/reward as before: a "good" onside
    (rests 10-18 yards out, aim within 15°) is recovered 45% of the time, any other 8%.
- `WARMUP_NET` (Career's sideline warmup, `WarmupMode`): the same scene on the sideline grass
  beside the team bench (`SidelineSet`: bench, cooler, 5 teammates in team colors, a strip of crowd;
  the field is empty), ball on a tee kicked into a net (`KickingNet`: frame on poles, mesh net that
  ripples where the ball hits, then the ball drops). Field-goal camera, no wind, no pressure, the
  player's KickProfile. Each strike is judged by `WarmupJudge` with the old pad's rules (power
  0.5-0.92 and aim within 6° = PURE!, otherwise PUSHED IT / PULLED IT / SOFT CONTACT / OVER-SWUNG);
  3 strikes, then WARMED UP (2+ pure) or LOOSE, handed to the game sim as before.
  `SidelineSet` and `KickingNet` are standalone pieces for anything else on the sideline.
  The result is in `tee_result` after `attempt_finished`. Tee kicks are **not** reported to
  `GameState.kick_resolved`, so they never touch field-goal stats, streaks or achievements.
  Camera: the same kicker's view from the start of the run-up, higher and a little wider
  (`kickoff_camera_offset`, `kickoff_camera_fov`, `kickoff_camera_follow` in `kick_tuning.tres`,
  group "Kickoff", with the launch angles and coverage speed). Same shake, slow-motion beat and
  banner as a field goal.

## Saves

One JSON file in the user data folder: **`user://kicker_save.json`**

| Platform | Folder |
|---|---|
| Android | app-private storage (cleared on uninstall) |
| Windows | `%APPDATA%\Godot\app_userdata\Kicker\` |
| macOS | `~/Library/Application Support/Godot/app_userdata/Kicker/` |
| Linux | `~/.local/share/godot/app_userdata/Kicker/` |

```json
{ "version": 2, "stats": {...}, "achievements": {"unlocked": {"first_make": 1794983149}},
  "settings": {...}, "career": {"last_slot": 1} }
```
Career Mode saves each career in its own file, **`user://career_slot_1.json`** .. `_3.json`
(same folder, same temp-file safety, own `"career_version"`; see `scripts/career/career_save.gd`).
The main save only remembers the last career slot, so a broken career file can't touch
your all-time stats. Version 1 saves are upgraded automatically.
Saved after every kick, run and settings change, and when the app is paused/closed.
Writes go to a temp file first and are then swapped in. A corrupt file is copied to
`kicker_save.json.bad` and the game starts fresh. To change the layout, bump
`SaveStore.VERSION` and add a step in `SaveStore._migrate()`. Delete the file to start over.

## Achievements (data)

Defined as data in `scripts/systems/achievement_defs.gd`: `id`, `name`, `description`,
`condition`. Add a row and it shows up and is checked automatically. Conditions can test
an all-time stat (`{"stat": "makes", "at_least": 100}`), a single kick
(`{"on": "kick", "made": true, "min_yards": 50}`, also `min_pressure`, `min_wind_mph`,
`mode`), or a run (`{"on": "run", "mode": "challenge", "min_makes": 10}`).
Seeded: First Make, 5-in-a-Row, Automatic (10 in a row), 50+ Yard Make, Moonshot (60 yd),
Clutch Kick, Windy Day (15+ mph at the moment of the kick), Century (100 makes), Gauntlet
(10 makes in one Challenge run).
Career achievements (condition `"on": "career"`, sent by Career Mode through
`GameState.report_career_event()` with `event` + `match` / `min_value` filters):
Scholarship Offer, Big Time (top program), Draft Day, Welcome to the League (first pro season),
Walk-Off (game-winning kick), Complete Package (all 8 traits), Against the Odds (pro after the
walk-on or junior college route), Full Career (retire after a pro season), Ironman (play until 40).

## Tuning (one file)

All feel numbers are in **`res://tuning/kick_tuning.tres`**. Click it in the
FileSystem dock and edit it in the Inspector, grouped as:
Ball Physics, Swipe → Power, Swipe → Aim, Wind, Pressure, Attempt, Feel.
Defaults and descriptions live in `scripts/config/kick_tuning.gd`. Values you change in
the Inspector are saved in the `.tres` and override those defaults.

Turn on `show_debug_readout` (on by default) to see `Power % / Aim° / Wobble°`
after every kick.

Reference numbers with the defaults (from a quick sim, center aim, no wind):

| Distance | Power needed | Raw swipe strength | 20 mph drift | Make cone |
|---|---|---|---|---|
| 20 yd | 18% | 24% | 1.2 m | ±8.8° |
| 40 yd | 47% | 53% | 2.6 m | ±4.4° |
| 50 yd | 58% | 64% | 3.4 m | ±3.5° |
| 60 yd | 69% | 73% | 4.1 m | ±2.9° |

Uprights are 2.82 m either side of center. More power means less hang time and therefore less drift.

## Look (no art files)

Everything is drawn with primitives plus procedural shaders in `shaders/`:
- `field.gdshader`: grass grain, mowing stripes, yard lines, hash marks, end zone
- `ball.gdshader`: pebbled leather, seams, worn tips, white stripes (`stripes` toggle).
  The pointed ball mesh and laces are generated in `ball.gd`
- `crowd.gdshader`: seats full of swaying fans behind the posts
- `sky.gdshader`: gradient sky with clouds
- `jersey.gdshader`: block numbers front and back with outline, side panels, fabric texture

Colors are shader uniforms. Click the mesh or material in the running scene's Remote tree,
or change the defaults at the top of each shader.
Framing: kicker's-eye view. The camera stays where the kicker stands and only turns its
head slightly to watch the ball (`camera_follow_strength`). Eye height, distance and tilt
are `home_offset` / `look_down_deg` in `kick_camera.gd`. The ball is drawn larger than real
(`ball_visual_scale`) and shrinks as it flies downfield (`ball_visual_scale_far`).

Formation: protection unit (blue) and block unit (red) line up 7 yards ahead, with a
holder kneeling at the spot. Every snap rolls a random block call (`rush_plan.gd`):
- who comes for the ball: the left edge, the right edge, or a lineman breaking through the middle
- the other edge rushes too but gets pushed wide by the wing and runs on past
- everyone runs nonstop from the snap: a quick burst, then constant speed
- the play's flavor: linemen pushing, getting their hands up, leaping, or diving forward,
  each with their own timing and slightly different alignment
- whether the middle man leaps, gets his hands up, or just walks up into a gap

Exactly one defender (the blocker) reaches the ball as the kick window closes, so if you're
late it's BLOCKED, and there's always someone there to show for it.

Blocks are also physical: every frame of the flight, the ball's path is checked against every
defender's gloves (`hand_block_radius`). A hurried kick comes off the foot lower
(`rushed_elevation_drop_deg`, starting at `rushed_from` of the way through the rush), so:
kick early and you clear everyone; kick late and a leaper (or, at the very end, a lineman
with his hands up) can tip it. Tipped kicks deflect up and back and count as BLOCKED.
The debug readout shows the launch angle as `Loft`.
Positions and colors are constants at the top of `field_builder.gd`; odds are in `RushPlan.roll()`.

Wind gusts: some windy kicks are gusty. Gusts only add speed in the wind's direction, from
the base speed up to base + gust (the HUD shows e.g. `8-15 MPH -> GUSTY`). The HUD arrow and
the ribbons on the uprights show the wind right now, so time your kick for a lull.
Tunables: `gust_chance`, `max_gust_mph`, `gust_speed`.

Did it get there? From the kicker's view a ball high in the air short of the posts looks like
one over the bar, so every field goal / extra point result shows where the ball really ended up
(`goal_marker.gd`, drawn over the players): a ring flashes where it crossed the plane of the posts
and the crossbar lights up green (good) or red (under the bar or wide); a kick that lands short
gets a red stake where it came down plus a red crossbar. The line under the banner gives the
margin: "Cleared the bar by 4 ft", "Under the bar by 1 ft", "Wide by 2 ft", "3 yards short".

Vibration: `Haptics.pulse()` on contact (stronger with more power) and on a block.
Tunables: `kick_vibration_ms`, `block_vibration_ms` (0 = off).

## UI look ("Night Broadcast")

Menus and overlays share one look: a night-game stadium (deep backgrounds, floodlight glow,
gold accent) with broadcast graphics (slanted buttons, lower-third headers, tickers, color
bars on cards). No image files: backgrounds (`ui/backdrop.gd`) and icons (`ui/ui_icons.gd`,
original SVG markup rasterized at runtime) are drawn from code.

- **Tokens, one place:** `scripts/ui/ui_tokens.gd` holds the palettes (colors), spacing,
  radii, slant, tap size, font sizes and animation times. Change a value there and every
  screen follows.
- **Theme:** `assets/ui/kicker_theme.tres` (the project's default theme) holds the fonts:
  Barlow (body), Oswald Bold (`Display`), Anton (`Banner`), Barlow Condensed (`Condensed`).
  `UiKit.theme()` adds the palette's buttons, panels, sliders and switches on top.
- **Widgets:** `UiKit` (buttons: `primary` / secondary / `danger`, with press feedback;
  `card`, `chip`, `section`, `title_block`, `stat_row`, `stat_tile`, `ticker`, `modal`) and
  `CareerUi` (stat group cards, `StatBar` with animated changes and +/- previews, change
  chips, choice cards with a locked state, scoreboard, result banner).
- **Career stages:** `UiKit.set_stage()` switches the palette: Friday Night (high school,
  navy + gold), Saturday (junior college / college, crimson + orange), Sunday Broadcast
  (pro, charcoal + red). The player's team colors are used in the Hub header and backdrop.
- **Motion:** screens fade/slide between each other (`ScreenFade` autoload), cards stagger
  in, stat bars glide to new values, trait unlocks and result banners punch in.
- **Sound and haptics hooks:** `UiKit.feedback(&"event")` plays the Sfx event (silent until
  a file exists) and pulses the phone. Events are listed under "Sound".
- **Performance:** backgrounds are drawn once (no per-frame shaders on menus); the only
  continuous animation is the main menu ticker when its text doesn't fit.
- Font licenses: `CREDITS.md` (all SIL Open Font License).

**Score bug (career games):** `scenes/ui/scoreboard.tscn` (`Scoreboard`) is an early-2000s TV score bug
for the fictional **GRIDCAST** network: a quarter / clock tab, the network block, away and home rows
(team abbreviation, score, a gold marker for the team with the ball) and a strip with your game line
(FG, XP, long, points). Chrome and glass panels are drawn in code (`Scoreboard.GlossPanel`). It reads a
`ScoreBugState` (`scripts/ui/score_bug_state.gd`) through signals, never polling; the career game screen
owns one state, set from every `GameSim` event (score, clock, `possession`), and both the bench screen's
bug and the one over the kick scene bind to it. A kick updates the score and strip the moment it is
judged; changes flash. In the kick scene the HUD keeps the top clear for it
(`Hud.make_room_for_score_bug`). Abbreviations: each team's `short` field, or one made from its name.

**Field tracker (career game screen):** `scenes/ui/field_tracker.tscn` (`FieldTracker`) is a compact
top-down strip of the field under the score bug, sized to the screen width (height about 30% of the
width, at most 16% of the screen). End zones in team colors with the names written vertically (away
left, home right, all game; the offense attacks the other end, so direction flips with possession),
striped turf with faint yard numbers, the ball (tweened between plays), the line of scrimmage (red)
and first-down line (yellow), a drive bar in the offense's color with an arrow, field goal range
shaded when the offense is in it, and a gold frame with the distance when it's your kick. Under it:
an info bar ("1st & 10 ball on OAK 37", timeouts at the edges) and the last play with a type tag
(RUSH, PASS, PUNT, FG, XP, KICKOFF, TURNOVER, TD, TIMEOUT). It reads a `FieldState`
(`scripts/ui/field_state.gd`, signals only, no polling) that `FieldModel`
(`scripts/career/field_model.gd`) fills from `GameSim`'s events. The sim plays drives, not single
plays, so the model builds the field picture from the sim's own numbers (drive start spots, gains,
the warmup's "opponent 32", your kick's distance, kickoff start spots, TDs / punts / turnovers);
timeouts are 3 per team per half, used to ice your clutch kicks and by a trailing offense late in a
half. Display only: it never changes the sim (a test plays the same seeded game with and without it).
Play events carry their play line's key and numbers (`"key"`, `"vars"`) for it. Nothing is saved.

**Layout checker:** `tools/ui_check.tscn` opens every screen in a real state (it plays a
career forward with the real rules) and checks tap targets (>= 88 px), cut-off text and
anything off screen. Run it at the four window shapes (needs a window, not `--headless`;
your saves are backed up and restored):

```
godot --path . --resolution 720x1280  res://tools/ui_check.tscn -- tag=phone out=/tmp/shots
godot --path . --resolution 1080x2400 res://tools/ui_check.tscn -- tag=tall
godot --path . --resolution 1536x2048 res://tools/ui_check.tscn -- tag=tablet
godot --path . --resolution 1920x1080 res://tools/ui_check.tscn -- tag=desktop
```
`out=` saves a screenshot of every screen; `only=hub,results` limits the run.

## Project layout

```
project.godot                 portrait 720x1280 base, canvas_items stretch, GL Compatibility
tuning/kick_tuning.tres       ← all tunables
scenes/field_goal.tscn        kick scene (wires the pieces together), reused by every mode
scenes/screens/               main menu, practice, challenge, stats, achievements,
                              settings, career placeholder (thin scenes; UI built in code)
scenes/ball.tscn              football model + ground shadow
scenes/ui/hud.tscn            HUD layout
shaders/                      procedural field, ball, crowd, sky
audio/                        optional sounds (see "Sound")
scripts/
  autoload/game_state.gd      GameState: THE service. kick_resolved event, session stats,
                              owns KickStats / AchievementTracker / GameSettings / SaveStore
  autoload/sfx.gd             Sfx: sound hook (plays on the "SFX" bus)
  autoload/haptics.gd         Haptics: phone vibration
  autoload/music.gd           Music: loops audio/music.ogg on the "Music" bus if present
  core/kick_report.gd         KickReport: the kick-result event payload
  systems/kick_stats.gd       all-time stats (streaks, longest FG, misses by type, best run)
  systems/achievement_defs.gd achievements as data
  systems/achievement_tracker.gd  unlock state + condition checks
  systems/game_settings.gd    volumes, haptics, aim assist; creates SFX/Music buses
  systems/save_store.gd       JSON save file, version + migrations
  modes/kick_mode.gd          KickMode: how a mode plugs into the kick scene
  modes/challenge_rules.gd    Challenge difficulty ramp + 3-miss rule
  modes/warmup_mode.gd        sideline warmup: 3 strikes into the net, then pure / loose
  config/kick_tuning.gd       KickTuning resource definition
  input/swipe.gd              swipe data, normalized to screen height
  input/swipe_input.gd        pointer → swipe (touch & mouse, one code path)
  kick/kick_controller.gd     swipe → launch velocity (power curve, aim, wobble)
  kick/kick_modifiers.gd      Phase 2 seam: stats → multipliers (neutral now)
  kick/kick_situation.gd      one attempt: kick type, distance, wind, pressure (random or from a mode)
  kick/kickoff_rules.gd       kickoff / onside numbers (spot, touchback, return, onside odds)
  kick/kickoff_judge.gd       touchback / deep / returned / short / out of bounds; onside results
  kick/kick_launch.gd         tee kicks: launch speed for a target carry (same integrator as Ball)
  kick/warmup_judge.gd        sideline net: pure strike rules, session result
  kick/kick_result.gd         GOOD / WIDE LEFT / WIDE RIGHT / SHORT / BLOCKED rules
  kick/goal_marker.gd         result marks at the posts (crossing ring, crossbar glow, short stake)
  kick/wind.gd                crosswind + gusts
  kick/snap_animator.gd       snap: snapper -> holder's hands -> spot
  kick/pressure.gd            aim wobble + kick-window shrink
  kick/ball.gd                ballistic flight, goal-plane + landing detection
  kick/ball_trail.gd          dotted arc trail
  kick/aim_marker.gd          wobbling aim ring
  field/field_builder.gd      field, stands, light towers, formation, holder
  field/kickoff_formation.gd  kickoff / onside formations, tee, yard numbers, coverage run
  field/sideline_set.gd       team sideline: bench, cooler, teammates, crowd strip, net + tee
  field/kicking_net.gd        kicking net on poles with a ripple (shaders/net.gdshader)
  field/player_figure.gd      jointed football player (helmet, pads, numbered jersey,
                              gloves, cleats): stance, run, block, jump, dive, kneel
  field/team_kit.gd           team uniform colors (fictional teams) + shared materials
  field/rush_plan.gd          random block call per attempt (who comes, who dives/leaps)
  field/goal_posts.gd         posts + wind ribbons, regulation dimensions
  camera/kick_camera.gd       behind-the-ball camera, follow + shake
  game/field_goal_game.gd     attempt state machine (SETUP → SNAP → KICK_WINDOW → FLIGHT → RESULT);
                              tee kicks skip the snap (SETUP → KICK_WINDOW → FLIGHT → RESULT)
  ui/hud.gd, wind_indicator.gd, swipe_trail.gd
  ui/ui_tokens.gd             UiTokens: palettes, spacing, radii, fonts, timings (the one place)
  ui/ui_kit.gd                theme, widgets, safe-area frame, modal/confirm, feedback hook
  ui/ui_icons.gd              vector icons (SVG in code) for stats, traits, menus
  ui/backdrop.gd              code-drawn screen backgrounds per palette mood
  ui/stat_bar.gd              StatBar: icon + animated bar + +/- preview
  ui/screen_fade.gd           ScreenFade autoload: fade between screens
  ui/screens.gd               scene paths + navigation
  ui/menu_screen.gd           base for menu screens (Back / Esc / Android back)
  ui/play_overlay.gd          pause button + pause menu over the kick scene
  ui/toast.gd                 Toast autoload: achievement banners
  ui/screens/*.gd             one script per screen
```

### Screen scaling (phones now, Steam later)
Menus are laid out in the 720×1280 base viewport and scaled by the `canvas_items` stretch
mode. Content sits in a centered 640-px column, so taller phones get more space and a
landscape desktop window just gets wider side margins. Buttons are 96 px tall (thumb
sized), and screens respect the notch / safe area like the HUD. On desktop, buttons take
keyboard/gamepad focus (arrows + Enter, Esc = back). On phones, focus rings are off.

Each script does one job and talks to the others through method calls and signals
wired in `field_goal_game.gd`. `KickController`, `KickResult`, `KickSituation`
are pure logic with no scene access.

### Input (touch now, Steam later)
`emulate_mouse_from_touch` is on, so the first finger arrives as mouse events.
`SwipeInput` handles mouse only, so phones and desktops share one path. It
listens in `_unhandled_input` and every HUD control is `mouse_filter = Ignore`.
Future menu buttons will therefore take their own clicks without firing kicks. Swipe
distances and speeds are measured in *screen heights*, so feel is resolution-independent.

### Career Mode
Playable from freshman year to retirement: high school -> recruiting (offers by tier,
GPA-gated) -> college (or walk-on tryout / junior college) -> draft (or training camp /
open free-agent tryouts) -> pro contracts (re-sign, release, Retire; no age cap: older free agents get fewer tryouts) ->
career summary. A long run of poor seasons and failed tryouts ends a career early.
A short tutorial runs the first time Career Mode opens (text: `data/career/tutorial.json`;
"seen" flag: `career_tutorial_seen` in Settings; replay: "How Career Mode Works").
Career milestones feed My Stats (CAREER section) and the career achievements.
**Stats per level** come from the season history: every finished season is saved with its stage
and kicking line, so High School / College (junior college included) / Pro totals and the season
rows are built from it (plus the season in progress). Saves from every earlier version already
have this.
**Expanded stats** (Stats screen, Season view and each Career tab, in collapsible sections):
field goals by distance (20-29, 30-39, 40-49, 50-59, 60+; anything under 20 yards would count in
20-29, but the shortest field goal is 20 yards with the current tuning), extra points, streaks
(made field goals in a row overall and per distance range, made extra points in a row; longest and
current), and Misc (longest field goal, points, game-winning kicks, games, clutch kicks to win or
tie, kickoffs, touchbacks, average kickoff, onside kicks recovered). Distance, streak, clutch and
kickoff numbers come from the per-kick log `CareerData.kick_log` (save version 7, filled from then
on by `CareerManager._record_kicks`). Streaks run in kick order across seasons within a level; a new
level starts fresh, and Total shows the best level's streak. A range's streak only sees kicks in
that range. Any scope with kicks from before the log (older saves, or the season in progress when
the save was upgraded) shows "-" for those numbers instead of guessing; a season counts as logged
when its logged kicks match its saved attempts.
**School interest** (Recruiting screen; `Progression.school_interest`) is computed, not saved:
50 = the recruiting points at which that school's tier starts offering, about 2.5 per point near
there and leveling off toward 6..94, plus a fixed -6..+6 lean per school; at least the matching
level once a school has offered, and capped when your GPA is below the tier's minimum. Each tier's
offer goes to its most interested school without one, so a school without an offer never outranks
an offering school of its tier; schools at offer-level interest (50+) that are still waiting (one
new offer per tier a season, none as a freshman) say "Interest high, no offer yet this season".
Old career saves load and are upgraded (format versions and steps in
`scripts/career/career_save.gd`); content that was renamed or removed since a save was made is
dropped on load. Design decisions and values to playtest: `PLAYTEST.md`, "Career Mode".

| What | Where |
|---|---|
| Balance numbers (stat -> kick curves, caps, gains, seasons, game sim, scenario picks) | `tuning/career_tuning.tres` (defaults + docs in `scripts/career/career_tuning.gd`) |
| Scenarios (61 written: HS, college, pro, bye/offseason, trait-gated; plus the 150-scenario high school and 154-scenario college story graphs, all written, and the pro story graph: 828 PRO_* scenes in six eras by age, 100 written so far, the rest drafts the game skips) | `data/career/scenarios_*.json` (field reference: `_doc` in `scenarios_hs.json`; graphs: `scenarios_hs_graph.json`, COL_* in `scenarios_college.json`, PRO_* in `scenarios_pro.json`; pro design: `tools/pro_graph/PRO_DESIGN.md`) |
| Relationships: the cast (8 people + Team standing), roles, tiers, name lists | `data/career/people.json` (rules: `scripts/career/relationships.gd`; numbers: `career_tuning.tres` "Relationships") |
| Skill points, attribute upgrades (Skills screen) | `scripts/career/skill_points.gd` (numbers: `career_tuning.tres` "Skill Points") |
| Field goal / kickoff range, game-day range, range -> launch speed | `scripts/career/kick_range.gd`, `kick_profile.gd` (numbers: "Power -> Range", "Game Day Range") |
| Kick results -> Coach / Team, coach doubt ("too many misses") | `scripts/career/kick_trust.gd` (numbers: "Relationships", kick results + too many misses) |
| Perks (15): cost, prerequisites, effects | `data/career/perks.json` (rules: `scripts/career/perks.gd`) |
| Aging and maintenance (from 30) | `scripts/career/aging.gd` (numbers: `career_tuning.tres` "Aging") |
| Cold and snow games (late season) | `career_manager.gd` `_roll_cold()`, `kick_profile.gd` (numbers: "Weather") |
| Traits (8), game-day modifiers (19), stat descriptions | `data/career/traits.json`, `modifiers.json`, `stats_info.json` |
| Schools (16 HS, 18 colleges in 3 tiers, 6 junior colleges), 12 pro clubs, names, play-by-play | `data/career/world.json`, `game_day.json` |
| Progression tables: college tiers, offers, draft rounds, tryouts, contracts | `data/career/progression.json` (weights in `career_tuning.tres`) |
| Recruiting / draft / retention / academics rules | `scripts/career/progression.gd` |
| Content word check (teen audience) | `data/career/content_rules.json` |
| Weekly loop / saves | `scripts/career/career_manager.gd`, `career_save.gd` (3 slots: `user://career_slot_N.json`) |
| Stats + traits -> kick | `scripts/career/kick_profile.gd` (`KickProfile.build()` -> `KickModifiers`) |
| Scenario engine | `scripts/career/scenario_engine.gd` |
| Hub → **Stats** (kicking record: Season view; Career view with HS / College / Pro / Career Total tabs, season rows and totals; distance, extra point, streak and misc sections; per-kick log `CareerData.kick_log`) and Hub → **Recruiting** (recruiting points, interested colleges with interest level and offers) | `scripts/career/career_records.gd` (`CareerRecords`, read-only), screens `career_kicking.gd`, `career_recruiting_board.gd` |

Goalposts and uniforms: `field_goal_game.gd` `set_look()` (called before the scene enters the
tree) picks the posts style per stage (high school plain H-frame and wide, college gooseneck
with school-colored padding/bands, pro polished and narrower; widths in `career_tuning.tres`
"Goalposts") and dresses both lines in the teams' colors. Without it the scene looks as before.

How the pieces connect: a career game runs the existing kick scene through `CareerGameMode`
(a `KickMode`) with `KickProfile.to_kick_modifiers()`, so career field goals and extra points
report through `GameState.kick_resolved` with `mode = &"career"` and count in My Stats and
Achievements. Kickoffs and onside kicks run in the same 3D scene (`CareerGameMode.kickoff_rules_for()`
builds the stage's `KickoffRules`) and hand `tee_result` back to `GameSim.resolve_call()`; they
don't count in My Stats. Kickoff spots per stage (`career_tuning.tres`, "Sideline Kicks"): high
school from the 40, college and pro from the 35; touchbacks at the 20 / 25 / 30, out of bounds at
the 35 / 35 / 40. The sideline warmup is the same 3D scene too (`WarmupMode`); the old 2D
sideline pad is gone.
`CareerContent.validate()` checks every data file (run by the Career Debug screen, the simulator and the tests; problems print as warnings).

**Balance simulator:** `godot --headless res://tools/career_sim.tscn -- careers=40 seed=1` plays
many careers with different choice strategies through the real systems and writes
`user://career_sim_report.md` (trait unlock rates, personality / football / life stat
distributions, scenario frequencies; each career also spends skill points one of four ways, and the
report covers range, slumps by kicker quality, the skill point economy, aging and perk usage).
It ends with an aging probe (the same pro from 30, preserving vs not); `probe=1 income=50` runs only
that, in a second. `tools/career_sim_baseline.md` is the current baseline.
It also reports followers (by stage, season, kicker quality and spending style; tier shares by
season) and kick challenge pass chances (each proposed conversion, for kickers at 60/70/80/90%
expected field goals, normal / tired / heavy legs / injured). Options: `make=0.8` (every kick made
with that chance), `bench=0` (benching off), `fans=0` (followers give nothing: effects on vs off),
`tag=1` (+1 followers buzz on every choice: an estimate of the story session's tags),
`conv=res://path.json` (other kick challenge values), `set=key:value,...` (override tuning values).
Design decisions and values to playtest: `PLAYTEST.md`, "Career Mode".

**Relationships:** eight recurring people (head coach, holder, teacher, best friend, Tyler
Brooks, Dad, your little brother, someone special), each with a value 0-100 saved per career in
`CareerData.people` (story flags stay in `CareerData.flags`); the People screen (Hub) lists everyone
you've met. Scenario choices move values (`"rel": {"coach": 5}`), scenarios and choices can require
them (`"min": {"rel_coach": 60}`), and scenario text can name people (`{coach}`, `{tyler}`...).
Values feed game day (coach: pressure and how long a kick you're sent out for; holder: aim; Tyler),
the week (family: energy; friends: fun and social; Tyler as a rival: skill points), grades
(teacher) and recruiting (final-season coach recommendation; a teacher who vouches eases college
GPA minimums). Team standing (your teammates) is a ninth entry: kicks move it, it calms or rattles you
on game day, and it backs the coach's word. Every effect is zero at 50, the starting value. Coach, holder and teacher are new
each stage (the old ones are listed as Former); Tyler Brooks signs with his own college and pro
club, shows up on your schedule once you've met him, and is your teammate if you pick his school.
Save version 3 (older saves get the current stage's cast at 50).

**Skill points, range and kick trust (save version 4):** football attributes grow through
skill points, not passive growth (the old weekly / offseason / per-make growth knobs are kept at 0).
Points come from makes (long, clutch and game-winning ones earn more), perfect games, weekly
practice, offseason training, good seasons and scenario choices (`"skill_points": n`); the Skills
screen (Hub: tap the range strip) spends them one attribute point at a time, at a cost that rises
with the level, with a preview of what the point changes. **Field goal range** comes from Power
(`KickRange`: a new freshman kicks 40, Power 100 reaches 66, perks will add a little, hard cap 70);
rest and health add yards on game day and fatigue, illness and injury take them away (Game Day
Outlook: "Rested: +2 yds"). The kick's top launch speed is set from today's range, so a full
flick clears the bar at exactly that distance; Practice and Challenge are unchanged. **Kickoff
range** is its own Power curve; `CareerGameMode.kickoff_rules_for(..., profile)` sets the carry so
a full kickoff reaches it, and `KickModifiers.kickoff_range_yd` / `kickoff_mult` carry it for kickoff
code that scales carry directly. The coach calls field goals up to your range minus 2 (plus or
minus his relationship). Every field goal and extra point you kick moves the coach and your **Team
standing** (`KickTrust`: misses cost more than makes earn, scaled by the situation and the kick's
difficulty; Resilience and Leadership soften misses). Too many misses (the last 5 attempts, or the
season FG%) start **coach doubt**: shorter and fewer field goal calls for a few weeks, explained on
the Outlook, and the `kicking_slump` flag (HS_142 can follow). Recruiting, the draft and pro
retention count range; the coach's recommendation uses Coach and Team.

**Benching (save version 5):** when the coach doubts you and trust is low, the Hub and the Game Day
Outlook warn you (ON THIN ICE). A bad game that week (two missed field goals) and the backup takes your
field goals for a week or two (Tyler Brooks when he's your teammate, otherwise the stage's backup
kicker); you keep extra points and kickoffs. Win the job back in an audition (3 of 5, a tryout in the
kick scene). Rules: `scripts/career/bench.gd`; numbers: `career_tuning.tres` "Benching"; details and
tuning: `PLAYTEST.md`, "Benching".

**Followers (save version 7):** a real social media follower count. Field goals, game winners,
perfect games, good seasons, viral moments, winning the bench audition and scenario choices
(posting, charity, helping teammates, good conduct) add followers; bad conduct, scandals, a missed
game winner and being benched cost some. The same moment is worth a few dozen followers in high
school and thousands in the pros. Tiers (Local Name, Hometown Hero 500, Rising Star 5K, Campus
Celebrity 25K, Verified 100K, Fan Favorite 500K, Household Name 2M) unlock scenarios
(`requires.followers_tier`) and give small, capped extras (skill points and Team at each new tier,
Fun / Social in a big week, a small season-end standing bonus in the pros, up to +10% pro salary,
brand deals, and a little pressure in close 4th quarters once you're famous: "Fans are watching" on
the Outlook). Shown on the Hub, Results, Stats, the season summary and scenario cards. Rules:
`scripts/career/followers.gd`; numbers: `career_tuning.tres` "Followers"; details: `PLAYTEST.md`,
"Followers".

**Character reputation and suspensions:** the college story's `character_concerns` flag costs draft
stock on draft day and early pro standing; `rebuilt_reputation` clears the draft penalty and adds a
little standing. A choice's `suspend_weeks` (1-3) sits the player out games like academic
ineligibility. Rules: `scripts/career/reputation.gd`; notes for writers:
`docs/story_note_reputation_suspensions.md`.

**Career state for scenarios:** "right now" values (`slump_now`, `benched_now`, `fg_streak`, `clubs`, ...),
game-set flags (`contract_year`, `re_signed`, `signed_new_club`, `released`), `{club}` / `{town}`,
`once_per_club`, and a season-end `dismissed` flag: `docs/story_note_career_state.md`.

**Overtime:** a tie after four quarters goes to overtime, with rules by stage: high school (the
Kansas plan from the 10, up to 4 rounds), college (from the 25; two-point tries from the third
overtime, so the kicker sits out; no ties) and pro (one 10-minute period, both teams get the ball
unless the first scores a touchdown, then sudden death; can end tied). Overtime kicks are high
pressure, and an overtime game winner counts like any game winner. Details: `PLAYTEST.md`,
"Overtime".

**Kick challenges:** a scenario choice can be a real kick challenge (showcase, camp, combine,
kicker battle): picking it opens the kick scene (field goals clamped to your range - 1, and kickoffs
for combines); pass for the full reward, miss for a milder outcome. Tryouts, the bench audition and
challenges save every kick and resume after a reload (a kick struck mid-flight counts as a miss).
Rules: `scripts/career/kick_challenge.gd`; details: `PLAYTEST.md`, "Kick challenges"; the data
format for scenario writers: `docs/story_handoff_followers_challenges.md`.

**Perks, aging and weather:** the Skills screen has two tabs. **Perks** (15, `data/career/perks.json`)
cost skill points and need prerequisites (attributes, other perks, a personality trait, a stage, an
age); each is a small edge (Big Leg +2 yd, Laser tighter aim, Clutch less pressure on game winners,
Hang Time, Onside Specialist, Cold Weather Kicker, Iron Leg...). **Aging:** from age 30 every
football attribute declines at the end of each season (Power and Toughness fastest, Resilience
slowest, more every year); the Attributes tab's Maintenance section preserves one for the season
with skill points, and the season summary shows what's about to drop. **Weather:** late-season
games can be cold (-1 to -2 yd) or snowy (-2 to -3 yd, a little aim error), shown on the Game Day
Outlook; Cold Weather Kicker removes most of it.

**Tests:** `godot --headless --path . res://tests/run_tests.tscn` runs every `test_*` method in
`tests/test_*.gd` (add `-- only=test_saves` for one file) and exits with the number of failing
tests: old-save compatibility (frozen v0/v1/v2 saves in `tests/fixtures/`; never edit those, add a
new fixture per save version), the scenario engine, `CareerContent.validate()` on the real data,
kickoffs (`test_kickoff.gd`: the judge, the launch solver, per-stage rules, the career wiring) and the
warmup (`test_warmup.gd`: same rules as the old pad, session flow). `tools/ui_check.tscn` also captures
`warmup`, `warmup_result`, `kickoff`, `kickoff_result` and `onside` from a real career game.
The balance simulator gives the same report for the same seed, so a content-neutral change can
be checked by diffing its tables before and after.

**High school story graph:** 150 scenarios (IDs HS_001-HS_160; the upstream skeleton has 160, and
the converter merges 10 duplicates into other scenarios) with flag dependencies, in
`data/career/scenarios_hs_graph.json`. They start as drafts (`"draft": true`, no text or choices):
the engine never picks a draft and `validate()` checks only its graph data, so they can be written
a few at a time. Fill in `category`, `text` and `choices` (each choice setting the scenario's
`expected_flags` between them), then remove `draft`.
- `python3 tools/convert_hs_graph.py` regenerated the file from the upstream skeleton
  (`tools/hs_graph/`); its decision tables (ungated targets, story windows, year-0 seasons,
  duplicates) are the record of how the graph was mapped. Re-running keeps written content.
- `python3 tools/validate_scenario_graph.py` runs the same flag checks as `validate()` without
  Godot, plus warnings (overlapping same-season windows, unread flags, similar titles) and a
  scenarios-per-season count. `--skeleton <file>` audits a file in the upstream format.
- **Writing content:** `tools/authoring/WRITING_GUIDE.md` (rules, stat ranges, modifiers,
  people, placeholders), fill-in templates `tools/authoring/hs_template_freshman.json` (25 to
  start with) and `hs_template_all.json` (all 150; regenerate with
  `python3 tools/make_authoring_templates.py`), and three finished examples in `examples.json`.
  Import with `python3 tools/import_scenarios.py <file> --dry-run` (check only), then without
  `--dry-run` (writes into the data files; nothing is written if there's any error).
  The dry run also prints lint notes (advice): pronouns on gender-neutral placeholders, hand-written
  cast names, curly quotes, game-kick language, one-sided choices; `python3 tools/lint_scenarios.py`
  (`--all` for every scenario file) runs them on what's already imported.
  Tool tests: `python3 -m unittest discover -s tests -p 'test_*.py'`.
- Story scenarios (`"story": true`) have a season/week window: boosted while it's open, forced
  in its last week if not seen (`story_weight_mult`, `max_forced_per_week` in `career_tuning.tres`,
  "Scenario Picks").

## Sound

`Sfx.play(&"kick")` is called for `snap`, `catch`, `kick`, `good`, `miss`, `block`, plus
`ui_tap` (menu buttons), `achievement` (toast), `run_over` (Challenge results) and `net` (ball into
the sideline warmup net).
UI hooks (`UiKit.feedback`, also a haptic pulse; see `UiKit.FEEDBACK`): `ui_confirm`
(primary buttons, picking a choice), `ui_locked` (tapping a locked choice), `ui_transition`,
`stat_up`, `trait_unlock`, `week_result`, `result_good` / `result_miss` (HUD banner, on top
of `good` / `miss`) and `game_winner`.
`audio/music.ogg` (or .mp3/.wav), if present, loops on the Music bus.
Drop `audio/kick.ogg` (or `.wav`/`.mp3`) etc. into `audio/` and they play automatically.
Until then the events are printed to the Output panel in debug builds.

## Export for Android

Build the APK/AAB on your own machine: you accept the Android SDK licenses there and you own
the signing keys. Nothing here needs Android Studio's IDE, only its SDK.
The facts below are for **Godot 4.7** (checked against the 4.7-stable source and the 4.7 docs).

### What you need (one time)

| Item | Version | Notes |
|---|---|---|
| Godot editor | **4.7** (standard build is fine; no .NET needed) | |
| Export templates | **4.7**, exactly matching the editor | **Editor → Manage Export Templates → Download and Install** |
| JDK | **OpenJDK 17** | Newer JDKs are allowed but 17 is the one Godot recommends. Adoptium Temurin 17 is a good choice. |
| Android SDK Command-line Tools | latest | from developer.android.com ("Command line tools only"), or via Android Studio's SDK Manager |
| SDK Platform-Tools | latest | provides `adb` for one-click deploy |
| SDK Build-Tools | **36.1.0** (35.0.1 also works) | `apksigner` is taken from here |
| SDK Platform | **Android 36** (`platforms;android-36`) | Godot 4.7 targets API 36, min API 24 (Android 7.0) |
| NDK + CMake | NDK **29.0.14206865**, CMake 3.10.2.4988404 | only for **Gradle builds** (needed for `.aab` / Play Store) |

Install the SDK packages with `sdkmanager` (this is where you accept the licenses):

```bash
sdkmanager --sdk_root=<android_sdk_path> "platform-tools" "build-tools;36.1.0" "platforms;android-36" "cmdline-tools;latest"
```

```bash
sdkmanager --sdk_root=<android_sdk_path> "ndk;29.0.14206865" "cmake;3.10.2.4988404"
```

```bash
sdkmanager --sdk_root=<android_sdk_path> --licenses
```

(The second command is only needed for Gradle / `.aab` builds.)

### Godot Editor Settings

**Editor → Editor Settings → Export → Android** (turn on *Advanced Settings* at the top
right if a field is hidden):

- **Java SDK Path** (`export/android/java_sdk_path`): the JDK 17 install folder (the one that
  contains `bin/java`). Empty = uses `JAVA_HOME`.
- **Android SDK Path** (`export/android/android_sdk_path`): the SDK root (the folder that
  contains `platform-tools/` and `build-tools/`). Empty = uses `ANDROID_HOME`.
- **Debug Keystore** (`export/android/debug_keystore`), **Debug Keystore User**,
  **Debug Keystore Pass**: see below.

### Debug keystore

Godot creates one for you: once the Java SDK Path is set, the editor generates
`debug.keystore` (user `androiddebugkey`, password `android`) and fills in the three debug
fields. If it didn't (for example the JDK path was wrong at the time), make it yourself and
point *Debug Keystore* at the file:

```bash
keytool -genkey -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "cn=Godot, ou=Godot Engine, o=Stichting Godot, c=NL"
```

Debug Keystore User = `androiddebugkey`, Debug Keystore Pass = `android`.
The debug key is only for testing on your own phone; the Play Store won't accept it.

### Release keystore (create once, back it up)

Every update to a published app must be signed with the same key, so this file matters
more than anything else in the build setup.

```bash
keytool -v -genkey -keystore kicker-release.keystore -alias kicker -keyalg RSA -keysize 2048 -validity 10000
```

- Use **one password for both the keystore and the key** (Godot's preset has a single
  *Release Password* field), and avoid special characters in it.
- In the Android export preset: **Keystore → Release** = path to the file,
  **Release User** = `kicker` (the alias), **Release Password** = the password.
  Untick **Export With Debug** when exporting for release.
- Or keep the secrets out of the editor: set `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`,
  `GODOT_ANDROID_KEYSTORE_RELEASE_USER` and `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD`
  before launching Godot (there are matching `..._DEBUG_...` variables).

**Back it up:**
- Keep the `.keystore` file **and** its alias and password in at least two safe places
  (e.g. a password manager entry with the file attached, plus an offline copy such as an
  encrypted USB drive). Not only on the build machine.
- Never commit it: `.gitignore` already excludes `*.keystore` and `export_presets.cfg`
  (the preset stores the password in plain text).
- On Google Play, turn on **Play App Signing** (the default for new apps). Your keystore
  then becomes the *upload key*: if it is ever lost, Google can reset it for you. Without
  Play App Signing a lost key means you can never update the app again.

### Export steps

1. **Project → Export → Add… → Android**.
2. *Package → Unique Name*: e.g. `com.yourstudio.kicker` (it can never change after publishing).
   Set *Version → Code* (an integer, bump it for every store upload) and *Version → Name*
   (shown to players; keep it in step with `config/version` in Project Settings, which the
   Settings screen shows).
3. *Permissions*: tick **Vibrate** (used for the kick vibration). Nothing else is needed.
4. *Launcher Icons*: the project has no icon yet, so Godot's default is used. Add a
   192×192 main icon and 432×432 adaptive foreground/background before a store release.
5. *Resources → Filters to exclude files*: `tests/*, tests_tmp/*, tools/*` (dev-only). Keep
   *Export all resources in the project*. Career data (`data/career/*.json`) is included
   automatically.
6. Orientation is already portrait from Project Settings (`display/window/handheld/orientation`).
7. Test on a phone: enable USB debugging, plug it in, and use the **Remote Debug /
   One-click deploy** button (top right of the editor). Or **Export Project** → `.apk`
   with *Export With Debug* on, and sideload it.
8. Play Store: tick **Gradle Build → Use Gradle Build**, run **Project → Install Android
   Build Template**, set the release keystore, untick *Export With Debug*, and export as `.aab`.

The renderer is **GL Compatibility** for the widest Android device support.
The Android back button is handled by the game (`application/config/quit_on_go_back=false`):
back to the menu from a screen, pause in a kick, quit from the main menu.

**What has been verified so far:** a pack-only Android export
(`godot --headless --export-pack "Android" kicker.pck`, which needs no SDK or templates)
contains every game resource including all `data/career/*.json`, and the exported pack boots
the menu, the Career tutorial and the Career Debug screen (which validates all career data)
with no errors. A full signed `.apk` / `.aab` has **not** been built yet. On the first real
export, check touch, vibration and the back button on an actual phone.

### Note: the "thekicker" cloud environment

During Career Mode development a personal Claude Code cloud environment named
**thekicker** was created (network: package registries plus `dl.google.com`, for a
download of the Android SDK that was then dropped in favour of building on your own machine).
Nothing in the project depends on it. If you don't need it, delete it in
claude.ai → Claude Code → the environment menu → **thekicker** → Edit / Delete.

## Export for the web

A browser build (desktop and phone browsers), single-threaded so it runs on any static host
(itch.io, GitHub Pages, Netlify) without special server headers. Saves go to the browser's
storage (per site), separate from the Android app's saves.

1. Export templates, once: Godot editor → *Editor → Manage Export Templates → Download and
   Install* (the 4.7 set includes Web).
2. Add the preset, once: *Project → Export → Add... → Web*, then match
   `tools/web/web_preset.cfg`: *Variant → Thread Support* **off**, *Resources → Filters to
   exclude*: `tests/*, tests_tmp/*, tools/*`, export path `export/web/index.html`. (Or append that
   file's block to `export_presets.cfg`, renumbering `preset.0` to the next free number.)
3. Export: *Project → Export → Web → Export Project* (uncheck *Export With Debug*), or from a
   terminal: `godot --headless --path . --export-release "Web" export/web/index.html`.
4. Try it locally: `cd export/web && python3 -m http.server 8000`, open http://localhost:8000
   (opening index.html straight from disk doesn't work: browsers block it).
5. Publish: upload everything in `export/web/` (index.html, .js, .wasm, .pck, icons). On itch.io:
   zip the folder's *contents*, upload as an HTML game, viewport 720 x 1280, enable
   "Mobile friendly". Re-export after every change (the .pck holds the game and its data).

**Typing on phone browsers (known limitation and fix).** A phone browser only opens its
keyboard when a text field is focused inside the tap itself, and Godot handles taps a frame
later, so tapping a Godot text field in the web build shows no keyboard (iOS Safari is the
strictest). The native apps don't have this problem: there the New Career name field asks the
OS for its keyboard on every tap. Godot's *Experimental Virtual Keyboard* web option and
JavaScript workarounds (a hidden HTML input, `prompt()`) are unreliable on phones, and itch.io
runs games in a cross-origin frame where dialogs can be blocked, so keep that option **off**.
**The fix:** the web build on touch devices (`web_android` / `web_ios`, or any touch screen)
never needs the keyboard. The name field starts with a random name and works as a button:
tapping it opens **Pick a Name**, six suggestions from `data/career/world.json` ("names") with
a Shuffle button (`CareerNewScreen.uses_name_chooser()`). Desktop browsers, desktop builds and
the Android/iOS apps type the name as before. The New Career name is the only text field in
the game; give any new one the same treatment.

## Desktop / Steam later
- Add a Windows/Linux/macOS export preset. Mouse already works.
- Remove the `window_*_override` (450×800) in Project Settings → Display → Window or
  switch to a landscape-friendly layout. The HUD will reflow either way.
- Steam integration would come via the GodotSteam addon later. Achievements: listen to
  `GameState.achievement_unlocked` and call the Steam API with the same `id`.
