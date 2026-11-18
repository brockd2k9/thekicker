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
walk-on or junior college route), Full Career (retire after a pro season), Ironman (age 38).

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

### Career Mode
Playable from freshman year to retirement: high school -> recruiting (offers by tier,
GPA-gated) -> college (or walk-on tryout / junior college) -> draft (or training camp /
open free-agent tryouts) -> pro contracts (re-sign, release, Retire, age cap 38) ->
career summary. A long run of poor seasons and failed tryouts ends a career early.
A short tutorial runs the first time Career Mode opens (text: `data/career/tutorial.json`;
"seen" flag: `career_tutorial_seen` in Settings; replay: "How Career Mode Works").
Career milestones feed My Stats (CAREER section) and the career achievements.
Old career saves load and are upgraded (format versions and steps in
`scripts/career/career_save.gd`); content that was renamed or removed since a save was made is
dropped on load. Design decisions and values to playtest: `PLAYTEST.md`, "Career Mode".

| What | Where |
|---|---|
| Balance numbers (stat -> kick curves, caps, gains, seasons, game sim, scenario picks) | `tuning/career_tuning.tres` (defaults + docs in `scripts/career/career_tuning.gd`) |
| Scenarios (49: HS, college, pro, bye/offseason, trait-gated) | `data/career/scenarios_*.json` (field reference: `_doc` in `scenarios_hs.json`) |
| Traits (8), game-day modifiers (19), stat descriptions | `data/career/traits.json`, `modifiers.json`, `stats_info.json` |
| Schools (16 HS, 18 colleges in 3 tiers, 6 junior colleges), 12 pro clubs, names, play-by-play | `data/career/world.json`, `game_day.json` |
| Progression tables: college tiers, offers, draft rounds, tryouts, contracts | `data/career/progression.json` (weights in `career_tuning.tres`) |
| Recruiting / draft / retention / academics rules | `scripts/career/progression.gd` |
| Content word check (teen audience) | `data/career/content_rules.json` |
| Weekly loop / saves | `scripts/career/career_manager.gd`, `career_save.gd` (3 slots: `user://career_slot_N.json`) |
| Stats + traits -> kick | `scripts/career/kick_profile.gd` (`KickProfile.build()` -> `KickModifiers`) |
| Scenario engine | `scripts/career/scenario_engine.gd` |

Goalposts and uniforms: `field_goal_game.gd` `set_look()` (called before the scene enters the
tree) picks the posts style per stage (high school plain H-frame and wide, college gooseneck
with school-colored padding/bands, pro polished and narrower; widths in `career_tuning.tres`
"Goalposts") and dresses both lines in the teams' colors. Without it the scene looks as before.

How the pieces connect: a career game runs the existing kick scene through `CareerGameMode`
(a `KickMode`) with `KickProfile.to_kick_modifiers()`, so career kicks report through
`GameState.kick_resolved` with `mode = &"career"` and count in My Stats and Achievements.
`CareerContent.validate()` checks every data file (run by the Career Debug screen, the simulator and the tests; problems print as warnings).

**Balance simulator:** `godot --headless res://tools/career_sim.tscn -- careers=40 seed=1` plays
many careers with different choice strategies through the real systems and writes
`user://career_sim_report.md` (trait unlock rates, personality / football / life stat
distributions, scenario frequencies). `tools/career_sim_baseline.md` is the current baseline.
Design decisions and values to playtest: `PLAYTEST.md`, "Career Mode".

## Sound

`Sfx.play(&"kick")` is called for `snap`, `catch`, `kick`, `good`, `miss`, `block`, plus
`ui_tap` (menu buttons), `achievement` (toast) and `run_over` (Challenge results).
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
5. *Resources → Filters to exclude files*: `tests_tmp/*, tools/*` (dev-only). Keep
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

## Desktop / Steam later
- Add a Windows/Linux/macOS export preset. Mouse already works.
- Remove the `window_*_override` (450×800) in Project Settings → Display → Window or
  switch to a landscape-friendly layout. The HUD will reflow either way.
- Steam integration would come via the GodotSteam addon later. Achievements: listen to
  `GameState.achievement_unlocked` and call the Steam API with the same `id`.
