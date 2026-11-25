extends "res://tests/test_case.gd"
## AdManager (Stage 1): backend choice, test / real ID safety, the rewarded
## and forced ad rules, and the saved ads_removed flag. Uses a fresh AdManager
## (not the autoload) with an instant MockAdBackend, so nothing waits.

const AD_MANAGER := preload("res://scripts/autoload/ad_manager.gd")


func _mock_manager() -> Node:
	var m: Node = AD_MANAGER.new()
	m.setup("mock", true, "desktop")
	var b: MockAdBackend = m.backend
	b.seconds = 0.0
	b.load_seconds = 0.0
	m.backend.start()
	return m


func test_pick_mode() -> void:
	eq(AD_MANAGER.pick_mode("", false, "Android", false), "admob", "Android -> AdMob")
	eq(AD_MANAGER.pick_mode("", false, "iOS", true), "admob", "iOS -> AdMob")
	eq(AD_MANAGER.pick_mode("", true, "Android", false), "none", "steam / no-ads build -> none")
	eq(AD_MANAGER.pick_mode("", false, "Windows", true), "mock", "desktop debug -> mock")
	eq(AD_MANAGER.pick_mode("", false, "Linux", false), "none", "desktop release -> none")
	eq(AD_MANAGER.pick_mode("mock", false, "Android", false), "mock", "override")


func test_test_mode_never_returns_real_ids() -> void:
	for plat in ["android", "ios"]:
		for k in ["app", "rewarded", "interstitial"]:
			check(MonetizationConfig.ad_id(plat, k, true).begins_with(MonetizationConfig.GOOGLE_TEST_PUBLISHER),
				"%s %s test id is Google's" % [plat, k])
	eq(AD_MANAGER.id_problem("android", true), "", "android test mode ok")
	eq(AD_MANAGER.id_problem("ios", true), "", "ios test mode ok")
	eq(MonetizationConfig.ad_id("android", "rewarded", true), "ca-app-pub-3940256099942544/5224354917", "android test rewarded")
	eq(MonetizationConfig.ad_id("ios", "rewarded", true), "ca-app-pub-3940256099942544/1712485313", "ios test rewarded")
	eq(MonetizationConfig.ad_id("android", "interstitial", true), "ca-app-pub-3940256099942544/1033173712", "android test interstitial")
	eq(MonetizationConfig.ad_id("ios", "interstitial", true), "ca-app-pub-3940256099942544/4411468910", "ios test interstitial")


func test_real_mode_rules() -> void:
	check(AD_MANAGER.id_problem("ios", false) != "", "iOS real mode refused while its IDs are empty")
	eq(AD_MANAGER.id_problem("android", false, MonetizationConfig.ANDROID_REAL_APP_ID), "",
		"android real mode ok with the matching manifest app id")
	check(AD_MANAGER.id_problem("android", false, MonetizationConfig.ANDROID_TEST_APP_ID) != "",
		"android real mode refused when the manifest still has the test app id")
	check(AD_MANAGER.id_problem("desktop", false) != "", "AdMob only on phones")
	var m: Node = AD_MANAGER.new()
	m.setup("admob", false, "ios")
	eq(m.mode, "blocked", "iOS real mode -> blocked")
	check(not m.is_rewarded_ready(), "blocked: nothing ready")
	check(m.platform_has_ads(), "blocked still counts as an ads platform (no free fallback)")
	m.free()


func test_rewarded_flow_emits_the_right_signal() -> void:
	var m := _mock_manager()
	var got := []
	m.ad_rewarded.connect(func(p: String) -> void: got.append("rewarded:" + p))
	m.ad_dismissed_without_reward.connect(func(p: String) -> void: got.append("dismissed:" + p))
	m.ad_failed.connect(func(p: String) -> void: got.append("failed:" + p))
	check(m.is_rewarded_ready(), "mock is ready")
	var ok: bool = await m.show_rewarded(m.REDO_KICK)
	check(ok, "reward earned")
	m.backend.next_result = AdBackend.DISMISSED
	ok = await m.show_rewarded(m.REDO_GAME)
	check(not ok, "closed early: no reward")
	m.backend.next_result = AdBackend.FAILED
	ok = await m.show_rewarded(m.PRACTICE_50)
	check(not ok, "failed: no reward")
	eq(got, ["rewarded:REDO_KICK", "dismissed:REDO_GAME", "failed:PRACTICE_50"], "one signal each")
	check(m.is_rewarded_ready(), "next ad preloaded")
	m.free()


