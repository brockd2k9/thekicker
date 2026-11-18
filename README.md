# Kicker (working title)

Mobile-first football kicker game. Godot 4 / GDScript, portrait, touch + mouse.
**Phase 1 = kicking prototype only.** All teams/players/situations are fictional.

## Run it

1. Install **Godot 4.7** (4.3+ should work) (standard build, not .NET): https://godotengine.org/download
2. Open Godot → **Import** → pick this folder's `project.godot` → **Import & Edit**.
   (The first open builds Godot's class cache. Run from the editor at least once
   before using the command line.)
3. Press **F5** / **⌘B** (Run Project).

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

Colors are shader uniforms. Click the mesh or material in the running scene's Remote tree,
or change the defaults at the top of each shader.
Framing: kicker's-eye view. The camera stays where the kicker stands and only turns its
head slightly to watch the ball (`camera_follow_strength`). Eye height, distance and tilt
are `home_offset` / `look_down_deg` in `kick_camera.gd`. The ball is drawn larger than real
(`ball_visual_scale`) and shrinks as it flies downfield (`ball_visual_scale_far`).

Formation: protection unit (blue) and block unit (red) line up 7 yards ahead, with a
holder kneeling at the spot. After the snap, both lines fire out, the middle defenders jump
with hands up, and two edge rushers come around the ends. If they reach the ball before
you kick, it's BLOCKED. Positions and colors are constants at the top of `field_builder.gd`.

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
scenes/field_goal.tscn        main scene (wires the pieces together)
scenes/ball.tscn              football model + ground shadow
scenes/ui/hud.tscn            HUD layout
shaders/                      procedural field, ball, crowd, sky
audio/                        optional sounds (see "Sound")
scripts/
  autoload/game_state.gd      GameState: session stats (Phase 2: player/season/save)
  autoload/sfx.gd             Sfx: sound hook
  autoload/haptics.gd         Haptics: phone vibration
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
  field/player_figure.gd      capsule player that can crouch, block, jump
  field/goal_posts.gd         posts + wind ribbons, regulation dimensions
  camera/kick_camera.gd       behind-the-ball camera, follow + shake
  game/field_goal_game.gd     attempt state machine (SETUP → SNAP → KICK_WINDOW → FLIGHT → RESULT)
  ui/hud.gd, wind_indicator.gd, swipe_trail.gd
```

Each script does one job and talks to the others through method calls and signals
wired in `field_goal_game.gd`. `KickController`, `KickResult`, `KickSituation`
are pure logic with no scene access.

### Input (touch now, Steam later)
`emulate_mouse_from_touch` is on, so the first finger arrives as mouse events.
`SwipeInput` handles mouse only, so phones and desktops share one path. It
listens in `_unhandled_input` and every HUD control is `mouse_filter = Ignore`.
Future menu buttons will therefore take their own clicks without firing kicks. Swipe
distances and speeds are measured in *screen heights*, so feel is resolution-independent.

### Where Phase 2 plugs in
- **Player stats → kick:** build a `KickModifiers` from stats
  (Leg Power → `power_mult`, Accuracy → `accuracy_spread_deg`,
  Composure → `pressure_sensitivity`, Fitness/Morale → `window_mult`) and assign it to
  `field_goal_game.gd`'s `modifiers`. Nothing else in the kick code changes.
- **Season games:** create `KickSituation`s from the game sim instead of `KickSituation.roll()`.
- **Week/schedule/money/relationships + save/load:** live in `GameState` (or sibling
  autoloads) as plain data, serialized to `user://`.
- **Menus:** new scenes. The field-goal scene can be instanced from a game-day scene.

## Sound

`Sfx.play(&"kick")` is called for `snap`, `catch`, `kick`, `good`, `miss`, `block`.
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

## Desktop / Steam later
- Add a Windows/Linux/macOS export preset. Mouse already works.
- Remove the `window_*_override` (450×800) in Project Settings → Display → Window or
  switch to a landscape-friendly layout. The HUD will reflow either way.
- Steam integration (achievements, etc.) would come via the GodotSteam addon later.
