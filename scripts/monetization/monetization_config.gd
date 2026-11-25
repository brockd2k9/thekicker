class_name MonetizationConfig
extends RefCounted
## Every monetization setting in ONE place: ad unit IDs, test/real switch, ad
## rules and (Stage 3) store products. No other script holds an ad ID, a price
## or an ad-frequency number. Game code never reads the IDs: it calls the
## AdManager autoload, which reads them from here.
##
## Switching to real ads (Android):
##   1. USE_TEST_IDS = false
##   2. Project Settings > admob/general/android/app_id = ANDROID_REAL_APP_ID
##      (the AdMob plugin writes that value into the AndroidManifest at export;
##      AdManager refuses real mode if it doesn't match).
## iOS real mode is refused until the IOS_REAL_* IDs below are filled in.
##
## Google's test IDs (developers.google.com/admob/android/test-ads and
## /admob/ios/test-ads; checked against Google's official sample apps,
## googleads/googleads-mobile-android-examples and -ios-examples).

# --- ads: test / real ------------------------------------------------------------

## true = only Google's test ad units are ever requested. Leave true until the
## store listing is live. Real IDs are never read while this is true.
const USE_TEST_IDS := true

## All of Google's test IDs share this publisher id. In test mode AdManager
## refuses any ID that doesn't start with it (so a real ID pasted into a test
## slot can't be requested by accident).
const GOOGLE_TEST_PUBLISHER := "ca-app-pub-3940256099942544"

const ANDROID_TEST_APP_ID := "ca-app-pub-3940256099942544~3347511713"
const ANDROID_TEST_REWARDED := "ca-app-pub-3940256099942544/5224354917"
const ANDROID_TEST_INTERSTITIAL := "ca-app-pub-3940256099942544/1033173712"

const IOS_TEST_APP_ID := "ca-app-pub-3940256099942544~1458002511"
const IOS_TEST_REWARDED := "ca-app-pub-3940256099942544/1712485313"
const IOS_TEST_INTERSTITIAL := "ca-app-pub-3940256099942544/4411468910"

const ANDROID_REAL_APP_ID := "ca-app-pub-3315717237019806~6775531912"
const ANDROID_REAL_REWARDED := "ca-app-pub-3315717237019806/5522159998"
## Ad unit "Interstitial_PostGame" (the forced post-game ad). An empty
## interstitial ID switches forced ads off in real mode (rewarded still work).
const ANDROID_REAL_INTERSTITIAL := "ca-app-pub-3315717237019806/4720214210"

## TODO: create the iOS app in AdMob. Real mode on iOS is refused while the
## app ID or rewarded unit is empty.
const IOS_REAL_APP_ID := ""
const IOS_REAL_REWARDED := ""
const IOS_REAL_INTERSTITIAL := ""

## Device IDs that get test ads even with real IDs (the SDK logs the id on
## first run: "Use RequestConfiguration.Builder().setTestDeviceIds(...)").
const TEST_DEVICE_IDS: Array[String] = []

# --- ads: which implementation ----------------------------------------------------

## "" = automatic: Android / iOS -> AdMob, feature tag "steam" -> None,
## other debug builds (editor, desktop) -> Mock, other release builds -> None.
## "mock" / "none" / "admob" force one (e.g. "mock" to test the flow on a phone).
const BACKEND_OVERRIDE := ""
## Force the no-ads build (same as exporting with the "steam" feature tag).
const NO_ADS_PLATFORM := false

## Mock ads (editor / desktop): the fake "Ad playing..." screen.
const MOCK_AD_SECONDS := 3.0
## How long the mock takes to "load" the next ad after one is shown.
const MOCK_LOAD_SECONDS := 1.0
## false = the mock behaves like no ad is available (offline / no fill).
const MOCK_FILL := true

# --- ads: consent (UMP) and privacy -------------------------------------------------

## Debug only (test IDs): pretend the device is in the EEA ("EEA"), outside it
## ("NOT_EEA") or use the real location (""), to see the consent form.
const CONSENT_DEBUG_GEOGRAPHY := ""
## Hashed device ids for the consent debug geography (the UMP SDK logs it).
const CONSENT_TEST_DEVICE_HASHED_IDS: Array[String] = []
## Tag users as under the age of consent (TFUA). false for a general-audience game.
const TAG_UNDER_AGE_OF_CONSENT := false

# --- ads: rules ---------------------------------------------------------------------

## Minimum seconds between the end of any ad and a forced (interstitial) ad,
## so two ads never play back to back.
const MIN_SECONDS_BETWEEN_ADS := 90.0
## A rewarded ad's reward can arrive a moment after the ad closes; wait this
## long before deciding the player didn't earn it.
const REWARD_GRACE_SECONDS := 0.6
## Give up on a show if the SDK reports nothing at all within this time (and
## the app never went to the background).
const SHOW_START_TIMEOUT_SECONDS := 10.0
## Retry a failed ad load after this many seconds, doubling each failure up to
## the max.
const LOAD_RETRY_SECONDS := 15.0
const LOAD_RETRY_MAX_SECONDS := 300.0

# --- Career Mode ad placements (Stage 2) -----------------------------------------------

## Switch each placement on / off.
const REDO_KICK_ENABLED := true
const REDO_GAME_ENABLED := true
const PRACTICE_50_ENABLED := true
const FORCED_ADS_ENABLED := true

