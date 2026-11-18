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
| Career Mode | In progress: 3 save slots, high school seasons played week by week (off-field scenarios, Game Day Outlook, games watched from the bench with field goals / extra points in the kick scene and kickoffs / onside kicks / warmups on a sideline pad). Data in `data/career/`, balance in `tuning/career_tuning.tres`. Full docs come with the last Career stage |
| Challenge Mode | A run of kicks that get longer (25 yd → 60), windier (calm → 20 mph + gusts) and more pressured (none → clutch). **3 misses and the run ends** (blocks count). Results screen: Play Again / Main Menu |
| Practice | The original Phase 1 loop: random kicks forever (not in the original menu spec, added so the existing mode is still reachable) |
| My Stats | Session accuracy, all-time accuracy, longest make/miss streaks, longest field goal, misses by type, best Challenge run |
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

Vibration: `Haptics.pulse()` on contact (stronger with more power) and on a block.
Tunables: `kick_vibration_ms`, `block_vibration_ms` (0 = off).

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
  config/kick_tuning.gd       KickTuning resource definition
  input/swipe.gd              swipe data, normalized to screen height
  input/swipe_input.gd        pointer → swipe (touch & mouse, one code path)
  kick/kick_controller.gd     swipe → launch velocity (power curve, aim, wobble)
  kick/kick_modifiers.gd      Phase 2 seam: stats → multipliers (neutral now)
  kick/kick_situation.gd      random distance + pressure scenario
  kick/kick_result.gd         GOOD / WIDE LEFT / WIDE RIGHT / SHORT / BLOCKED rules
  kick/wind.gd                crosswind + gusts
  kick/snap_animator.gd       snap: snapper -> holder's hands -> spot
  kick/pressure.gd            aim wobble + kick-window shrink
  kick/ball.gd                ballistic flight, goal-plane + landing detection
  kick/ball_trail.gd          dotted arc trail
  kick/aim_marker.gd          wobbling aim ring
  field/field_builder.gd      field, stands, light towers, formation, holder
  field/player_figure.gd      jointed football player (helmet, pads, numbered jersey,
                              gloves, cleats): stance, run, block, jump, dive, kneel
  field/team_kit.gd           team uniform colors (fictional teams) + shared materials
  field/rush_plan.gd          random block call per attempt (who comes, who dives/leaps)
  field/goal_posts.gd         posts + wind ribbons, regulation dimensions
  camera/kick_camera.gd       behind-the-ball camera, follow + shake
  game/field_goal_game.gd     attempt state machine (SETUP → SNAP → KICK_WINDOW → FLIGHT → RESULT)
  ui/hud.gd, wind_indicator.gd, swipe_trail.gd
  ui/ui_kit.gd                shared theme, widgets, safe-area frame, modal/confirm dialog
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

### Career Mode: where it plugs in
- **Kicks:** a `CareerGameMode extends KickMode` sets the situation from the game sim and
  ends the game via `wants_next_kick()`. Kicks then reach stats and achievements through
  `GameState.kick_resolved` with `mode = &"career"`, with no other changes.
- **Save:** the save file already has a reserved `"career"` section (`GameState.career_data`).
- **Player stats → kick:** build a `KickModifiers` from stats
  (Leg Power → `power_mult`, Accuracy → `accuracy_spread_deg`,
  Composure → `pressure_sensitivity`, Fitness/Morale → `window_mult`) and assign it to
  `field_goal_game.gd`'s `modifiers`. Nothing else in the kick code changes.
- **Season games:** create `KickSituation`s from the game sim instead of `KickSituation.roll()`.
- **Week/schedule/money/relationships:** plain data in the `career` save section.
- **Screens:** the field-goal scene is instanced by a wrapper scene
  (see `challenge_screen.gd`), so a game-day scene can do the same.

## Sound

`Sfx.play(&"kick")` is called for `snap`, `catch`, `kick`, `good`, `miss`, `block`, plus
`ui_tap` (menu buttons), `achievement` (toast) and `run_over` (Challenge results).
`audio/music.ogg` (or .mp3/.wav), if present, loops on the Music bus.
Drop `audio/kick.ogg` (or `.wav`/`.mp3`) etc. into `audio/` and they play automatically.
Until then the events are printed to the Output panel in debug builds.

## Export for Android

One-time setup:
1. Install **Android Studio** (or the command-line tools) plus SDK Platform 34, Build-Tools 34,
   Platform-Tools, and **OpenJDK 17**.
2. Godot → **Editor → Editor Settings → Export → Android**: set *Java SDK Path* and
   *Android SDK Path*.
3. **Editor → Manage Export Templates → Download and Install** (must match your Godot version).
4. A debug keystore is created automatically by Godot 4.3+. For release you need your own:
   ```bash
   keytool -genkeypair -v -keystore release.keystore -alias kicker -keyalg RSA -keysize 2048 -validity 10000
   ```
   Keep keystores out of git (`.gitignore` already excludes `*.keystore` and `export_presets.cfg`).

Export:
1. **Project → Export → Add… → Android**.
2. Set *Package → Unique Name* (e.g. `com.yourstudio.kicker`), *Version Code/Name*.
3. Under *Permissions*, tick **Vibrate** (needed for the kick vibration).
4. Orientation is already portrait from Project Settings (`display/window/handheld/orientation`).
5. For a phone on USB with debugging on, use the **Remote Debug / One-click deploy** icon
   (top-right of the editor) to run straight on the device. Or **Export Project** → `.apk`
   (sideload) or `.aab` (Play Store, enable *Gradle Build* and install the Android build template).

The renderer is **GL Compatibility** for the widest Android device support.
The Android back button is handled by the game (`application/config/quit_on_go_back=false`):
back to the menu from a screen, pause in a kick, quit from the main menu.
Bump **Version Code** for every Play Store upload. `config/version` in Project Settings is
what the Settings screen shows.

## Desktop / Steam later
- Add a Windows/Linux/macOS export preset. Mouse already works.
- Remove the `window_*_override` (450×800) in Project Settings → Display → Window or
  switch to a landscape-friendly layout. The HUD will reflow either way.
- Steam integration would come via the GodotSteam addon later. Achievements: listen to
  `GameState.achievement_unlocked` and call the Steam API with the same `id`.
