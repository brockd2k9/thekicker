class_name AdMobAdBackend
extends AdBackend
## Android + iOS through the Poing Studios AdMob plugin v5.1.0
## (github.com/poingstudios/godot-admob-plugin, MIT). Same GDScript API on both
## platforms; only the IDs differ (MonetizationConfig.ad_id()).
##
## The plugin's classes are looked up by name at runtime (_cls), so this
## project still opens, runs and exports without the plugin installed (desktop,
## Steam, the test runner). Every call below was read from the plugin source,
## platforms/godot_editor/addons/admob/gdscript/src/ at tag v5.1.0:
##   api/MobileAds.gd             MobileAds.initialize(OnInitializationCompleteListener),
##                                MobileAds.set_request_configuration(RequestConfiguration)
##   api/RewardedAdLoader.gd      RewardedAdLoader.new().load(unit_id, AdRequest, RewardedAdLoadCallback)
##   api/listeners/RewardedAdLoadCallback.gd  on_ad_loaded(RewardedAd), on_ad_failed_to_load(LoadAdError)
##   api/RewardedAd.gd            show(OnUserEarnedRewardListener), destroy(), full_screen_content_callback
##   api/listeners/OnUserEarnedRewardListener.gd  on_user_earned_reward(RewardedItem)
##   api/listeners/FullScreenContentCallback.gd   on_ad_showed_full_screen_content(),
##                                on_ad_dismissed_full_screen_content(),
##                                on_ad_failed_to_show_full_screen_content(AdError)
##   api/InterstitialAdLoader.gd / InterstitialAd.gd / InterstitialAdLoadCallback.gd (same shape, show())
##   ump/api/ConsentInformation.gd  update(ConsentRequestParameters, on_ok(), on_fail(FormError)),
##                                get_consent_status() (UNKNOWN, NOT_REQUIRED, REQUIRED, OBTAINED),
##                                get_is_consent_form_available(),
##                                get_privacy_options_requirement_status(), reset()
##   ump/api/UserMessagingPlatform.gd  consent_information (static), load_consent_form(on_ok(ConsentForm), on_fail(FormError)),
##                                show_privacy_options_form(on_dismissed(FormError))
##   ump/api/ConsentForm.gd       show(on_dismissed(FormError))
##   ump/core/ConsentRequestParameters.gd, ConsentDebugSettings.gd, DebugGeography.gd (DISABLED, EEA, NOT_EEA)
## Callbacks are Callables on the plugin's objects (not Godot signals) and are
## called deferred.
##
## Startup (Google's recommended order): consent info update -> consent form if
## required (on iOS this is where Google's IDFA explainer + the App Tracking
## Transparency prompt appear, when the IDFA message is set up in AdMob >
## Privacy & messaging) -> only if ads may be requested: MobileAds.initialize
## -> preload one rewarded + one interstitial.

const PLUGIN_SINGLETON := "PoingGodotAdMob"
## ConsentInformation.ConsentStatus values.
const CONSENT_UNKNOWN := 0
const CONSENT_NOT_REQUIRED := 1
const CONSENT_REQUIRED := 2
const CONSENT_OBTAINED := 3
## ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED
const PRIVACY_REQUIRED := 2

var platform := "android"  # "android" / "ios"
var use_test_ids := true
var rewarded_unit := ""
var interstitial_unit := ""

var _classes := {}
var _plugin_ok := false
var _consent_running := false
var _can_request_ads := false
var _initialized := false
var _privacy_required := false
var _status := "starting"

var _rewarded: Object = null
var _interstitial: Object = null
var _loading := {"rewarded": false, "interstitial": false}
var _fails := {"rewarded": 0, "interstitial": 0}

## Set by AdManager when the app goes to the background during a show (the ad
## covers the game), so the show timeout never cancels a real ad.
var focus_lost_during_show := false

signal _step
signal _show_step


