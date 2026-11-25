extends Node
## Autoload "AdManager": the ONLY place the game touches ads. Game code calls
##   AdManager.is_rewarded_ready()            enable / disable an ad button
##   await AdManager.show_rewarded(placement) opt-in rewarded ad (true = reward earned)
##   await AdManager.show_interstitial(placement)  the forced post-game ad
## and listens to the signals below. It never calls an SDK; the backend does
## (scripts/monetization/ads/: AdMob on Android + iOS, Mock in the editor /
## desktop debug, None on Steam / desktop release). Swapping or adding a
## network means a new AdBackend and a line in pick_mode(): no game code changes.
##
## Rules applied here, for every placement (Daily Challenge included):
##   - rewarded ads only for the opt-in placements (REWARDED_PLACEMENTS);
##     ad_rewarded fires ONLY when the SDK says the reward was earned
##   - forced ads only for FORCED_PLACEMENTS, never when ads_removed, never
##     within MIN_SECONDS_BETWEEN_ADS of the last ad, never while one shows,
##     skipped silently when none is loaded
##   - nothing is requested before the consent flow allows it (AdMob backend)
##   - real ad IDs are never used while USE_TEST_IDS is on; real mode is
##     refused when the platform's real IDs are missing (iOS for now)
## All numbers and IDs: MonetizationConfig (scripts/monetization/monetization_config.gd).
## Saved state ({"ads_removed": bool, "games_since_forced_ad": int}) lives in
## the main save under "monetization" (GameState loads / saves it through
## from_dict / to_dict). Career placements (redo offers, the practice choice,
## the forced ad every N games) are decided here too: see "Career placements".

## The player earned the reward of a rewarded ad.
signal ad_rewarded(placement: String)
## No ad could be shown (none loaded, failed to show, busy, wrong placement).
signal ad_failed(placement: String)
## The ad was shown but closed before the reward was earned.
signal ad_dismissed_without_reward(placement: String)
## A forced (interstitial) ad finished or was skipped (shown = false).
signal interstitial_finished(placement: String, shown: bool)
## Readiness, mode or ads_removed changed: refresh ad buttons.
signal ads_changed

const REDO_KICK := "REDO_KICK"
const REDO_GAME := "REDO_GAME"
const PRACTICE_50 := "PRACTICE_50"
const POST_GAME_FORCED := "POST_GAME_FORCED"
const DAILY_RETRY := "DAILY_RETRY"
const STREAK_SAVER := "STREAK_SAVER"
## Opt-in placements: the only ones show_rewarded() accepts.
const REWARDED_PLACEMENTS := [REDO_KICK, REDO_GAME, PRACTICE_50, DAILY_RETRY, STREAK_SAVER]
## Forced placements: the only ones show_interstitial() accepts.
const FORCED_PLACEMENTS := [POST_GAME_FORCED]

const LOG_PREFIX := "[AdManager] "

## "admob" / "mock" / "none" / "blocked" (real mode refused: see blocked_reason).
var mode := "none"
var use_test_ids := MonetizationConfig.USE_TEST_IDS
## "android" / "ios" / "desktop".
var platform := "desktop"
var blocked_reason := ""
## Bought "Remove forced ads" (Stage 3). Forced ads never show while true;
## rewarded ads stay available as an opt-in.
var ads_removed := false
var backend: AdBackend = NoneAdBackend.new()
## How the last show_rewarded() ended: AdBackend.REWARDED / DISMISSED / FAILED.
var last_rewarded_result := ""
## Career games finished since the last forced ad (saved).
var games_since_forced_ad := 0
## Time.get_ticks_msec() when the last ad closed (-1 = none yet).
var last_ad_end_msec := -1

var _showing := false
var _badge_layer: CanvasLayer
var _badge: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var os_name := OS.get_name()
	var m := pick_mode(MonetizationConfig.BACKEND_OVERRIDE,
		OS.has_feature("steam") or MonetizationConfig.NO_ADS_PLATFORM, os_name, OS.is_debug_build())
	setup(m, MonetizationConfig.USE_TEST_IDS, {"Android": "android", "iOS": "ios"}.get(os_name, "desktop"))
	_build_badge()
	_start_backend.call_deferred()


