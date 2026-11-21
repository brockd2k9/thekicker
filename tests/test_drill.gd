extends "res://tests/test_case.gd"
## Thumb Drill: 20 kicks each from 30, 40 and 50 yards, calm, neutral; the
## results text (header + one row per kick) and the summary.

const Drill := preload("res://scripts/ui/screens/career_drill.gd")


func test_kick_order() -> void:
	var m := Drill.DrillMode.new()
	eq(m.total(), 60, "60 kicks")
	var seen := []
	var wind := Wind.new()
	for i in 60:
		m.index = i
		var s := m.next_situation(RandomNumberGenerator.new(), KickTuning.new(), wind)
		seen.append(s.distance_yards)
		eq(s.wind_mph, 0.0, "calm")
		eq(s.pressure, Drill.PRESSURE, "the same pressure every kick")
	eq(seen.slice(0, 20).all(func(d): return d == 30), true, "20 from 30")
	eq(seen.slice(20, 40).all(func(d): return d == 40), true, "20 from 40")
	eq(seen.slice(40, 60).all(func(d): return d == 50), true, "20 from 50")
	wind.free()
	m.index = 60
	check(not m.wants_next_kick(), "then it stops")


func test_results_text() -> void:
	var d: Node = Drill.new()
	for i in 60:
		d._rows.append({"yd": Drill.DISTANCES[i / 20], "made": i % 3 != 0, "out": "GOOD", "speed": 4.1,
			"path": [[0.0, 0.0], [0.0, 0.5]]})
	var lines: PackedStringArray = d.results_text().split("\n")
	eq(lines.size(), 61, "a header and 60 kicks")
	var head: Variant = JSON.parse_string(lines[0])
	check(head is Dictionary and head["kicker"] == "neutral", "the header says how it was measured")
	var row: Variant = JSON.parse_string(lines[1])
	eq((row as Array).size(), Drill.COLS.size(), "one value per column")
	var sum: Dictionary = d.summary()
	eq(int(sum[30][1]), 20, "20 at 30")
	eq(int(sum[50][0]) + int(sum[40][0]) + int(sum[30][0]), 40, "made counted")
	d.free()


func test_path_is_8_points_in_screen_heights() -> void:
	var s := Swipe.new()
	s.screen_height = 1000.0
	s.start = Vector2(500, 900)
	s.end = Vector2(500, 400)
	s.points = PackedVector2Array([s.start, Vector2(500, 650), s.end])
	var p: Array = Drill._path(s)
	eq(p.size(), 8, "8 points")
	eq(p[7], [0.0, 0.5], "half a screen up")