func _init(m: Node = null, p: String = "android", test: bool = true) -> void:
	super(m)
	platform = p
	use_test_ids = test
	rewarded_unit = MonetizationConfig.ad_id(platform, "rewarded", use_test_ids)
	interstitial_unit = MonetizationConfig.ad_id(platform, "interstitial", use_test_ids)


func kind() -> String:
	return "admob"


func platform_has_ads() -> bool:
	return true


func start() -> void:
	_plugin_ok = Engine.has_singleton(PLUGIN_SINGLETON) and _cls("MobileAds") != null
	if not _plugin_ok:
		_status = "AdMob plugin not found in this build"
		_log("ERROR: the AdMob plugin is missing (singleton %s). Install Poing Studios AdMob v5.1.0, "
			% PLUGIN_SINGLETON + "enable it, and on Android turn on Use Gradle Build. No ads will load.")
		state_changed.emit()
		return
	_log("AdMob plugin %s, native %s, platform %s, %s IDs" % [
		_cls("MobileAds").get_version(), _cls("MobileAds").get_platform_version(), platform,
		"TEST" if use_test_ids else "REAL"])
	await _gather_consent()
	if _can_request_ads:
		await _init_sdk()


# --- consent (UMP) -------------------------------------------------------------------

func _gather_consent() -> void:
	if _consent_running:
		return
	_consent_running = true
	_status = "asking for consent"
	var info: Object = _cls("UserMessagingPlatform").consent_information
	var params: Object = _new("ConsentRequestParameters")
	params.tag_for_under_age_of_consent = MonetizationConfig.TAG_UNDER_AGE_OF_CONSENT
	var geo := MonetizationConfig.CONSENT_DEBUG_GEOGRAPHY
	if use_test_ids and geo != "":
		var dbg: Object = _new("ConsentDebugSettings")
		dbg.debug_geography = {"EEA": 1, "NOT_EEA": 2}.get(geo, 0)  # DebugGeography.Values
		dbg.test_device_hashed_ids.assign(MonetizationConfig.CONSENT_TEST_DEVICE_HASHED_IDS)
		params.consent_debug_settings = dbg
		_log("consent debug geography: %s" % geo)
	var r := {"done": false, "error": ""}
	info.update(params, func() -> void:
		r["done"] = true
		_step.emit(),
		func(err: Object) -> void:
			r["done"] = true
			r["error"] = _err_text(err)
			_step.emit())
	while not r["done"]:
		await _step
	if r["error"] != "":
		# Offline etc.: Google says to use the choice from the previous session.
		_log("consent info update failed (%s); using the previous session's consent" % r["error"])
	elif int(info.get_consent_status()) == CONSENT_REQUIRED and info.get_is_consent_form_available():
		await _show_consent_form()
	var status := int(info.get_consent_status())
	_can_request_ads = status == CONSENT_NOT_REQUIRED or status == CONSENT_OBTAINED
	_privacy_required = int(info.get_privacy_options_requirement_status()) == PRIVACY_REQUIRED
	_log("consent status %s, can request ads: %s, privacy options required: %s" % [
		["UNKNOWN", "NOT_REQUIRED", "REQUIRED", "OBTAINED"][clampi(status, 0, 3)],
		_can_request_ads, _privacy_required])
	if not _can_request_ads:
		_status = "no consent yet (retries when the app returns)"
	_consent_running = false
	state_changed.emit()


func _show_consent_form() -> void:
	var r := {"done": false, "form": null, "error": ""}
	_cls("UserMessagingPlatform").load_consent_form(func(form: Object) -> void:
		r["form"] = form
		r["done"] = true
		_step.emit(),
		func(err: Object) -> void:
			r["error"] = _err_text(err)
			r["done"] = true
			_step.emit())
	while not r["done"]:
		await _step
	if r["form"] == null:
		_log("consent form failed to load (%s)" % r["error"])
		return
	_log("showing the consent form")
	var s := {"done": false}
	r["form"].show(func(err: Object) -> void:
		if err != null:
			_log("consent form error: %s" % _err_text(err))
		s["done"] = true
		_step.emit())
	while not s["done"]:
		await _step