## Picks the implementation. override: MonetizationConfig.BACKEND_OVERRIDE.
static func pick_mode(override: String, no_ads_platform: bool, os_name: String, debug: bool) -> String:
	if override in ["mock", "none", "admob"]:
		return override
	if no_ads_platform:
		return "none"
	if os_name == "Android" or os_name == "iOS":
		return "admob"
	return "mock" if debug else "none"


## Why AdMob may not run with these IDs ("" = fine). manifest_app_id: the
## plugin's Project Setting admob/general/<platform>/app_id ("" = unknown).
static func id_problem(plat: String, test: bool, manifest_app_id: String = "") -> String:
	if plat != "android" and plat != "ios":
		return "AdMob only runs on Android and iOS"
	var test_pub := MonetizationConfig.GOOGLE_TEST_PUBLISHER
	if test:
		for k in ["app", "rewarded", "interstitial"]:
			if not MonetizationConfig.ad_id(plat, k, true).begins_with(test_pub + "~") \
					and not MonetizationConfig.ad_id(plat, k, true).begins_with(test_pub + "/"):
				return "the %s %s test ID is not one of Google's test IDs" % [plat, k]
		return ""
	var app := MonetizationConfig.ad_id(plat, "app", false)
	var rewarded := MonetizationConfig.ad_id(plat, "rewarded", false)
	if app == "" or rewarded == "":
		return "real mode refused: the %s real app ID / rewarded unit are not filled in" % plat \
			+ " (MonetizationConfig)"
	if app.begins_with(test_pub) or rewarded.begins_with(test_pub):
		return "real mode refused: a %s real ID slot holds a Google test ID" % plat
	if manifest_app_id != "" and manifest_app_id != app:
		return "real mode refused: Project Settings admob/general/%s/app_id is %s, expected %s" % [
			plat, manifest_app_id, app]
	return ""


## Builds the backend (also used by tests, which then call backend methods
## synchronously with a MockAdBackend whose seconds = 0).
func setup(m: String, test: bool, plat: String) -> void:
	use_test_ids = test
	platform = plat
	blocked_reason = ""
	match m:
		"admob":
			var setting := "admob/general/%s/app_id" % plat
			var manifest := str(ProjectSettings.get_setting(setting, "")) if ProjectSettings.has_setting(setting) else ""
			blocked_reason = id_problem(plat, test, manifest)
			if blocked_reason != "":
				push_error(LOG_PREFIX + blocked_reason + ". No ads will be requested.")
				backend = NoneAdBackend.new(self, blocked_reason, true)
				mode = "blocked"
			else:
				if test and manifest != "" and manifest != MonetizationConfig.ad_id(plat, "app", true):
					debug_log("note: Project Settings %s is %s (not the test app ID). Allowed with test units." % [setting, manifest])
				backend = AdMobAdBackend.new(self, plat, test)
				mode = "admob"
		"mock":
			backend = MockAdBackend.new(self)
			mode = "mock"
		_:
			backend = NoneAdBackend.new(self, "no ads on this build")
			mode = "none"
	backend.state_changed.connect(_on_backend_changed)
	debug_log("mode %s, %s IDs, platform %s" % [mode.to_upper(), "TEST" if use_test_ids else "REAL", platform])


func _start_backend() -> void:
	await _async_backend().start()
	_on_backend_changed()


# --- the API game code uses ----------------------------------------------------------------

## False on builds that never show ads (Steam): hide every ad offer.
func platform_has_ads() -> bool:
	return backend.platform_has_ads()


## A rewarded ad can be shown right now (for enabling ad buttons).
func is_rewarded_ready() -> bool:
	return not _showing and backend.is_rewarded_ready()


