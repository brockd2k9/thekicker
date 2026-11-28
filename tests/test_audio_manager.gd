extends "res://tests/test_case.gd"
## AudioManager: the cue table, picking the game track, crossfades that don't
## restart a playing cue, one-shots returning to the music before them, and a
## missing file keeping the current music. Streams are generated in memory (no
## files needed); a one-shot ending is simulated with _on_finished().

const AM := preload("res://scripts/autoload/audio_manager.gd")


func _manager() -> Node:
	var m: Node = AM.new()
	# Players only play inside the tree. The root is busy while the test
	# runner readies, so the manager goes under the runner (the last child).
	(Engine.get_main_loop() as SceneTree).root.get_children().back().add_child(m)
	m._cache.clear()
	return m


## Half a second of silence, standing in for a music file.
static func _tone() -> AudioStreamWAV:
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = 22050
	var data := PackedByteArray()
	data.resize(22050)
	s.data = data
	return s


func _give(m: Node, cues: Array) -> void:
	for c in cues:
		m._cache[c] = _tone()


func test_every_cue_is_listed() -> void:
	for c in [&"menu", &"training", &"hs_game", &"college_game", &"pro_game", &"playoffs",
			&"clutch_kick", &"championship_win", &"benched", &"draft_day", &"win", &"loss", &"season_end"]:
		check(AM.CUES.has(c), "cue %s" % c)
	for c in [&"championship_win", &"win", &"loss", &"season_end"]:
		check(not bool(AM.CUES[c]["loop"]), "%s is a one-shot" % c)
	for c in [&"menu", &"training", &"hs_game", &"playoffs", &"clutch_kick", &"benched", &"draft_day"]:
		check(bool(AM.CUES[c]["loop"]), "%s loops" % c)


func test_game_cue() -> void:
	eq(AM.game_cue(CareerData.STAGE_HIGH_SCHOOL, false), &"hs_game", "high school")
	eq(AM.game_cue(CareerData.STAGE_COLLEGE, false), &"college_game", "college")
	eq(AM.game_cue(CareerData.STAGE_JUCO, false), &"college_game", "junior college")
	eq(AM.game_cue(CareerData.STAGE_PRO, false), &"pro_game", "pro")
	for st in [CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_COLLEGE, CareerData.STAGE_PRO]:
		eq(AM.game_cue(st, true), &"playoffs", "postseason %s" % st)


func test_career_game_cue() -> void:
	var t := CareerTuning.get_default()
	var c := CareerData.create("Music Test", t)
	c.team = Progression.team_from(TeamDatabase.high_schools()[0], CareerData.STAGE_HIGH_SCHOOL)
	var m := CareerManager.new(c, t)
	m._start_season(false)
	c.week = 1
	eq(AM.career_game_cue(m), &"hs_game", "week 1, high school")
	c.schedule.append({"type": "playoff", "postseason": "playoff", "round": 1, "round_name": "Final",
		"final": true, "opponent": {}, "result": null})
	c.week = c.schedule.size()
	eq(AM.career_game_cue(m), &"playoffs", "a playoff week")


func test_clutch_call() -> void:
	check(AM.is_clutch_call({"kind": "fg", "label": "0:12 4th - DOWN 2 - GAME WINNER"}), "game winner")
	check(AM.is_clutch_call({"kind": "pat", "label": "0:00 4th - DOWN 1 - TO TIE"}), "tying PAT")
	check(not AM.is_clutch_call({"kind": "fg", "label": "8:00 2nd - UP 3"}), "ordinary field goal")
	check(not AM.is_clutch_call({"kind": "kickoff", "label": "GAME WINNER"}), "kickoffs aren't")


func test_no_restart_when_playing() -> void:
	var m := _manager()
	_give(m, [&"training"])
	check(m.play_music(&"training", 0.0), "plays")
	var p: AudioStreamPlayer = m._players[m._active]
	var active: int = m._active
	check(m.play_music(&"training", 0.0), "asked again")
	eq(m._active, active, "same player: no crossfade")
	check(p.playing, "still playing")
	m.free()