func test_forced_placement_is_not_a_rewarded_ad() -> void:
	var m := _mock_manager()
	var failed := []
	m.ad_failed.connect(func(p: String) -> void: failed.append(p))
	var ok: bool = await m.show_rewarded(m.POST_GAME_FORCED)
	check(not ok and failed == [m.POST_GAME_FORCED], "rewarded refuses the forced placement")
	eq(m.backend.shown, 0, "no ad shown")
	var shown: bool = await m.show_interstitial(m.REDO_KICK)
	check(not shown, "interstitial refuses opt-in placements")
	m.free()


func test_forced_ad_rules() -> void:
	var m := _mock_manager()
	eq(m.forced_skip_reason(), "", "would show")
	var shown: bool = await m.show_interstitial(m.POST_GAME_FORCED)
	check(shown, "forced ad shown")
	check(m.forced_skip_reason() != "", "never twice back to back")
	m.last_ad_end_msec = Time.get_ticks_msec() - int((MonetizationConfig.MIN_SECONDS_BETWEEN_ADS + 1.0) * 1000.0)
	eq(m.forced_skip_reason(), "", "allowed again after the gap")
	await m.show_rewarded(m.REDO_KICK)
	check(m.forced_skip_reason().begins_with("an ad ended"), "no forced ad right after a rewarded one")
	m.last_ad_end_msec = -1
	m.ads_removed = true
	eq(m.forced_skip_reason(), "ads removed", "ad-free: no forced ads")
	check(m.is_rewarded_ready(), "ad-free: rewarded still offered (opt-in)")
	m.ads_removed = false
	m.backend.fill = false
	eq(m.forced_skip_reason(), "no forced ad loaded", "skips silently with nothing loaded")
	m.free()


func test_none_backend_shows_nothing() -> void:
	var m: Node = AD_MANAGER.new()
	m.setup("none", true, "desktop")
	check(not m.platform_has_ads(), "no ads platform")
	check(not m.is_rewarded_ready(), "never ready")
	check(m.forced_skip_reason() != "", "forced never triggers")
	var ok: bool = await m.show_rewarded(m.REDO_KICK)
	check(not ok, "no reward")
	m.free()


func test_ads_removed_round_trip() -> void:
	var m: Node = AD_MANAGER.new()
	m.from_dict({"ads_removed": true})
	check(m.ads_removed, "loaded")
	eq(m.to_dict(), {"ads_removed": true, "games_since_forced_ad": 0}, "saved")
	m.from_dict({"ads_removed": true, "games_since_forced_ad": 2.0})
	eq(m.games_since_forced_ad, 2, "forced-ad counter loaded (JSON float)")
	m.from_dict({"ads_removed": "yes"})
	check(not m.ads_removed, "wrong type falls back to false")
	m.from_dict({})
	check(not m.ads_removed, "missing -> false")
	m.free()


func test_main_save_v2_gets_monetization() -> void:
	var d: Dictionary = SaveStore.new()._migrate(fixture("main_save_v2.json"))
	eq(int(d["version"]), SaveStore.VERSION, "version")
	eq(d["monetization"], {}, "empty monetization section (nothing bought)")


func test_admob_without_the_plugin_is_safe() -> void:
	# This repo has no AdMob plugin installed: the backend must report "not
	# ready" (and log why) instead of crashing.
	var m: Node = AD_MANAGER.new()
	m.setup("admob", true, "android")
	eq(m.mode, "admob", "test IDs on android -> admob")
	m.backend.start()
	check(not m.is_rewarded_ready(), "nothing ready without the plugin")
	check("plugin not found" in m.backend.status_text(), "says why")
	var shown: bool = await m.show_interstitial(m.POST_GAME_FORCED)
	check(not shown, "no forced ad")
	m.free()
