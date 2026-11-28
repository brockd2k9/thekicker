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
| Daily Challenge | One kick a day, the same for every player (seeded by the date), with a streak and a 7-day track: 7 successful days in a row pay skill points for Career Mode. A popup the first time the menu opens each day, a NEW badge on the menu and the Career hub. See "Daily Challenge" below |
| Challenge Mode | A run of kicks that get longer (25 yd → 60), windier (calm → 20 mph + gusts) and more pressured (none → clutch). **3 misses and the run ends** (blocks count). Results screen: Play Again / Main Menu |
| Practice | The original Phase 1 loop: random kicks forever (not in the original menu spec, added so the existing mode is still reachable) |
| My Stats | Session accuracy, all-time accuracy, longest make/miss streaks, longest field goal, misses by type, best Challenge run, and a CAREER section (careers started / completed, best career, longest career, career kicks) |
| Achievements | Locked/unlocked list with unlock dates. A toast slides in when one unlocks |
| Settings | Sound volume, music volume, haptics, aim assist, graphics (Low / High quality, a switch per visual feature, frame-rate readout, benchmark), Reset Stats (with confirmation) |

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

## Daily Challenge

One kick a day. Main menu -> **Daily Challenge** (or Career hub -> Daily Challenge, or the popup
the first time the menu opens each day). Code: `scripts/daily/`; screens:
`scripts/ui/screens/daily_screen.gd` (streak, reward track, stats, today's kick),
`daily_kick_screen.gd` (intro card -> kick -> result card), shared pieces `scripts/ui/daily_ui.gd`
(the week track: 7 slots, the prize on day 7, made days filled red).
**Every number is in `tuning/daily_tuning.tres`** (defaults and docs: `scripts/daily/daily_tuning.gd`).

- **The day:** `DailyClock.day_number()` is the only definition (local midnight; `day_start_hour`
  moves it). Time comes from a `DateSource` (`scripts/daily/date_source.gd`): the device clock now;
  subclass it for server time and assign it to `GameState.daily.clock`.
- **The kick:** `DailyScenario.generate(day, tier)` builds it from the date alone (seeded, so the
  same for everyone and it can't be re-rolled): kick type (field goal, extra point, kickoff, onside),
  situation (game winner, down 1, icing, overtime...), wind / gusts / head-tailwind, weather (seasonal)
  and field condition (small kick modifiers). Difficulty follows the week (easy Monday, harder each
  day, a **boss kick on Saturday**, easier Sunday). Your skill tier (Rookie / Varsity / College / Pro,
  from your career's FG range, or your all-time accuracy without a career; locked for the day) only
  sets the distances and how much the weather bites, so everyone shares the same situation. Daily kicks
  use Challenge Mode's physics (not a career's range). Goals: field goal / extra point made; kickoff
  in play (easy days) or deep (touchback / inside the 10); onside: a perfect hop (10-18 yd, straight).
- **Attempts:** one kick. A miss offers one retry per day with a rewarded ad (optional). A kick
  counts the moment it's struck (saved), so closing the game mid-flight is a miss.
- **Streak and the weekly payout:** the streak is consecutive days with a success; the week is the
  streak mod 7. Days 1-6 pay nothing ("Day X of 7 complete"). The 7th success in a row pays
  `sp_weekly` skill points (default 10) the moment that kick is made, claimed in the same save write
  as the result (`payout_days` + per-career claim ids: never paid twice), with an optional
  `consecutive_week_bonus` per consecutive week (default 0, off). Then the track starts a new week at
  day 1; the streak and longest streak keep counting. Skill points go to the last-played career (the
  same balance as the Skills screen, source "Daily Challenge"); with no active career they're banked
  and added when one opens. A missed day resets the streak and the week; after exactly one missed
  day the **streak saver** (rewarded ad, or free on a no-ads platform with the "free" rule; once per
  streak, only that day) restores both.
- **Clock guard:** the last time seen and highest day seen are saved. A clock set back to a day
  already seen locks the challenge (no kicks, no claims) until it catches up.
- **Kept apart:** daily kicks report with mode `daily`, in `GameState.UNRECORDED_MODES`: never in
  My Stats, career stats, records, streaks of made kicks or achievements.
- **Ads:** the Daily Challenge's `AdService` (`scripts/daily/ad_service.gd`: `is_ready(placement)`,
  `await show_rewarded(placement) -> bool`) goes through the **AdManager** autoload
  (`ManagedAdService`, placements `DAILY_RETRY` / `STREAK_SAVER`), so it follows the same rules as
  every other ad (see "Ads" below). `StubAdService` (instant, no AdManager) is for tests and
  `ad_mode = "stub"`; `NoAdService` for `ad_mode = "none"` / `no_ads_platform`. On a platform
  without ads `no_ads_rule` decides: `"none"` (default: no retry, no saver) or `"free"` (both
  without an ad).
- **Debug:** in debug builds the Daily Challenge screen has **Prev Day / Next Day** (shifts the
  clock a day; Prev after playing shows the clock-moved-back lock) and **Reset Daily Data**.

## Saves

One JSON file in the user data folder: **`user://kicker_save.json`**

| Platform | Folder |
|---|---|
| Android | app-private storage (cleared on uninstall) |
| Windows | `%APPDATA%\Godot\app_userdata\Kicker\` |
| macOS | `~/Library/Application Support/Godot/app_userdata/Kicker/` |
| Linux | `~/.local/share/godot/app_userdata/Kicker/` |

```json
{ "version": 5, "stats": {...}, "achievements": {"unlocked": {"first_make": 1794983149}},
  "settings": {...}, "career": {"last_slot": 1}, "daily": {...},
  "monetization": {"ads_removed": false} }
```
`"daily"` is the Daily Challenge (version 3; older saves get an empty one).
`"monetization"` is app-wide ad / purchase state (version 4; AdManager.to_dict()).
Version 5 made the Daily Challenge rewards weekly: a streak in progress lands on its day of the
week (streak mod 7), and per-day rewards from earlier versions that were still waiting still pay out.
Career Mode saves each career in its own file, **`user://career_slot_1.json`** .. `_3.json`
(same folder, same temp-file safety, own `"career_version"`; see `scripts/career/career_save.gd`).
The main save only remembers the last career slot, so a broken career file can't touch
your all-time stats. Version 1 saves are upgraded automatically.
Saved after every kick, run and settings change, and when the app is paused/closed.
Writes go to a temp file first and are then swapped in. A corrupt file is copied to
`kicker_save.json.bad` and the game starts fresh. To change the layout, bump
`SaveStore.VERSION` and add a step in `SaveStore._migrate()`. Delete the file to start over.

## Ads (AdManager)

Game code never calls an ad SDK. It calls the **AdManager** autoload (`scripts/autoload/ad_manager.gd`):

| Call | What it does |
|---|---|
| `AdManager.is_rewarded_ready()` | enable / disable an ad button |
| `await AdManager.show_rewarded(placement)` | opt-in rewarded ad; `true` only if the reward was earned |
| `await AdManager.show_interstitial(placement)` | the forced post-game ad; skipped silently when the rules say no |
| `AdManager.platform_has_ads()` | `false` on Steam: hide ad offers |
| signals | `ad_rewarded`, `ad_dismissed_without_reward`, `ad_failed` (exactly one per rewarded call), `interstitial_finished`, `ads_changed` |

Placements: rewarded (opt-in only) `REDO_KICK`, `REDO_GAME`, `PRACTICE_50`, `DAILY_RETRY`, `STREAK_SAVER`;
forced (interstitial only) `POST_GAME_FORCED`. A forced placement can't be shown as a rewarded ad
(AdMob policy: rewarded ads must be opt-in).

**Rules (every placement):** forced ads never show when `ads_removed`, within
`MIN_SECONDS_BETWEEN_ADS` of the end of any ad, while another ad shows, or when none is loaded.
Rewarded ads stay available to ad-free buyers. Game audio is muted while an ad plays.

**Backends** (`scripts/monetization/ads/`, chosen by `AdManager.pick_mode()`):
- `AdMobAdBackend`: Android + iOS through the Poing Studios AdMob plugin **v5.1.0**. Consent first
  (Google UMP: consent form if required; on iOS Google's IDFA explainer + the App Tracking
  Transparency prompt come from this flow when the IDFA message is set up in AdMob > Privacy &
  messaging), then SDK init, then one rewarded + one interstitial preloaded, reloaded after each
  show and retried with backoff after a failed load. The plugin's classes are looked up at runtime,
  so the project runs without the plugin installed.
- `MockAdBackend`: editor / desktop debug. Full-screen "Ad playing..." for 3 s, then the reward;
  **Skip (No Reward)** tests the no-reward path.
- `NoneAdBackend`: Steam (export feature tag `steam`) and desktop release builds: no SDK, no ad UI.

**Config, one file:** `scripts/monetization/monetization_config.gd` (`MonetizationConfig`): `USE_TEST_IDS`
(default `true`; real IDs are never read while it's on, and test slots must hold Google test IDs),
test and real IDs per platform, mock timings, consent debug geography, the ad rules. Real mode is
refused (badge **ADS: BLOCKED**, error in the log) while a platform's real app ID / rewarded unit is
empty (iOS today) or Project Settings `admob/general/<platform>/app_id` doesn't match.

**Seeing the mode:** a small top-right badge, **ADS: MOCK / TEST IDS / REAL / BLOCKED** (debug builds
and any test-ID build; never a release build with real ads). Log lines start with `[AdManager]`.
Debug builds also get **Settings > ADS (DEBUG)**: status, Test Rewarded Ad, Test Forced Ad, an
Ads Removed switch and Reset Ad Consent. **Settings > PRIVACY > Privacy Options** appears when
Google's consent SDK requires it (EEA / UK).

**Setup on your machine (not in the repo):**
1. Install the plugin: AssetLib "AdMob" by Poing Studios v5.1.0 (or the release zip from
   github.com/poingstudios/godot-admob-plugin) into `res://addons/admob`, enable it in Project
   Settings > Plugins; it downloads the Android / iOS binaries for your exact Godot version (4.7.0-4.7.2).
2. The app IDs are already in `project.godot` (`[admob]`, the test app IDs); the plugin writes them into
   the Android manifest / iOS Info.plist at export. Change them together with `USE_TEST_IDS`.
3. Android: Project > Install Android Build Template, export preset > Use Gradle Build, min SDK 24.
4. iOS: paste `platform/ios/additional_plist_content.xml` into the iOS export preset's
   **Application > Additional Plist Content** (the App Tracking Transparency text). The plugin adds
   `GADApplicationIdentifier` and Google's `SKAdNetworkItems` itself. iOS 15+, Xcode 15+.

**Career placements (Stage 2).** Every number is in `MonetizationConfig` ("Career Mode ad placements").
- **Missed kick** (field goal / extra point): "No good" card with **Watch an Ad to Retry** /
  **Accept the Miss**. A retry kicks the same call again in the kick scene; the miss is taken back
  from the score bug and never reaches the game sim (it still counts in My Stats, like any kick).
- **Lost game:** the Final card offers **Watch an Ad to Replay** / **Accept the Loss**. The loss is
  saved as pending first (`CareerManager.set_pending_final`), so closing the app on the offer brings
  the offer back instead of a free replay. A replay restarts the game from the same checkpoint.
- **Caps:** `MAX_REDOS_PER_GAME` (2) kick retries + replays together, `MAX_GAME_REPLAYS_PER_GAME` (1);
  counted per game in the career's game checkpoint (`CareerManager.game_redos()`), so leaving or
  replaying doesn't reset them. Ad-free buyers get `FREE_REDOS_PER_GAME_AD_FREE` (1) without an ad.
  Steam: `REDOS_ON_NO_ADS_PLATFORM` (`"none"`).
- **"Stay for all 50"** (`PRACTICE_50_CHOICES`: scenario `hs_extra_practice`, choice 0): the card says
  **WATCH AN AD TO CHOOSE THIS**, tapping it asks first, and the choice is applied only when the reward
  is earned. No ad available (decided when the screen opens, or the ad can't play) -> free
  (`PRACTICE_50_FREE_IF_NO_AD`). Closing the ad early chooses nothing.
- **Forced ad:** leaving a game's Final card calls `AdManager.after_career_game()`: one interstitial
  every `FORCED_AD_EVERY_N_GAMES` (3) games (counter in the main save). Skipped silently when
  ad-free, none loaded, within `MIN_SECONDS_BETWEEN_ADS` of another ad, or after a declined redo offer
  in that game (`FORCED_AD_SKIP_AFTER_ANY_DECLINE`); it then stays due for the next game.
- Ad buttons are disabled with "No ad is available right now..." while no ad is loaded, and enable
  themselves when one loads. Debug panel extras: **Make Forced Ad Due After Next Game**, **Mock: Ad
  Available** (test the no-ad paths).

## Store (StoreManager)

Game code never calls a billing SDK. It calls the **StoreManager** autoload
(`scripts/autoload/store_manager.gd`): `is_available()`, `products()`, `await purchase(id)`,
`await restore_purchases()`. Screens: **Store** (main menu, and "Get Skill Points" on the Career
Skills screen), with **Restore Purchases** (required on iOS).

**Products, one file:** `MonetizationConfig.STORE_PRODUCTS` (ids, kinds, pack sizes, reference prices,
`enabled`). The id is the Play Console / App Store Connect product id (`store_ids` overrides per platform).

| Product | Kind | Price | Gives | On sale |
|---|---|---|---|---|
| `remove_ads` "Remove Forced Ads" | non-consumable | $9.99 | no forced ads; rewarded ads stay optional; 1 free redo per game | yes |
| `skill_points_50` | consumable | $4.99 | 50 SP (about one season of play) | yes |
| `skill_points_100` | consumable | $8.99 | 100 SP (+11% per dollar) | `enabled: false` |
| `skill_points_250` | consumable | $19.99 | 250 SP (+25%) | `enabled: false` |
| `skill_points_500` | consumable | $34.99 | 500 SP (+43%) | `enabled: false` |

**Why these prices:** players earn about 45 SP a season (`tools/career_sim_baseline.md`), an attribute
point costs 2-3 SP at 40-50 and 9-15 SP from 80 up, perks 12-60 SP. So $4.99 buys about one season's
grind: worth it early (about 15-20 attribute points in high school) and a smaller boost late (4-5 points
at 90+), never a requirement. Bigger packs give more per dollar on standard store price points.

**Bought skill points** go to the open career, else the last-played one (`GameState.store_grant_skill_points`;
source "Store", not counted as earned in season / career totals); with no career they're banked and added
when one opens. Each grant is keyed by its transaction id (never twice), and the store transaction is
finished only after the grant is saved. Saved in the main save: `"monetization" > "store"`.

**Backends** (`scripts/monetization/store/`): `MockStoreBackend` (debug builds while `STORE_DEBUG_GRANTS`:
a "Test purchase" card, then the item, no payment; Restore works from a test ledger),
`GooglePlayStoreBackend` and `AppStoreStoreBackend` (**not wired yet**: they report unavailable, so a
release build hides the store; `TODO(billing)` marks each plugin call), `NoneStoreBackend` (Steam: the
ad-free product is never listed; the skill point store follows `STEAM_SKILL_POINT_STORE`, `"off"`).
Release builds never grant without payment. No external payment links anywhere (Apple's rule for iOS).

**Billing plugins to wire later:** Android: **GodotGooglePlayBilling 3.3.0** (official, Play Billing Library
9.1.0, one build for Godot 4.2+, Gradle build). iOS: **hrk4649/godot_ios_plugin_iap** 0.4.0+ (StoreKit 2,
confirmed on Godot 4.7, rebuilt per Godot version). One API for both: **godot-iap** (OpenIAP, StoreKit 2,
iOS 17+). Debug panel: **Settings > STORE (DEBUG) > Forget Local Purchases** to test Restore.

**Godot 4.7.2 crash to know about:** calling a method that `await`s through a variable typed as a
base class whose own version doesn't `await` corrupts the caller's locals after the await (segfault).
AdManager calls its backend's async methods through an untyped reference (`_async_backend()`) for
this reason; keep that pattern when adding a backend.

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
- `turf.gdshaderinc`: the field (see "Graphics quality" below): mowing stripes, color variation,
  wind, yard lines, hash marks, yard numbers, end zone paint. `field.gdshader` is the old flat
  field, still used when Grass Shader and Field Paint are both switched off
- `ball.gdshader`: pebbled leather, seams, worn tips, white stripes (`stripes` toggle).
  The pointed ball mesh and laces are generated in `ball.gd`
- `crowd.gdshader`: seats full of swaying fans behind the posts
- `sky_broadcast.gdshader`: sun-lit sky with shaded clouds (lights the scene too).
  `sky.gdshader` is the old gradient sky (Sky Lighting off)
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

Difficulty (field goals and extra points, `tuning/kick_difficulty.tres`, defaults and docs in
`scripts/config/kick_difficulty.gd`; `enabled = false` restores the old, easier kicking exactly):
- **Crooked swipes:** the swipe's path is measured (how far it bulges off a straight line and how far
  its finish turns away). Past `straightness_tolerance` the penalty grows on a curve
  (`straightness_penalty_curve`): extra aim error the way the swipe curled (`max_deviation_degrees`),
  less power (`max_power_loss`) and a hook/slice in flight (`max_hook_accel`).
- **Distance:** from `easy_yards` to `hard_yards` the tolerance shrinks and the penalty grows, plus a
  little extra random aim error. A 20-yarder stays easy; a 50+ needs a clean, straight swipe.
- **Wind:** pushes harder (`wind_strength_multiplier`) and more the longer the ball is up
  (`hang_time_wind_growth`). Windy field goals also get a headwind / tailwind (`max_head_tail_mph`);
  the HUD arrow, its label and the upright ribbons show the true direction.
- **Contact vibration:** a short sharp pulse for a clean strike, longer and rougher for a mishit
  (phones only; Settings > Vibration).
All of it stacks on the Career KickModifiers (scenario choices and stats still scale power, aim
error, wobble, the kick window and wind as before).

Did it get there? From the kicker's view a ball high in the air short of the posts looks like
one over the bar, so every field goal / extra point result shows where the ball really ended up
(`goal_marker.gd`, drawn over the players): a ring flashes where it crossed the plane of the posts
and the crossbar lights up green (good) or red (under the bar or wide); a kick that lands short
gets a red stake where it came down plus a red crossbar. The line under the banner gives the
margin: "Cleared the bar by 4 ft", "Under the bar by 1 ft", "Wide by 2 ft", "3 yards short".

Vibration: `Haptics.pulse()` on contact (stronger with more power) and on a block.
Tunables: `kick_vibration_ms`, `block_vibration_ms` (0 = off).

## Graphics quality (visual upgrade, stage 1)

**Settings → Graphics.** Two presets, and one switch per feature so each can be checked on its
own. Low is the default on phones and in the browser, High on desktop. Changes show the next
time a kick scene opens. None of it touches the kick: only how the scene is drawn.

| Feature | Off | Low | High |
|---|---|---|---|
| Sun Shadows | no shadows | one 2048 shadow map over the first 60 m, hard edges | 4 blended splits to 150 m, 4096 map, soft edges |
| Sky Lighting | old gradient sky, flat ambient color | sun-lit sky with clouds; the sky lights and reflects on the scene (64 px cubemap) | same with sun-shaded clouds and a 256 px cubemap |
| Distance Haze | none | depth fog tinted by the sky, a little sun scatter | same |
| Color Grading | none | filmic tonemap (runs inside each material: no extra pass) | + contrast and saturation (one full-screen pass) |
| Bloom | none | none | glow on the light banks, scoreboards and white paint |
| Grass Shader | old flat field | mowing stripes that follow the sun, color variation, blade grain, wind gusts that follow the real wind | + worn turf between the hashes, fine blade detail, blade normals |
| Field Paint | old thin lines | 6 ft white border, 4 in yard lines, 8 in goal lines, inbound and sideline hash marks, yard numbers with arrows, try line, end zone color with the home team's nickname, pylons | same |

How it is built:
- `scripts/systems/visual_quality.gd` (VisualQuality): the preset, the switches, the FPS
  readout flag; saved inside the settings. `VisualQuality.active()` is what the scene draws with.
- `scripts/visual/stage_look.gd` (StageLook, a node in `field_goal.tscn`): the sun or the
  stadium lights, shadows, sky, haze, grading and bloom for the active options. Sun direction:
  `SUN_DAY` / `SUN_NIGHT` at the top of the file.
- `shaders/turf.gdshaderinc` + `scripts/visual/turf_shader.gd`: the field, compiled in variants
  so a feature that is off costs nothing. Colors are set in `FieldBuilder._build_ground()`.
  The big bowls (stadiums with sideline stands) mow a checkerboard.
- `scripts/visual/field_paint.gd`: draws the yard-number digits and the end zone lettering
  once with the display font (no texture files). `scripts/visual/noise_texture.gd`: the one
  small noise texture the grass and sky sample.
- With Grass Shader and Field Paint both off the field is `field.gdshader`, untouched.

**Frame rate.** Settings → Show Frame Rate puts fps / ms in the corner on every screen.
Settings → **Graphics Benchmark** times every feature on the device (about a minute), shows
the table, saves it to `user://graphics_benchmark.txt` and can copy it. Phones lock the frame
rate to the screen, so when everything fits in a frame it says so and runs a second pass at four
times the pixels to rank the features. From the command line:
`godot --path . res://scenes/screens/graphics_benchmark.tscn -- auto=1 seconds=6`.

Measured so far only on a **software renderer** (Mesa llvmpipe, 720x1280, no GPU), which
overstates per-pixel work and says nothing about a phone's absolute numbers. Use it for the
order of the costs; run the benchmark on the phone for the real ones.

| Row | ms / frame | vs. everything off | Share of the old frame |
|---|---|---|---|
| Before the upgrade (old look: 4 shadow splits) | 166 | +106 | 100% |
| Everything off | 60 | | 36% |
| + Sun Shadows, Low / High | 87 / 173 | +27 / +113 | 16% / 68% |
| + Sky Lighting, Low / High | 60 / 64 | 0 / +4 | 0% / 2% |
| + Distance Haze | 68 | +8 | 5% |
| + Color Grading, Low / High | 61 / 71 | +1 / +10 | 1% / 6% |
| + Bloom (High only) | 81 | +21 | 13% |
| + Grass Shader, Low / High | 74 / 75 | +14 / +15 | 8% / 9% |
| + Field Paint | 62 | +2 | 1% |
| **LOW preset** | 93 | +33 | 56% |
| **HIGH preset** | 201 | +141 | 121% |

Run-to-run noise is a few ms. Low draws faster than the old look because the old scene used
the engine's default four shadow splits; Low uses one.

Screenshots with chosen options (dev tool): `godot --path . --resolution 720x1280
res://tools/visual_shot.tscn -- out=/tmp/high.png preset=high off=bloom night=1 tier=pro_3`.

Not in stage 1: no HDRI file (the sky is procedural, so the build stays free of texture
assets and the lighting cubemap is made once at load), no 3D grass blades, no midfield logo,
no extra real-time lights at night.

## UI look: the broadcast design system

Every menu, career screen and overlay uses one look: modern TV sports broadcast graphics,
strictly red, black and white (greys allowed). Red marks primary actions and highlights only;
team colors appear only as thin stripes. The kick scene's in-play HUD (`scenes/ui/hud.tscn`) keeps
its own layout but uses the same fonts.

- **One file for the look:** `scripts/ui/brand/brand.gd` (`Brand`): the palette (blacks for
  layering, one red, white, two greys), the type scale (Hero 128, Display 84, Title 60, Heading 48,
  Subhead 40, Body 32, BodyStrong 32, Caption 28, Eyebrow 28; nothing smaller than 28 px, about
  15 pt on a phone), spacing, corner clips, rules and motion times. No other UI script holds a
  color (a test checks the component scripts).
- **Theme:** `BrandTheme.get_theme()` builds it from Brand. `assets/ui/brand_theme.tres` is a
  generated copy for the editor: after editing Brand, run
  `godot --headless --path . res://tools/build_brand_theme.tscn` (a test fails if it's stale).
- **Panel shape:** `ClippedBox` (a StyleBox drawn from polygons): clipped corners, a thin inner
  stroke, a faint diagonal texture, an accent stripe, a top or bottom rule.
- **Components** (`scenes/ui/brand/*.tscn`, scripts in `scripts/ui/brand/`): primary and secondary
  button, tab bar, segmented toggle, list row, stat tile (numbers count up and shrink to fit),
  progress bar, card, header bar, banner (info / warning), popup, chip. States: normal, hover,
  focus, pressed, disabled. Motion (`BrandMotion`): 80-150 ms presses and swaps, count-ups, a red
  flash.
- **UI Gallery:** main menu -> UI Gallery (debug builds), or `Screens.UI_GALLERY`: every component
  in every state, the palette with contrast ratios, the type scale and the icons. The layout
  checker pages through it (shots `gallery_1` ... `gallery_N`).
- **Licenses:** Barlow and Barlow Condensed (SIL Open Font License 1.1, `assets/fonts/OFL-barlow*.txt`);
  icons from Google Material Symbols, Sharp, filled (Apache License 2.0,
  `assets/ui/icons/LICENSE-material-symbols.txt`; the path data is in `scripts/ui/brand/brand_icons.gd`).
  Both allow commercial use; keep the license files with the game.
- **Older screens, same look:** screens built with the older toolkit (`UiKit`, `CareerUi`,
  `UiIcons`, `StatBar`, `UiTokens`) keep their code but draw with the system: `UiTokens` has one
  palette taken from `Brand`, `UiKit` panels are `ClippedBox`es, its buttons and chips are the
  Brand ones, its text sizes snap to the type scale, and `UiIcons` names map onto the Brand icons.
  `UiKit.set_stage()` keeps the player's team color as an accent; the palette no longer changes
  by career stage.
- **Project theme:** `assets/ui/kicker_theme.tres` (the project default, used by the kick scene)
  holds the same fonts: Barlow Medium (body), Barlow Condensed Bold (`Display`, buttons),
  Barlow Condensed ExtraBold (`Banner`).
- **Sound and haptics hooks:** `UiKit.feedback(&"event")` plays the Sfx event (silent until a file
  exists) and pulses the phone. Events are listed under "Sound".

## Project layout

```
project.godot                 portrait 720x1280 base, canvas_items stretch, GL Compatibility
tuning/kick_tuning.tres       ← all tunables
tuning/leveling.tres          ← Career leveling: skill point costs, stage caps
tuning/postseason.tres        ← Career postseason: playoffs, bowls, titles
tuning/league.tres            ← Career leagues: sizes, schedule mix, playoff spots, game sim, drift
scenes/field_goal.tscn        kick scene (wires the pieces together), reused by every mode
scenes/screens/               main menu, practice, challenge, stats, achievements,
                              settings, career placeholder (thin scenes; UI built in code)
scenes/ball.tscn              football model + ground shadow
scenes/ui/hud.tscn            HUD layout
shaders/                      procedural field (turf), ball, crowd, sky
audio/                        optional sounds (see "Sound")
scripts/
  autoload/game_state.gd      GameState: THE service. kick_resolved event, session stats,
                              owns KickStats / AchievementTracker / GameSettings / SaveStore
  autoload/sfx.gd             Sfx: sound hook (plays on the "SFX" bus)
  autoload/haptics.gd         Haptics: phone vibration
  autoload/audio_manager.gd   AudioManager: situation music (cues in audio/music/), crossfades,
                              one-shot stingers, optional clutch-kick stems ("Music" bus)
  core/kick_report.gd         KickReport: the kick-result event payload
  systems/kick_stats.gd       all-time stats (streaks, longest FG, misses by type, best streak)
  systems/achievement_defs.gd achievements as data
  systems/achievement_tracker.gd  unlock state + condition checks
  systems/game_settings.gd    volumes, haptics, aim assist, graphics; creates SFX/Music buses
  systems/visual_quality.gd   graphics preset (Low / High) + one switch per visual feature
  visual/stage_look.gd        sun, shadows, sky, haze, grading, bloom for the active options
  visual/turf_shader.gd       field shader variants (grass / paint compiled in or out)
  visual/field_paint.gd       yard-number digits and end zone lettering textures
  visual/noise_texture.gd     shared tiling noise for the grass and sky
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
  config/kick_difficulty.gd   KickDifficulty: crooked swipes, distance, wind, contact vibration
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
  ui/perf_overlay.gd          PerfOverlay autoload: the frame-rate readout
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
new offer per tier a season, none as a freshman) say "could offer after the season". The screen lists
every four-year college (FBS / FCS / D2 tabs, `CareerRecords.all_schools`), most interested first.
**Recruiting points move after every game** (`Progression.credit_recruiting`): the season formula
(`recruiting_gain` without the coach's recommendation) times the share of the regular season played,
so a bad game can lower them; the season end adds the rest (coach, followers, postseason), and the
season total is what it was before. The Results screen shows each game's change.
Old career saves load and are upgraded (format versions and steps in
`scripts/career/career_save.gd`); content that was renamed or removed since a save was made is
dropped on load. Design decisions and values to playtest: `PLAYTEST.md`, "Career Mode".

| What | Where |
|---|---|
| Balance numbers (stat -> kick curves, caps, gains, seasons, game sim, scenario picks) | `tuning/career_tuning.tres` (defaults + docs in `scripts/career/career_tuning.gd`) |
| Scenarios (61 written: HS, college, pro, bye/offseason, trait-gated; plus the 150-scenario high school and 154-scenario college story graphs, all written, and the pro story graph: 828 PRO_* scenes in six eras by age, 100 written so far, the rest drafts the game skips) | `data/career/scenarios_*.json` (field reference: `_doc` in `scenarios_hs.json`; graphs: `scenarios_hs_graph.json`, COL_* in `scenarios_college.json`, PRO_* in `scenarios_pro.json`; pro design: `tools/pro_graph/PRO_DESIGN.md`) |
| Relationships: the cast (8 people + Team standing), roles, tiers, name lists | `data/career/people.json` (rules: `scripts/career/relationships.gd`; numbers: `career_tuning.tres` "Relationships") |
| Skill points, attribute upgrades (Skills screen) | `scripts/career/skill_points.gd` (earn amounts: `career_tuning.tres` "Skill Points"; cost curve: `tuning/leveling.tres`) |
| Leveling: overall rating, upgrade cost curve, per-stage caps (HS overall 55) | `tuning/leveling.tres` (defaults + docs in `scripts/config/leveling_config.gd`; rules: `scripts/career/leveling.gd`) |
| Postseason: rounds, bowl names, opponent strength, pressure, rewards (and the record-only fallback) | `tuning/postseason.tres` (defaults + docs in `scripts/config/postseason_config.gd`; rules: `scripts/career/postseason.gd`) |
| Leagues: division / conference games, playoff spots, wild cards, college title games / field / bowls, simulated games, strength drift, playoff picture week | `tuning/league.tres` (defaults + docs in `scripts/config/league_config.gd`; rules: `scripts/career/league.gd`). The teams, conferences and divisions are the team database's (`data/teams/`, see `DATA_FORMAT.md`) |
| Field goal / kickoff range, game-day range, range -> launch speed | `scripts/career/kick_range.gd`, `kick_profile.gd` (numbers: "Power -> Range", "Game Day Range") |
| Kick results -> Coach / Team, coach doubt ("too many misses") | `scripts/career/kick_trust.gd` (numbers: "Relationships", kick results + too many misses) |
| Perks (15): cost, prerequisites, effects | `data/career/perks.json` (rules: `scripts/career/perks.gd`) |
| Aging and maintenance (from 30) | `scripts/career/aging.gd` (numbers: `career_tuning.tres` "Aging") |
| Cold and snow games (late season) | `career_manager.gd` `_roll_cold()`, `kick_profile.gd` (numbers: "Weather") |
| Traits (8), game-day modifiers (19), stat descriptions | `data/career/traits.json`, `modifiers.json`, `stats_info.json` |
| Teams: 21 high schools (every career starts at Hoboken High School), 426 colleges (FBS / FCS / D2 = top / mid / small tier), 6 junior colleges (placeholders) and 32 pro clubs (AFC / NFC, 8 divisions) | `data/teams/` via the `TeamDatabase` autoload; format, import and validator: [DATA_FORMAT.md](DATA_FORMAT.md) |
| All-time records: fictional record books (league / conference / division / team, single season and career, 11 categories) and your kicker's records, NEW RECORD events (`CareerManager.records_set`) | `data/records/record_book.json` (made once by `tools/records/generate_records.py`, fixed seed), `scripts/records/record_book.gd` (`RecordBook`), saved events: `CareerData.records` |
| Season length: high school 10, college 12, pro 17 regular-season games (+1 bye). Per-game and per-week amounts tuned on 10 games are scaled so a season is worth the same (`season_scale` = 10 / games: skill points from games, practice and choices; Coach / Team trust per kick; win-loss and game-winner terms of the recruiting, draft and retention scores), "this season, after N attempts" thresholds grow with it (`season_attempts`), the season FG% weighs sqrt(games / 10) in the pro retention score (`season_pct_weight`, with `retention_fg_ref` 0.67), a bench can start in the last 8 weeks (`Bench.min_week`) and lasts the same share of the season (pro 2-3 weeks), and in-season choices' recruiting / draft / retention / GPA progress counts `season_scale` as much | `career_tuning.tres` "Seasons" (`games_for`, `season_scale`) |
| Names, play-by-play, player looks | `data/career/world.json`, `game_day.json` |
| Progression tables: college tiers, offers, draft rounds, tryouts, contracts | `data/career/progression.json` (weights in `career_tuning.tres`) |
| Recruiting / draft / retention / academics rules | `scripts/career/progression.gd` |
| Content word check (teen audience) | `data/career/content_rules.json` |
| Weekly loop / saves | `scripts/career/career_manager.gd`, `career_save.gd` (3 slots: `user://career_slot_N.json`) |
| Stats + traits -> kick | `scripts/career/kick_profile.gd` (`KickProfile.build()` -> `KickModifiers`) |
| Scenario engine | `scripts/career/scenario_engine.gd` |
| Hub → **Stats** (kicking record: Season view; Career view with HS / College / Pro / Career Total tabs, season rows and totals; distance, extra point, streak and misc sections; per-kick log `CareerData.kick_log`) and Hub → **Recruiting** (recruiting points, every college by level with its interest and offers) | `scripts/career/career_records.gd` (`CareerRecords`, read-only), screens `career_kicking.gd`, `career_recruiting_board.gd` |
| Hub → **Records** (Records Book: High School / College / Pro, then League / Conference / Division / Team with a team picker, Single Season / Career, ◀ category ▶; your entries highlighted and "Your best" with the gap to the next rank and to #1). New records, ties and lists entered show on the Results and Season screens | `scripts/ui/screens/career_records.gd`, row scene `scenes/ui/record_row.tscn`, `CareerUi.record_events` |

Goalposts and uniforms: `field_goal_game.gd` `set_look()` (called before the scene enters the
tree) picks the posts style per stage (high school plain H-frame and wide, college gooseneck
with school-colored padding/bands, pro polished and narrower; widths in `career_tuning.tres`
"Goalposts") and dresses both lines in the teams' colors. Without it the scene looks as before.

**Kick nerves (Career only, `scripts/career/kick_nerves.gd`):** when off-field life goes badly, a
crooked swipe costs more. One number, `straightness_penalty_mult` (1.0 = normal, clamped 1.0-2.0),
scales only the sideways miss of a crooked swipe (KickDifficulty's extra aim error and hook); a
straight swipe, power, distance and wind are never affected. It is 1 + low Energy + low Health /
Fun / Social + wrong decisions (choices with conduct bad / scandal or that set
`character_concerns` / `dismissed`; fades each week without one, faster with good choices) + a
slump (after 3 misses in a row or a bad stretch; out only after 5 straight makes in a row, each one
easing it a little; in a slump low Energy / life stats count 1.5x). The Game Day Outlook and the
kick's situation line say "Shaky" or "In a slump"; with `show_debug_readout` on, the kick shows the
breakdown, and the Career Debug screen's readout has the same line. Numbers: `career_tuning.tres`,
"Kick Nerves".

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

**Scenario popup and impact:** the setup reads in short beats (tap to continue) under a headline,
with the key phrase highlighted, a speaker strip for the person it features and a "Because you..."
line when an earlier choice brought the scene. Choice cards show a short label and stakes chips
(exact numbers only on safe choices). A scene's `"impact"` (minor / normal / major) decides whether
the full result shows or only a toast, and scales its stat swings; every choice is kept in the Hub's
"Recent choices". Rules: `ScenarioEngine` ("impact, results and callbacks"), `ScenarioText`; numbers:
`career_tuning.tres` "Scenario Impact"; for writers: `docs/story_note_scenario_impact.md`.

**Career state for scenarios:** "right now" values (`slump_now`, `benched_now`, `fg_streak`, `clubs`, ...),
game-set flags (`contract_year`, `re_signed`, `signed_new_club`, `released`), `{club}` / `{town}`,
`once_per_club`, and a season-end `dismissed` flag: `docs/story_note_career_state.md`.

**Overtime:** a tie after four quarters goes to overtime, with rules by stage: high school (the
Kansas plan from the 10, up to 4 rounds), college (from the 25; two-point tries from the third
overtime, so the kicker sits out; no ties) and pro (one 10-minute period, both teams get the ball
unless the first scores a touchdown, then sudden death; can end tied). Overtime kicks are high
pressure, and an overtime game winner counts like any game winner. Details: `PLAYTEST.md`,
"Overtime".

**Low Energy:** tired (Energy under 40) also raises injury chance; ending a week exhausted (under
20) brings a further temporary penalty and a "Running on empty" warning, and a second exhausted
week in a row costs a point of Power and Toughness (at most 3 a season, bought back with skill
points). Each week you pick Light, Normal or Hard practice on the Hub; three well-rested weeks in a
row pay a "Good habits" skill point. Details: `PLAYTEST.md`, "Low Energy".

**Retirement epilogue and Hall of Fame:** after the last snap, the closing scenes (scenarios with
`when: ["epilogue"]`), then a Hall of Fame vote for pro careers (longevity, accuracy, volume,
clutch, distance, fame and character, each shown with its points; tiers Ring of Honor, Finalist,
Hall of Fame, First ballot), then the career summary. Details: `PLAYTEST.md`, "Retirement epilogue".

**Thumb Drill:** Career -> Thumb Drill (calibration) plays 60 field goals (30 / 40 / 50 yards,
calm, a neutral kicker) and records each swipe, so the simulator's swipe model can be fitted to a
real thumb. Results: Copy on the last screen, also saved in `user://thumb_drill.json`. Details:
`PLAYTEST.md`, "Thumb Drill".

**Savings:** each pro season's salary, minus taxes and the agent's fee, goes into savings, and
scenario choices can add or take money ("money" field). Savings show on the Hub, on choice cards
and in the career summary, and scenarios can require a savings level. They're a score and a story
hook: money never buys skill points or performance. Details: `PLAYTEST.md`, "Savings".

**Stadiums:** each Career game is at the home team's stadium, with tiers by stage (high school
bleachers to a two-deck field, always at night; junior college bleachers; college one deck to a
three-deck bowl; pro stadiums up to a lit roof ring) and some college and pro games at night.
Challenges are at neutral sites. Practice keeps the original stadium. Preview them from Career
Debug ("STADIUM"). Details: `PLAYTEST.md`, "Stadiums".

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
**Music** (`AudioManager`, `scripts/autoload/audio_manager.gd`): one file per cue in
`audio/music/`, named after the cue (`audio/music/hs_game.ogg`, or .mp3/.wav):

| Cue | Kind | Plays |
|---|---|---|
| `menu` | loop | main menu and the other menus (falls back to the old `audio/music.ogg`) |
| `training` | loop | Career Hub and the week's screens (scenarios, outlook, skills, stats, results) |
| `hs_game` / `college_game` / `pro_game` | loop | a career game, by level (junior college = college) |
| `playoffs` | loop | any postseason game (playoffs, bowls, conference title games) |
| `clutch_kick` | loop | a GAME WINNER / TO TIE field goal or extra point, back to the game track after |
| `benched` | loop | a game you watch from the bench, and its Results |
| `draft_day` | loop | Draft Day (Free Agency keeps `training`) |
| `championship_win` | one-shot | the final whistle of a won title game or bowl |
| `win` / `loss` | one-shot | the final whistle of any other game |
| `season_end` | one-shot | Season Summary (not after a title) |

`AudioManager.play_music(cue)` crossfades and never restarts the cue that's playing. One-shots
play once, then the music before them comes back where it left off; a loop asked for during a
one-shot comes in when it ends. Game tracks resume where they were after a clutch kick.
`AudioManager.game_cue(stage, postseason)` / `career_game_cue(career)` pick the game track.
Screens pick their cue with `MenuScreen.music_cue()` (career screens: `training`).
A cue with no file logs one warning and the current music keeps playing; debug builds print
the cues still missing a file at startup.
**Stems (optional):** `audio/music/clutch_kick_drums.ogg`, `_bass`, `_lead`, `_choir` play in
sync with `clutch_kick.ogg` (itself optional once a stem exists);
`AudioManager.set_stem_level(&"drums", 0.0 .. 1.0)` brings a layer in or out. Add stem names
to `CUES` in `audio_manager.gd`.
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