func test_crossfade_swaps_players() -> void:
	var m := _manager()
	_give(m, [&"training", &"hs_game"])
	m.play_music(&"training", 0.0)
	var first: int = m._active
	m.play_music(&"hs_game", 0.0)
	check(m._active != first, "the other player takes the new cue")
	eq(m.current, &"hs_game", "current cue")
	check(not m._players[first].playing, "old track stopped (no fade)")
	m.free()


func test_missing_file_keeps_music() -> void:
	var m := _manager()
	_give(m, [&"training"])
	m.play_music(&"training", 0.0)
	check(not m.play_music(&"draft_day", 0.0), "no draft_day file: false")
	eq(m.current, &"training", "training keeps going")
	check(m._players[m._active].playing, "still playing")
	check(not m.play_music(&"not_a_cue", 0.0), "unknown cue: false")
	eq(m.current, &"training", "still training")
	check(&"draft_day" in Array(m.missing_cues()).map(func(s: String) -> StringName: return StringName(s)),
		"draft_day listed as missing")
	m.free()


func test_one_shot_returns() -> void:
	var m := _manager()
	_give(m, [&"hs_game", &"win"])
	m.play_music(&"hs_game", 0.0)
	m.play_music(&"win", 0.0)
	eq(m.current, &"win", "stinger playing")
	eq(m._return_cue, &"hs_game", "remembers the game track")
	m._on_finished(m._active)
	eq(m.current, &"hs_game", "back to the game track")
	check(m._players[m._active].playing, "playing again")
	m.free()


func test_loop_during_one_shot_waits() -> void:
	var m := _manager()
	_give(m, [&"hs_game", &"training", &"championship_win", &"season_end"])
	m.play_music(&"hs_game", 0.0)
	m.play_music(&"championship_win", 0.0)
	check(m.play_music(&"training", 0.0), "accepted")
	eq(m.current, &"championship_win", "the title music isn't cut off")
	eq(m._return_cue, &"training", "training comes in after it")
	m.play_music(&"season_end", 0.0)  # another one-shot replaces it, same return
	eq(m._return_cue, &"training", "return kept")
	m._on_finished(m._active)
	eq(m.current, &"training", "then training")
	m.free()


func test_missing_loop_during_one_shot_keeps_return() -> void:
	var m := _manager()
	_give(m, [&"training", &"loss"])
	m.play_music(&"training", 0.0)
	m.play_music(&"loss", 0.0)
	check(not m.play_music(&"benched", 0.0), "no benched file")
	eq(m._return_cue, &"training", "still returns to training")
	m.free()


func test_one_shot_from_silence() -> void:
	var m := _manager()
	_give(m, [&"win"])
	m.play_music(&"win", 0.0)
	m._on_finished(m._active)
	eq(m.current, &"", "nothing to return to: silence, no error")
	m.free()


func test_stem_levels() -> void:
	var m := _manager()
	var sync := AudioStreamSynchronized.new()
	sync.stream_count = 2
	sync.set_sync_stream(0, _tone())
	sync.set_sync_stream(1, _tone())
	m._cache[&"clutch_kick"] = sync
	m._stems[&"clutch_kick"] = {&"drums": 1}
	m.play_music(&"clutch_kick", 0.0)
	check(m.set_stem_level(&"drums", 0.0, 0.0), "drums set")
	eq(sync.get_sync_stream_volume(1), AM.SILENT_DB, "drums silent")
	check(m.set_stem_level(&"drums", 1.0, 0.0), "drums back")
	eq(sync.get_sync_stream_volume(1), 0.0, "drums full")
	check(not m.set_stem_level(&"choir", 1.0, 0.0), "no choir stem")
	eq(m.stems_loaded(&"clutch_kick"), [&"drums"], "loaded stems")
	m.free()


func test_resume_game_track() -> void:
	var m := _manager()
	_give(m, [&"hs_game", &"clutch_kick"])
	m.play_music(&"hs_game", 0.0)
	m._positions[&"hs_game"] = 0.0
	m.play_music(&"clutch_kick", 0.0)
	check(m._positions.has(&"hs_game"), "game track position saved")
	check(m.play_music(&"hs_game", 0.0), "back to the game")
	eq(m.current, &"hs_game", "game track")
	m.free()