## Shows an opt-in rewarded ad. Emits exactly one of ad_rewarded /
## ad_dismissed_without_reward / ad_failed, and also returns (await it) true
## only if the reward was earned.
func show_rewarded(placement: String) -> bool:
	if not placement in REWARDED_PLACEMENTS:
		push_error(LOG_PREFIX + "show_rewarded(%s): not an opt-in placement" % placement)
		last_rewarded_result = AdBackend.FAILED
		ad_failed.emit(placement)
		return false
	if not is_rewarded_ready():
		debug_log("%s: no rewarded ad ready (%s)" % [placement, backend.status_text()])
		last_rewarded_result = AdBackend.FAILED
		ad_failed.emit(placement)
		return false
	debug_log("%s: showing rewarded ad" % placement)
	_begin_show()
	var result: String = await _async_backend().show_rewarded(placement)
	_end_show()
	last_rewarded_result = result if result in [AdBackend.REWARDED, AdBackend.DISMISSED] else AdBackend.FAILED
	if result == AdBackend.REWARDED:
		debug_log("%s: reward earned" % placement)
		ad_rewarded.emit(placement)
		return true
	if result == AdBackend.DISMISSED:
		debug_log("%s: closed without the reward" % placement)
		ad_dismissed_without_reward.emit(placement)
	else:
		debug_log("%s: failed to show" % placement)
		ad_failed.emit(placement)
	return false


## Why a forced ad would be skipped right now ("" = it would show).
func forced_skip_reason(placement: String = POST_GAME_FORCED) -> String:
	if not placement in FORCED_PLACEMENTS:
		return "not a forced placement"
	if ads_removed:
		return "ads removed"
	if not platform_has_ads():
		return "no ads on this build"
	if _showing:
		return "another ad is showing"
	if last_ad_end_msec >= 0 and seconds_since_last_ad() < MonetizationConfig.MIN_SECONDS_BETWEEN_ADS:
		return "an ad ended %.0f s ago" % seconds_since_last_ad()
	if not backend.is_interstitial_ready():
		return "no forced ad loaded"
	return ""


## Shows the forced (interstitial) ad if the rules allow it; otherwise skips
## silently. Returns (await it) true if one was shown.
func show_interstitial(placement: String) -> bool:
	var why := forced_skip_reason(placement)
	if why != "":
		debug_log("%s: skipped (%s)" % [placement, why])
		interstitial_finished.emit(placement, false)
		return false
	debug_log("%s: showing forced ad" % placement)
	_begin_show()
	var shown: bool = await _async_backend().show_interstitial(placement)
	_end_show()
	interstitial_finished.emit(placement, shown)
	return shown


func seconds_since_last_ad() -> float:
	if last_ad_end_msec < 0:
		return INF
	return (Time.get_ticks_msec() - last_ad_end_msec) / 1000.0


func unavailable_text() -> String:
	return "No ad is available right now. Check your connection and try again in a moment."


## Google's privacy options must be reachable from Settings when required.
func privacy_options_required() -> bool:
	return backend.privacy_options_required()


func show_privacy_options() -> void:
	await _async_backend().show_privacy_options()


# --- Career placements (Stage 2) --------------------------------------------------------------
# The game keeps one game's redo counters in a Dictionary it saves with the
# game (CareerManager.game_redos()): {"total", "kick", "game", "free",
# "declined"}. These functions read and update it; the game never counts.

