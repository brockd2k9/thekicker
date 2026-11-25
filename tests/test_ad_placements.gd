extends "res://tests/test_case.gd"
## Stage 2: the Career Mode ad placements (AdManager's rules, the mock backend):
## kick retry / game replay offers and caps, ad-free free redos, the practice
## choice gate, the forced ad every N games, and the redo counters saved with
## the career's game checkpoint.

const AD_MANAGER := preload("res://scripts/autoload/ad_manager.gd")
const C := preload("res://scripts/monetization/monetization_config.gd")


func _mock(mode := "mock") -> Node:
	var m: Node = AD_MANAGER.new()
	m.setup(mode, true, "desktop")
	if mode == "mock":
		var b: MockAdBackend = m.backend
		b.seconds = 0.0
		b.load_seconds = 0.0
		m.backend.start()
	return m


func test_kick_retry_offer_and_cap() -> void:
	var m := _mock()
	var used := {}
	var o: Dictionary = m.redo_offer("kick", used)
	check(o["show"] and o["enabled"] and not o["free"], "offered with an ad")
	eq(o["button"], "Watch an Ad to Retry", "plain opt-in wording")
	eq(o["left"], C.MAX_REDOS_PER_GAME, "redos left")
	for i in C.MAX_REDOS_PER_GAME:
		check(await m.claim_redo("kick", used), "redo %d granted" % (i + 1))
	eq(int(used["total"]), C.MAX_REDOS_PER_GAME, "counted")
	check(not m.redo_offer("kick", used)["show"], "no more offers past the cap")
	check(not m.redo_offer("game", used)["show"], "the cap covers game replays too")
	eq(m.backend.shown, C.MAX_REDOS_PER_GAME, "one ad per redo")
	m.free()


func test_game_replay_cap() -> void:
	var m := _mock()
	var used := {}
	check(await m.claim_redo("game", used), "replay granted")
	check(not m.redo_offer("game", used)["show"], "one replay per game")
	check(m.redo_offer("kick", used)["show"] == (C.MAX_REDOS_PER_GAME > 1), "kick retries left in the budget")
	m.free()


func test_no_reward_no_redo() -> void:
	var m := _mock()
	var used := {}
	m.backend.next_result = AdBackend.DISMISSED
	check(not await m.claim_redo("kick", used), "closed early: no redo")
	eq(int(used.get("total", 0)), 0, "not counted")
	eq(m.last_rewarded_result, AdBackend.DISMISSED, "result recorded as dismissed")
	m.backend.next_result = AdBackend.FAILED
	check(not await m.claim_redo("kick", used), "failed: no redo")
	eq(m.last_rewarded_result, AdBackend.FAILED, "result recorded as failed")
	m.free()


func test_offer_disabled_when_no_ad() -> void:
	var m := _mock()
	m.backend.fill = false
	var o: Dictionary = m.redo_offer("kick", {})
	check(o["show"] and not o["enabled"], "shown but disabled")
	eq(o["note"], m.unavailable_text(), "says why")
	check(not await m.claim_redo("kick", {}), "can't be taken")
	m.free()


func test_ad_free_gets_free_redos() -> void:
	var m := _mock()
	m.ads_removed = true
	var used := {}
	var o: Dictionary = m.redo_offer("kick", used)
	check(o["free"] and o["enabled"], "free redo for ad-free buyers")
	check(not "Ad" in str(o["button"]), "no ad wording on a free redo")
	check(await m.claim_redo("kick", used), "granted")
	eq(m.backend.shown, 0, "without an ad")
	if C.FREE_REDOS_PER_GAME_AD_FREE < C.MAX_REDOS_PER_GAME:
		o = m.redo_offer("kick", used)
		check(o["show"] and not o["free"], "after the free ones: an ad, still optional")
	m.free()


func test_no_ads_platform_redos() -> void:
	var m := _mock("none")
	eq(m.redo_offer("kick", {})["show"], C.REDOS_ON_NO_ADS_PLATFORM == "free", "Steam follows REDOS_ON_NO_ADS_PLATFORM")
	m.free()


func test_practice_choice_gate() -> void:
	var m := _mock()
	var sid: String = C.PRACTICE_50_CHOICES.keys()[0]
	var idx := int(C.PRACTICE_50_CHOICES[sid])
	eq(m.choice_gate(sid, idx), "ad", "ad ready: watch an ad")
	eq(m.choice_gate(sid, idx + 1), "", "other choices are free")
	eq(m.choice_gate("some_other_scenario", idx), "", "other scenarios untouched")
	m.backend.fill = false
	eq(m.choice_gate(sid, idx), "free" if C.PRACTICE_50_FREE_IF_NO_AD else "unavailable", "no ad: fallback")
	m.backend.fill = true
	m.ads_removed = true
	eq(m.choice_gate(sid, idx), "free" if C.PRACTICE_50_FREE_FOR_AD_FREE else "ad", "ad-free rule")
	m.free()
	var n := _mock("none")
	eq(n.choice_gate(sid, idx), "free" if C.PRACTICE_50_FREE_ON_NO_ADS_PLATFORM else "unavailable", "Steam rule")
	n.free()