## Redos (kick retries + game replays together) allowed per game, so a loss
## still feels like a loss. Counted per game and saved with it (closing the
## app doesn't reset them; a game replay keeps the count).
const MAX_REDOS_PER_GAME := 2
## Of those, game replays allowed per game.
const MAX_GAME_REPLAYS_PER_GAME := 1
## Which missed kicks can be retried: "fg" field goals, "pat" extra points.
const REDO_KICK_KINDS: Array[String] = ["fg", "pat"]
## Offer a replay after a tie too (false = losses only).
const REDO_GAME_ON_TIE := false
## Ad-free buyers: this many redos per game without an ad (counted inside
## MAX_REDOS_PER_GAME); after that they can still watch an ad.
const FREE_REDOS_PER_GAME_AD_FREE := 1
## Builds without ads (Steam): "none" = no redo offers, "free" = offered free.
const REDOS_ON_NO_ADS_PLATFORM := "none"

## The "stay for 50 kicks" practice choice: scenario id -> choice index that
## needs a rewarded ad (scenario text and effects are unchanged).
const PRACTICE_50_CHOICES := {"hs_extra_practice": 0}
## No ad available (not loaded, failed): let the player pick it for free, so
## a failed ad load never blocks progress. false = the choice is disabled.
const PRACTICE_50_FREE_IF_NO_AD := true
## Ad-free buyers pick it without an ad (false = they watch one like everyone).
const PRACTICE_50_FREE_FOR_AD_FREE := false
## Builds without ads (Steam): the choice is free.
const PRACTICE_50_FREE_ON_NO_ADS_PLATFORM := true

## Forced post-game ad: one every N career games (counted in the main save).
## Skipped silently when ad-free or none is loaded; it then stays due and is
## tried after the next game, so it's never more often than every N games.
const FORCED_AD_EVERY_N_GAMES := 3
## Never right after the player declined a redo offer: true = any offer
## declined during that game (a declined kick retry too); false = only the
## lost-game replay offer.
const FORCED_AD_SKIP_AFTER_ANY_DECLINE := true

# --- store (Stage 3) ---------------------------------------------------------------------

## Products: ids, kinds, pack sizes and reference prices in ONE place.
## "id" is the product id in Google Play Console / App Store Connect (both
## stores; "store_ids" can override it per platform). "price_usd" is only the
## fallback shown before the store returns its localized price, and the price
## to set in the consoles. Set "enabled" to sell a pack.
##
## Pricing (see the README, "Store"): players earn about 45 skill points a
## season (tools/career_sim_baseline.md) and an attribute point costs 2-3 SP
## at 40-50, 9 at 80, 15 near 100. So the 50-point pack is about one season
## of play for $4.99, a fair "skip a season's grind" price. Bigger packs give
## more points per dollar (+11%, +25%, +43%) on standard store price points.
const STORE_PRODUCTS: Array[Dictionary] = [
	{"id": "remove_ads", "kind": "non_consumable", "enabled": true,
		"title": "Remove Forced Ads", "price_usd": 9.99,
		"description": "No more ads after games. Optional ads (retries and replays) stay available "
			+ "if you want them, and you get 1 free retry or replay every game."},
	{"id": "skill_points_50", "kind": "consumable", "enabled": true, "skill_points": 50,
		"title": "50 Skill Points", "price_usd": 4.99,
		"description": "About one season of training, right away."},
	{"id": "skill_points_100", "kind": "consumable", "enabled": false, "skill_points": 100,
		"title": "100 Skill Points", "price_usd": 8.99,
		"description": "About two seasons of training."},
	{"id": "skill_points_250", "kind": "consumable", "enabled": false, "skill_points": 250,
		"title": "250 Skill Points", "price_usd": 19.99,
		"description": "About five seasons of training."},
	{"id": "skill_points_500", "kind": "consumable", "enabled": false, "skill_points": 500,
		"title": "500 Skill Points", "price_usd": 34.99,
		"description": "About ten seasons of training."},
]

## Debug builds only: purchases go through the test store (a confirmation,
## then the item, no payment) on every platform, phones included. Release
## builds never grant without payment, whatever this says.
const STORE_DEBUG_GRANTS := true
## "" = automatic; "mock" / "none" / "google_play" / "app_store" force one.
const STORE_BACKEND_OVERRIDE := ""
## Steam builds: the ad-free product is always hidden. The skill point store:
## "off" (hidden) or "steam" (Steam's own in-game purchases, not built yet:
## stays hidden until a Steam store backend exists).
const STEAM_SKILL_POINT_STORE := "off"
## Show "Restore Purchases" on Android too (iOS always shows it: required).
const RESTORE_BUTTON_ON_ANDROID := true

# --- ads: debug ---------------------------------------------------------------------

## Print "[AdManager] ..." lines (always on in debug builds).
const DEBUG_LOGGING := true
## Corner badge showing the ad mode (MOCK / TEST / REAL). Shown in debug builds
## and whenever test IDs are on; never in a release build with real ads.
const SHOW_MODE_BADGE := true


# --- helpers (no numbers below) -------------------------------------------------------

## platform: "android" / "ios". kind: "app" / "rewarded" / "interstitial".
## Real IDs are only returned when use_test is false.
static func ad_id(platform: String, kind: String, use_test: bool) -> String:
	var table := {
		"android": {
			"app": [ANDROID_TEST_APP_ID, ANDROID_REAL_APP_ID],
			"rewarded": [ANDROID_TEST_REWARDED, ANDROID_REAL_REWARDED],
			"interstitial": [ANDROID_TEST_INTERSTITIAL, ANDROID_REAL_INTERSTITIAL],
		},
		"ios": {
			"app": [IOS_TEST_APP_ID, IOS_REAL_APP_ID],
			"rewarded": [IOS_TEST_REWARDED, IOS_REAL_REWARDED],
			"interstitial": [IOS_TEST_INTERSTITIAL, IOS_REAL_INTERSTITIAL],
		},
	}
	var row: Array = table.get(platform, {}).get(kind, ["", ""])
	return str(row[0] if use_test else row[1])