## Should a redo be offered, and how. kind: "kick" / "game". Returns
## {"show": offer at all, "free": no ad needed, "enabled": can be taken now,
##  "left": redos left this game, "button": button text, "note": line under it}.
func redo_offer(kind: String, used: Dictionary) -> Dictionary:
	var out := {"show": false, "free": false, "enabled": false, "left": 0, "button": "", "note": ""}
	var on := MonetizationConfig.REDO_KICK_ENABLED if kind == "kick" else MonetizationConfig.REDO_GAME_ENABLED
	if not on:
		return out
	var total := int(used.get("total", 0))
	var left := MonetizationConfig.MAX_REDOS_PER_GAME - total
	if left <= 0:
		return out
	if kind == "game" and int(used.get("game", 0)) >= MonetizationConfig.MAX_GAME_REPLAYS_PER_GAME:
		return out
	var what := "retry this kick" if kind == "kick" else "replay this game"
	out["show"] = true
	out["left"] = left
	if not platform_has_ads():
		if MonetizationConfig.REDOS_ON_NO_ADS_PLATFORM != "free":
			out["show"] = false
			return out
		out["free"] = true
	elif ads_removed and int(used.get("free", 0)) < MonetizationConfig.FREE_REDOS_PER_GAME_AD_FREE:
		out["free"] = true
	if out["free"]:
		out["enabled"] = true
		out["button"] = what.capitalize()
		if platform_has_ads():
			out["note"] = "Ad-free: no ad needed (%d free left this game)." % (
				MonetizationConfig.FREE_REDOS_PER_GAME_AD_FREE - int(used.get("free", 0)))
		else:
			out["note"] = "%d left this game." % left
		return out
	out["enabled"] = is_rewarded_ready()
	# Short enough to show in full on a phone button; the offer's text says
	# what is retried / replayed.
	out["button"] = "Watch an Ad to Retry" if kind == "kick" else "Watch an Ad to Replay"
	out["note"] = ("Optional. %d left this game." % left) if out["enabled"] else unavailable_text()
	return out


## Takes the redo the player chose: free when redo_offer() said so, else a
## rewarded ad. Returns (await it) true if the redo happens; then `used` is
## updated and the game must save it.
func claim_redo(kind: String, used: Dictionary) -> bool:
	var offer := redo_offer(kind, used)
	if not offer["show"]:
		return false
	if not offer["free"]:
		if not await show_rewarded(REDO_KICK if kind == "kick" else REDO_GAME):
			return false
	else:
		used["free"] = int(used.get("free", 0)) + 1
		debug_log("%s: free redo (%s)" % [REDO_KICK if kind == "kick" else REDO_GAME,
			"ad-free" if platform_has_ads() else "no-ads build"])
	used["total"] = int(used.get("total", 0)) + 1
	used[kind] = int(used.get(kind, 0)) + 1
	return true


## The player turned down a redo offer they could have taken.
func decline_redo(kind: String, used: Dictionary) -> void:
	if kind == "game" or MonetizationConfig.FORCED_AD_SKIP_AFTER_ANY_DECLINE:
		used["declined"] = true
	debug_log("redo offer declined (%s)" % kind)


## How a scenario choice is gated by an ad: "" (not gated), "ad" (watch an
## ad to pick it), "free" (gated choice, free right now: no ad / ad-free /
## no-ads build), "unavailable" (no ad and no free fallback).
func choice_gate(scenario_id: String, index: int) -> String:
	if not MonetizationConfig.PRACTICE_50_ENABLED:
		return ""
	if int(MonetizationConfig.PRACTICE_50_CHOICES.get(scenario_id, -1)) != index:
		return ""
	if not platform_has_ads():
		return "free" if MonetizationConfig.PRACTICE_50_FREE_ON_NO_ADS_PLATFORM else "unavailable"
	if ads_removed and MonetizationConfig.PRACTICE_50_FREE_FOR_AD_FREE:
		return "free"
	if is_rewarded_ready():
		return "ad"
	return "free" if MonetizationConfig.PRACTICE_50_FREE_IF_NO_AD else "unavailable"


## A career game is over (call when leaving its result screen). Counts it and
## shows the forced ad when one is due and the rules allow. `used`: that
## game's redo counters. Returns (await it) true if an ad was shown.
func after_career_game(used: Dictionary) -> bool:
	games_since_forced_ad += 1
	_save()
	if not MonetizationConfig.FORCED_ADS_ENABLED:
		return false
	if games_since_forced_ad < MonetizationConfig.FORCED_AD_EVERY_N_GAMES:
		debug_log("game counted (%d of %d before a forced ad)" % [games_since_forced_ad,
			MonetizationConfig.FORCED_AD_EVERY_N_GAMES])
		return false
	if bool(used.get("declined", false)):
		debug_log("%s: skipped (a redo offer was just declined); due after the next game" % POST_GAME_FORCED)
		interstitial_finished.emit(POST_GAME_FORCED, false)
		return false
	var shown: bool = await show_interstitial(POST_GAME_FORCED)
	if shown:
		games_since_forced_ad = 0
		_save()
	return shown