func privacy_options_required() -> bool:
	return _privacy_required


func show_privacy_options() -> void:
	if not _plugin_ok:
		return
	var s := {"done": false}
	_cls("UserMessagingPlatform").show_privacy_options_form(func(err: Object) -> void:
		if err != null:
			_log("privacy options form error: %s" % _err_text(err))
		s["done"] = true
		_step.emit())
	while not s["done"]:
		await _step
	var info: Object = _cls("UserMessagingPlatform").consent_information
	var status := int(info.get_consent_status())
	_can_request_ads = status == CONSENT_NOT_REQUIRED or status == CONSENT_OBTAINED
	_log("privacy options closed; can request ads: %s" % _can_request_ads)
	if _can_request_ads and not _initialized:
		await _init_sdk()
	state_changed.emit()


func reset_consent() -> void:
	if _plugin_ok:
		_cls("UserMessagingPlatform").consent_information.reset()
		_log("consent reset: the form shows again on the next launch")


func on_resume() -> void:
	if _plugin_ok and not _can_request_ads and not _consent_running:
		await _gather_consent()
		if _can_request_ads and not _initialized:
			await _init_sdk()
	elif _initialized:
		_load("rewarded")
		_load("interstitial")


# --- SDK init and loading -----------------------------------------------------------------

func _init_sdk() -> void:
	if _initialized:
		return
	_status = "initializing"
	if not MonetizationConfig.TEST_DEVICE_IDS.is_empty():
		var rc: Object = _new("RequestConfiguration")
		rc.test_device_ids.assign(MonetizationConfig.TEST_DEVICE_IDS)
		_cls("MobileAds").set_request_configuration(rc)
	var r := {"done": false}
	var listener: Object = _new("OnInitializationCompleteListener")
	listener.on_initialization_complete = func(_status_obj: Object) -> void:
		r["done"] = true
		_step.emit()
	_cls("MobileAds").initialize(listener)
	while not r["done"]:
		await _step
	_initialized = true
	_status = "ready"
	_log("SDK initialized")
	_load("rewarded")
	_load("interstitial")


func _load(which: String) -> void:
	var unit := rewarded_unit if which == "rewarded" else interstitial_unit
	if not _initialized or unit == "" or _loading[which]:
		return
	if (which == "rewarded" and _rewarded != null) or (which == "interstitial" and _interstitial != null):
		return
	_loading[which] = true
	_log("loading %s ad (%s)" % [which, unit])
	var cb: Object
	var loader: Object
	if which == "rewarded":
		cb = _new("RewardedAdLoadCallback")
		loader = _new("RewardedAdLoader")
	else:
		cb = _new("InterstitialAdLoadCallback")
		loader = _new("InterstitialAdLoader")
	cb.on_ad_loaded = func(ad: Object) -> void:
		_loading[which] = false
		_fails[which] = 0
		if which == "rewarded":
			_rewarded = ad
		else:
			_interstitial = ad
		_log("%s ad loaded" % which)
		state_changed.emit()
	cb.on_ad_failed_to_load = func(err: Object) -> void:
		_loading[which] = false
		_fails[which] += 1
		var wait := minf(MonetizationConfig.LOAD_RETRY_SECONDS * pow(2.0, _fails[which] - 1),
			MonetizationConfig.LOAD_RETRY_MAX_SECONDS)
		_log("%s ad failed to load (%s); retrying in %.0f s" % [which, _err_text(err), wait])
		state_changed.emit()
		if manager != null and manager.is_inside_tree():
			manager.get_tree().create_timer(wait, true, false, true).timeout.connect(_load.bind(which))
	loader.load(unit, _new("AdRequest"), cb)


func is_rewarded_ready() -> bool:
	return _rewarded != null