func test_practice_choice_points_at_real_content() -> void:
	for sid in C.PRACTICE_50_CHOICES:
		var s := CareerContent.scenario(str(sid))
		check(not s.is_empty(), "%s exists" % sid)
		var choices: Array = s.get("choices", [])
		var i := int(C.PRACTICE_50_CHOICES[sid])
		check(i < choices.size(), "%s choice %d exists" % [sid, i])
		if i < choices.size():
			check("50" in str(choices[i].get("label", "")), "%s choice %d is the 50-kick one" % [sid, i])


func test_forced_ad_every_n_games() -> void:
	var m := _mock()
	var shown := 0
	for g in C.FORCED_AD_EVERY_N_GAMES * 2:
		m.last_ad_end_msec = -1  # games are longer than the gap
		if await m.after_career_game({}):
			shown += 1
	eq(shown, 2, "one forced ad every %d games" % C.FORCED_AD_EVERY_N_GAMES)
	eq(m.games_since_forced_ad, 0, "counter reset after the ad")
	m.free()


func test_forced_ad_skipped_after_declined_redo_then_due() -> void:
	var m := _mock()
	m.games_since_forced_ad = C.FORCED_AD_EVERY_N_GAMES - 1
	var used := {}
	m.decline_redo("game", used)
	check(not await m.after_career_game(used), "never right after a declined redo offer")
	eq(m.games_since_forced_ad, C.FORCED_AD_EVERY_N_GAMES, "still due")
	m.last_ad_end_msec = -1
	check(await m.after_career_game({}), "shown after the next game")
	var kick_used := {}
	m.decline_redo("kick", kick_used)
	eq(kick_used.get("declined", false), C.FORCED_AD_SKIP_AFTER_ANY_DECLINE, "declined kick retry follows the config")
	m.free()


func test_forced_ad_never_back_to_back_or_ad_free() -> void:
	var m := _mock()
	m.games_since_forced_ad = C.FORCED_AD_EVERY_N_GAMES - 1
	await m.claim_redo("kick", {})  # a rewarded ad just ended
	check(not await m.after_career_game({}), "not right after another ad")
	m.last_ad_end_msec = -1
	m.ads_removed = true
	check(not await m.after_career_game({}), "ad-free: never")
	m.ads_removed = false
	m.backend.fill = false
	check(not await m.after_career_game({}), "none loaded: skipped silently")
	m.free()


func test_redo_counters_live_in_the_game_checkpoint() -> void:
	var c := CareerData.create("Test Kicker", CareerTuning.get_default())
	var cm := CareerManager.new(c)
	var used := cm.game_redos()
	used["total"] = 1
	used["kick"] = 1
	var seed := cm.start_game()
	eq(int(c.game_checkpoint["redos"]["total"]), 1, "start_game keeps the counters")
	eq(cm.start_game(), seed, "same seed on restart / replay")
	var back := CareerData.from_dict(JSON.parse_string(JSON.stringify(c.to_dict())))
	eq(int(back.game_checkpoint["redos"]["total"]), 1, "saved with the career")


func test_pending_loss_survives_a_save() -> void:
	var c := CareerData.create("Test Kicker", CareerTuning.get_default())
	var cm := CareerManager.new(c)
	cm.start_game()
	var summary := {"us": 10, "them": 13, "outcome": "L", "kicks": [{"yards": 42, "made": false}], "warmups": []}
	cm.set_pending_final(summary)
	var back := CareerManager.new(CareerData.from_dict(JSON.parse_string(JSON.stringify(c.to_dict()))))
	var f := back.pending_final()
	eq(f.get("outcome"), "L", "pending loss kept")
	check(f.get("them") is int and f["kicks"][0]["yards"] is int, "whole numbers back as ints")
	back.replay_game()
	check(back.pending_final().is_empty(), "replay clears it")
	check(back.data.game_checkpoint.has("seed"), "and keeps the game's seed")


func test_ad_screens_compile() -> void:
	# The screens with ad offers aren't opened by other tests: make sure they load.
	for p in ["res://scripts/ui/screens/career_game.gd", "res://scripts/ui/screens/career_scenario.gd",
			"res://scripts/ui/screens/settings_screen.gd", "res://scripts/daily/managed_ad_service.gd"]:
		var s: Variant = load(p)
		check(s is GDScript and (s as GDScript).can_instantiate(), "%s compiles" % p)