# --- ad-free flag (saved) ---------------------------------------------------------------------

func set_ads_removed(on: bool) -> void:
	if ads_removed == on:
		return
	ads_removed = on
	debug_log("ads_removed = %s (forced ads %s)" % [on, "off" if on else "on"])
	_refresh_badge()
	ads_changed.emit()
	_save()


func to_dict() -> Dictionary:
	return {"ads_removed": ads_removed, "games_since_forced_ad": games_since_forced_ad}


func from_dict(d: Dictionary) -> void:
	ads_removed = bool(d.get("ads_removed", false)) if d.get("ads_removed") is bool else false
	var g: Variant = d.get("games_since_forced_ad", 0)
	games_since_forced_ad = maxi(int(g), 0) if (g is int or g is float) else 0
	_refresh_badge()
	ads_changed.emit()


# --- internals ---

func _save() -> void:
	var gs := get_node_or_null("/root/GameState") if is_inside_tree() else null
	if gs != null:
		gs.save_game()


## The backend as a plain Object, for every call that may `await`. Godot 4.7.2
## crashes (corrupted locals after the await) when a coroutine is called through
## a variable typed as the base class whose own version of the method doesn't
## await (AdBackend's defaults don't). An untyped call is dispatched at runtime
## and is safe. Checked in a minimal project: typed call 5/5 crashes, untyped 0/5.
func _async_backend() -> Object:
	return backend


func debug_log(msg: String) -> void:
	if MonetizationConfig.DEBUG_LOGGING or OS.is_debug_build():
		print(LOG_PREFIX + msg)


func status_text() -> String:
	return "%s · %s IDs · %s%s" % [mode.to_upper(), "TEST" if use_test_ids else "REAL",
		blocked_reason if blocked_reason != "" else backend.status_text(),
		" · ads removed" if ads_removed else ""]


var _was_muted := false


func _begin_show() -> void:
	_showing = true
	_was_muted = AudioServer.is_bus_mute(0)
	AudioServer.set_bus_mute(0, true)
	ads_changed.emit()


func _end_show() -> void:
	_showing = false
	AudioServer.set_bus_mute(0, _was_muted)
	last_ad_end_msec = Time.get_ticks_msec()
	ads_changed.emit()


func _on_backend_changed() -> void:
	_refresh_badge()
	ads_changed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if _showing and backend is AdMobAdBackend:
			(backend as AdMobAdBackend).focus_lost_during_show = true
	elif what == NOTIFICATION_APPLICATION_RESUMED and not _showing:
		_async_backend().on_resume()


## Small top-right badge: MOCK / TEST / REAL / BLOCKED. Debug builds, and any
## build still on test IDs. Never shown in a release build with real ads.
func _build_badge() -> void:
	_badge_layer = CanvasLayer.new()
	_badge_layer.layer = 111
	add_child(_badge_layer)
	_badge = Label.new()
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.add_theme_font_size_override("font_size", 20)
	_badge.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_badge.add_theme_constant_override("outline_size", 6)
	# Top-right: clear of the FPS readout (bottom-left) and the bottom buttons.
	_badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_badge.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_badge.position += Vector2(-10, 6)
	_badge_layer.add_child(_badge)
	_refresh_badge()


func _refresh_badge() -> void:
	if _badge == null:
		return
	var debug := OS.is_debug_build()
	var visible_now := MonetizationConfig.SHOW_MODE_BADGE and (debug or use_test_ids) \
		and (mode != "none" or debug)
	_badge_layer.visible = visible_now
	var text := ""
	var color := Color(1, 1, 1, 0.92)
	match mode:
		"mock":
			text = "ADS: MOCK"
		"admob":
			text = "ADS: TEST IDS" if use_test_ids else "ADS: REAL"
			if not use_test_ids:
				color = Brand.RED_HOT
		"blocked":
			text = "ADS: BLOCKED (see log)"
			color = Brand.RED_HOT
		_:
			text = "ADS: OFF"
	if ads_removed:
		text += " · AD-FREE"
	_badge.text = text
	_badge.add_theme_color_override("font_color", color)
