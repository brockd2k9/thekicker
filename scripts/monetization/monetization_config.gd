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
## TODO: create an Interstitial ad unit in AdMob for the post-game ad. While
## empty, real mode runs rewarded ads only (forced ads are switched off).
const ANDROID_REAL_INTERSTITIAL := ""

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