func is_interstitial_ready() -> bool:
	return _interstitial != null


# --- showing ------------------------------------------------------------------------------

func show_rewarded(placement: String) -> String:
	var ad := _rewarded
	if ad == null:
		return FAILED
	_rewarded = null
	var st := await _show(ad, placement, true)
	ad.destroy()
	_load("rewarded")
	if st["failed"]:
		return FAILED
	return REWARDED if st["earned"] else DISMISSED


func show_interstitial(placement: String) -> bool:
	var ad := _interstitial
	if ad == null:
		return false
	_interstitial = null
	var st := await _show(ad, placement, false)
	ad.destroy()
	_load("interstitial")
	return not st["failed"]


## Shows `ad` and waits until it is closed or fails. A rewarded ad's reward
## can arrive just after the close, so the close waits REWARD_GRACE_SECONDS.
func _show(ad: Object, placement: String, rewarded: bool) -> Dictionary:
	var st := {"showed": false, "earned": false, "failed": false, "done": false}
	focus_lost_during_show = false
	var fsc: Object = ad.full_screen_content_callback
	fsc.on_ad_showed_full_screen_content = func() -> void:
		st["showed"] = true
		_log("%s showing" % placement)
	fsc.on_ad_dismissed_full_screen_content = func() -> void:
		if not st["done"]:
			st["done"] = true
			_show_step.emit()
	fsc.on_ad_failed_to_show_full_screen_content = func(err: Object) -> void:
		_log("%s failed to show (%s)" % [placement, _err_text(err)])
		if not st["done"]:
			st["failed"] = true
			st["done"] = true
			_show_step.emit()
	if manager != null and manager.is_inside_tree():
		manager.get_tree().create_timer(MonetizationConfig.SHOW_START_TIMEOUT_SECONDS, true, false, true) \
			.timeout.connect(func() -> void:
				if not st["done"] and not st["showed"] and not focus_lost_during_show:
					_log("%s: no response from the SDK; giving up" % placement)
					st["failed"] = true
					st["done"] = true
					_show_step.emit())
	if rewarded:
		var listener: Object = _new("OnUserEarnedRewardListener")
		listener.on_user_earned_reward = func(item: Object) -> void:
			st["earned"] = true
			_log("%s reward earned%s" % [placement,
				" (%s x%d)" % [item.type, item.amount] if item != null else ""])
		ad.show(listener)
	else:
		ad.show()
	while not st["done"]:
		await _show_step
	if rewarded and not st["failed"] and not st["earned"] and manager != null and manager.is_inside_tree():
		await manager.get_tree().create_timer(MonetizationConfig.REWARD_GRACE_SECONDS, true, false, true).timeout
	return st


func status_text() -> String:
	return "admob %s (%s): %s, rewarded %s, interstitial %s" % [
		platform, "test" if use_test_ids else "REAL", _status,
		"ready" if _rewarded != null else ("loading" if _loading["rewarded"] else "none"),
		"ready" if _interstitial != null else ("loading" if _loading["interstitial"] else
			("no unit id" if interstitial_unit == "" else "none"))]


# --- plugin class lookup --------------------------------------------------------------------

## The plugin's global class `name` (a GDScript), or null when not installed.
func _cls(class_name_str: String) -> Variant:
	if _classes.has(class_name_str):
		return _classes[class_name_str]
	var script: Variant = null
	for c in ProjectSettings.get_global_class_list():
		if str(c["class"]) == class_name_str:
			script = load(str(c["path"]))
			break
	_classes[class_name_str] = script
	return script


func _new(class_name_str: String) -> Object:
	var s: Variant = _cls(class_name_str)
	return s.new() if s != null else null


static func _err_text(err: Object) -> String:
	if err == null:
		return "no details"
	if "message" in err:
		return "%s (code %s)" % [err.message, err.get("code") if "code" in err else err.get("error_code")]
	return str(err)
